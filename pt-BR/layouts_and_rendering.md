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

#### Opções para `render`

As chamadas para o método `render` geralmente aceitam seis opções:

* `:content_type`
* `:layout`
* `:location`
* `:status`
* `:formats`
* `:variants`

##### A opção `:content_type`

Por padrão, o Rails exibirá os resultados de uma renderização com o tipo de conteúdo MIME como `text/html` (ou `application/json` se você usar a opção `:json` ou` application/xml` para a opção `:xml`.). Há momentos em que você pode alterar isso, e pode fazê-lo definindo a opção `:content_type`:

```ruby
render template: "feed", content_type: "application/rss"
```

##### A opção `:layout`

Com a maioria das opções para `render`, o conteúdo renderizado é exibido como parte do layout atual. Você aprenderá mais sobre layouts e como usá-los posteriormente neste guia.

Você pode usar a opção `:layout` para que o Rails use um arquivo específico como o layout da _action_ atual:

```ruby
render layout: "special_layout"
```

Você também pode dizer ao Rails para renderizar sem nenhum layout:

```ruby
render layout: false
```

##### A opção `:location`

Você pode usar a opção `:location` para definir o cabeçalho HTTP `Location`:

```ruby
render xml: photo, location: photo_url(photo)
```

##### A opção `:status`

O Rails gerará automaticamente uma resposta com o código de status HTTP correto (na maioria dos casos, isso é `200 OK`). Você pode usar a opção `:status` para alterar isso:

```ruby
render status: 500
render status: :forbidden
```

O Rails entende os códigos númericos de status e os símbolos correspondentes mostrados abaixo.

| Classe da Resposta  | Código de Status HTTP      | Símbolo                          |
| ------------------- | -------------------------- | -------------------------------- |
| **Informational**   | 100                        | :continue                        |
|                     | 101                        | :switching_protocols             |
|                     | 102                        | :processing                      |
| **Success**         | 200                        | :ok                              |
|                     | 201                        | :created                         |
|                     | 202                        | :accepted                        |
|                     | 203                        | :non_authoritative_information   |
|                     | 204                        | :no_content                      |
|                     | 205                        | :reset_content                   |
|                     | 206                        | :partial_content                 |
|                     | 207                        | :multi_status                    |
|                     | 208                        | :already_reported                |
|                     | 226                        | :im_used                         |
| **Redirection**     | 300                        | :multiple_choices                |
|                     | 301                        | :moved_permanently               |
|                     | 302                        | :found                           |
|                     | 303                        | :see_other                       |
|                     | 304                        | :not_modified                    |
|                     | 305                        | :use_proxy                       |
|                     | 307                        | :temporary_redirect              |
|                     | 308                        | :permanent_redirect              |
| **Client Error**    | 400                        | :bad_request                     |
|                     | 401                        | :unauthorized                    |
|                     | 402                        | :payment_required                |
|                     | 403                        | :forbidden                       |
|                     | 404                        | :not_found                       |
|                     | 405                        | :method_not_allowed              |
|                     | 406                        | :not_acceptable                  |
|                     | 407                        | :proxy_authentication_required   |
|                     | 408                        | :request_timeout                 |
|                     | 409                        | :conflict                        |
|                     | 410                        | :gone                            |
|                     | 411                        | :length_required                 |
|                     | 412                        | :precondition_failed             |
|                     | 413                        | :payload_too_large               |
|                     | 414                        | :uri_too_long                    |
|                     | 415                        | :unsupported_media_type          |
|                     | 416                        | :range_not_satisfiable           |
|                     | 417                        | :expectation_failed              |
|                     | 421                        | :misdirected_request             |
|                     | 422                        | :unprocessable_entity            |
|                     | 423                        | :locked                          |
|                     | 424                        | :failed_dependency               |
|                     | 426                        | :upgrade_required                |
|                     | 428                        | :precondition_required           |
|                     | 429                        | :too_many_requests               |
|                     | 431                        | :request_header_fields_too_large |
|                     | 451                        | :unavailable_for_legal_reasons   |
| **Server Error**    | 500                        | :internal_server_error           |
|                     | 501                        | :not_implemented                 |
|                     | 502                        | :bad_gateway                     |
|                     | 503                        | :service_unavailable             |
|                     | 504                        | :gateway_timeout                 |
|                     | 505                        | :http_version_not_supported      |
|                     | 506                        | :variant_also_negotiates         |
|                     | 507                        | :insufficient_storage            |
|                     | 508                        | :loop_detected                   |
|                     | 510                        | :not_extended                    |
|                     | 511                        | :network_authentication_required |

NOTE: Se você tentar renderizar um conteúdo junto com um código de status que não tem conteúdo
(100-199, 204, 205 ou 304), o contéudo será descartado da resposta.

##### A opção `:formats`

O Rails usa o formato especificado na solicitação (ou `:html` por padrão). Você pode
mudar isso passando a opção `:formats` com um símbolo ou um _array_:

```ruby
render formats: :xml
render formats: [:json, :xml]
```

Se um template com o formato especificado não existir, será gerado um erro `ActionView::MissingTemplate`.

##### A opção `:variants`

Isso diz ao Rails para procurar variações de template do mesmo formato.
Você pode especificar uma lista de variações passando a opção `:variants` com um símbolo ou um _array_.

Um exemplo de uso seria este.

```ruby
# called in HomeController#index
render variants: [:mobile, :desktop]
```

Com esse conjunto de variantes, o Rails procurará o conjunto de modelos a seguir e usará o primeiro que encontrar.

- `app/views/home/index.html+mobile.erb`
- `app/views/home/index.html+desktop.erb`
- `app/views/home/index.html.erb`

Se um template com o formato especificado não existir, será gerado um erro `ActionView::MissingTemplate`.

Em vez de definir a variação na chamada da renderização, você também pode configurá-la no objeto de solicitação na _action_ do _controller_.

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

#### Localizando Layouts

Para encontrar o layout atual, o Rails primeiro procura por um arquivo em `app/views/layouts` com o mesmo nome base que o _controller_. Por exemplo, renderizar _actions_ da classe `PhotosController` usam `app/views/layouts/photos.html.erb` (ou `app/views/layouts/photos.builder`). Se não houver esse layout específico do _controller_, o Rails usará `app/views/layouts/application.html.erb` ou` app/views/layouts/application.builder`. Se não houver um layout `.erb`, o Rails usará um layout` .builder`, se houver. O Rails também fornece várias maneiras de atribuir layouts específicos com mais precisão a _controllers_ e _actions_ individuais.

##### Especificando Layouts para Controllers

Você pode substituir as convenções de layout padrão em seus _controllers_ usando a declaração `layout`. Por exemplo:

```ruby
class ProductsController < ApplicationController
  layout "inventory"
  #...
end
```

Com esta declaração, todas as _views_ renderizadas pelo `ProductsController` usarão` app/views/layouts/inventário.html.erb` como layout.

Para atribuir um layout específico para toda a aplicação, declare um `layout` na sua classe` ApplicationController`:

```ruby
class ApplicationController < ActionController::Base
  layout "main"
  #...
end
```

Com esta declaração, todas as _views_, em toda a aplicação, usarão `app/views/layouts/main.html.erb` para seu layout.

##### Escolhendo Layouts em Tempo de Execução

Você pode usar um símbolo para adiar a escolha do layout até que uma requisição seja processada:

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

Agora, se o usuário atual for um usuário especial, ele receberá um layout especial ao visualizar um produto.

Você pode até usar um método _inline_, como um Proc, para determinar o layout. Por exemplo, se você passar um objeto Proc, o bloco que você fornecer ao Proc receberá a instância `controller`, para que o layout possa ser determinado com base na solicitação atual:

```ruby
class ProductsController < ApplicationController
  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }
end
```

##### Layouts Condicionais

Os layouts especificados no nível do _controller_ suportam as opções `:only` e`:except`. Essas opções recebem um nome de método ou um _array_ de nomes de métodos que correspondem aos nomes de métodos no _controller_:

```ruby
class ProductsController < ApplicationController
  layout "product", except: [:index, :rss]
end
```

Com esta declaração, o layout de `product` seria usado para tudo, menos os métodos` rss` e `index`.

##### Herança de Layout

As declarações de layout cascateam na hierarquia, e as declarações de layout mais específicas sempre substituem as mais gerais. Por exemplo:

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

Nesta aplicação:

* Em geral, as _views_ serão renderizadas no layout `main`
* O `ArticlesController#index` usará o layout `main`
* `SpecialArticlesController#index` usará o layout `special`
* `OldArticlesController#show` não usará nenhum layout
* `OldArticlesController#index` usará o layout `old`

##### Herança de Template

Similar à lógica de herança de layout, se um *template* ou _partial_ não for encontrado no caminho convencional, o _controller_ procurará um *template* ou _partial_ para renderizar em sua cadeia de herança. Por exemplo:

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

A ordem de busca para uma _action_ `admin/products#index` será:

* `app/views/admin/products/`
* `app/views/admin/`
* `app/views/application/`

Isso torna o `app/views/application/` um ótimo lugar para suas _partials_ compartilhadas, que podem ser renderizadas no seu ERB da seguinte forma:

```erb
<%# app/views/admin/products/index.html.erb %>
<%= render @products || "empty_list" %>

<%# app/views/application/_empty_list.html.erb %>
There are no items in this list <em>yet</em>.
```

#### Como evitar erros de renderização dupla

Mais cedo ou mais tarde, a maioria das pessoas desenvolvedoras Rails verá a mensagem de erro "Só pode renderizar ou redirecionar uma vez por ação" ("Can only render or redirect once per action"). Embora isso seja irritante, é relativamente fácil de corrigir. Geralmente isso ocorre devido a um mal-entendido sobre o modo como o `render` funciona.

Por exemplo, aqui está um código que acionará esse erro:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
  render action: "regular_show"
end
```

Se `@book.special?` for avaliado como `true`, o Rails iniciará o processo de renderização para despejar a variável `@book` na _view_ `special_show`. Mas isso _não_ interrompe a execução do restante do código na _action_ `show`, e quando o Rails chegar ao final da ação, ele começará a renderizar a _view_ `regular_show` - e gerará um erro. A solução é simples: verifique se você tem apenas uma chamada para `render` ou `redirect` em um único fluxo de código. Uma coisa que pode ajudar é `and return`. Aqui está uma versão corrigida do método:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show" and return
  end
  render action: "regular_show"
end
```

Certifique-se de usar `and return` em vez de `&& return`, porque `&& return` não funcionará devido à precedência do operador na linguagem Ruby.

Observe que a renderização implícita feita pelo `ActionController` detecta se `render` foi chamado, portanto, o seguinte código funcionará sem erros:

```ruby
def show
  @book = Book.find(params[:id])
  if @book.special?
    render action: "special_show"
  end
end
```
Isso renderizará um livro com `special?` configurado com o *template* `special_show`, enquanto outros livros serão renderizados com o template padrão `show`.

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

Estruturando *Layouts*
-------------------

Quando o Rails renderiza a *view* como uma resposta, ele faz isso combinando a *view* com o *layout* atual, usando as regras pra achar o *layout* atual que foram mencionadas neste guia. Dentro de um *layout*, você tem acesso a três ferramentas para combinar pedaços diferentes de saídas para formar a resposta geral:

* *Asset tags*
* `yield` e `content_for`
* *Partials*

### *Helpers* de *Asset Tags*

*Helpers* de *Asset Tags* fornecem métodos para gerar HTML que liga *views* a *feeds*, JavaScript, *stylesheets*, imagens, vídeos, e áudios. Há seis *helpers* de *asset tags* disponíveis no Rails:

* `auto_discovery_link_tag`
* `javascript_include_tag`
* `stylesheet_link_tag`
* `image_tag`
* `video_tag`
* `audio_tag`

Você pode usar essas *tags* em *layouts* ou outras *views*, embora os métodos `auto_discovery_link_tag`, `javascript_include_tag` e `stylesheet_link_tag` apareçam mais na seção `<head>` de um *layout*.

WARNING: Os *helpers* de *asset tags* _não_ verificam a existência dos *assets* nos endereços específicos; eles simplesmente presumem que você sabe o que está fazendo e geram o link.

#### Ligando a *Feeds* com o método `auto_discovery_link_tag`

O *helper* `auto_discovery_link_tag` monta HTML que a maioria dos navegadores e leitores de *feeds* conseguem usar para detectar a presenta de *feeds* RSS, Atom, ou JSON. Ele recebe o tipo de link (`:rss`, `:atom`, or `:json`), um *hash* de opções que são encaminhados para url_for, e um *hash* de opções para a *tag*:

```erb
<%= auto_discovery_link_tag(:rss, {action: "feed"},
  {title: "RSS Feed"}) %>
```

Há três opções de *tags* disponíveis para o método `auto_discovery_link_tag`:

* `:rel` especifica o valor `rel` no link. O valor padrão é "alternate".
* `:type` especifica um *MIME type* explícito. O Rails criará um *MIME type* apropriado automaticamente.
* `:title` especifica o título do link. O valor padrão é o valor definido em `:type` com letras maiúsculas, por exemplo, "ATOM" ou "RSS".

#### Ligando a Arquivos JavaScript com o Método `javascript_include_tag`

O *helper* `javascript_include_tag` retorna uma tag HTML `script` para cada fonte fornecida.

Se você está usando o Rails com a [*Asset Pipeline*](asset_pipeline.html) habilitada, este *helper* criará um link para `/assets/javascripts/` ao invés de `public/javascripts` que era usado em versões anteriores do Rails. Este link será disponibilizado pelo *asset pipeline*.

Um arquivo JavaScript dentro de uma aplicação ou *engine* Rails pode ir dentro de uma entre três possíveis pastas: `app/assets`, `lib/assets` ou `vendor/assets`. Estas pastas são explicadas com detalhes na seção [Organização de *Assets* no Guia de *Asset Pipeline*](asset_pipeline.html#asset-organization).

Você pode especificar um caminho completo relativo à raiz do documento, ou uma URL, se você preferir. Por exemplo, pra ligar a um arquivo JavaScript que está dentro de um diretório chamado `javascripts` dentro de`app/assets`, `lib/assets` ou `vendor/assets`, você faria isto:

```erb
<%= javascript_include_tag "main" %>
```

O Rails criará então uma tag `script` tag como esta:

```html
<script src='/assets/main.js'></script>
```

A requisição para este *asset* será então disponibilizada pela *gem* Sprockets.

Para incluir vários arquivos como `app/assets/javascripts/main.js` e `app/assets/javascripts/columns.js` ao mesmo tempo:

```erb
<%= javascript_include_tag "main", "columns" %>
```

Para incluir `app/assets/javascripts/main.js` e `app/assets/javascripts/photos/columns.js`:

```erb
<%= javascript_include_tag "main", "/photos/columns" %>
```

Para incluir `http://example.com/main.js`:

```erb
<%= javascript_include_tag "http://example.com/main.js" %>
```

#### Ligando a Arquivos CSS com o método `stylesheet_link_tag`

O *helper* `stylesheet_link_tag` retorna uma tag HTML `<link>` para cada fonte fornecida.

Se você está usando o Rails com a *"Asset Pipeline"* habilitada, este *helper* criará um link para `/assets/stylesheets/`. Este link então será processado pela *gem* Sprockets. Um arquivo de *stylesheet* pode ser armazenado em um de três endereços: `app/assets`, `lib/assets` ou `vendor/assets`.

Você pode especificar um caminho completo relativo à raiz do documento, ou uma URL. Por exemplo, para ligar a um arquivo de *stylesheet* que está dentro de um diretório chamado `stylesheets` dentro de `app/assets`, `lib/assets` ou `vendor/assets`, você faria isto:

```erb
<%= stylesheet_link_tag "main" %>
```

Para incluir `app/assets/stylesheets/main.css` e `app/assets/stylesheets/columns.css`:

```erb
<%= stylesheet_link_tag "main", "columns" %>
```

Para incluir `app/assets/stylesheets/main.css` e `app/assets/stylesheets/photos/columns.css`:

```erb
<%= stylesheet_link_tag "main", "photos/columns" %>
```

Para incluir `http://example.com/main.css`:

```erb
<%= stylesheet_link_tag "http://example.com/main.css" %>
```

Por padrão, o método `stylesheet_link_tag` cria links com `media="screen" rel="stylesheet"`. Você pode sobrescrever qualquer um destes padrões especificando uma opção apropriada (`:media`, `:rel`):

```erb
<%= stylesheet_link_tag "main_print", media: "print" %>
```

#### Ligando a  Imagens com o método `image_tag`

O *helper* `image_tag` monta uma tag `<img />` que aponta para o arquivo especificado. Por padrão, os arquivos são carregados a partir de `public/images`.

WARNING: Note que você deve especificar a extensão da imagem.

```erb
<%= image_tag "header.png" %>
```

Você pode fornecer um caminho para a imagem se preferir:

```erb
<%= image_tag "icons/delete.gif" %>
```

Você pode fornecer um *hash* de opções adicionais para o HTML:

```erb
<%= image_tag "icons/delete.gif", {height: 45} %>
```

Você pode fornecer um texto alternativo para a imagem que será utilizado se a pessoa usuária estiver com imagens desabilitadas no navegador. Se você não especificar um texto alternativo de forma explícita, o valor padrão será o nome do arquivo, com a inicial maiúscula e sem extensão. Por exemplo, estas duas imagens devolvem o mesmo código:

```erb
<%= image_tag "home.gif" %>
<%= image_tag "home.gif", alt: "Home" %>
```

Você também pode especificar uma tag *size* especial, no formato "{largura}x{altura}":

```erb
<%= image_tag "home.gif", size: "50x20" %>
```

Além da tag especial acima, você pode fornecer um *hash* final de opções HTML padrão, como `:class`, `:id` ou `:name`:

```erb
<%= image_tag "home.gif", alt: "Go Home",
                          id: "HomeImage",
                          class: "nav_bar" %>
```

#### Ligando a Vídeos com o método `video_tag`

O *helper* `video_tag` monta uma tag HTML 5 `<video>` apontando para o arquivo especificado. Por padrão, os arquivos são carregados a partir de `public/videos`.

```erb
<%= video_tag "movie.ogg" %>
```

Produz

```erb
<video src="/videos/movie.ogg" />
```

Como o método `image_tag`, você pode fornecer um caminho absoluto ou relativo ao diretório `public/videos`. Além disso você pode especificar a opção `size: "#{width}x#{height}"` assim como no método `image_tag`. Tags de vídeo também podem ter qualquer uma das opções HTML especificadas no fim do método (`id`, `class` et al).

O método `video_tag` também suporta todas as opções da tag HTML `<video>` através do *hash* de opções HTML, incluindo:

* `poster: "image_name.png"`, fornece uma imagem para colocar no lugar do vídeo antes de reproduzir.
* `autoplay: true`, inicia a reprodução do vídeo quando a página é carregada.
* `loop: true`, continua a reprodução do vídeo quando este chega no fim.
* `controls: true`, habilita controles fornecidos pelo navegador de forma que a pessoa usuária possa interagir com o vídeo.
* `autobuffer: true`, o vídeo será pré-carregado para a pessoa usuária quando a página carregar.

Você também pode especificar vários vídeos para reprodução consecutiva passando um *array* de vídeos para o método `video_tag`:

```erb
<%= video_tag ["trailer.ogg", "movie.ogg"] %>
```

Isto irá produzir:

```erb
<video>
  <source src="/videos/trailer.ogg">
  <source src="/videos/movie.ogg">
</video>
```

#### Ligando a Arquivos de Áudio com o método `audio_tag`

O *helper* `audio_tag` monta uma tag HTML 5 `<audio>` apontando para o arquivo especificado. Por padrão, os arquivos são carregados a partir de `public/audios`.

```erb
<%= audio_tag "music.mp3" %>
```

Você pode fornecer um caminho para o arquivo de áudio se preferir:

```erb
<%= audio_tag "music/first_song.mp3" %>
```

Você também pode fornecer um *hash* de opções adicionais, como `:id`, `:class` etc.

Como o método `video_tag`, o método `audio_tag` tem opções especiais:

* `autoplay: true`, inicia a reprodução do áudio quando a página é carregada.
* `controls: true`, habilita controles fornecidos pelo navegador para a pessoa usuária interagir com o áudio.
* `autobuffer: true`, o áudio será pré-carregado para a pessoa usuária quando a página carregar.

### Entendendo `yield`

Dentro do contexto de um *layout*, `yield` identifica uma seção onde o conteúdo da *view* deve ser inserido. A maneira mais simples de utilizar isto é colocar um único `yield`, dentro do qual todo o conteúdo da *view* renderizada no momento é inserido:

```html+erb
<html>
  <head>
  </head>
  <body>
  <%= yield %>
  </body>
</html>
```

Você também pode criar um *layout* com várias regiões com `yield`:

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

O *body* principal da *view* sempre manda o conteúdo para dentro do `yield` sem nome. Para direcionar o conteúdo para as tags `yield` com nome, usa-se o método `content_for`.

### Usando o Método `content_for`

O método `content_for` lhe permite inserir conteúdo dentro de um bloco `yield` com nome no seu *layout*. Por exmeplo, esta *view* funcionaria com o *layout* que você acabou de ver:

```html+erb
<% content_for :head do %>
  <title>A simple page</title>
<% end %>

<p>Hello, Rails!</p>
```

O resultado da renderização desta página dentro do *layout* fornecido seria este HTML:

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

O método `content_for` ajuda muito quando o seu *layout* contém regiões distintas como *sidebars* e rodapés que precisam receber blocos de conteúdo próprios. Ele também é útil para inserir tags que carregam JavaScript ou arquivos css dentro do cabeçalho de um *layout* que seria genérico em outro cenário.

### Usando *Partials*

Templates parciais - normalmente chamados de *"partials"* - são outro dispositivo para quebrar o processo de renderização em pedaços menores. Com uma *partial*, você pode mover o código para renderizar um pedaço específico de uma resposta para um arquivo próprio.

#### Nomeando *Partials*

Para renderizar uma *partial* como parte da *view*, usa-se o método `render` dentro da view:

```ruby
<%= render "menu" %>
```

Isto inclui o conteúdo de um arquivo chamado `_menu.html.erb` neste ponto dentro da view renderizada. Note o *underscore* inicial no nome do arquivo: *partials* recebem nomes com um *underscore* inicial para distingui-los de *views* regulares, mesmo sem usar esta notação em casos mais comuns. Isso continua sendo verdade mesmo quando você incluir uma *partial* de outro diretório:

```ruby
<%= render "shared/menu" %>
```

Este código puxará a *partial* de `app/views/shared/_menu`.

#### Usando *Partials* para Simplificar *Views*

Um jeito de usar *partials* é tratá-los como algo equivalente a sub-rotinas: como um jeito de mover detalhes fora da *view* de forma que você entenda o que está acontecendo de forma mais fácil. Por exemplo, você pode ter uma *view* que estava assim:

```erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
...

<%= render "shared/footer" %>
```

Aqui, os *partials* `_ad_banner.html.erb` e `_footer.html.erb` podem ter conteúdo que é compartilhado por muitas páginas na sua aplicação. Você não precisa ver os detalhes destas seções quando concentrar a atenção em uma página em particular.

Como em seções anteriores deste guia, o `yield` é uma ferramenta muito poderosa para fazer faxina nos seus *layouts*. Tenha em mente que isto é Ruby puro, então é possível usar isto quase em qualquer lugar. Por exemplo, nós podemos usar o `yield` para remover a duplicação das definições do *layout* de formulário para vários recursos similares:

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

TIP: Para conteúdo que é compartilhado por todas as páginas da sua aplicação, você pode usar *partials* diretamente dos *layouts*.

#### *Layouts* Parciais

Uma *partial* pode usar seu próprio arquivo, assim como uma *view* pode usar um *layout*. Por exemplo, você pode chamar uma *partial* assim:

```erb
<%= render partial: "link_area", layout: "graybar" %>
```

Isto procura por uma *partial* chamado `_link_area.html.erb` e o renderiza usando o *layout* `_graybar.html.erb`. Note que *layouts* para *partials* seguem a mesma nomenclatura de *underscore* inicial que *partials* comuns, e ficam no mesmo diretório que a *partial* ao qual pertencem (não é o diretório principal `layouts`).

Note também que é necessário especificar `:partial` de forma explícita quando passar opções adicionais como `:layout`.

#### Passando Variáveis Locais

Você também pode passar variáveis locais para os *partials*, tornando-os ainda mais poderosos e flexíveis. Por exemplo, você pode utilizar esta técnica para reduzir duplicação entre páginas *new* e *edit*, enquanto mantém um pouco de conteúdo distinto:

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

Mesmo com o mesma *partial* renderizado dentro das duas *views*, o *helper* `submit` retorna *"Create Zone"* para a ação *new* e *"Update Zone"* para a ação *edit*.

Para passar uma variável local para uma *partial* apenas em casos específicos usa-se `local_assigns`.

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

Desta forma é possível utilizar a *partial* sem necessidade de declarar todas as variáveis locais.

Toda *partial* também tem uma variável local com o mesmo nome da *partial* (sem o *underscore* inicial). Você pode passar um objeto para esta variável local por via da opção `:object`.

```erb
<%= render partial: "customer", object: @new_customer %>
```

Dentro da *partial* `customer`, a variável `customer` refere a `@new_customer` a partir da *view* superior.

Se você tem uma instância de um *model* para renderizar dentro de uma *partial*, você pode usar a sintaxe reduzida:

```erb
<%= render @customer %>
```

Presumindo que a variável de instância `@customer` contém uma instância do model `Customer`, isto utilizará `_customer.html.erb` para renderizá-la e passará a variável local `customer` dentro da *partial* que se refere à variável de instância `@customer` na *view* superior.

#### Renderizando Coleções

*Partials* são muito úteis para renderizar coleções. Quando você passa uma coleção para uma *partial* através da opção `:collection`, a *partial* será inserido uma vez para cada membro da coleção:

* `index.html.erb`

    ```html+erb
    <h1>Products</h1>
    <%= render partial: "product", collection: @products %>
    ```

* `_product.html.erb`

    ```html+erb
    <p>Product Name: <%= product.name %></p>
    ```

Quando uma *partial* é chamado com uma coleção pluralizada, então as instâncias individuais da *partial* tem acesso ao membro da coleção que é renderizado por via de uma variável nomeada com base na *partial*. Neste caso, a *partial* é `_product`, e dentro da *partial* `_product`, você pode referir a `product` para pegar a instância renderizada.

Há também uma sintaxe reduzida para isto. Presumindo question `@products` é uma coleção de instâncias `Product`, você pode simplesmente escrever isto dentro de `index.html.erb` para produzir o mesmo resultado:

```html+erb
<h1>Products</h1>
<%= render @products %>
```

O Rails determina o nome da *partial* a utilizar olhando para o nome do *model* na coleção. Aliás, você pode até criar uma coleção heterogênea e fazer a renderização deste jeito, e o Rails escolherá a *partial* apropriado para cada membro da coleção:

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

Neste caso, o Rails utilizará os *partials* de cliente ou empregado nas situações apropriadas para cada membro da coleção.

Caso a coleção esteja vazia, `render` retornará *nil*, então não deve haver dificuldades para fornecer conteúdo alternativo.

```html+erb
<h1>Products</h1>
<%= render(@products) || "There are no products available." %>
```

#### Variáveis Locais

Para usar uma variável local personalizada dentro da *partial*, especifique a opção `:as` na chamada para a *partial*:

```erb
<%= render partial: "product", collection: @products, as: :item %>
```

Com esta mudança, você pode acessar uma instância da coleção `@products` como a variável local `item` dentro da *partial*.

Você também pode passar variáveis locais arbitrárias para qualquer *partial* que você renderizar com a opção `locals: {}`:

```erb
<%= render partial: "product", collection: @products,
           as: :item, locals: {title: "Products Page"} %>
```

Neste caso, a *partial* terá acesso à variável local `title` com o valor *"Products Page"*.

TIP: O Rails também cria uma variável de contagem disponível dentro de uma *partial* chamado pela coleção, que recebe um nome com base no título da *partial* seguido de `_counter`. Por exemplo, ao renderizar a coleção `@products` a *partial* `_product.html.erb` pode acessar a variável `product_counter` que registra o número de vezes que a *partial* foi renderizado dentro da *view* em questão. Note que isto também se aplica para quando o nome da *partial* sofre alterações através da opção `as:`. Por exemplo, a variável de contagem para o código acima seria `item_counter`.

Você também pode especificar um segunda *partial* para renderizar entre instâncias de uma *partial* principal usando a opção `:spacer_template`:

#### *Spacer Templates*

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

O Rails irá renderizar a *partial* `_product_ruler` (sem dados encaminhados pra ele) entre cada par de *partials* `_product`.

#### *Layouts* Parciais de Coleção

É possível usar a opção `:layout` quando renderizar coleções:

```erb
<%= render partial: "product", collection: @products, layout: "special_layout" %>
```

O *layout* será renderizado junto com a *partial* para cada item da coleção. As variáveis de objeto atual e *object_counter* ficam disponíveis no *layout* também, da mesma forma que ficam dentro da *partial*.

### Usando *Layouts* Aninhados

Pode ser que sua aplicação necessite de um *layout* que seja ligeiramente diferente do *layout* da aplicação para dar suporte a um *controller* em particular. Ao invés de repetir o *layout* principal e editá-lo, é possível fazer isso através de *layouts* aninhados (algumas vezes chamados de *sub-templates*). Segue um exemplo:

Suponha que você tem este *layout* de `ApplicationController`:

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

Nas páginas geradas pelo `NewsController`, você quer esconder o menu do topo e colocar um menu à direita:

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

É isto. A view *News* irá utilizar o novo *layout*, com um menu no topo e com um menu novo à direita dentro da *div* "content".

Há vários jeitos de conseguir resultados similares com esquemas diferentes de *sub-templates* através desta técnica. Note que não há limite no nível de aninhamento. É possível utilizar o método `ActionView::render` via `render template: 'layouts/news'` para criar um novo *layout* com base no *layout* News. Se você tem certeza que não criará outros templates a partir do *layout* `News`, você pode substituir o `content_for?(:news_content) ? yield(:news_content) : yield` com simplesmente `yield`.
