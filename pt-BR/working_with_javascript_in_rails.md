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

Adicionando pacotes NPM com Bundlers JavaScript
--------

Importar por mapas é o padrão para novas aplicações Rails, mas se você preferir o pacote JavaScript tradicional, você pode criar novas aplicações Rails com as opções de [esbuild](https://esbuild.github.io/), [webpack](https://webpack.js.org/), ou
[rollup.js](https://rollupjs.org/guide/en/).

Para usar um _bundler_ ao invés de mapas de importação em uma nova aplicação Rails, passe a opção `—javascript` ou a opção `-j` para `rails new`:

```bash
$ rails new meu_novo_app --javascript=webpack
OU
$ rails new meu_novo_app -j webpack
```

Cada uma dessas opções de pacotes vem com uma configuração simples e integração com o _pipeline_ por meio da gem [jsbundling-rails](https://github.com/rails/jsbundling-rails).

Quando optar pelo caminho via _bundle_, use `bin/dev` para iniciar o servidor Rails e construir o JavaScript para desenvolvimento.

### Instalando Node.js e Yarn

Se você está usando um _bundler_ JavaScript na sua aplicação Rails, Node.js e Yarn precisam ser instalados.

Encontre as instruções de instalação no [site Node.js](https://nodejs.org/pt-br/download/) e verifique se está instalado corretamente com o seguinte comando:

```bash
$ node --version
```

A versão de _runtime_ de seu Node.js deve ser exibida. Tenha certeza de que é maior que `8.16.0`.

Para instalar o Yarn, siga as instruções de instalação no
[site do Yarn](https://classic.yarnpkg.com/en/docs/install). Executar este comando deverá exibir a versão do Yarn:

```bash
$ yarn --version
```

Se apresentar algo como `1.22.0`, o Yarn foi instalado corretamente.

Escolhendo entre Importar com Mapas e um JavaScript Bundler
-----------------------------------------------------

Quando você cria uma nova aplicação Rails, você precisará escolher entre importar com mapas ou a solução via JavaScript _bundling_. Cada aplicação possui diferentes requisitos, e você deverá considerar suas necessidades cuidadosamente antes de escolher a opção JavaScript, já que migrar de uma para outra pode ser demorada para aplicações grandes e complexas.

Mapas de importação são a opção padrão porque o time Rails acredita no potencial desses mapas para reduzir complexidade, melhorando a experiência do desenvolvedor e entregando ganhos de performance.

Para muitas aplicações, especialmente aquelas que dependem principalmente na _stack_ [Hotwire](https://hotwired.dev/) para suas necessidades JavaScript, mapas de importação são a opção certa a longo prazo. Você pode ler mais sobre as razões dos mapas de importação serem o padrão no Rails 7 [aqui](https://world.hey.com/dhh/rails-7-will-have-three-great-answers-to-javascript-in-2021-8d68191b).

Outras aplicações ainda podem precisar do tradicional _bundler_ JavaScript. Requisitos que indicam que você deveria escolher o _bundler_ tradicional incluem:

* Se seu código necessita de um passo de transpilação, como JSX ou TypeScript.
* Se você precisa usar bibliotecas JavaScript que incluem CSS ou
libraries that include CSS então dependem de [carregadores Webpack](https://webpack.js.org/loaders/).
* Se você tem certeza absoluta que você precisa de _[tree-shaking](https://webpack.js.org/guides/tree-shaking/)_.
* Se você vai instalar Bootstrap, Bulma, PostCSS, ou Dart CSS através da
[gem cssbundling-rails](https://github.com/rails/cssbundling-rails). Todas as opções disponibilizadas por essa gem, exceto Tailwind, vão automaticamente instalar `esbuild` para você se você não especificar uma opção diferente no `rails new`.

Turbo
-----

Whether you choose import maps or a traditional bundler, Rails ships with
[Turbo](https://turbo.hotwired.dev/) to speed up your application while dramatically reducing the
amount of JavaScript that you will need to write.

Turbo lets your server deliver HTML directly as an alternative to the prevailing front-end
frameworks that reduce the server-side of your Rails application to little more than a JSON API.

### Turbo Drive

[Turbo Drive](https://turbo.hotwired.dev/handbook/drive) speeds up page loads by avoiding full-page
teardowns and rebuilds on every navigation request. Turbo Drive is an improvement on and
replacement for Turbolinks.

### Turbo Frames

[Turbo Frames](https://turbo.hotwired.dev/handbook/frames) allow predefined parts of a page to be
updated on request, without impacting the rest of the page’s content.

You can use Turbo Frames to build in-place editing without any custom JavaScript, lazy load
content, and create server-rendered, tabbed interfaces with ease.

Rails provides HTML helpers to simplify the use of Turbo Frames through the
[turbo-rails](https://github.com/hotwired/turbo-rails) gem.

Using this gem, you can add a Turbo Frame to your application with the `turbo_frame_tag` helper
like this:

```erb
<%= turbo_frame_tag dom_id(post) do %>
  <div>
     <%= link_to post.title, post_path(path) %>
  </div>
<% end %>
```

### Turbo Streams

[Turbo Streams](https://turbo.hotwired.dev/handbook/streams) deliver page changes as fragments of
HTML wrapped in self-executing `<turbo-stream>` elements. Turbo Streams allow you to broadcast
changes made by other users over WebSockets and update pieces of a page after a form submission
without requiring a full page load.

Rails provides HTML and server-side helpers to simplify the use of Turbo Streams through the
[turbo-rails](https://github.com/hotwired/turbo-rails) gem.

Using this gem, you can render Turbo Streams from a controller action:

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

Rails will automatically look for a `.turbo_stream.erb` view file and render that view when found.

Turbo Stream responses can also be rendered inline in the controller action:

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

Finally, Turbo Streams can be initiated from a model or a background job using built-in helpers.
These broadcasts can be used to update content via a WebSocket connection to all users, keeping
page content fresh and bringing your application to life.

To broadcast a Turbo Stream from a model combine a model callback like this:

```ruby
class Post < ApplicationRecord
  after_create_commit { broadcast_append_to('posts') }
end
```

With a WebSocket connection set up on the page that should receive the updates like this:

```erb
<%= turbo_stream_from "posts" %>
```

Replacements for Rails/UJS Functionality
----------------------------------------

Rails 6 shipped with a tool called UJS that allows developers to override the method of `<a>` tags
to perform non-GET requests after a hyperlink click and to add confirmation dialogs before
executing an action. This was the default before Rails 7, but it is now recommended to use Turbo
instead.

### Method

Clicking links always results in an HTTP GET request. If your application is
[RESTful](https://en.wikipedia.org/wiki/Representational_State_Transfer), some links are in fact
actions that change data on the server, and should be performed with non-GET requests. This
attribute allows marking up such links with an explicit method such as "post", "put", or "delete".

Turbo will scan `<a>` tags in your application for the `turbo-method` data attribute and use the
specified method when present, overriding the default GET action.

For example:

```erb
<%= link_to "Delete post", post_path(post), data: { turbo_method: "delete" } %>
```

This generates:

```html
<a data-turbo-method="delete" href="...">Delete post</a>
```

An alternative to changing the method of a link with `data-turbo-method` is to use Rails
`button_to` helper. For accessibility reasons, actual buttons and forms are preferable for any
non-GET action.

### Confirmations

You can ask for an extra confirmation of the user by adding a `data-turbo-confirm` attribute on
links and forms. The user will be presented with a JavaScript `confirm()` dialog containing the
attribute’s text. If the user chooses to cancel, the action doesn't take place.

Adding this attribute on links will trigger the dialog on click, and adding it on forms will
trigger it on submit. For example:

```erb
<%= link_to "Delete post", post_path(post), data: { turbo_method: "delete", turbo_confirm: "Are you sure?" } %>
```

This generates:

```html
<a href="..." data-confirm="Are you sure?" data-turbo-method="delete">Delete post</a>
```
