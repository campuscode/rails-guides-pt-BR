**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Threading and Code Execution in Rails
=====================================

After reading this guide, you will know:

* What code Rails will automatically execute concurrently
* How to integrate manual concurrency with Rails internals
* How to wrap all application code
* How to affect application reloading

--------------------------------------------------------------------------------

Automatic Concurrency
---------------------

Rails automatically allows various operations to be performed at the same time.

When using a threaded web server, such as the default Puma, multiple HTTP
requests will be served simultaneously, with each request provided its own
controller instance.

Threaded Active Job adapters, including the built-in Async, will likewise
execute several jobs at the same time. Action Cable channels are managed this
way too.

These mechanisms all involve multiple threads, each managing work for a unique
instance of some object (controller, job, channel), while sharing the global
process space (such as classes and their configurations, and global variables).
As long as your code doesn't modify any of those shared things, it can mostly
ignore that other threads exist.

The rest of this guide describes the mechanisms Rails uses to make it "mostly
ignorable", and how extensions and applications with special needs can use them.

Executor
--------

The Rails Executor separates application code from framework code: any time the
framework invokes code you've written in your application, it will be wrapped by
the Executor.

The Executor consists of two callbacks: `to_run` and `to_complete`. The Run
callback is called before the application code, and the Complete callback is
called after.

### Default callbacks

In a default Rails application, the Executor callbacks are used to:

* track which threads are in safe positions for autoloading and reloading
* enable and disable the Active Record query cache
* return acquired Active Record connections to the pool
* constrain internal cache lifetimes

Prior to Rails 5.0, some of these were handled by separate Rack middleware
classes (such as `ActiveRecord::ConnectionAdapters::ConnectionManagement`), or
directly wrapping code with methods like
`ActiveRecord::Base.connection_pool.with_connection`. The Executor replaces
these with a single more abstract interface.

### Wrapping application code

If you're writing a library or component that will invoke application code, you
should wrap it with a call to the executor:

```ruby
Rails.application.executor.wrap do
  # call application code here
end
```

TIP: If you repeatedly invoke application code from a long-running process, you
may want to wrap using the [Reloader](#reloader) instead.

Each thread should be wrapped before it runs application code, so if your
application manually delegates work to other threads, such as via `Thread.new`
or Concurrent Ruby features that use thread pools, you should immediately wrap
the block:

```ruby
Thread.new do
  Rails.application.executor.wrap do
    # your code here
  end
end
```

NOTE: Concurrent Ruby uses a `ThreadPoolExecutor`, which it sometimes configures
with an `executor` option. Despite the name, it is unrelated.

The Executor is safely re-entrant; if it is already active on the current
thread, `wrap` is a no-op.

If it's impractical to wrap the application code in a block (for
example, the Rack API makes this problematic), you can also use the `run!` /
`complete!` pair:

```ruby
Thread.new do
  execution_context = Rails.application.executor.run!
  # your code here
ensure
  execution_context.complete! if execution_context
end
```

### Concurrency

The Executor will put the current thread into `running` mode in the [Load
Interlock](#load-interlock). This operation will block temporarily if another
thread is currently either autoloading a constant or unloading/reloading
the application.

Reloader
--------

Assim como o *Executor*, o *Reloader* também envolve o código da aplicação.
Se o *Executor* ainda não estiver ativo na *thread* atual, o *Reloader* vai
invocá-lo para você, logo você só precisa chamar o *Reloader*. Isso garante que
tudo que o *Reloader* faça, inclusive suas invocações de *callback*, ocorram envolvidas
pelo *Executor*.

```ruby
Rails.application.reloader.wrap do
  # call application code here
end
```

O *Reloader* é mais indicado para processos de longa duração de nível de *framework*
que chamam repetidamente o código da aplicação, como servidores web e filas de *jobs*.
O Rails automaticamente envolve requisições web e *workers* do Active Job, logo
você raramente precisará invocar o *Reloader* por si mesmo. Sempre se pergunte se
o *Executor* não seria a melhor opção para o seu caso de uso.

### *Callbacks*

Antes de executar o bloco envolvido, o *Reloader* vai verificar se a aplicação que
está rodando precisa ser recarregada. Por exemplo, talvez o código fonte de um *model*
tenha sido alterado. Se é determinado que um recarregamento é necessário, o *Reloader*
esperará até que seja seguro fazer isso e depois disso irá recarregar a aplicação
antes de continuar. Quando a aplicação está configurada para sempre ser recarregada,
indepentende de modificações, o recarregamento da aplicação é feito no final do bloco,
ao invés de no começo.

O *Reloader* também oferece os *callbacks* `to_run` e `to_complete`. Eles são
invocados nos mesmos pontos do *Executor*, mas somente quando a execução atual começar
um recarregamento da aplicação. Quando o recarregamento não é necessário, o *Reloader*
irá invocar o bloco envolvido por ele sem executar os *callbacks*.

### Descarregamento de Classes

A parte mais trabalhosa do processo de recarregamento é o Descarregamento de Classes,
em que todas as classes automaticamente carregadas são removidas e ficam prontas para
ser carregadas de novo. Isso irá ocorrer imediatamente antes do *callback* Run ou Complete,
dependendo do valor da configuração `reload_classes_only_on_change`.

Na maioria das vezes, algumas ações extras precisam ser feitas exatamente no momento
antes ou no momento posterior ao Descarregamento de Classes, logo o *Reloader* também
fornece os *callbacks* `before_class_unload` e `after_class_unload`.

### Concorrência

Somente processos "top level" de longa duração devem invocar o *Reloader*, porque
se ele determinar que um recarregamento é necessário, ele vai bloquear até que
todas as outras *threads* tenham terminado qualquer invocação do *Executor*.

Se isso ocorrer numa *sub-thread*, com a *thread* pai esperando dentro do *Executor*,
isso irá causar um bloqueio permanente (*deadlock*) inevitável: o recarregamento
deve ocorrer antes da *sub-thread* ser executada, mas ela não pode ser invocada com
segurança enquanto a *thread* pai está em execução. *Sub-threads* devem usar somente o
*Executor*.

Framework Behavior
------------------

The Rails framework components use these tools to manage their own concurrency
needs too.

`ActionDispatch::Executor` and `ActionDispatch::Reloader` are Rack middlewares
that wrap requests with a supplied Executor or Reloader, respectively. They
are automatically included in the default application stack. The Reloader will
ensure any arriving HTTP request is served with a freshly-loaded copy of the
application if any code changes have occurred.

Active Job also wraps its job executions with the Reloader, loading the latest
code to execute each job as it comes off the queue.

Action Cable uses the Executor instead: because a Cable connection is linked to
a specific instance of a class, it's not possible to reload for every arriving
WebSocket message. Only the message handler is wrapped, though; a long-running
Cable connection does not prevent a reload that's triggered by a new incoming
request or job. Instead, Action Cable uses the Reloader's `before_class_unload`
callback to disconnect all its connections. When the client automatically
reconnects, it will be speaking to the new version of the code.

The above are the entry points to the framework, so they are responsible for
ensuring their respective threads are protected, and deciding whether a reload
is necessary. Other components only need to use the Executor when they spawn
additional threads.

### Configuration

The Reloader only checks for file changes when `cache_classes` is false and
`reload_classes_only_on_change` is true (which is the default in the
`development` environment).

When `cache_classes` is true (in `production`, by default), the Reloader is only
a pass-through to the Executor.

The Executor always has important work to do, like database connection
management. When `cache_classes` and `eager_load` are both true (`production`),
no autoloading or class reloading will occur, so it does not need the Load
Interlock. If either of those are false (`development`), then the Executor will
use the Load Interlock to ensure constants are only loaded when it is safe.

Load Interlock
--------------

The Load Interlock allows autoloading and reloading to be enabled in a
multi-threaded runtime environment.

When one thread is performing an autoload by evaluating the class definition
from the appropriate file, it is important no other thread encounters a
reference to the partially-defined constant.

Similarly, it is only safe to perform an unload/reload when no application code
is in mid-execution: after the reload, the `User` constant, for example, may
point to a different class. Without this rule, a poorly-timed reload would mean
`User.new.class == User`, or even `User == User`, could be false.

Both of these constraints are addressed by the Load Interlock. It keeps track of
which threads are currently running application code, loading a class, or
unloading autoloaded constants.

Only one thread may load or unload at a time, and to do either, it must wait
until no other threads are running application code. If a thread is waiting to
perform a load, it doesn't prevent other threads from loading (in fact, they'll
cooperate, and each perform their queued load in turn, before all resuming
running together).

### `permit_concurrent_loads`

The Executor automatically acquires a `running` lock for the duration of its
block, and autoload knows when to upgrade to a `load` lock, and switch back to
`running` again afterwards.

Other blocking operations performed inside the Executor block (which includes
all application code), however, can needlessly retain the `running` lock. If
another thread encounters a constant it must autoload, this can cause a
deadlock.

For example, assuming `User` is not yet loaded, the following will deadlock:

```ruby
Rails.application.executor.wrap do
  th = Thread.new do
    Rails.application.executor.wrap do
      User # inner thread waits here; it cannot load
           # User while another thread is running
    end
  end

  th.join # outer thread waits here, holding 'running' lock
end
```

To prevent this deadlock, the outer thread can `permit_concurrent_loads`. By
calling this method, the thread guarantees it will not dereference any
possibly-autoloaded constant inside the supplied block. The safest way to meet
that promise is to put it as close as possible to the blocking call:

```ruby
Rails.application.executor.wrap do
  th = Thread.new do
    Rails.application.executor.wrap do
      User # inner thread can acquire the 'load' lock,
           # load User, and continue
    end
  end

  ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    th.join # outer thread waits here, but has no lock
  end
end
```

Another example, using Concurrent Ruby:

```ruby
Rails.application.executor.wrap do
  futures = 3.times.collect do |i|
    Concurrent::Promises.future do
      Rails.application.executor.wrap do
        # do work here
      end
    end
  end

  values = ActiveSupport::Dependencies.interlock.permit_concurrent_loads do
    futures.collect(&:value)
  end
end
```

### ActionDispatch::DebugLocks

If your application is deadlocking and you think the Load Interlock may be
involved, you can temporarily add the ActionDispatch::DebugLocks middleware to
`config/application.rb`:

```ruby
config.middleware.insert_before Rack::Sendfile,
                                  ActionDispatch::DebugLocks
```

If you then restart the application and re-trigger the deadlock condition,
`/rails/locks` will show a summary of all threads currently known to the
interlock, which lock level they are holding or awaiting, and their current
backtrace.

Generally a deadlock will be caused by the interlock conflicting with some other
external lock or blocking I/O call. Once you find it, you can wrap it with
`permit_concurrent_loads`.
