**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Rotas do Rails de Fora pra Dentro
=================================

Esse guia cobre os recursos de roteamento que os usuários podem utilizar no Rails.

Após ler esse guia, você saberá:

* Como interpretar o código em `config/routes.rb`.
* Como construir suas próprias rotas, seja usando o formato preferido de
  `resources` ou o método `match`.
* Como declarar parâmetros de rota, que são passados para ações do _controller_.
* Como criar automaticamente caminhos e URLs usando _helpers_ de rota.
* Técnicas avançadas como criar restrições e montar _endpoints Rack_.

--------------------------------------------------------------------------------

O Propósito do Roteador do Rails
-------------------------------

O roteador do Rails organiza URLs e as direcionam para uma ação de um
_controller_ ou de um aplicativo _Rack_. Também pode gerar caminhos e URLs,
evitando a necessidade de codificar sequências de caracteres em suas
visualizações.

### Conectando URLs ao código

Quando sua aplicação Rails recebe uma requisição para:

```
GET /patients/17
```

ela solicita ao roteador que corresponda com uma ação do _controller_.
Se a primeira rota correspondente for:

```ruby
get '/patients/:id', to: 'patients#show'
```

a requisição é direcionada para o _controller_ `patients` na ação `show`
com `{ id: '17' }` em `params`.

NOTE: O Rails usa _snake_case_ para nomes de _controller_ no roteamento, se você
tem um _controller_ com várias palavras como `MonsterTrucksController`, você
deve usar `monster_trucks#show`, por exemplo.

### Gerando Caminhos e URLs a partir do código

Você também pode gerar caminhos e URLs. Se a rota acima for modificada para ser:

```ruby
get '/patients/:id', to: 'patients#show', as: 'patient'
```

e sua aplicação contém esse código no _controller_:

```ruby
@patient = Patient.find(params[:id])
```
e isso na _view_ correspondente:

```erb
<%= link_to 'Patient Record', patient_path(@patient) %>
```

então seu roteador irá gerar o caminho `/patients/17`. Isso reduz a fragilidade
da sua _view_ e faz seu código mais simples de entender. Observe que o _id_ não
não precisa ser especificado no _helper_ da rota.

### Configurando o Roteador do Rails

As rotas para sua aplicação ou _engine_ estão dentro do arquivo `config/routes.rb`
e tipicamente se parecem com isso:

```ruby
Rails.application.routes.draw do
  resources :brands, only: [:index, :show] do
    resources :products, only: [:index, :show]
  end

  resource :basket, only: [:show, :update, :destroy]

  resolve("Basket") { route_for(:basket) }
end
```

Como isso é um arquivo padrão do Ruby você pode utilizar de todos os seus recursos
para te ajudar a definir suas rotas, porém tenha cautela com nomes de variáveis
já que ela pode conflitar com os métodos da [DSL](https://pt.wikipedia.org/wiki/Linguagem_de_dom%C3%ADnio_espec%C3%ADfico) do roteador.

NOTE: O bloco `Rails.application.routes.draw do ... end` que encapsula suas
definições de rotas é necessário para estabelecer o escopo do roteador da DSL e não
deve ser deletado.

Roteando _Resources_: O padrão do Rails
-----------------------------------

O roteamento de _resources_ permite que você rapidamente declare todas as rotas
comuns para um _controller_. Em contrapartida a declarar cada uma das rotas
das _actions_ `index`, `show`, `new`, `edit`, `create`, `update` e `destroy`,
uma rota de _resources_ declara todas elas em uma única linha de código.

### _Resources_ na Web

Navegadores solicitam páginas do Rails através de uma URL usando um método HTTP
específico, como `GET`,` POST`, `PATCH`,` PUT` e `DELETE`. Cada método é uma
solicitação para executar uma operação no recurso. Uma rota de recurso mapeia
uma série de solicitações relacionadas a _actions_ em um único _controller_.

Quando sua aplicação Rails recebe uma requisição para:

```
DELETE /photos/17
```

ela pede ao roteador para enviar esta requisição para a _action_ no seu
respectivo _controller_. Se a primeira rota encontrada for:

```ruby
resources :photos
```

O Rails enviará esta requisição para a _action_ `destroy` no _controller_
`photos` com `{ id: 17 }` no `params`

### CRUD, Verbos, e _Actions_

No Rails, uma rota de _resources_ fornece um mapeamento entre verbos HTTP e URLs para
_actions_ do _controller_. Por convenção, cada ação também é mapeada para uma
operação específica do CRUD em um banco de dados. Uma única entrada no arquivo
de roteamento, como:

```ruby
resources :photos
```

cria sete rotas diferentes rotas em sua aplicação, todas mapeando para o
_controller_ `Photos`:

| HTTP Verb | Path             | Controller#Action | Usado para                                          |
| --------- | ---------------- | ----------------- | --------------------------------------------------- |
| GET       | /photos          | photos#index      | mostra uma lista de todas as fotos                  |
| GET       | /photos/new      | photos#new        | retorna um formulário HTML para criar uma nova foto |
| POST      | /photos          | photos#create     | cria uma nova foto                                  |
| GET       | /photos/:id      | photos#show       | mostra uma foto específica                          |
| GET       | /photos/:id/edit | photos#edit       | retorna um formulário HTML para editar uma foto     |
| PATCH/PUT | /photos/:id      | photos#update     | atualiza uma foto específica                        |
| DELETE    | /photos/:id      | photos#destroy    | deleta uma foto específica                          |

NOTE: Por conta do roteador utilizar os verbos HTTP e a URL para corresponder as requisições de entrada, quatro URLs equivalem a sete _actions_ diferentes.

NOTE: Rotas de aplicações Rails são combinadas na ordem que são especificadas, portanto, se você tem `resources :photos` acima de `get 'photos/poll'`, a rota da _action_ `show` para a linha do `resources` será correspondida antes da linha `get`. Para resolver este problema, mova a linha `get` **acima** da linha `resources`, assim a rota será equiparada primeiro.

### Helpers _Path_ e _URL_

Criando uma rota de _resource_ vai expor um número de _helpers_ para os _controllers_ em sua aplicação. No caso de `resources :photos`:

* `photos_path` retorna `/photos`
* `new_photo_path` retorna `/photos/new`
* `edit_photo_path(:id)` retorna `/photos/:id/edit` (por exemplo, `edit_photo_path(10)` retorna `/photos/10/edit`)
* `photo_path(:id)` retorna `/photos/:id` (por exemplo, `photo_path(10)` retorna `/photos/10`)

Cada um desses _helpers_ tem um _helper_ `_url`  (assim como `photos_url`) que retorna o mesmo _path_ prefixado com o _host_ atual, porta e o prefixo do _path_.

### Definindo Multiplos _Resources_ ao Mesmo tempo

Se você precisa criar rotas para mais de um _resource_, você pode salvar um pouco de digitação definindo todos eles em uma unica chamada para `resources`:

```ruby
resources :photos, :books, :videos
```

Isto funciona exatamente igual a:

```ruby
resources :photos
resources :books
resources :videos
```

### _Resources_ no Singular

Algumas vezes você tem um _resource_ que clientes sempre veem sem referenciar um ID. Por exemplo, você gostaria que `/profile` sempre mostre o perfil do usuário que esta autenticado. Neste caso, você pode usar um _resource_ no singular para  mapear `/profile` (em vez de `/profile/:id`) para a _action_ `show`:

```ruby
get 'profile', to: 'users#show'
```

Passando uma `String` para `to:` ira esperar um formato `controller#action`. Quando usamos um `Symbol`, a opção `to:` deveria ser trocada por `action:`. Quando usamos uma `String` sem um `#`, a opção `to:` deveria ser trocada por `controller:`:

```ruby
get 'profile', action: :show, controller: 'users'
```

Esta rota _resourceful_:

```ruby
resource :geocoder
resolve('Geocoder') { [:geocoder] }
```

cria seis rotas diferentes em sua aplicação, todas mapeando para o _controller_ `Geocoders`:

| HTTP Verb | Path           | Controller#Action | Usado para                                        |
| --------- | -------------- | ----------------- | ------------------------------------------------- |
| GET       | /geocoder/new  | geocoders#new     | retorna um formulário HTML para criar o geocoder  |
| POST      | /geocoder      | geocoders#create  | cria o novo geocoder                              |
| GET       | /geocoder      | geocoders#show    | mostra o único geocoder _resource_                |
| GET       | /geocoder/edit | geocoders#edit    | retorna um formulário HTML para editar o geocoder |
| PATCH/PUT | /geocoder      | geocoders#update  | atualiza o único geocoder _resource_              |
| DELETE    | /geocoder      | geocoders#destroy | deleta o geocoder _resource_                      |

NOTE: Como você pode querer usar o mesmo _controller_ para uma _singular route_ (`/account`) e uma _plural route_ (`/accounts /45`), os _singular resources_ são mapeados para os _plural controllers_. Assim, por exemplo, `resource: photo` e` resources: photos` criam rotas singular e plural que são mapeadas para o mesmo controlador (`PhotosController`).

Uma rota _resourceful_ singular gera estes _helpers_:

* `new_geocoder_path` returns `/geocoder/new`
* `edit_geocoder_path` returns `/geocoder/edit`
* `geocoder_path` returns `/geocoder`

Assim como com _resources_ no plural, os mesmos _helpers_ que terminam com `_url` tambem vão incluir o _host_, porta, e o prefixo do _path_.

### Controller Namespaces e Routing

Você pode querer organizar grupos de _controllers_ em um _namespace_. Mais comumente, você pode querer agrupar _controllers_ administrativos sob um _namespace_ `Admin::`. Você deverá por esses _controllers_ sob o diretório `app/controllers/admin`, e você pode agrupá-los em um _router_:

```ruby
namespace :admin do
  resources :articles, :comments
end
```

Isto criará um número de rotas para cada _controller_ de `articles` e `comments`. Para `Admin::ArticlesController`, o Rails vai criar:

| HTTP Verb | Path                     | Controller#Action      | Named Route Helper           |
| --------- | ------------------------ | ---------------------- | ---------------------------- |
| GET       | /admin/articles          | admin/articles#index   | admin_articles_path          |
| GET       | /admin/articles/new      | admin/articles#new     | new_admin_article_path       |
| POST      | /admin/articles          | admin/articles#create  | admin_articles_path          |
| GET       | /admin/articles/:id      | admin/articles#show    | admin_article_path(:id)      |
| GET       | /admin/articles/:id/edit | admin/articles#edit    | edit_admin_article_path(:id) |
| PATCH/PUT | /admin/articles/:id      | admin/articles#update  | admin_article_path(:id)      |
| DELETE    | /admin/articles/:id      | admin/articles#destroy | admin_article_path(:id)      |

Se você quiser rotear `/articles` (sem o prefixo `/admin`) para `Admin::ArticlesController`, você poderia usar:

```ruby
scope module: 'admin' do
  resources :articles, :comments
end
```

ou, para um único caso:

```ruby
resources :articles, module: 'admin'
```

Se você quiser rotear `/admin/articles` para `ArticlesController` (Sem o prefixo do modulo `Admin::`), você poderia usar:

```ruby
scope '/admin' do
  resources :articles, :comments
end
```
ou, para um unico caso:

```ruby
resources :articles, path: '/admin/articles'
```

Em cada um desses casos, a rota nomeada continua a mesma, como se você não tivesse usado `scope`. No último exemplo, os _paths_ seguintes mapeiam para `ArticlesController`:

| HTTP Verb | Path                     | Controller#Action    | Named Route Helper     |
| --------- | ------------------------ | -------------------- | ---------------------- |
| GET       | /admin/articles          | articles#index       | articles_path          |
| GET       | /admin/articles/new      | articles#new         | new_article_path       |
| POST      | /admin/articles          | articles#create      | articles_path          |
| GET       | /admin/articles/:id      | articles#show        | article_path(:id)      |
| GET       | /admin/articles/:id/edit | articles#edit        | edit_article_path(:id) |
| PATCH/PUT | /admin/articles/:id      | articles#update      | article_path(:id)      |
| DELETE    | /admin/articles/:id      | articles#destroy     | article_path(:id)      |

TIP: Se você precisar usar um _namespace_ de _controller_ diferente dentro de um bloco `namespace` você pode especificar um _path_ absoluto de _controller_, e.g: `get '/foo', to: '/foo#index'`.

### Nested Resources (Recursos Aninhados)

É comum encontrarmos _resources_ que são "filhos" de outros. Por exemplo, supondo que sua aplicação tem esses _models_:

```ruby
class Magazine < ApplicationRecord
  has_many :ads
end

class Ad < ApplicationRecord
  belongs_to :magazine
end
```

_Nested routes_ (rotas aninhadas) permitem que você capture este relacionamento no seu roteamento. Neste caso, você poderia incluir esta delcaração de rota:

```ruby
resources :magazines do
  resources :ads
end
```

Em adição das rotas para _magazines_, esta declaração também adicionará rotas de _ads_ para um `AdsContriller`. As URLs de _ad_ vão precisar de um _magazine_:

| HTTP Verb | Path                                 | Controller#Action | Used for                                                                   |
| --------- | ------------------------------------ | ----------------- | -------------------------------------------------------------------------- |
| GET       | /magazines/:magazine_id/ads          | ads#index         | display a list of all ads for a specific magazine                          |
| GET       | /magazines/:magazine_id/ads/new      | ads#new           | return an HTML form for creating a new ad belonging to a specific magazine |
| POST      | /magazines/:magazine_id/ads          | ads#create        | create a new ad belonging to a specific magazine                           |
| GET       | /magazines/:magazine_id/ads/:id      | ads#show          | display a specific ad belonging to a specific magazine                     |
| GET       | /magazines/:magazine_id/ads/:id/edit | ads#edit          | return an HTML form for editing an ad belonging to a specific magazine     |
| PATCH/PUT | /magazines/:magazine_id/ads/:id      | ads#update        | update a specific ad belonging to a specific magazine                      |
| DELETE    | /magazines/:magazine_id/ads/:id      | ads#destroy       | delete a specific ad belonging to a specific magazine                      |

Isto vai tambem criar _routing helpers_ como `magazine_ads_url` e `edit_magazine_ad_path`. Esses _helpers_ pegam uma instância de _Magazine_ como o primeiro parametro (`magazine_ads_url(@magazine)`).

#### Limites para o Aninhamento

Você pode aninhar _resources_ entre outros _resources_ aninhados se você desejar. Por exemplo:

```ruby
resources :publishers do
  resources :magazines do
    resources :photos
  end
end
```

_Resources_ profundamente aninhados ficam confusos. Neste caso, por exemplo, a aplicação iria reconhecer _paths_ como:

```
/publishers/1/magazines/2/photos/3
```

O _helper_ correspondente a essa rota seria `publisher_magazine_photo_url`, sendo necessário especificar os objetos de todos os três níveis. De fato, esta situação é confusa o bastante que um [artigo](http://weblog.jamisbuck.org/2007/2/5/nesting-resources) escrito por Jamis Buck propõe uma regra de ouro para um bom design no Rails:

TIP: _Resources_ Não devem nunca ser aninhados mais de um nível de profundidade.

#### Shallow Nesting (Aninhamento raso)

Uma maneira de evitar um aninhamento profundo (como recomendado acima) é gerar uma coleção de _actions_ _scoped_ abaixo de um pai, assim para ter uma sensação de hierarquia, mas não aninhar as _actions_ do membro. Em outras palavras. para apenas construir _routes_ com o mínimo de informação para identificar unicamente o _recurso_, como isto:

```ruby
resources :articles do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

Essa idéia encontra um equilíbrio entre rotas descritivas e aninhamento profundo. Existe uma sintaxe abreviada para conseguir exatamente isso, via a opção `:shallow`:

```ruby
resources :articles do
  resources :comments, shallow: true
end
```

Isso vai gerar as mesmas rotas do primeiro exemplo, Você pode também especificar a opção `:shallow` no seu recurso pai, em cada caso todos os _resources_ aninhados serão rasos:

```ruby
resources :articles, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```
O metodo `shallow` do DSL cria um _scope_ em que todos os aninhamentos são rasos. Isso gera as mesmas rotas que o exemplo anterior:

```ruby
shallow do
  resources :articles do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```

Existem duas opções no `scope` para customizar _shallow routes_. `:shallow_path` prefixa seus _paths_ membros com o parametro especificado:

```ruby
scope shallow_path: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

O _resource_ _comments_ aqui terá gerado as seguintes rotas para sí:

| HTTP Verb | Path                                         | Controller#Action | Named Route Helper       |
| --------- | -------------------------------------------- | ----------------- | ------------------------ |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path    |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path    |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path |
| GET       | /sekret/comments/:id/edit(.:format)          | comments#edit     | edit_comment_path        |
| GET       | /sekret/comments/:id(.:format)               | comments#show     | comment_path             |
| PATCH/PUT | /sekret/comments/:id(.:format)               | comments#update   | comment_path             |
| DELETE    | /sekret/comments/:id(.:format)               | comments#destroy  | comment_path             |

A opção `:shallow_prefix` adiciona o parÂmetro especificado para os _helpers_ da rota nomeada:

```ruby
scope shallow_prefix: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

O _resource_ _comments_ aqui terá gerado as seguintes rotas para si:

| HTTP Verb | Path                                         | Controller#Action | Named Route Helper          |
| --------- | -------------------------------------------- | ----------------- | --------------------------- |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path       |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path       |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path    |
| GET       | /comments/:id/edit(.:format)                 | comments#edit     | edit_sekret_comment_path    |
| GET       | /comments/:id(.:format)                      | comments#show     | sekret_comment_path         |
| PATCH/PUT | /comments/:id(.:format)                      | comments#update   | sekret_comment_path         |
| DELETE    | /comments/:id(.:format)                      | comments#destroy  | sekret_comment_path         |

### Roteamento com método concerns

Roteamento com método concerns permitem você declarar rotas comuns que podem ser reutilizadas dentro de outros _resources_ e rotas. Para definier um _concern_:

```ruby
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

Estes _concerns_ podem ser usados em recursos para evitar duplicação de códigos e compartilhar o mesmo comportamento por entre as rotas:

```ruby
resources :messages, concerns: :commentable

resources :articles, concerns: [:commentable, :image_attachable]
```

O exemplo acima é equivalente a:

```ruby
resources :messages do
  resources :comments
end

resources :articles do
  resources :comments
  resources :images, only: :index
end
```

Além disso você pode usá-los em qualquer lugar que você quiser dentro das rotas, por exemplo, em uma chamada `scope` ou `namespace`:

```ruby
namespace :articles do
  concerns :commentable
end
```

### Criando Paths e URLs De Objetos

Além de usarmos os _helpers_ de roteamento, o Rails pode também criar _paths_ e _URLs_ de um _array_ de parâmetros. Por exemplo, imagine que você tem este grupo de rotas:

```ruby
resources :magazines do
  resources :ads
end
```

Enquanto estiver usando `magazine_ad_path`, você pode passar as instâncias de `Magazine` e `Ad` em contrapartida a IDs numéricos:

```erb
<%= link_to 'Ad details', magazine_ad_path(@magazine, @ad) %>
```

Você pode também usar `url_for` com um grupo de objetos, e o Rails vai automaticamente determinar qual rota você quer:

```erb
<%= link_to 'Ad details', url_for([@magazine, @ad]) %>
```

Neste caso, o Rails verá que `@magazine` é um `Magazine` e `@ad` é um `Ad` e vai portanto usar o _helper_ `magazine_ad_path`. em _helpers_ como `link_to`, você pode especificar apenas o objeto no lugar da chamada `url_for` inteira:

```erb
<%= link_to 'Ad details', [@magazine, @ad] %>
```

Se você queria apenas o link da magazine:

```erb
<%= link_to 'Magazine details', @magazine %>
```

Para outras _actions_, você apenas precisa inserir o nome desta _action_ como o primeiro elemento deste _array_:

```erb
<%= link_to 'Edit Ad', [:edit, @magazine, @ad] %>
```

Isto permite você tratar instâncias de seus _models_ como URLs, e é uma vantagem chave de usar o estilo _resourceful_.

### Adicionando mais RESTful Actions

Você não esta limitado as sete rotas que o _RESTful routing_ cria por padrão. Se você quiser, pode criar rotas adicionais  que aplicam a uma coleção ou membros individuais da coleção.

#### Adicionando Rotas de Membros

Para adicionar uma rota para um membro, apenas adicione um bloco `member` em um bloco de _resource_:

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```
Isso vai reconhecer `/photos/1/preview` com GET, e rotear para a _action_ `preview` de `PhotosController`, com o valor do _resource id_  passado em `params[:id]`. Isso vai tambem criar os _helpers_ `preview_photo_url` e `preview_photo_path`.

Dentro do bloco de rotas para membros, cada nome de rota especifica o verbo HTTP
que vai ser reconhecido. Você pode usar `get`, `patch`, `put`, `post` ou
`delete` aqui. Se você não tiver múltiplas rotas para membros, você pode também
passar `:on` para a rota, eliminando o bloco:

```ruby
resources :photos do
  get 'preview', on: :member
end
```

Você pode deixar fora a opção `:on`, isso vai criar o mesmo _member route_ exceto que o valor do _resource id_ estará disponível em `params[:photo_id]` ao invés de `params[:id]`. _Helpers_ de rota tambem serão renomeados de `preview_photo_url` para `photo_preview_url` e `photo_preview_path`.

#### Adicionando Collection Routes

Para adicionar uma rota para uma coleção:

```ruby
resources :photos do
  collection do
    get 'search'
  end
end
```

Isto vai permitir que o Rails reconheça _paths_ como `/photos/search` com GET, e a rota para a _action_ `search` do `PhotosController`. Isto também criará os _helpers_ `search_photos_url` e `search_photos_path`.

Assim como em _member routes_, você pode passar `:on` para uma rota:

```ruby
resources :photos do
  get 'search', on: :collection
end
```

NOTE: Se vocês estão definindo rotas de _resource_ adicionais com um _symbol_ como o primeiro argumento posicional, tenha em mente que não é igual a usar uma _string_. _Symbols_ inferem _actions_ do _controller_ enquanto _strings_ inferem _paths_.

#### Adicionando Rotas para Novas Actions Adicionais

Para adicionar uma _action_ alternativa nova usando o atalho `:on`:

```ruby
resources :comments do
  get 'preview', on: :new
end
```

Isto vai permitir que o Rails reconheça _paths_ como `/comments/new/preview` com GET, e rotear para a _action_ `preview` do `CommentesController`. Isto também vai criar os _helpers_ `preview_new_comment_url` e `preview_new_comment_path`.

TIP: Se você se encontrar adicionando muitas _actions_ extras para uma rota _resourceful_, é um bom momento para perguntar a si mesmo se você está mascarando a presença de outro _resource_.

Non-Resourceful Routes
----------------------

In addition to resource routing, Rails has powerful support for routing arbitrary URLs to actions. Here, you don't get groups of routes automatically generated by resourceful routing. Instead, you set up each route separately within your application.

While you should usually use resourceful routing, there are still many places where the simpler routing is more appropriate. There's no need to try to shoehorn every last piece of your application into a resourceful framework if that's not a good fit.

In particular, simple routing makes it very easy to map legacy URLs to new Rails actions.

### Bound Parameters

When you set up a regular route, you supply a series of symbols that Rails maps to parts of an incoming HTTP request. For example, consider this route:

```ruby
get 'photos(/:id)', to: 'photos#display'
```

If an incoming request of `/photos/1` is processed by this route (because it hasn't matched any previous route in the file), then the result will be to invoke the `display` action of the `PhotosController`, and to make the final parameter `"1"` available as `params[:id]`. This route will also route the incoming request of `/photos` to `PhotosController#display`, since `:id` is an optional parameter, denoted by parentheses.

### Dynamic Segments

You can set up as many dynamic segments within a regular route as you like. Any segment will be available to the action as part of `params`. If you set up this route:

```ruby
get 'photos/:id/:user_id', to: 'photos#show'
```

An incoming path of `/photos/1/2` will be dispatched to the `show` action of the `PhotosController`. `params[:id]` will be `"1"`, and `params[:user_id]` will be `"2"`.

TIP: By default, dynamic segments don't accept dots - this is because the dot is used as a separator for formatted routes. If you need to use a dot within a dynamic segment, add a constraint that overrides this – for example, `id: /[^\/]+/` allows anything except a slash.

### Static Segments

You can specify static segments when creating a route by not prepending a colon to a fragment:

```ruby
get 'photos/:id/with_user/:user_id', to: 'photos#show'
```

This route would respond to paths such as `/photos/1/with_user/2`. In this case, `params` would be `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### The Query String

The `params` will also include any parameters from the query string. For example, with this route:

```ruby
get 'photos/:id', to: 'photos#show'
```

An incoming path of `/photos/1?user_id=2` will be dispatched to the `show` action of the `Photos` controller. `params` will be `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### Defining Defaults

You can define defaults in a route by supplying a hash for the `:defaults` option. This even applies to parameters that you do not specify as dynamic segments. For example:

```ruby
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

Rails would match `photos/12` to the `show` action of `PhotosController`, and set `params[:format]` to `"jpg"`.

You can also use `defaults` in a block format to define the defaults for multiple items:

```ruby
defaults format: :json do
  resources :photos
end
```

NOTE: You cannot override defaults via query parameters - this is for security reasons. The only defaults that can be overridden are dynamic segments via substitution in the URL path.

### Naming Routes

You can specify a name for any route using the `:as` option:

```ruby
get 'exit', to: 'sessions#destroy', as: :logout
```

This will create `logout_path` and `logout_url` as named route helpers in your application. Calling `logout_path` will return `/exit`

You can also use this to override routing methods defined by resources, like this:

```ruby
get ':username', to: 'users#show', as: :user
```

This will define a `user_path` method that will be available in controllers, helpers, and views that will go to a route such as `/bob`. Inside the `show` action of `UsersController`, `params[:username]` will contain the username for the user. Change `:username` in the route definition if you do not want your parameter name to be `:username`.

### HTTP Verb Constraints

In general, you should use the `get`, `post`, `put`, `patch`  and `delete` methods to constrain a route to a particular verb. You can use the `match` method with the `:via` option to match multiple verbs at once:

```ruby
match 'photos', to: 'photos#show', via: [:get, :post]
```

You can match all verbs to a particular route using `via: :all`:

```ruby
match 'photos', to: 'photos#show', via: :all
```

NOTE: Routing both `GET` and `POST` requests to a single action has security implications. In general, you should avoid routing all verbs to an action unless you have a good reason to.

NOTE: `GET` in Rails won't check for CSRF token. You should never write to the database from `GET` requests, for more information see the [security guide](security.html#csrf-countermeasures) on CSRF countermeasures.

### Segment Constraints

You can use the `:constraints` option to enforce a format for a dynamic segment:

```ruby
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

This route would match paths such as `/photos/A12345`, but not `/photos/893`. You can more succinctly express the same route this way:

```ruby
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`:constraints` takes regular expressions with the restriction that regexp anchors can't be used. For example, the following route will not work:

```ruby
get '/:id', to: 'articles#show', constraints: { id: /^\d/ }
```

However, note that you don't need to use anchors because all routes are anchored at the start.

For example, the following routes would allow for `articles` with `to_param` values like `1-hello-world` that always begin with a number and `users` with `to_param` values like `david` that never begin with a number to share the root namespace:

```ruby
get '/:id', to: 'articles#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```

### Request-Based Constraints

You can also constrain a route based on any method on the [Request object](action_controller_overview.html#the-request-object) that returns a `String`.

You specify a request-based constraint the same way that you specify a segment constraint:

```ruby
get 'photos', to: 'photos#index', constraints: { subdomain: 'admin' }
```

You can also specify constraints in a block form:

```ruby
namespace :admin do
  constraints subdomain: 'admin' do
    resources :photos
  end
end
```

NOTE: Request constraints work by calling a method on the [Request object](action_controller_overview.html#the-request-object) with the same name as the hash key and then compare the return value with the hash value. Therefore, constraint values should match the corresponding Request object method return type. For example: `constraints: { subdomain: 'api' }` will match an `api` subdomain as expected, however using a symbol `constraints: { subdomain: :api }` will not, because `request.subdomain` returns `'api'` as a String.

NOTE: There is an exception for the `format` constraint: while it's a method on the Request object, it's also an implicit optional parameter on every path. Segment constraints take precedence and the `format` constraint is only applied as such when enforced through a hash. For example, `get 'foo', constraints: { format: 'json' }` will match `GET  /foo` because the format is optional by default. However, you can [use a lambda](#advanced-constraints) like in `get 'foo', constraints: lambda { |req| req.format == :json }` and the route will only match explicit JSON requests.

### Advanced Constraints

If you have a more advanced constraint, you can provide an object that responds to `matches?` that Rails should use. Let's say you wanted to route all users on a restricted list to the `RestrictedListController`. You could do:

```ruby
class RestrictedListConstraint
  def initialize
    @ips = RestrictedList.retrieve_ips
  end

  def matches?(request)
    @ips.include?(request.remote_ip)
  end
end

Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: RestrictedListConstraint.new
end
```

You can also specify constraints as a lambda:

```ruby
Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }
end
```

Both the `matches?` method and the lambda gets the `request` object as an argument.

### Route Globbing and Wildcard Segments

Route globbing is a way to specify that a particular parameter should be matched to all the remaining parts of a route. For example:

```ruby
get 'photos/*other', to: 'photos#unknown'
```

This route would match `photos/12` or `/photos/long/path/to/12`, setting `params[:other]` to `"12"` or `"long/path/to/12"`. The fragments prefixed with a star are called "wildcard segments".

Wildcard segments can occur anywhere in a route. For example:

```ruby
get 'books/*section/:title', to: 'books#show'
```

would match `books/some/section/last-words-a-memoir` with `params[:section]` equals `'some/section'`, and `params[:title]` equals `'last-words-a-memoir'`.

Technically, a route can have even more than one wildcard segment. The matcher assigns segments to parameters in an intuitive way. For example:

```ruby
get '*a/foo/*b', to: 'test#index'
```

would match `zoo/woo/foo/bar/baz` with `params[:a]` equals `'zoo/woo'`, and `params[:b]` equals `'bar/baz'`.

NOTE: By requesting `'/foo/bar.json'`, your `params[:pages]` will be equal to `'foo/bar'` with the request format of JSON. If you want the old 3.0.x behavior back, you could supply `format: false` like this:

```ruby
get '*pages', to: 'pages#show', format: false
```

NOTE: If you want to make the format segment mandatory, so it cannot be omitted, you can supply `format: true` like this:

```ruby
get '*pages', to: 'pages#show', format: true
```

### Redirection

You can redirect any path to another path using the `redirect` helper in your router:

```ruby
get '/stories', to: redirect('/articles')
```

You can also reuse dynamic segments from the match in the path to redirect to:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}')
```

You can also provide a block to redirect, which receives the symbolized path parameters and the request object:

```ruby
get '/stories/:name', to: redirect { |path_params, req| "/articles/#{path_params[:name].pluralize}" }
get '/stories', to: redirect { |path_params, req| "/articles/#{req.subdomain}" }
```

Please note that default redirection is a 301 "Moved Permanently" redirect. Keep in mind that some web browsers or proxy servers will cache this type of redirect, making the old page inaccessible. You can use the `:status` option to change the response status:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}', status: 302)
```

In all of these cases, if you don't provide the leading host (`http://www.example.com`), Rails will take those details from the current request.

### Routing to Rack Applications

Instead of a String like `'articles#index'`, which corresponds to the `index` action in the `ArticlesController`, you can specify any [Rack application](rails_on_rack.html) as the endpoint for a matcher:

```ruby
match '/application.js', to: MyRackApp, via: :all
```

As long as `MyRackApp` responds to `call` and returns a `[status, headers, body]`, the router won't know the difference between the Rack application and an action. This is an appropriate use of `via: :all`, as you will want to allow your Rack application to handle all verbs as it considers appropriate.

NOTE: For the curious, `'articles#index'` actually expands out to `ArticlesController.action(:index)`, which returns a valid Rack application.

If you specify a Rack application as the endpoint for a matcher, remember that
the route will be unchanged in the receiving application. With the following
route your Rack application should expect the route to be `/admin`:

```ruby
match '/admin', to: AdminApp, via: :all
```

If you would prefer to have your Rack application receive requests at the root
path instead, use `mount`:

```ruby
mount AdminApp, at: '/admin'
```

### Using `root`

You can specify what Rails should route `'/'` to with the `root` method:

```ruby
root to: 'pages#main'
root 'pages#main' # shortcut for the above
```

You should put the `root` route at the top of the file, because it is the most popular route and should be matched first.

NOTE: The `root` route only routes `GET` requests to the action.

You can also use root inside namespaces and scopes as well. For example:

```ruby
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```

### Unicode character routes

You can specify unicode character routes directly. For example:

```ruby
get 'こんにちは', to: 'welcome#index'
```

### Direct routes

You can create custom URL helpers directly. For example:

```ruby
direct :homepage do
  "http://www.rubyonrails.org"
end

# >> homepage_url
# => "http://www.rubyonrails.org"
```

The return value of the block must be a valid argument for the `url_for` method. So, you can pass a valid string URL, Hash, Array, an Active Model instance, or an Active Model class.

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```

### Using `resolve`

The `resolve` method allows customizing polymorphic mapping of models. For example:

``` ruby
resource :basket

resolve("Basket") { [:basket] }
```

``` erb
<%= form_for @basket do |form| %>
  <!-- basket form -->
<% end %>
```

This will generate the singular URL `/basket` instead of the usual `/baskets/:id`.

Customizando Rotas com Recursos
------------------------------

Enquanto as rotas padrão e *helpers* gerados por `resources :articles` normalmente atendem a maior parte dos casos de uso, você pode querer customizá-los de alguma forma. O Rails lhe permite customizar virtualmente qualquer parte genérica dos *helpers* de recursos.

### Especificando um *Controller* para Usar

A opção `:controller` permite que você especifique um *controller* de forma explícita para usar para o recurso. Por exemplo:

```ruby
resources :photos, controller: 'images'
```

vai reconhecer caminhos requisitados iniciando com `/photos` mas vai rotear para o *controller* `Images`:

| Verbo HTTP | Caminho             | Controller#Action |  Nome do *Helper* de Rota   |
| --------- | ---------------- | ----------------- | -------------------- |
| GET       | /photos          | images#index      | photos_path          |
| GET       | /photos/new      | images#new        | new_photo_path       |
| POST      | /photos          | images#create     | photos_path          |
| GET       | /photos/:id      | images#show       | photo_path(:id)      |
| GET       | /photos/:id/edit | images#edit       | edit_photo_path(:id) |
| PATCH/PUT | /photos/:id      | images#update     | photo_path(:id)      |
| DELETE    | /photos/:id      | images#destroy    | photo_path(:id)      |

NOTE: Utilize `photos_path`, `new_photo_path`, etc. para gerar caminhos para este recurso.

Você pode usar a notação de diretório para *controllers* com *namespaces* associados. Por exemplo:

```ruby
resources :user_permissions, controller: 'admin/user_permissions'
```

Isso vai direcionar a chamada da rota para o *controller* `Admin::UserPermissions`.

NOTE: Apenas a notação de diretório é suportada. Especificar o *controller* com
a notação de constante do Ruby (e.g. `controller: 'Admin::UserPermissions'`) pode
causar problemas e resulta em um aviso.

### Especificando Restrições

Você pode usar a opção `:constraints` pra especificar um formato exigido no `id` implícito. Por exemplo:

```ruby
resources :photos, constraints: { id: /[A-Z][A-Z][0-9]+/ }
```

Essa declaração restringe o parâmetro `:id` de forma que ele seja igual à especificação da expressão regular. Então, nesse caso, o roteador não iria mais aceitar `/photos/1` para essa rota. Por outro lado, a requisição `/photos/RR27` seria aceita.

Você pode especificar uma única restrição para aplicar a mais de uma rota usando a forma de bloco:

```ruby
constraints(id: /[A-Z][A-Z][0-9]+/) do
  resources :photos
  resources :accounts
end
```

NOTE: De fato, você pode usar restrições mais avançadas disponíveis em rotas sem recursos nesse contexto.

TIP: Por padrão o parâmetro `:id` não aceita pontos - isto acontece pois os pontos são usados como separadores para rotas com formato de arquivo especificado. Se você precisa usar um ponto dentro do `:id` adicione uma restrição que sobrescreva isto - a expressão regular `id: /[^\/]+/` permite tudo exceto uma barra (`\`).

### Sobrescrevendo *Helpers* de Nome de Rota

A opção `:as` permite que você sobrescreva a convenção de nomes para os *helpers* de nome de rota. Por exemplo:

```ruby
resources :photos, as: 'images'
```

vai reconhecer chamadas que chegarem iniciando com `/photos` e direcionar as requisições para o `PhotosController`, mas vai usar o valor especificado na opção `:as` para nomear os *helpers*.

| Verbo HTTP | Caminho             | Controller#Action |  Nome do *Helper* de Rota   |
| --------- | ---------------- | ----------------- | -------------------- |
| GET       | /photos          | photos#index      | images_path          |
| GET       | /photos/new      | photos#new        | new_image_path       |
| POST      | /photos          | photos#create     | images_path          |
| GET       | /photos/:id      | photos#show       | image_path(:id)      |
| GET       | /photos/:id/edit | photos#edit       | edit_image_path(:id) |
| PATCH/PUT | /photos/:id      | photos#update     | image_path(:id)      |
| DELETE    | /photos/:id      | photos#destroy    | image_path(:id)      |

### Sobrescrevendo os Segmentos `new` e `edit`

A opção `:path_names` permite que você sobrescreva os segmentos `new` e `edit` gerados automaticamente nos caminhos:

```ruby
resources :photos, path_names: { new: 'make', edit: 'change' }
```

Isso faz o roteamento reconhecer caminhos como:

```
/photos/make
/photos/1/change
```

NOTE: Os nomes das ações não sofrem alterações devido a esta opção. Os dois caminhos exibidos ainda apontarão para as ações `new` e `edit`.

TIP: Se você quiser mudar esta opção para todas as rotas, você pode usar um *scope*.

```ruby
scope path_names: { new: 'make' } do
  # rest of your routes
end
```

### Prefixando os *Helpers* de Nome de Rota

Você pode usar a opção `:as` pra prefixar os *helpers* de nome de rota que o Rails gera. Use esta opção para evitar colisões de nomes entre rotas usando um escopo de caminho. Por exemplo:

```ruby
scope 'admin' do
  resources :photos, as: 'admin_photos'
end

resources :photos
```

Isto fornecerá *helpers* de rota como `admin_photos_path`, `new_admin_photo_path`, etc.

Para prefixar um grupo de *helpers* de rota, utilize `:as` com `scope`:

```ruby
scope 'admin', as: 'admin' do
  resources :photos, :accounts
end

resources :photos, :accounts
```

Isto irá gerar rotas como `admin_photos_path` e `admin_accounts_path` que são mapeadas para `/admin/photos` e `/admin/accounts` respectivamente.

NOTE: O *scope* `namespace` adicionará automaticamente os prefixos `:as`, assim como `:module` e `:path`.

Você pode prefixar as rotas com um *named parameter* também:

```ruby
scope ':username' do
  resources :articles
end
```

Isto vai lhe deixar com URLs como `/bob/articles/-1` e também permitirá referir à parte `username` do caminho como `params[:username]` nos *controllers*, *helpers*, e *views*.

### Restringindo as Rotas Criadas

O Rails cria rotas para sete ações diferentes (`index`, `show`, `new`, `create`, `edit`, `update`, and `destroy`) por padrão pra cada rota *RESTful* na sua aplicação.
A opção `:only` diz ao Rails para criar apenas as rotas especificadas:

```ruby
resources :photos, only: [:index, :show]
```

Agora, a requisição `GET` para `/photos` daria certo, mas uma requisição `POST` para `/photos` (que por padrão iria para ação `create`) falhará.

A opção `:except` específica uma rota ou lista de rotas que o Rails _não_ deve criar:

```ruby
resources :photos, except: :destroy
```

Nesse caso, o Rails vai criar todas as rotas normais exceto a rota para `destroy` (uma requisição `DELETE` para `/photos/:id`).

TIP: Se sua aplicação tem muitas rotas *RESTful*, usar `:only` e `:except` para gerar somente as rotas que você realmente precisa pode reduzir o consumo de memória e agilizar o processo de roteamento.

### Traduzindo Caminhos

Podemos alterar nomes de caminho gerados por `resources` usando `scope`:

```ruby
scope(path_names: { new: 'neu', edit: 'bearbeiten' }) do
  resources :categories, path: 'kategorien'
end
```

O Rails agora cria rotas para o `CategoriesController`.

| Verbo HTTP | Caminho             | Controller#Action |  Nome do *Helper* de Rota   |
| --------- | -------------------------- | ------------------ | ----------------------- |
| GET       | /kategorien                | categories#index   | categories_path         |
| GET       | /kategorien/neu            | categories#new     | new_category_path       |
| POST      | /kategorien                | categories#create  | categories_path         |
| GET       | /kategorien/:id            | categories#show    | category_path(:id)      |
| GET       | /kategorien/:id/bearbeiten | categories#edit    | edit_category_path(:id) |
| PATCH/PUT | /kategorien/:id            | categories#update  | category_path(:id)      |
| DELETE    | /kategorien/:id            | categories#destroy | category_path(:id)      |

### Sobrescrevendo a Forma Singular

Se você quer definir a forma singular de um recurso, você deve colocar regras adicionais para o `Inflector`:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```

### Usando `:as` em Recursos Aninhados

A opção `:as` sobrescreve o nome gerado automaticamente para o recurso em *helpers* de rota aninhados. Por exemplo:

```ruby
resources :magazines do
  resources :ads, as: 'periodical_ads'
end
```

Isto criará helpers de rota como `magazine_periodical_ads_url` e `edit_magazine_periodical_ad_path`.

### Sobrescrevendo Parâmetros de Nome de Rota

A opção `:param` sobrescreve o identificador padrão de recurso `:id` (nome do [segmento dinâmico](routing.html#dynamic-segments) usado para gerar as rotas). Você pode acessar o segmento do seu *controller* usando `params[<:param>]`.

```ruby
resources :videos, param: :identifier
```

```
    videos GET  /videos(.:format)                  videos#index
           POST /videos(.:format)                  videos#create
 new_video GET  /videos/new(.:format)              videos#new
edit_video GET  /videos/:identifier/edit(.:format) videos#edit
```

```ruby
Video.find_by(identifier: params[:identifier])
```

Você pode sobrescrever `ActiveRecord::Base#to_param` de um *model* relacionado para construir a URL:

```ruby
class Video < ApplicationRecord
  def to_param
    identifier
  end
end

video = Video.find_by(identifier: "Roman-Holiday")
edit_video_path(video) # => "/videos/Roman-Holiday/edit"
```

Inspecionando e Testando Rotas
-----------------------------

Rails oferece recursos para inspecionar e testar suas rotas.

### Listando Rotas Existentes

Para obter uma lista completa de rotas disponíveis na sua aplicação, visite `http://localhost:3000/rails/info/routes` no browser quando o servidor estiver rodando em ambiente de desenvolvimento. Você pode também executar o comando `rails routes` no terminal para reproduzir o mesmo resultado.

Ambos os métodos irão listas todas suas rotas, na mesma ordem que aparece em `config/routes.rb`. Para cada rota, você irá ver:

* O Nome da rota (se houver)
* O verbo HTTP usado (se a rota não responder a todos os verbos)
* O padrão ao qual a URL deve corresponder
* Os parâmetros para a cada rota

Por exemplo, segue uma pequena parte da resposta `rails routes` para uma rota RESTful:

```
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
 new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
```

Você pode também utilizar a opção `--expanded` para ativar o modo de formatação por tabela expandida.

```
$ rails routes --expanded

--[ Route 1 ]----------------------------------------------------
Prefix            | users
Verb              | GET
URI               | /users(.:format)
Controller#Action | users#index
--[ Route 2 ]----------------------------------------------------
Prefix            |
Verb              | POST
URI               | /users(.:format)
Controller#Action | users#create
--[ Route 3 ]----------------------------------------------------
Prefix            | new_user
Verb              | GET
URI               | /users/new(.:format)
Controller#Action | users#new
--[ Route 4 ]----------------------------------------------------
Prefix            | edit_user
Verb              | GET
URI               | /users/:id/edit(.:format)
Controller#Action | users#edit
```

Você pode procurar por rotas utilizando a opção grep: -g. Isso resulta qualquer rota que corresponda parcialmente ao nome do método da URL, o verbo HTTP, ou a URL.

```
$ rails routes -g new_comment
$ rails routes -g POST
$ rails routes -g admin
```

Se você quiser ver somente as rotas que mapeiam um controller especifico, existe a opção `-c`.

```
$ rails routes -c users
$ rails routes -c admin/users
$ rails routes -c Comments
$ rails routes -c Articles::CommentsController
```

TIP: O resultado do comando `rails routes` fica muito mais legível se você ampliar a janela do seu terminal até que não haja quebra de linha.

### Testando Rotas

Rotas deveriam ser incluidas na sua estratégia de testes (assim como resto da sua aplicação). Rails oferece três [validações nativas](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html) desenvolvidas para fazer os testes de rotas mais simples:

* `assert_generates`
* `assert_recognizes`
* `assert_routing`

#### A validação `assert_generates`

`assert_generates` valida que um conjunto de opções em particular gera um caminho equivalente que pode ser usar com rota padrão ou rota customizada. Por exemplo:

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### A validação `assert_recognizes`

`assert_recognizes` é o inverso de `assert_generates`. Valida que um dado caminho é reconhecido e roteia-o a um lugar determinado na sua aplicação. Por exemplo:

```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

Você pode passar um argumento `:method` para especificar um verbo HTTP:

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### A validação `assert_routing`

A validação `assert_routing` testa a rota dos dois jeitos: Testa que um caminho gera opções, e que opções gera um caminho. Logo, Ela combina as validações `assert_generates` e `assert_recognizes`:

```ruby
assert_routing({ path: 'photos', method: :post }, { controller: 'photos', action: 'create' })
```
