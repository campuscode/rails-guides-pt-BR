**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

_Threading_ e Execução de Código no Rails
=========================================

Depois de ler esse guia, você vai saber:

* Quais códigos o Rails executa automaticamente de maneira concorrente
* Como integrar código concorrente feito por você com a parte interna do Rails
* Como envolver todo o código da aplicação
* Como modificar o recarregamento da aplicação

--------------------------------------------------------------------------------

Concorrência Automática
-----------------------

O Rails automaticamente permite que várias operações sejam feitas ao mesmo tempo.

Quando um servidor web que utiliza *threads* está em uso, como o Puma, que é padrão,
múltiplas requisições HTTP serão servidas simultaneamente, com cada requisição
utilizando sua própria instância de *controller*.



Adaptadores do Active Job que usam *thread*, incluindo o Async, que é padrão, vai
executar vários *jobs* ao mesmo tempo. Os canais (*channels*) Action Cable também
são gerenciados dessa forma.

Todos esses mecanismos envolvem múltiplas *threads*, cada uma gerenciando trabalho
para uma única instância de algum objeto (*controller*, *job*, *channel*), enquanto
compartilham o espaço global do processo (classes e suas configurações e variáveis globais).
Contanto que seu código não modifique nenhuma dessas coisas compartilhadas, ele pode
quase esquecer que outras *threads* existem.

O resto desse guia vai mostrar os mecanismos que o Rails usa para fazer com que
suas *threads* sejam "quase ignoráveis" e como extensões e aplicações com necessidades
especiais podem usar esse aparato.

Executor
--------

O *Rails Executor* separa o código da sua aplicação do código de *framework*:
toda vez que o *framework* invoca código que você escreveu em sua aplicação, ele
vai estar envolvido pelo *Executor*.

O *Executor* consiste em dois *callbacks*: `to_run` e `to_complete`. O *callback*
*Run* é chamado antes do código da aplicação e o *Complete* é chamado após o código
da aplicação.

### Callbacks Padrões

Em uma aplicação Rails padrão, os *callbacks* do *Executor* são usados para:

* acompanhar quais *threads* estão em uma posição segura para carregar e recarregar código automaticamente (*autoloading* e *reloading*).
* habilitar e desabilitar o cache do Active Record
* retornar conexões Active Record adquiridas para o *pool* de conexões.
* controlar a duração dos caches internos

Antes do Rails 5.0, algumas dessas funções eram gerenciadas por *middlewares* Rack
(como `ActiveRecord::ConnectionAdapters::ConnectionManagement`) ou envolvendo o código
diretamente com métodos como `ActiveRecord::Base.connection_pool.with_connection`.
O *Executor* substitui essas interfaces por uma mais simples e mais abstrata.

### Envolvendo Código da Aplicação

Se você está escrevendo uma biblioteca ou componente que vai invocar código da aplicação,
você deve envolver esse código com uma chamada para o *Executor*:

```ruby
Rails.application.executor.wrap do
  # chame o código da aplicação aqui
end
```

TIP: Se você quiser repetidamente invocar código da aplicação de um processo de
longa duração, talvez você queira usar o [*Reloader*](#reloader) ao invés do *Executor*.

Toda *thread* deve ser envolvida antes de rodar código da aplicação, então se sua
aplicação manualmente delega trabalho para outras *threads* utilizando, por exemplo
`Thread.new` ou funcionalidades da biblioteca Concurrent Ruby que usam *pools* de
*threads*, você deve imediatamente envolver o bloco:

```ruby
Thread.new do
  Rails.application.executor.wrap do
    # seu código aqui
  end
end
```

NOTE: A biblioteca Concurrent Ruby usa um objeto `ThreadPoolExecutor`, que as vezes se configura
com uma opção chamada `executor`. Apesar do nome, isso não se relaciona com o *Executor* do Rails.

O *Executor* admite re-entradas seguramente. Se ele já está ativo na *thread* atual,
`wrap` não faz nada (é uma *no-op*).

Se não for possível envolver o código da aplicação em um bloco (como por exemplo
a API Rack, que torna isso difícil), você pode utilizar o par de métodos `run!`
/ `complete!`:


```ruby
Thread.new do
  execution_context = Rails.application.executor.run!
  # seu código aqui
ensure
  execution_context.complete! if execution_context
end
```

### Concorrência

O *Executor* vai colocar a *thread* atual no modo `running`, no [Load Interlock](#load-interlock).
Essa operação irá bloquear temporariamente outras *threads* que estejam carregando automaticamante
(*autoloading*) uma constante ou que estejam carregando ou recarregando a aplicação.

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

Comportamento do *Framework*
----------------------------

Os componentes do *framework* Rails também utilizam essas ferramentas para gerenciar
suas necessidades relacionadas à concorrência.

`ActionDispatch::Executor` e `ActionDispatch::Reloader` são *middlewares* Rack
que envolvem requisições com o *Executor* ou *Reloader* fornecido. Esses componentes
são automaticamente incluídos na pilha de *middlewares* de uma aplicação padrão.
O *Reloader* irá garantir que qualquer requisição HTTP seja servida com a cópia
mais recente possível da aplicação se houver qualquer mudança de código.

O Active Job também envolve a execução de *jobs* com o *Reloader*, carregando a
última versão do código para executar cada *job* assim que sai da fila para ser executado.

Ao invés de utilizar o *Reloader*, o Action Cable usa o *Executor*: já que cada conexão *Cable*
é associada a uma instância de uma classe, não é possível recarregar a cada mensagem WebSocket.
Somente o *message handler* é envolvido pelo *Reloader* a propósito. Uma conexão
de longa duração não previne o recarregamento a aplicação promovido por uma requisição ou
*job*. Ao invés disso, o Action Cable utiliza o *callback* `before_class_unload`
do *Reloader* para desconectar todas as suas conexões. Quando o cliente automaticamente
reconectar, ele irá se comunicar com a nova versão do código.

Os pontos acima são *entry points* para o *framework*, logo eles são responsáveis
por garantir a proteção de suas *threads* e por decidir quando um recarregamento
é necessário. Outros componentes utilizam apenas o *Executor* quando criam *threads*
adicionais.

### Configuração

O *Reloader* apenas verifica mudanças em arquivos se `cache_classes` for falso e
`reload_classes_only_on_change` for verdadeiro (que é o padrão no ambiente `development`).

Quando `cache_classes` for verdadeiro (em `production`, por padrão), o *Reloader*
passa o controle imediatamente para o *Executor*.

O *Executor* sempre tem coisas importantes para fazer, como gerenciar as conexões
do banco de dados. Quando `cache_classes` e `eager_load` são verdadeiros (`production`),
nenhum autocarregamento ou recarregamento de classes irá ocorrer, então o *Load Interlock*
não é necessário. Se algum dessas configurações forem falsas (`development`), o *Executor*
irá usar o *Load Interlock* para garantir que constantes só serão carregadas quando for
seguro.

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
