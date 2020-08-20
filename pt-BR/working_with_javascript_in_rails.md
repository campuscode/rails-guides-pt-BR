**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Trabalhando com JavaScript no Rails
================================

Este guia aborda as funcionalidades internas Ajax/JavaScript do Rails (e
mais); Isso permitirá que você crie aplicações Ajax ricas e dinâmicas com
facilidade!

Após ler este guia, você saberá:

* O básico de *Ajax*. 
* JavaScript discreto (*unobtrusive*).
* Como os *helpers* internos do Rails ajudam você.
* Como lidar com Ajax no lado do servidor.
* A *gem* Turbolinks.
* Como incluir seu token de [Falsa Requisição Entre Sites (CSRF)](https://pt.wikipedia.org/wiki/Cross-site_request_forgery) nos cabeçalhos da requisição

-------------------------------------------------------------------------------

Uma introdução ao Ajax
------------------------

Para entender o Ajax, você precisa entender primeiro o que o navegador faz normalmente.

Quando você digita `http://localhost:3000` na barra de endereço do navegador
e clica no Enter, o navegador (seu 'cliente') faz uma requisição para o servidor.
Ele analisa a resposta, traz todos os *assets* associados, como arquivos JavaScript,
*stylesheets* e imagens. E então monta a página. Se você clica em um link, ele
repete o mesmo processo: encontra a página, encontra os *assets*, coloca eles juntos
e mostra o resultado. Isso é chamado de 'ciclo de requisição e resposta'.


JavaScript também pode fazer requisições para o servidor, e analisar a resposta.
Ele também tem a habilidade de atualizar informações na página. Combinando
esses dois poderes, o JavaScript permite que uma página web atualize partes
do seu próprio conteúdo, sem precisar pegar a página inteira do servidor.
Essa é uma técnica poderosa que nós chamamos de Ajax.

O Rails é distribuído por padrão com CoffeeScript, então o resto dos exemplos neste
guia serão em CoffeeScript. Todos essas lições, naturalmente, também funcionam para
o JavaScript puro (*vanilla*).

Como exemplo, aqui está um código CoffeeScript que faz uma requisição Ajax
usando a biblioteca jQuery:

```coffeescript
$.ajax(url: "/test").done (html) ->
  $("#results").append html
```

Este código pega os dados do "/test", e então anexa o resultado na `div` com
o id `results`.

O Rails fornece muito suporte interno para a criação de páginas web
com essa técnica. Você raramente terá de escrever esse código. O resto deste
guia irá lhe mostrar como o Rails pode te ajudar a escrever páginas web
desse modo, mas tudo isso é feito a partir dessa técnica muito simples.

JavaScript discreto (*unobtrusive*)
----------------------

O Rails usa uma técnica chamada "JavaScript discreto (*unobtrusive*)"
para lidar com a junção do JavaScript ao DOM. Essa costuma ser considerada
a melhor prática entre a comunidade *frontend*, mas você pode ocasionalmente
ler tutoriais que demonstram de outras formas.

Aqui está o modo mais simples de escrever JavaScript. Você pode ver ele sendo
referido como *'Inline JavaScript'*:

```html
<a href="#" onclick="this.style.backgroundColor='#990000'">Paint it red</a>
```

Ao clicar no link, ele ficará vermelho. Aqui está o problema: o que
acontece quando queremos que mais JavaScript seja executado no clique?

```html
<a href="#" onclick="this.style.backgroundColor='#009900';this.style.color='#FFFFFF';">Paint it green</a>
```

Estranho, certo? Poderíamos retirar a definição da função do manipulador de cliques,
e transformar em CoffeeScript:

```coffeescript
@paintIt = (element, backgroundColor, textColor) ->
  element.style.backgroundColor = backgroundColor
  if textColor?
    element.style.color = textColor
```

E então na nossa página:

```html
<a href="#" onclick="paintIt(this, '#990000')">Paint it red</a>
```

Esse é um pouco melhor, mas que tal múltiplos links com o mesmo efeito?

```html
<a href="#" onclick="paintIt(this, '#990000')">Paint it red</a>
<a href="#" onclick="paintIt(this, '#009900', '#FFFFFF')">Paint it green</a>
<a href="#" onclick="paintIt(this, '#000099', '#FFFFFF')">Paint it blue</a>
```
Não muito [DRY](https://pt.wikipedia.org/wiki/Don%27t_repeat_yourself), ahn?
Podemos corrigir usando eventos. Vamos adicionar o atributo `data-*` nos
nossos links, e então vincular o manipulador ao evento clique de cada link
que tenha esse atributo:

```coffeescript
@paintIt = (element, backgroundColor, textColor) ->
  element.style.backgroundColor = backgroundColor
  if textColor?
    element.style.color = textColor

$ ->
  $("a[data-background-color]").click (e) ->
    e.preventDefault()

    backgroundColor = $(this).data("background-color")
    textColor = $(this).data("text-color")
    paintIt(this, backgroundColor, textColor)
```
```html
<a href="#" data-background-color="#990000">Paint it red</a>
<a href="#" data-background-color="#009900" data-text-color="#FFFFFF">Paint it green</a>
<a href="#" data-background-color="#000099" data-text-color="#FFFFFF">Paint it blue</a>
```

Nós chamamos isso de JavaScript 'discreto (*unobtrusive*)' porque nós não estamos mais
misturando nosso JavaScript dentro do HTML. Estamos separando propriamente nossos interesses,
facilitando mudanças futuras. Podemos facilmente adicionar comportamentos em qualquer link
adicionando o atributo *data*. Podemos rodar todo nosso JavaScript através de um minimizador
e concatenador. Podemos entregar todo nosso pacote JavaScript em cada página, o que significa
que ele terá de ser baixado quando a primeira página carregar e então será salvo na memória
cache (*cached*) em todas as páginas depois disso. Muitos pequenos benefícios realmente se somam.

O time Rails fortemente lhe encoraja a escrever seu CoffeeScript (e JavaScript) nesse estilo,
e você pode esperar que muitas bibliotecas também seguirão esse padrão.

Built-in Helpers
----------------

### Remote elements

Rails provides a bunch of view helper methods written in Ruby to assist you
in generating HTML. Sometimes, you want to add a little Ajax to those elements,
and Rails has got your back in those cases.

Because of Unobtrusive JavaScript, the Rails "Ajax helpers" are actually in two
parts: the JavaScript half and the Ruby half.

Unless you have disabled the Asset Pipeline,
[rails-ujs](https://github.com/rails/rails/tree/master/actionview/app/assets/javascripts)
provides the JavaScript half, and the regular Ruby view helpers add appropriate
tags to your DOM.

You can read below about the different events that are fired dealing with
remote elements inside your application.

#### form_with

[`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)
is a helper that assists with writing forms. By default, `form_with` assumes that
your form will be using Ajax. You can opt out of this behavior by
passing the `:local` option `form_with`.

```erb
<%= form_with(model: @article) do |f| %>
  ...
<% end %>
```

This will generate the following HTML:

```html
<form action="/articles" accept-charset="UTF-8" method="post" data-remote="true">
  ...
</form>
```

Note the `data-remote="true"`. Now, the form will be submitted by Ajax rather
than by the browser's normal submit mechanism.

You probably don't want to just sit there with a filled out `<form>`, though.
You probably want to do something upon a successful submission. To do that,
bind to the `ajax:success` event. On failure, use `ajax:error`. Check it out:

```coffeescript
$(document).ready ->
  $("#new_article").on("ajax:success", (event) ->
    [data, status, xhr] = event.detail
    $("#new_article").append xhr.responseText
  ).on "ajax:error", (event) ->
    $("#new_article").append "<p>ERROR</p>"
```

Obviously, you'll want to be a bit more sophisticated than that, but it's a
start.

NOTE: As of Rails 5.1 and the new `rails-ujs`, the parameters `data, status, xhr`
have been bundled into `event.detail`. For information about the previously used
`jquery-ujs` in Rails 5 and earlier, read the [`jquery-ujs` wiki](https://github.com/rails/jquery-ujs/wiki/ajax).

#### link_to

[`link_to`](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)
is a helper that assists with generating links. It has a `:remote` option you
can use like this:

```erb
<%= link_to "an article", @article, remote: true %>
```

which generates

```html
<a href="/articles/1" data-remote="true">an article</a>
```

You can bind to the same Ajax events as `form_with`. Here's an example. Let's
assume that we have a list of articles that can be deleted with just one
click. We would generate some HTML like this:

```erb
<%= link_to "Delete article", @article, remote: true, method: :delete %>
```

and write some CoffeeScript like this:

```coffeescript
$ ->
  $("a[data-remote]").on "ajax:success", (event) ->
    alert "The article was deleted."
```

#### button_to

[`button_to`](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to) is a helper that helps you create buttons. It has a `:remote` option that you can call like this:

```erb
<%= button_to "An article", @article, remote: true %>
```

this generates

```html
<form action="/articles/1" class="button_to" data-remote="true" method="post">
  <input type="submit" value="An article" />
</form>
```

Since it's just a `<form>`, all of the information on `form_with` also applies.

### Customize remote elements

It is possible to customize the behavior of elements with a `data-remote`
attribute without writing a line of JavaScript. You can specify extra `data-`
attributes to accomplish this.

#### `data-method`

Activating hyperlinks always results in an HTTP GET request. However, if your
application is [RESTful](https://en.wikipedia.org/wiki/Representational_State_Transfer),
some links are in fact actions that change data on the server, and must be
performed with non-GET requests. This attribute allows marking up such links
with an explicit method such as "post", "put" or "delete".

The way it works is that, when the link is activated, it constructs a hidden form
in the document with the "action" attribute corresponding to "href" value of the
link, and the method corresponding to `data-method` value, and submits that form.

NOTE: Because submitting forms with HTTP methods other than GET and POST isn't
widely supported across browsers, all other HTTP methods are actually sent over
POST with the intended method indicated in the `_method` parameter. Rails
automatically detects and compensates for this.

#### `data-url` and `data-params`

Certain elements of your page aren't actually referring to any URL, but you may want
them to trigger Ajax calls. Specifying the `data-url` attribute along with
the `data-remote` one will trigger an Ajax call to the given URL. You can also
specify extra parameters through the `data-params` attribute.

This can be useful to trigger an action on check-boxes for instance:

```html
<input type="checkbox" data-remote="true"
    data-url="/update" data-params="id=10" data-method="put">
```

#### `data-type`

It is also possible to define the Ajax `dataType` explicitly while performing
requests for `data-remote` elements, by way of the `data-type` attribute.

### Confirmations

You can ask for an extra confirmation of the user by adding a `data-confirm`
attribute on links and forms. The user will be presented a JavaScript `confirm()`
dialog containing the attribute's text. If the user chooses to cancel, the action
doesn't take place.

Adding this attribute on links will trigger the dialog on click, and adding it
on forms will trigger it on submit. For example:

```erb
<%= link_to "Dangerous zone", dangerous_zone_path,
  data: { confirm: 'Are you sure?' } %>
```

This generates:

```html
<a href="..." data-confirm="Are you sure?">Dangerous zone</a>
```

The attribute is also allowed on form submit buttons. This allows you to customize
the warning message depending on the button which was activated. In this case,
you should **not** have `data-confirm` on the form itself.

The default confirmation uses a JavaScript confirm dialog, but you can customize
this by listening to the `confirm` event, which is fired just before the confirmation
window appears to the user. To cancel this default confirmation, have the confirm
handler to return `false`.

### Automatic disabling

It is also possible to automatically disable an input while the form is submitting
by using the `data-disable-with` attribute. This is to prevent accidental
double-clicks from the user, which could result in duplicate HTTP requests that
the backend may not detect as such. The value of the attribute is the text that will
become the new value of the button in its disabled state.

This also works for links with `data-method` attribute.

For example:

```erb
<%= form_with(model: @article.new) do |f| %>
  <%= f.submit data: { "disable-with": "Saving..." } %>
<%= end %>
```

This generates a form with:

```html
<input data-disable-with="Saving..." type="submit">
```

### Rails-ujs event handlers

Rails 5.1 introduced rails-ujs and dropped jQuery as a dependency.
As a result the Unobtrusive JavaScript (UJS) driver has been rewritten to operate without jQuery.
These introductions cause small changes to `custom events` fired during the request:

NOTE: Signature of calls to UJS's event handlers has changed.
Unlike the version with jQuery, all custom events return only one parameter: `event`.
In this parameter, there is an additional attribute `detail` which contains an array of extra parameters.

| Event name          | Extra parameters (event.detail) | Fired                                                       |
|---------------------|---------------------------------|-------------------------------------------------------------|
| `ajax:before`       |                                 | Before the whole ajax business.                             |
| `ajax:beforeSend`   | [xhr, options]                  | Before the request is sent.                                 |
| `ajax:send`         | [xhr]                           | When the request is sent.                                   |
| `ajax:stopped`      |                                 | When the request is stopped.                                |
| `ajax:success`      | [response, status, xhr]         | After completion, if the response was a success.            |
| `ajax:error`        | [response, status, xhr]         | After completion, if the response was an error.             |
| `ajax:complete`     | [xhr, status]                   | After the request has been completed, no matter the outcome.|

Example usage:

```html
document.body.addEventListener('ajax:success', function(event) {
  var detail = event.detail;
  var data = detail[0], status = detail[1], xhr = detail[2];
})
```

NOTE: As of Rails 5.1 and the new `rails-ujs`, the parameters `data, status, xhr`
have been bundled into `event.detail`. For information about the previously used
`jquery-ujs` in Rails 5 and earlier, read the [`jquery-ujs` wiki](https://github.com/rails/jquery-ujs/wiki/ajax).

### Stoppable events
You can stop execution of the Ajax request by running `event.preventDefault()`
from the handlers methods `ajax:before` or `ajax:beforeSend`.
The `ajax:before` event can manipulate form data before serialization and the
`ajax:beforeSend` event is useful for adding custom request headers.

If you stop the `ajax:aborted:file` event, the default behavior of allowing the
browser to submit the form via normal means (i.e. non-Ajax submission) will be
canceled and the form will not be submitted at all. This is useful for
implementing your own Ajax file upload workaround.

Note, you should use `return false` to prevent event for `jquery-ujs` and
`e.preventDefault()` for `rails-ujs`

Server-Side Concerns
--------------------

Ajax isn't just client-side, you also need to do some work on the server
side to support it. Often, people like their Ajax requests to return JSON
rather than HTML. Let's discuss what it takes to make that happen.

### A Simple Example

Imagine you have a series of users that you would like to display and provide a
form on that same page to create a new user. The index action of your
controller looks like this:

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    @user = User.new
  end
  # ...
```

The index view (`app/views/users/index.html.erb`) contains:

```erb
<b>Users</b>

<ul id="users">
<%= render @users %>
</ul>

<br>

<%= form_with(model: @user) do |f| %>
  <%= f.label :name %><br>
  <%= f.text_field :name %>
  <%= f.submit %>
<% end %>
```

The `app/views/users/_user.html.erb` partial contains the following:

```erb
<li><%= user.name %></li>
```

The top portion of the index page displays the users. The bottom portion
provides a form to create a new user.

The bottom form will call the `create` action on the `UsersController`. Because
the form's remote option is set to true, the request will be posted to the
`UsersController` as an Ajax request, looking for JavaScript. In order to
serve that request, the `create` action of your controller would look like
this:

```ruby
  # app/controllers/users_controller.rb
  # ......
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.js
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
```

Notice the `format.js` in the `respond_to` block: that allows the controller to
respond to your Ajax request. You then have a corresponding
`app/views/users/create.js.erb` view file that generates the actual JavaScript
code that will be sent and executed on the client side.

```erb
$("<%= escape_javascript(render @user) %>").appendTo("#users");
```

Turbolinks
----------

Rails ships with the [Turbolinks library](https://github.com/turbolinks/turbolinks),
which uses Ajax to speed up page rendering in most applications.

### How Turbolinks Works

Turbolinks attaches a click handler to all `<a>` tags on the page. If your browser
supports
[PushState](https://developer.mozilla.org/en-US/docs/Web/Guide/API/DOM/Manipulating_the_browser_history#The_pushState%28%29_method),
Turbolinks will make an Ajax request for the page, parse the response, and
replace the entire `<body>` of the page with the `<body>` of the response. It
will then use PushState to change the URL to the correct one, preserving
refresh semantics and giving you pretty URLs.

If you want to disable Turbolinks for certain links, add a `data-turbolinks="false"`
attribute to the tag:

```html
<a href="..." data-turbolinks="false">No turbolinks here</a>.
```

### Page Change Events

When writing CoffeeScript, you'll often want to do some sort of processing upon
page load. With jQuery, you'd write something like this:

```coffeescript
$(document).ready ->
  alert "page has loaded!"
```

However, because Turbolinks overrides the normal page loading process, the
event that this relies upon will not be fired. If you have code that looks like
this, you must change your code to do this instead:

```coffeescript
$(document).on "turbolinks:load", ->
  alert "page has loaded!"
```

For more details, including other events you can bind to, check out [the
Turbolinks
README](https://github.com/turbolinks/turbolinks/blob/master/README.md).

Cross-Site Request Forgery (CSRF) token in Ajax
----

When using another library to make Ajax calls, it is necessary to add
the security token as a default header for Ajax calls in your library. To get
the token:

```javascript
var token = document.getElementsByName('csrf-token')[0].content
```

You can then submit this token as a X-CSRF-Token in your header for your
Ajax requst.  You do not need to add a CSRF for GET requests, only non-GET
requests.

You can read more about about Cross-Site Request Forgery in [Security](https://guides.rubyonrails.org/security.html#cross-site-request-forgery-csrf)

Other Resources
---------------

Here are some helpful links to help you learn even more:

* [jquery-ujs wiki](https://github.com/rails/jquery-ujs/wiki)
* [jquery-ujs list of external articles](https://github.com/rails/jquery-ujs/wiki/External-articles)
* [Rails 3 Remote Links and Forms: A Definitive Guide](http://www.alfajango.com/blog/rails-3-remote-links-and-forms/)
* [Railscasts: Unobtrusive JavaScript](http://railscasts.com/episodes/205-unobtrusive-javascript)
* [Railscasts: Turbolinks](http://railscasts.com/episodes/390-turbolinks)
