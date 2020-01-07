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

Rendering XML and JSON data
---------------------------

ActionController makes it extremely easy to render `XML` or `JSON` data. If you've generated a controller using scaffolding, it would look something like this:

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

You may notice in the above code that we're using `render xml: @users`, not `render xml: @users.to_xml`. If the object is not a String, then Rails will automatically invoke `to_xml` for us.

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

Nesse exemplo o filtro é adicionado ao `ApplicationController` e dessa forma todos os *controllers* na aplicaçào irão herdar ele. Isso fará com que tudo na aplicação requera que o usuário esteja logado para que ele possa usar. Por razões óbvias (o usuário não conseguiria fazer o log in para começo de conversa!), nem todos os *controllers* devem requerer isso. Você pode evitar esse filtro de ser executado antes de ações em particular com `skip_before_action`:

```ruby
class LoginsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]
end
```

Agora, as ações de `new` e `create` do `LoginsController` irão funcionar como antes sem requerer que o usuário esteja logado. A opção `:only` é usada para pular esse filtro somente para essas ações, e existe também a opção `:except` que funciona de maneira contrária. Essas opções podem ser utilizadas quando adicionamos filtros também, para que você possa adicionar um fltro que somente executa para as ações selecionadas.

NOTE: Chamar o mesmo filtro múltiplas vezes com diferentes opções não irá funcionar,
já que a última definição do filtro irá sobreescrever as anteriores.

### Filtros after e around

Além de filtros "before", você pode também executar filtros depois que uma ação tenha sido executada, ou antes e depois em conjunto.

Filtros "after" são similares aos filtros "before", mas porque a ação já foi executada eles tem acesso a dados da resposta que serão enviados para o cliente. Obviamente, filtros "after" não podem impedir uma ação de ser executada. Note também que filtros "after" são executados somente após uma ação bem sucedida, mas não quando uma exceção é gerada durante o ciclo de uma requisição.

Filtros "around" são responsáveis por executar as ações associadas por *yield*, simular a como os *middlewares* do Rack funcionam.

Por exemplo, em um *website* aonde alterações possuem um fluxo de aprovação um administrador pode pré visualizar as mesmas facilmente, aplicando as dentro de uma transação.

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

Enquanto a forma mais comum de se utilizar filtros é criando métodos privados e usando *_action para adiciona-los, existem duas outras formas para fazer a mesma coisa.

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

Note nesse caso que o filtro utiliza `send`  porque o método `logged_in?` é privado e o filtro não é executado no escopo do *controller*. Essa não é a forma recomendada para implementar esse filtro em particular, mas ele pode ser útil em casos mais simples.

A segunda forma é utilizar uma classe (na verdade, qualquer objeto que resposta os métodos corretos serve) para gerenciar a filtragem. Isto é útil em casos mais complexos que não são possíveis de serem implementados de uma forma de fácil leitura e reutilizados usando as outras duas abordagens. Por exemplo, você pode reescrever o filtro de login novamente utilizando uma classe:

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

Request Forgery Protection
--------------------------

Cross-site request forgery is a type of attack in which a site tricks a user into making requests on another site, possibly adding, modifying, or deleting data on that site without the user's knowledge or permission.

The first step to avoid this is to make sure all "destructive" actions (create, update, and destroy) can only be accessed with non-GET requests. If you're following RESTful conventions you're already doing this. However, a malicious site can still send a non-GET request to your site quite easily, and that's where the request forgery protection comes in. As the name says, it protects from forged requests.

The way this is done is to add a non-guessable token which is only known to your server to each request. This way, if a request comes in without the proper token, it will be denied access.

If you generate a form like this:

```erb
<%= form_with model: @user, local: true do |form| %>
  <%= form.text_field :username %>
  <%= form.text_field :password %>
<% end %>
```

You will see how the token gets added as a hidden field:

```html
<form accept-charset="UTF-8" action="/users/1" method="post">
<input type="hidden"
       value="67250ab105eb5ad10851c00a5621854a23af5489"
       name="authenticity_token"/>
<!-- fields -->
</form>
```

Rails adds this token to every form that's generated using the [form helpers](form_helpers.html), so most of the time you don't have to worry about it. If you're writing a form manually or need to add the token for another reason, it's available through the method `form_authenticity_token`:

The `form_authenticity_token` generates a valid authentication token. That's useful in places where Rails does not add it automatically, like in custom Ajax calls.

The [Security Guide](security.html) has more about this and a lot of other security-related issues that you should be aware of when developing a web application.

The Request and Response Objects
--------------------------------

In every controller there are two accessor methods pointing to the request and the response objects associated with the request cycle that is currently in execution. The `request` method contains an instance of `ActionDispatch::Request` and the `response` method returns a response object representing what is going to be sent back to the client.

### The `request` Object

The request object contains a lot of useful information about the request coming in from the client. To get a full list of the available methods, refer to the [Rails API documentation](https://api.rubyonrails.org/classes/ActionDispatch/Request.html) and [Rack Documentation](https://www.rubydoc.info/github/rack/rack/Rack/Request). Among the properties that you can access on this object are:

| Property of `request`                     | Purpose                                                                          |
| ----------------------------------------- | -------------------------------------------------------------------------------- |
| host                                      | The hostname used for this request.                                              |
| domain(n=2)                               | The hostname's first `n` segments, starting from the right (the TLD).            |
| format                                    | The content type requested by the client.                                        |
| method                                    | The HTTP method used for the request.                                            |
| get?, post?, patch?, put?, delete?, head? | Returns true if the HTTP method is GET/POST/PATCH/PUT/DELETE/HEAD.               |
| headers                                   | Returns a hash containing the headers associated with the request.               |
| port                                      | The port number (integer) used for the request.                                  |
| protocol                                  | Returns a string containing the protocol used plus "://", for example "http://". |
| query_string                              | The query string part of the URL, i.e., everything after "?".                    |
| remote_ip                                 | The IP address of the client.                                                    |
| url                                       | The entire URL used for the request.                                             |

#### `path_parameters`, `query_parameters`, and `request_parameters`

Rails collects all of the parameters sent along with the request in the `params` hash, whether they are sent as part of the query string or the post body. The request object has three accessors that give you access to these parameters depending on where they came from. The `query_parameters` hash contains parameters that were sent as part of the query string while the `request_parameters` hash contains parameters sent as part of the post body. The `path_parameters` hash contains parameters that were recognized by the routing as being part of the path leading to this particular controller and action.

### The `response` Object

The response object is not usually used directly, but is built up during the execution of the action and rendering of the data that is being sent back to the user, but sometimes - like in an after filter - it can be useful to access the response directly. Some of these accessor methods also have setters, allowing you to change their values. To get a full list of the available methods, refer to the [Rails API documentation](https://api.rubyonrails.org/classes/ActionDispatch/Response.html) and [Rack Documentation](https://www.rubydoc.info/github/rack/rack/Rack/Response).

| Property of `response` | Purpose                                                                                             |
| ---------------------- | --------------------------------------------------------------------------------------------------- |
| body                   | This is the string of data being sent back to the client. This is most often HTML.                  |
| status                 | The HTTP status code for the response, like 200 for a successful request or 404 for file not found. |
| location               | The URL the client is being redirected to, if any.                                                  |
| content_type           | The content type of the response.                                                                   |
| charset                | The character set being used for the response. Default is "utf-8".                                  |
| headers                | Headers used for the response.                                                                      |

#### Setting Custom Headers

If you want to set custom headers for a response then `response.headers` is the place to do it. The headers attribute is a hash which maps header names to their values, and Rails will set some of them automatically. If you want to add or change a header, just assign it to `response.headers` this way:

```ruby
response.headers["Content-Type"] = "application/pdf"
```

NOTE: In the above case it would make more sense to use the `content_type` setter directly.

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

Streaming and File Downloads
----------------------------

Sometimes you may want to send a file to the user instead of rendering an HTML page. All controllers in Rails have the `send_data` and the `send_file` methods, which will both stream data to the client. `send_file` is a convenience method that lets you provide the name of a file on the disk and it will stream the contents of that file for you.

To stream data to the client, use `send_data`:

```ruby
require "prawn"
class ClientsController < ApplicationController
  # Generates a PDF document with information on the client and
  # returns it. The user will get the PDF as a file download.
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

The `download_pdf` action in the example above will call a private method which actually generates the PDF document and returns it as a string. This string will then be streamed to the client as a file download and a filename will be suggested to the user. Sometimes when streaming files to the user, you may not want them to download the file. Take images, for example, which can be embedded into HTML pages. To tell the browser a file is not meant to be downloaded, you can set the `:disposition` option to "inline". The opposite and default value for this option is "attachment".

### Sending Files

If you want to send a file that already exists on disk, use the `send_file` method.

```ruby
class ClientsController < ApplicationController
  # Stream a file that has already been generated and stored on disk.
  def download_pdf
    client = Client.find(params[:id])
    send_file("#{Rails.root}/files/clients/#{client.id}.pdf",
              filename: "#{client.name}.pdf",
              type: "application/pdf")
  end
end
```

This will read and stream the file 4kB at the time, avoiding loading the entire file into memory at once. You can turn off streaming with the `:stream` option or adjust the block size with the `:buffer_size` option.

If `:type` is not specified, it will be guessed from the file extension specified in `:filename`. If the content type is not registered for the extension, `application/octet-stream` will be used.

WARNING: Be careful when using data coming from the client (params, cookies, etc.) to locate the file on disk, as this is a security risk that might allow someone to gain access to files they are not meant to.

TIP: It is not recommended that you stream static files through Rails if you can instead keep them in a public folder on your web server. It is much more efficient to let the user download the file directly using Apache or another web server, keeping the request from unnecessarily going through the whole Rails stack.

### RESTful Downloads

While `send_data` works just fine, if you are creating a RESTful application having separate actions for file downloads is usually not necessary. In REST terminology, the PDF file from the example above can be considered just another representation of the client resource. Rails provides an easy and quite sleek way of doing "RESTful downloads". Here's how you can rewrite the example so that the PDF download is a part of the `show` action, without any streaming:

```ruby
class ClientsController < ApplicationController
  # The user can request to receive this resource as HTML or PDF.
  def show
    @client = Client.find(params[:id])

    respond_to do |format|
      format.html
      format.pdf { render pdf: generate_pdf(@client) }
    end
  end
end
```

In order for this example to work, you have to add the PDF MIME type to Rails. This can be done by adding the following line to the file `config/initializers/mime_types.rb`:

```ruby
Mime::Type.register "application/pdf", :pdf
```

NOTE: Configuration files are not reloaded on each request, so you have to restart the server in order for their changes to take effect.

Now the user can request to get a PDF version of a client just by adding ".pdf" to the URL:

```bash
GET /clients/1.pdf
```

### Live Streaming of Arbitrary Data

Rails allows you to stream more than just files. In fact, you can stream anything
you would like in a response object. The `ActionController::Live` module allows
you to create a persistent connection with a browser. Using this module, you will
be able to send arbitrary data to the browser at specific points in time.


#### Incorporating Live Streaming

Including `ActionController::Live` inside of your controller class will provide
all actions inside of the controller the ability to stream data. You can mix in
the module like so:

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

The above code will keep a persistent connection with the browser and send 100
messages of `"hello world\n"`, each one second apart.

There are a couple of things to notice in the above example. We need to make
sure to close the response stream. Forgetting to close the stream will leave
the socket open forever. We also have to set the content type to `text/event-stream`
before we write to the response stream. This is because headers cannot be written
after the response has been committed (when `response.committed?` returns a truthy
value), which occurs when you `write` or `commit` the response stream.

#### Example Usage

Let's suppose that you were making a Karaoke machine and a user wants to get the
lyrics for a particular song. Each `Song` has a particular number of lines and
each line takes time `num_beats` to finish singing.

If we wanted to return the lyrics in Karaoke fashion (only sending the line when
the singer has finished the previous line), then we could use `ActionController::Live`
as follows:

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

The above code sends the next line only after the singer has completed the previous
line.

#### Streaming Considerations

Streaming arbitrary data is an extremely powerful tool. As shown in the previous
examples, you can choose when and what to send across a response stream. However,
you should also note the following things:

* Each response stream creates a new thread and copies over the thread local
  variables from the original thread. Having too many thread local variables can
  negatively impact performance. Similarly, a large number of threads can also
  hinder performance.
* Failing to close the response stream will leave the corresponding socket open
  forever. Make sure to call `close` whenever you are using a response stream.
* WEBrick servers buffer all responses, and so including `ActionController::Live`
  will not work. You must use a web server which does not automatically buffer
  responses.

Log Filtering
-------------

Rails keeps a log file for each environment in the `log` folder. These are extremely useful when debugging what's actually going on in your application, but in a live application you may not want every bit of information to be stored in the log file.

### Parameters Filtering

You can filter out sensitive request parameters from your log files by appending them to `config.filter_parameters` in the application configuration. These parameters will be marked [FILTERED] in the log.

```ruby
config.filter_parameters << :password
```

NOTE: Provided parameters will be filtered out by partial matching regular expression. Rails adds default `:password` in the appropriate initializer (`initializers/filter_parameter_logging.rb`) and cares about typical application parameters `password` and `password_confirmation`.

### Redirects Filtering

Sometimes it's desirable to filter out from log files some sensitive locations your application is redirecting to.
You can do that by using the `config.filter_redirect` configuration option:

```ruby
config.filter_redirect << 's3.amazonaws.com'
```

You can set it to a String, a Regexp, or an array of both.

```ruby
config.filter_redirect.concat ['s3.amazonaws.com', /private_path/]
```

Matching URLs will be marked as '[FILTERED]'.

Rescue
------

Most likely your application is going to contain bugs or otherwise throw an exception that needs to be handled. For example, if the user follows a link to a resource that no longer exists in the database, Active Record will throw the `ActiveRecord::RecordNotFound` exception.

Rails default exception handling displays a "500 Server Error" message for all exceptions. If the request was made locally, a nice traceback and some added information gets displayed so you can figure out what went wrong and deal with it. If the request was remote Rails will just display a simple "500 Server Error" message to the user, or a "404 Not Found" if there was a routing error or a record could not be found. Sometimes you might want to customize how these errors are caught and how they're displayed to the user. There are several levels of exception handling available in a Rails application:

### The Default 500 and 404 Templates

By default a production application will render either a 404 or a 500 error message, in the development environment all unhandled exceptions are raised. These messages are contained in static HTML files in the public folder, in `404.html` and `500.html` respectively. You can customize these files to add some extra information and style, but remember that they are static HTML; i.e. you can't use ERB, SCSS, CoffeeScript, or layouts for them.

### `rescue_from`

If you want to do something a bit more elaborate when catching errors, you can use `rescue_from`, which handles exceptions of a certain type (or multiple types) in an entire controller and its subclasses.

When an exception occurs which is caught by a `rescue_from` directive, the exception object is passed to the handler. The handler can be a method or a `Proc` object passed to the `:with` option. You can also use a block directly instead of an explicit `Proc` object.

Here's how you can use `rescue_from` to intercept all `ActiveRecord::RecordNotFound` errors and do something with them.

```ruby
class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

    def record_not_found
      render plain: "404 Not Found", status: 404
    end
end
```

Of course, this example is anything but elaborate and doesn't improve on the default exception handling at all, but once you can catch all those exceptions you're free to do whatever you want with them. For example, you could create custom exception classes that will be thrown when a user doesn't have access to a certain section of your application:

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

WARNING: Using `rescue_from` with `Exception` or `StandardError` would cause serious side-effects as it prevents Rails from handling exceptions properly. As such, it is not recommended to do so unless there is a strong reason.

NOTE: When running in the production environment, all
`ActiveRecord::RecordNotFound` errors render the 404 error page. Unless you need
a custom behavior you don't need to handle this.

NOTE: Certain exceptions are only rescuable from the `ApplicationController` class, as they are raised before the controller gets initialized and the action gets executed.

Force HTTPS protocol
--------------------

If you'd like to ensure that communication to your controller is only possible
via HTTPS, you should do so by enabling the `ActionDispatch::SSL` middleware via
`config.force_ssl` in your environment configuration.
