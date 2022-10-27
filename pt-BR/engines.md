**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Introdução às *Engines*
============================

Neste guia você irá aprender sobre *engines* e como elas podem ser utilizadas para prover funcionalidades adicionais para suas aplicações hospedeiras através de uma interface bem limpa e fácil de usar.

Após ler este guia, você saberá:

* O que compõe uma *engine*.
* Como gerar uma *engine*.
* Como construir as funcionalidades para a *engine*.
* Como conectar a *engine* em uma aplicação.
* Como substituir a funcionalidade de uma *engine* na aplicação.
* Como evitar carregar frameworks Rails com *Load* e *Hooks* de Configuração.

--------------------------------------------------------------------------------

O que são *Engines*?
-----------------

*Engines* podem ser consideradas aplicações em miniatura que fornecem funcionalidades
para a aplicação hospedeira. Uma aplicação Rails é na verdade apenas uma *engine*
"sobrecarregada", com a classe `Rails::Application` herdando muitos de seus comportamentos
a partir da classe `Rails::Engine`.

Portanto, *engines* e aplicações podem ser tratadas quase como a mesma coisa,
apenas com algumas diferenças sutis, como você verá ao longo deste guia. *Engines*
e aplicações também compartilham uma estrutura em comum.

*Engines* também são intimamente relacionadas a *plugins*. Os dois compartilham uma
estrutura de diretório `lib` e ambos são gerados usando o gerador `rails plugin new`.
A diferença é que uma *engine* é considerada um "*plugin* completo" pelo Rails
(como é indicado pela opção `--full` que é passada ao comando gerador). Entretanto,
nós iremos usar a opção `--mountable` aqui, que inclui todas as funcionalidades
da `--full`, e mais algumas. Este guia referenciará estes "*plugins* completos"
apenas como "*engines*" em todo o decorrer. Uma *engine* **pode** ser um *plugin*,
e um *plugin* **pode** ser uma *engine*.

A *engine* que será criada neste guia será chamada "blorgh". Essa *engine* proverá
a funcionalidade de *blogging* para sua aplicação hospedeira, permitindo a criação
de novos artigos e comentários. No começo deste guia, você irá trabalhar somente
com a *engine* em si, mas nas seções mais a frente, você verá como conectá-la em
uma aplicação.

*Engines* também podem ser isoladas de sua aplicação hospedeira. Isso significa que
uma aplicação é capaz de ter um caminho provido por um *helper* de roteamento,
como o `articles_path` e usar uma *engine* que também provê um caminho chamado
`articles_path`, e os dois não sofreram conflito. Junto com isso, *controllers*,
*models* e nomes de tabela também são separados por *namespace*. Você verá como
fazer isso mais tarde neste guia.

É importante ter em mente que a aplicação **sempre** terá precedência
sobre suas *engines*. Uma aplicação é o objeto que terá a palavra final sobre o
que estará presente no ambiente. A *engine* estará somente a aprimorando, ao invés
de mudá-la drasticamente.

Para ver demonstrações de outras *engines*,
veja [Devise](https://github.com/plataformatec/devise), uma *engine* que provê
autenticação para suas aplicações hospedeiras, ou
[Thredded](https://github.com/thredded/thredded), uma *engine* que provê
funcionalidades de fórum, também há
[Spree](https://github.com/spree/spree), que provê uma plataforma de *e-commerce*,
e [Refinery CMS](https://github.com/refinery/refinerycms), uma *engine* de CMS.

Por fim, *engines* não seriam possíveis sem o trabalho de James Adam,
Piotr Sarnacki, a equipe principal do Rails e várias outras pessoas. Se algum dia
você se encontrar com eles, não se esqueça de dizer "obrigado(a)"!

Generating an Engine
--------------------

To generate an engine, you will need to run the plugin generator and pass it
options as appropriate to the need. For the "blorgh" example, you will need to
create a "mountable" engine, running this command in a terminal:

```bash
$ rails plugin new blorgh --mountable
```

The full list of options for the plugin generator may be seen by typing:

```bash
$ rails plugin --help
```

The `--mountable` option tells the generator that you want to create a
"mountable" and namespace-isolated engine. This generator will provide the same
skeleton structure as would the `--full` option. The `--full` option tells the
generator that you want to create an engine, including a skeleton structure
that provides the following:

  * An `app` directory tree
  * A `config/routes.rb` file:

    ```ruby
    Rails.application.routes.draw do
    end
    ```

  * A file at `lib/blorgh/engine.rb`, which is identical in function to a
    standard Rails application's `config/application.rb` file:

    ```ruby
    module Blorgh
      class Engine < ::Rails::Engine
      end
    end
    ```

The `--mountable` option will add to the `--full` option:

  * Asset manifest files (`blorgh_manifest.js` and `application.css`)
  * A namespaced `ApplicationController` stub
  * A namespaced `ApplicationHelper` stub
  * A layout view template for the engine
  * Namespace isolation to `config/routes.rb`:

    ```ruby
    Blorgh::Engine.routes.draw do
    end
    ```

  * Namespace isolation to `lib/blorgh/engine.rb`:

    ```ruby
    module Blorgh
      class Engine < ::Rails::Engine
        isolate_namespace Blorgh
      end
    end
    ```

Additionally, the `--mountable` option tells the generator to mount the engine
inside the dummy testing application located at `test/dummy` by adding the
following to the dummy application's routes file at
`test/dummy/config/routes.rb`:

```ruby
mount Blorgh::Engine => "/blorgh"
```

### Inside an Engine

#### Critical Files

At the root of this brand new engine's directory lives a `blorgh.gemspec` file.
When you include the engine into an application later on, you will do so with
this line in the Rails application's `Gemfile`:

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

Don't forget to run `bundle install` as usual. By specifying it as a gem within
the `Gemfile`, Bundler will load it as such, parsing this `blorgh.gemspec` file
and requiring a file within the `lib` directory called `lib/blorgh.rb`. This
file requires the `blorgh/engine.rb` file (located at `lib/blorgh/engine.rb`)
and defines a base module called `Blorgh`.

```ruby
require "blorgh/engine"

module Blorgh
end
```

TIP: Some engines choose to use this file to put global configuration options
for their engine. It's a relatively good idea, so if you want to offer
configuration options, the file where your engine's `module` is defined is
perfect for that. Place the methods inside the module and you'll be good to go.

Within `lib/blorgh/engine.rb` is the base class for the engine:

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    isolate_namespace Blorgh
  end
end
```

By inheriting from the `Rails::Engine` class, this gem notifies Rails that
there's an engine at the specified path, and will correctly mount the engine
inside the application, performing tasks such as adding the `app` directory of
the engine to the load path for models, mailers, controllers, and views.

The `isolate_namespace` method here deserves special notice. This call is
responsible for isolating the controllers, models, routes, and other things into
their own namespace, away from similar components inside the application.
Without this, there is a possibility that the engine's components could "leak"
into the application, causing unwanted disruption, or that important engine
components could be overridden by similarly named things within the application.
One of the examples of such conflicts is helpers. Without calling
`isolate_namespace`, the engine's helpers would be included in an application's
controllers.

NOTE: It is **highly** recommended that the `isolate_namespace` line be left
within the `Engine` class definition. Without it, classes generated in an engine
**may** conflict with an application.

What this isolation of the namespace means is that a model generated by a call
to `bin/rails generate model`, such as `bin/rails generate model article`, won't be called `Article`, but
instead be namespaced and called `Blorgh::Article`. In addition, the table for the
model is namespaced, becoming `blorgh_articles`, rather than simply `articles`.
Similar to the model namespacing, a controller called `ArticlesController` becomes
`Blorgh::ArticlesController` and the views for that controller will not be at
`app/views/articles`, but `app/views/blorgh/articles` instead. Mailers, jobs
and helpers are namespaced as well.

Finally, routes will also be isolated within the engine. This is one of the most
important parts about namespacing, and is discussed later in the
[Routes](#routes) section of this guide.

#### `app` Directory

Inside the `app` directory are the standard `assets`, `controllers`, `helpers`,
`jobs`, `mailers`, `models`, and `views` directories that you should be familiar with
from an application. We'll look more into models in a future section, when we're writing the engine.

Within the `app/assets` directory, there are the `images` and
`stylesheets` directories which, again, you should be familiar with due to their
similarity to an application. One difference here, however, is that each
directory contains a sub-directory with the engine name. Because this engine is
going to be namespaced, its assets should be too.

Within the `app/controllers` directory there is a `blorgh` directory that
contains a file called `application_controller.rb`. This file will provide any
common functionality for the controllers of the engine. The `blorgh` directory
is where the other controllers for the engine will go. By placing them within
this namespaced directory, you prevent them from possibly clashing with
identically-named controllers within other engines or even within the
application.

NOTE: The `ApplicationController` class inside an engine is named just like a
Rails application in order to make it easier for you to convert your
applications into engines.

NOTE: If the parent application runs in `classic` mode, you may run into a
situation where your engine controller is inheriting from the main application
controller and not your engine's application controller. The best way to prevent
this is to switch to `zeitwerk` mode in the parent application. Otherwise, use
`require_dependency` to ensure that the engine's application controller is
loaded. For example:

```ruby
# ONLY NEEDED IN `classic` MODE.
require_dependency "blorgh/application_controller"

module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

WARNING: Don't use `require` because it will break the automatic reloading of
classes in the development environment - using `require_dependency` ensures that
classes are loaded and unloaded in the correct manner.

Just like for `app/controllers`, you will find a `blorgh` subdirectory under
the `app/helpers`, `app/jobs`, `app/mailers` and `app/models` directories
containing the associated `application_*.rb` file for gathering common
functionalities. By placing your files under this subdirectory and namespacing
your objects, you prevent them from possibly clashing with identically-named
elements within other engines or even within the application.

Lastly, the `app/views` directory contains a `layouts` folder, which contains a
file at `blorgh/application.html.erb`. This file allows you to specify a layout
for the engine. If this engine is to be used as a stand-alone engine, then you
would add any customization to its layout in this file, rather than the
application's `app/views/layouts/application.html.erb` file.

If you don't want to force a layout on to users of the engine, then you can
delete this file and reference a different layout in the controllers of your
engine.

#### `bin` Directory

This directory contains one file, `bin/rails`, which enables you to use the
`rails` sub-commands and generators just like you would within an application.
This means that you will be able to generate new controllers and models for this
engine very easily by running commands like this:

```bash
$ bin/rails generate model
```

Keep in mind, of course, that anything generated with these commands inside of
an engine that has `isolate_namespace` in the `Engine` class will be namespaced.

#### `test` Directory

The `test` directory is where tests for the engine will go. To test the engine,
there is a cut-down version of a Rails application embedded within it at
`test/dummy`. This application will mount the engine in the
`test/dummy/config/routes.rb` file:

```ruby
Rails.application.routes.draw do
  mount Blorgh::Engine => "/blorgh"
end
```

This line mounts the engine at the path `/blorgh`, which will make it accessible
through the application only at that path.

Inside the test directory there is the `test/integration` directory, where
integration tests for the engine should be placed. Other directories can be
created in the `test` directory as well. For example, you may wish to create a
`test/models` directory for your model tests.

Fornecendo Funcionalidades a *Engine*
------------------------------

A *engine* que este guia cobre fornece funcionalidades de submeter artigos e
comentários e segue na mesma linha do [Guia Começando com Rails](getting_started.html), com algumas
novas alterações.

NOTE: For this section, make sure to run the commands in the root of the
`blorgh` engine's directory.

### Gerando um Recurso de Artigo

A primeira coisa a se gerar para uma *engine* de blog é o *model* `Article` e o
*controller* relacionado. Para gerar isso rapidamente, você pode utilizar o
gerador de *scaffold* do Rails.

```bash
$ bin/rails generate scaffold article title:string text:text
```

Esse comando gerará a seguinte saída:

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_articles.rb
create    app/models/blorgh/article.rb
invoke    test_unit
create      test/models/blorgh/article_test.rb
create      test/fixtures/blorgh/articles.yml
invoke  resource_route
 route    resources :articles
invoke  scaffold_controller
create    app/controllers/blorgh/articles_controller.rb
invoke    erb
create      app/views/blorgh/articles
create      app/views/blorgh/articles/index.html.erb
create      app/views/blorgh/articles/edit.html.erb
create      app/views/blorgh/articles/show.html.erb
create      app/views/blorgh/articles/new.html.erb
create      app/views/blorgh/articles/_form.html.erb
invoke    test_unit
create      test/controllers/blorgh/articles_controller_test.rb
create      test/system/blorgh/articles_test.rb
invoke    helper
create      app/helpers/blorgh/articles_helper.rb
invoke      test_unit
```

A primeira coisa que o gerador de *scaffold* faz é invocar o gerador `active_record`,
que gera uma migração e um `model` para o recurso. Note que, porém, a migração é
chamada `create_blorgh_articles` ao invés de `create_articles`. Isso se deve a
chamada do método `isolate_namespace` na definição da classe `Blorgh::Engine`. O *model*
aqui também está sob um *namespace*, colocado em `app/models/blorgh/article.rb` ao invés
de `app/models/article.rb` devido à chamada do método `isolate_namespace` dentro da
classe `Engine`.

A seguir, é invocado o gerador `test_unit` para este *model*, gerando um teste de *model*
em `test/models/blorgh/article_test.rb` (ao invés de `test/models/article_test.rb`) e uma
*fixture* em `test/fixtures/blorgh/articles.yml` (ao invés de `test/fixtures/articles.yml`).

Depois disso, uma linha para o recurso é inserida no arquivo `config/routes.rb` para
aquela *engine*. Essa linha é simplesmente `resources :articles`, transformando o
arquivo `config/routes.rb` da *engine* nisto:

```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

Note que as rotas são escritas sobre o objeto `Blorgh::Engine` ao invés da classe
`YourApp::Application`. Isso acontece, pois assim as rotas da *engine* permanecem
confinadas na própria *engine* e podem ser montadas em um ponto específico como
mostrado na seção [diretório de teste](#test-directory). Isso também faz com que
as rotas da *engine* estejam isoladas das rotas da própria aplicação. A seção
[Rotas](#routes) deste guia, descreve isso em detalhes.

A seguir, é invocado o gerador `scaffold_controller`, gerando um *controller* chamado
`Blorgh::ArticlesController` (em `app/controllers/blorgh/articles_controller.rb`) e
suas *views* relacionadas em `app/views/blorgh/articles`. Esse gerador também gera testes
para o *controller* (`test/controllers/blorgh/articles_controller_test.rb` e
`test/system/blorgh/articles_test.rb`) e um *helper* (`app/helpers/blorgh/articles_helper.rb`).

Tudo que esse gerador cria está sob um *namespace*. A classe do *controller* é
definida dentro de um módulo `Blorgh`:

```ruby
module Blorgh
  class ArticlesController < ApplicationController
    # ...
  end
end
```

NOTE: The `ArticlesController` class inherits from
`Blorgh::ApplicationController`, not the application's `ApplicationController`.

O *helper* dentro de `app/helpers/blorgh/articles_helper.rb` também está sob um *namespace*.

```ruby
module Blorgh
  module ArticlesHelper
    # ...
  end
end
```

Isso ajuda a prevenir conflitos com qualquer outra *engine* ou aplicação que também
tenha um recurso de artigo.

Você pode ver o que a *engine* tem até agora executando `bin/rails db:migrate` na raiz
de sua *engine* para executar as migrações geradas pelo gerador de *scaffold*, e então
executar `bin/rails server` em `test/dummy`. Quando você abrir `http://localhost:3000/blorgh/articles`,
você verá o *scaffold* padrão que foi gerado.  Clique em volta! Você acaba de gerar as
primeiras funções de sua primeira *engine*.

Se você preferir testar utilizando o *console*, `bin/rails console` também funcionará
como uma aplicação Rails. Lembre-se: o model `Article` utiliza um *namespace*, então para
referenciá-lo, você deve chamá-lo como `Blorgh::Article`.

```irb
irb> Blorgh::Article.find(1)
=> #<Blorgh::Article id: 1 ...>
```

Uma última coisa é que o recurso `articles` para essa *engine* deve estar na
raiz da *engine*. Sempre que alguém for ao caminho raiz onde a *engine* está montada,
eles devem ver uma lista de artigos. Isso pode ser feito se essa linha for inserida
ao arquivo `config/routes.rb` dentro da *engine*:

```ruby
root to: "articles#index"
```

Agora, as pessoas só precisarão ir à raiz da *engine* para ver os artigos, ao invés
de visitar `/articles`. Isso significa que ao invés de `http://localhost:3000/blorgh/articles`,
você agora só precisa ir até `http://localhost:3000/blorgh`.

### Gerando um Recurso de Comentários

Agora que a *engine* pode criar novos artigos, faz sentido adicionar a funcionalidade
de comentários também. Para fazer isso, você precisará gerar um *model* de comentário,
um *controller* de comentários, e então modificar o *scaffold* de artigos para
exibir os comentários e permitir que pessoas possam criar novos comentários.

Da raiz da *engine*, execute o gerador de *model*. Indique a geração de um
*model* `Comment`, com a sua tabela contendo duas colunas: um inteiro `article_id`
e uma coluna de texto `text`.

```bash
$ bin/rails generate model Comment article_id:integer text:text
```

Isso produzirá a seguinte saída:

```
invoke  active_record
create    db/migrate/[timestamp]_create_blorgh_comments.rb
create    app/models/blorgh/comment.rb
invoke    test_unit
create      test/models/blorgh/comment_test.rb
create      test/fixtures/blorgh/comments.yml
```

Esse gerador gerará somente os arquivos de *model* que ele precisa, colocando
os arquivo dentro de um diretório `blorgh` e criando uma classe de *model*
chamada `Blorgh::Comment`. Agora execute a migração para criar nossa tabela
`blorgh_comments`.

```bash
$ bin/rails db:migrate
```

Para exibir os comentários em um artigo, edite `app/views/blorgh/articles/show.html.erb`
e adicione essas linhas antes do link "Edit".

```html+erb
<h3>Comments</h3>
<%= render @article.comments %>
```

Essa linha requer que exista uma associação `has_many` com os comentários definida
no *model* `Blorgh::Article`, o que não existe até o momento. Para defini-la, abra
`app/models/blorgh/article.rb` e adicione essa linha no *model*.

```ruby
has_many :comments
```

Transformando o *model* nisso:

```ruby
module Blorgh
  class Article < ApplicationRecord
    has_many :comments
  end
end
```

NOTE: Because the `has_many` is defined inside a class that is inside the
`Blorgh` module, Rails will know that you want to use the `Blorgh::Comment`
model for these objects, so there's no need to specify that using the
`:class_name` option here.

A seguir, é necessário que tenhamos um formulário para que os comentários sejam
criados dentro de um artigo. Para adicionar isso, coloque essa linha logo após
`render @article.comments` em `app/views/blorgh/articles/show.html.erb`.

```erb
<%= render "blorgh/comments/form" %>
```

A seguir, a *partial* que essa linha renderizará precisa existir. Crie um novo
diretório `app/views/blorgh/comments` e dentro dele, um novo arquivo chamado
`_form.html.erb` que contem esse conteúdo para criar a *partial* requerida:

```html+erb
<h3>New comment</h3>
<%= form_with model: [@article, @article.comments.build] do |form| %>
  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>
  <%= form.submit %>
<% end %>
```

Quando esse formulário é submetido, ele tentará performar uma requisição do tipo
`POST` a uma rota `/articles/:article_id/comments` da *engine*. Essa ainda não existe
atualmente, mas pode ser criada mudando a linha `resources :articles` dentro de
`config/routes.rb` para estas linhas:

```ruby
resources :articles do
  resources :comments
end
```

Isso cria uma rota aninhada para os comentários, que o formulário requer.

Essa rota agora existe, mas o *controller* para onde está rota leva, não existe.
Para criá-lo, execute este comando na raiz da *engine*.

```bash
$ bin/rails generate controller comments
```

Isso gerará o seguinte:

```
create  app/controllers/blorgh/comments_controller.rb
invoke  erb
 exist    app/views/blorgh/comments
invoke  test_unit
create    test/controllers/blorgh/comments_controller_test.rb
invoke  helper
create    app/helpers/blorgh/comments_helper.rb
invoke    test_unit
```

O formulário está executando uma requisição do tipo `POST` para `/articles/:article_id/comments`
que corresponderá a ação `create` em `Blorgh::CommentsController`. Essa ação precisa ser
criada, o que pode ser feito colocando as seguintes linhas dentro da definição da classe
em `app/controllers/blorgh/comments_controller.rb`:

```ruby
def create
  @article = Article.find(params[:article_id])
  @comment = @article.comments.create(comment_params)
  flash[:notice] = "Comment has been created!"
  redirect_to articles_path
end

private
  def comment_params
    params.require(:comment).permit(:text)
  end
```

Isso é o último passo requerido para obter o formulário de novo comentário funcionando.
Exibir os comentários, entretanto, ainda não está funcionando. Se você criar um comentário
agora, você verá o seguinte erro:

```
Missing partial blorgh/comments/_comment with {:handlers=>[:erb, :builder],
:formats=>[:html], :locale=>[:en, :en]}. Searched in:   *
"/Users/ryan/Sites/side_projects/blorgh/test/dummy/app/views"   *
"/Users/ryan/Sites/side_projects/blorgh/app/views"
```

Essa *engine* não é capaz de encontrar a *partial* requerida para renderizar os comentários.
O Rails procura primeiro no diretório `app/views` da aplicação (`test/dummy`) e
depois no diretório `app/views` da *engine*. Quando ele não consegue encontrar, ele
irá disparar esse erro. A *engine* sabe procurar por `blorgh/comments/_comment` porque
o objeto do *model* a está recebendo da classe `Blorgh::Comment`.

Essa *partial* será responsável apenas por renderizar o texto do comentário, por agora.
Crie um novo arquivo em `app/views/blorgh/comments/_comment.html.erb` e coloque essa
linha dentro dele:

```erb
<%= comment_counter + 1 %>. <%= comment.text %>
```

A variável local `comment_counter` nos é provida pela chamada `<%= render
@article.comments %>`, que irá defini-la automaticamente e incrementar o contador
enquanto faz a iteração através de cada comentário. Ela é usada nesse exemplo para
exibir um pequeno número ao lado de cada comentário quando ele é criado.

Isso finaliza a funcionalidade de comentário da *engine* de *blogging*. Agora é
hora de utilizá-la em uma aplicação.

Hooking Into an Application
---------------------------

Using an engine within an application is very easy. This section covers how to
mount the engine into an application and the initial setup required, as well as
linking the engine to a `User` class provided by the application to provide
ownership for articles and comments within the engine.

### Mounting the Engine

First, the engine needs to be specified inside the application's `Gemfile`. If
there isn't an application handy to test this out in, generate one using the
`rails new` command outside of the engine directory like this:

```bash
$ rails new unicorn
```

Usually, specifying the engine inside the `Gemfile` would be done by specifying it
as a normal, everyday gem.

```ruby
gem 'devise'
```

However, because you are developing the `blorgh` engine on your local machine,
you will need to specify the `:path` option in your `Gemfile`:

```ruby
gem 'blorgh', path: 'engines/blorgh'
```

Then run `bundle` to install the gem.

As described earlier, by placing the gem in the `Gemfile` it will be loaded when
Rails is loaded. It will first require `lib/blorgh.rb` from the engine, then
`lib/blorgh/engine.rb`, which is the file that defines the major pieces of
functionality for the engine.

To make the engine's functionality accessible from within an application, it
needs to be mounted in that application's `config/routes.rb` file:

```ruby
mount Blorgh::Engine, at: "/blog"
```

This line will mount the engine at `/blog` in the application. Making it
accessible at `http://localhost:3000/blog` when the application runs with `bin/rails
server`.

NOTE: Other engines, such as Devise, handle this a little differently by making
you specify custom helpers (such as `devise_for`) in the routes. These helpers
do exactly the same thing, mounting pieces of the engines's functionality at a
pre-defined path which may be customizable.

### Engine Setup

The engine contains migrations for the `blorgh_articles` and `blorgh_comments`
table which need to be created in the application's database so that the
engine's models can query them correctly. To copy these migrations into the
application run the following command from the application's root:

```bash
$ bin/rails blorgh:install:migrations
```

If you have multiple engines that need migrations copied over, use
`railties:install:migrations` instead:

```bash
$ bin/rails railties:install:migrations
```

This command, when run for the first time, will copy over all the migrations
from the engine. When run the next time, it will only copy over migrations that
haven't been copied over already. The first run for this command will output
something such as this:

```
Copied migration [timestamp_1]_create_blorgh_articles.blorgh.rb from blorgh
Copied migration [timestamp_2]_create_blorgh_comments.blorgh.rb from blorgh
```

The first timestamp (`[timestamp_1]`) will be the current time, and the second
timestamp (`[timestamp_2]`) will be the current time plus a second. The reason
for this is so that the migrations for the engine are run after any existing
migrations in the application.

To run these migrations within the context of the application, simply run `bin/rails
db:migrate`. When accessing the engine through `http://localhost:3000/blog`, the
articles will be empty. This is because the table created inside the application is
different from the one created within the engine. Go ahead, play around with the
newly mounted engine. You'll find that it's the same as when it was only an
engine.

If you would like to run migrations only from one engine, you can do it by
specifying `SCOPE`:

```bash
$ bin/rails db:migrate SCOPE=blorgh
```

This may be useful if you want to revert engine's migrations before removing it.
To revert all migrations from blorgh engine you can run code such as:

```bash
$ bin/rails db:migrate SCOPE=blorgh VERSION=0
```

### Using a Class Provided by the Application

#### Using a Model Provided by the Application

When an engine is created, it may want to use specific classes from an
application to provide links between the pieces of the engine and the pieces of
the application. In the case of the `blorgh` engine, making articles and comments
have authors would make a lot of sense.

A typical application might have a `User` class that would be used to represent
authors for an article or a comment. But there could be a case where the
application calls this class something different, such as `Person`. For this
reason, the engine should not hardcode associations specifically for a `User`
class.

To keep it simple in this case, the application will have a class called `User`
that represents the users of the application (we'll get into making this
configurable further on). It can be generated using this command inside the
application:

```bash
$ bin/rails generate model user name:string
```

The `bin/rails db:migrate` command needs to be run here to ensure that our
application has the `users` table for future use.

Also, to keep it simple, the articles form will have a new text field called
`author_name`, where users can elect to put their name. The engine will then
take this name and either create a new `User` object from it, or find one that
already has that name. The engine will then associate the article with the found or
created `User` object.

First, the `author_name` text field needs to be added to the
`app/views/blorgh/articles/_form.html.erb` partial inside the engine. This can be
added above the `title` field with this code:

```html+erb
<div class="field">
  <%= form.label :author_name %><br>
  <%= form.text_field :author_name %>
</div>
```

Next, we need to update our `Blorgh::ArticlesController#article_params` method to
permit the new form parameter:

```ruby
def article_params
  params.require(:article).permit(:title, :text, :author_name)
end
```

The `Blorgh::Article` model should then have some code to convert the `author_name`
field into an actual `User` object and associate it as that article's `author`
before the article is saved. It will also need to have an `attr_accessor` set up
for this field, so that the setter and getter methods are defined for it.

To do all this, you'll need to add the `attr_accessor` for `author_name`, the
association for the author and the `before_validation` call into
`app/models/blorgh/article.rb`. The `author` association will be hard-coded to the
`User` class for the time being.

```ruby
attr_accessor :author_name
belongs_to :author, class_name: "User"

before_validation :set_author

private
  def set_author
    self.author = User.find_or_create_by(name: author_name)
  end
```

By representing the `author` association's object with the `User` class, a link
is established between the engine and the application. There needs to be a way
of associating the records in the `blorgh_articles` table with the records in the
`users` table. Because the association is called `author`, there should be an
`author_id` column added to the `blorgh_articles` table.

To generate this new column, run this command within the engine:

```bash
$ bin/rails generate migration add_author_id_to_blorgh_articles author_id:integer
```

NOTE: Due to the migration's name and the column specification after it, Rails
will automatically know that you want to add a column to a specific table and
write that into the migration for you. You don't need to tell it any more than
this.

This migration will need to be run on the application. To do that, it must first
be copied using this command:

```bash
$ bin/rails blorgh:install:migrations
```

Notice that only _one_ migration was copied over here. This is because the first
two migrations were copied over the first time this command was run.

```
NOTE Migration [timestamp]_create_blorgh_articles.blorgh.rb from blorgh has been skipped. Migration with the same name already exists.
NOTE Migration [timestamp]_create_blorgh_comments.blorgh.rb from blorgh has been skipped. Migration with the same name already exists.
Copied migration [timestamp]_add_author_id_to_blorgh_articles.blorgh.rb from blorgh
```

Run the migration using:

```bash
$ bin/rails db:migrate
```

Now with all the pieces in place, an action will take place that will associate
an author - represented by a record in the `users` table - with an article,
represented by the `blorgh_articles` table from the engine.

Finally, the author's name should be displayed on the article's page. Add this code
above the "Title" output inside `app/views/blorgh/articles/show.html.erb`:

```html+erb
<p>
  <b>Author:</b>
  <%= @article.author.name %>
</p>
```

#### Using a Controller Provided by the Application

Because Rails controllers generally share code for things like authentication
and accessing session variables, they inherit from `ApplicationController` by
default. Rails engines, however are scoped to run independently from the main
application, so each engine gets a scoped `ApplicationController`. This
namespace prevents code collisions, but often engine controllers need to access
methods in the main application's `ApplicationController`. An easy way to
provide this access is to change the engine's scoped `ApplicationController` to
inherit from the main application's `ApplicationController`. For our Blorgh
engine this would be done by changing
`app/controllers/blorgh/application_controller.rb` to look like:

```ruby
module Blorgh
  class ApplicationController < ::ApplicationController
  end
end
```

By default, the engine's controllers inherit from
`Blorgh::ApplicationController`. So, after making this change they will have
access to the main application's `ApplicationController`, as though they were
part of the main application.

This change does require that the engine is run from a Rails application that
has an `ApplicationController`.

### Configuring an Engine

This section covers how to make the `User` class configurable, followed by
general configuration tips for the engine.

#### Setting Configuration Settings in the Application

The next step is to make the class that represents a `User` in the application
customizable for the engine. This is because that class may not always be
`User`, as previously explained. To make this setting customizable, the engine
will have a configuration setting called `author_class` that will be used to
specify which class represents users inside the application.

To define this configuration setting, you should use a `mattr_accessor` inside
the `Blorgh` module for the engine. Add this line to `lib/blorgh.rb` inside the
engine:

```ruby
mattr_accessor :author_class
```

This method works like its siblings, `attr_accessor` and `cattr_accessor`, but
provides a setter and getter method on the module with the specified name. To
use it, it must be referenced using `Blorgh.author_class`.

The next step is to switch the `Blorgh::Article` model over to this new setting.
Change the `belongs_to` association inside this model
(`app/models/blorgh/article.rb`) to this:

```ruby
belongs_to :author, class_name: Blorgh.author_class
```

The `set_author` method in the `Blorgh::Article` model should also use this class:

```ruby
self.author = Blorgh.author_class.constantize.find_or_create_by(name: author_name)
```

To save having to call `constantize` on the `author_class` result all the time,
you could instead just override the `author_class` getter method inside the
`Blorgh` module in the `lib/blorgh.rb` file to always call `constantize` on the
saved value before returning the result:

```ruby
def self.author_class
  @@author_class.constantize
end
```

This would then turn the above code for `set_author` into this:

```ruby
self.author = Blorgh.author_class.find_or_create_by(name: author_name)
```

Resulting in something a little shorter, and more implicit in its behavior. The
`author_class` method should always return a `Class` object.

Since we changed the `author_class` method to return a `Class` instead of a
`String`, we must also modify our `belongs_to` definition in the `Blorgh::Article`
model:

```ruby
belongs_to :author, class_name: Blorgh.author_class.to_s
```

To set this configuration setting within the application, an initializer should
be used. By using an initializer, the configuration will be set up before the
application starts and calls the engine's models, which may depend on this
configuration setting existing.

Create a new initializer at `config/initializers/blorgh.rb` inside the
application where the `blorgh` engine is installed and put this content in it:

```ruby
Blorgh.author_class = "User"
```

WARNING: It's very important here to use the `String` version of the class,
rather than the class itself. If you were to use the class, Rails would attempt
to load that class and then reference the related table. This could lead to
problems if the table didn't already exist. Therefore, a `String` should be
used and then converted to a class using `constantize` in the engine later on.

Go ahead and try to create a new article. You will see that it works exactly in the
same way as before, except this time the engine is using the configuration
setting in `config/initializers/blorgh.rb` to learn what the class is.

There are now no strict dependencies on what the class is, only what the API for
the class must be. The engine simply requires this class to define a
`find_or_create_by` method which returns an object of that class, to be
associated with an article when it's created. This object, of course, should have
some sort of identifier by which it can be referenced.

#### General Engine Configuration

Within an engine, there may come a time where you wish to use things such as
initializers, internationalization, or other configuration options. The great
news is that these things are entirely possible, because a Rails engine shares
much the same functionality as a Rails application. In fact, a Rails
application's functionality is actually a superset of what is provided by
engines!

If you wish to use an initializer - code that should run before the engine is
loaded - the place for it is the `config/initializers` folder. This directory's
functionality is explained in the [Initializers
section](configuring.html#initializers) of the Configuring guide, and works
precisely the same way as the `config/initializers` directory inside an
application. The same thing goes if you want to use a standard initializer.

For locales, simply place the locale files in the `config/locales` directory,
just like you would in an application.

Testando uma *Engine*
-----------------

Quando uma *engine* é gerada, há uma pequena aplicação fictícia (dummy)
criada dentro dela em `test/dummy`. Essa aplicação é utilizada como ponto de
montagem para a *engine*, para tornar os testes de uma *engine* extremamente
simples. Você pode ampliar essa aplicação gerando *controllers*, *models* ou
*views* de dentro do diretório, e então usá-los para testar sua *engine*.

O diretório `test` sempre deverá ser tratado como um ambiente de teste típico
do Rails, permitindo testes unitários, funcionais e de integração.

### Testes funcionais

É importante levar em consideração ao escrever testes funcionais, que os testes
serão executados em uma aplicação - a aplicação `test/dummy` - e não a sua *engine*.
Isso se deve a preparação do ambiente de testes; uma *engine* precisa de uma
aplicação hospedeira para que seja possível testar suas funcionalidades principais,
especialmente os *controllers*. Isso significa que se você está a realizar um
típico `GET` para um *controller* em um teste funcional de *controller* como este:

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    def test_index
      get foos_url
      # ...
    end
  end
end
```

Ele pode não funcionar corretamente. Isso acontece porque a aplicação não sabe
como rotear essas requisições para as *engines* a menos que você diga *como* fazer
isso, de forma explícita. E para isso, você precisa definir a variável de instância
`@routes` como sendo o conjunto de rotas da *engine* no seu código de
preparação (setup):

```ruby
module Blorgh
  class FooControllerTest < ActionDispatch::IntegrationTest
    include Engine.routes.url_helpers

    setup do
      @routes = Engine.routes
    end

    def test_index
      get foos_url
      # ...
    end
  end
end
```

Isso indica à aplicação que você ainda quer executar uma requisição do tipo `GET`,
para ação `index` desse *controller*, mas você quer usar as rotas da *engine* para
chegar lá, ao invés das rotas da aplicação.

Isso também certifica que os *helpers* de URL da *engine* irão funcionar como
esperado em seus testes.

Improving Engine Functionality
------------------------------

This section explains how to add and/or override engine MVC functionality in the
main Rails application.

### Overriding Models and Controllers

Engine models and controllers can be reopened by the parent application to extend or decorate them.

Overrides may be organized in a dedicated directory `app/overrides` that is preloaded in a `to_prepare` callback.

In `zeitwerk` mode you'd do this:

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # ...

    overrides = "#{Rails.root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)
    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").each do |override|
        load override
      end
    end
  end
end
```

and in `classic` mode this:

```ruby
# config/application.rb
module MyApp
  class Application < Rails::Application
    # ...

    config.to_prepare do
      Dir.glob("#{Rails.root}/app/overrides/**/*_override.rb").each do |override|
        require_dependency override
      end
    end
  end
end
```

#### Reopening existing classes using `class_eval`

For example, in order to override the engine model

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    has_many :comments

    def summary
      "#{title}"
    end
  end
end
```

you just create a file that _reopens_ that class:

```ruby
# MyApp/app/overrides/models/blorgh/article_override.rb
Blorgh::Article.class_eval do
  def time_since_created
    Time.current - created_at
  end

  def summary
    "#{title} - #{truncate(text)}"
  end
end
```

It is very important that the override _reopens_ the class or module. Using the `class` or `module` keywords would define them if they were not already in memory, which would be incorrect because the definition lives in the engine. Using `class_eval` as shown above ensures you are reopening.

#### Reopening existing classes using ActiveSupport::Concern

Using `Class#class_eval` is great for simple adjustments, but for more complex
class modifications, you might want to consider using [`ActiveSupport::Concern`]
(https://api.rubyonrails.org/classes/ActiveSupport/Concern.html).
ActiveSupport::Concern manages load order of interlinked dependent modules and
classes at run time allowing you to significantly modularize your code.

**Adding** `Article#time_since_created` and **Overriding** `Article#summary`:

```ruby
# MyApp/app/models/blorgh/article.rb

class Blorgh::Article < ApplicationRecord
  include Blorgh::Concerns::Models::Article

  def time_since_created
    Time.current - created_at
  end

  def summary
    "#{title} - #{truncate(text)}"
  end
end
```

```ruby
# Blorgh/app/models/blorgh/article.rb
module Blorgh
  class Article < ApplicationRecord
    include Blorgh::Concerns::Models::Article
  end
end
```

```ruby
# Blorgh/lib/concerns/models/article.rb

module Blorgh::Concerns::Models::Article
  extend ActiveSupport::Concern

  # 'included do' causes the included code to be evaluated in the
  # context where it is included (article.rb), rather than being
  # executed in the module's context (blorgh/concerns/models/article).
  included do
    attr_accessor :author_name
    belongs_to :author, class_name: "User"

    before_validation :set_author

    private
      def set_author
        self.author = User.find_or_create_by(name: author_name)
      end
  end

  def summary
    "#{title}"
  end

  module ClassMethods
    def some_class_method
      'some class method string'
    end
  end
end
```

### Autoloading and Engines

Please check the [Autoloading and Reloading Constants](autoloading_and_reloading_constants.html#autoloading-and-engines)
guide for more information about autoloading and engines.


### Overriding Views

When Rails looks for a view to render, it will first look in the `app/views`
directory of the application. If it cannot find the view there, it will check in
the `app/views` directories of all engines that have this directory.

When the application is asked to render the view for `Blorgh::ArticlesController`'s
index action, it will first look for the path
`app/views/blorgh/articles/index.html.erb` within the application. If it cannot
find it, it will look inside the engine.

You can override this view in the application by simply creating a new file at
`app/views/blorgh/articles/index.html.erb`. Then you can completely change what
this view would normally output.

Try this now by creating a new file at `app/views/blorgh/articles/index.html.erb`
and put this content in it:

```html+erb
<h1>Articles</h1>
<%= link_to "New Article", new_article_path %>
<% @articles.each do |article| %>
  <h2><%= article.title %></h2>
  <small>By <%= article.author %></small>
  <%= simple_format(article.text) %>
  <hr>
<% end %>
```

### Routes

Routes inside an engine are isolated from the application by default. This is
done by the `isolate_namespace` call inside the `Engine` class. This essentially
means that the application and its engines can have identically named routes and
they will not clash.

Routes inside an engine are drawn on the `Engine` class within
`config/routes.rb`, like this:

```ruby
Blorgh::Engine.routes.draw do
  resources :articles
end
```

By having isolated routes such as this, if you wish to link to an area of an
engine from within an application, you will need to use the engine's routing
proxy method. Calls to normal routing methods such as `articles_path` may end up
going to undesired locations if both the application and the engine have such a
helper defined.

For instance, the following example would go to the application's `articles_path`
if that template was rendered from the application, or the engine's `articles_path`
if it was rendered from the engine:

```erb
<%= link_to "Blog articles", articles_path %>
```

To make this route always use the engine's `articles_path` routing helper method,
we must call the method on the routing proxy method that shares the same name as
the engine.

```erb
<%= link_to "Blog articles", blorgh.articles_path %>
```

If you wish to reference the application inside the engine in a similar way, use
the `main_app` helper:

```erb
<%= link_to "Home", main_app.root_path %>
```

If you were to use this inside an engine, it would **always** go to the
application's root. If you were to leave off the `main_app` "routing proxy"
method call, it could potentially go to the engine's or application's root,
depending on where it was called from.

If a template rendered from within an engine attempts to use one of the
application's routing helper methods, it may result in an undefined method call.
If you encounter such an issue, ensure that you're not attempting to call the
application's routing methods without the `main_app` prefix from within the
engine.

### Assets

Assets within an engine work in an identical way to a full application. Because
the engine class inherits from `Rails::Engine`, the application will know to
look up assets in the engine's `app/assets` and `lib/assets` directories.

Like all of the other components of an engine, the assets should be namespaced.
This means that if you have an asset called `style.css`, it should be placed at
`app/assets/stylesheets/[engine name]/style.css`, rather than
`app/assets/stylesheets/style.css`. If this asset isn't namespaced, there is a
possibility that the host application could have an asset named identically, in
which case the application's asset would take precedence and the engine's one
would be ignored.

Imagine that you did have an asset located at
`app/assets/stylesheets/blorgh/style.css`. To include this asset inside an
application, just use `stylesheet_link_tag` and reference the asset as if it
were inside the engine:

```erb
<%= stylesheet_link_tag "blorgh/style.css" %>
```

You can also specify these assets as dependencies of other assets using Asset
Pipeline require statements in processed files:

```css
/*
 *= require blorgh/style
 */
```

INFO. Remember that in order to use languages like Sass or CoffeeScript, you
should add the relevant library to your engine's `.gemspec`.

### Separate Assets and Precompiling

There are some situations where your engine's assets are not required by the
host application. For example, say that you've created an admin functionality
that only exists for your engine. In this case, the host application doesn't
need to require `admin.css` or `admin.js`. Only the gem's admin layout needs
these assets. It doesn't make sense for the host app to include
`"blorgh/admin.css"` in its stylesheets. In this situation, you should
explicitly define these assets for precompilation.  This tells Sprockets to add
your engine assets when `bin/rails assets:precompile` is triggered.

You can define assets for precompilation in `engine.rb`:

```ruby
initializer "blorgh.assets.precompile" do |app|
  app.config.assets.precompile += %w( admin.js admin.css )
end
```

For more information, read the [Asset Pipeline guide](asset_pipeline.html).

### Other Gem Dependencies

Gem dependencies inside an engine should be specified inside the `.gemspec` file
at the root of the engine. The reason is that the engine may be installed as a
gem. If dependencies were to be specified inside the `Gemfile`, these would not
be recognized by a traditional gem install and so they would not be installed,
causing the engine to malfunction.

To specify a dependency that should be installed with the engine during a
traditional `gem install`, specify it inside the `Gem::Specification` block
inside the `.gemspec` file in the engine:

```ruby
s.add_dependency "moo"
```

To specify a dependency that should only be installed as a development
dependency of the application, specify it like this:

```ruby
s.add_development_dependency "moo"
```

Both kinds of dependencies will be installed when `bundle install` is run inside
of the application. The development dependencies for the gem will only be used
when the development and tests for the engine are running.

Note that if you want to immediately require dependencies when the engine is
required, you should require them before the engine's initialization. For
example:

```ruby
require "other_engine/engine"
require "yet_another_engine/engine"

module MyEngine
  class Engine < ::Rails::Engine
  end
end
```

Load and Configuration Hooks
----------------------------

Rails code can often be referenced on load of an application. Rails is responsible for the load order of these frameworks, so when you load frameworks, such as `ActiveRecord::Base`, prematurely you are violating an implicit contract your application has with Rails. Moreover, by loading code such as `ActiveRecord::Base` on boot of your application you are loading entire frameworks which may slow down your boot time and could cause conflicts with load order and boot of your application.

Load and configuration hooks are the API that allow you to hook into this initialization process without violating the load contract with Rails. This will also mitigate boot performance degradation and avoid conflicts.

### Avoid loading Rails Frameworks

Since Ruby is a dynamic language, some code will cause different Rails frameworks to load. Take this snippet for instance:

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

This snippet means that when this file is loaded, it will encounter `ActiveRecord::Base`. This encounter causes Ruby to look for the definition of that constant and will require it. This causes the entire Active Record framework to be loaded on boot.

`ActiveSupport.on_load` is a mechanism that can be used to defer the loading of code until it is actually needed. The snippet above can be changed to:

```ruby
ActiveSupport.on_load(:active_record) do
  include MyActiveRecordHelper
end
```

This new snippet will only include `MyActiveRecordHelper` when `ActiveRecord::Base` is loaded.

### When are Hooks called?

In the Rails framework these hooks are called when a specific library is loaded. For example, when `ActionController::Base` is loaded, the `:action_controller_base` hook is called. This means that all `ActiveSupport.on_load` calls with `:action_controller_base` hooks will be called in the context of `ActionController::Base` (that means `self` will be an `ActionController::Base`).

### Modifying Code to use Load Hooks

Modifying code is generally straightforward. If you have a line of code that refers to a Rails framework such as `ActiveRecord::Base` you can wrap that code in a load hook.

**Modifying calls to `include`**

```ruby
ActiveRecord::Base.include(MyActiveRecordHelper)
```

becomes

```ruby
ActiveSupport.on_load(:active_record) do
  # self refers to ActiveRecord::Base here,
  # so we can call .include
  include MyActiveRecordHelper
end
```

**Modifying calls to `prepend`**

```ruby
ActionController::Base.prepend(MyActionControllerHelper)
```

becomes

```ruby
ActiveSupport.on_load(:action_controller_base) do
  # self refers to ActionController::Base here,
  # so we can call .prepend
  prepend MyActionControllerHelper
end
```

**Modifying calls to class methods**

```ruby
ActiveRecord::Base.include_root_in_json = true
```

becomes

```ruby
ActiveSupport.on_load(:active_record) do
  # self refers to ActiveRecord::Base here
  self.include_root_in_json = true
end
```

### Available Load Hooks

These are the load hooks you can use in your own code. To hook into the initialization process of one of the following classes use the available hook.

| Class                                | Hook                                 |
| -------------------------------------| ------------------------------------ |
| `ActionCable`                        | `action_cable`                       |
| `ActionCable::Channel::Base`         | `action_cable_channel`               |
| `ActionCable::Connection::Base`      | `action_cable_connection`            |
| `ActionCable::Connection::TestCase`  | `action_cable_connection_test_case`  |
| `ActionController::API`              | `action_controller_api`              |
| `ActionController::API`              | `action_controller`                  |
| `ActionController::Base`             | `action_controller_base`             |
| `ActionController::Base`             | `action_controller`                  |
| `ActionController::TestCase`         | `action_controller_test_case`        |
| `ActionDispatch::IntegrationTest`    | `action_dispatch_integration_test`   |
| `ActionDispatch::Response`           | `action_dispatch_response`           |
| `ActionDispatch::Request`            | `action_dispatch_request`            |
| `ActionDispatch::SystemTestCase`     | `action_dispatch_system_test_case`   |
| `ActionMailbox::Base`                | `action_mailbox`                     |
| `ActionMailbox::InboundEmail`        | `action_mailbox_inbound_email`       |
| `ActionMailbox::Record`              | `action_mailbox_record`              |
| `ActionMailbox::TestCase`            | `action_mailbox_test_case`           |
| `ActionMailer::Base`                 | `action_mailer`                      |
| `ActionMailer::TestCase`             | `action_mailer_test_case`            |
| `ActionText::Content`                | `action_text_content`                |
| `ActionText::Record`                 | `action_text_record`                 |
| `ActionText::RichText`               | `action_text_rich_text`              |
| `ActionView::Base`                   | `action_view`                        |
| `ActionView::TestCase`               | `action_view_test_case`              |
| `ActiveJob::Base`                    | `active_job`                         |
| `ActiveJob::TestCase`                | `active_job_test_case`               |
| `ActiveRecord::Base`                 | `active_record`                      |
| `ActiveStorage::Attachment`          | `active_storage_attachment`          |
| `ActiveStorage::VariantRecord`       | `active_storage_variant_record`      |
| `ActiveStorage::Blob`                | `active_storage_blob`                |
| `ActiveStorage::Record`              | `active_storage_record`              |
| `ActiveSupport::TestCase`            | `active_support_test_case`           |
| `i18n`                               | `i18n`                               |

### Available Configuration Hooks

Configuration hooks do not hook into any particular framework, but instead they run in context of the entire application.

| Hook                   | Use Case                                                                           |
| ---------------------- | ---------------------------------------------------------------------------------- |
| `before_configuration` | First configurable block to run. Called before any initializers are run.           |
| `before_initialize`    | Second configurable block to run. Called before frameworks initialize.             |
| `before_eager_load`    | Third configurable block to run. Does not run if `config.eager_load` set to false. |
| `after_initialize`     | Last configurable block to run. Called after frameworks initialize.                |

Configuration hooks can be called in the Engine class.

```ruby
module Blorgh
  class Engine < ::Rails::Engine
    config.before_configuration do
      puts 'I am called before any initializers'
    end
  end
end
```
