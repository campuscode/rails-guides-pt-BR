**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Usando Rails para aplicações somente API
=====================================

Depois de ler esse guia, você saberá:

* O que o Rails disponibiliza para aplicações somente API
* Como configurar o Rails para iniciar sem qualquer *feature* de browser
* Como decidir quais *middleware* você deve incluir
* Como decidir quais módulos usar no seu *controller*

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


Por Que Usar Rails para APIs JSON?
----------------------------

A primeira questão que muitas pessoas têm quando estão pensando em construir uma
API JSON utilizando Rails é: "Utilizar Rails para retornar alguns JSON não é
exagero? Não deveríamos usar algo como Sinatra?"

Para APIs muito simples, isso pode ser verdade. Porém, até mesmo em aplicações
com muito HTML, boa parte da lógica de uma aplicação está fora da camada de
visualização.

A razão da maioria das pessoas usar o Rails é que ele fornece um conjunto de
padrões que permitem desenvolvedores criarem e rodarem rápido, sem ter de fazer
muitas decisões triviais.

Vamos dar uma olhada em algumas das coisas que o Rails fornece "direto da caixa"
que são aplicáveis para aplicações API.

Manipulado na camada de `middleware`:

- Recarregando: Aplicações Rails suportam recarregamento transparente. Isso
  funciona até quando sua aplicação fica grande e reiniciar o servidor para
  cada requisição fica inviável.
- Modo de Desenvolvimento: Aplicações Rails vem com padrões inteligentes para
  desenvolvimento, tornando o desenvolvimento prazeroso sem comprometer performance e
  tempo de produção.
- Modo de Teste: Modo de desenvolvimento `Ditto`.
- *Logging*: Aplicações Rails criam *logs* cada requisição, em um nível de
  verbosidade apropriada para seu modo atual. Os Logs do Rails em modo de
  desenvolvimento incluem informações sobre o ambiente da requisição, *queries* da
  base de dados e informações básicas de performance.
- Segurança: O Rails detecta e impede [ataques de IP spoofing](https://pt.wikipedia.org/wiki/IP_spoofing)
  e lida com assinaturas criptográficas em um [timming attack](https://pt.wikipedia.org/wiki/Ataque_de_temporiza%C3%A7%C3%A3o)
  de maneira consciente. Não sabe o que são *IP spoofing* e *timming attack*?
  Exato.
- Análise de Parâmetros: Quer especificar seus parâmetros como JSON ao invés de
  uma *String URL-encoded*? Sem problemas. O Rails vai decodificar o JSON para
  você e disponibilizá-lo em `params`. Quer usar parâmetros *URL-encoded*
  aninhados? Isto funciona também.
- *GETs* condicionais: O Rails lida com GET condicional (`ETag` e `Last-Modified`)
  processando os cabeçalhos de requisição e retornando os cabeçalhos corretos de
  resposta e o código de status. Tudo que você precisa para isso é usar a
  checagem
  [`stale?`](https://api.rubyonrails.org/classes/ActionController/ConditionalGet.html#method-i-stale-3F)
  em seu *controller*, e o Rails vai cuidar de todos os detalhes do HTTP para
  você.
- Requisições HEAD: O Rails vai converter de forma transparente requisições
  `HEAD` em requisições `GET`, e retornar apenas os cabeçalhos no retorno. Isto
  garante que `HEAD` funcione de forma confiável em todas as APIs Rails.

Enquanto você poderia obviamente construir isto em termos de existir o
*middleware* Rack, esta lista demonstra que o padrão de pilha *middleware* Rails
fornece muito valor, até mesmo quando você está só "gerando JSON".

Controlado na camada *Action Pack*:

- Rotas *Resourceful*: Se você está construindo uma API RESTful JSON, você
  quer usar o *Rails router*. O mapeamento limpo e convencional de HTTP para
  *controllers* significa não ter que gastar tempo pensando em como modelar sua
  API em termos de HTTP.
- Geração de URL: O outro lado do roteamento é a geração de URL. Uma boa API
  baseada em HTTP inclui URLs (veja [o GitHub Gist API](https://docs.github.com/en/rest/reference/gists) como exemplo)
- Respostas de Cabeçalho e Redirecionamento: `head :no_content` e
  `redirect_to user_url(current_user)` são bem convenientes. Claro, você pode
  adicionar cabeçalhos de respostas manualmente, mas por quê?
- *Caching*: O Rails fornece cache de página, ação e fragmento. Cache de
  fragmento é especialmente útil quando construímos objetos JSON aninhados.
- Autenticações *Basic*, *Digest*, and *Token*: O Rails vem com um suporte para
  todos os três tipos de autenticação "direto da caixa".
- Instrumentação: O Rails tem uma instrumentação de API que desencadeia
  manipuladores registrados para uma variedade de eventos, assim como
  processamento de ação, enviando um arquivo ou dado, redirecionamento e
  *queries* de base de dados. O *payload* de cada evento vem com informações
  relevantes (para o processamento de ação, o *payload* inclui o *controller*,
  *action*, *parameters*, *request format*, *request method* e o *request's full path*).
- Geradores: É muitas vezes útil gerar um recurso e gerar para você *model*,
  *controller*, *test stubs* e *routes* em um único comando para futuros
  ajustes. Mesmo para migrações entre outros.
- Plugins: Muitas bibliotecas terceiras vem com suporte para Rails que reduzem ou
  eliminam o custo de configuração e utilização junto da  biblioteca e o
  framework web. Isso inclui coisas como substituir geradores padrão,
  adicionando *Rake tasks*, honrando as escolhas do Rails (como *logger* e
  *cache back-end*).

Claro, o processo de *boot* do Rails também junta todos os componentes
registrados.
Por exemplo, o processo de *boot* do Rails é o que usa seu arquivo
`config/database.yml` quando está configurando seu `Active Record`.

**A versão resumida é**: você pode não ter pensado em quais partes do Rails
continuam aplicáveis até mesmo se você remover a camada de *view*, mas a
resposta é que a maioria delas continua.

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

Escolhendo o Middleware
--------------------

Uma aplicação de API vem com os seguintes *middlewares* por padrão:

- `ActionDispatch::HostAuthorization`
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
- `ActionDispatch::ActionableExceptions`
- `ActionDispatch::Reloader`
- `ActionDispatch::Callbacks`
- `ActiveRecord::Migration::CheckPending`
- `Rack::Head`
- `Rack::ConditionalGet`
- `Rack::ETag`

Olhe a sessão [middleware interno](rails_on_rack.html#internal-middleware-stack)
do guia do `Rack` para mais informações.

Outros _plugins_, incluindo o _Active Record_, podem adicionar *middlewares*
adicionais. Em geral, esses *middlewares* são agnósticos para o tipo de
aplicação que você está construindo, e isso faz sentido em uma aplicação de API
Rails.

Você pode recuperar uma lista com todos os *middlewares* de sua aplicação via:

```bash
$ bin/rails middleware
```

### Usando o Middleware de Cache

Por padrão, o Rails vai adicionar um _middleware_ que fornece um armazenamento de
*cache* baseado na configuração de sua aplicação (*memcache* por padrão). Isso
significa que o *cache* embutido no HTTP pode confiar nisso.

Por exemplo, usando o metodo `stale?`:

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at)
    render json: @post
  end
end
```

A chamada `stale?` vai comparar o cabeçalho `If-Modified-Since` na requisição
com o `@post.updated_at`. Se o cabeçalho é mais novo que a ultima modificação,
esta ação vai retornar a resposta "304 Not Modified". Do contrário, ele vai
renderizar a resposta e incluir um cabeçalho `Last-Modified` nele.

Normalmente, este mecanismo é usado com base por cliente. O cache de
*middleware* nos permite compartilhar este mecanismo de cache através dos
clientes. Nós podemos ativar o cache *cross-client* na chamada para `stale?`:

```ruby
def show
  @post = Post.find(params[:id])

  if stale?(last_modified: @post.updated_at, public: true)
    render json: @post
  end
end
```

Isto significa que o cache de *middleware* vai guardar o valor de
`Last-Modified` para a URL no cache do Rails, e adiciona um cabeçalho
`If-Modified-Since` para qualquer requisição de entrada para a mesma URL.

Pense nisso como um cache de página usando a semântica HTTP.

### Usando Rack::Sendfile

Quando você usa o método `send_file` dentro de um *controller* do Rails, ele
define o cabeçalho `X-Sendfile`. O `Rack::Sendfile` é responsável por
efetivamente enviar o arquivo.

Se seu servidor front-end suportar envio de arquivos acelerado, `Rack::SendFile`
vai descarregar o arquivo real enviando o trabalho para o servidor front-end.

Você pode configurar o nome do cabeçalho que seu servidor _front-end_ usa para
este propósito usando `config.action_dispatch.x_sendfile_header` em seu arquivo
de configuração de ambiente apropriado.

Você pode aprender mais sobre como usar o `Rack::Sendfile` com _front-ends_
populares [na documentação do Rack::Sendfile](https://www.rubydoc.info/github/rack/rack/master/Rack/Sendfile).

Aqui estão alguns valores para este cabeçalho para alguns servidores populares, quando
estes servidores são configurados para suportar envio de arquivo acelerado.

```ruby
# Apache e lighttpd
config.action_dispatch.x_sendfile_header = "X-Sendfile"

# Nginx
config.action_dispatch.x_sendfile_header = "X-Accel-Redirect"
```

Se certifique de configurar seu servidor para suportar estas opções seguindo as
instruções na documentação do `Rack::Sendfile`.

### Usando ActionDispatch::Request

`ActionDispatch::Request#params` vai pegar os parâmetros do cliente no formato
_JSON_ e deixa-los disponiveis em seu _controller_ dentro de `params`.

para usar isto, seu cliente vai precisar fazer a requisição com parâmetros
_JSON-encoded_ e especificar o `Content-Type` como `application/json`.

Aqui um exemplo em _JQuery_:

```js
jQuery.ajax({
  type: 'POST',
  url: '/people',
  dataType: 'json',
  contentType: 'application/json',
  data: JSON.stringify({ person: { firstName: "Yehuda", lastName: "Katz" } }),
  success: function(json) { }
});
```

O `ActionDispatch::Request` verá o `Content-Type` e seus parâmetros serão:

```ruby
{ :person => { :firstName => "Yehuda", :lastName => "Katz" } }
```

### Usando *Middlewares* de Sessão (*Session*)

Os *middlewares* a seguir, usados para gerenciamento de sessão, são excluídos das aplicações de API, pois normalmente não precisam de sessões. Se um de seus clientes de API forem um navegador, convém adicionar um deles novamente em:

- `ActionDispatch::Session::CacheStore`
- `ActionDispatch::Session::CookieStore`
- `ActionDispatch::Session::MemCacheStore`

O truque para adicioná-los de volta é que, por padrão, eles são passados para `session_options`
quando adicionado (incluindo a chave de sessão), então você não pode simplesmente adicionar um inicializador `session_store.rb`, adicione
`use ActionDispatch::Session::CookieStore` e tenha as sessões funcionando normalmente. (Para ser claro: sessões
pode funcionar, mas suas opções de sessão serão ignoradas - ou seja, a chave de sessão será padronizada para `_session_id`)

Em vez do inicializador, você terá que definir as opções relevantes em algum lugar antes que seu middleware seja
construído (como `config/application.rb`) e passá-los para o seu middleware preferido, assim:

```ruby
# Isso também configura session_options para uso abaixo
config.session_store :cookie_store, key: '_interslice_session'

# Obrigatório para todo o gerenciamento de sessão (independentemente de session_store)
config.middleware.use ActionDispatch::Cookies

config.middleware.use config.session_store, config.session_options
```

### Outros _Middleware_

O Rails vem com vários outros _middlewares_ que você pode querer usar em uma
aplicação _API_, especialmente se um de seus clientes da API é o navegador:

- `Rack::MethodOverride`
- `ActionDispatch::Cookies`
- `ActionDispatch::Flash`

Qualquer um desses _middlewares_ pode ser adicionado via:

```ruby
config.middleware.use Rack::MethodOverride
```

### Removendo _Middleware_

Se você não quer usar um _middleware_ que está incluído por padrão no conjunto de
_middlewares_ _API-only_, você pode remove-lo com:

```ruby
config.middleware.delete ::Rack::Sendfile
```

Tenha em mente que removendo estes _middlewares_ vai remover suporte para
alguns recursos no _Action Controller_.

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
- `ActionController::Head`: Suporte para o retorno de uma resposta sem conteúdo, apenas *headers*.

Outros plugins podem adicionar mais módulos. Você pode obter uma lista de todos os módulos incluídos no `ActionController::API` no console do Rails:

```irb
irb> ActionController::API.ancestors - ActionController::Metal.ancestors
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
  * `ActionController::HttpAuthentication::Basic::ControllerMethods`
  * `ActionController::HttpAuthentication::Digest::ControllerMethods`
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
