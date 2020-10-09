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

*Helpers* Internos
----------------

### Elementos Remotos

O Rails fornece um grupo de métodos *view helper* escritos em ruby para ajudar você
na criação do HTML. As vezes, você quer adicionar um pouco de *Ajax* para esses elementos,
e o Rails te da cobertura nesses casos.

Por causa do JavaScript não obtrusivo (*unobtrusive*), os *"Ajax Helpers"* do rails
estão atualmente em duas partes: metade JavaScript e metade Rails.

A não ser que você desabilite a *Asset Pipeline*,
[o *rails-ujs*](https://github.com/rails/rails/tree/master/actionview/app/assets/javascripts)
fornece a metade JavaScript, e os *view helpers* regulares em Ruby adicionam as *tags* apropriadas
ao seu DOM.

Você pode ler abaixo sobre a diferença dos eventos que são disparados lidando com
elementos remotos dentro da sua aplicação.

#### form_with

[o `form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)
é um *helper* que auxilia na escrita de formulários. Por padrão, o `form_with` assume
que seu formulário estará usando Ajax. Você pode desativar esse comportamento passando
a opção *`:local`* no *`form_with`*

```erb
<%= form_with(model: @article) do |f| %>
  ...
<% end %>
```

Isso irá gerar o seguinte HTML:

```html
<form action="/articles" accept-charset="UTF-8" method="post" data-remote="true">
  ...
</form>
```

Veja o `data-remote="true"`. Agora, o formulário será enviado por *Ajax* ao invés
do mecanismo normal de envio do browser.

Você provavelmente não quer só ficar sentado com um `<form>` preenchido, entretanto.
Você provavelmente quer que algo aconteça após um envio bem-sucedido. Para fazer isso,
vincule o evento `ajax:success`. Em caso de falha, use `ajax:error`. confira:

```coffeescript
$(document).ready ->
  $("#new_article").on("ajax:success", (event) ->
    [data, status, xhr] = event.detail
    $("#new_article").append xhr.responseText
  ).on "ajax:error", (event) ->
    $("#new_article").append "<p>ERROR</p>"
```

Obviamente, você irá querer ser um pouco mais sofisticado que isso, mas
é um começo.

NOTE: A partir do Rails 5.1 e do novo `rails-ujs`, os parâmetros
`data, status, xhr` foram empacotados no `event.detail`. Para informações
sobre o `jquery-ujs` usado anteriormente no Rails 5 e anteriores, leia a [wiki do `jquery-ujs`](https://github.com/rails/jquery-ujs/wiki/ajax)

#### link_to

[`link_to`](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)
é um *helper* que ajuda na geração de links. Ele tem a opção `:remote`
que você pode usar assim:

```erb
<%= link_to "an article", @article, remote: true %>
```

que gera

```html
<a href="/articles/1" data-remote="true">an article</a>
```

Você pode vincular os mesmos eventos *Ajax* do `form_with`. Aqui está um exemplo.
Vamos assumir que nós temos uma lista de artigos que podem ser deletadas com apenas
um clique. Iríamos gerar um HTML como este:

```erb
<%= link_to "Delete article", @article, remote: true, method: :delete %>
```

e escrever um pouco de CoffeeScript como este:

```coffeescript
$ ->
  $("a[data-remote]").on "ajax:success", (event) ->
    alert "The article was deleted."
```

#### button_to

[`button_to`](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to) é um *helper* que ajuda você a criar botões. Ele tem a opção `:remote` que você pode chamar assim:


```erb
<%= button_to "An article", @article, remote: true %>
```

Isso gera

```html
<form action="/articles/1" class="button_to" data-remote="true" method="post">
  <input type="submit" value="An article" />
</form>
```

Uma vez que é apenas um `<form>`, todas as informações do `form_with` também se aplicam.

### Personalize elementos remotos

É possível personalizar o comportamento dos elementos com o atributo `data-remote`
sem escrever uma linha de JavaScript. Você pode especificar extras atributos `data-`
para fazer isso.

#### `data-method`

Ativando *hyperlinks* sempre resultam em uma requisição HTTP GET. Seja como for, se
sua aplicação é [RESTful](https://pt.wikipedia.org/wiki/REST),
alguns links são na verdade ações que mudam dados no servidor, e devem ser executados com
requisições diferentes de GET. Esse atributo permite mudar tais links para um método explícito
tais como "post", "put" ou "delete".

O modo como isso funciona é que, quando um link é ativado, ele constrói um formulário
escondido no documento com o atributo *"action"* correspondendo ao valor *"href"* do
link, e o método corresponde ao valor do `data-method`, e envia esse formulário.

NOTE: por causa dos envios de formulários com outros métodos HTTP além de
GET e POST não são amplamente suportados entre navegadores, todos os outros métodos
HTTP são na verdade enviados através de POST com o método pretendido indicado no
parâmetro `_method`. o Rails automaticamente detecta e compensa isso.

#### `data-url` e `data-params`

Certos elementos da sua página não estão atualmente referenciando a alguma URL, mas você pode querer
que eles acionem chamadas Ajax. Especificando o atributo `data-url` juntamente com o `data-remote`
um irá disparar uma chamada Ajax para a URL dada. Você pode também
especificar parâmetros extras através do atributo `data-params`.

Isso pode ser útil para disparar uma ação nos *check-boxes* por exemplo:

```html
<input type="checkbox" data-remote="true"
    data-url="/update" data-params="id=10" data-method="put">
```

#### `data-type`

Também é possível definir o Ajax `dataType` explicitamente enquanto desempenha
requisições para os elementos `data-remote`, por meio do atributo `data-type`

### Confirmations

Você pode pedir uma confirmação extra do usuário adicionando o atributo
`data-confirm` nos links e formulários. O usuário verá uma caixa de diálogo
`confirm()` em JavaScript contendo o texto do atributo. Se o usuário escolher
cancelar, a ação não acontece.

Adicionando esse atributo nos links, será disparado a mensagem no clique, e adicionando
aos formulários, será disparado no *submit*. Por exemplo:

```erb
<%= link_to "Dangerous zone", dangerous_zone_path,
  data: { confirm: 'Are you sure?' } %>
```

Isso gera:

```html
<a href="..." data-confirm="Are you sure?">Dangerous zone</a>
```

O atributo também está disponível no botão *submit* do formulário. Isso permite
você customizar a mensagem de aviso dependendo do botão que foi ativado. Nesse caso,
você **não** deve ter um `data-confirm` no formulário em si.

A confirmação padrão usa a mensagem de confirmação JavaScript, mas você pode mudar
isso pegando o evento `confirm`, o qual é disparado antes da janela de confirmação
aparecer para o usuário. Para cancelar essa confirmação padrão, você tem que fazer o
gerenciador de confirmação retornar *false*.

### Desativando Automaticamente

Também é possível desabilitar automaticamente um input enquanto o formulário está sendo
enviado usando o atributo `data-disable-with`. Isso evita acidentes de duplo cliques do
usuário, o qual resultaria em uma dupla requisição HTTP que o `backend` pode não detectar
como tal. O valor do atributo é o texto que se tornará o novo valor do botão quando está
no estado desabilitado.

Isso também funciona para links com o atributo `data-method`.

Por exemplo:

```erb
<%= form_with(model: @article.new) do |f| %>
  <%= f.submit data: { "disable-with": "Saving..." } %>
<%= end %>
```

Isso gera um formulário com:

```html
<input data-disable-with="Saving..." type="submit">
```

### Manipuladores de eventos `Rails-ujs`

Rails 5.1 introduziu o `rails-ujs` e removeram o jQuery como dependência.
Como resultado o JavaScript discreto (*unobtrusive (UJS)*) foi reescrito para operar sem *jQuery*.
Estas introduções causam pequenas mudanças para os eventos personalizados executados durante a requisição:

NOTE: A assinatura de chamadas para os manipuladores de eventos do `UJS` mudaram.
Diferente da versão com jQuery, todos os eventos personalizados retornam apenas um parâmetro: `event`.
Nesse parâmetro, existe um atributo adicional, o `detail`, ao qual contém um *array* de parâmetros extra.

| Nome do evento      | Parâmetros extra (event.detail) | Quando é executado                                          |
|---------------------|---------------------------------|-------------------------------------------------------------|
| `ajax:before`       |                                 | Antes de toda regra de negócio no *ajax*.                   |
| `ajax:beforeSend`   | [xhr, options]                  | Antes da requisição ser enviada.                            |
| `ajax:send`         | [xhr]                           | Quando a requisição é enviada.                              |
| `ajax:stopped`      |                                 | Quando a requisição é parada.                               |
| `ajax:success`      | [response, status, xhr]         | Após a conclusão, se a resposta foi bem sucedida.           |
| `ajax:error`        | [response, status, xhr]         | Após a conclusão, se a resposta foi um erro.                |
| `ajax:complete`     | [xhr, status]                   | Após a requisição ser concluída, não importa o resultado.   |

Exemplo de uso:

```html
document.body.addEventListener('ajax:success', function(event) {
  var detail = event.detail;
  var data = detail[0], status = detail[1], xhr = detail[2];
})
```
NOTE: A partir do Rails 5.1 e o novo `rails-ujs`, os parâmetros `data, status, xhr`
foram empacotados dentro do `event.detail`. Para informações sobre o `jquery-ujs` anteriormente
usado no Rails 5 e anteriores, leia a [wiki do `jquery-ujs`](https://github.com/rails/jquery-ujs/wiki/ajax).

### Eventos Paravéis

Você pode parar a execução da requisição *Ajax* executando o `event.preventDefault()`
a partir dos métodos `ajax:before` ou `ajax:beforeSend`.
O evento `ajax:before` pode manipular os dados do formulário antes da serialização e o
evento `ajax:beforeSend` é útil para adicionar *headers* personalizados.

Se você parar o evento `ajax:aborted:file`, o comportamento padrão de permitir
que o navegador envie o formulário por meios normais (i.e. requisição sem *Ajax*)
será cancelada e o formulário não será enviado de nenhuma forma. Isso é útil para
implementar seu próprio ambiente de *upload* de arquivos via *Ajax*.

Observação, você deveria usar o `return false` para prevenir eventos para o `jquery-ujs`
e `e.preventDefault()` para o `rails-ujs`

Preocupações Do Lado Do Servidor
--------------------

Ajax não é só do lado do cliente, você também precisa trabalhar
no lado do servidor para oferecer suporte, geralmente, as pessoas gostam
que suas requisições retornem JSON mais do que HTML. Vamos discutir o que
é preciso fazer para isso acontecer.

### Um Exemplo Simples

Imagine que você tenha uma série de usuários que você gostaria de mostrar e
fornecer um formulário nessa mesma página para criar um novo usuário. A ação *index*
do seu *controller* se parece com isso:

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    @user = User.new
  end
  # ...
```

A *view index* (`app/views/users/index.html.erb`) contém:

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

A *partial* `app/views/users/_user.html.erb` contém o seguinte:

```erb
<li><%= user.name %></li>
```

A parte de cima da página *index* mostra os usuários. A parte de baixo
fornece o formulário para criar um novo usuário.

O formulário de baixo chamará a ação *`create`* no `UsersController`. Por causa
da opção *remote* definida como `true`, a requisição será enviada para o `UsersController`
como uma requisição *Ajax*, procurando por JavaScript. Afim de atender a requisição,
a ação *`create`* do seu *controller* ficaria assim:

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

Observe o `format.js` no bloco `respond_to`: que permite o seu controller responder
a sua requisição *Ajax*. Então você tem um correspondente arquivo *view*
`app/views/users/create.js.erb` que gera o atual código JavaScript que será enviado
e executado no lado do cliente.

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

token de Falsa Requisição Entre Sites (CSRF) no *Ajax*
----

Ao usar outra biblioteca para fazer chamadas *Ajax*, é necessário adicionar
o token de segurança como um *header* padrão para chamadas *Ajax* na sua biblioteca.
Para pegar o token:

```javascript
var token = document.getElementsByName('csrf-token')[0].content
```

Você pode então enviar esse token como um *X-CSRF-Token* no seu *header*
para requisições *Ajax*. Você não precisa adicionar o CSRF para requisições GET,
apenas para requisições *non-GET*.

Você pode ler mais sobre Falsa Requisição Entre Sites (CSRF) na [segurança](https://www.guiarails.com.br/working_with_javascript_in_rails.html#cross-site-request-forgery-csrf-token-in-ajax)

Outros recursos
---------------

Aqui estão alguns links úteis para te ajudar a aprender mais:

* [jquery-ujs wiki](https://github.com/rails/jquery-ujs/wiki)
* [jquery-ujs list of external articles](https://github.com/rails/jquery-ujs/wiki/External-articles)
* [Rails 3 Remote Links and Forms: A Definitive Guide](http://www.alfajango.com/blog/rails-3-remote-links-and-forms/)
* [Railscasts: Unobtrusive JavaScript](http://railscasts.com/episodes/205-unobtrusive-javascript)
* [Railscasts: Turbolinks](http://railscasts.com/episodes/390-turbolinks)
