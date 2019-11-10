**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Layouts e Renderização no Rails
==============================

Este guia aborda os recursos básicos de layout do _Action Controller_ e da _Action View_.

Depois de ler este guia, você saberá:

* Como usar os vários métodos de renderização embutidos no Rails.
* Como criar layouts com várias seções de conteúdo.
* Como usar _partials_ para enxugar suas _views_.
* Como usar _nested layouts_ (sub-templates).

---------------------------------------------------------------------------------

Visão Geral: Como as peças se encaixam
-------------------------------------

Este guia concentra-se na interação entre o _Controller_ e _View_ no triângulo _Model-View-Controller_. Como você sabe, o _Controller_ é responsável por orquestrar todo o processo de como lidar com uma requisição no Rails, embora normalmente entregue qualquer código pesado ao _Model_. Porém, na hora de enviar uma resposta de volta ao usuário, o _Controller_ transfere as informações para a _View_. É essa transferência que é o assunto deste guia.

Em linhas gerais, isso envolve decidir o que deve ser enviado como resposta e chamar um método apropriado para criar essa resposta. Se a resposta for uma _view_ completa, o Rails também fará um trabalho extra para encapsular a _view_ em um layout e, possivelmente, obter as _partials_. Você verá todos esses caminhos posteriormente neste guia.

Criando respostas
------------------

Do ponto de vista do _controller_, há três maneiras de criar uma resposta HTTP:

* Chamar `render` para criar uma resposta completa e enviar de volta ao navegador
* Chamar `redirect_to` para enviar um _status code_ HTTP de redirecionamento para o navegador
* Chamar `head` para criar uma resposta que consiste apenas em cabeçalhos HTTP para enviar de volta ao navegador

### Renderização por padrão: Convenção sobre configuração em ação

Você já ouviu falar que o Rails promove "convenção sobre configuração". A renderização padrão é um excelente exemplo disso. Por padrão, os _controllers_ no Rails renderizam automaticamente _views_ com nomes que correspondem a rotas válidas. Por exemplo, se você tiver esse código na classe `BooksController`:

```ruby
class BooksController < ApplicationController
end
```

E o seguinte no seu arquivo de rotas:

```ruby
resources :books
```

E você tem um arquivo de exibição `app/views/books/index.html.erb`:

```html+erb
<h1>Os livros chegarão em breve!</h1>
```

O Rails renderizará automaticamente `app/views/books/index.html.erb` quando você navegar para `/books` e verá "Os livros chegarão em breve!" na sua tela.

No entanto, uma tela em breve é apenas minimamente útil; portanto, em breve você criará o seu modelo `Book` e adicionará a _action_ _index_ ao `BooksController`:

```ruby
class BooksController < ApplicationController
  def index
    @books = Book.all
  end
end
```

Observe que não temos _render_ explícito no final da _action_ _index_, de acordo com o princípio "convenção sobre configuração". A regra é que, se você não renderizar explicitamente algo no final de uma _action_ do _controller_, o Rails procurará automaticamente o _template_ `action_name.html.erb` no caminho da _view_ do _controller_ e o renderizará. Portanto, neste caso, o Rails renderizará o arquivo `app/views/books/index.html.erb`.

Se queremos exibir as propriedades de todos os livros em nossa _view_, podemos fazer isso com um template ERB como este:

```html+erb
<h1>Listing Books</h1>

<table>
  <thead>
    <tr>
      <th>Title</th>
      <th>Content</th>
      <th colspan="3"></th>
    </tr>
  </thead>

  <tbody>
    <% @books.each do |book| %>
      <tr>
        <td><%= book.title %></td>
        <td><%= book.content %></td>
        <td><%= link_to "Show", book %></td>
        <td><%= link_to "Edit", edit_book_path(book) %></td>
        <td><%= link_to "Destroy", book, method: :delete, data: { confirm: "Are you sure?" } %></td>
      </tr>
    <% end %>
  </tbody>
</table>

<br>

<%= link_to "New book", new_book_path %>
```

NOTE: A renderização real é feita por classes aninhadas do módulo [`ActionView::Template::Handlers`](https://api.rubyonrails.org/classes/ActionView/Template/Handlers.html). Este guia não analisa esse processo, mas é importante saber que a extensão do arquivo na sua _view_ controla a escolha do manipulador de templates.

### Usando `render`

Na maioria dos casos, o método `ActionController::Base#render` faz o trabalho pesado de renderizar o conteúdo do aplicativo para ser utilizado por um navegador. Existem várias maneiras de personalizar o comportamento do `render`. Você pode renderizar a _view_ padrão de um template do Rails, ou de um template específico, ou de um arquivo, ou código embutido, ou nada. Você pode renderizar text, JSON ou XML. Você também pode especificar o tipo de conteúdo ou o status HTTP da resposta renderizada.

TIP: Se você deseja ver os resultados exatos de uma chamada para `render` sem precisar inspecioná-la em um navegador, você pode chamar` render_to_string`. Este método usa exatamente as mesmas opções que o `render`, mas retorna uma string em vez de enviar uma resposta de volta ao navegador.

#### Renderizando a _View_ de uma _Action_

Se você deseja renderizar a _view_ que corresponde a um modelo diferente dentro do mesmo _controller_, você pode usar `render` com o nome da _view_:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render "edit"
  end
end
```

Se a chamada para `update` falhar, a _action_ `update` neste _controller_ renderizará o template `edit.html.erb` pertencente ao mesmo _controller_.

Se preferir, você pode usar um símbolo em vez de uma _string_ para especificar a _action_ a ser renderizada:

```ruby
def update
  @book = Book.find(params[:id])
  if @book.update(book_params)
    redirect_to(@book)
  else
    render :edit
  end
end
```

#### Renderizando o template de uma _Action_ de outro _Controller_

E se você quiser renderizar um template de um _controller_ totalmente diferente daquele que contém o código da _action_? Você também pode fazer isso com `render`, que aceita o caminho completo (relativo a `app/views`) do template a ser renderizado. Por exemplo, se você estiver executando o código em `AdminProductsController` que fica em` app/controllers/admin`, você pode renderizar os resultados de uma _action_ em um template em `app/views/products` desta maneira:

```ruby
render "products/show"
```

O Rails sabe que essa _view_ pertence a um _controller_ diferente devido ao caractere de barra contido na string. Se você quer ser explícito, você pode usar a opção `:template` (necessária no Rails 2.2 e versões anteriores):

```ruby
render template: "products/show"
```

#### Resumindo

As três maneiras acima de renderizar (renderizar outro template dentro do _controller_, renderizar um template dentro de outro _controller_ e renderizar um arquivo arbitrário no sistema de arquivos) são na verdade variantes da mesma ação.

De fato, na classe _BooksController_, dentro da _action_ update na qual queremos renderizar o template _edit_, se o livro não for atualizado com êxito, todas as seguintes chamadas de `render` renderizarão o _template_ `edit.html.erb` no diretório `views/books`:

```ruby
render :edit
render action: :edit
render "edit"
render action: "edit"
render "books/edit"
render template: "books/edit"
```

Qual deles você usa é realmente uma questão de estilo e convenção, mas a regra geral é usar o mais simples que faça sentido para o código que você está escrevendo.

#### Usando `render` com `:inline`

O método `render` pode ficar completamente sem uma _view_ se você estiver disposto a usar a opção `:inline` para fornecer um ERB como parte da chamada do método. Isso é perfeitamente válido:

```ruby
render inline: "<% products.each do |p| %><p><%= p.name %></p><% end %>"
```

WARNING: Raramente existe uma boa razão para usar esta opção. Misturar ERB em seus _controllers_ anula o MVC do Rails e torna mais difícil para outros desenvolvedores seguir a lógica do seu projeto. De preferência, use uma _view_ erb separada.

Por padrão, a renderização _inline_ usa o ERB. Como alternativa, você pode forçá-lo a usar Builder com a opção `:type`:

```ruby
render inline: "xml.p {'Horrid coding practice!'}", type: :builder
```

#### Renderização de texto

Você pode enviar texto sem formatação - sem nenhuma marcação - de volta ao navegador usando
a opção `:plain` em` render`:

```ruby
render plain: "OK"
```

TIP: A renderização de texto puro é mais útil quando você está respondendo solicitações Ajax ou serviços Web
que esperam algo diferente de HTML adequado.

NOTE: Por padrão, se você usar a opção `:plain`, o texto será renderizado sem
usar o layout atual. Se você deseja que o Rails coloque o texto no layout
atual, você precisa adicionar a opção `layout: true` e usar a extensão` .text.erb`
para o arquivo de layout.

#### Renderização de HTML

Você pode enviar uma _string_ HTML de volta ao navegador usando a opção `:html`
 em `render`:

```ruby
render html: helpers.tag.strong('Not Found')
```

TIP: Isso é útil quando você renderiza um pequeno trecho de código HTML.
No entanto, você deve considerar movê-lo para um arquivo de template se a marcação
for complexa.

NOTE: Ao usar a opção `html:`, as entidades HTML serão escapadas se a _string_ não for composta por APIs compatíveis com `html_safe`.

#### Renderizando JSON

JSON é um formato de dados JavaScript usado por muitas bibliotecas Ajax. O Rails possui suporte interno para converter objetos em JSON e renderizar esse JSON de volta ao navegador:

```ruby
render json: @product
```

TIP: Você não precisa chamar `to_json` no objeto que deseja renderizar. Se você usar a opção `:json`, o `render` chamará automaticamente `to_json` para você.

#### Renderizando XML

O Rails também possui suporte interno para converter objetos em XML e renderizar esse XML de volta para quem o chamou:

```ruby
render xml: @product
```

TIP: Você não precisa chamar `to_xml` no objeto que deseja renderizar. Se você usar a opção `:xml`, o` render` automaticamente chamará `to_xml` para você.

#### Renderizando Vanilla JavaScript

O Rails pode renderizar JavaScript convencional:

```ruby
render js: "alert('Hello Rails');"
```

Isso enviará a _string_ fornecida ao navegador com um _MIME type_ de `text/javascript`.

#### Renderizando conteúdo bruto

Você pode enviar um conteúdo bruto de volta ao navegador, sem definir nenhum tipo de
conteúdo, usando a opção `:body` em `render`:

```ruby
render body: "raw"
```

TIP: essa opção deve ser usada apenas se você não se importar com o tipo de conteúdo
da resposta. Usando `:plain` ou `:html` é mais apropriado na maior parte do
tempo.

NOTE: A menos que substituído, sua resposta retornada dessa opção de renderização será
`text/plain`, pois esse é o tipo de conteúdo padrão da resposta do Action Dispatch.

#### Renderizando arquivo bruto

O Rails pode renderizar um arquivo bruto a partir de um caminho absoluto. Isso é útil para
condicionalmente renderizar arquivos estáticos, como páginas de erro.

```ruby
render file: "#{Rails.root}/public/404.html", layout: false
```

Isso renderiza o arquivo bruto (não suporta ERB ou outros manipuladores). Por
o padrão é renderizado no layout atual.

WARNING: Usar a opção `:file` em combinação com a entrada de dados dos usuários pode levar a problemas de segurança,
pois um invasor pode usar esta _action_ para acessar arquivos confidenciais de segurança em seu sistema de arquivos.

TIP: `send_file` geralmente é uma opção mais rápida e melhor se um layout não for necessário.

#### Options for `render`

Calls to the `render` method generally accept five options:

* `:content_type`
* `:layout`
* `:location`
* `:status`
* `:formats`
* `:variants`

##### The `:content_type` Option

By default, Rails will serve the results of a rendering operation with the MIME content-type of `text/html` (or `application/json` if you use the `:json` option, or `application/xml` for the `:xml` option.). There are times when you might like to change this, and you can do so by setting the `:content_type` option:

```ruby
render template: "feed", content_type: "application/rss"
```

##### The `:layout` Option

With most of the options to `render`, the rendered content is displayed as part of the current layout. You'll learn more about layouts and how to use them later in this guide.

You can use the `:layout` option to tell Rails to use a specific file as the layout for the current action:

```ruby
render layout: "special_layout"
```

You can also tell Rails to render with no layout at all:

```ruby
render layout: false
```

##### The `:location` Option

You can use the `:location` option to set the HTTP `Location` header:

```ruby
render xml: photo, location: photo_url(photo)
```

##### The `:status` Option

Rails will automatically generate a response with the correct HTTP status code (in most cases, this is `200 OK`). You can use the `:status` option to change this:

```ruby
render status: 500
render status: :forbidden
```

Rails understands both numeric status codes and the corresponding symbols shown below.

| Response Class      | HTTP Status Code | Symbol                           |
| ------------------- | ---------------- | -------------------------------- |
| **Informational**   | 100              | :continue                        |
|                     | 101              | :switching_protocols             |
|                     | 102              | :processing                      |
| **Success**         | 200              | :ok                              |
|                     | 201              | :created                         |
|                     | 202              | :accepted                        |
|                     | 203              | :non_authoritative_information   |
|                     | 204              | :no_content                      |
|                     | 205              | :reset_content                   |
|                     | 206              | :partial_content                 |
|                     | 207              | :multi_status                    |
|                     | 208              | :already_reported                |
|                     | 226              | :im_used                         |
| **Redirection**     | 300              | :multiple_choices                |
|                     | 301              | :moved_permanently               |
|                     | 302              | :found                           |
|                     | 303              | :see_other                       |
|                     | 304              | :not_modified                    |
|                     | 305              | :use_proxy                       |
|                     | 307              | :temporary_redirect              |
|                     | 308              | :permanent_redirect              |
| **Client Error**    | 400              | :bad_request                     |
|                     | 401              | :unauthorized                    |
|                     | 402              | :payment_required                |
|                     | 403              | :forbidden                       |
|                     | 404              | :not_found                       |
|                     | 405              | :method_not_allowed              |
|                     | 406              | :not_acceptable                  |
|                     | 407              | :proxy_authentication_required   |
|                     | 408              | :request_timeout                 |
|                     | 409              | :conflict                        |
|                     | 410              | :gone                            |
|                     | 411              | :length_required                 |
|                     | 412              | :precondition_failed             |
|                     | 413              | :payload_too_large               |
|                     | 414              | :uri_too_long                    |
|                     | 415              | :unsupported_media_type          |
|                     | 416              | :range_not_satisfiable           |
|                     | 417              | :expectation_failed              |
|                     | 421              | :misdirected_request             |
|                     | 422              | :unprocessable_entity            |
|                     | 423              | :locked                          |
|                     | 424              | :failed_dependency               |
|                     | 426              | :upgrade_required                |
|                     | 428              | :precondition_required           |
|                     | 429              | :too_many_requests               |
|                     | 431              | :request_header_fields_too_large |
|                     | 451              | :unavailable_for_legal_reasons   |
| **Server Error**    | 500              | :internal_server_error           |
|                     | 501              | :not_implemented                 |
|                     | 502              | :bad_gateway                     |
|                     | 503              | :service_unavailable             |
|                     | 504              | :gateway_timeout                 |
|                     | 505              | :http_version_not_supported      |
|                     | 506              | :variant_also_negotiates         |
|                     | 507              | :insufficient_storage            |
|                     | 508              | :loop_detected                   |
|                     | 510              | :not_extended                    |
|                     | 511              | :network_authentication_required |

NOTE:  If you try to render content along with a non-content status code
(100-199, 204, 205, or 304), it will be dropped from the response.

##### The `:formats` Option

Rails uses the format specified in the request (or `:html` by default). You can
change this passing the `:formats` option with a symbol or an array:

```ruby
render formats: :xml
render formats: [:json, :xml]
```

If a template with the specified format does not exist an `ActionView::MissingTemplate` error is raised.

##### The `:variants` Option

This tells Rails to look for template variations of the same format.
You can specify a list of variants by passing the `:variants` option with a symbol or an array.

An example of use would be this.

```ruby
# called in HomeController#index
render variants: [:mobile, :desktop]
```

With this set of variants Rails will look for the following set of templates and use the first that exists.

- `app/views/home/index.html+mobile.erb`
- `app/views/home/index.html+desktop.erb`
- `app/views/home/index.html.erb`

If a template with the specified format does not exist an `ActionView::MissingTemplate` error is raised.

Instead of setting the variant on the render call you may also set it on the request object in your controller action.

```ruby
def index
  request.variant = determine_variant
end

private

def determine_variant
  variant = nil
  # some code to determine the variant(s) to use
  variant = :mobile if session[:use_mobile]

  variant
end
```

#### Finding Layouts

To find the current layout, Rails first looks for a file in `app/views/layouts` with the same base name as the controller. For example, rendering actions from the `PhotosController` class will use `app/views/layouts/photos.html.erb` (or `app/views/layouts/photos.builder`). If there is no such controller-specific layout, Rails will use `app/views/layouts/application.html.erb` or `app/views/layouts/application.builder`. If there is no `.erb` layout, Rails will use a `.builder` layout if one exists. Rails also provides several ways to more precisely assign specific layouts to individual controllers and actions.

##### Specifying Layouts for Controllers

You can override the default layout conventions in your controllers by using the `layout` declaration. For example:

```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

With this declaration, all of the views rendered by the `ProductsController` will use `app/views/layouts/inventory.html.erb` as their layout.

To assign a specific layout for the entire application, use a `layout` declaration in your `ApplicationController` class:

```ruby
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```

With this declaration, all of the views in the entire application will use `app/views/layouts/main.html.erb` for their layout.

##### Choosing Layouts at Runtime

You can use a symbol to defer the choice of layout until a request is processed:

```ruby
class ProductsController < ApplicationController
  layout :products_layout

  def show
    @product = Product.find(params[:id])
  end

  private
    def products_layout
      @current_user.special? ? "special" : "products"
    end

end
```

Now, if the current user is a special user, they'll get a special layout when viewing a product.

You can even use an inline method, such as a Proc, to determine the layout. For example, if you pass a Proc object, the block you give the Proc will be given the `controller` instance, so the layout can be determined based on the current request:

```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

##### Conditional Layouts

Layouts specified at the controller level support the `:only` and `:except` options. These options take either a method name, or an array of method names, corresponding to method names within the controller:

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

With this declaration, the `product` layout would be used for everything but the `rss` and `index` methods.

##### Layout Inheritance

Layout declarations cascade downward in the hierarchy, and more specific layout declarations always override more general ones. For example:

* `application_controller.rb`

    ```ruby
    class ApplicationController < ActionController::Base
      layout "main"
    end
    ```

* `articles_controller.rb`

    ```ruby
    class ArticlesController < ApplicationController
    end
    ```

* `special_articles_controller.rb`

    ```ruby
    class SpecialArticlesController < ArticlesController
      layout "special"
    end
    ```

* `old_articles_controller.rb`

    ```ruby
    class OldArticlesController < SpecialArticlesController
      layout false

      def show
        @article = Article.find(params[:id])
      end

      def index
        @old_articles = Article.older
        render layout: "old"
      end
      # ...
    end
    ```

In this application:

* In general, views will be rendered in the `main` layout
* `ArticlesController#index` will use the `main` layout
* `SpecialArticlesController#index` will use the `special` layout
* `OldArticlesController#show` will use no layout at all
* `OldArticlesController#index` will use the `old` layout

##### Template Inheritance

Similar to the Layout Inheritance logic, if a template or partial is not found in the conventional path, the controller will look for a template or partial to render in its inheritance chain. For example:

```ruby
# in app/controllers/application_controller
class ApplicationController < ActionController::Base
end

# in app/controllers/admin_controller
class AdminController < ApplicationController
end

# in app/controllers/admin/products_controller
class Admin::ProductsController < AdminController
  def index
  end
end
```

The lookup order for an `admin/products#index` action will be:

* `app/views/admin/products/`
* `app/views/admin/`
* `app/views/application/`

This makes `app/views/application/` a great place for your shared partials, which can then be rendered in your ERB as such:

```erb
<%# app/views/admin/products/index.html.erb %>
<%= render @products || "empty_list" %>

<%# app/views/application/_empty_list.html.erb %>
There are no items in this list <em>yet</em>.
```

#### Avoiding Double Render Errors

Sooner or later, most Rails developers will see the error message "Can only render or redirect once per action". While this is annoying, it's relatively easy to fix. Usually it happens because of a fundamental misunderstanding of the way that `render` works.

For example, here's some code that will trigger this error:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

If `@book.special?` evaluates to `true`, Rails will start the rendering process to dump the `@book` variable into the `special_show` view. But this will _not_ stop the rest of the code in the `show` action from running, and when Rails hits the end of the action, it will start to render the `regular_show` view - and throw an error. The solution is simple: make sure that you have only one call to `render` or `redirect` in a single code path. One thing that can help is `and return`. Here's a patched version of the method:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show" and return
  end
  render action: "regular_show"
end
```

Make sure to use `and return` instead of `&& return` because `&& return` will not work due to the operator precedence in the Ruby Language.

Note that the implicit render done by ActionController detects if `render` has been called, so the following will work without errors:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```

This will render a book with `special?` set with the `special_show` template, while other books will render with the default `show` template.

### Usando `redirect_to`

Outra maneira de lidar com o retorno das respostas de uma requisição HTTP é com `redirect_to`. Como você viu, `render` diz ao Rails qual _view_ (ou outro _asset_) deve ser usado na construção de uma resposta. O método `redirect_to` faz algo completamente diferente: diz ao navegador para enviar uma nova requisição para uma URL diferente. Por exemplo, você pode redirecionar de onde quer que esteja no seu código para o _index_ de fotos em sua aplicação com esta chamada:

```ruby
redirect_to photos_url
```

Você pode usar o `redirect_back` para retornar o usuário à página de onde eles vieram.
Este local é extraído do cabeçalho `HTTP_REFERER`, que não garante
que esteja definido pelo navegador, portanto, você deve fornecer o `fallback_location`
para usar neste caso.

```ruby
redirect_back(fallback_location: root_path)
```

NOTE: `redirect_to` e `redirect_back` não param e retornam imediatamente da execução do método, mas simplesmente definem as respostas HTTP. As instruções que ocorrerem depois deles em um método serão executadas. Você pode parar a execução com um `return` explícito ou algum outro mecanismo de parada, se necessário.

#### Obtendo um Código de Status de Redirecionamento Diferente

O Rails usa o código de status HTTP 302, um redirecionamento temporário, quando você chama `redirect_to`. Se você quiser usar um código de status diferente, talvez 301, um redirecionamento permanente, use a opção `:status`:

```ruby
redirect_to photos_path, status: 301
```

Assim como a opção `:status` para` render`, `:status` para `redirect_to` aceita designações numéricas e simbólicas de cabeçalho .

#### A Diferença entre `render` e` redirect_to`

Às vezes, pessoas desenvolvedoras inexperientes pensam no `redirect_to` como uma espécie de comando `goto`, movendo a execução de um lugar para outro no seu código Rails. Isso _não_ está correto. Seu código para de ser executado e aguarda uma nova requisição do navegador. Acontece que você informou ao navegador qual requisição deve acontecer em seguida, enviando de volta um código de status HTTP 302.

Considere estas ações para ver a diferença:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    render action: "index"
  end
end
```

Com o código neste formulário, provavelmente haverá um problema se a variável `@book` for `nil`. Lembre-se de que um `render: action` não executa nenhum código na _action_ de destino, então nada configurará a variável `@books` que a _view_ do `index` provavelmente exigirá. Uma maneira de corrigir isso é redirecionar em vez de renderizar:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    redirect_to action: :index
  end
end
```

Com esse código, o navegador fará uma nova requisição para a página de índice, o código no método `index` será executado e tudo ficará bem.

A única desvantagem desse código é que ele requer que o navegador faça uma volta: o navegador solicitou a _action_ _show_ com `/books/1` e o _controller_ descobre que não há livros, portanto o _controller_ envia uma resposta de redirecionamento 302 para o navegador dizendo para ele ir para `/books/`, o navegador obedece e envia uma nova requisição de volta ao _controller_ solicitando agora a _action_ `index`, o _controller_ obtém todos os livros no banco de dados e renderiza o template de _index_, enviando-o de volta para o navegador, que o exibe na tela.

Enquanto em uma aplicação pequena essa latência adicional pode não ser um problema, é algo para se pensar se o tempo de resposta é uma preocupação. Podemos demonstrar uma maneira de lidar com isso com um exemplo:

```ruby
def index
  @books = Book.all
end

def show
  @book = Book.find_by(id: params[:id])
  if @book.nil?
    @books = Book.all
    flash.now[:alert] = "Your book was not found"
    render "index"
  end
end
```

Isso detectaria que não há livros com o ID especificado, define a variável de instância `@books` com todos os livros no modelo e depois renderiza diretamente o template `index.html.erb`, retornando-o ao navegador com um mensagem de alerta _flash_ para informar ao usuário o que aconteceu.

### Usando `head` para criar respostas com apenas o cabeçalho (_Header-Only_)

O método `head` pode ser usado para enviar respostas apenas com cabeçalhos para o navegador. O método `head` aceita um número ou símbolo (consulte [tabela de referência] (#a-opção-status)) representando um código de status HTTP. O argumento de _options_ é interpretado como um hash de nomes e valores de cabeçalho. Por exemplo, você pode retornar apenas um cabeçalho de erro:

```ruby
head :bad_request
```

Isso produziria o seguinte cabeçalho:

```
HTTP/1.1 400 Bad Request
Connection: close
Date: Sun, 24 Jan 2010 12:15:53 GMT
Transfer-Encoding: chunked
Content-Type: text/html; charset=utf-8
X-Runtime: 0.013483
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

Ou você pode usar outros cabeçalhos HTTP para transmitir outras informações:

```ruby
head :created, location: photo_path(@photo)
```

O que produziria:

```
HTTP/1.1 201 Created
Connection: close
Date: Sun, 24 Jan 2010 12:16:44 GMT
Transfer-Encoding: chunked
Location: /photos/1
Content-Type: text/html; charset=utf-8
X-Runtime: 0.083496
Set-Cookie: _blog_session=...snip...; path=/; HttpOnly
Cache-Control: no-cache
```

Structuring Layouts
-------------------

When Rails renders a view as a response, it does so by combining the view with the current layout, using the rules for finding the current layout that were covered earlier in this guide. Within a layout, you have access to three tools for combining different bits of output to form the overall response:

* Asset tags
* `yield` and `content_for`
* Partials

### Asset Tag Helpers

Asset tag helpers provide methods for generating HTML that link views to feeds, JavaScript, stylesheets, images, videos, and audios. There are six asset tag helpers available in Rails:

* `auto_discovery_link_tag`
* `javascript_include_tag`
* `stylesheet_link_tag`
* `image_tag`
* `video_tag`
* `audio_tag`

You can use these tags in layouts or other views, although the `auto_discovery_link_tag`, `javascript_include_tag`, and `stylesheet_link_tag`, are most commonly used in the `<head>` section of a layout.

WARNING: The asset tag helpers do _not_ verify the existence of the assets at the specified locations; they simply assume that you know what you're doing and generate the link.

#### Linking to Feeds with the `auto_discovery_link_tag`

The `auto_discovery_link_tag` helper builds HTML that most browsers and feed readers can use to detect the presence of RSS, Atom, or JSON feeds. It takes the type of the link (`:rss`, `:atom`, or `:json`), a hash of options that are passed through to url_for, and a hash of options for the tag:

```erb
<%= auto_discovery_link_tag(:rss, {action: "feed"},
  {title: "RSS Feed"}) %>
```

There are three tag options available for the `auto_discovery_link_tag`:

* `:rel` specifies the `rel` value in the link. The default value is "alternate".
* `:type` specifies an explicit MIME type. Rails will generate an appropriate MIME type automatically.
* `:title` specifies the title of the link. The default value is the uppercase `:type` value, for example, "ATOM" or "RSS".

#### Linking to JavaScript Files with the `javascript_include_tag`

The `javascript_include_tag` helper returns an HTML `script` tag for each source provided.

If you are using Rails with the [Asset Pipeline](asset_pipeline.html) enabled, this helper will generate a link to `/assets/javascripts/` rather than `public/javascripts` which was used in earlier versions of Rails. This link is then served by the asset pipeline.

A JavaScript file within a Rails application or Rails engine goes in one of three locations: `app/assets`, `lib/assets` or `vendor/assets`. These locations are explained in detail in the [Asset Organization section in the Asset Pipeline Guide](asset_pipeline.html#asset-organization).

You can specify a full path relative to the document root, or a URL, if you prefer. For example, to link to a JavaScript file that is inside a directory called `javascripts` inside of one of `app/assets`, `lib/assets` or `vendor/assets`, you would do this:

```erb
<%= javascript_include_tag "main" %>
```

Rails will then output a `script` tag such as this:

```html
<script src='/assets/main.js'></script>
```

The request to this asset is then served by the Sprockets gem.

To include multiple files such as `app/assets/javascripts/main.js` and `app/assets/javascripts/columns.js` at the same time:

```erb
<%= javascript_include_tag "main", "columns" %>
```

To include `app/assets/javascripts/main.js` and `app/assets/javascripts/photos/columns.js`:

```erb
<%= javascript_include_tag "main", "/photos/columns" %>
```

To include `http://example.com/main.js`:

```erb
<%= javascript_include_tag "http://example.com/main.js" %>
```

#### Linking to CSS Files with the `stylesheet_link_tag`

The `stylesheet_link_tag` helper returns an HTML `<link>` tag for each source provided.

If you are using Rails with the "Asset Pipeline" enabled, this helper will generate a link to `/assets/stylesheets/`. This link is then processed by the Sprockets gem. A stylesheet file can be stored in one of three locations: `app/assets`, `lib/assets` or `vendor/assets`.

You can specify a full path relative to the document root, or a URL. For example, to link to a stylesheet file that is inside a directory called `stylesheets` inside of one of `app/assets`, `lib/assets` or `vendor/assets`, you would do this:

```erb
<%= stylesheet_link_tag "main" %>
```

To include `app/assets/stylesheets/main.css` and `app/assets/stylesheets/columns.css`:

```erb
<%= stylesheet_link_tag "main", "columns" %>
```

To include `app/assets/stylesheets/main.css` and `app/assets/stylesheets/photos/columns.css`:

```erb
<%= stylesheet_link_tag "main", "photos/columns" %>
```

To include `http://example.com/main.css`:

```erb
<%= stylesheet_link_tag "http://example.com/main.css" %>
```

By default, the `stylesheet_link_tag` creates links with `media="screen" rel="stylesheet"`. You can override any of these defaults by specifying an appropriate option (`:media`, `:rel`):

```erb
<%= stylesheet_link_tag "main_print", media: "print" %>
```

#### Linking to Images with the `image_tag`

The `image_tag` helper builds an HTML `<img />` tag to the specified file. By default, files are loaded from `public/images`.

WARNING: Note that you must specify the extension of the image.

```erb
<%= image_tag "header.png" %>
```

You can supply a path to the image if you like:

```erb
<%= image_tag "icons/delete.gif" %>
```

You can supply a hash of additional HTML options:

```erb
<%= image_tag "icons/delete.gif", {height: 45} %>
```

You can supply alternate text for the image which will be used if the user has images turned off in their browser. If you do not specify an alt text explicitly, it defaults to the file name of the file, capitalized and with no extension. For example, these two image tags would return the same code:

```erb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", alt: "Home" %>
```

You can also specify a special size tag, in the format "{width}x{height}":

```erb
<%= image_tag "home.gif", size: "50x20" %>
```

In addition to the above special tags, you can supply a final hash of standard HTML options, such as `:class`, `:id` or `:name`:

```erb
<%= image_tag "home.gif", alt: "Go Home",
                          id: "HomeImage",
                          class: "nav_bar" %>
```

#### Linking to Videos with the `video_tag`

The `video_tag` helper builds an HTML 5 `<video>` tag to the specified file. By default, files are loaded from `public/videos`.

```erb
<%= video_tag "movie.ogg" %>
```

Produces

```erb
<video src="/videos/movie.ogg" />
```

Like an `image_tag` you can supply a path, either absolute, or relative to the `public/videos` directory. Additionally you can specify the `size: "#{width}x#{height}"` option just like an `image_tag`. Video tags can also have any of the HTML options specified at the end (`id`, `class` et al).

The video tag also supports all of the `<video>` HTML options through the HTML options hash, including:

* `poster: "image_name.png"`, provides an image to put in place of the video before it starts playing.
* `autoplay: true`, starts playing the video on page load.
* `loop: true`, loops the video once it gets to the end.
* `controls: true`, provides browser supplied controls for the user to interact with the video.
* `autobuffer: true`, the video will pre load the file for the user on page load.

You can also specify multiple videos to play by passing an array of videos to the `video_tag`:

```erb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

This will produce:

```erb
<video>
  <source src="/videos/trailer.ogg">
  <source src="/videos/movie.ogg">
</video>
```

#### Linking to Audio Files with the `audio_tag`

The `audio_tag` helper builds an HTML 5 `<audio>` tag to the specified file. By default, files are loaded from `public/audios`.

```erb
<%= audio_tag "music.mp3" %>
```

You can supply a path to the audio file if you like:

```erb
<%= audio_tag "music/first_song.mp3" %>
```

You can also supply a hash of additional options, such as `:id`, `:class` etc.

Like the `video_tag`, the `audio_tag` has special options:

* `autoplay: true`, starts playing the audio on page load
* `controls: true`, provides browser supplied controls for the user to interact with the audio.
* `autobuffer: true`, the audio will pre load the file for the user on page load.

### Understanding `yield`

Within the context of a layout, `yield` identifies a section where content from the view should be inserted. The simplest way to use this is to have a single `yield`, into which the entire contents of the view currently being rendered is inserted:

```html+erb
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

You can also create a layout with multiple yielding regions:

```html+erb
<html>
  <head>
  <%= yield :head %>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

The main body of the view will always render into the unnamed `yield`. To render content into a named `yield`, you use the `content_for` method.

### Using the `content_for` Method

The `content_for` method allows you to insert content into a named `yield` block in your layout. For example, this view would work with the layout that you just saw:

```html+erb
<% content_for :head do %>
  <title>A simple page</title>
<% end %>

<p>Hello, Rails!</p>
```

The result of rendering this page into the supplied layout would be this HTML:

```html+erb
<html>
  <head>
  <title>A simple page</title>
  </head>
  <body>
  <p>Hello, Rails!</p>
  </body>
</html>
```

The `content_for` method is very helpful when your layout contains distinct regions such as sidebars and footers that should get their own blocks of content inserted. It's also useful for inserting tags that load page-specific JavaScript or css files into the header of an otherwise generic layout.

### Using Partials

Partial templates - usually just called "partials" - are another device for breaking the rendering process into more manageable chunks. With a partial, you can move the code for rendering a particular piece of a response to its own file.

#### Naming Partials

To render a partial as part of a view, you use the `render` method within the view:

```ruby
<%= render "menu" %>
```

This will render a file named `_menu.html.erb` at that point within the view being rendered. Note the leading underscore character: partials are named with a leading underscore to distinguish them from regular views, even though they are referred to without the underscore. This holds true even when you're pulling in a partial from another folder:

```ruby
<%= render "shared/menu" %>
```

That code will pull in the partial from `app/views/shared/_menu.html.erb`.

#### Using Partials to Simplify Views

One way to use partials is to treat them as the equivalent of subroutines: as a way to move details out of a view so that you can grasp what's going on more easily. For example, you might have a view that looked like this:

```erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
...

<%= render "shared/footer" %>
```

Here, the `_ad_banner.html.erb` and `_footer.html.erb` partials could contain
content that is shared by many pages in your application. You don't need to see
the details of these sections when you're concentrating on a particular page.

As seen in the previous sections of this guide, `yield` is a very powerful tool
for cleaning up your layouts. Keep in mind that it's pure Ruby, so you can use
it almost everywhere. For example, we can use it to DRY up form layout
definitions for several similar resources:

* `users/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |f| %>
      <p>
        Name contains: <%= f.text_field :name_contains %>
      </p>
    <% end %>
    ```

* `roles/index.html.erb`

    ```html+erb
    <%= render "shared/search_filters", search: @q do |f| %>
      <p>
        Title contains: <%= f.text_field :title_contains %>
      </p>
    <% end %>
    ```

* `shared/_search_filters.html.erb`

    ```html+erb
    <%= form_for(search) do |f| %>
      <h1>Search form:</h1>
      <fieldset>
        <%= yield f %>
      </fieldset>
      <p>
        <%= f.submit "Search" %>
      </p>
    <% end %>
    ```

TIP: For content that is shared among all pages in your application, you can use partials directly from layouts.

#### Partial Layouts

A partial can use its own layout file, just as a view can use a layout. For example, you might call a partial like this:

```erb
<%= render partial: "link_area", layout: "graybar" %>
```

This would look for a partial named `_link_area.html.erb` and render it using the layout `_graybar.html.erb`. Note that layouts for partials follow the same leading-underscore naming as regular partials, and are placed in the same folder with the partial that they belong to (not in the master `layouts` folder).

Also note that explicitly specifying `:partial` is required when passing additional options such as `:layout`.

#### Passing Local Variables

You can also pass local variables into partials, making them even more powerful and flexible. For example, you can use this technique to reduce duplication between new and edit pages, while still keeping a bit of distinct content:

* `new.html.erb`

    ```html+erb
    <h1>New zone</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `edit.html.erb`

    ```html+erb
    <h1>Editing zone</h1>
    <%= render partial: "form", locals: {zone: @zone} %>
    ```

* `_form.html.erb`

    ```html+erb
    <%= form_for(zone) do |f| %>
      <p>
        <b>Zone name</b><br>
        <%= f.text_field :name %>
      </p>
      <p>
        <%= f.submit %>
      </p>
    <% end %>
    ```

Although the same partial will be rendered into both views, Action View's submit helper will return "Create Zone" for the new action and "Update Zone" for the edit action.

To pass a local variable to a partial in only specific cases use the `local_assigns`.

* `index.html.erb`

  ```erb
  <%= render user.articles %>
  ```

* `show.html.erb`

  ```erb
  <%= render article, full: true %>
  ```

* `_article.html.erb`

  ```erb
  <h2><%= article.title %></h2>

  <% if local_assigns[:full] %>
    <%= simple_format article.body %>
  <% else %>
    <%= truncate article.body %>
  <% end %>
  ```

This way it is possible to use the partial without the need to declare all local variables.

Every partial also has a local variable with the same name as the partial (minus the leading underscore). You can pass an object in to this local variable via the `:object` option:

```erb
<%= render partial: "customer", object: @new_customer %>
```

Within the `customer` partial, the `customer` variable will refer to `@new_customer` from the parent view.

If you have an instance of a model to render into a partial, you can use a shorthand syntax:

```erb
<%= render @customer %>
```

Assuming that the `@customer` instance variable contains an instance of the `Customer` model, this will use `_customer.html.erb` to render it and will pass the local variable `customer` into the partial which will refer to the `@customer` instance variable in the parent view.

#### Rendering Collections

Partials are very useful in rendering collections. When you pass a collection to a partial via the `:collection` option, the partial will be inserted once for each member in the collection:

* `index.html.erb`

    ```html+erb
    <h1>Products</h1>
    <%= render partial: "product", collection: @products %>
    ```

* `_product.html.erb`

    ```html+erb
    <p>Product Name: <%= product.name %></p>
    ```

When a partial is called with a pluralized collection, then the individual instances of the partial have access to the member of the collection being rendered via a variable named after the partial. In this case, the partial is `_product`, and within the `_product` partial, you can refer to `product` to get the instance that is being rendered.

There is also a shorthand for this. Assuming `@products` is a collection of `Product` instances, you can simply write this in the `index.html.erb` to produce the same result:

```html+erb
<h1>Products</h1>
<%= render @products %>
```

Rails determines the name of the partial to use by looking at the model name in the collection. In fact, you can even create a heterogeneous collection and render it this way, and Rails will choose the proper partial for each member of the collection:

* `index.html.erb`

    ```html+erb
    <h1>Contacts</h1>
    <%= render [customer1, employee1, customer2, employee2] %>
    ```

* `customers/_customer.html.erb`

    ```html+erb
    <p>Customer: <%= customer.name %></p>
    ```

* `employees/_employee.html.erb`

    ```html+erb
    <p>Employee: <%= employee.name %></p>
    ```

In this case, Rails will use the customer or employee partials as appropriate for each member of the collection.

In the event that the collection is empty, `render` will return nil, so it should be fairly simple to provide alternative content.

```html+erb
<h1>Products</h1>
<%= render(@products) || "There are no products available." %>
```

#### Local Variables

To use a custom local variable name within the partial, specify the `:as` option in the call to the partial:

```erb
<%= render partial: "product", collection: @products, as: :item %>
```

With this change, you can access an instance of the `@products` collection as the `item` local variable within the partial.

You can also pass in arbitrary local variables to any partial you are rendering with the `locals: {}` option:

```erb
<%= render partial: "product", collection: @products,
           as: :item, locals: {title: "Products Page"} %>
```

In this case, the partial will have access to a local variable `title` with the value "Products Page".

TIP: Rails also makes a counter variable available within a partial called by the collection, named after the title of the partial followed by `_counter`. For example, when rendering a collection `@products` the partial `_product.html.erb` can access the variable `product_counter` which indexes the number of times it has been rendered within the enclosing view. Note that it also applies for when the partial name was changed by using the `as:` option. For example, the counter variable for the code above would be `item_counter`.

You can also specify a second partial to be rendered between instances of the main partial by using the `:spacer_template` option:

#### Spacer Templates

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

Rails will render the `_product_ruler` partial (with no data passed in to it) between each pair of `_product` partials.

#### Collection Partial Layouts

When rendering collections it is also possible to use the `:layout` option:

```erb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

The layout will be rendered together with the partial for each item in the collection. The current object and object_counter variables will be available in the layout as well, the same way they are within the partial.

### Using Nested Layouts

You may find that your application requires a layout that differs slightly from your regular application layout to support one particular controller. Rather than repeating the main layout and editing it, you can accomplish this by using nested layouts (sometimes called sub-templates). Here's an example:

Suppose you have the following `ApplicationController` layout:

* `app/views/layouts/application.html.erb`

    ```html+erb
    <html>
    <head>
      <title><%= @page_title or "Page Title" %></title>
      <%= stylesheet_link_tag "layout" %>
      <style><%= yield :stylesheets %></style>
    </head>
    <body>
      <div id="top_menu">Top menu items here</div>
      <div id="menu">Menu items here</div>
      <div id="content"><%= content_for?(:content) ? yield(:content) : yield %></div>
    </body>
    </html>
    ```

On pages generated by `NewsController`, you want to hide the top menu and add a right menu:

* `app/views/layouts/news.html.erb`

    ```html+erb
    <% content_for :stylesheets do %>
      #top_menu {display: none}
      #right_menu {float: right; background-color: yellow; color: black}
    <% end %>
    <% content_for :content do %>
      <div id="right_menu">Right menu items here</div>
      <%= content_for?(:news_content) ? yield(:news_content) : yield %>
    <% end %>
    <%= render template: "layouts/application" %>
    ```

That's it. The News views will use the new layout, hiding the top menu and adding a new right menu inside the "content" div.

There are several ways of getting similar results with different sub-templating schemes using this technique. Note that there is no limit in nesting levels. One can use the `ActionView::render` method via `render template: 'layouts/news'` to base a new layout on the News layout. If you are sure you will not subtemplate the `News` layout, you can replace the `content_for?(:news_content) ? yield(:news_content) : yield` with simply `yield`.
