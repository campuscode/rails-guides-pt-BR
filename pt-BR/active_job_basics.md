**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Básico de Active Jobs
=================

Este guia oferece a você tudo o que você precisa para começar a criar, enfileirar e executar *jobs* em *background*

Depois de ler este guia, você saberá:

* Como criar *jobs*
* Como enfileirar *jobs*
* como executar *jobs* em segundo plano 
* Como enviar emails de sua aplicação de maneira assíncrona 

--------------------------------------------------------------------------------

Introdução 
------------

O *Active Job* é um *framework* para declarar *jobs* e fazê-los executar em uma variedade de *backends* de fila. Estes *jobs* podem ser qualquer coisa, de limpezas programadas regularmente, a cobranças de despesas, a envio de emails. Qualquer coisa que possa ser cortada em pequenas unidades de trabalho e executadas paralelamente, sério. 


O Propósito do Active Job
-----------------------------

O ponto principal é garantir que todas as aplicações Rails terão uma infraestrutura
de *jobs* no lugar. Nós podemos então ter *features* de *frameworks* e outras *gems*
construídas em cima dela, sem ter que nos preocupar com diferenças de API entre vários
executadores de *job* como *Delayed Job* e *Resque*. Dessa forma, escolher o seu *backend* 
de enfileiramento se torna mais uma preocupação operacional. E você poderá alternar entre eles sem
ter que reescrever os seus *jobs*. 

NOTE: Rails por padrão vem com uma implementação de fila assíncrona que executa *jobs*
com uma *pool* de *threads* no processo. *Jobs* serão executados da maneira assíncrona, mas
quaisquer *jobs* na fila serão derrubados ao reinicializar.


Creating a Job
--------------

This section will provide a step-by-step guide to creating a job and enqueuing it.

### Create the Job

Active Job provides a Rails generator to create jobs. The following will create a
job in `app/jobs` (with an attached test case under `test/jobs`):

```bash
$ rails generate job guests_cleanup
invoke  test_unit
create    test/jobs/guests_cleanup_job_test.rb
create  app/jobs/guests_cleanup_job.rb
```

You can also create a job that will run on a specific queue:

```bash
$ rails generate job guests_cleanup --queue urgent
```

If you don't want to use a generator, you could create your own file inside of
`app/jobs`, just make sure that it inherits from `ApplicationJob`.

Here's what a job looks like:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*guests)
    # Do something later
  end
end
```

Note that you can define `perform` with as many arguments as you want.

### Enqueue the Job

Enqueue a job like so:

```ruby
# Enqueue a job to be performed as soon as the queuing system is
# free.
GuestsCleanupJob.perform_later guest
```

```ruby
# Enqueue a job to be performed tomorrow at noon.
GuestsCleanupJob.set(wait_until: Date.tomorrow.noon).perform_later(guest)
```

```ruby
# Enqueue a job to be performed 1 week from now.
GuestsCleanupJob.set(wait: 1.week).perform_later(guest)
```

```ruby
# `perform_now` and `perform_later` will call `perform` under the hood so
# you can pass as many arguments as defined in the latter.
GuestsCleanupJob.perform_later(guest1, guest2, filter: 'some_filter')
```

That's it!

Execução de *Job*
-------------

Para enfileirar e executar *jobs* em produção você precisa configurar um *backend* de filas,
ou seja, você precisa decidir por uma *lib* de enfileiramento de terceiros que o Rails deve usar,
o Rails em si fornece apenas um sistema de filas em processo, que só mantém os *jobs* em memória(RAM).
Se o processo quebra ou a máquina é reiniciada, todos os *jobs* pendentes serão perdidos com o
*backend* assíncrono padrão. Isso pode ser bom para aplicações menores ou *jobs* não críticos, mas a maioria
das aplicações em produção precisará escolher um *backend* de persistência.

### *Backends*

O *Active Job* tem adaptadores *built-in* para múltiplos *backends* de fila (Sidekiq
Resque, Delayed Job e outros). Para obter uma lista atualizada dos adaptadores,
consulte a documentação da API para [ActiveJob::QueueAdapters](https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html).

### Configurando o *Backend*

Você pode definir facilmente o *backend* de fila:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # Be sure to have the adapter's gem in your Gemfile
    # and follow the adapter's specific installation
    # and deployment instructions.
    config.active_job.queue_adapter = :sidekiq
  end
end
```

Você também pode configurar seu *backend* por um *job* base.

```ruby
class GuestsCleanupJob < ApplicationJob
  self.queue_adapter = :resque
  #....
end

# Now your job will use `resque` as its backend queue adapter overriding what
# was configured in `config.active_job.queue_adapter`.
```

### Iniciando o *Backend*

Uma vez que os *jobs* são executados em paralelo à sua aplicação Rails, a maioria
das bibliotecas de filas exigem que você inicie um serviço de enfileiramento específico
(além de iniciar sua aplicação Rails) para que o processamento do *job* funcione. Consulte a
documentação da biblioteca para obter instruções sobre como iniciar o *backend* da fila.

Aqui está uma lista não abrangente de documentação:

- [Sidekiq](https://github.com/mperham/sidekiq/wiki/Active-Job)
- [Resque](https://github.com/resque/resque/wiki/ActiveJob)
- [Sneakers](https://github.com/jondot/sneakers/wiki/How-To:-Rails-Background-Jobs-with-ActiveJob)
- [Sucker Punch](https://github.com/brandonhilkert/sucker_punch#active-job)
- [Queue Classic](https://github.com/QueueClassic/queue_classic#active-job)
- [Delayed Job](https://github.com/collectiveidea/delayed_job#active-job)

Filas
-----

A maioria dos *adapters* suportam múltiplas filas. Com o *Active Job* você pode agendar
o *job* para executar em uma fila específica:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  #....
end
```

Você pode prefixar o nome da fila para todos os *jobs* usando
`config.active_job.queue_name_prefix` in `application.rb`:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
  end
end

# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  #....
end

# Agora seu job irá executar na fila production_low_priority no seu
# ambiente de produção e na staging_low_priority
# no seu ambiente de desenvolvimento
```

O prefixo delimitador padrão de nome de fila é '\_'. Isso pode ser alterado configurando o
`config.active_job.queue_name_delimiter` no `application.rb`:

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
    config.active_job.queue_name_delimiter = '.'
  end
end

# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  #....
end

# Agora seu job irá executar na fila production.low.priority no seu
# ambiente de produção e na staging.low.priority
# no seu ambiente de desenvolvimento
```

Se você quiser mais controle em qual fila um *job* será executado, você pode passar
uma opção `:queue` ao `#set`:

```ruby
MyJob.set(queue: :another_queue).perform_later(record)
```

Para controlar a fila a partir do nível do *job*, você pode passar um bloco para `#queue_as`.
O bloco será executado no contexto do *job* (o que te permite acessar `self.arguments`) e você
deve retornar o nome da fila:

```ruby
class ProcessVideoJob < ApplicationJob
  queue_as do
    video = self.arguments.first
    if video.owner.premium?
      :premium_videojobs
    else
      :videojobs
    end
  end

  def perform(video)
    # Processa o vídeo
  end
end

ProcessVideoJob.perform_later(Video.last)
```

NOTE: Tenha certeza de que o seu *backend* de fila "escuta" o nome da fila.
Para alguns *backends* você precisará especificar as filas a serem "ouvidas".


*Callbacks*
---------

O *Active Job* fornece Hooks para disparar lógica durante o ciclo de vida de um *Job*.
Assim como em outros *callbacks* no Rails, você pode implementar *callbacks*
como métodos comuns e usar um método macro de classe para registrá-los
como *callbacks*:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  around_perform :around_cleanup

  def perform
    # Do something later
  end

  private
    def around_cleanup
      # Do something before perform
      yield
      # Do something after perform
    end
end
```

Os métodos macro de classe podem também receber um bloco. Considere usar esse estilo,
se o código dentro do bloco for tão pequeno que cabe numa única linha.
Por exemplo, você pode enviar métricas para cada *job* enfileirado:

```ruby
class ApplicationJob < ActiveJob::Base
  before_enqueue { |job| $statsd.increment "#{job.class.name.underscore}.enqueue" }
end
```

### *Callbacks* disponíveis

* `before_enqueue`
* `around_enqueue`
* `after_enqueue`
* `before_perform`
* `around_perform`
* `after_perform`


Action Mailer
------------

One of the most common jobs in a modern web application is sending emails outside
of the request-response cycle, so the user doesn't have to wait on it. Active Job
is integrated with Action Mailer so you can easily send emails asynchronously:

```ruby
# If you want to send the email now use #deliver_now
UserMailer.welcome(@user).deliver_now

# If you want to send the email through Active Job use #deliver_later
UserMailer.welcome(@user).deliver_later
```

NOTE: Using the asynchronous queue from a Rake task (for example, to
send an email using `.deliver_later`) will generally not work because Rake will
likely end, causing the in-process thread pool to be deleted, before any/all
of the `.deliver_later` emails are processed. To avoid this problem, use
`.deliver_now` or run a persistent queue in development.


Internacionalização
-------------------

Cada *job* usa o `I18n.locale` configurado quando o *job* é criado. Isso é útil se você
enviar e-mails assincronamente:

```ruby
I18n.locale = :eo

UserMailer.welcome(@user).deliver_later # O e-mail será localizado para Esperanto.
```


Supported types for arguments
----------------------------

ActiveJob supports the following types of arguments by default:

  - Basic types (`NilClass`, `String`, `Integer`, `Float`, `BigDecimal`, `TrueClass`, `FalseClass`)
  - `Symbol`
  - `Date`
  - `Time`
  - `DateTime`
  - `ActiveSupport::TimeWithZone`
  - `ActiveSupport::Duration`
  - `Hash` (Keys should be of `String` or `Symbol` type)
  - `ActiveSupport::HashWithIndifferentAccess`
  - `Array`

### GlobalID

Active Job supports GlobalID for parameters. This makes it possible to pass live
Active Record objects to your job instead of class/id pairs, which you then have
to manually deserialize. Before, jobs would look like this:

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable_class, trashable_id, depth)
    trashable = trashable_class.constantize.find(trashable_id)
    trashable.cleanup(depth)
  end
end
```

Now you can simply do:

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

This works with any class that mixes in `GlobalID::Identification`, which
by default has been mixed into Active Record classes.

### Serializers

You can extend the list of supported argument types. You just need to define your own serializer:

```ruby
class MoneySerializer < ActiveJob::Serializers::ObjectSerializer
  # Checks if an argument should be serialized by this serializer.
  def serialize?(argument)
    argument.is_a? Money
  end

  # Converts an object to a simpler representative using supported object types.
  # The recommended representative is a Hash with a specific key. Keys can be of basic types only.
  # You should call `super` to add the custom serializer type to the hash.
  def serialize(money)
    super(
      "amount" => money.amount,
      "currency" => money.currency
    )
  end

  # Converts serialized value into a proper object.
  def deserialize(hash)
    Money.new(hash["amount"], hash["currency"])
  end
end
```

and add this serializer to the list:

```ruby
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

Exceptions
----------

Active Job provides a way to catch exceptions raised during the execution of the
job:

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    # Do something with the exception
  end

  def perform
    # Do something later
  end
end
```

### Retrying or Discarding failed jobs

It's also possible to retry or discard a job if an exception is raised during execution.
For example:

```ruby
class RemoteServiceJob < ApplicationJob
  retry_on CustomAppException # defaults to 3s wait, 5 attempts

  discard_on ActiveJob::DeserializationError

  def perform(*args)
    # Might raise CustomAppException or ActiveJob::DeserializationError
  end
end
```

To get more details see the API Documentation for [ActiveJob::Exceptions](https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html).

### Deserialization

GlobalID allows serializing full Active Record objects passed to `#perform`.

If a passed record is deleted after the job is enqueued but before the `#perform`
method is called Active Job will raise an `ActiveJob::DeserializationError`
exception.

Testando os *Jobs*
--------------

Você pode encontrar instruções mais detalhadas sobre como testar seus *jobs* no
[guia de teste](testing.html#testing-jobs).
