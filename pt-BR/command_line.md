**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Linhas de Comando do Rails
======================

Depois de ler este guia, você saberá:

* Como criar uma aplicação Rails.
* Como gerar *models*, *controllers*, *migrations* de banco de dados e testes de unidade.
* Como iniciar um servidor e desenvolvimento.
* Como fazer experimentos com objetos por meio de um *shell* interativo.

--------------------------------------------------------------------------------

NOTE: Esse tutorial considera que você já tenha um conhecimento básico de Rails, ou tenha lido o [Começando com o Rails](getting_started.html).

Noções Básicas de Linha de Comando
-------------------

Existem alguns comandos essenciais para o uso cotidiano do Rails. Na ordem de quanto você provavelmente irá utilizá-los são:

* `bin/rails console`
* `bin/rails server`
* `bin/rails test`
* `bin/rails generate`
* `bin/rails db:migrate`
* `bin/rails db:create`
* `bin/rails routes`
* `bin/rails dbconsole`
* `rails new app_name`

Você pode obter uma lista dos comandos do Rails disponíveis, que geralmente depende de seu diretório atual, escrevendo `rails --help`. Cada comando possui uma descrição, que deverá ajudá-lo a encontrar o que precisa.

```bash
$ rails --help
Usage: rails COMMAND [ARGS]

Os comandos de Rails mais comuns são:
 generate    Gera um novo código (tecla de atalho: "g")
 console     Inicia um console Rails (tecla de atalho: "c")
 server      Inicia um servidor Rails (tecla de atalho: "s")
 ...

Todos os comandos podem ser executados com -h (ou --help) para mais informações.

Além desses comandos, existem:
 about                               Lista a versão de todos os Rails ...
 assets:clean[keep]                  Remove os *assets* compilados antigos
 assets:clobber                      Remove os *assets* compilados
 assets:environment                  Carrega o ambiente de compilação de *assets*
 assets:precompile                   Compila todos os *assets* ...
 ...
 db:fixtures:load                    Carrega *fixtures* no ...
 db:migrate                          Migra o banco de dados ...
 db:migrate:status                   Mostra o status da migração
 db:rollback                         Retorna o *schema* de volta para ...
 db:schema:cache:clear               Limpa um arquivo db/schema_cache.yml
 db:schema:cache:dump                Cria um arquivo db/schema_cache.yml
 db:schema:dump                      Cria o schema do banco de dados (db/schema.rb ou db/structure.sql ...
 db:schema:load                      Carrega um arquivo de schema de banco de dados (db/schema.rb ou db/structure.sql ...
 db:seed                             Carrega os dados da seed ...
 db:version                          Recupera o *schema* atual ...
 ...
 restart                             Reinicia o aplicativo tocando em ...
 tmp:create                          Cria diretórios tmp ...
```

Vamos criar uma aplicação Rails simples passando por cada um destes comandos.

### `rails new`

A primeira coisa que precisamos fazer é criar uma nova aplicação Rails executando o comando
`rails new` após a instalação do Rails.

INFO: Você pode instalar a *gem* rails digitando `gem install rails`, caso ainda não esteja instalada.

```bash
$ rails new commandsapp
     create
     create  README.md
     create  Rakefile
     create  config.ru
     create  .gitignore
     create  Gemfile
     create  app
     ...
     create  tmp/cache
     ...
        run  bundle install
```

O Rails criará o que parece ser um monte de coisas pra um comando tão pequeno! Agora você tem a estrutura de diretorios do Rails inteira, com todo o código que você precisa pra rodar nossa aplicação simples sem ter que configurar mais nada.

Se você quiser fazer com que alguns arquivos ou componentes não sejam gerados, você pode 
acrescentar os seguintes arumentos ao seu comando `rails new`:

| Argumento               | Descricão                                                   |
| ----------------------- | ----------------------------------------------------------- |
| `--skip-gemfile`        | Não cria um Gemfile                                         |
| `--skip-git`            | Pula o arquivo .gitignore                                   |
| `--skip-keeps`          | Pula os arquivos .keep de controle de origem                |
| `--skip-action-mailer`  | Pula os arquivos *Action Mailer*                            |
| `--skip-action-text`    | Pula a *gem* *Action Text*                                  |
| `--skip-active-record`  | Pula os arquivos *Active Record*                            |
| `--skip-active-storage` | Pula os arquivos *Active Storage files*                     |
| `--skip-puma`           | Pula os arquivos do Puma                                    |
| `--skip-action-cable`   | Pula os arquivos *Action Cable*                             |
| `--skip-sprockets`      | Pula os arquivos do Sprockets                               |
| `--skip-spring`         | Não instala a aplicação de pré-carregamento Spring          |
| `--skip-listen`         | Não gera configuração que depende da *gem* listen           |
| `--skip-javascript`     | Pula os arquivos JavaScript                                 |
| `--skip-turbolinks`     | Pula a *gem* turbolinks                                     |
| `--skip-test`           | Pula os arquivos de teste                                   |
| `--skip-system-test`    | Pula os arquivos de teste de sistema                        |
| `--skip-bootsnap`       | Pula a *gem* bootsnap                                       |

### `bin/rails server`

O coomando `bin/rails server` inicia um servidor web chamado Puma que vem com o Rails. Você vai utilizá-lo sempre que quiser acessar sua aplicação por um navegador.

Sem que precisemos fazer mais nada, o comando `bin/rails server` executa a nossa aplicação Rails novinha em folha:

```bash
$ cd commandsapp
$ bin/rails server
=> Booting Puma
=> Rails 6.0.0 application starting in development
=> Run `bin/rails server --help` for more startup options
Puma starting in single mode...
* Version 3.12.1 (ruby 2.5.7-p206), codename: Llamas in Pajamas
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://localhost:3000
Use Ctrl-C to stop
```

Com apenas três comandos, produzimos um servidor Rails escutando na porta 3000. Vá até o seu navegador, abra [http://localhost:3000](http://localhost:3000) e veja a aplicação Rails básica rodando.

INFO: Você também pode utilizar a abreviação "s" pra iniciar o servidor: `bin/rails s`.

O servidor pode ser executado utilizando uma porta diferente com a opção `-p`. O ambiente de desenvolvimento padrão pode ser modificado usando `-e`.

```bash
$ bin/rails server -e production -p 4000
```

A opção `-b` vincula o Rails a um IP especificado que, por padrão, é o *localhost*. Você pode rodar um servidor como *daemon* passando a opção `-d`.

### `bin/rails generate`

O comando `bin/rails generate` usa um *template* pra criar um monte de coisas. Executar `bin/rails generate` sozinho retorna uma lista de vários geradores disponíveis:

INFO: Você pode usar o atalho "g" para chamar o comando *generate*: `bin/rails g`.

```bash
$ bin/rails generate
Usage: rails generate GENERATOR [args] [options]

...
...

Please choose a generator below.

Rails:
  assets
  channel
  controller
  generator
  ...
  ...
```

NOTE: Você pode instalar mais geradores por meio de *gems* de geradores, partes de *plugins* que você sem dúvida vai instalar, e você pode até criar seus próprios!

Usar geradores economiza bastante tempo porque envolve escrever **código *boilerplate*** (ou padrão), código necessário para que a aplicação funcione.

Vamos fazer nosso próprio *controller* com o gerador de *controllers*. Mas qual comando devemos usar? Vamos perguntar ao gerador:

INFO: Todos os serviços do console do Rails têm textos de ajuda. Como ocorre com a maioria dos comandos \*nix, você pode tentar adicionar `--help` ou `-h` no final (por exemplo: `bin/rails server --help`).

```bash
$ bin/rails generate controller
Usage: bin/rails generate controller NAME [action action] [options]

...
...

Description:
    ...

    To create a controller within a module, specify the controller name as a path like 'parent_module/controller_name'.

    ...

Example:
    `bin/rails generate controller CreditCards open debit credit close`

    Credit card controller with URLs like /credit_cards/debit.
        Controller: app/controllers/credit_cards_controller.rb
        Test:       test/controllers/credit_cards_controller_test.rb
        Views:      app/views/credit_cards/debit.html.erb [...]
        Helper:     app/helpers/credit_cards_helper.rb
```

O gerador de *controller* precisa de parâmtros no seguinte formato: `generate controller NomeDoController ação1 ação2`. Vamos fazer o *controller* `Greetings` com uma ação **hello**, que dirá algo legal pra gente.

```bash
$ bin/rails generate controller Greetings hello
     create  app/controllers/greetings_controller.rb
      route  get 'greetings/hello'
     invoke  erb
     create    app/views/greetings
     create    app/views/greetings/hello.html.erb
     invoke  test_unit
     create    test/controllers/greetings_controller_test.rb
     invoke  helper
     create    app/helpers/greetings_helper.rb
     invoke    test_unit
     invoke  assets
     invoke    scss
     create      app/assets/stylesheets/greetings.scss
```

O que foi tudo isso que o comando gerou? Ele gerou vários diretórios na nossa aplicação e criou um arquivo de *controller*, um arquivo de *view*, um arquivo de teste funcional, um *helper* pra *view*, um arquivo Javascript e um arquivo de folha de estilo em cascata.

Dê uma olhada no *controller* e faça a seguinte pequena modificação no arquivo `app/controllers/greetings_controller.rb`:

```ruby
class GreetingsController < ApplicationController
  def hello
    @message = "Olá. Como vai você?"
  end
end
```

Agora edite a *view* para que ela exiba a nossa mensagem (em `app/views/greetings/hello.html.erb`):

```erb
<h1>Uma mensagem pra você!</h1>
<p><%= @message %></p>
```

Rode o seu servidor usando o comando `bin/rails server`.

```bash
$ bin/rails server
=> Booting Puma...
```

O URL será [http://localhost:3000/greetings/hello](http://localhost:3000/greetings/hello).

INFO: Em uma aplicação comum de Rails, seus URLs vão geralmente seguir o seguinte padrão: http://(host)/(controller)/(action). Um URL como http://(host)/(controller) vai direcionar você pra ação **index** daquele *controller*.

O Rails também vem com um gerador para os *models* de dados.

```bash
$ bin/rails generate model
Usage:
  bin/rails generate model NAME [field[:type][:index] field[:type][:index]] [options]

...

ActiveRecord options:
      [--migration], [--no-migration]        # Indicates when to generate migration
                                             # Default: true

...

Description:
    Generates a new model. Pass the model name, either CamelCased or
    under_scored, and an optional list of attribute pairs as arguments.

...
```

NOTA: Para obter uma lista dos tipos de campos disponíveis para o parâmetro `type`, consulte a [documentação API](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column) para o métodos *add_column* (adicionar coluna) do módulo `SchemaStatements`. O parâmetro `index` gera um índice correspondente para a coluna.

Mas em vez de gerar o *model* diretamente (o que faremos depois), vamos configurar um *scaffold*. Um ***scaffold*** em Rails é um conjunto completo de *model*, a *migration* da base de dados para esse *model*, o *controller* para manipulá-lo, *views* para visualizar e manipular os dados e um conjunto de testes para cada um dos itens descritos acima.

Vamos configurar uma *resource* simples chamado "HighScore" que contabiliza nossas pontuações mais altas no jogos de videogame que jogamos.

```bash
$ bin/rails generate scaffold HighScore game:string score:integer
    invoke  active_record
    create    db/migrate/20190416145729_create_high_scores.rb
    create    app/models/high_score.rb
    invoke    test_unit
    create      test/models/high_score_test.rb
    create      test/fixtures/high_scores.yml
    invoke  resource_route
     route    resources :high_scores
    invoke  scaffold_controller
    create    app/controllers/high_scores_controller.rb
    invoke    erb
    create      app/views/high_scores
    create      app/views/high_scores/index.html.erb
    create      app/views/high_scores/edit.html.erb
    create      app/views/high_scores/show.html.erb
    create      app/views/high_scores/new.html.erb
    create      app/views/high_scores/_form.html.erb
    invoke    test_unit
    create      test/controllers/high_scores_controller_test.rb
    create      test/system/high_scores_test.rb
    invoke    helper
    create      app/helpers/high_scores_helper.rb
    invoke      test_unit
    invoke    jbuilder
    create      app/views/high_scores/index.json.jbuilder
    create      app/views/high_scores/show.json.jbuilder
    create      app/views/high_scores/_high_score.json.jbuilder
    invoke  assets
    invoke    scss
    create      app/assets/stylesheets/high_scores.scss
    invoke  scss
    create    app/assets/stylesheets/scaffolds.scss
```

O gerador verifica os diretórios existentes em busca de *models*, *controllers*, *helpers*, layouts, testes funcionais e unitários, folhas de estilo de cascata, e cria as *views*, os *controllers* e a *migration* de banco de dados para *HighScore* (criando a tabela e os campos `high_scores`. Além disso, o gerador se encarrega da rota para a ***resource*** e dos novos testes para tudo.

A *migration* precise que migremos, ou seja, que executemos um código em Ruby (contido em `20130717151933_create_high_scores.rb`) que modifica o *schema* (esquema) do nosso banco de dados. Mas qual banco de dados? O banco de dados SQLite3 que o Rails vai criar para nós quando executarmos o comando `bin/rails db:migrate`. Falaremos mais sobre esse comando a seguir.

```bash
$ bin/rails db:migrate
==  CreateHighScores: migrating ===============================================
-- create_table(:high_scores)
   -> 0.0017s
==  CreateHighScores: migrated (0.0019s) ======================================
```

INFO: Vamos falar sobre testes unitários. Testes unitários são códigos que testam e
fazem afirmações sobre o código. Com testes unitários, pegamos um pequeno trecho de código, 
digamos, um método ou um *model*, e testamos suas entradas e saídas. Testes unitários são
seus amigos. Quantos antes vocês aceitar o fato de que a sua qualidade de vida vai aumentar
drasticamente quando você faz testes unitários no seu código, melhor. Sério. Por favor, vá
em [the testing guide](https://guides.rubyonrails.org/testing.html) para uma visão mais 
aprofundada de testes unitários.

Vejamos a interface que o Rails criou para nós.

```bash
$ bin/rails server
```

Abra o seu navegador e digite [http://localhost:3000/high_scores](http://localhost:3000/high_scores). Agora podemos criar novas pontuações máximas (55,160 no *Space Invaders*!)

### `bin/rails console`

The `console` command lets you interact with your Rails application from the command line. On the underside, `bin/rails console` uses IRB, so if you've ever used it, you'll be right at home. This is useful for testing out quick ideas with code and changing data server-side without touching the website.

INFO: You can also use the alias "c" to invoke the console: `bin/rails c`.

You can specify the environment in which the `console` command should operate.

```bash
$ bin/rails console -e staging
```

If you wish to test out some code without changing any data, you can do that by invoking `bin/rails console --sandbox`.

```bash
$ bin/rails console --sandbox
Loading development environment in sandbox (Rails 5.1.0)
Any modifications you make will be rolled back on exit
irb(main):001:0>
```

#### The app and helper objects

Inside the `bin/rails console` you have access to the `app` and `helper` instances.

With the `app` method you can access named route helpers, as well as do requests.

```irb
irb> app.root_path
=> "/"

irb> app.get _
Started GET "/" for 127.0.0.1 at 2014-06-19 10:41:57 -0300
...
```

With the `helper` method it is possible to access Rails and your application's helpers.

```irb
irb> helper.time_ago_in_words 30.days.ago
=> "about 1 month"

irb> helper.my_custom_helper
=> "my custom helper"
```

### `bin/rails dbconsole`

`bin/rails dbconsole` figures out which database you're using and drops you into whichever command line interface you would use with it (and figures out the command line parameters to give to it, too!). It supports MySQL (including MariaDB), PostgreSQL, and SQLite3.

INFO: You can also use the alias "db" to invoke the dbconsole: `bin/rails db`.

If you are using multiple databases, `bin/rails dbconsole` will connect to the primary database by default. You can specify which database to connect to using `--database` or `--db`:

```bash
$ bin/rails dbconsole --database=animals
```

### `bin/rails runner`

`runner` runs Ruby code in the context of Rails non-interactively. For instance:

```bash
$ bin/rails runner "Model.long_running_method"
```

INFO: You can also use the alias "r" to invoke the runner: `bin/rails r`.

You can specify the environment in which the `runner` command should operate using the `-e` switch.

```bash
$ bin/rails runner -e staging "Model.long_running_method"
```

You can even execute ruby code written in a file with runner.

```bash
$ bin/rails runner lib/code_to_be_run.rb
```

### `bin/rails destroy`

Think of `destroy` as the opposite of `generate`. It'll figure out what generate did, and undo it.

INFO: You can also use the alias "d" to invoke the destroy command: `bin/rails d`.

```bash
$ bin/rails generate model Oops
      invoke  active_record
      create    db/migrate/20120528062523_create_oops.rb
      create    app/models/oops.rb
      invoke    test_unit
      create      test/models/oops_test.rb
      create      test/fixtures/oops.yml
```
```bash
$ bin/rails destroy model Oops
      invoke  active_record
      remove    db/migrate/20120528062523_create_oops.rb
      remove    app/models/oops.rb
      invoke    test_unit
      remove      test/models/oops_test.rb
      remove      test/fixtures/oops.yml
```

### `bin/rails about`

`bin/rails about` gives information about version numbers for Ruby, RubyGems, Rails, the Rails subcomponents, your application's folder, the current Rails environment name, your app's database adapter, and schema version. It is useful when you need to ask for help, check if a security patch might affect you, or when you need some stats for an existing Rails installation.

```bash
$ bin/rails about
About your application's environment
Rails version             6.0.0
Ruby version              2.5.0 (x86_64-linux)
RubyGems version          2.7.3
Rack version              2.0.4
JavaScript Runtime        Node.js (V8)
Middleware:               Rack::Sendfile, ActionDispatch::Static, ActionDispatch::Executor, ActiveSupport::Cache::Strategy::LocalCache::Middleware, Rack::Runtime, Rack::MethodOverride, ActionDispatch::RequestId, ActionDispatch::RemoteIp, Sprockets::Rails::QuietAssets, Rails::Rack::Logger, ActionDispatch::ShowExceptions, WebConsole::Middleware, ActionDispatch::DebugExceptions, ActionDispatch::Reloader, ActionDispatch::Callbacks, ActiveRecord::Migration::CheckPending, ActionDispatch::Cookies, ActionDispatch::Session::CookieStore, ActionDispatch::Flash, Rack::Head, Rack::ConditionalGet, Rack::ETag
Application root          /home/foobar/commandsapp
Environment               development
Database adapter          sqlite3
Database schema version   20180205173523
```

### `bin/rails assets:`

You can precompile the assets in `app/assets` using `bin/rails assets:precompile`, and remove older compiled assets using `bin/rails assets:clean`. The `assets:clean` command allows for rolling deploys that may still be linking to an old asset while the new assets are being built.

If you want to clear `public/assets` completely, you can use `bin/rails assets:clobber`.

### `bin/rails db:`

The most common commands of the `db:` rails namespace are `migrate` and `create`, and it will pay off to try out all of the migration rails commands (`up`, `down`, `redo`, `reset`). `bin/rails db:version` is useful when troubleshooting, telling you the current version of the database.

More information about migrations can be found in the [Migrations](active_record_migrations.html) guide.

### `bin/rails notes`

`bin/rails notes` searches through your code for comments beginning with a specific keyword. You can refer to `bin/rails notes --help` for information about usage.

By default, it will search in `app`, `config`, `db`, `lib`, and `test` directories for FIXME, OPTIMIZE, and TODO annotations in files with extension `.builder`, `.rb`, `.rake`, `.yml`, `.yaml`, `.ruby`, `.css`, `.js`, and `.erb`.

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 13] [OPTIMIZE] refactor this code to make it faster
  * [ 17] [FIXME]
```

#### Annotations

You can pass specific annotations by using the `--annotations` argument. By default, it will search for FIXME, OPTIMIZE, and TODO.
Note that annotations are case sensitive.

```bash
$ bin/rails notes --annotations FIXME RELEASE
app/controllers/admin/users_controller.rb:
  * [101] [RELEASE] We need to look at this before next release
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 17] [FIXME]
```

#### Tags

You can add more default tags to search for by using `config.annotations.register_tags`. It receives a list of tags.

```ruby
config.annotations.register_tags("DEPRECATEME", "TESTME")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] do A/B testing on this
  * [ 42] [TESTME] this needs more functional tests
  * [132] [DEPRECATEME] ensure this method is deprecated in next release
```

#### Directories

You can add more default directories to search from by using `config.annotations.register_directories`. It receives a list of directory names.

```ruby
config.annotations.register_directories("spec", "vendor")
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

lib/school.rb:
  * [ 13] [OPTIMIZE] Refactor this code to make it faster
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works

vendor/tools.rb:
  * [ 56] [TODO] Get rid of this dependency
```

#### Extensions

You can add more default file extensions to search from by using `config.annotations.register_extensions`. It receives a list of extensions with its corresponding regex to match it up.

```ruby
config.annotations.register_extensions("scss", "sass") { |annotation| /\/\/\s*(#{annotation}):?\s*(.*)$/ }
```

```bash
$ bin/rails notes
app/controllers/admin/users_controller.rb:
  * [ 20] [TODO] any other way to do this?
  * [132] [FIXME] high priority for next deploy

app/assets/stylesheets/application.css.sass:
  * [ 34] [TODO] Use pseudo element for this class

app/assets/stylesheets/application.css.scss:
  * [  1] [TODO] Split into multiple components

lib/school.rb:
  * [ 13] [OPTIMIZE] Refactor this code to make it faster
  * [ 17] [FIXME]

spec/models/user_spec.rb:
  * [122] [TODO] Verify the user that has a subscription works

vendor/tools.rb:
  * [ 56] [TODO] Get rid of this dependency
```

### `bin/rails routes`

`bin/rails routes` will list all of your defined routes, which is useful for tracking down routing problems in your app, or giving you a good overview of the URLs in an app you're trying to get familiar with.

### `bin/rails test`

INFO: A good description of unit testing in Rails is given in [A Guide to Testing Rails Applications](testing.html)

Rails comes with a test framework called minitest. Rails owes its stability to the use of tests. The commands available in the `test:` namespace helps in running the different tests you will hopefully write.

### `bin/rails tmp:`

The `Rails.root/tmp` directory is, like the *nix /tmp directory, the holding place for temporary files like process id files and cached actions.

The `tmp:` namespaced commands will help you clear and create the `Rails.root/tmp` directory:

* `bin/rails tmp:cache:clear` clears `tmp/cache`.
* `bin/rails tmp:sockets:clear` clears `tmp/sockets`.
* `bin/rails tmp:screenshots:clear` clears `tmp/screenshots`.
* `bin/rails tmp:clear` clears all cache, sockets, and screenshot files.
* `bin/rails tmp:create` creates tmp directories for cache, sockets, and pids.

### Miscellaneous

* `bin/rails initializers` prints out all defined initializers in the order they are invoked by Rails.
* `bin/rails middleware` lists Rack middleware stack enabled for your app.
* `bin/rails stats` is great for looking at statistics on your code, displaying things like KLOCs (thousands of lines of code) and your code to test ratio.
* `bin/rails secret` will give you a pseudo-random key to use for your session secret.
* `bin/rails time:zones:all` lists all the timezones Rails knows about.

### Custom Rake Tasks

Custom rake tasks have a `.rake` extension and are placed in
`Rails.root/lib/tasks`. You can create these custom rake tasks with the
`bin/rails generate task` command.

```ruby
desc "I am short, but comprehensive description for my cool task"
task task_name: [:prerequisite_task, :another_task_we_depend_on] do
  # All your magic here
  # Any valid Ruby code is allowed
end
```

To pass arguments to your custom rake task:

```ruby
task :task_name, [:arg_1] => [:prerequisite_1, :prerequisite_2] do |task, args|
  argument_1 = args.arg_1
end
```

You can group tasks by placing them in namespaces:

```ruby
namespace :db do
  desc "This task does nothing"
  task :nothing do
    # Seriously, nothing
  end
end
```

Invocation of the tasks will look like:

```bash
$ bin/rails task_name
$ bin/rails "task_name[value 1]" # entire argument string should be quoted
$ bin/rails db:nothing
```

NOTE: If you need to interact with your application models, perform database queries, and so on, your task should depend on the `environment` task, which will load your application code.

The Rails Advanced Command Line
-------------------------------

More advanced use of the command line is focused around finding useful (even surprising at times) options in the utilities, and fitting those to your needs and specific work flow. Listed here are some tricks up Rails' sleeve.

### Rails with Databases and SCM

When creating a new Rails application, you have the option to specify what kind of database and what kind of source code management system your application is going to use. This will save you a few minutes, and certainly many keystrokes.

Let's see what a `--git` option and a `--database=postgresql` option will do for us:

```bash
$ mkdir gitapp
$ cd gitapp
$ git init
Initialized empty Git repository in .git/
$ rails new . --git --database=postgresql
      exists
      create  app/controllers
      create  app/helpers
...
...
      create  tmp/cache
      create  tmp/pids
      create  Rakefile
add 'Rakefile'
      create  README.md
add 'README.md'
      create  app/controllers/application_controller.rb
add 'app/controllers/application_controller.rb'
      create  app/helpers/application_helper.rb
...
      create  log/test.log
add 'log/test.log'
```

We had to create the **gitapp** directory and initialize an empty git repository before Rails would add files it created to our repository. Let's see what it put in our database configuration:

```bash
$ cat config/database.yml
# PostgreSQL. Versions 9.3 and up are supported.
#
# Install the pg driver:
#   gem install pg
# On macOS with Homebrew:
#   gem install pg -- --with-pg-config=/usr/local/bin/pg_config
# On macOS with MacPorts:
#   gem install pg -- --with-pg-config=/opt/local/lib/postgresql84/bin/pg_config
# On Windows:
#   gem install pg
#       Choose the win32 build.
#       Install PostgreSQL and put its /bin directory on your path.
#
# Configure Using Gemfile
# gem 'pg'
#
default: &default
  adapter: postgresql
  encoding: unicode
  # For details on connection pooling, see Rails configuration guide
  # https://guides.rubyonrails.org/configuring.html#database-pooling
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: gitapp_development
...
...
```

It also generated some lines in our `database.yml` configuration corresponding to our choice of PostgreSQL for database.

NOTE. The only catch with using the SCM options is that you have to make your application's directory first, then initialize your SCM, then you can run the `rails new` command to generate the basis of your app.
