**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Action Controller Overview
==========================

Nesse guia você irá aprender como `controllers` trabalham e como eles se encaixam no ciclo de requisições da sua aplicação.

Depois de ler este guia, você irá saber:

* Como seguir o fluxo de uma requisição através de um *controller*.
* Como restringir parâmetros passados ao seu *controller*.
* Como e porque salvar dados na sessão ou nos `cookies`.
* Como trabalhar com filtros para executar código durante o processamento de uma requisição.
* Como utilizar o autenticador HTTP nativo do `ActionController`.
* Como transmitir dados diretamente ao navegador do usuário.
* Como filtrar parâmetros sensíveis para que não apareçam no *log* da aplicação.
* Como lidar com erros que podem surgir durante o processamento de uma requisição.
--------------------------------------------------------------------------------

O que um *Controller* faz?
--------------------------

*ActionController* é o _C_ em [MVC](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller). Após o `router` determinar qual _controller_ usar para a requisição, o _controller_ será responsável por entender a requisição e retornar a resposta apropriada. Por sorte, *ActionController* faz a maior parte do trabalho fundamental pra você e usa convenções inteligentes pra fazer esse processo ser tão intuitivo quanto possível.

Para a maior parte das aplicações [RESTful](https://en.wikipedia.org/wiki/Representational_state_transfer),o *controller* receberá a requisição (o que é "invisível" a você que está desenvolvendo), busca e/ou salva dados de um *model*, e usa a *view* para criar a saída HTML. Se seu *controller* precisa tratar requisições um pouco diferente, isso não é um problema, este é apenas o jeito mais comum de um *controller* trabalhar.

Um *controller* pode então ser pensado como um intermediário entre um *model* e uma *view*. Isso faz com que os dados do *model* fiquem disponíveis para a *view* para que possa ser mostrado ao usuário, e ele salva ou atualiza dados do usuário no *model*.

NOTE: Para mais detalhes sobre processo de roteamento, veja [Rails Routing from the Outside In](routing.html)

Convenção para Nomeclatura de *Controllers*
----------------------------
A convenção para nomenclatura de *controllers* no Rails favorece a pluralização da última palavra do nome do *controller*, embora não seja estritamente necessário (ex: `ApplicationController`). Por exemplo, `ClientsController` é recomendado ao invés de `ClientController`, `SiteAdminsController` é recomendado ao invés de `SiteAdminController` ou `SitesAdminsController`, e assim por diante.

Seguindo essa convenção será possível utilizar o gerador de rotas padrão (ex: `resources`, etc) sem precisar configurar cada `:path` ou `:controller`, e ainda manter consistente o uso dos auxiliares de rotas em todo o seu projeto. Veja [Layouts & Guia de Renderização](layouts_and_rendering.html) para mais detalhes.

NOTE: A convenção para nomenclatura de *controllers* difere da convenção para nomenclatura de *models*, que devem ser nomeados na forma singular.

Métodos e Actions
-------------------

Um *controller* é uma classe do Ruby que herda de `ApplicationController` e tem métodos como qualquer outra classe. Quando a sua aplicação recebe uma requisição, o roteamento irá determinar qual *controller* e qual *action* serão executados, e então o Rails irá criar uma instância desse *controller* e executará o método que possui o mesmo nome da *action*.

```ruby
class ClientsController < ApplicationController
  def new
  end
end
```

Como exemplo, se um usuário acessar `/clients/new` na sua aplicação para adicionar um novo cliente, o Rails irá criar uma instância de `ClientsController` e irá chamar o método `new` dele. Repare que o método vazio do exemplo acima funcionaria normalmente porque o Rails por padrão vai renderizar a *view* `new.html.erb` a menos que a `action` indique outro caminho. Ao criar um novo `Client` o método `new` pode tornar uma variável de instância `@client` acessível na `view`.

```ruby
def new
  @client = Client.new
end
```

O [Guia de Layouts e Renderização](layouts_and_rendering.html) explica essa etapa mais detalhadamente.

`ApplicationController` herda de `ActionController::Base`, que define uma quantidade de métodos úteis. Este guia irá cobrir alguns destes métodos, mas se você estiver com curiosidade para ver o que há neles, você pode ver todos eles na [Documentação da API](https://api.rubyonrails.org/classes/ActionController.html) ou no próprio código fonte.

Apenas métodos públicos são executáveis como *actions*. É uma boa prática diminuir a visibilidade de métodos (utilizando `private` ou `protected`) que não foram designados para serem *actions*, como métodos auxiliares ou filtros.

Parâmetros
----------

Você provavelmente vai querer acessar os dados enviados pelo usuário ou outros parâmetros nas *actions* do seu *controller*. Existem dois tipos de parâmetros possíveis numa aplicação *web*. O primeiro são os parâmetros que são enviados como parte da URL, chamados parâmetros de *query string*. A *query string* é tudo o que vem após o "?" na URL. O segundo tipo de parâmetro é geralmente referido como os dados de POST. Essa informação geralmente vem de um formulário HTML que foi preenchido pelo usuário. Se chamam dados de POST porque estes dados somente podem ser enviados como parte de uma requisição HTTP usando o verbo POST. O Rails não faz distinção sobre parâmetros de *query string* e parâmetros de POST, ambos são acessíveis por meio do *hash* `params` no seu *controller*:

```ruby
class ClientsController < ApplicationController
  # Essa action usa parâmetros de query string porque ela é
  # executada através de uma requisição HTTP GET, mas isso
  # não faz nenhuma diferença para a maneira como os parâmetros
  # são acessados. A URL para essa action seria desse jeito
  # para mostrar os clientes ativos: /clients?status=activated
  def index
    if params[:status] == "activated"
      @clients = Client.activated
    else
      @clients = Client.inactivated
    end
  end

  # Essa action usa parâmetros de POST. Eles provavelmente estão
  # vindo de um formulário HTML que o usuário submeteu. A URL
  # para essa requisição RESTful será "/clients", e os dados
  # serão enviados como parte do corpo da requisição.
  def create
    @client = Client.new(params[:client])
    if @client.save
      redirect_to @client
    else
      # Essa linha sobrescreve o método padrão de renderização,
      # que seria chamado para renderizar a *view* "*create*"
      render "new"
    end
  end
end
```

### Hash e Parâmetros de Array

O *hash* `params` não é limitado a um vetor unidimensional de chaves e valores. Ele pode conter *arrays* e *hashes* aninhados. Para enviar um *array* de valores, concatene um par de colchetes vazio "[]" ao nome da chave:

```
GET /clients?ids[]=1&ids[]=2&ids[]=3
```

NOTE: A URL efetiva neste neste exemplo será codificada como "/clients?ids%5b%5d=1&ids%5b%5d=2&ids%5b%5d=3", visto que os caracteres "[" e "]" não são permitidos em URLs. Na maioria do tempo você não precisa se preocupar com isso porque o navegador irá codificar os dados para você, e o Rails vai decodificá-los automaticamente, porém se por acaso você se encontrar na situação de ter que enviar este tipo de requisição ao servidor manualmente você deve ter em mente essa questão.

O valor de `params[:ids]` será neste caso `["1", "2", "3"]`. Note que os valores de parâmetros são sempre *strings*; o Rails não tenta adivinhar ou converter o tipo.

NOTE: Valores como `[nil]` ou `[nil, nil, ...]` em `params` são substituídos por `[]` por motivos de segurança por padrão. Veja o [Guia de Segurança](security.html#unsafe-query-generation) para mais informações.

Para enviar um *hash*, você inclui o nome da chave dentro dos colchetes:

```html
<form accept-charset="UTF-8" action="/clients" method="post">
  <input type="text" name="client[name]" value="Acme" />
  <input type="text" name="client[phone]" value="12345" />
  <input type="text" name="client[address][postcode]" value="12345" />
  <input type="text" name="client[address][city]" value="Carrot City" />
</form>
```

Quando esse formulário é enviado o valor de `params[:client]` será `{ "name" => "Acme", "phone" => "12345", "address" => { "postcode" => "12345", "city" => "Carrot City" } }`. Repare o *hash* aninhado em `params[:client][:address]`.

O objeto `params` atua como um *hash*, mas permite que você use *symbols* e *strings* indistintamente como chaves.

### Parâmetros JSON

Se você está construindo uma aplicação *web*, você pode achar mais confortável receber parâmetros no formato JSON. Se o *header* "Content-Type" da sua requisição estiver definido como "application/json" o Rails vai automaticamente carregar os seus parâmetros no *hash* `params`, que você pode acessar como acessaria normalmente.

Então por exemplo, se você estiver enviando este conteúdo JSON:

```json
{ "company": { "name": "acme", "address": "123 Carrot Street" } }
```

O seu *controller* vai receber `params[:company]` no formato `{ "name" => "acme", "address" => "123 Carrot Street" }`.

Além disso, se você tiver ativado `config.wrap_parameters` no seu inicializador ou chamado `wrap_parameters` no seu *controller*, você pode omitir o elemento raiz no seu parâmetro JSON. Neste caso, os parâmetros serão clonados e enpacotados sob uma chave baseada no nome do seu *controller*. Então a requisição JSON acima pode ser escrita como:

```json
{ "name": "acme", "address": "123 Carrot Street" }
```

E, assumindo que você está enviando os dados para `CompaniesController`, eles serão então encapsulados na chave `:company` desta maneira:

```ruby
{ name: "acme", address: "123 Carrot Street", company: { name: "acme", address: "123 Carrot Street" } }
```

Você pode customizar o nome da chave ou parâmetros específicos que você quer envelopar consultando a [documentação da API](https://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html)

NOTE: Suporte para interpretar parâmetros XML foi extraído para uma *gem* chamada `actionpack-xml_parser`.

### Parâmetros de Rota

O *hash* `params` sempre irá conter as chaves `:controller` e `:action`, mas você deve usar os métodos `nome_do_controller` e `nome_da_action` para acessar estes valores. Quaisquer outros parâmetros definidos pela rota, como `:id`, também estarão disponíveis. Por exemplo, considere uma listagem de clientes onde a lista pode mostrar os clientes ativos e inativos. Nós podemos adicionar uma rota que captura o parâmetro `:status` numa URL "normalizada":

```ruby
get '/clients/:status', to: 'clients#index', foo: 'bar'
```

Neste caso, quando um usuário abrir a URL `/clients/active`, `params[:status]` estará definido como "active". Quando esta rota é usada, `params[:foo]` também será definido como "bar", como se tivesse sido enviado por meio da *query string*. O seu *controller* também irá receber `params[:action]` com o valor "index" e `params[:controller]` com o valor "clients".

### `default_url_options`

Você pode determinar parâmetros padrão globais para a geração de URLs definindo um método chamado `default_url_options` no seu *controller*. Este método deve retornar um *hash* com os dados padrão desejados, cujas chaves devem ser símbolos:

```ruby
class ApplicationController < ActionController::Base
  def default_url_options
    { locale: I18n.locale }
  end
end
```

Estas opções serão usadas como um ponto de partida na geração de URLs, então é possível que elas sejam sobrescritas pelas opções passadas para chamadas a `url_for`.

Se você definir `default_url_options` em `ApplicationController`, como no exemplo acima, estes padrões irão ser usados para todas as gerações de URL. O método pode também ser definido num *controller* específico, neste caso afetando somente as URLs geradas a partir desse escopo.

Numa requisição o método não é de fato chamado para toda URL gerada; por questões de performance o *hash* retornado é cacheado. Há no máximo uma invocação por requisição.

### Parâmetros Fortes

Com parâmetros fortes (*strong parameters*), os parâmetros do *Action Controller* são proibidos de serem usados nas atribuições em massa no *Active Model* até que sejam deliberadamente permitidos. Isso significa que você tem que tomar uma decisão consciente sobre quais atributos podem ser permitidos para um *update* em massa. Esta é uma prática mais segura para ajudar a prevenir que acidentalmente os usuários atualizem atributos sensíveis do *model*.

Além disso, os parâmetros podem ser marcados como obrigatórios e irão seguir por um fluxo de erro e tratamento predefinido que irá resultar num código 400 *Bad Request* sendo retornado caso todos os parâmetros obrigatórios não forem informados.

```ruby
class PeopleController < ActionController::Base
  # Isso vai lançar uma exceção do tipo ActiveModel::ForbiddenAttributesError
  # porque está usando atribuição em massa sem passar pela etapa de permitir
  # explicitamente os parâmetros.
  def create
    Person.create(params[:person])
  end

  # Isso irá passar contanto que exista uma chave de *person* nos parâmetros,
  # caso contrário o código irá lançar uma exceção do tipo
  # ActionController::ParameterMissing, que será capturada pelo
  # ActionController::Base e transformada num erro 400 Bad Request.
  def update
    person = current_account.people.find(params[:id])
    person.update!(person_params)
    redirect_to person
  end

  private
    # Usar um método privado para encapsular os parâmetros permissíveis
    # é um bom padrão visto que que você poderá reusar a mesma lista
    # para as actions create e update. Você também pode especificar
    # este método com a checagem de atributos permitidos de acordo com
    # cada usuário.
    def person_params
      params.require(:person).permit(:name, :age)
    end
end
```

#### Valores Escalares Permitidos

Dado o seguinte código:

```ruby
params.permit(:id)
```

a chave `:id` será permitida para inclusão se ela aparecer em `params` e ela tiver um valor escalar permitido associado a ela. Caso contrário a chave será filtrada, então *arrays*, *hashes*, ou quaisquer outros objetos não poderão ser adicionados.

Os tipos escalares permitidos são `String`, `Symbol`, `NilClass`, `Numeric`, `TrueClass`, `FalseClass`, `Date`, `Time`, `DateTime`, `StringIO`, `IO`, `ActionDispatch::Http::UploadedFile`, e `Rack::Test::UploadedFile`.

Para declarar que o valor em `params` deve ser um *array* de valores escalares permitidos, mapeie a chave para um *array* vazio.

```ruby
params.permit(id: [])
```

Às vezes não é possível ou conveniente declarar as chaves válidas de um parâmetro de *hash* ou sua estrutura interna. Apenas mapeie para um *hash* vazio:

```ruby
params.permit(preferences: {})
```

entretanto fique atento porque isso abre a porta para *input* arbitrário. Neste caso, `permit` garante que os valores na estrutura retornada são valores escalares permitidos e faz a filtragem de tudo o que houver além deles.

Para permitir um *hash* completo de parâmetros, o método `permit!` pode ser usado:

```ruby
params.require(:log_entry).permit!
```

Este código marca o *hash* de parâmetros `:log_entry` e qualquer *sub-hash* dele como valores permitidos e não verifica por escalares permitidos, sendo qualquer coisa a partir dele aceita.
Extremo cuidado deve ser considerado ao usar o método `permit!`, visto que ele irá permitir que todos os atuais e futuros atributos do `model` sejam preenchidos em massa.

#### Parâmetros Aninhados

Você também pode usar `permit` em parâmetros aninhados, da seguinte forma:

```ruby
params.permit(:name, { emails: [] },
              friends: [ :name,
                         { family: [ :name ], hobbies: [] }])
```

Esta declaração permite o preenchimento dos atributos `name`, `emails`, e `friends`. É esperado que `emails` seja um *array* de valores permitidos escalares, e que `friends` seja um *array* de recursos com atributos específicos: deve possuir um atributo `name` (com quaisquer valores escalares permitidos), um atributo `hobbies` como um *array* de valores permitidos escalares, e um atributo `family` que é restrito a ter um `name` (com qualquer valor escalar permitido também).

#### Mais Exemplos

Você pode também querer usar os atributos permitidos na sua *action* `new`. Isso traz o problema que você não pode chamar `require` na chave raiz porque normalmente ela não existe no momento da chamada de `new`

```ruby
# usando fetch você pode fornecer um valor padrão e visualizar
# a API de Parâmetros Fortes a partir dele.
params.fetch(:blog, {}).permit(:title, :author)
```

O método da classe *model* `accepts_nested_attributes_for` te permite atualizar e destruir outros *models* associados. Isso é baseado nos parâmetros `id` e `_destroy`:

```ruby
# permite :id e :_destroy
params.require(:author).permit(:name, books_attributes: [:title, :id, :_destroy])
```

*Hashes* com chaves de valor do tipo inteiro são tratados de maneira diferente, e você pode declarar os atributos como se eles fossem atributos filhos imediatos. Você obtém estes tipos de parâmetros quando você usa `accepts_nested_attributes_for` combinado com uma associação `has_many`:

```ruby
# Para permitir os seguintes dados:
# {"book" => {"title" => "Some Book",
#             "chapters_attributes" => { "1" => {"title" => "First Chapter"},
#                                        "2" => {"title" => "Second Chapter"}}}}
params.require(:book).permit(:title, chapters_attributes: [:title])
```

Imagine um cenário onde você tem parâmetros representando um nome de produto e um *hash* de dados arbitrários associado a esse produto, e você queira permitir o preenchimento do atributo de nome do produto e também o *hash* de dados:

```ruby
def product_params
  params.require(:product).permit(:name, data: {})
end
```

#### Fora do Escopo de Parâmetros Fortes

A API de parâmetros fortes foi desenhada com os casos mais comuns em mente. Não houve a intenção de torná-la uma bala prateada para lidar com todos os seus problemas de filtragem de parâmetros. Entretanto, você pode facilmente misturar a API com seu próprio código para se adaptar à sua situação.

Sessão
------

Sua aplicação possui uma sessão para cada usuário, na qual pode-se armazenar quantidades pequenas de dados que serão persistidos entre as requisições. A sessão fica disponível apenas no *controller* e na *view* e pode utilizar um dentre vários mecanismos diferentes de armazenamento:

* `ActionDispatch::Session::CookieStore` - Armazena tudo no cliente.
* `ActionDispatch::Session::CacheStore` - Armazena os dados no *cache* do Rails.
* `ActionDispatch::Session::ActiveRecordStore` - Armazena os dados em um banco de dados utilizando o *Active Record*. (a gem `activerecord-session_store` é necessária).
* `ActionDispatch::Session::MemCacheStore` - Armazena os dados em um *cluster* de *cache* de memória (esta é uma implementação legada; considere utilizar o *CacheStore* como alternativa)

Todos os armazenamentos de sessão utilizam um *cookie* para armazenar um ID único para cada sessão (você deve utilizar um *cookie*, o Rails não permitirá que você passe o ID da sessão na URL, pois isso é menos seguro).

Para a maioria dos armazenamentos, esse ID é utilizado para procurar os dados da sessão no servidor, por exemplo, em uma tabela do banco de dados. Há apenas uma exceção, que é o armazenamento de sessão recomendado por padrão - o *CookieStore* - que armazena todos os dados da sessão no próprio *cookie* (o ID ainda estará disponível para você, se você precisar). A vantagem é a de ser muito leve e requer zero configuração em uma nova aplicação para utilizar a sessão. Os dados do *cookie* são assinados criptograficamente para torná-los invioláveis, e também é criptografado para que qualquer pessoa com acesso não leia o seu conteúdo. (O Rails não aceitará se estiver sido editado).
O *CookieStore* pode armazenar cerca de 4kB de dados - muito menos que os demais - mas geralmente é o suficiente. O armazenamento de grandes quantidades de dados na sessão não é recomendado, independentemente de qual armazenamento de sessão sua aplicação utiliza. Você deve evitar armazenar objetos complexos (qualquer coisa que não sejam objetos Ruby básicos, o exemplo mais comum são instâncias de um *model*) na sessão, pois o servidor pode não ser capaz de remontá-los entre as requisições, o que resultará em um erro.

Se as suas sessões de usuário não armazenam dados críticos ou não precisam durar por longos períodos (por exemplo, se você apenas utiliza o *flash* para mensagens), considere o uso do `ActionDispatch::Session::CacheStore`. Isso armazenará as sessões utilizando a implementação de *cache* que você configurou para a sua aplicação. A vantagem é que você pode utilizar sua infraestrutura de *cache* existente para armazenar sessões sem precisar de nenhuma configuração ou administração adicional. A desvantagem é que as sessões serão temporárias e poderão desaparecer a qualquer momento.

Leia mais sobre armazenamento de sessão no [Guia de Segurança](security.html).

Se você precisar de um mecanismo diferente de sessão de armazenamento, você poderá alterá-lo no *initializer*:

```ruby
# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails g active_record:session_migration")
# Rails.application.config.session_store :active_record_store
```

O Rails configura uma chave de sessão (o nome do *cookie*) ao assinar os dados da sessão. Estes também podem ser alterados no *initializer*:

```ruby
# Be sure to restart your server when you modify this file.
Rails.application.config.session_store :cookie_store, key: '_your_app_session'
```

Você também pode passar uma chave `:domain` e especificar o nome do domínio para o *cookie*:

```ruby
# Be sure to restart your server when you modify this file.
Rails.application.config.session_store :cookie_store, key: '_your_app_session', domain: ".example.com"
```

O Rails configura (para o *CookieStore*) uma chave secreta utilizada para assinar os dados da sessão em `config/credentials.yml.enc`. Isso pode ser alterado com o comando `rails credentials:edit`.

```ruby
# aws:
#   access_key_id: 123
#   secret_access_key: 345

# Used as the base secret for all MessageVerifiers in Rails, including the one protecting cookies.
secret_key_base: 492f...
```

NOTE: Alterar a `secret_key_base` ao utilizar o `CookieStore` invalidará todas as sessões existentes.

### Acessando a Sessão

No seu *controller*, você pode acessar a sessão através do método de instância `session`.

NOTE: As sessões são [*lazy loading*](https://pt.wikipedia.org/wiki/Lazy_loading) (carregamento lento). Se você não acessá-las no código da sua *action*, elas não serão carregadas. Portanto, você nunca precisará desativar as sessões, basta apenas não acessá-las.

Os valores da sessão são armazenados utilizando pares de chave/valor como em um *hash*:

```ruby
class ApplicationController < ActionController::Base

  private

  # Finds the User with the ID stored in the session with the key
  # :current_user_id This is a common way to handle user login in
  # a Rails application; logging in sets the session value and
  # logging out removes it.
  def current_user
    @_current_user ||= session[:current_user_id] &&
      User.find_by(id: session[:current_user_id])
  end
end
```

Para armazenar algo na sessão, basta atribuí-lo à chave como em um *hash*:

```ruby
class LoginsController < ApplicationController
  # "Create" a login, aka "log the user in"
  def create
    if user = User.authenticate(params[:username], params[:password])
      # Save the user ID in the session so it can be used in
      # subsequent requests
      session[:current_user_id] = user.id
      redirect_to root_url
    end
  end
end
```

Para remover algo da sessão, exclua o par de chave/valor:

```ruby
class LoginsController < ApplicationController
  # "Delete" a login, aka "log the user out"
  def destroy
    # Remove the user id from the session
    session.delete(:current_user_id)
    # Clear the memoized current user
    @_current_user = nil
    redirect_to root_url
  end
end
```

Para redefinir a sessão inteira, utilize `reset_session`.

### The Flash

The flash is a special part of the session which is cleared with each request. This means that values stored there will only be available in the next request, which is useful for passing error messages etc.

It is accessed in much the same way as the session, as a hash (it's a [FlashHash](https://api.rubyonrails.org/classes/ActionDispatch/Flash/FlashHash.html) instance).

Let's use the act of logging out as an example. The controller can send a message which will be displayed to the user on the next request:

```ruby
class LoginsController < ApplicationController
  def destroy
    session.delete(:current_user_id)
    flash[:notice] = "You have successfully logged out."
    redirect_to root_url
  end
end
```

Note that it is also possible to assign a flash message as part of the redirection. You can assign `:notice`, `:alert` or the general purpose `:flash`:

```ruby
redirect_to root_url, notice: "You have successfully logged out."
redirect_to root_url, alert: "You're stuck here!"
redirect_to root_url, flash: { referral_code: 1234 }
```

The `destroy` action redirects to the application's `root_url`, where the message will be displayed. Note that it's entirely up to the next action to decide what, if anything, it will do with what the previous action put in the flash. It's conventional to display any error alerts or notices from the flash in the application's layout:

```erb
<html>
  <!-- <head/> -->
  <body>
    <% flash.each do |name, msg| -%>
      <%= content_tag :div, msg, class: name %>
    <% end -%>

    <!-- more content -->
  </body>
</html>
```

This way, if an action sets a notice or an alert message, the layout will display it automatically.

You can pass anything that the session can store; you're not limited to notices and alerts:

```erb
<% if flash[:just_signed_up] %>
  <p class="welcome">Welcome to our site!</p>
<% end %>
```

If you want a flash value to be carried over to another request, use the `keep` method:

```ruby
class MainController < ApplicationController
  # Let's say this action corresponds to root_url, but you want
  # all requests here to be redirected to UsersController#index.
  # If an action sets the flash and redirects here, the values
  # would normally be lost when another redirect happens, but you
  # can use 'keep' to make it persist for another request.
  def index
    # Will persist all flash values.
    flash.keep

    # You can also use a key to keep only some kind of value.
    # flash.keep(:notice)
    redirect_to users_url
  end
end
```

#### `flash.now`

By default, adding values to the flash will make them available to the next request, but sometimes you may want to access those values in the same request. For example, if the `create` action fails to save a resource and you render the `new` template directly, that's not going to result in a new request, but you may still want to display a message using the flash. To do this, you can use `flash.now` in the same way you use the normal `flash`:

```ruby
class ClientsController < ApplicationController
  def create
    @client = Client.new(params[:client])
    if @client.save
      # ...
    else
      flash.now[:error] = "Could not save client"
      render action: "new"
    end
  end
end
```

Cookies
-------

Sua Aplicação pode armazemar pequenas quantidades de dados no cliente - chamados de *cookies* - que serão mantidas entre requisições e até as sessões. O Rails fornece um fácil acesso para os *cookies* através do método `cookies`, que - assim como a `session` - funciona como um hash:

```ruby
class CommentsController < ApplicationController
  def new
    # Preencher automaticamente o nome de quem comentou se ele estiver armazenado em um cookie
    @comment = Comment.new(author: cookies[:commenter_name])
  end

  def create
    @comment = Comment.new(params[:comment])
    if @comment.save
      flash[:notice] = "Thanks for your comment!"
      if params[:remember_name]
        # Lembrar o nome de quem fez o comentário
        cookies[:commenter_name] = @comment.author
      else
        # Deletar o cookie do nome de quem fez o comentário, caso exista.
        cookies.delete(:commenter_name)
      end
      redirect_to @comment.article
    else
      render action: "new"
    end
  end
end
```

Perceba que enquanto para valores de sessão você define a chave como `nil`, para deletar um valor de *cookie* você deve usar ` cookies.delete(:key)`.

O Rails também fornece um *cookie jar* assinado e um *cookie jar* criptografado para amazenar
dados sensíveis. O *cookie jar* assinado anexa uma assinaura criptográfica nos
valores do *cookie* para proteger sua integridade. O *cookie jar* criptografado, criptografa os
valores além de assiná-los, para que eles não possam ser lidos pelo usuário final.
Consulte a [documentação da API (em inglês)](https://api.rubyonrails.org/classes/ActionDispatch/Cookies.html)
para mais detalhes.

Esses *cookie jars* especiais usam um *serializer* para serializar os valores atribuídos em
strings e desserializa-os em objetos Ruby na leitura.

Você pode especificar qual *serializer* usar:

```ruby
Rails.application.config.action_dispatch.cookies_serializer = :json
```

O *serializer* padrão para novas aplicações é `:json`. Para compatibilidade com
aplicações antigas que usam *cookies*, o `:marshal` é usado quando a opção
`serializer` não está especificada.

Você também pode definir esta opção como `:hybrid`, nesse caso o Rails desserializaria
de forma transparente os *cookies* (serializados no formato `Marshal`) existentes ao ler e reescrevê-los
no formaro `JSON`. Isso é útil para migrar aplicações existentes para o
*serializer* `:json`.

Também é possível passar um *serializer* personalizado que responda a `load` e
`dump`:

```ruby
Rails.application.config.action_dispatch.cookies_serializer = MyCustomSerializer
```

Ao usar o *serializer* `:json` ou `:hybrid`, lembre-se de que nem todos os
os objetos Ruby podem ser serializados como JSON. Por exemplo, objetos `Date` e` Time`
serão serializados como strings, e os `Hash`es terão suas chaves transformadas em string também.

```ruby
class CookiesController < ApplicationController
  def set_cookie
    cookies.encrypted[:expiration_date] = Date.tomorrow # => Thu, 20 Mar 2014
    redirect_to action: 'read_cookie'
  end

  def read_cookie
    cookies.encrypted[:expiration_date] # => "2014-03-20"
  end
end
```

É aconselhável que você armazene apenas dados simples (strings e números) nos *cookies*.
Se você precisar armazenar objetos complexos, precisará lidar com a conversão
manualmente ao ler os valores em requisições subsequentes.

Se você usar o *cookie* de armazenamento de sessão, isso também se aplicaria aos *hashes* `session` e `flash`.

Renderizando dados XML e JSON
---------------------------

O *ActionController* faz com que renderizar dados `XML` ou `JSON` seja extremamente fácil. Se você gerou um *controller* usando o *scaffold*, será algo mais ou menos assim:

```ruby
class UsersController < ApplicationController
  def index
    @users = User.all
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @users }
      format.json { render json: @users }
    end
  end
end
```

Você pode observar que no código acima estamos usando `render xml: @users`, e não `render xml: @users.to_xml`. Se o objeto não é uma *String*, então o Rails automaticamente chama `to_xml` por nós.

Filtros
-------

Filtros são métodos que rodam "before" (antes de), "after" (depois de) ou "around" (em torno de) de uma ação de *controller*.

Filtros são herdados, então se você configurou um filtro em `ApplicationController`, o mesmo irá rodar em cada *controller* da sua aplicação.

Filtros "before" podem interromper o ciclo de uma requisição. Um filtro comum para "before" é o que requer que um usuário está logado para que uma ação seja executada. Você pode definir o método do filtro dessa forma:

```ruby
class ApplicationController < ActionController::Base
  before_action :require_login

  private

  def require_login
    unless logged_in?
      flash[:error] = "You must be logged in to access this section"
      redirect_to new_login_url # interrompe o ciclo da requisição
    end
  end
end
```
Esse método simplesmente armazena uma mensagem de erro no *flash* e redireciona para o formulário de login se o usuário não estiver logado. Se um filtro "before" renderiza ou redireciona, a ação não será executada. Se filtros adicionais estão programados para executar após esse filtro, eles são cancelados também.

Nesse exemplo o filtro é adicionado ao `ApplicationController` e dessa forma todos os *controllers* na aplicação irão herdar ele. Isso fará com que tudo na aplicação requeira que o usuário esteja logado para que ele possa usar. Por razões óbvias (o usuário não conseguiria fazer o log in para começo de conversa!), nem todos os *controllers* devem requerer isso. Você pode evitar esse filtro de ser executado antes de ações em particular com `skip_before_action`:

```ruby
class LoginsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
end
```

Agora, as ações de `new` e `create` do `LoginsController` irão funcionar como antes sem requerer que o usuário esteja logado. A opção `:only` é usada para pular esse filtro somente para essas ações, e existe também a opção `:except` que funciona de maneira contrária. Essas opções podem ser utilizadas quando adicionamos filtros também, para que você possa adicionar um filtro que somente executa para as ações selecionadas.

NOTE: Chamar o mesmo filtro múltiplas vezes com diferentes opções não irá funcionar,
já que a última definição do filtro irá sobreescrever as anteriores.

### Filtros after e around

Além de filtros "before", você pode também executar filtros depois que uma ação tenha sido executada, ou antes e depois em conjunto.

Filtros "after" são similares aos filtros "before", mas porque a ação já foi executada eles tem acesso a dados da resposta que serão enviados para o cliente. Obviamente, filtros "after" não podem impedir uma ação de ser executada. Note também que filtros "after" são executados somente após uma ação bem sucedida, mas não quando uma exceção é gerada durante o ciclo de uma requisição.

Filtros "around" são responsáveis por executar as ações associadas por *yield*, simular a como os *middlewares* do Rack funcionam.

Por exemplo, em um *website* aonde alterações possuem um fluxo de aprovação, um administrador pode pré-visualizar as mesmas facilmente, aplicando-as dentro de uma transação.

```ruby
class ChangesController < ApplicationController
  around_action :wrap_in_transaction, only: :show

  private

  def wrap_in_transaction
    ActiveRecord::Base.transaction do
      begin
        yield
      ensure
        raise ActiveRecord::Rollback
      end
    end
  end
end
```

Note que um filtro "around" também envolvem a renderização. Em particular, se no exemplo acima, a view efetuar uma leitura no banco de dados (p. ex. usando um *scope*), a mesma é efetuada dentro de uma transação e então apresenta a informação para visualização.

Você pode escolher não efetuar *yield* e montar a resposta você mesmo, o que faria com que a ação não fosse executada.

### Outras formas de usar

Enquanto a forma mais comum de se utilizar filtros é criando métodos privados e usando *_action para adicioná-los, existem duas outras formas para fazer a mesma coisa.

A primeira é utilizar um bloco diretamente com método *\_action. O bloco recebe o *controller* como um argumento. O filtro `require_login` acima pode ser reescrito para utilizar um bloco:

```ruby
class ApplicationController < ActionController::Base
  before_action do |controller|
    unless controller.send(:logged_in?)
      flash[:error] = "Você deve estar logado para acessar essa seção"
      redirect_to new_login_url
    end
  end
end
```

Note nesse caso que o filtro utiliza `send` porque o método `logged_in?` é privado e o filtro não é executado no escopo do *controller*. Essa não é a forma recomendada para implementar esse filtro em particular, mas ele pode ser útil em casos mais simples.

Especificamente para `around_action`, o bloco também acessa a `action`:

```ruby
around_action { |_controller, action| time(&action) }
```

A segunda forma é utilizar uma classe (na verdade, qualquer objeto que responda aos métodos corretos serve) para gerenciar a filtragem. Isto é útil em casos mais complexos que não são possíveis de serem implementados de uma forma de fácil leitura e reutilizados usando as outras duas abordagens. Por exemplo, você pode reescrever o filtro de login novamente utilizando uma classe:

```ruby
class ApplicationController < ActionController::Base
  before_action LoginFilter
end

class LoginFilter
  def self.before(controller)
    unless controller.send(:logged_in?)
      controller.flash[:error] = "Você deve estar logado para acessar essa seção"
      controller.redirect_to controller.new_login_url
    end
  end
end
```

Novamente, esse não é um exemplo ideal para esse filtro, pois não é executado dentro do escopo do *controller* mas recebe o mesmo como um argumento. A classe de filtro deve implementar um método com o mesmo nome do filtro, então para o filtro de `before_action` a classe deve implementar um método `before`, e assim em diante. O método `around` deve efetuar `yield` para executar a ação.

Proteção de falsificação de requisição
--------------------------

Falsificação de requisições *cross-site* é um tipo de ataque no qual o site engana o usuário a fim de que ele faça requisições em outro site, possivelmente adicionando, alterando ou deletando informações naquela site sem o conhecimento ou a permissão do usuário.

O primeiro passo para evitar isso é ter certeza que todas as ações "destrutivas" (criar, atualizar, e destruir) possam ser acessadas somente via requisições que não sejam *GET*. Se você está seguindo as convenções *RESTful* você já está fazendo isso. Contudo, sites maliciosos continuam podendo enviar requisições não *GET* para o seu site facilmente, e é aí que a proteção de falsificação de requisição entra. Como o nome diz, ela te protege de requisições falsas.

A forma como isso é feito é adicionando um *token* não adivinhável que é conhecido apenas pelo seu servidor para cada requisição. Desta forma, se uma requisição chega sem um token conhecido, o seu acesso será negado.

Se você gera um *form* como este:

```erb
<%= form_with model: @user, local: true do |form| %>
  <%= form.text_field :username %>
  <%= form.text_field :password %>
<% end %>
```

Você perceberá como o *token* é adicionado como um campo invisível.

```html
<form accept-charset="UTF-8" action="/users/1" method="post">
<input type="hidden"
       value="67250ab105eb5ad10851c00a5621854a23af5489"
       name="authenticity_token"/>
<!-- fields -->
</form>
```

O Rails adiciona esse *token* para cada *form* que é gerado usando o [*form helpers*](form_helpers.html), então na maior parte das vezes você não precisa se preocupar com isso. Se você está escrevendo um *form* manualmente ou precisa adicionar o *token* para outra sessão, ele está disponível por meio do método `form_authenticity_token`.

O `form_authenticity_token` gera um *token* de autenticação válido. Isso é útil em lugar aonde o Rails não adiciona o mesmo automaticamente, como em chamadas Ajax personalizadas.

O [Guia de segurança](security.html) possui mais informações sobre isso e muitos outros problemas relacionados a segurança que você deve estar ciente quando desenvolve uma aplicação *web*.

Os Objetos de Requisição e Resposta
--------------------------------

Em todo *controller* existem dois métodos de acesso apontando para os objetos de requisição e de resposta associados com o ciclo de requisição que estiver em execução no momento. O método `request` contém uma instância de `ActionDispatch::Request` e o método `response` retorna um objeto de resposta representando o que será enviado de volta ao cliente.

### O Objeto `request`

O objeto de requisição contém muitas informações úteis sobre a requisição proveniente do cliente. Para obter uma lista completa dos métodos disponíveis verifique a [documentação da API do Rails](https://api.rubyonrails.org/classes/ActionDispatch/Request.html) e a [documentação do Rack](https://www.rubydoc.info/github/rack/rack/Rack/Request). Entre as propriedades que você pode acessar estão:

| Propriedade de `request`                     | Propósito                                                                          |
| ----------------------------------------- | --------------------------------------------------------------------------------  |
| host                                      | O *hostname* utilizado para esta requisição.                                      |
| domain(n=2)                               | Os primeiros `n` segmentos do *hostname*, iniciando pela direita (o domínio de primeiro nível).       |
| format                                    | O tipo de conteúdo requisitado pelo cliente.                                      |
| method                                    | O método HTTP utilizado para a requisição.                                        |
| get?, post?, patch?, put?, delete?, head? | Retorna *true* se o método HTTP é GET/POST/PATCH/PUT/DELETE/HEAD.                 |
| headers                                   | Retorna um *hash* contendo os *headers* associados com a requisição.              |
| port                                      | O número (*integer*) da porta utilizada para a requisição.                        |
| protocol                                  | Retorna uma *string* contendo o protocolo utilizado, além do trecho "://". Por exemplo: "http://". |
| query_string                              | A *query string* da URL (todo o trecho após "?").                                 |
| remote_ip                                 | O endereço IP do cliente.                                                         |
| url                                       | A URL completa utilizada para a requisição.                                       |

#### `path_parameters`, `query_parameters`, e `request_parameters`

O *Rails* armazena todos os parâmetros enviados com a requisição no *hash* `params`, não importando se eles foram enviados como parte da *query string* ou no corpo da requisição. O objeto de requisição tem três métodos de acesso que te fornecem acesso a estes parâmetros dependendo de onde eles vieram. O *hash* `query_parameters` contem os parâmetros que foram enviados por meio da *query_string* enquanto o *hash* `request_parameters` contem os parâmetros enviados através do corpo da requisição. O *hash* `path_parameters` contém os parâmetros que foram reconhecidos pelo roteamento como parte do caminho que leva ao *controller* e *action* sendo executados.

### O Objeto `response`

O objeto de resposta geralmente não é usado diretamente, mas é construído durante a execução da *action* e renderização dos dados que serão enviados de volta ao usuário, porém às vezes - como num filtro posterior - ele pode ser útil para acessar a resposta diretamente. Alguns destes métodos de acesso também possuem *setters*, lhe permitindo mudar seus valores. Para obter uma lista completa dos métodos disponíveis verifique a [documentação da API do Rails](https://api.rubyonrails.org/classes/ActionDispatch/Response.html) e a [documentação do Rack](https://www.rubydoc.info/github/rack/rack/Rack/Response);

| Propriedade de `response` | Propósito                                                                                             |
| ---------------------- | --------------------------------------------------------------------------------------------------- |
| body                   | Esta é a *string* de dados sendo enviada de volta ao usuário. Na maioria dos casos se trata de código HTML.    |
| status                 | O código de *status* HTTP para a resposta, como um código 200 para uma requisição bem sucedida ou 404 para um arquivo não encontrado.    |
| location               | A URL que o cliente estiver sendo redirecionado para, caso haja alguma.                 |
| content_type           | O tipo de conteúdo da resposta.                                                         |
| charset                | O conjunto de caracteres sendo utilizado na resposta. O valor padrão é "utf-8".         |
| headers                | *Headers* utilizados para a resposta.                                                   |

#### Definindo *Headers* customizados

Se você quer definir *headers* customizados para uma resposta então `response.headers` é o local indicado para ajustar isto. O atributo *headers* é um *hash* que mapeia os nomes dos *headers* para seus respectivos valores, e o Rails irá definir alguns deles automaticamente. Se você quiser adicionar ou modificar um *header*, basta sinalizá-lo para `response.headers` da seguinte maneira:

```ruby
response.headers["Content-Type"] = "application/pdf"
```

NOTE: No caso acima faria mais sentido utilizar o *setter* `content_type` diretamente.

Autenticações HTTP
------------------

O Rails vem com dois mecanismos de autenticação HTTP embutidos:

* Autenticação *Basic*
* Autenticação *Digest*

### Autenticação HTTP *Basic*

Autenticação HTTP *basic* é um esquema de autenticação que é suportado pela maioria dos navegadores e outros clientes HTTP. Como um exemplo, considere uma página de administração que será acessável apenas informando um nome de usuário e uma senha na janela de autenticação HTTP *basic* do navegador. Usar a autenticação embutida é bem fácil e apenas requer que você use um método, `http_basic_authenticate_with`.

```ruby
class AdminsController < ApplicationController
  http_basic_authenticate_with name: "humbaba", password: "5baa61e4"
end
```

Com isso, você pode criar *controllers* com *namespaces* que herdam de `AdminsController`. O filtro vai, assim, ser executado para todas as ações nos *controllers*, protegendo-os com a autenticação HTTP *basic*.

### Autenticação HTTP *Digest*

A autenticação HTTP *digest* é superior à autenticação *basic* porque ela não requer que o cliente envie uma senha sem criptografia pela rede (embora a autenticação HTTP *basic* seja segura via HTTPS). Usar a autenticação *digest* com Rails é bem fácil e requer apenas o uso de um método, `authenticate_or_request_with_http_digest`.

```ruby
class AdminsController < ApplicationController
  USERS = { "lifo" => "world" }

  before_action :authenticate

  private

    def authenticate
      authenticate_or_request_with_http_digest do |username|
        USERS[username]
      end
    end
end
```

Como visto no exemplo acima, o bloco `authenticate_or_request_with_http_digest` recebe apenas um argumento - o nome de usuário. E o bloco retorna a senha. Retornar `false` ou `nil` em `authenticate_or_request_with_http_digest` causará falha de autenticação.

*Streaming* e *Downloads* de Arquivos
----------------------------

Às vezes você pode querer enviar um arquivo para o usuário ao invés de uma página HTML. Todos os _controllers_ no Rails possuem os métodos `send_data` e `send_file`, que transmitem dados ao navegador. O método `send_file` permite que você proveja o nome do arquivo no disco e seu conteúdo será transmitido.

Para transmitir dados para o navegador, use `send_data`:

```ruby
require "prawn"
class ClientsController < ApplicationController
  # Gera um documento PDF com informações no navegador e 
  # o retorna. O usuário receberá o documento PDF como um download.
  def download_pdf
    client = Client.find(params[:id])
    send_data generate_pdf(client),
              filename: "#{client.name}.pdf",
              type: "application/pdf"
  end

  private

    def generate_pdf(client)
      Prawn::Document.new do
        text client.name, align: :center
        text "Address: #{client.address}"
        text "Email: #{client.email}"
      end.render
    end
end
```

A _action_ `download_pdf` no exemplo acima está chamando um método privado que na verdade cria o documento PDF e o retorna como uma _string_. Essa _string_ será então transmitida ao navegador como um arquivo para download e o nome do arquivo será sugerido ao usuário. Às vezes, quando arquivos são transmitidos aos usuários, você pode não querer que façam o download do arquivo. Imagens, por exemplo, podem ser embutidas em páginas HTML. Para comunicar ao navegador que não deve ser feito o download do arquivo, você pode utilizar a propriedade `inline` na opção `:disposition`. A propriedade oposta e padrão para essa opção é "_attachment_".

### Enviando Arquivos

Se você deseja enviar um arquivo que já existe no disco, utilize o método `send_file`.

```ruby
class ClientsController < ApplicationController
  # Transmite um arquivo que já foi gerado e salvo no disco.
  def download_pdf
    client = Client.find(params[:id])
    send_file("#{Rails.root}/files/clients/#{client.id}.pdf",
              filename: "#{client.name}.pdf",
              type: "application/pdf")
  end
end
```

Esse método irá ler e transmitir o arquivo 4kb por vez, evitando carregar o arquivo inteiro em memória de uma vez. Você pode desativar a transmissão com a opção `:stream` ou ajustar o tamanho do bloco com a opção `:buffer_size`.

Se a opção `:type` não for especificada, será presumido de acordo com a extensão especificada no `:filename`. Se o tipo do conteúdo (`content_type`) não estiver registrado para a extensão, será usado `application/octet-stream`.

WARNING:  Tenha cuidado ao utilizar dados vindos do navegador ( _params_, _cookies_, etc.) para localizar um arquivo no disco, pois é um risco de segurança que pode permitir a alguém ter acesso a arquivos não permitidos.

TIP: Não é recomendado que você transmita arquivos estáticos através do Rails, você pode, ao invés disso, mantê-los em uma pasta pública no seu servidor _web_. É muito mais eficiente deixar os usuários baixarem os arquivos diretamente utilizando _Apache_ ou outro servidor _web_, evitando que a requisição passe, sem necessidade, por todo o fluxo do Rails.

### _RESTful_ _Downloads_

Apesar de o método `send_data` funcionar tranquilamente, se você está criando uma aplicação _RESTful_, geralmente não é necessário ter _actions_ separadas para o _download_ de arquivos. Na terminologia _REST_, o arquivo PDF do exemplo acima pode ser considerado apenas uma outra representação do recurso do navegador. Rails provê um jeito fácil e prático de fazer "downloads _RESTful_". Veja como você pode re-escrever o exemplo para que o _download_ do PDF seja parte da _action_ `show`, sem qualquer transmissão:

```ruby
class ClientsController < ApplicationController
  # O usuário pode solicitar receber este recurso como HTML ou PDF.
  def show
    @client = Client.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf { render pdf: generate_pdf(@client) }
    end
  end
end
```

Para que este exemplo funcione, você deve adicionar o `MIME type` ao Rails. Isso pode ser feito adicionando a seguinte linha ao arquivo `config/initializers/mime_types.rb`:

```ruby
Mime::Type.register "application/pdf", :pdf
```

NOTE: Arquivos de configuração não são recarregados a cada requisição, então você precisa reiniciar seu servidor para que as mudanças façam afeito.

Agora os usuários podem requerer um arquivo em PDF só adicionando ".pdf" ao final da _URL_:

```bash
GET /clients/1.pdf
```

### Transmissão Ao Vivo de Dado Arbitrários

O Rails permite que você transmita mais do que apenas arquivos. Na verdade, você pode transmitir o que você desejar como um objeto de resposta. O modulo `ActionController::Live` permite a você criar uma conexão persistente com o navegador. Utilizando esse módulo, você é capaz de enviar dados arbitrários ao navegador sem depender de uma requisição _HTTP_.

#### Implementando Transmissão Ao Vivo ( _Live Streaming_ )

Incluindo `ActionController::Live` dentro da sua classe _controller_ irá prover a todas as _actions_ do seu _controller_ a habilidade de transmitir dados. Você pode mesclar o modulo da seguinte forma:

```ruby
class MyController < ActionController::Base
  include ActionController::Live

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    100.times {
      response.stream.write "hello world\n"
      sleep 1
    }
  ensure
    response.stream.close
  end
end
```

O código acima manterá uma conexão constante com o navegador e mandará 100 mensagens de `"hello world\n"`, cada uma com um segundo de diferença. 

Existem algumas coisas a serem notadas no exemplo acima. Nós precisamos ter certeza de que a resposta da transmissão foi terminada. Esquecer de encerrar a transmissão deixará o *socket* aberto pra sempre. Nós também precisamos estabelecer o tipo de conteúdo (_`content_type`_) para `text/event-stream` antes de responder a transmissão. Isso é necessário, pois _headers_ não podem ser escritos depois que uma resposta foi enviada (quando `response.committed?` retorna um valor _truthy_ ), que ocorre quando você escreve ou envia (`commit`) a resposta de uma transmissão.

#### Exemplo de Uso

Vamos supor que você estivesse criando uma máquina de Karaokê e um usuário quer achar a letra de uma música em particular. Cada música (`Song`) tem um número específico de linhas e cada linha tem um tempo (`num_beats`) para terminar de ser cantada.

Se nós quiséssemos retornar as letras no estilo de Karaokê (mandar a linha só quando a linha anterior for terminada de cantar), então poderíamos usar `ActionController::Live` da seguinte forma:

```ruby
class LyricsController < ActionController::Base
  include ActionController::Live

  def show
    response.headers['Content-Type'] = 'text/event-stream'
    song = Song.find(params[:id])

    song.each do |line|
      response.stream.write line.lyrics
      sleep line.num_beats
    end
  ensure
    response.stream.close
  end
end
```

O código acima envia a próxima linha apenas depois que a pessoa cantando completou a linha anterior.

#### Considerações da Transmissão

Transmitir dados arbitrários é uma ferramenta extremamente poderosa. Como mostrado nos exemplos anteriores, você pode escolher quando e o que enviar na resposta da transmissão. Entretanto, você deveria se atentar aos seguintes pontos:

* Cada transmissão cria uma nova _thread_ e copia sobre as variáveis locais da 
  _thread_, as variáveis da _thread_ original. Ter muitas variáveis locais em uma
  _thread_ local pode impactar negativamente na performance. Da mesma forma, um 
  grande número de _threads_ pode também piorar a performance.
* Deixar de encerrar a transmissão deixará o _socket_ correspondente aberto para 
  sempre. Certifique-se de chamar o método `close` sempre que estiver transmitindo
  dados.
* Os servidores WEBrick armazena todas as respostas, então apenas incluir no 
  _controller_ `ActionController::Live` não irá funcionar. Você deve usar um 
  servidor web que não armazene automaticamente as respostas.

Filtragem de Log
-------------

Rails mantém um arquivo de log pra cada ambiente na pasta `log`. Eles são bastante úteis quando estamos depurando o que está de fato acontecendo na sua aplicação, porém você pode não querer que sejam salvos todas as informações sejam armazenadas no arquivo de log em uma aplicação ativa.

### Filtrando Parâmetros

Você pode evitar que parâmetros sensíveis da requisição sejam salvos no seu arquivo de log adicionando-os a `config.filter_parameters` na configuração da aplicação. Esses parâmetros aparecerão como [FILTERED] no arquivo de log.

```ruby
config.filter_parameters << :password
```

NOTE: Os Parâmetros fornecidos serão filtrados correspondendo parcialmente a uma expressão regular. Rails por padrão adiciona `:password` no *initializer* apropriado (`initializers/filter_parameter_logging.`) e se preocupa com parâmetros típicos da aplicação `password` e `password_confirmation`.

### Filtrando Redirecionamentos

Às vezes é desejável que sejam filtrados dos arquivos de log alguns locais sensíveis para os quais sua aplicação está redirecionando.
Você pode fazer isso utilizando uma opção de configuração `config.filter_redirect`:

```ruby
config.filter_redirect << 's3.amazonaws.com'
```

Você pode utilizar uma _String_, uma expressão regular ou um array com ambos.

```ruby
config.filter_redirect.concat ['s3.amazonaws.com', /private_path/]
```

_URLs_ correspondentes com a expressão regular serão marcadas como  '[FILTERED]'.

Rescue
------

Muito provavelmente sua aplicação irá conter bugs ou enviar exceções que precisam ser tratadas. Por exemplo, se o usuário acessar um link que não possui uma fonte no banco de dados, o Active Record enviará `ActiveRecord::RecordNotFound` como exceção.

A exceção padrão do Rails apresenta a mensagem "500 Server Error" para todas as exceções. Se a requisição for feita localmente, um belo *traceback* e outras informações serão mostradas assim você pode verificar o que deu errado e tratar o problema. Se a requisição for remota o Rails apenas apresentará a mensagem "500 Server Error" para o usuário, ou um "404 Not Found" se houver um erro na rota ou o registro não puder ser encontrado. As vezes você pode querer customizar como esses erros são encontrados e como são apresentados ao usuário. Há diversos níveis de tratamento de excessões disponiveis em uma aplicação Rails:

### Os *Templates* 404 e 500 Padrão

Por padrão uma aplicação em produção irá renderizar uma mensagem em um template de erro 404 ou 500, no ambiente de produção todas as mensagens de erro são disparadas. Essas mensagens são armazenadas em templates estáticos de HTML na pasta *public*, em `404.html` e `500.html` respectivamente. Você pode customizar essas páginas e adicionar algumas estilizações, mas lembre-se elas são HTML estático; i.e. você não pode usar ERB, SCSS, CoffeeScript, ou layouts para elas.

### `rescue_from`

Se você quiser fazer algo mais elaborado quando estiver lidando com erros, você pode usar `rescue_from`, que trata as exceções de um certo tipo (ou de vários tipos) em um *controller* inteiro e nas subclasses.

Quando uma exceção acontece e é pega por uma diretiva `rescue_from`, o objeto da exceção é passado ao *handler*. O *handler* pode ser um método ou um objeto `Proc` passado com a opção `:with`. Você também pode usar um bloco diretamente ao invés de um objeto `Proc`.

Aqui está um exemplo de como você pode usar `rescue_from` para interceptar todos os erros `ActiveRecord::RecordNotFound` e fazer algo com eles.

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

    def record_not_found
      render plain: "404 Not Found", status: 404
    end
end
```

É claro, que este exemplo não é nada elaborado e não melhora muito a forma original de lidar com os erros, mas uma vez que você capture todas essas exceções você é livre para fazer o que quiser com elas. Por exemplo, você pode criar uma exceção personalizada para quando o usuário não tem acesso a uma parte da aplicação:

```ruby
class ApplicationController < ActionController::Base
  rescue_from User::NotAuthorized, with: :user_not_authorized

  private

    def user_not_authorized
      flash[:error] = "You don't have access to this section."
      redirect_back(fallback_location: root_path)
    end
end

class ClientsController < ApplicationController
  # Check that the user has the right authorization to access clients.
  before_action :check_authorization

  # Note how the actions don't have to worry about all the auth stuff.
  def edit
    @client = Client.find(params[:id])
  end

  private

    # If the user is not authorized, just throw the exception.
    def check_authorization
      raise User::NotAuthorized unless current_user.admin?
    end
end
```

WARNING: Ao usar `rescue_from` com `Exception` ou `StandardError` pode causar efeitos colaterais já que previne o Rails de lidar com as exceções apropriadamente. Dessa forma, não é recomendado fazer sem uma boa razão.

NOTE: Quando rodando em ambiente de desenvolvimento, todos os erros
`ActiveRecord::RecordNotFound` renderizam uma página 404. A não ser que você precise de uma forma especifica de tratar isso você não precisa tratar isso.

NOTE: Certas exceções são tratadas apenas pela classe `ApplicationController`, já que são acionadas antes do controller ser iniciado a exceção é executada.

Forçar protocolo HTTPS
--------------------

Se você quiser garantir que a comunicação com seu *controller* seja possível apenas
via HTTPS, você deve fazer isso ativando o middleware `ActionDispatch::SSL` via
`config.force_ssl` na configuração do seu ambiente.
