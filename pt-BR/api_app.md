**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Using Rails for API-only Applications
=====================================

In this guide you will learn:

* What Rails provides for API-only applications
* How to configure Rails to start without any browser features
* How to decide which middleware you will want to include
* How to decide which modules to use in your controller

--------------------------------------------------------------------------------
O que é uma Aplicação API?
---------------------------

Tradicionalmente, quando as pessoas dizem que usam o Rails como uma "API",
elas querem dizer que fornecem  uma API acessível junto a suas aplicações web.
Por exemplo, o GitHub fornece [uma API](https://developer.github.com) que você
pode usar nas suas próprias aplicações personalizadas.

Com o advento dos *frameworks client-side*, mais desenvolvedores estão usando o Rails para construir
um *back-end* compartilhado entre suas aplicações web e outros aplicativos nativos.

Por exemplo, o Twitter usa sua [API pública](https://developer.twitter.com/) em sua aplicação web,
que é um site estático que consome recursos via JSON.

Em vez de usar o Rails para gerar HTML que se comunica com o servidor através de formulários e links,
muitos desenvolvedores estão tratando suas aplicações web apenas como uma API, separadamente do HTML com JavaScript que apenas consome uma API JSON.

Esse guia aborda a construção de um aplicativo Rails que fornece dados em JSON para um cliente, incluindo frameworks *client-side*.


Porque Usar Rails para APIs JSON?
----------------------------

A primeira questão que muitas pessoas tem quando estão pensando em construir uma
API JSON utilizando Rails é: "Utilizar Rails para retornar alguns JSON não é
overkill? Não deveriamos usar algo como Sinatra?"

Para APIs muito simles, isso pode ser verdade. Porem, até mesmo em aplicações
com muito HTML, boa parte da lógica de uma aplicação está fora da camada de
visualização.

A razão da maioria das pessoas usar o Rails é que ele fornece um conjunto de
padrões que permitem desenvolvedores criarem e rodarem rápido, sem ter de fazer
muitas decisões triviais.

Vamos dar uma olhada em algumas das coisas que o Rails fornece "fora da caixa"
que são aplicaveis para aplicações API.

Manipulado na camada de `middleware`:

- Recarregando: Aplicações Rails suportam recarregamento transparente. Isso
  funciona até quando sua aplicação fica grande e reiniciar o servidor para
  cada requisição fica inviavel.
- Modo de Desenvolvimento: Aplicações Rails vem com padrões inteligentes para
  desenvolvimento, fazendo desenvolver prazeroso sem comprometer performance e
  tempo de produção.
- Modo de Teste: Modo de desenvolvimento `Ditto`.
- *Logging*: Aplicações Rails *logam* cada requisições, em um nivel de
  verbosidade apropriada para seu modo atual. Os Logs do Rails em modo de
  desenvolvimento incluem informações sobre o ambiente da requisição, queries da
  base de dados e informações basicas de performance.
- Segurança: O Rails detecta e impede [ataques de IP spoofing](https://en.wikipedia.org/wiki/IP_address_spoofing)
  e lida com assinaturas criptográficas em um [timming attack](https://en.wikipedia.org/wiki/Timing_attack)
  de maneira consciente. Não sabe o que é um IP spoofing e um timming attack é?
  Exato.
- Análise de Parametros: Quer especificar seus parametros como JSON ao inves de
  uma *String URL-encoded*? Sem problemas. O Rails vai decodificar o JSON para
  você e disponibiliza-lo em `params`. Quer usar parametros *URL-encoded*
  aninhados? Isto funciona tambem.
- *GETs* condicionais: O Rails lida com GET condicional (`ETag` e `Last-Modified`)
  processando os cabeçalhos de requisição e retornando os cabeçalhos corretos de
  resposta e o código de status. Tudo que você precisa para isso é usar a
  checagem
  [`stale?`](https://api.rubyonrails.org/classes/ActionController/ConditionalGet.html#method-i-stale-3F)
  em seu *controller*, e o Rails vai cuidar de todo os detalhes do HTTP para
  você.
- Requisições HEAD: O Rails vai converter de forma transparente requisições
  `HEAD` em requisições `GET`, e retornar apenas os cabeçalhos no retorno. Isto
  garante que `HEAD` funcione de forma confiável em todas as APIs Rails.

Enquanto você poderia obviamente construir isto em termos de existir o
middleware Rack, esta lista demonstra que o padrão de pilha middleware Rails
fornece muito valor, até mesmo quando você está só "gerando JSON".

Controlado na camada *Action Pack*:

- Rotas *Resourceful*: Se você está construindo uma API RESTful JSON, você
  quer usar o *Rails router*. O mapeamento limpo e convencional de HTTP para
  *controllers* significa não ter que gastar tempo pensando em como modelar sua
  API em termos de HTTP.
- Geração de URL: O outro lado do roteamento é a geração de URL. Uma boa API
  baseada em HTTP inclui URLs (veja [o GitHub Gist API](https://developer.github.com/v3/gists/) como exemplo).
- Respostas de Cabeçalho e Redirecionamento: `head :no_content` e
  `redirect_to user_url(current_user)` são bem convenientes. Claro, você pode
  adicionar cabeçalhos de respostas manualmente, mas porque?
- *Caching*: O Rails fornece cache de pagina, ação e fragmento. Cache de
  fragmento é especialmente útil quando construimos um objetos JSON aninhados.
- Autenticações *Basic*, *Digest*, and *Token*: O Rails vem com um suporte para
  todos os tres tipos de autenticação fora da caixa.
- Instrumentação: O Rails tem uma instrumentação de API que desencadeia
  manipuladores registrados para uma variedade de eventos, assim como
  processamento de ação, enviando um arquivo ou dado, redirecionamento e
  *queries* de base de dados. O *payload* de cada evento vem com informações
  relevantes (para o processamento de ação, o *payload* inclui o *controller*,
  *action*, *parameters*, *request format*, *request method* e o *request's full path*).
- Geradores: É muitas vezes útil gerar um recurso e gerar para você *model*,
  *controller*, *test stubs* e *routes* em um unico comando para futuros
  ajustes. Mesmo para migrações entre outros.
- Plugins: Muitas bibliotecas terceiras vem com suporte para Rails que reduz ou
  elimina o custo de configuração e utilização junto da  biblioteca e o
  framework web. Isso inclui coisas como subistituir geradores padrão,
  adicionando *Rake tasks*, honrando as escolhas do Rails (como *logger* e
  *cache back-end*).

Claro, o processo de *boot* do Rails tambem junta todos os componentes
registrados.
Por exemplo, o processo de *boot* do Rails é o que usa seu arquivo
`config/database.yml` quando esta configurando seu `Active Record`.

**A versão curta é**: você pode não ter pensado em que partes do Rails
continuam aplicaveis até mesmo se você remover a camada de *view*, mas a
resposta é que a maioria delas.

Configuração básica
-----------------------

Se você estiver construindo uma aplicação Rails que será uma API, você pode começar
com um subconjunto mais limitado do Rails e adicionar recursos, conforme necessário.

### Criando uma nova aplicação

Você pode gerar uma nova API Rails:

```bash
$ rails new my_api --api
```

Esse comando fará três coisas principais para você:

- Configura sua aplicação para começar com um conjunto mais limitado de *middlewares* que o normal.
Especificamente, não serão incluídos *middlewares* para aplicações web (como suporte a *cookies*) por padrão.
- Faz com que o `ApplicationController` herde do `ActionController::API` ao invés do `ActionController::Base`.
Como nos *middlewares*, isso exclui qualquer *Action Controller* ou Módulo que forneçam funcionalidades usadas primordialmente pelo navegador.
- Configura os geradores para não gerar *views*, *helpers*, e *assets* quando você criar um novo recurso.

### Alterando uma aplicação existente

Se você deseja usar uma aplicação que já existe e transformá-la em API, siga os passos a seguir.

Em `config/application.rb` adicione a seguinte linha no começo da classe `Application`:

```ruby
config.api_only = true
```

Em `config/environments/development.rb`, defina `config.debug_exception_response_format`
para configurar o formato usado nas respostas quando ocorrer um erro no modo de desenvolvimento.

Para renderizar uma página HTML com as informações de *debugging*, use o valor `:default`.

```ruby
config.debug_exception_response_format = :default
```

Para renderizar as informações de *debugging* preservando o formato da resposta, use o valor `:api`.

```ruby
config.debug_exception_response_format = :api
```

Por padrão, `config.debug_exception_response_format` está definido para `:api`, quando `config.api_only` está com o valor *true*.

Finalmente, no arquivo `app/controllers/application_controller.rb`, ao invés de

```ruby
class ApplicationController < ActionController::Base
end
```

troque por:

```ruby
class ApplicationController < ActionController::API
end
```

Choosing Middleware
--------------------

An API application comes with the following middleware by default:

- `Rack::Sendfile`
- `ActionDispatch::Static`
- `ActionDispatch::Executor`
- `ActiveSupport::Cache::Strategy::LocalCache::Middleware`
- `Rack::Runtime`
- `ActionDispatch::RequestId`
- `ActionDispatch::RemoteIp`
- `Rails::Rack::Logger`
- `ActionDispatch::ShowExceptions`
- `ActionDispatch::DebugExceptions`
- `ActionDispatch::Reloader`
- `ActionDispatch::Callbacks`
- `ActiveRecord::Migration::CheckPending`
- `Rack::Head`
- `Rack::ConditionalGet`
- `Rack::ETag`

See the [internal middleware](rails_on_rack.html#internal-middleware-stack)
section of the Rack guide for further information on them.

Other plugins, including Active Record, may add additional middleware. In
general, these middleware are agnostic to the type of application you are
building, and make sense in an API-only Rails application.

You can get a list of all middleware in your application via:

```bash
$ rails middleware
```

### Using the Cache Middleware

By default, Rails will add a middleware that provides a cache store based on
the configuration of your application (memcache by default). This means that
the built-in HTTP cache will rely on it.

For instance, using the `stale?` method:

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at)
    render json: @post
  end
end
```

The call to `stale?` will compare the `If-Modified-Since` header in the request
with `@post.updated_at`. If the header is newer than the last modified, this
action will return a "304 Not Modified" response. Otherwise, it will render the
response and include a `Last-Modified` header in it.

Normally, this mechanism is used on a per-client basis. The cache middleware
allows us to share this caching mechanism across clients. We can enable
cross-client caching in the call to `stale?`:

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at, public: true)
    render json: @post
  end
end
```

This means that the cache middleware will store off the `Last-Modified` value
for a URL in the Rails cache, and add an `If-Modified-Since` header to any
subsequent inbound requests for the same URL.

Think of it as page caching using HTTP semantics.

### Using Rack::Sendfile

When you use the `send_file` method inside a Rails controller, it sets the
`X-Sendfile` header. `Rack::Sendfile` is responsible for actually sending the
file.

If your front-end server supports accelerated file sending, `Rack::Sendfile`
will offload the actual file sending work to the front-end server.

You can configure the name of the header that your front-end server uses for
this purpose using `config.action_dispatch.x_sendfile_header` in the appropriate
environment's configuration file.

You can learn more about how to use `Rack::Sendfile` with popular
front-ends in [the Rack::Sendfile
documentation](https://www.rubydoc.info/github/rack/rack/master/Rack/Sendfile).

Here are some values for this header for some popular servers, once these servers are configured to support
accelerated file sending:

```ruby
# Apache and lighttpd
config.action_dispatch.x_sendfile_header = "X-Sendfile"

# Nginx
config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"
```

Make sure to configure your server to support these options following the
instructions in the `Rack::Sendfile` documentation.

### Using ActionDispatch::Request

`ActionDispatch::Request#params` will take parameters from the client in the JSON
format and make them available in your controller inside `params`.

To use this, your client will need to make a request with JSON-encoded parameters
and specify the `Content-Type` as `application/json`.

Here's an example in jQuery:

```javascript
jQuery.ajax({
  type: 'POST',
  url: '/people',
  dataType: 'json',
  contentType: 'application/json',
  data: JSON.stringify({ person: { firstName: "Yehuda", lastName: "Katz" } }),
  success: function(json) { }
});
```

`ActionDispatch::Request` will see the `Content-Type` and your parameters
will be:

```ruby
{ :person => { :firstName => "Yehuda", :lastName => "Katz" } }
```

### Other Middleware

Rails ships with a number of other middleware that you might want to use in an
API application, especially if one of your API clients is the browser:

- `Rack::MethodOverride`
- `ActionDispatch::Cookies`
- `ActionDispatch::Flash`
- For session management
    * `ActionDispatch::Session::CacheStore`
    * `ActionDispatch::Session::CookieStore`
    * `ActionDispatch::Session::MemCacheStore`

Any of these middleware can be added via:

```ruby
config.middleware.use Rack::MethodOverride
```

### Removing Middleware

If you don't want to use a middleware that is included by default in the API-only
middleware set, you can remove it with:

```ruby
config.middleware.delete ::Rack::Sendfile
```

Keep in mind that removing these middlewares will remove support for certain
features in Action Controller.

Escolhendo os módulos do *controller*
---------------------------

Uma aplicação API (utilizando `ActionController::API`) vem com os seguintes módulos do *controller* por padrão:

- `ActionController::UrlFor`: Faz com que `url_for` e helpers similares sejam disponíveis.
- `ActionController::Redirecting`: Suporte para `redirect_to`.
- `AbstractController::Rendering` e `ActionController::ApiRendering`: Suporte básico para renderização.
- `ActionController::Renderers::All`: Suporte para `render :json` e similares.
- `ActionController::ConditionalGet`: Suporte para `stale?`.
- `ActionController::BasicImplicitRender`: Certifica-se de retornar uma resposta vazia, se não houver uma explícita.
- `ActionController::StrongParameters`: Suporte para filtragem de parâmetros em conjunto com a atribuição do ActiveModel.
- `ActionController::DataStreaming`: Suporte para `send_file` e `send_data`.
- `AbstractController::Callbacks`: Suporte para `before_action` e helpers similares.
- `ActionController::Rescue`: Suporte para `rescue_from`.
- `ActionController::Instrumentation`: Suporte para ganchos de instrumentação definidos pela *Action Controller* (veja [o guia da instrumentação](active_support_instrumentation.html#action-controller) para mais informações a respeito disso)
- `ActionController::ParamsWrapper`: Agrupa o hash dos parâmetros em um hash encadeado, para que você não precise especificar elementos raiz enviando requisições POST, por exemplo.
- `ActionController::Head`: Suporte para o retorno de uma resposta sem conteúdo, apenas *headers*

Outros plugins podem adicionar mais módulos. Você pode obter uma lista de todos os módulos incluídos no `ActionController::API` no console do Rails:

```bash
$ rails c
>> ActionController::API.ancestors - ActionController::Metal.ancestors
=> [ActionController::API,
    ActiveRecord::Railties::ControllerRuntime,
    ActionDispatch::Routing::RouteSet::MountedHelpers,
    ActionController::ParamsWrapper,
    ... ,
    AbstractController::Rendering,
    ActionView::ViewPaths]
```

### Adicionando Outros Módulos

Todos os módulos do *Action Controller* conhecem seus módulos dependentes. Assim, você pode incluir qualquer módulo em seus controllers, e todas as dependências serão
incluídas e configuradas também.

Alguns módulos comuns que você pode querer adicionar:

- `AbstractController::Translation`: Suporte para os métodos de localização e tradução `l` e `t`
- Suporte para autenticações HTTP basic, digest ou por token:
  * `ActionController::HttpAuthentication::Basic::ControllerMethods`,
  * `ActionController::HttpAuthentication::Digest::ControllerMethods`,
  * `ActionController::HttpAuthentication::Token::ControllerMethods`
- `ActionView::Layouts`: Suporte para layouts ao renderizar.
- `ActionController::MimeResponds`: Suporte para `respond_to`.
- `ActionController::Cookies`: Suporte para `cookies`, que inclui suporte para cookies assinados e criptografados. Isso requer um middleware de cookies
- `ActionController::Caching`: Suporte para cache da *view* do *controller* da API. Lembre-se que você precisará especificar manualmente o armazenamento em cache dentro do *controller*, como por exemplo:
  ```ruby
  class ApplicationController < ActionController::API
    include ::ActionController::Caching
    self.cache_store = :mem_cache_store
  end
  ```
  O Rails *não* faz essa configuração automaticamente

O melhor lugar para adicionar um módulo é em sua `ApplicationController`, mas 
você também pode adicionar módulos em *controllers* individuais.
