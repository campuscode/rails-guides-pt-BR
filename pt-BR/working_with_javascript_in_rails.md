**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Trabalhando com JavaScript no Rails
================================

Este guia aborda as opções para integrar funcionalidades JavaScript na aplicação Rails,
incluindo as opções para usar pacotes JavaScript externos e como usar Turbo com
o Rails.

Após ler este guia, você saberá:

* Como usar o Rails sem precisar de Node.js, Yarn, ou um *empacotador (bundler)* JavaScript.
* Como criar uma nova aplicação Rails usando *import maps*, *esbuild*, *rollup*, ou *webpack* para empacotar
seu JavaScript.
* O que é o Turbo, e como usá-lo.
* Como usar os auxiliares do Turbo HTML fornecidos pelo Rails.

-------------------------------------------------------------------------------

Import maps
-----------

[Import maps](https://github.com/rails/importmap-rails) let you import JavaScript modules using
logical names that map to versioned files directly from the browser. Import maps are the default
from Rails 7, allowing anyone to build modern JavaScript applications using most NPM packages
without the need for transpiling or bundling.

Applications using import maps do not need [Node.js](https://nodejs.org/en/) or
[Yarn](https://yarnpkg.com/) to function. If you plan to use Rails with `importmap-rails` to
manage your JavaScript dependencies, there is no need to install Node.js or Yarn.

When using import maps, no separate build process is required, just start your server with
`bin/rails server` and you are good to go.

### Adding NPM Packages with importmap-rails

To add new packages to your import map-powered application, run the `bin/importmap pin` command
from your terminal:

```bash
$ bin/importmap pin react react-dom
```

Then, import the package into `application.js` as usual:

```javascript
import React from "react"
import ReactDOM from "react-dom"
```

Adding NPM Packages with JavaScript Bundlers
--------

Import maps are the default for new Rails applications, but if you prefer traditional JavaScript
bundling, you can create new Rails applications with your choice of
[esbuild](https://esbuild.github.io/), [webpack](https://webpack.js.org/), or
[rollup.js](https://rollupjs.org/guide/en/).

To use a bundler instead of import maps in a new Rails application, pass the `—javascript` or `-j`
option to `rails new`:

```bash
$ rails new my_new_app --javascript=webpack
OR
$ rails new my_new_app -j webpack
```

These bundling options each come with a simple configuration and integration with the asset
pipeline via the [jsbundling-rails](https://github.com/rails/jsbundling-rails) gem.

When using a bundling option, use `bin/dev` to start the Rails server and build JavaScript for
development.

### Installing Node.js and Yarn

If you are using a JavaScript bundler in your Rails application, Node.js and Yarn must be
installed.

Find the installation instructions at the [Node.js website](https://nodejs.org/en/download/) and
verify it’s installed correctly with the following command:

```bash
$ node --version
```

The version of your Node.js runtime should be printed out. Make sure it’s greater than `8.16.0`.

To install Yarn, follow the installation instructions at the
[Yarn website](https://classic.yarnpkg.com/en/docs/install). Running this command should print out
the Yarn version:

```bash
$ yarn --version
```

If it says something like `1.22.0`, Yarn has been installed correctly.

Choosing Between Import Maps and a JavaScript Bundler
-----------------------------------------------------

When you create a new Rails application, you will need to choose between import maps and a
JavaScript bundling solution. Every application has different requirements, and you should
consider your requirements carefully before choosing a JavaScript option, as migrating from one
option to another may be time-consuming for large, complex applications.

Import maps are the default option because the Rails team believes in import maps' potential for
reducing complexity, improving developer experience, and delivering performance gains.

For many applications, especially those that rely primarily on the [Hotwire](https://hotwired.dev/)
stack for their JavaScript needs, import maps will be the right option for the long term. You
can read more about the reasoning behind making import maps the default in Rails 7
[here](https://world.hey.com/dhh/rails-7-will-have-three-great-answers-to-javascript-in-2021-8d68191b).

Other applications may still need a traditional JavaScript bundler. Requirements that indicate
that you should choose a traditional bundler include:

* If your code requires a transpilation step, such as JSX or TypeScript.
* If you need to use JavaScript libraries that include CSS or otherwise rely on
[Webpack loaders](https://webpack.js.org/loaders/).
* If you are absolutely sure that you need
[tree-shaking](https://webpack.js.org/guides/tree-shaking/).
* If you will install Bootstrap, Bulma, PostCSS, or Dart CSS through the
[cssbundling-rails gem](https://github.com/rails/cssbundling-rails). All options provided by this
gem except Tailwind will automatically install `esbuild` for you if you do not specify a different
option in `rails new`.

Turbo
-----

Quer você escolha mapas de importação ou um _bundler_ tradicional, Rails vem com [Turbo](https://turbo.hotwired.dev/) para acelerar sua aplicação enquanto reduz dramaticamente a quantia de JavaScript que você precisará escrever.

O Turbo permite que seu servidor forneça HTML diretamente como uma alternativa aos _frameworks_ _front-end_ predominantes que reduzem o lado do servidor de seu aplicativo Rails a pouco mais que uma API JSON.

### Turbo Drive

[Turbo Drive](https://turbo.hotwired.dev/handbook/drive) acelera os carregamentos da página, evitando desmontagens e reconstruções em cada solicitação de navegação. Turbo Drive é uma melhoria e substituição para Turbolinks.

### Turbo Frames

[Turbo Frames](https://turbo.hotwired.dev/handbook/frames) permitem que partes predefinidas de uma página sejam atualizadas mediante solicitação, sem afetar o restante do conteúdo da página.

Você pode usar o Turbo Frames para criar edição no local sem qualquer JavaScript personalizado, conteúdo de carregamento lento (_lazy load_) e criar interfaces com guias e renderizadas pelo servidor com facilidade.

Rails disponibiliza _helpers_ HTML para simplificar o uso de Turbo Frames através da gem [turbo-rails](https://github.com/hotwired/turbo-rails).

Usando essa gem, você pode adicionar um Turbo Frame na sua aplicação com o _helper_ `turbo_frame_tag` assim:

```erb
<%= turbo_frame_tag dom_id(post) do %>
  <div>
     <%= link_to post.title, post_path(path) %>
  </div>
<% end %>
```

### Turbo Streams

[Turbo Streams](https://turbo.hotwired.dev/handbook/streams) entregam mudanças de página como fragmentos de HTML envoltos em elementos `<turbo-stream>` auto-executáveis. O Turbo Streams permite que você transmita alterações feitas por outros usuários por meio de WebSockets e atualize partes de uma página após o envio de um formulário sem exigir o carregamento completo da página.

Rails disponibiliza HTML e _helpers_ _server-side_ para simplificar o uso de Turbo Streams através da gem [turbo-rails](https://github.com/hotwired/turbo-rails).

Usando essa gem, você pode renderizar Turbo Streams de uma ação controladora:

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

Rails irá automaticamente procurar por um arquivo _view_ `.turbo_stream.erb` e renderizar essa _view_ quando encontrada.

Respostas Turbo Stream também podem ser renderizadas _inline_ na ação controladora:

```ruby
def create
  @post = Post.new(post_params)

  respond_to do |format|
    if @post.save
      format.turbo_stream { render turbo_stream: turbo_stream.prepend('posts', partial: 'post') }
    else
      format.html { render :new, status: :unprocessable_entity }
    end
  end
end
```

Finalmente, Turbo Streams podem ser inicializados com um modelo ou uma ação em segundo plano usando _built-in helpers_.

Essas transmissões podem ser usadas para atualizar o conteúdo por meio de uma conexão WebSocket para todos os usuários, mantendo o conteúdo da página atualizado e dando vida ao seu aplicativo.

Para transmitir um Turbo Stream de um modelo, combine um retorno de chamada de modelo como este:

```ruby
class Post < ApplicationRecord
  after_create_commit { broadcast_append_to('posts') }
end
```

Com uma conexão WebSocket configurada na página que deve receber as atualizações assim:

```erb
<%= turbo_stream_from "posts" %>
```

Substituições para a funcionalidade Rails/UJS
----------------------------------------

O Rails 6 vem com uma ferramenta chamada UJS que permite aos desenvolvedores substituir o método das _tags_ `<a>` para executar solicitações não-GET após um clique de _hiperlink_, assim como adicionar diálogos de confirmação antes de executar uma ação. Este era o padrão antes do Rails 7, mas agora é recomendado usar o Turbo.

### Método

Clicar em links sempre resulta em uma solicitação GET HTTP. Se a sua aplicação for [RESTful](https://pt.wikipedia.org/wiki/REST), alguns _links_ são de fato ações que alteram dados no servidor e devem ser executados com solicitações não-GET. Este atributo permite marcar tais _links_ com um método explícito como "_post_", "_put_" ou "_delete_".

Turbo irá procurar por _tags_ `<a>` na sua aplicação para os dados do atributos `turbo-method` e utilizando o método especificado quando presente, sobrescrevendo a ação GET padrão.

Por exemplo:

```erb
<%= link_to "Excluir post", post_path(post), data: { turbo_method: "delete" } %>
```

Isso gera:

```html
<a data-turbo-method="delete" href="...">Excluir post</a>
```

Uma alternativa para mudar o método de um _link_ com `data-turbo-method` é usar o auxiliar `button_to` do Rails. Por motivos de acessibilidade, botões e formulários reais são preferíveis para qualquer ação que não seja GET.

### Confirmações

Você pode solicitar confirmações adicionais do usuário ao adicionar o atributo `data-turbo-confirm` em _links_ e formulários. O usuário será apresentado com uma caixa de diálogo JavaScript `confirm()`, contendo o atributo de texto. Se o usuário escolhe cancelar, a ação não será executada.

Adicionar esse atributo em _links_ irá acionar o diálogo no clique, e adicionar em formulários irá acionar na submissão. Por exemplo:


```erb
<%= link_to "Excluir post", post_path(post), data: { turbo_method: "delete", turbo_confirm: "Você tem certeza?" } %>
```

Isso gera:

```html
<a href="..." data-confirm="Você tem certeza?" data-turbo-method="delete">Excluir post</a>
```
