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

Roteando _Resources_ (Recursos): O padrão do Rails
-----------------------------------

O roteamento de _resources_ permite que você rapidamente declare todas as rotas
comuns para um _controller_. Uma chamada única para [`resources`][] pode declarar todas as rotas
necessárias para as _actions_ `index`, `show`, `new`, `edit`, `create`, `update` e `destroy`.

[`resources`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources

### _Resources_ na Web

Navegadores solicitam páginas do Rails através de uma URL usando um método HTTP
específico, como `GET`,` POST`, `PATCH`,` PUT` e `DELETE`. Cada método é uma
solicitação para executar uma operação no _resource_. Uma rota de _resource_ mapeia
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

| Verbo HTTP | Path             | Controller#Action | Usado para                                          |
| ---------- | ---------------- | ----------------- | --------------------------------------------------- |
| GET        | /photos          | photos#index      | mostra uma lista de todas as fotos                  |
| GET        | /photos/new      | photos#new        | retorna um formulário HTML para criar uma nova foto |
| POST       | /photos          | photos#create     | cria uma nova foto                                  |
| GET        | /photos/:id      | photos#show       | mostra uma foto específica                          |
| GET        | /photos/:id/edit | photos#edit       | retorna um formulário HTML para editar uma foto     |
| PATCH/PUT  | /photos/:id      | photos#update     | atualiza uma foto específica                        |
| DELETE     | /photos/:id      | photos#destroy    | deleta uma foto específica                          |

NOTE: Por conta do roteador utilizar os verbos HTTP e a URL para corresponder as requisições de entrada, quatro URLs equivalem a sete _actions_ diferentes.

NOTE: Rotas de aplicações Rails são combinadas na ordem que são especificadas, portanto, se você tem `resources :photos` acima de `get 'photos/poll'`, a rota da _action_ `show` para a linha do `resources` será correspondida antes da linha `get`. Para resolver este problema, mova a linha `get` **acima** da linha `resources`, assim a rota será equiparada primeiro.

### Helpers _Path_ e _URL_

Criando uma rota de _resource_ vai expor um número de _helpers_ para os _controllers_ em sua aplicação. No caso de `resources :photos`:

* `photos_path` retorna `/photos`
* `new_photo_path` retorna `/photos/new`
* `edit_photo_path(:id)` retorna `/photos/:id/edit` (por exemplo, `edit_photo_path(10)` retorna `/photos/10/edit`)
* `photo_path(:id)` retorna `/photos/:id` (por exemplo, `photo_path(10)` retorna `/photos/10`)

Cada um desses _helpers_ tem um _helper_ `_url`  (assim como `photos_url`) que retorna o mesmo _path_ prefixado com o _host_ atual, porta e o prefixo do _path_.

### Definindo Múltiplos _Resources_ ao Mesmo tempo

Se você precisa criar rotas para mais de um _resource_, você pode salvar um pouco de digitação definindo todos eles em uma única chamada para `resources`:

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

| Verbo HTTP | Path           | Controller#Action | Usado para                                        |
| ---------- | -------------- | ----------------- | ------------------------------------------------- |
| GET        | /geocoder/new  | geocoders#new     | retorna um formulário HTML para criar o geocoder  |
| POST       | /geocoder      | geocoders#create  | cria o novo geocoder                              |
| GET        | /geocoder      | geocoders#show    | mostra o único geocoder _resource_                |
| GET        | /geocoder/edit | geocoders#edit    | retorna um formulário HTML para editar o geocoder |
| PATCH/PUT  | /geocoder      | geocoders#update  | atualiza o único geocoder _resource_              |
| DELETE     | /geocoder      | geocoders#destroy | deleta o geocoder _resource_                      |

NOTE: Como você pode querer usar o mesmo _controller_ para uma _singular route_ (`/account`) e uma _plural route_ (`/accounts /45`), os _singular resources_ são mapeados para os _plural controllers_. Assim, por exemplo, `resource: photo` e` resources: photos` criam rotas singular e plural que são mapeadas para o mesmo controlador (`PhotosController`).

Uma rota _resourceful_ singular gera estes _helpers_:

* `new_geocoder_path` returns `/geocoder/new`
* `edit_geocoder_path` returns `/geocoder/edit`
* `geocoder_path` returns `/geocoder`

Assim como com _resources_ no plural, os mesmos _helpers_ que terminam com `_url` tambem vão incluir o _host_, porta, e o prefixo do _path_.

### Controller Namespaces e Routing

Você pode querer organizar grupos de _controllers_ em um _namespace_. Mais comumente, você pode querer agrupar _controllers_ administrativos sob um _namespace_ `Admin::`, colocar esses _controllers_ no diretório `app/controllers/admin`. Você pode agrupar _routes_ como um grupo usando o bloco [`namespace`][]:

```ruby
namespace :admin do
  resources :articles, :comments
end
```

Isto criará um número de rotas para cada _controller_ de `articles` e `comments`. Para `Admin::ArticlesController`, o Rails vai criar:

| Verbo HTTP | Path                     | Controller#Action      | Helper de rota nomeado       |
| ---------- | ------------------------ | ---------------------- | ---------------------------- |
| GET        | /admin/articles          | admin/articles#index   | admin_articles_path          |
| GET        | /admin/articles/new      | admin/articles#new     | new_admin_article_path       |
| POST       | /admin/articles          | admin/articles#create  | admin_articles_path          |
| GET        | /admin/articles/:id      | admin/articles#show    | admin_article_path(:id)      |
| GET        | /admin/articles/:id/edit | admin/articles#edit    | edit_admin_article_path(:id) |
| PATCH/PUT  | /admin/articles/:id      | admin/articles#update  | admin_article_path(:id)      |
| DELETE     | /admin/articles/:id      | admin/articles#destroy | admin_article_path(:id)      |

Se ao invés você quiser rotear `/articles` (sem o prefixo `/admin`) para `Admin::ArticlesController`, você poderia especificar um *module* com um bloco [`scope`][]:

```ruby
scope module: 'admin' do
  resources :articles, :comments
end
```

Isso também pode ser feito para uma única rota:

```ruby
resources :articles, module: 'admin'
```

Se ao invés você quiser rotear `/admin/articles` para `ArticlesController` (Sem o prefixo do modulo `Admin::`), você poderia especificar o caminho usando um bloco `scope`:

```ruby
scope '/admin' do
  resources :articles, :comments
end
```
Isso também pode ser feito para uma única rota:

```ruby
resources :articles, path: '/admin/articles'
```

Em cada um desses casos, a rota nomeada continua a mesma, como se você não tivesse usado `scope`. No último exemplo, os _paths_ seguintes mapeiam para `ArticlesController`:

| Verbo HTTP | Path                     | Controller#Action    | Helper de rota nomeado |
| ---------- | ------------------------ | -------------------- | ---------------------- |
| GET        | /admin/articles          | articles#index       | articles_path          |
| GET        | /admin/articles/new      | articles#new         | new_article_path       |
| POST       | /admin/articles          | articles#create      | articles_path          |
| GET        | /admin/articles/:id      | articles#show        | article_path(:id)      |
| GET        | /admin/articles/:id/edit | articles#edit        | edit_article_path(:id) |
| PATCH/PUT  | /admin/articles/:id      | articles#update      | article_path(:id)      |
| DELETE     | /admin/articles/:id      | articles#destroy     | article_path(:id)      |

TIP: Se você precisar usar um _namespace_ de _controller_ diferente dentro de um bloco `namespace` você pode especificar um _path_ absoluto de _controller_, e.g: `get '/foo', to: '/foo#index'`.

[`namespace`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-namespace
[`scope`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-scope

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

_Nested routes_ (rotas aninhadas) permitem que você capture este relacionamento no seu roteamento. Neste caso, você poderia incluir esta declaração de rota:

```ruby
resources :magazines do
  resources :ads
end
```

Em adição das rotas para _magazines_, esta declaração também adicionará rotas de _ads_ para um `AdsContriller`. As URLs de _ad_ vão precisar de um _magazine_:

| Verbo HTTP | Path                                 | Controller#Action | Usado para                                                                                        |
| ---------- | ------------------------------------ | ----------------- | ------------------------------------------------------------------------------------------------- |
| GET        | /magazines/:magazine_id/ads          | ads#index         | mostra a lista de todos os `ads` para um `magazine` específico                                    |
| GET        | /magazines/:magazine_id/ads/new      | ads#new           | retorna um formulário HTML para a criação de um novo `ad` pertencente de um `magazine` específico |
| POST       | /magazines/:magazine_id/ads          | ads#create        | cria um novo `ad` pertencente a um `magazine` específico                                          |
| GET        | /magazines/:magazine_id/ads/:id      | ads#show          | exibe um `ad` pertencente a um `magazine` específico                                              |
| GET        | /magazines/:magazine_id/ads/:id/edit | ads#edit          | retorna um formulário HTML para editar um `ad` pertencente a um `magazine` específico             |
| PATCH/PUT  | /magazines/:magazine_id/ads/:id      | ads#update        | atualiza um `ad` específico pertencente a um `magazine` específico                                |
| DELETE     | /magazines/:magazine_id/ads/:id      | ads#destroy       | deleta um `ad` específico pertencente a um `magazine` específico                                  |

Isto vai também criar _routing helpers_ como `magazine_ads_url` e `edit_magazine_ad_path`. Esses _helpers_ pegam uma instância de _Magazine_ como o primeiro parâmetro (`magazine_ads_url(@magazine)`).

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

TIP: _Resources_ não devem nunca ser aninhados mais de um nível de profundidade.

#### Shallow Nesting (Aninhamento raso)

Uma maneira de evitar um aninhamento profundo (como recomendado acima) é gerar uma coleção de _actions_ _scoped_ abaixo de um pai, assim para ter uma sensação de hierarquia, mas não aninhar as _actions_ do membro. Em outras palavras. para apenas construir _routes_ com o mínimo de informação para identificar unicamente o _recurso_, como isto:

```ruby
resources :articles do
  resources :comments, only: [:index, :new, :create]
end
resources :comments, only: [:show, :edit, :update, :destroy]
```

Essa ideia encontra um equilíbrio entre rotas descritivas e aninhamento profundo. Existe uma sintaxe abreviada para conseguir exatamente isso, via a opção `:shallow`:

```ruby
resources :articles do
  resources :comments, shallow: true
end
```

Isso vai gerar as mesmas rotas do primeiro exemplo, Você pode também especificar a opção `:shallow` no seu _resource_ pai, em cada caso todos os _resources_ aninhados serão rasos:

```ruby
resources :articles, shallow: true do
  resources :comments
  resources :quotes
  resources :drafts
end
```
O método `shallow` do DSL cria um _scope_ em que todos os aninhamentos são rasos. Isso gera as mesmas rotas que o exemplo anterior:

```ruby
shallow do
  resources :articles do
    resources :comments
    resources :quotes
    resources :drafts
  end
end
```

Existem duas opções no `scope` para customizar _shallow routes_. `:shallow_path` prefixa seus _paths_ membros com o parâmetro especificado:

```ruby
scope shallow_path: "sekret" do
  resources :articles do
    resources :comments, shallow: true
  end
end
```

O _resource_ _comments_ aqui terá gerado as seguintes rotas para si:

| HTTP Verb | Path                                         | Controller#Action | Helper de rota nomeado   |
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

| HTTP Verb | Path                                         | Controller#Action | Helper de rota nomeado      |
| --------- | -------------------------------------------- | ----------------- | --------------------------- |
| GET       | /articles/:article_id/comments(.:format)     | comments#index    | article_comments_path       |
| POST      | /articles/:article_id/comments(.:format)     | comments#create   | article_comments_path       |
| GET       | /articles/:article_id/comments/new(.:format) | comments#new      | new_article_comment_path    |
| GET       | /comments/:id/edit(.:format)                 | comments#edit     | edit_sekret_comment_path    |
| GET       | /comments/:id(.:format)                      | comments#show     | sekret_comment_path         |
| PATCH/PUT | /comments/:id(.:format)                      | comments#update   | sekret_comment_path         |
| DELETE    | /comments/:id(.:format)                      | comments#destroy  | sekret_comment_path         |

### Roteamento com método *Concerns*

Roteamento com método concerns permitem você declarar rotas comuns que podem ser reutilizadas dentro de outros _resources_ e rotas. Para definir um _concern_, use um bloco [`concern`][]:

```ruby
concern :commentable do
  resources :comments
end

concern :image_attachable do
  resources :images, only: :index
end
```

Estes _concerns_ podem ser usados em _resources_ para evitar duplicação de códigos e compartilhar o mesmo comportamento por entre as rotas:

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

Além disso você pode usá-los em qualquer lugar que você quiser chamando [`concerns`][]. Por exemplo, em um bloco de `scope` ou `namespace`:

```ruby
namespace :articles do
  concerns :commentable
end
```

[`concern`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concern
[`concerns`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Concerns.html#method-i-concerns

### Criando Paths e URLs de Objetos

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

Para adicionar uma rota para um membro, apenas adicione um bloco [`member`][] em um bloco de _resource_:

```ruby
resources :photos do
  member do
    get 'preview'
  end
end
```
Isso vai reconhecer `/photos/1/preview` com GET, e rotear para a _action_ `preview` de `PhotosController`, com o valor do _resource id_  passado em `params[:id]`. Isso vai tambem criar os _helpers_ `preview_photo_url` e `preview_photo_path`.

Dentro do bloco de rotas para membros, cada nome de rota especifica o verbo HTTP
que vai ser reconhecido. Você pode usar [`get`][], [`patch`][], [`put`][], [`post`][] ou
[`delete`][] aqui. Se você não tiver múltiplas rotas para membros, você pode também
passar `:on` para a rota, eliminando o bloco:

```ruby
resources :photos do
  get 'preview', on: :member
end
```

Você pode deixar fora a opção `:on`, isso vai criar o mesmo _member route_ exceto que o valor do _resource id_ estará disponível em `params[:photo_id]` ao invés de `params[:id]`. _Helpers_ de rota tambem serão renomeados de `preview_photo_url` para `photo_preview_url` e `photo_preview_path`.

[`delete`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-delete
[`get`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-get
[`member`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-member
[`patch`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-patch
[`post`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-post
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put
[`put`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/HttpHelpers.html#method-i-put

#### Adicionando Collection Routes

Para adicionar uma rota para uma coleção, use um bloco [`collection`][]:

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

[`collection`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-collection

#### Adicionando Rotas para Novas Actions Adicionais

Para adicionar uma _action_ alternativa nova usando o atalho `:on`:

```ruby
resources :comments do
  get 'preview', on: :new
end
```

Isto vai permitir que o Rails reconheça _paths_ como `/comments/new/preview` com GET, e rotear para a _action_ `preview` do `CommentesController`. Isto também vai criar os _helpers_ `preview_new_comment_url` e `preview_new_comment_path`.

TIP: Se você se encontrar adicionando muitas _actions_ extras para uma rota _resourceful_, é um bom momento para perguntar a si mesmo se você está mascarando a presença de outro _resource_.

Rotas sem uso de *Resources*
----------------------

Além do roteamento de *resources*, o Rails possui um suporte poderoso para rotear URLs arbitrárias para *actions*. Aqui, você não obtém grupos de rotas gerados automaticamente pelo roteamento de *resources*. Em vez disso, você configura cada rota separadamente na sua aplicação.

Embora você geralmente deva usar roteamento com *resources*, ainda existem muitos lugares em que o roteamento mais simples é mais apropriado. Não é necessário tentar encaixar todas as partes do seu aplicativo em uma estrutura de *resources* se isso não for um bom ajuste.

Em particular, o roteamento simples facilita o mapeamento de URLs herdados para novas *actions* do Rails.

### Parâmetros Vinculados

Ao configurar uma rota regular, você fornece uma série de *symbols* que o Rails mapeia para partes de uma requisição HTTP chegando na aplicação. Por exemplo, considere esta rota:

```ruby
get 'photos(/:id)', to: 'photos#display'
```

Se uma requisição para `/photos/1` for processada por esta rota (porque não corresponde a nenhuma rota anterior no arquivo), o resultado será invocar a *action* `display` do `PhotosController`, e tornar o parâmetro final `"1"` disponível como `params[:id]`. Esta rota também encaminhará uma requisição recebida de `/photos` para `PhotosController#display`, pois `:id` é um parâmetro opcional, indicado por parênteses.

### Segmentos Dinâmicos

Você pode configurar quantos segmentos dinâmicos em uma rota regular desejar. Qualquer segmento estará disponível para a *action* como parte de `params`. Se você configurar esta rota:

```ruby
get 'photos/:id/:user_id', to: 'photos#show'
```

Uma requisição para o endereço `/photos/1/2` será enviada para a *action* `show` do `PhotosController`. `params[:id]` será `"1"` e `params[:user_id]` será `"2"`.

TIP: Por padrão, os segmentos dinâmicos não aceitam pontos - isso ocorre porque o ponto é usado como um separador para rotas formatadas. Se você precisar usar um ponto em um segmento dinâmico, adicione uma restrição que o substitua - por exemplo, `id: /[^\/]+/` permite qualquer coisa, exceto uma barra.

### Segmentos Estáticos

Você pode especificar segmentos estáticos ao criar uma rota somente não acrescentando dois pontos a um segmento:

```ruby
get 'photos/:id/with_user/:user_id', to: 'photos#show'
```

Esta rota responderia a caminhos como `/photos/1/with_user/2`. Nesse caso, `params` seria `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### Usando *Query String*

Os `params` também incluirão quaisquer parâmetros da *query string*. Por exemplo, com esta rota:

```ruby
get 'photos/:id', to: 'photos#show'
```

Uma requisição para o caminho `/photos/1?user_id=2` será enviada para a *action* `show` do *controller* `Photos`. `params` será `{ controller: 'photos', action: 'show', id: '1', user_id: '2' }`.

### Definindo Padrões

Você pode definir padrões em uma rota fornecendo um hash para a opção `:defaults`. Isso também se aplica a parâmetros que você não especifica como segmentos dinâmicos. Por exemplo:

```ruby
get 'photos/:id', to: 'photos#show', defaults: { format: 'jpg' }
```

O Rails corresponderia `photos/12` com a *action* `show` do `PhotosController` e definiria `params[:format]` como `"jpg"`.

Você também pode usar [`defaults`][] em um formato de bloco para definir os padrões para múltiplos itens:

```ruby
defaults format: :json do
  resources :photos
end
```

NOTE: Você não pode substituir os padrões via *query parameters* por motivos de segurança. Os únicos padrões que podem ser substituídos são segmentos dinâmicos via substituição no caminho da URL.

[`defaults`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-defaults

### Nomeando Rotas

Você pode especificar um nome para qualquer rota usando a opção `:as`:

```ruby
get 'exit', to: 'sessions#destroy', as: :logout
```

Isso criará `logout_path` e `logout_url` como *helpers* de rota em sua aplicação. Chamar `logout_path` retornará `/exit`.

Você também pode usar isso para substituir os métodos de roteamento definidos pelos *resources* usando rotas customizadas antes do *resource* ser definido, da seguinte forma:

```ruby
get ':username', to: 'users#show', as: :user
resources :users
```

Isso definirá um método `user_path` que estará disponível em *controllers*, *helpers* e *views* que irão para uma rota como `/bob`. Dentro da *action* `show` do `UsersController`, `params[:username]` conterá o nome do usuário. Altere `:username` na definição da rota se você não quiser que o nome do seu parâmetro seja `:username`.

### Restringindo Verbos HTTP

Em geral, você deve usar os métodos [`get`][], [`post`][], [`put`][], [`patch`][] e [`delete`][] para restringir uma rota a um verbo específico. Você pode usar o método [`match`][] com a opção `:via` para combinar vários verbos ao mesmo tempo:

```ruby
match 'photos', to: 'photos#show', via: [:get, :post]
```

Você pode combinar todos os verbos em uma rota específica usando `via: :all`:

```ruby
match 'photos', to: 'photos#show', via: :all
```

NOTE: Rotear solicitações `GET` e `POST` para uma única *action* tem implicações de segurança. Em geral, você deve evitar rotear todos os verbos para uma *action*, a menos que tenha um bom motivo.

NOTE: `GET` no Rails não verificará o token CSRF. Você nunca deve escrever no banco de dados a partir de solicitações `GET`, para obter mais informações, consulte o [guia de segurança](security.html#csrf-countermeasures) para contramedidas CSRF.

[`match`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-match

### Restrições de Segmento

Você pode usar a opção `:constraints` para impor um formato para um segmento dinâmico:

```ruby
get 'photos/:id', to: 'photos#show', constraints: { id: /[A-Z]\d{5}/ }
```

Essa rota corresponderia a caminhos como `/photos/A12345`, mas não `/photos/893`. Você pode expressar de forma mais sucinta a mesma rota desta maneira:

```ruby
get 'photos/:id', to: 'photos#show', id: /[A-Z]\d{5}/
```

`: constraints` usam expressões regulares com a restrição de que as âncoras regexp não podem ser usadas. Por exemplo, a seguinte rota não funcionará:

```ruby
get '/:id', to: 'articles#show', constraints: { id: /^\d/ }
```

No entanto, note que você não precisa usar âncoras porque todas as rotas estão ancoradas no início e no fim.

Por exemplo, as rotas a seguir permitiriam `articles` com valores `to_param` como `1-hello-world` que sempre começam com um número e `users` com valores `to_param` como `david` que nunca começam com um número compartilhem o mesmo *namespace* raiz:

```ruby
get '/:id', to: 'articles#show', constraints: { id: /\d.+/ }
get '/:username', to: 'users#show'
```

### Restrições Baseadas em Requisições

Você também pode restringir uma rota com base em qualquer método no [objeto `request`](action_controller_overview.html#o-objeto-request) que retorna uma `String`.

Você especifica uma restrição baseada em requisições da mesma maneira que especifica uma restrição de segmento:

```ruby
get 'photos', to: 'photos#index', constraints: { subdomain: 'admin' }
```

Você também pode especificar restrições usando blocos de [`constraints`][]:

```ruby
namespace :admin do
  constraints subdomain: 'admin' do
    resources :photos
  end
end
```

NOTE: As restrições de requisição funcionam chamando um método no [Objeto `request`](action_controller_overview.html#o-objeto-request) com o mesmo nome que a chave de hash e, em seguida, compara o valor retornado com o valor de hash. Portanto, os valores de restrição devem corresponder ao tipo de retorno do método no objeto `request` correspondente. Por exemplo: `constraints: { subdomain: 'api' }` corresponderá a um subdomínio `api` conforme o esperado. No entanto, o uso de um símbolo `constraints: { subdomain: :api }` não será, porque `request.subdomain` retorna `'api'` como uma *String*.

NOTE: Há uma exceção para a restrição `format`: embora seja um método no objeto `request`, também é um parâmetro opcional implícito em todos os endereços. Restrições de segmento têm precedência e a restrição de `format` só é aplicada quando através de um hash. Por exemplo, `get 'foo', constraints: { format: 'json' }` corresponderão a `GET /foo` porque o formato é opcional por padrão. No entanto, você pode [usar uma expressão lambda](#restricoes-avancadas) como em `get 'foo', constraints: lambda { |req| req.format == :json }` assim a rota corresponderá apenas a requisições JSON explícitas.

[`constraints`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Scoping.html#method-i-constraints

### Restrições Avançadas

Se você tiver uma restrição mais avançada, poderá fornecer um objeto que responda a `matches?` que o Rails deve usar. Digamos que você queira rotear todos os usuários em uma lista restrita para o `RestrictedListController`. Você poderia fazer:

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

Você também pode especificar restrições como uma lambda:

```ruby
Rails.application.routes.draw do
  get '*path', to: 'restricted_list#index',
    constraints: lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }
end
```

Tanto o método `matches?` quanto a lambda usam o objeto `request` como argumento.

#### *Constraints* em forma de bloco

Você pode especificar restrições em forma de bloco. Isso é útil quando você precisa aplicar a mesma regra a várias rotas. Por exemplo:

```ruby
class RestrictedListConstraint
  # ...Same as the example above
end

Rails.application.routes.draw do
  constraints(RestrictedListConstraint.new) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

Você também pode usar `lambda`:

```ruby
Rails.application.routes.draw do
  constraints(lambda { |request| RestrictedList.retrieve_ips.include?(request.remote_ip) }) do
    get '*path', to: 'restricted_list#index'
    get '*other-path', to: 'other_restricted_list#index'
  end
end
```

### Rotas Englobadas (*Glob*) e Segmentos Curinga

O englobamento de rota é uma maneira de especificar que um parâmetro em particular deve corresponder a todas as partes restantes de uma rota. Por exemplo:

```ruby
get 'photos/*other', to: 'photos#unknown'
```

Esta rota irá corresponder a `photos/12` ou `/photos/long/path/to/12`, definindo `params[:other]` como `"12"` ou `"long/path/to/12"`. Os segmentos prefixados com um asterisco são chamados de "segmentos curinga".

Segmentos curinga podem ocorrer em qualquer lugar da rota. Por exemplo:

```ruby
get 'books/*section/:title', to: 'books#show'
```

corresponderia `books/some/section/last-words-a-memoir` para `params[:section]` igual a `'some/section'` e `params[:title]` igual a `'last-words-a-memoir'`.

Tecnicamente, uma rota pode ter ainda mais de um segmento curinga. O *matcher* de rotas atribui segmentos aos parâmetros de maneira intuitiva. Por exemplo:

```ruby
get '*a/foo/*b', to: 'test#index'
```

corresponderia `zoo/woo/foo/bar/baz` para `params[:a]` igual a `'zoo/woo'`, e `params[:b]` igual a `'bar/baz'`.

NOTE: Ao solicitar `'/foo/bar.json'`, seu `params[:pages]` serão iguais a `'foo/bar'` com o formato de solicitação JSON. Se você quiser o antigo comportamento 3.0.x de volta, poderá fornecer `format: false` assim:

```ruby
get '*pages', to: 'pages#show', format: false
```

NOTE: Se você quiser tornar o segmento de formato obrigatório, para que ele não possa ser omitido, você pode fornecer `format: true` assim:

```ruby
get '*pages', to: 'pages#show', format: true
```

### Redirecionamento

Você pode redirecionar qualquer rota para outra usando o auxiliar [`redirect`][] no seu roteador:

```ruby
get '/stories', to: redirect('/articles')
```

Você também pode reutilizar segmentos dinâmicos para corresponder a rotas e redirecionar para:

```ruby
get '/stories/:name', to: redirect('/articles/%{name}')
```

Você também pode fornecer um bloco para redirecionar, que recebe os parâmetros do caminho simbolizado e o objeto `request`:

```ruby
get '/stories/:name', to: redirect { |path_params, req| "/articles/#{path_params[:name].pluralize}" }
get '/stories', to: redirect { |path_params, req| "/articles/#{req.subdomain}" }
```

Observe que o redirecionamento padrão é um redirecionamento 301 "Moved Permanently". Lembre-se de que alguns navegadores da Web ou servidores proxy armazenam em cache esse tipo de redirecionamento, tornando a página antiga inacessível. Você pode usar a opção `:status` para alterar o status da resposta:


```ruby
get '/stories/:name', to: redirect('/articles/%{name}', status: 302)
```

Em todos esses casos, se você não fornecer o host principal (`http://www.example.com`), o Rails obterá esses detalhes da requisição atual.

[`redirect`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Redirection.html#method-i-redirect

### Roteamento para Aplicações Rack

Em vez de uma String como `'articles#index'`, que corresponde à *action* `index` no `ArticlesController`, você pode especificar qualquer [aplicação Rack](rails_on_rack.html) como o *endpoint*:

```ruby
match '/application.js', to: MyRackApp, via: :all
```

Desde que o `MyRackApp` responda ao método `call` e retorne um `[status, headers, body]`, o roteador não saberá a diferença entre a aplicação Rack e uma *action*. Este é um uso apropriado de `via: :all`, pois você deseja permitir que sua aplicação Rack manipule todos os verbos conforme considerar apropriado.

NOTE: Para os curiosos, `'articles#index'` na verdade se expande para `ArticlesController.action(:index)`, que retorna uma aplicação Rack válida.

Se você especificar uma aplicação Rack como *endpoint*, lembre-se de que
a rota não será alterada na aplicação de recebimento. Com a seguinte
rota sua aplicação Rack deve esperar que a rota seja `/admin`:

```ruby
match '/admin', to: AdminApp, via: :all
```

Se você preferir que sua aplicação Rack receba requisições no *root
path* em vez disso, use [`mount`][]:

```ruby
mount AdminApp, at: '/admin'
```

[`mount`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Base.html#method-i-mount

### Usando `root`

Você pode especificar para onde o Rails deve rotear `'/'` com o método [`root`][]:

```ruby
root to: 'pages#main'
root 'pages#main' # shortcut for the above
```

Você deve colocar a rota `root` no topo do arquivo, porque é a rota mais popular e deve ser correspondida primeiro.

NOTE: A rota `root` direciona apenas requisições `GET` para a *action*.

Você também pode usar o *root* dentro de *namespaces* e *scopes*. Por exemplo:

```ruby
namespace :admin do
  root to: "admin#index"
end

root to: "home#index"
```

[`root`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-root

### Rotas com Caracteres Unicode

Você pode especificar rotas de caracteres unicode diretamente. Por exemplo:

```ruby
get 'こんにちは', to: 'welcome#index'
```

### Rotas Diretas

Você pode criar *URL helpers* personalizados diretamente chamando [`direct`][]. Por exemplo:

```ruby
direct :homepage do
  "http://www.rubyonrails.org"
end

# >> homepage_url
# => "http://www.rubyonrails.org"
```

O valor de retorno do bloco deve ser um argumento válido para o método `url_for`. Portanto, você pode transmitir uma URL como *string* válida, Hash, Array, ou uma instância de *Active Model* ou uma classe *Active Model*.

```ruby
direct :commentable do |model|
  [ model, anchor: model.dom_id ]
end

direct :main do
  { controller: 'pages', action: 'index', subdomain: 'www' }
end
```

[`direct`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-direct

### Usando `resolve`

O método [`resolve`][] permite personalizar o mapeamento polimórfico de *models*. Por exemplo:

```ruby
resource :basket

resolve("Basket") { [:basket] }
```

```erb
<%= form_with model: @basket do |form| %>
  <!-- basket form -->
<% end %>
```

Isso irá gerar uma URL singular `/basket` ​​em vez da habitual `/baskets/:id`.

[`resolve`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/CustomUrls.html#method-i-resolve

Customizando Rotas com Recursos
------------------------------

Enquanto as rotas padrões e *helpers* gerados por [`resources`][] normalmente atendem a maior parte dos casos de uso, você pode querer customizá-los de alguma forma. O Rails lhe permite customizar virtualmente qualquer parte genérica dos *helpers* de recursos.

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

TIP: Se você quiser mudar esta opção para todas as rotas, você pode usar um *scope*. Da seguinte forma:

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

Se você quer sobrescrever a forma singular de um recurso, você deve colocar regras adicionais para o `Inflector` via [`inflections`][]:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'tooth', 'teeth'
end
```

[`inflections`]: https://api.rubyonrails.org/classes/ActiveSupport/Inflector.html#method-i-inflections

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

Você pode sobrescrever `ActiveRecord::Base#to_param` de um *model* associado para construir a URL:

```ruby
class Video < ApplicationRecord
  def to_param
    identifier
  end
end
```

```ruby
video = Video.find_by(identifier: "Roman-Holiday")
edit_video_path(video) # => "/videos/Roman-Holiday/edit"
```

Breaking up *very* large route file into multiple small ones:
-------------------------------------------------------

If you work in a large application with thousands of routes,
a single `config/routes.rb` file can become cumbersome and hard to read.

Rails offers a way to break a gigantic single `routes.rb` file into multiple small ones using the [`draw`][] macro.

```ruby
# config/routes.rb

Rails.application.routes.draw do
  get 'foo', to: 'foo#bar'

  draw(:admin) # Will load another route file located in `config/routes/admin.rb`
end
```

```ruby
# config/routes/admin.rb

namespace :admin do
  resources :comments
end
```

Calling `draw(:admin)` inside the `Rails.application.routes.draw` block itself will try to load a route
file that has the same name as the argument given (`admin.rb` in this case).
The file needs to be located inside the `config/routes` directory or any sub-directory (i.e. `config/routes/admin.rb` or `config/routes/external/admin.rb`).

You can use the normal routing DSL inside the `admin.rb` routing file, **however** you shouldn't surround it with the `Rails.application.routes.draw` block like you did in the main `config/routes.rb` file.

[`draw`]: https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-draw

### When to use and not use this feature

Drawing routes from external files can be very useful to organise a large set of routes into multiple organised ones. You could have a `admin.rb` route that contains all the routes for the admin area, another `api.rb` file to route API related resources, etc...

However, you shouldn't abuse this feature as having too many route files make discoverability and understandability more difficult. Depending on the application, it might be easier for developers to have a single routing file even if you have few hundreds routes. You shouldn't try to create a new routing file for each category (e.g. admin, api, ...) at all cost; the Rails routing DSL already offers a way to break routes in a organised manner with `namespaces` and `scopes`.

Inspecionando e Testando Rotas
-----------------------------

Rails oferece recursos para inspecionar e testar suas rotas.

### Listando Rotas Existentes

Para obter uma lista completa de rotas disponíveis na sua aplicação, visite <http://localhost:3000/rails/info/routes> no browser quando o servidor estiver rodando em ambiente de desenvolvimento. Você pode também executar o comando `bin/rails routes` no terminal para reproduzir o mesmo resultado.

Ambos os métodos irão listas todas suas rotas, na mesma ordem que aparece em `config/routes.rb`. Para cada rota, você irá ver:

* O Nome da rota (se houver)
* O verbo HTTP usado (se a rota não responder a todos os verbos)
* O padrão ao qual a URL deve corresponder
* Os parâmetros para a cada rota

Por exemplo, segue uma pequena parte da resposta `bin/rails routes` para uma rota RESTful:

```
    users GET    /users(.:format)          users#index
          POST   /users(.:format)          users#create
 new_user GET    /users/new(.:format)      users#new
edit_user GET    /users/:id/edit(.:format) users#edit
```

Você pode também utilizar a opção `--expanded` para ativar o modo de formatação por tabela expandida.

```bash
$ bin/rails routes --expanded

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

```bash
$ bin/rails routes -g new_comment
$ bin/rails routes -g POST
$ bin/rails routes -g admin
```

Se você quiser ver somente as rotas que mapeiam um controller especifico, existe a opção `-c`.

```bash
$ bin/rails routes -c users
$ bin/rails routes -c admin/users
$ bin/rails routes -c Comments
$ bin/rails routes -c Articles::CommentsController
```

TIP: O resultado do comando `bin/rails routes` fica muito mais legível se você ampliar a janela do seu terminal até que não haja quebra de linha.

### Testando Rotas

Rotas deveriam ser incluidas na sua estratégia de testes (assim como resto da sua aplicação). Rails oferece três validações nativas desenvolvidas para fazer os testes de rotas mais simples:

* [`assert_generates`][]
* [`assert_recognizes`][]
* [`assert_routing`][]

[`assert_generates`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates
[`assert_recognizes`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes
[`assert_routing`]: https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_routing

#### A validação `assert_generates`

[`assert_generates`][] valida que um conjunto de opções em particular gera um caminho equivalente que pode ser usar com rota padrão ou rota customizada. Por exemplo:

```ruby
assert_generates '/photos/1', { controller: 'photos', action: 'show', id: '1' }
assert_generates '/about', controller: 'pages', action: 'about'
```

#### A validação `assert_recognizes`

[`assert_recognizes`][] é o inverso de `assert_generates`. Valida que um dado caminho é reconhecido e roteia-o a um lugar determinado na sua aplicação. Por exemplo:

```ruby
assert_recognizes({ controller: 'photos', action: 'show', id: '1' }, '/photos/1')
```

Você pode passar um argumento `:method` para especificar um verbo HTTP:

```ruby
assert_recognizes({ controller: 'photos', action: 'create' }, { path: 'photos', method: :post })
```

#### A validação `assert_routing`

A validação [`assert_routing`][] testa a rota dos dois jeitos: Testa que um caminho gera opções, e que opções gera um caminho. Logo, Ela combina as validações `assert_generates` e `assert_recognizes`:

```ruby
assert_routing({ path: 'photos', method: :post }, { controller: 'photos', action: 'create' })
```
