**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Começando com Rails
===================

Este guia aborda a instalação e a execução do Ruby on Rails.

Depois de ler este guia, você vai saber:

* Como instalar o Rails, criar uma nova aplicação Rails e conectar sua
  aplicação com um banco de dados.
* A estrutura geral de uma aplicação Rails.
* Os princípios básicos do MVC (**Model**, **View**, **Controller**) e design **RESTful**.
* Como gerar rapidamente as peças iniciais de uma aplicação Rails.

--------------------------------------------------------------------------------

Premissas do Guia
-----------------

Este guia é projetado para iniciantes que desejam começar uma aplicação Rails do
zero. Ele não assume que você tenha nenhuma experiência anterior com Rails.

O Rails é um _framework_ para aplicações web que é executado em cima da linguagem
de programação Ruby. Se você não tem nenhuma experiência com Ruby, você vai
achar a curva de aprendizado bastante íngrime começando direto com Rails.
Existem diversas listas organizadas de materiais online para aprender Ruby:

* [Site Oficial da Linguagem de Programação Ruby (Em inglês)](https://www.ruby-lang.org/en/documentation/)
* [Lista de Livros Grátis de Programação (Em inglês)](https://github.com/EbookFoundation/free-programming-books/blob/master/books/free-programming-books.md#ruby)

Fique atento que alguns materiais, apesar de excelentes, envolvem versões antigas
do Ruby e podem não incluir parte da sintaxe que você
vai ver no seu dia-a-dia desenvolvendo com Rails.

O que é o Rails?
--------------

Rails é um *framework* de desenvolvimento de aplicações *web* escrito na linguagem de programação Ruby.
Foi projetado para facilitar o desenvolvimento de aplicações *web*, criando premissas sobre tudo que uma pessoa desenvolvedora precisa para começar. Permite que você escreva menos código, enquanto realiza mais do que em muitas outras linguagens ou *frameworks.* Pessoas desenvolvedoras experientes em Rails, também dizem que desenvolver aplicações web ficou mais divertido.

Rails é um software opinativo. Assumindo que há uma "melhor" maneira para fazer as coisas, e foi projetado para encorajar essa maneira - e, em alguns casos para desencorajar alternativas. Se você aprender o "Rails Way", provavelmente terá um grande aumento de produtividade. Se você insistir nos velhos hábitos de outras linguagens, tentando usar os padrões que você aprendeu em outro lugar, você pode ter uma experiência menos feliz.

A filosofia do Rails possui dois princípios fundamentais:

* **Não repita a si mesmo:** DRY (don't repeat yourself) é um conceito de desenvolvimento de software que estabelece que "Todo conhecimento deve possuir uma representação única, de autoridade e livre de ambiguidades em todo o sistema". Ao não escrever as mesmas informações repetidamente, o código fica mais fácil de manter, de expandir e com menos _bugs_.
* **Convenção sobre configuração:** O Rails possui convenções sobre as melhores maneiras de fazer muitas coisas em uma aplicação web, devido a essas convenções você não precisa especificar detalhes através de arquivos de configuração infinitos.


Criando um Novo Projeto em Rails
---------------------------------

A melhor forma de ler esse guia é seguir o passo à passo. Todos os passos são
essenciais para rodar a aplicação de exemplo e nenhum código ou passos adicionais
serão necessários.

Seguindo este guia, você irá criar um projeto em *Rails* chamado de
`blog`, um *weblog* (muito) simples. Antes de você começar a construir a aplicação,
você precisa ter certeza de ter o *Rails* instalado.

NOTE: Os exemplos à seguir usam `$` para representar seu *prompt* de terminal em um
sistema operacional baseado em UNIX, mesmo que ele tenha sido customizado para parecer diferente.
Se você está utilizando Windows, seu *prompt* será parecido com algo como `C:\source_code>`.

### Instalando o Rails

Antes de você instalar o Rails, você deve validar para ter certeza que seu sistema
tem os pré requisitos necessários instalados. Esses incluem:

* Ruby 
* SQLite3
* Node.js
* Yarn

#### Instalando o Ruby

Abra o *prompt* de linha de comando. No *macOS* abra o *Terminal.app*; no *Windows*
escolha "Executar" no menu inicial e digite `cmd.exe`. Qualquer comando que antecede
o sinal de dólar `$` deverá ser rodado em linha de comando. Verifique se você tem a
versão atual do Ruby instalado:

```bash
$ ruby --version
ruby 2.5.0
```

O Rails necessita da versão Ruby 2.5.0 ou mais atual. Se o número da versão retornada
for menor que este número (como 2.3.7, e 1.8.7), você precisará instalar uma versão do Ruby mais atual.

Para instalar o Rails no Windows, você primeiro tem que instalar o [Ruby Installer](https://rubyinstaller.org). 

Para mais informações de instalação
de outros Sistemas Operacionais, dê uma olhada em [ruby-lang.org](https://www.ruby-lang.org/en/documentation/installation/).

#### Instalando o SQLite3

Você também precisará instalar o banco de dados SQLite3.
Muitos sistemas operacionais populares semelhantes ao UNIX são fornecidos com uma versão compatível do SQLite3.
Em outros sistemas você pode achar mais instruções de instalação em [SQLite3 website](https://www.sqlite.org).
Verifique se está corretamente instalado e carregado no seu `PATH`:

```bash
$ sqlite3 --version
```

O programa deverá reportar sua versão.

#### Instalando o Node.js e Yarn

Por fim, você precisará do Node.js e o Yarn instalados para gerenciar o JavaScript da sua aplicação.

Encontre as instruções de instalação no [site do Node.js](https://nodejs.org/en/download/) e
verifique se está instalado corretamente com o seguinte comando:

```bash 
$ node --version
```

A versão do Node.js deve ser impressa. Certifique-se de que é maior
que 8.16.0.

Para instalar o Yarn, siga as instruções de instalação
instruções no [site do Yarn](https://classic.yarnpkg.com/en/docs/install).

A execução deste comando deve imprimir a versão do Yarn:

```bash
$ yarn --version
```

Se aparecer algo como "1.22.0", o Yarn foi instalado corretamente.

#### Instalando o Rails

Para instalar o Rails, use o comando `gem install` fornecido pelo RubyGems:

```bash
$ gem install rails
```

Para verificar se você tem tudo instalado corretamente, você deve rodar o comando à seguir:

```bash
$ rails --version
```

Se esse comando retornar algo como "Rails 6.0.0", você está pronto para continuar.

### Criando a Aplicação Blog

O Rails vem com vários scripts chamados *generators* que são projetados para tornar
sua vida de desenvolvedor fácil, criando tudo que é necessário para começar a
trabalhar em uma tarefa em particular. Um desses é o *generator* de nova aplicação,
que irá te fornecer a base de uma nova aplicação em Rails para que você não precise
escrever tudo sozinho.

Para utilizar esse *generator*, abra um terminal, navegue para um diretório onde
você tenha permissão para criar arquivos, e rode:

```bash
$ rails new blog
```

Este comando irá criar uma aplicação em Rails chamada Blog em um diretório `blog`
e irá instalar as dependências das *gems* que já foram mencionadas no `Gemfile`
usando `bundle install`.

NOTE: Se você está utilizando um subsistema Windows para Linux então existem
algumas limitações nas notificações dos arquivos do sistema que significa que você
deve desabilitar as gems `spring` e `listen`, o que poderá ser feito rodando o comando
`rails new blog --skip-spring --skip-listen`.

TIP: Você pode ver todas as opções de linha de comando gerador que a aplicação Rails
aceita rodando o comando `rails new --help`.

Depois de criar a aplicação blog, entre em sua pasta:

```bash
$ cd blog
```

A pasta `blog` vai ter vários arquivos gerados e pastas que compõem a estrutura
de uma aplicação Rails. A maior parte da execução deste tutorial será feito na
pasta `app`, mas à seguir teremos um resumo básico das funções de cada um dos arquivos e pastas
que o Rails gerou por padrão:

| Arquivo/Pasta | Objetivo |
| ----------- | ------- |
|app/|Contém os *controllers*, *models*, *views*, *helpers*, *mailers*, *channels*, *jobs*, e *assets* para sua aplicação. Você irá se concentrar nesse diretório pelo restante desse guia.|
|bin/|Contém o script `rails` que inicializa sua aplicação e contém outros scripts que você utiliza para configurar, atualizar, colocar em produção ou executar sua aplicação.|
|config/|Contém configurações de rotas, banco de dados entre outros de sua aplicação. Este conteúdo é abordado com mais detalhes em [Configuring Rails Applications](configuring.html).|
|config.ru|Configuração *Rack* para servidores baseados em *Rack* usados para iniciar a aplicação. Para mais informações sobre o *Rack*, consulte [Rack website](https://rack.github.io/).|
|db/|Contém o *schema* do seu banco de dados atual, assim como as *migrations* do banco de dados.|
|Gemfile<br>Gemfile.lock|Esses arquivos permitem que você especifique quais dependências de *gem* são necessárias na sua aplicação Rails. Esses arquivos são usados pela *gem* Bundler. Para mais informações sobre o Bundler, acesse [o website do Bundler](https://bundler.io).|
|lib/|Módulos extendidos da sua aplicação.|
|log/|Arquivos de *log* da aplicação.|
|package.json|Este arquivo permite que você especifique quais dependências *npm* são necessárias para sua aplicação Rails. Este arquivo é usado pelo Yarn. Para mais informações do Yarn, acesse [o website do Yarn](https://yarnpkg.com/lang/en/).|
|public/|Contém arquivos estáticos e *assets* compilados. Quando sua aplicação está rodando esse diretório é exposto como ele está.|
|Rakefile|Este arquivo localiza e carrega tarefas que podem ser rodadas por linhas de comando. As tarefas são definidas nos componentes do Rails. Ao invés de editar o `Rakefile`, você deve criar suas próprias tarefas adicionando os arquivos no diretório `lib/tasks` da sua aplicação.|
|README.md|Este é um manual de instruções para sua aplicação. Você deve editar este arquivo para informar o que seu aplicativo faz, como configurá-lo e assim por diante.|
|storage/|Arquivos de armazenamento ativo do serviço de disco. Mais informações em [Active Storage Overview](active_storage_overview.html).|
|test/|Testes unitários, *fixtures*, e outros tipos de testes. Mais informações em [Testing Rails Applications](testing.html).|
|tmp/|Arquivos temporários (como cache e arquivos *pid*).|
|vendor/|Diretório com todos os códigos de terceiros. Em uma típica aplicação Rails inclui *vendored gems*.|
|.gitignore|Este arquivo diz ao Git quais arquivos (ou padrões) devem ser ignorados. Acesse [GitHub - Ignoring files](https://help.github.com/articles/ignoring-files) para mais informações sobre arquivos ignorados.|
|.ruby-version|Este arquivo contém a versão padrão do Ruby.|

Olá, Rails!
-----------

Para começar vamos colocar um texto na tela rapidamente. Para fazer isso, você
precisa que seu servidor de aplicação Rails esteja em execução.

### Inicializando o Servidor Web

Você já tem uma aplicação Rails funcional. Para vê-la você deve iniciar um
servidor web em sua máquina de desenvolvimento. Você pode fazer isso executando
o seguinte comando no diretório `blog`:

```bash
$ bin/rails server
```

TIP: Se você está usando Windows, deve executar os scripts do diretório
`bin` para o interpretador do Ruby: `ruby bin\rails server`.

TIP: A compressão de *assets* JavaScript requer que você tenha um executor
disponível em seu sistema operacional. Na ausência de um executor você verá um
erro de `execjs` durante a compressão dos *assets*. Geralmente o macOS e o Windows possuem um executor JavaScript instalado por
padrão. `therubyrhino` é o executor recomendado para usuários de JRuby e vem no
`Gemfile` por padrão em aplicações geradas com JRuby. Você pode avaliar todos
executores em [ExecJS](https://github.com/rails/execjs#readme).

A execução do comando irá iniciar o Puma, um servidor web distribuído com o
Rails por padrão. Para ver sua aplicação em execução, abra um navegador e
navegue para <http://localhost:3000>.  Você deve ver a página padrão com informações do Rails:

![Captura de tela escrito Yay! Você está no Rails(em inglês)](images/getting_started/rails_welcome.png)

Quando você deseja interromper a execução do servidor Web, pressione Ctrl+C na janela do
terminal em que o servidor está sendo executado. No ambiente de desenvolvimento, o Rails geralmente não requer que você reinicie o servidor; mudanças em arquivos são automaticamente interpretadas pelo servidor.

A página de "Yay! Você está no Rails! (Yay! You're on Rails!)" é o _smoke test_ (teste de sanidade) para uma
nova aplicação Rails: garante que o seu software esteja configurado
corretamente, o suficiente para gerar uma página.

### Diga "Olá", Rails

Para que o Rails diga "Olá", você precisa criar no mínimo uma rota (_route_), um _controller_ com uma _action_ e uma _view_. A _route_ mapeia uma requisição para uma _action_ de um _controller_. A _action_ do _controller_ faz todo o trabalho necessário para lidar com a requisição, e prepara qualquer dado para a _view_. A _view_  mostra o dado no formato que você quiser.

Em termos de implementação: Rotas são regras escritas em um [DSL (domain-specific language)](https://pt.wikipedia.org/wiki/Linguagem_de_dom%C3%ADnio_espec%C3%ADfico) em Ruby. _Controllers_ são classes Ruby, e seus métodos públicos são as _actions_. E as _views_ são _templates_, geralmente escritos numa mistura de Ruby e HTML.

Vamos começar adicionando uma rota ao nosso arquivo de rotas, `config/routes.rb`, no
topo do bloco `Rails.application.routes.draw`:

```ruby
Rails.application.routes.draw do
  get "/articles", to: "articles#index"

  # Para mais detalhes da DSL disponível para esse arquivo, veja https://guides.rubyonrails.org/routing.html
end
```

A rota acima declara que as requisições de `GET / articles` são mapeadas para o _action_ `index` do `ArticlesController`.

Para criar o `ArticlesController` e sua _action_ `index`, vamos executar o controlador
gerador (com a opção `--skip-routes` porque já temos um
rota apropriada):

```bash
$ bin/rails generate controller Articles index --skip-routes
```

O Rails vai gerar vários arquivos para você:

```
create  app/controllers/articles_controller.rb
invoke  erb
create    app/views/articles
create    app/views/articles/index.html.erb
invoke  test_unit
create    test/controllers/articles_controller_test.rb
invoke  helper
create    app/helpers/articles_helper.rb
invoke    test_unit
invoke  assets
invoke    scss
create      app/assets/stylesheets/articles.scss
```

Os mais importante desses é o arquivo _controller_, `app/controllers/welcome_controller.rb`. Vamos dar uma olhada nele:

```ruby
class ArticlesController < ApplicationController
  def index
  end
end
```

A _action_ `index` está vazia. Quando uma _action_ não renderiza explicitamente uma _view_
(ou de outra forma acionar uma resposta HTTP), o Rails irá renderizar automaticamente uma _view_
que corresponde ao nome do _controller_ e _action_. Convenção sobre
Configuração! As _views_ estão localizadas no diretório `app/views`. Portanto, a _action_ `index` renderizará `app/views/articles/index.html.erb` por padrão.

Vamos abrir o arquivo `app/views/articles/index.html.erb`, e substituir todo código existente por:

```html
<h1>Olá, Rails!</h1>
```

Se você parou anteriormente o servidor web para executar o gerador do _controller_,
reinicie-o com `bin/rails server`. Agora visite <http://localhost:3000/articles>
e veja nosso texto exibido!

### Configuração da Página Inicial da Aplicação

No momento, <http://localhost:3000> ainda exibe "Yay! Você está no Rails!".
Vamos mostrar nosso "Olá, Rails!" texto em <http://localhost:3000> também.
Para fazer isso, vamos adicionar uma rota que mapeia o caminho raiz (*root path*) da nossa aplicação para o _controller_ e _action_ apropriados.

Vamos abrir o arquivo `config/routes.rb`, e adicionar o a rota `root` no começo do bloco `Rails.application.routes.draw`:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
end
```

Agora podemos ver a mensagem "Olá, Rails!", quando visitamos <http://localhost:3000> confirmando que a _route_ `root` também mapeia para a _action_ `index` de `ArticlesController`.

TIP: Para mais informações sobre roteamento, consulte [Roteamento do Rails de Fora para Dentro](routing.html).


MVC and You
-----------

So far, we've discussed routes, controllers, actions, and views. All of these
are typical pieces of a web application that follows the [MVC (Model-View-Controller)](
https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller) pattern.
MVC is a design pattern that divides the responsibilities of an application to
make it easier to reason about. Rails follows this design pattern by convention.

Since we have a controller and a view to work with, let's generate the next
piece: a model.

### Generating a Model

A *model* is a Ruby class that is used to represent data. Additionally, models
can interact with the application's database through a feature of Rails called
*Active Record*.

To define a model, we will use the model generator:

```bash
$ bin/rails generate model Article title:string body:text
```

NOTE: Model names are **singular**, because an instantiated model represents a
single data record. To help remember this convention, think of how you would
call the model's constructor: we want to write `Article.new(...)`, **not**
`Articles.new(...)`.

This will create several files:

```
invoke  active_record
create    db/migrate/<timestamp>_create_articles.rb
create    app/models/article.rb
invoke    test_unit
create      test/models/article_test.rb
create      test/fixtures/articles.yml
```

The two files we'll focus on are the migration file
(`db/migrate/<timestamp>_create_articles.rb`) and the model file
(`app/models/article.rb`).

### Database Migrations

*Migrations* are used to alter the structure of an application's database. In
Rails applications, migrations are written in Ruby so that they can be
database-agnostic.

Let's take a look at the contents of our new migration file:

```ruby
class CreateArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
```

The call to `create_table` specifies how the `articles` table should be
constructed. By default, the `create_table` method adds an `id` column as an
auto-incrementing primary key. So the first record in the table will have an
`id` of 1, the next record will have an `id` of 2, and so on.

Inside the block for `create_table`, two columns are defined: `title` and
`body`. These were added by the generator because we included them in our
generate command (`bin/rails generate model Article title:string body:text`).

On the last line of the block is a call to `t.timestamps`. This method defines
two additional columns named `created_at` and `updated_at`. As we will see,
Rails will manage these for us, setting the values when we create or update a
model object.

Let's run our migration with the following command:

```bash
$ bin/rails db:migrate
```

The command will display output indicating that the table was created:

```
==  CreateArticles: migrating ===================================
-- create_table(:articles)
   -> 0.0018s
==  CreateArticles: migrated (0.0018s) ==========================
```

TIP: To learn more about migrations, see [Active Record Migrations](
active_record_migrations.html).

Now we can interact with the table using our model.

### Using a Model to Interact with the Database

To play with our model a bit, we're going to use a feature of Rails called the
*console*. The console is an interactive coding environment just like `irb`, but
it also automatically loads Rails and our application code.

Let's launch the console with this command:

```bash
$ bin/rails console
```

You should see an `irb` prompt like:

```irb
Loading development environment (Rails 6.0.2.1)
irb(main):001:0>
```

At this prompt, we can initialize a new `Article` object:

```irb
irb> article = Article.new(title: "Hello Rails", body: "I am on Rails!")
```

It's important to note that we have only *initialized* this object. This object
is not saved to the database at all. It's only available in the console at the
moment. To save the object to the database, we must call [`save`](
https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-save):

```irb
irb> article.save
(0.1ms)  begin transaction
Article Create (0.4ms)  INSERT INTO "articles" ("title", "body", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["title", "Hello Rails"], ["body", "I am on Rails!"], ["created_at", "2020-01-18 23:47:30.734416"], ["updated_at", "2020-01-18 23:47:30.734416"]]
(0.9ms)  commit transaction
=> true
```

The above output shows an `INSERT INTO "articles" ...` database query. This
indicates that the article has been inserted into our table. And if we take a
look at the `article` object again, we see something interesting has happened:

```irb
irb> article
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```

The `id`, `created_at`, and `updated_at` attributes of the object are now set.
Rails did this for us when we saved the object.

When we want to fetch this article from the database, we can call [`find`](
https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find)
on the model and pass the `id` as an argument:

```irb
irb> Article.find(1)
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```

And when we want to fetch all articles from the database, we can call [`all`](
https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-all)
on the model:

```irb
irb> Article.all
=> #<ActiveRecord::Relation [#<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">]>
```

This method returns an [`ActiveRecord::Relation`](
https://api.rubyonrails.org/classes/ActiveRecord/Relation.html) object, which
you can think of as a super-powered array.

TIP: To learn more about models, see [Active Record Basics](
active_record_basics.html) and [Active Record Query Interface](
active_record_querying.html).

Models are the final piece of the MVC puzzle. Next, we will connect all of the
pieces together.

### Showing a List of Articles

Let's go back to our controller in `app/controllers/articles_controller.rb`, and
change the `index` action to fetch all articles from the database:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end
end
```

Controller instance variables can be accessed by the view. That means we can
reference `@articles` in `app/views/articles/index.html.erb`. Let's open that
file, and replace its contents with:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= article.title %>
    </li>
  <% end %>
</ul>
```

The above code is a mixture of HTML and *ERB*. ERB is a templating system that
evaluates Ruby code embedded in a document. Here, we can see two types of ERB
tags: `<% %>` and `<%= %>`. The `<% %>` tag means "evaluate the enclosed Ruby
code." The `<%= %>` tag means "evaluate the enclosed Ruby code, and output the
value it returns." Anything you could write in a regular Ruby program can go
inside these ERB tags, though it's usually best to keep the contents of ERB tags
short, for readability.

Since we don't want to output the value returned by `@articles.each`, we've
enclosed that code in `<% %>`. But, since we *do* want to output the value
returned by `article.title` (for each article), we've enclosed that code in
`<%= %>`.

We can see the final result by visiting <http://localhost:3000>. (Remember that
`bin/rails server` must be running!) Here's what happens when we do that:

1. The browser makes a request: `GET http://localhost:3000`.
2. Our Rails application receives this request.
3. The Rails router maps the root route to the `index` action of `ArticlesController`.
4. The `index` action uses the `Article` model to fetch all articles in the database.
5. Rails automatically renders the `app/views/articles/index.html.erb` view.
6. The ERB code in the view is evaluated to output HTML.
7. The server sends a response containing the HTML back to the browser.

We've connected all the MVC pieces together, and we have our first controller
action! Next, we'll move on to the second action.

CRUDit Where CRUDit Is Due
--------------------------

Almost all web applications involve [CRUD (Create, Read, Update, and Delete)](
https://en.wikipedia.org/wiki/Create,_read,_update,_and_delete) operations. You
may even find that the majority of the work your application does is CRUD. Rails
acknowledges this, and provides many features to help simplify code doing CRUD.

Let's begin exploring these features by adding more functionality to our
application.

### Showing a Single Article

We currently have a view that lists all articles in our database. Let's add a
new view that shows the title and body of a single article.

We start by adding a new route that maps to a new controller action (which we
will add next). Open `config/routes.rb`, and insert the last route shown here:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
  get "/articles/:id", to: "articles#show"
end
```

The new route is another `get` route, but it has something extra in its path:
`:id`. This designates a route *parameter*. A route parameter captures a segment
of the request's path, and puts that value into the `params` Hash, which is
accessible by the controller action. For example, when handling a request like
`GET http://localhost:3000/articles/1`, `1` would be captured as the value for
`:id`, which would then be accessible as `params[:id]` in the `show` action of
`ArticlesController`.

Let's add that `show` action now, below the `index` action in
`app/controllers/articles_controller.rb`:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end
end
```

The `show` action calls `Article.find` ([mentioned
previously](#using-a-model-to-interact-with-the-database)) with the ID captured
by the route parameter. The returned article is stored in the `@article`
instance variable, so it is accessible by the view. By default, the `show`
action will render `app/views/articles/show.html.erb`.

Let's create `app/views/articles/show.html.erb`, with the following contents:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>
```

Now we can see the article when we visit <http://localhost:3000/articles/1>!

To finish up, let's add a convenient way to get to an article's page. We'll link
each article's title in `app/views/articles/index.html.erb` to its page:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="/articles/<%= article.id %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

### Resourceful Routing

So far, we've covered the "R" (Read) of CRUD. We will eventually cover the "C"
(Create), "U" (Update), and "D" (Delete). As you might have guessed, we will do
so by adding new routes, controller actions, and views. Whenever we have such a
combination of routes, controller actions, and views that work together to
perform CRUD operations on an entity, we call that entity a *resource*. For
example, in our application, we would say an article is a resource.

Rails provides a routes method named [`resources`](
https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources)
that maps all of the conventional routes for a collection of resources, such as
articles. So before we proceed to the "C", "U", and "D" sections, let's replace
the two `get` routes in `config/routes.rb` with `resources`:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles
end
```

We can inspect what routes are mapped by running the `bin/rails routes` command:

```bash
$ bin/rails routes
      Prefix Verb   URI Pattern                  Controller#Action
        root GET    /                            articles#index
    articles GET    /articles(.:format)          articles#index
 new_article GET    /articles/new(.:format)      articles#new
     article GET    /articles/:id(.:format)      articles#show
             POST   /articles(.:format)          articles#create
edit_article GET    /articles/:id/edit(.:format) articles#edit
             PATCH  /articles/:id(.:format)      articles#update
             DELETE /articles/:id(.:format)      articles#destroy
```

The `resources` method also sets up URL and path helper methods that we can use
to keep our code from depending on a specific route configuration. The values
in the "Prefix" column above plus a suffix of `_url` or `_path` form the names
of these helpers. For example, the `article_path` helper returns
`"/articles/#{article.id}"` when given an article. We can use it to tidy up our
links in `app/views/articles/index.html.erb`:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="<%= article_path(article) %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

However, we will take this one step further by using the [`link_to`](
https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)
helper. The `link_to` helper renders a link with its first argument as the
link's text and its second argument as the link's destination. If we pass a
model object as the second argument, `link_to` will call the appropriate path
helper to convert the object to a path. For example, if we pass an article,
`link_to` will call `article_path`. So `app/views/articles/index.html.erb`
becomes:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>
```

Nice!

TIP: To learn more about routing, see [Rails Routing from the Outside In](
routing.html).

### Creating a New Article

Now we move on to the "C" (Create) of CRUD. Typically, in web applications,
creating a new resource is a multi-step process. First, the user requests a form
to fill out. Then, the user submits the form. If there are no errors, then the
resource is created and some kind of confirmation is displayed. Else, the form
is redisplayed with error messages, and the process is repeated.

In a Rails application, these steps are conventionally handled by a controller's
`new` and `create` actions. Let's add a typical implementation of these actions
to `app/controllers/articles_controller.rb`, below the `show` action:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(title: "...", body: "...")

    if @article.save
      redirect_to @article
    else
      render :new
    end
  end
end
```

The `new` action instantiates a new article, but does not save it. This article
will be used in the view when building the form. By default, the `new` action
will render `app/views/articles/new.html.erb`, which we will create next.

The `create` action instantiates a new article with values for the title and
body, and attempts to save it. If the article is saved successfully, the action
redirects the browser to the article's page at `"http://localhost:3000/articles/#{@article.id}"`.
Else, the action redisplays the form by rendering `app/views/articles/new.html.erb`.
The title and body here are dummy values. After we create the form, we will come
back and change these.

NOTE: [`redirect_to`](https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to)
will cause the browser to make a new request,
whereas [`render`](https://api.rubyonrails.org/classes/AbstractController/Rendering.html#method-i-render)
renders the specified view for the current request.
It is important to use `redirect_to` after mutating the database or application state.
Otherwise, if the user refreshes the page, the browser will make the same request, and the mutation will be repeated.

#### Using a Form Builder

We will use a feature of Rails called a *form builder* to create our form. Using
a form builder, we can write a minimal amount of code to output a form that is
fully configured and follows Rails conventions.

Let's create `app/views/articles/new.html.erb` with the following contents:

```html+erb
<h1>New Article</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

The [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)
helper method instantiates a form builder. In the `form_with` block we call
methods like [`label`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-label)
and [`text_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-text_field)
on the form builder to output the appropriate form elements.

The resulting output from our `form_with` call will look like:

```html
<form action="/articles" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="...">

  <div>
    <label for="article_title">Title</label><br>
    <input type="text" name="article[title]" id="article_title">
  </div>

  <div>
    <label for="article_body">Body</label><br>
    <textarea name="article[body]" id="article_body"></textarea>
  </div>

  <div>
    <input type="submit" name="commit" value="Create Article" data-disable-with="Create Article">
  </div>
</form>
```

TIP: To learn more about form builders, see [Action View Form Helpers](
form_helpers.html).

#### Using Strong Parameters

Submitted form data is put into the `params` Hash, alongside captured route
parameters. Thus, the `create` action can access the submitted title via
`params[:article][:title]` and the submitted body via `params[:article][:body]`.
We could pass these values individually to `Article.new`, but that would be
verbose and possibly error-prone. And it would become worse as we add more
fields.

Instead, we will pass a single Hash that contains the values. However, we must
still specify what values are allowed in that Hash. Otherwise, a malicious user
could potentially submit extra form fields and overwrite private data. In fact,
if we pass the unfiltered `params[:article]` Hash directly to `Article.new`,
Rails will raise a `ForbiddenAttributesError` to alert us about the problem.
So we will use a feature of Rails called *Strong Parameters* to filter `params`.
Think of it as [strong typing](https://en.wikipedia.org/wiki/Strong_and_weak_typing)
for `params`.

Let's add a private method to the bottom of `app/controllers/articles_controller.rb`
named `article_params` that filters `params`. And let's change `create` to use
it:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

TIP: To learn more about Strong Parameters, see [Action Controller Overview §
Strong Parameters](action_controller_overview.html#strong-parameters).

#### Validations and Displaying Error Messages

As we have seen, creating a resource is a multi-step process. Handling invalid
user input is another step of that process. Rails provides a feature called
*validations* to help us deal with invalid user input. Validations are rules
that are checked before a model object is saved. If any of the checks fail, the
save will be aborted, and appropriate error messages will be added to the
`errors` attribute of the model object.

Let's add some validations to our model in `app/models/article.rb`:

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

The first validation declares that a `title` value must be present. Because
`title` is a string, this means that the `title` value must contain at least one
non-whitespace character.

The second validation declares that a `body` value must also be present.
Additionally, it declares that the `body` value must be at least 10 characters
long.

NOTE: You may be wondering where the `title` and `body` attributes are defined.
Active Record automatically defines model attributes for every table column, so
you don't have to declare those attributes in your model file.

With our validations in place, let's modify `app/views/articles/new.html.erb` to
display any error messages for `title` and `body`:

```html+erb
<h1>New Article</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% @article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% @article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

The [`full_messages_for`](https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_messages_for)
method returns an array of user-friendly error messages for a specified
attribute. If there are no errors for that attribute, the array will be empty.

To understand how all of this works together, let's take another look at the
`new` and `create` controller actions:

```ruby
  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new
    end
  end
```

When we visit <http://localhost:3000/articles/new>, the `GET /articles/new`
request is mapped to the `new` action. The `new` action does not attempt to save
`@article`. Therefore, validations are not checked, and there will be no error
messages.

When we submit the form, the `POST /articles` request is mapped to the `create`
action. The `create` action *does* attempt to save `@article`. Therefore,
validations *are* checked. If any validation fails, `@article` will not be
saved, and `app/views/articles/new.html.erb` will be rendered with error
messages.

TIP: To learn more about validations, see [Active Record Validations](
active_record_validations.html). To learn more about validation error messages,
see [Active Record Validations § Working with Validation Errors](
active_record_validations.html#working-with-validation-errors).

#### Finishing Up

We can now create an article by visiting <http://localhost:3000/articles/new>.
To finish up, let's link to that page from the bottom of
`app/views/articles/index.html.erb`:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

### Updating an Article

We've covered the "CR" of CRUD. Now let's move on to the "U" (Update). Updating
a resource is very similar to creating a resource. They are both multi-step
processes. First, the user requests a form to edit the data. Then, the user
submits the form. If there are no errors, then the resource is updated. Else,
the form is redisplayed with error messages, and the process is repeated.

These steps are conventionally handled by a controller's `edit` and `update`
actions. Let's add a typical implementation of these actions to
`app/controllers/articles_controller.rb`, below the `create` action:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

Notice how the `edit` and `update` actions resemble the `new` and `create`
actions.

The `edit` action fetches the article from the database, and stores it in
`@article` so that it can be used when building the form. By default, the `edit`
action will render `app/views/articles/edit.html.erb`.

The `update` action (re-)fetches the article from the database, and attempts
to update it with the submitted form data filtered by `article_params`. If no
validations fail and the update is successful, the action redirects the browser
to the article's page. Else, the action redisplays the form, with error
messages, by rendering `app/views/articles/edit.html.erb`.

#### Using Partials to Share View Code

Our `edit` form will look the same as our `new` form. Even the code will be the
same, thanks to the Rails form builder and resourceful routing. The form builder
automatically configures the form to make the appropriate kind of request, based
on whether the model object has been previously saved.

Because the code will be the same, we're going to factor it out into a shared
view called a *partial*. Let's create `app/views/articles/_form.html.erb` with
the following contents:

```html+erb
<%= form_with model: article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

The above code is the same as our form in `app/views/articles/new.html.erb`,
except that all occurrences of `@article` have been replaced with `article`.
Because partials are shared code, it is best practice that they do not depend on
specific instance variables set by a controller action. Instead, we will pass
the article to the partial as a local variable.

Let's update `app/views/articles/new.html.erb` to use the partial via [`render`](
https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render):

```html+erb
<h1>New Article</h1>

<%= render "form", article: @article %>
```

NOTE: A partial's filename must be prefixed **with** an underscore, e.g.
`_form.html.erb`. But when rendering, it is referenced **without** the
underscore, e.g. `render "form"`.

And now, let's create a very similar `app/views/articles/edit.html.erb`:

```html+erb
<h1>Edit Article</h1>

<%= render "form", article: @article %>
```

TIP: To learn more about partials, see [Layouts and Rendering in Rails § Using
Partials](layouts_and_rendering.html#using-partials).

#### Finishing Up

We can now update an article by visiting its edit page, e.g.
<http://localhost:3000/articles/1/edit>. To finish up, let's link to the edit
page from the bottom of `app/views/articles/show.html.erb`:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
</ul>
```

### Deleting an Article

Finally, we arrive at the "D" (Delete) of CRUD. Deleting a resource is a simpler
process than creating or updating. It only requires a route and a controller
action. And our resourceful routing (`resources :articles`) already provides the
route, which maps `DELETE /articles/:id` requests to the `destroy` action of
`ArticlesController`.

So, let's add a typical `destroy` action to `app/controllers/articles_controller.rb`,
below the `update` action:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

The `destroy` action fetches the article from the database, and calls [`destroy`](
https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-destroy)
on it. Then, it redirects the browser to the root path.

We have chosen to redirect to the root path because that is our main access
point for articles. But, in other circumstances, you might choose to redirect to
e.g. `articles_path`.

Now let's add a link at the bottom of `app/views/articles/show.html.erb` so that
we can delete an article from its own page:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article),
                  method: :delete,
                  data: { confirm: "Are you sure?" } %></li>
</ul>
```

In the above code, we're passing a few additional options to `link_to`. The
`method: :delete` option causes the link to make a `DELETE` request instead of a
`GET` request. The `data: { confirm: "Are you sure?" }` option causes a
confirmation dialog to appear when the link is clicked. If the user cancels the
dialog, the request is aborted. Both of these options are powered by a feature
of Rails called *Unobtrusive JavaScript* (UJS). The JavaScript file that
implements these behaviors is included by default in fresh Rails applications.

TIP: To learn more about Unobtrusive JavaScript, see [Working With JavaScript in
Rails](working_with_javascript_in_rails.html).

And that's it! We can now list, show, create, update, and delete articles!
InCRUDable!

Adicionando um Segundo Model
----------------------------

É hora de adicionar um segundo *model* à aplicação. O segundo *model* vai lidar com
comentários em artigos.

### Gerando um Model

Nós veremos o mesmo *generator* que usamos antes quando criamos o *model*
`Article` (artigo, inglês). Desta vez vamos criar um *model* `Comment` (comentário)
que contém a referência para um artigo. Rode esse comando no seu terminal:

```bash
$ bin/rails generate model Comment commenter:string body:text article:references
```

Este comando vai gerar quatro arquivos:


| Arquivo                                      | Propósito                                                                                                       |
| -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------|
| db/migrate/20140120201010_create_comments.rb | *Migration* para criar a tabela de comentários no seu banco de dados (o nome incluirá um *timestamp* diferente) |
| app/models/comment.rb                        | O *model* Comment                                                                                               |
| test/models/comment_test.rb                  | Aparelhagem de testes para o *model* de comentário                                                              |
| test/fixtures/comments.yml                   | Exemplo de comentários para uso em testes                                                                       |

Primeiro, veja o arquivo `app/models/comment.rb`:

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

Isso é muito semelhante ao *model* `Article` que vimos antes. A diferença está na
linha `belongs_to : article`, o que configura uma associação no *Active Record*.
Você vai aprender um pouco sobre associações na próxima seção deste guia.

A palavra-chave (`:references`) usada no comando `bash` é um tipo especial de
dado para *models*. Ela cria uma nova coluna na tabela do banco de dados com o
nome fornecido ao *model* anexada a um `_id` que contém um valor do tipo
*integer*. Para compreender melhor, analise o arquivo `db/schema.rb` depois de
rodar a *migration*.

Além do *model*, o Rails também gerou a *migration* para criar a tabela
correspondente no banco de dados:

```ruby
class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.string :commenter
      t.text :body
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```
A linha `t.references` cria uma coluna com valores do tipo *integer* chamada
`article_id`, um índice para ela e uma restrição de chave estrangeira (*foreign key*)
que aponta para a coluna `id` da tabela `articles`. Vá em frente e rode a
*migration*:

```bash
$ bin/rails db:migrate
```

O Rails é inteligente o suficiente para executar somente as migrações que ainda
não foram rodadas no banco de dados atual, assim neste caso você verá:

```
==  CreateComments: migrating =================================================
-- create_table(:comments)
   -> 0.0115s
==  CreateComments: migrated (0.0119s) ========================================
```
### Associando Models

Associações do *Active Record* permitem declarar facilmente a relação entre dois
*models*. No caso de comentários e artigos, você poderia descrever a relação
da seguinte maneira:

* Cada comentário pertece a um artigo.
* Um artigo pode possuir muitos comentários.

De fato, essa sintaxe é muito similar à utilizada pelo Rails para declarar essa
associação. Você já viu a linha de código dentro do *model* `Comment`
(`app/models/comment.rb`) que faz com que cada comentário pertença a um Artigo:

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```
Você vai precisar editar o arquivo `app/models/article.rb` para adicionar o outro lado da
associação:

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

Estas duas declarações habilitam uma boa parte de comportamento automático. Por
exemplo, se você possui uma instância da variável `@article` que contém um
artigo, você pode recuperar todos os comentários pertencentes àquele artigo na
forma de um *array* usando `@article.comments`.

TIP: Para mais informações sobre associações do *Active Record*, veja o guia
[Associações no Active Record](association_basics.html).

### Adicionando a Rota para Comentários

Da mesma forma que o *controller* `welcome`, nós vamos precisar adicionar a
rota para que o Rails saiba para onde queremos navegar para encontrar
`comments`. Abra o arquivo `config/routes.rb` novamente e o edite da seguinte
maneira:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles do
    resources :comments
  end
end
```

Isso cria `comments` como um recurso aninhado (_nested resource_) dentro de `article`. Essa é
outra parte do processo para recuperar as relações hierárquicas que existem  entre
artigos e comentários.

TIP: Para mais informações sobre rotas, veja o guia [Roteamento no Rails](routing.html)

### Gerando um Controller

Com o *model* em mãos, você pode voltar sua atenção para a criação do
*controller* correspondente. Mais uma vez, você vai usar o *generator* usado
anteriormente:

```bash
$ bin/rails generate controller Comments
```
Isso cria quatro arquivos e um diretório vazio:

| Arquivo/Diretório                            | Propósito                                            |
| -------------------------------------------- | ---------------------------------------------------- |
| app/controllers/comments_controller.rb       | O *controller* de comentários                        |
| app/views/comments/                          | *Views* do *controller* são armazenadas aqui         |
| test/controllers/comments_controller_test.rb | O teste para o *controller*                          |
| app/helpers/comments_helper.rb               | Arquivo de *helpers* da *view*                       |
| app/assets/stylesheets/comments.scss         | *Cascading style sheet* (CSS) para o *controller*    |

Como em qualquer blog, nossos leitores vão criar seus comentários diretamente
depois de lerem o artigo e, uma vez que adicionarem o comentário, serão enviados
de volta para a página *show* do artigo para verem o comentário agora listado.
Por essa razão, nosso `CommentsController` está aqui para fornecer um método que
cria comentários e deleta comentários *spam* quando chegarem.

Então, primeiro nós vamos ligar o *show template* para Artigos (`app/views/articles/show.html.erb`)
para que possamos criar um novo comentários:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article),
                  method: :delete,
                  data: { confirm: "Are you sure?" } %></li>
</ul>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Isso adiciona na página *show* do `Article` um formulário que cria um novo
comentário chamando a *action* `create` no `CommentsController`. O `form_with`
aqui usa um *array* que vai construir uma rota aninhada, como `/articles/1/comments`.

Vamos ligar a *action* `create` em `app/controllers/comments_controller.rb`:

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```
Você verá um pouco mais de complexidade aqui do que no *controller* para
artigos. Esse é o efeito colateral do aninhamento que você configurou. Cada
requisição para um comentário deve lembrar o artigo ao qual o comentário está
anexado, para que a chamada inicial do método `find` do *model* `Article`
encontre o artigo em questão.

Além disso, o código aproveita-se de alguns métodos disponíveis para uma
associação. Nós usamos o método `create` em `@article.comments` para criar e
salvar um comentário. Isso vai automaticamente conectar o comentário para que
ele pertença àquele artigo em particular.

Uma vez que temos um novo comentário, nós enviamos o usuário de volta ao artigo
original usando o helper `article_path(@article)`. Como já vimos
anteriormente, isso chama a *action* `show` do `ArticlesController` que por sua
vez renderiza o *template* `show.html.erb`. É aqui que queremos que o comentário
apareça, então vamos adicionar isso ao arquivo `app/views/articles/show.html.erb`.

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article),
                  method: :delete,
                  data: { confirm: "Are you sure?" } %></li>
</ul>

<h2>Comments</h2>
<% @article.comments.each do |comment| %>
  <p>
    <strong>Commenter:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comment:</strong>
    <%= comment.body %>
  </p>
<% end %>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Agora podemos adicionar artigos e comentários ao seu blog e mostrá-los nos
lugares certos.

![Article with Comments](images/getting_started/article_with_comments.png)

Refatorando
-----------

Agora que nossos artigos e comentários funcionam, dê uma olhada no template
`app/views/articles/show.html.erb`. Ele está ficando longo e esquisito. Nós
podemos usar *partials* (*views* parciais) para melhorá-lo.

### Renderizando Coleções de *Partials*

Primeiramente, nós vamos criar uma *partial* para extrair a exibição de todos os
comentários para o artigo. Crie o arquivo `app/views/comments/_comment.html.erb`
e insira o código a seguir:

```html+erb
<p>
  <strong>Commenter:</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>Comment:</strong>
  <%= comment.body %>
</p>
```

Então você pode mudar `app/views/articles/show.html.erb` para o seguinte código:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article),
                  method: :delete,
                  data: { confirm: "Are you sure?" } %></li>
</ul>

<h2>Comments</h2>
<%= render @article.comments %>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Isso fará com que a *partial* seja renderizada em `app/views/comments/_comment.html.erb`
uma vez para cada comentário na coleção `@article.comments`. Como o método
`render` itera sobre a coleção `@article.comments`, ele designa cada comentário
para uma variável local nomeada como a *partial*, nesse caso `comment`, que então
fica disponível para ser exibida na *partial*.

### Renderizando um Formulário com *Partial*

Agora vamos mover aquela nova seção de comentários para sua própria *partial*.
Novamente, crie o arquivo `app/viewscomments/_form.html.erb` contendo:

```html+erb
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Então deixe o arquivo `app/views/articles/show.html.erb` assim:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article),
                  method: :delete,
                  data: { confirm: "Are you sure?" } %></li>
</ul>

<h2>Comments</h2>
<%= render @article.comments %>

<h2>Add a comment:</h2>
<%= render 'comments/form' %>
```

O segundo *render* apenas define o template de *partial* que queremos renderizar,
`comments/form`. O Rails é inteligente o suficiente para entender a barra nessa
string e perceber que você quer renderizar o arquivo `_form.html.erb` no
diretório `app/views/comments`.

O objeto `@article` está disponível para todas as *partials* renderizadas na view
porque o definimos como uma variável de instância.

### Usando *Concerns*

*Concerns* são uma forma de tornar grandes _controllers_ ou _models_ mais fáceis de entender e gerenciar. Isso também tem a vantagem de ser reutilizável quando vários _models_ (ou _controllers_) compartilham as mesmas preocupações. As *concerns* são implementadas usando módulos (`module`) que contêm métodos que representam uma fatia bem definida da funcionalidade pela qual um _model_ ou _controller_ é responsável. Em outras linguagens, os módulos costumam ser conhecidos como *mixins*.

Você pode usar as *concerns* em seu _controller_ ou _model_ da mesma forma que usaria qualquer módulo. Quando você criou sua aplicação pela primeira vez com `rails new blog`, duas pastas foram criadas dentro de `app/` junto com o resto:

```
app/controllers/concerns
app/models/concerns
```

 Um determinado artigo do blog pode ter vários status - por exemplo, pode ser visível para todos (ou seja, `public`), ou visível apenas para o autor (ou seja, `private`). Também pode estar oculto para todos, mas ainda pode ser recuperado (ou seja, `archived`). Os comentários também podem estar ocultos ou visíveis. Isso pode ser representado usando uma coluna `status` em cada um dos _models_.

Dentro do _model_ `article`, após executar uma _migration_ para adicionar uma coluna `status`, você pode adicionar:

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

e no _model_ `Comment`:

```ruby
class Comment < ApplicationRecord
  belongs_to :article

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

Então, em nossa _action_ `index` (`app/views/articles/index.html.erb`), usaríamos o método `archived?` Para evitar a exibição de qualquer artigo que está arquivado:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

No entanto, se você olhar novamente para nossos _models_ agora, pode ver que a lógica está duplicada. Se, no futuro, aumentarmos a funcionalidade do nosso blog - para incluir mensagens privadas, por exemplo - podemos ver a duplicação de lógica mais uma vez. É aqui que as *concerns* são úteis.

Uma *concerns* é responsável apenas por um subconjunto específico da responsabilidade do _model_; os métodos na nossa *concern* estarão todos relacionados à visibilidade de um _model_. Vamos chamar nossa nova *concern* (módulo) de `Visible`. Podemos criar um novo arquivo dentro de `app/models/concerns` chamado` visible.rb`, e armazenar todos os métodos de status que foram duplicados nos _models_.

`app/models/concerns/visible.rb`

```ruby
module Visible
  def archived?
    status == 'archived'
  end
end
```

Podemos adicionar nossa validação de status à *concern*, mas isso é um pouco mais complexo, pois as validações são métodos chamados no nível da classe. O `ActiveSupport::Concern` ([API Guide] (https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)) nos dá uma maneira mais simples de incluí-los:

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  def archived?
    status == 'archived'
  end
end
```

Agora, podemos remover a lógica duplicada de cada _model_ e, em vez disso, incluir nosso novo módulo `Visible`:

Em `app/models/article.rb`:

```ruby
class Article < ApplicationRecord
  include Visible
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

e em `app/models/comment.rb`:

```ruby
class Comment < ApplicationRecord
  include Visible
  belongs_to :article
end
```

Os métodos de classe também podem ser adicionados às *concerns*. Se quisermos que uma contagem de artigos públicos ou comentários sejam exibidos em nossa página principal, podemos adicionar um método de classe a `Visible` da seguinte maneira:

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  class_methods do
    def public_count
      where(status: 'public').count
    end
  end

  def archived?
    status == 'archived'
  end
end
```

Então, na _view_, você pode chamá-lo como qualquer método de classe:

```html+erb
<h1>Articles</h1>

Our blog has <%= Article.public_count %> articles and counting!

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

Existem mais algumas etapas a serem realizadas antes que nossa aplicaçãi funcione com a adição da coluna `status`. Primeiro, vamos executar as seguintes *migrations* para adicionar `status` aos `Articles` e `Comments`:

```bash
$ bin/rails generate migration AddStatusToArticles status:string
$ bin/rails generate migration AddStatusToComments status:string
```

TIP: Para aprender mais sobre *migrations*, veja em [Active Record Migrations](
active_record_migrations.html).

Também temos que permitir a chave `:status` como parte do parâmetro (usando *strong parameters*), em `app/controllers/articles_controller.rb`:

```ruby
private
    def article_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
```

e em `app/controllers/comments_controller.rb`:

```ruby
private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
```

Para finalizar, adicionaremos uma caixa de seleção aos formulários e permitiremos que o usuário selecione o status ao criar um novo artigo ou postar um novo comentário. Também podemos especificar o status padrão como `public`. Em `app/views/articles/_form.html.erb`, podemos adicionar:

```html+erb
<div>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</div>
```

e em `app/views/comments/_form.html.erb`:

```html+erb
<p>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</p>
```

Deletando Comentários
-----------------

Outra importante *feature* de um blog é excluir comentários de spam. Para fazer
isto, nós precisamos implementar um link de alguma *view* e uma *action*
`destroy` no `CommentsController`.

Primeiro, vamos adicionar o link *delete* na *partial*
`app/views/comments/_comment.html.erb`:

```html+erb
<p>
  <strong>Autor do comentário:</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>Comentário:</strong>
  <%= comment.body %>
</p>

<p>
  <%= link_to 'Destruir comentário', [comment.article, comment],
              method: :delete,
              data: { confirm: "Are you sure?" } %>
</p>
```

Clicar neste novo link "Destruir comentário" será disparado um `DELETE
/articles/:article_id/comments/:id` ao nosso `CommentsController`, que
pode ser usar isso para encontrar o comentário que queremos excluir, então vamos adicionar
uma ação `destroy` ao nosso *controller* (`app/controllers/comments_controller.rb`):

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```

A *action* `destroy` vai encontrar o artigo que estamos vendo, localizar o
comentário na *collection* `@article.comments`, removê-lo do seu banco de
dados e nos enviar de volta para a *action* `show` do artigo.

### Excluindo objetos associados

Se você excluir um artigo, os comentários (comments) associados também precisarão ser
excluídos, caso contrário, eles simplesmente ocupariam espaço no banco de dados.
O Rails permite que você use a opção `dependent` de uma associação para conseguir isso.
Modifique o Modelo de artigo (article), `app/models/article.rb`, da seguinte forma:

```ruby
class Article < ApplicationRecord
  include Visible

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

Segurança
--------

### Autenticação Básica

Se fosse fosse publicar o seu blog online, qualquer um poderia adicionar, editar
e deletar seus artigos ou comentários.

O Rails disponibiliza um sistema de autenticação HTTP que funcionará
tranquilamente nesta situação.

No `ArticlesController` nós precisamos que tenha um meio de bloquear o acesso à
várias ações se uma pessoa não estiver autenticada. Aqui podemos usar o método
`http_basic_authenticate_with`, que permite o acesso para a ação requisitada se
o método deixar.

Para usar o sistema de autenticação, nós especificamos no topo do nosso
`ArticlesController` em `app/controllers/articles_controller.rb`. No nosso caso,
nós queremos que o usuário esteja autenticado em todas as ações, exceto `index`
e `show`, então nós colocamos isso:

```ruby
class ArticlesController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", except: [:index, :show]

  def index
    @articles = Article.all
  end

  # snippet for brevity
```
Nós também queremos autorizar somente usuários autenticados a deletar
comentários, então em `CommentsController`
(`app/controllers/comments_controller.rb`) nós colocamos:

```ruby
class CommentsController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", only: :destroy

  def create
    @article = Article.find(params[:article_id])
    # ...
  end

  # snippet for brevity
```

Agora se você tentar criar um novo artigo, você deverá preencher um formulário de autenticação:

![Formulário de Autenticação](images/getting_started/challenge.png)

Outros métodos de autenticação estão disponíveis para aplicações Rails. Dois
*add-ons* de autenticação populares para Rails são o
[Devise](https://github.com/plataformatec/devise) e o
[Authlogic](https://github.com/binarylogic/authlogic) entre outros.

### Outras Considerações de Segurança

Segurança, especialmente em aplicações web, é uma area ampla e detalhada. O
tópico de segurança aplicações Rails é coberto com mais detalhes em
[Guia de Segurança Ruby on Rails](security.html).

O que vem depois?
-----------------

Agora que você criou sua primeira aplicação Rails, sinta-se à vontade para
atualizar e experimentar por conta própria.

Lembre-se, você não precisa fazer tudo sem ajuda. Se você precisa de
assistência para começar a desenvolver com Rails, sinta-se à vontade para
consultar estes recursos:

* O [Guia Rails](index.html)
* O [Ruby on Rails Guides](https://guides.rubyonrails.org)
* A [lista de discussão do Ruby on Rails](https://discuss.rubyonrails.org/c/rubyonrails-talk)
* O canal [#rubyonrails](irc://irc.freenode.net/#rubyonrails) no irc.freenode.net


Dicas de Configuração
---------------------

O caminho mais fácil para se trabalhar com o Rails é armazenar todos os dados
externos como UTF-8. Se não fizer assim, as bibliotecas Ruby e o Rails vão, na
maioria das vezes, conseguir converter seus dados nativos em UTF-8, porém não
é sempre que isso funciona corretamente, então é melhor que você assegure que
todos seus dados externos estão em UTF-8.

Caso tenha cometido um erro nessa parte, o sintoma mais comum é o aparecimento
de um diamante preto com um ponto de interrogação dentro no seu navegador. Outro
sintoma comum é o aparecimento de caracteres como "Ã¼" ao invés de "ü". O Rails
executa um número de passos internos para mitigar causas comuns desses problemas
que possam ser detectadas e corrigidas automaticamente. Porém, caso você possua
dados externos que não estão armazenados como UTF-8, eles poderão ocasionalmente
resultar em problemas que não podem ser detectados e nem resolvidos de forma
automática pelo Rails.

Duas fontes muito comuns de dados que não estão em UTF-8 são:

* Seu editor de texto: A maioria dos editores de texto (como o TextMate), salvam
  os arquivos em UTF-8 de forma padrão. Caso o seu editor de texto não salve,
  isso pode resultar em caracteres especiais inseridos por você nos seus
  _templates_ (como por exemplo: é) aparecerem no navegador como um diamante
  com um ponto de interrogação dentro. Isso também se aplica aos seus arquivos
  de tradução i18n. Muitos editores que não salvam em UTF-8 por padrão (como
  algumas versões do Dreamweaver) oferecem uma forma de alterar o padrão para
  UTF-8. Faça isso.
* Seu banco de dados: o Rails converte seus dados do banco de dados em UTF-8
  de forma padrão. Porém, se seu banco de dados não está utilizando UTF-8
  internamente, pode ser que não consiga armazenar todos os caracteres que seus
  usuários insiram. Por exemplo, se seu banco de dados está utilizando Latin-1
  internamente, e seu usuário inserir um caractere russo, hebraico ou japonês,
  os dados serão perdidos para sempre assim que entrarem no banco de dados. Se
  possível, utilize UTF-8 como padrão de armazenamento para o seu banco de dados.
