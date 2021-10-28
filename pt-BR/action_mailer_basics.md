**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Começando a usar _Action Mailer_
====================

Este guia provê todos os conhecimentos que você precisa para iniciar
a enviar e-mails da sua aplicação e outros conhecimentos de como as coisas
funcionam internamente.
do _Action Mailer_. Ele também ensina como testar seus _mailers_.

Após a leitura deste guia, você saberá:

* Como enviar um e-mail usando sua aplicação Rails;
* Como gerar e editar uma classe _Action Mailer_ e uma _mailer view_;
* Como configurar o _Action Mailer_ para o seu ambiente;
* Como Testar suas classes do _Action Mailer_.

--------------------------------------------------------------------------------

O que é o *Action Mailer*?
------------------------

*Action Mailer* permite que você envie emails direto da sua aplicação usando as
classes e _Mailer views_

#### _Mailers_ são semelhantes a controllers

Eles herdam do `ActionMailer::Base` e se encontram na `app/mailers`. Os Mailers também funcionam de maneira muito semelhante aos controllers. Alguns exemplos de semelhanças são mostrados abaixo.
Mailers tem:

* *Actions*, e também, *views* associadas que aparecem em `app/views`.
* Variáveis de instância acessíveis nas *views*.
* A capacidade de utilizar *layouts* e *partials*.
* A capacidade de acessar um hash de parâmetros.

Enviando E-mails
--------------

Esta seção irá te guiar no processo de criação de um _Mailer_ e sua _view_.

### Passo a Passo para Gerar um _Mailer_

#### Criando um _Mailer_

```bash
$ bin/rails generate mailer User
create  app/mailers/user_mailer.rb
create  app/mailers/application_mailer.rb
invoke  erb
create    app/views/user_mailer
create    app/views/layouts/mailer.text.erb
create    app/views/layouts/mailer.html.erb
invoke  test_unit
create    test/mailers/user_mailer_test.rb
create    test/mailers/previews/user_mailer_preview.rb
```

```ruby
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "para@exemplo.com"
  layout 'mailer'
end
```

```ruby
# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
end
```

Como pôde ver no exemplo acima, você pode gerar _mailers_ como faz com outros tipos de arquivos no Rails.

Se você prefere não usar um _generator_, você pode criar esses arquivos por si só dentro de `app/mailers/`, só não se esqueça de adicionar a herança com `ActionMailer::Base` aos _mailers_:

```ruby
class MyMailer < ActionMailer::Base
end
```

#### Editando o _Mailer_

_Mailers_ têm métodos chamados _actions_ e usam _views_ para estruturar seu conteúdo.
Onde um _controller_ gera conteúdo como HTML para enviar de volta à um cliente, o _Mailer_ cria uma mensagem para ser entregue por e-mail.

`app/mailers/user_mailer.rb` contém um _mailer_ vazio:

```ruby
class UserMailer < ApplicationMailer
end
```

Vamos adicionar um método chamado `welcome_email`, que enviará um e-mail para o endereço de e-mail registrado pelo usuário.

```ruby
class UserMailer < ApplicationMailer
  default from: 'notificacoes@exemplo.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://exemplo.com/login'
    mail(to: @user.email, subject: 'Boas vindas ao nosso incrível site!')
  end
end
```

Uma breve explicação sobre os itens apresentados no método acima. Para uma lista completa de todas as opções disponíveis, por favor, dê uma olhada mais abaixo na seção: Lista completa de atributos de configuração do _Action Mailer_.

* `default Hash` — Está é a _Hash_ padrão com valores que serão usados em todos os e-mail enviados por este _mailer_. Neste exemplo nós configuramos o `:from` (Remetente, quem envia) para um valor padrão que será usado em todas as mensagens enviadas por está classe. Está configuração pode ser sobrescrita.
* `mail` — O próprio e-mail, aqui nós estamos passando os parâmetros `:to` (Destinatário, quem recebe) e `:subject` (Assunto do e-mail) ao cabeçalho.

#### Criando uma _View_ para nosso _Mailer_

Crie um arquivo com o nome `welcome_email.html.erb` em `app/views/user_mailer/`. Este será o modelo que usaremos para nosso e-mail, formatado usando HTML:

```html+erb
<!DOCTYPE html>
<html>
  <head>
    <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
  </head>
  <body>
    <h1>Boas vindas ao site exemplo.com, <%= @user.name %></h1>
    <p>
      Você concluiu seu cadastro com sucesso,
      seu nome de usuário é: <%= @user.login %>.<br>
    </p>
    <p>
      Para iniciar sua seção no site clique no link a seguir: <%= @url %>.
    </p>
    <p>Agradecemos por se juntar à nós! Tenha um ótimo dia!</p>
  </body>
</html>
```

Vamos criar também um modelo usando somente texto para este e-mail. Nem todos os programas de e-mail leem HTML, então enviar os dois formatos é uma boa prática. Para isto criaremos um arquivo com o nome `welcome_email.text.erb` em `app/views/user_mailer/`:

```erb
Boas vindas ao site exemplo.com, <%= @user.name %>
===============================================

Você concluiu seu cadastro com sucesso,
seu nome de usuário é: <%= @user.login %>.

Para iniciar sua seção no site clique no link a seguir: <%= @url %>.

Agradecemos por se juntar à nós! Tenha um ótimo dia!
```

Quando você chamar o método `mail`, `ActionMailer` detectará que existem dois modelos para esse e-mail (Um em HTML e outro somente texto) e automaticamente irá gerar um `multipart/alternative` (Opção que indica ao programa de e-mail que essa mensagem tem uma versão em HTML e outra em somente texto) e-mail.

#### Chamando o _Mailer_

_Mailers_ são somente outra maneira de renderizar uma _view_. Ao invés de renderizar uma
_view_ e envia-la usando o protocolo HTTP, um _Mailer_ envia através
dos protocolos de e-mail. Por esse motivo, faz sentido, para o exemplo anterior, que o
_controller_ informe ao _mailer_ para enviar uma mensagem assim que um usuário complete seu cadastro com sucesso.

Configurar isto é muito simples.

Primeiro, criaremos um _scaffold_ (esqueleto) para nosso _model_ `User`:

```bash
$ bin/rails generate scaffold user name e-mail login
$ bin/rails db:migrate
```

Agora que já temos o _model_ para nossos usuários, podemos começar a criar a funcionalidade. Para isso vamos editar o arquivo `app/controllers/users_controller.rb` para chamar o `UserMailer` para enviar um e-mail ao novo usuário registrado. Vamos editar a _action_ `create` inserindo a seguinte chamada: `UserMailer.with(user: @user).welcome_email` logo após o usuário ter sido salvo com sucesso.

_Action Mailer_ já é nativamente integrado com o _Active Job_, logo você pode enviar os e-mails fora do ciclo requisição-resposta, então o usuário não precisa aguardar esse processo terminar para continuar usando a aplicação.

```ruby
class UsersController < ApplicationController
  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        # Diz ao UserMailer para enviar o _welcome e-mail_ caso o usuário seja salvo
        UserMailer.with(user: @user).welcome_email.deliver_later

        format.html { redirect_to(@user, notice: 'Usuário foi criado com sucesso.') }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end
end
```

NOTE: O comportamento padrão do _Active Job_ é executar os serviços de maneira assíncrona, usando o adaptador `:async`. Então você pode usar o método `deliver_later` para enviar os e-mail de maneira assíncrona.
O adaptador padrão do _Active Job_ executa os serviços em um processo _Thread Pool_. Está abordagem é boa para os ambientes de desenvolvimento e teste, pois não requerem nenhuma infraestrutura externa/complexa, porém é uma abordagem ruim para o ambiente de produção, pois caso o sistema seja reiniciado você pode perder os registros desses serviços.
Se você precisar de uma solução para que esses serviços sejam persistidos, de modo a evitar possíveis perdas, você precisará de um serviço a parte que tenha essa funcionalidade, exemplos: Sidekiq, Resque etc.

Se você deseja que os e-mail sejam enviados no mesmo tempo que chamar o _Mailer_, simplesmente chame `deliver_now`:

```ruby
class SendWeeklySummary
  def run
    User.find_each do |user|
      UserMailer.with(user: user).weekly_summary.deliver_now
    end
  end
end
```

Qualquer chave-valor passado para o `with` se torna parte da _Hash_ `params` que será usado na _action_ do _Mailer_. Então `with(user: @user, account: @user.account)` cria `params[:user]` e `params[:account]` disponíveis na _action_ do _Mailer_. Como acontece nos _controllers_ que também tem `params`.

O método `welcome_email` tem como retorno um objeto do tipo `ActionMailer::MessageDelivery` que você pode encadear os métodos `deliver_now` ou `deliver_later` para assim ele se enviar como um e-mail.
O objeto `ActionMailer::MessageDelivery` é um _wrapper_ (Embrulho) para a classe `Mail::Message`. Se você quiser inspecionar, alterar, ou fazer qualquer coisa com o objeto `Mail::Message` você pode acessa-lo através do método `message` do objeto `ActionMailer::MessageDelivery`.

### Codificação automática

_Action Mailer_ gerencia automaticamente a codificação de caracteres _multibytes_ (Caracteres asiáticos, emojis etc) dentro do cabeçalho e corpo.

Para exemplos mais complexos como definir uma lista alternativa de caracteres ou codificar o texto de maneira diferente, use essa biblioteca como referência: [Mail](https://github.com/mikel/mail).

### Lista Completa de Métodos do _Action Mailer_

Existem apenas três métodos que você precisa para enviar qualquer mensagem de e-mail:

* `headers` — Especifica qualquer cabeçalho no e-mail como você desejar. Você pode passar uma _hash_ contendo os campos do cabeçalho seguindo o padrão `chave: valor`, ou você pode chamar a variável `headers[:field_name] = value`.
* `attachments` — Permite adicionar anexos ao e-mail. Exemplo: `attachments['file-name.jpg'] = File.read('file-name.jpg')` que irá adicionar o arquivo `file-name.jpg` como anexo no e-mail.
* `mail` — Cria o e-mail de fato. Você pode usar a _hash_ `headers` como um dos parâmetros.
  `mail` vai criar o e-mail, tanto em texto puro ou _multipart_, dependendo dos modelos disponíveis que você definiu.

#### Adicionando Anexos

Com o _Action Mailer_ é muito fácil trabalhar com anexos.

* Passe o nome do arquivo e o conteúdo para o _Action Mailer_ e a [Mail gem](https://github.com/mikel/mail) irá descobrir o `mime_type` do arquivo, define a codificação (`encoding`) e criar o anexo.

    ```ruby
    attachments['filename.jpg'] = File.read('/caminho/para/o/arquivo.jpg')
    ```

  Quando o método `mail` for invocado, enviará um e-mail no modo _multipart_
  com o anexo, corretamente configurado, sendo o anexo a primeira parte
  como `multipart/mixed` e a mensagem sendo a segunda com `multipart/alternative`
  com o texto e o HTML do e-mail.

NOTE: O anexo será codificado usando _Base64_ pelo `Mail`. Se você precisar de algo diferente, codifique previamente o conteúdo e adicione o anexo e qual a codificação na _hash_ `attachments`.

* Passe o nome do arquivo, cabeçalhos específicos e o conteúdo e o _Action Mailer_ e `Mail` irão usar as configurações:

    ```ruby
    encoded_content = SpecialEncode(File.read('/caminho/para/o/arquivo.jpg'))
    attachments['arquivo.jpg'] = {
      mime_type: 'application/gzip',
      encoding: 'SpecialEncoding',
      content: encoded_content
    }
    ```

NOTE: Se você especificar a codificação, `Mail` assumirá que o conteúdo já está codificado e não irá codificar usando o padrão _Base64_.

#### Criando Anexos dentro da Mensagem de E-mail (_Inline_)

_Action Mailer_ 3.0 cria anexos dentro da mensagem de e-mail, algo que antes da versão 3.0 envolvia algumas gambiarras, de maneira muito simples e trivia como sempre deveria ter sido.

* Primeiro, para informar ao `Mail` que o anexo deve ser enviado dentro da própria mensagem você pode encadear o método `#inline` no `attachments` dentro da _action_ do seu _Mailer_:

    ```ruby
    def welcome
      attachments.inline['image.jpg'] = File.read('/caminho/para/a/imagem.jpg')
    end
    ```

* Na _view_, você só precisa especificar qual o anexo dentro de `attachments`, que é uma _hash_, você quer mostrar, encadeando o método `url` no anexo irá retornar o endereço do anexo e você pode passar o resultado para o método `image_tag` que renderiza uma imagem, veja o exemplo abaixo:

    ```html+erb
    <p>Olá! Aqui está nossa imagem</p>

    <%= image_tag attachments['imagem.jpg'].url %>
    ```

* Como isso é uma chamada normal ao método `image_tag` você pode passar uma _hash_ de opções após a _URL_ do anexo como você faria para qualquer outra imagem:

    ```html+erb
    <p>Olá! Aqui está nossa imagem</p>

    <%= image_tag attachments['imagem.jpg'].url, alt: 'Minha Foto', class: 'fotos' %>
    ```

#### Enviando E-mail para Vários Destinatários

É possível enviar e-mail para um ou mais destinatários usando uma mensagem de e-mail (Por exemplo: notificando os administradores que houve um novo cadastro) bastando configurar uma lista de e-mails no parâmetro `:to`. Essa lista de e-mails pode ser um _Array_ de endereços de e-mails ou uma _String_ contendo todos os e-mails separados por vírgulas.

```ruby
class AdminMailer < ApplicationMailer
  default to: -> { Admin.pluck(:email) },
          from: 'notificacao@exemplo.com'

  def new_registration(user)
    @user = user
    mail(subject: "Novo usuário cadastrado: #{@user.email}")
  end
end
```

```ruby
class AdminMailer < ApplicationMailer
  default to: 'email_um@exemplo.com,email_dois@exemplo.com,email_tres@exemplo.com',
          from: 'notificacao@exemplo.com'

  def new_registration(user)
    @user = user
    mail(subject: "Novo usuário cadastrado: #{@user.email}")
  end
end
```


O mesmo formato pode ser usado para enviar e-mails com cópia (Cc:) ou com cópia oculta (Cco: ou Bcc: em inglês), adicione `:cc` ou `:bcc` para enviar seguindo os padrões descritos acima.

#### Enviando E-mail com Nome

Em alguns momentos você deseja exibir o nome da pessoa que enviou a mensagem ao invés de mostrar somente o e-mail.
Você pode usar `email_address_with_name` para isso:

```ruby
def welcome_email
  @user = params[:user]
  mail(
    to: email_address_with_name(((((nc(@user.email, @user.name),
    subject: 'Welcome to My Awesome Site'
  )
end
```

### *Views* de *Mailer*

As *views* de um *Mailer* ficam no diretório `app/views/nome_da_classe_do_mailer`. A *view* específica do *mailer* é reconhecida pela classe pois seu nome é o mesmo do método. No exemplo anterior, nossa *view* para o método `welcome_email` estará em `app/views/user_mailer/welcome_email.html.erb`, para a versão em HTML e em `welcome_email.text.erb` para a versão em texto simples.

Para mudar a *mailer view* padrão da sua *action*, é preciso fazer algo como por exemplo:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'Bem vindo ao meu site!',
         template_path: 'notifications',
         template_name: 'another')
  end
end
```

Nesse caso, os *templates* serão buscados em `app/views/notifications`, com o nome `another`. Também é possível especificar um *array* de caminhos, que serão verificados em ordem.

Se quiser mais flexibilidade, você pode fornecer um bloco e renderizar *templates* específicos, ou até mesmo renderizar texto ou conteúdo *inline* sem usar um arquivo de *template*:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'Bem vindo ao meu site!') do |format|
      format.html { render 'another_template' }
      format.text { render plain: 'Renderizar texto simples' }
    end
  end
end
```

Isso fará com que o *template* 'another_template.html.erb' seja renderizado para a parte HTML, e usará o texto especificado para a parte textual. O comando *render* é o mesmo usado em *Action Controller*, então é possível usar as mesmas opções, como por exemplo, `:text`, `:inline`, etc.

Se deseja renderizar um *template* que está fora do diretório padrão `app/views/mailer_name/`, você pode usar a opção `prepend_view_path`, da seguinte forma:

```ruby
class UserMailer < ApplicationMailer
  prepend_view_path "custom/path/to/mailer/view"

  # Isso tentará carregar o template "custom/path/to/mailer/view/welcome_email"
  def welcome_email
    # ...
  end
end
```

Considere também usar o método [append_view_path](https://guides.rubyonrails.org/action_view_overview.html#view-paths).

#### Criando *cache* de uma *view* de *mailer*

É possível criar cache de um fragmento das *views* de um *mailer* da mesma forma como fazemos para as *views* da aplicação, usando o método `cache`.

```html+erb
<% cache do %>
  <%= @company.name %>
<% end %>
```

Para usar essa funcionalidade, é necessário configurar sua aplicação da seguinte forma:

```ruby
config.action_mailer.perform_caching = true
```

Também é possível criar *cache* de fragmentos para os emails *multipart*. Leia mais sobre cache em [Guia de cache do Rails](caching_with_rails.html).

### *Layouts de Action Mailer*

Similarmente como nas *views* dos *controllers*, é possível também ter *layouts* para os *mailers*. O nome do *layout* deve ser o mesmo do *mailer*, como `user_mailer.html.erb` e `user_mailer.text.erb` para ser reconhecido automaticamente pelo seu *mailer* como um *layout*.

Se quiser usar um arquivo diferente, chame `layout` em seu *mailer*:

```ruby
class UserMailer < ApplicationMailer
  layout 'awesome' # use awesome.(html|text).erb as the layout
end
```

Assim como nas *views* de *controller*, use `yield` para renderizar a *view* dentro do layout.

Você também pode passar `layout: 'layout_name'` dentro do bloco de formatação como opção na chamada do *render* para especificar quais formatos usar em *layouts* diferentes:

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email) do |format|
      format.html { render layout: 'my_layout' }
      format.text
    end
  end
end
```

Vai renderizar a parte *HTML* usando o arquivo `my_layout.html.erb` e a parte de texto com o arquivo usual `user_mailer.text.erb` se ele existir.

### Pré-visualizando Emails

O *Action Mailer Preview* possibilita uma maneira de pré-visualizar como o email vai ficar, acessando uma _URL_ especial que o renderiza. No exemplo acima, a classe para pré-visualizar `UserMailer` deve se chamar `UserMailerPreview`
e deve estar localizada em `test/mailers/previews/user_mailer_preview.rb`. Para ver o modelo de `welcome_email`, implemente um método que tem o mesmo nome e chame por `UserMailer.welcome_email`:

```ruby
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end
end
```

Dessa maneira, o modelo vai ficar disponível em <http://localhost:3000/rails/mailers/user_mailer/welcome_email>.

Se você mudar algo em `app/views/user_mailer/welcome_email.html.erb` ou no próprio *mailer*,
ele será automaticamente recarregado e renderizado, para que você veja as mudanças instantaneamente.
Uma lista das pré-visualizações também ficam disponíveis em <http://localhost:3000/rails/mailers>.

Por padrão, essas classes de pré-visualizações ficam em `test/mailers/previews`. Isso pode ser configurado usando a opção `preview_path`. Por exemplo, se você quiser alterar para `lib/mailer_previews`, você pode configurar isso em `config/application.rb`:

```ruby
config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"
```

### Gerando URLs no Action Mailer Views

Ao contrário dos *controllers*, a instância do `mailer` não tem nenhum contexto sobre a
requisição recebida, então você precisará informar o parâmetro `:host`.

Como o `:host` normalmente é o mesmo em toda a aplicação, você pode configurá-lo
globalmente no arquivo `config/application.rb`:

```ruby
config.action_mailer.default_url_options = { host: 'exemplo.com' }
```

Por causa dessa característica, você não pode usar nenhum dos *helpers* `*_path` dentro de
um email. Ao invés, você precisará usar o `*_url` helper respectivo. Por exemplo,
ao invés de usar:

```html+erb
<%= link_to 'welcome', welcome_path %>
```

Você precisará usar:

```html+erb
<%= link_to 'welcome', welcome_url %>
```

Usando a URL completa, seus links irão funcionar dentro dos seus emails.

#### Gerando URLs com `url_for`

Por padrão, o `url_for` gera uma URL completa nos *templates*.

Se você não configurar a opção `:host` globalmente, não esqueça de passá-lo para o
`url_for`.


```erb
<%= url_for(host: 'example.com',
            controller: 'welcome',
            action: 'greeting') %>
```

#### Gerando URLs com Rotas Nomeadas

Os clientes de email não têm o contexto da web e, portanto, os caminhos não têm a URL
base para completar os endereços da web. Assim, você deve sempre usar a variant  `*_url`
do *helper* da rota nomeada.

Se você não configurar a opção `:host` globalmente, não esqueça de passá-lo para o
helper da URL.


```erb
<%= user_url(@user, host: 'example.com') %>
```

NOTE: Links que não são `GET` vão exigir o uso de [rails-ujs](https://github.com/rails/rails/blob/main/actionview/app/assets/javascripts) ou
[jQuery UJS](https://github.com/rails/jquery-ujs), e, portanto, não irão funcionar em templates de email.
Eles irão resultar em requisições `GET` normais.

### Adicionando imagens no Action Mailer Views

Ao contrário dos controllers, a instância do `mailer` não tem nenhum contexto sobre a
requisição recebida, então você precisará informar o parâmetro `:asset_host`.

Como o `:asset_host` normalmente é o mesmo em toda a aplicação, você pode configurá-lo
globalmente no arquivo `config/application.rb`:


```ruby
config.asset_host = 'http://example.com'
```

Agora você pode exibir uma imagem dentro do seu email.

```html+erb
<%= image_tag 'image.jpg' %>
```

### Enviando Emails *Multipart*

O Action Mailer enviará automaticamente emails *multipart* se você tiver templates
diferentes para a mesma action. Então, para o nosso exemplo do `UserMailer`, se você tiver
os templates `welcome_email.text.erb` e `welcome_email.html.erb` na pasta
`app/views/user_mailer`, o Action Mailer irá automaticamente enviar um email multipart
com as versões de HTML e texto configuradas como partes diferentes.

A ordem das partes sendo inseridas é determinado pelo argumento `:parts_order`
dentro do método the `ActionMailer::Base.default`.

### Enviando Emails com Opções de Entrega Dinâmicas

Se você deseja sobrescrever as opções de entrega padrões (ex: as credenciais SMTP)
enquanto o email está sendo enviado, você pode fazer isso usando o `delivery_method_options`
na *action* do mailer.


```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    @user = params[:user]
    @url  = user_url(@user)
    delivery_options = { user_name: params[:company].smtp_user,
                         password: params[:company].smtp_password,
                         address: params[:company].smtp_host }
    mail(to: @user.email,
         subject: "Please see the Terms and Conditions attached",
         delivery_method_options: delivery_options)
  end
end
```

### Enviando Emails sem Renderizar um Template

Podem haver casos onde você quer pular a etapa de renderização de um template e enviar
o corpo do email como `string`. Você pode fazer isso usando a opção `:body`.
Nesses casos, não esqueça de adicionar também a opção `:content_type`. Caso contrário,
o Rails vai usar o `text/plain` como padrão.

```ruby
class UserMailer < ApplicationMailer
  def welcome_email
    mail(to: params[:user].email,
         body: params[:email_body],
         content_type: "text/html",
         subject: "Already rendered!")
  end
end
```

Callbacks do _Action Mailer_
-----------------------

*Action Mailer* permite que você especifique o `before_action`, `after_action` e
`around_action`.

* Filtros podem ser especificados com um bloco ou um *symbol* para um  método no *Mailer*, similar a um *controller*

* Você pode usar um `before_action` para definir variáveis de instância,
popule o objeto de email com valores padrões, ou insira *headers* e anexos padrões.

```ruby
class InvitationsMailer < ApplicationMailer
  before_action :set_inviter_and_invitee
  before_action { @account = params[:inviter].account }

  default to:       -> { @invitee.email_address },
          from:     -> { common_address(@inviter) },
          reply_to: -> { @inviter.email_address_with_name }

  def account_invitation
    mail subject: "#{@inviter.name} invited you to their Basecamp (#{@account.name})"
  end

  def project_invitation
    @project    = params[:project]
    @summarizer = ProjectInvitationSummarizer.new(@project.bucket)

    mail subject: "#{@inviter.name.familiar} added you to a project in Basecamp (#{@account.name})"
  end

  private

    def set_inviter_and_invitee
      @inviter = params[:inviter]
      @invitee = params[:invitee]
    end
end
```

* Você pode usar um `after_action` para fazer uma configuração semelhante ao `before_action`, mas usando variáveis de instância definidas em sua *action* do *mailer*.

* Usando um `after_action` também vai te permitir sobreescrever o método de
  entrega definido por atualizar `mail.delivery_method.settings`.

```ruby
class UserMailer < ApplicationMailer
  before_action { @business, @user = params[:business], params[:user] }

  after_action :set_delivery_options,
               :prevent_delivery_to_guests,
               :set_business_headers

  def feedback_message
  end

  def campaign_message
  end

  private

    def set_delivery_options
      # You have access to the mail instance,
      # @business and @user instance variables here
      if @business && @business.has_smtp_settings?
        mail.delivery_method.settings.merge!(@business.smtp_settings)
      end
    end

    def prevent_delivery_to_guests
      if @user && @user.guest?
        mail.perform_deliveries = false
      end
    end

    def set_business_headers
      if @business
        headers["X-SMTPAPI-CATEGORY"] = @business.code
      end
    end
end
```

* Os filtros do *mailer* interrompem o processamento adicional se o *body* estiver definido com um valor não nulo.

Usando os *helpers* do *Action Mailer*
---------------------------

O *Action Mailer* agora herda de `AbstractController`, para que você tenha acesso aos mesmos
*helpers* genéricos que um *Action Controller*.

Existem também alguns métodos auxiliares específicos do Action Mailer disponíveis em
`ActionMailer::MailHelper`. Por exemplo, estes permitem acessar a instância de mailer
a partir da *view* com `mailer`, e acessando a mensagem usando `message`:

```erb
<%= stylesheet_link_tag mailer.name.underscore %>
<h1><%= message.subject %></h1>
```

Configuração do _Action Mailer_
---------------------------

As seguintes opções de configuração são feitas melhor em um dos ambientes
arquivos (environment.rb, production.rb, etc...)

| Configuração  | Descrição |
|---------------|-------------|
|`logger`|Gera informações sobre a execução de correspondência, se disponível. Pode ser definido como `nil` para nenhum registro. Compatível com os _loggers_ `Logger` e `Log4r` do Ruby.|
|`smtp_settings`|Permite configuração detalhada para o método de entrega `:smtp`:<ul><li>`:address` - Permite que você use um servidor de e-mail remoto. Basta alterar a configuração do padrão `"localhost"`.</li><li>`:port` - Na chance de seu servidor de e-mail não funcionar na porta 25, você pode alterá-lo.</li><li>`:domain` - Se você precisar especificar um domínio HELO, pode fazê-lo aqui.</li><li>`:user_name` - Se o seu servidor de e-mail requer autenticação, defina o nome de usuário neste configuração.</li><li>`:password` - Se o seu servidor de e-mail requer autenticação, defina a senha neste configuração.</li><li>`:authentication` - Se o seu servidor de e-mail requer autenticação, você precisa especificar o tipo de autenticação aqui. Este é um símbolo e um dos `:plain` (irá enviar a senha em claro), `:login` (irá enviar senha codificada em Base64) or `:cram_md5` (combina um mecanismo de desafio / resposta para trocar informações e um algoritmo criptográfico Message Digest 5 para _hash_ informações importantes)</li><li>`:enable_starttls_auto` - Detecta se STARTTLS está habilitado em seu servidor SMTP e começa a usá-lo. O padrão é `true`.</li><li>`:openssl_verify_mode` - Ao usar TLS, você pode definir como o OpenSSL verifica o certificado. Isso é realmente útil se você precisar validar um certificado auto assinado e / ou curinga. Você pode usar o nome de uma constante de verificação OpenSSL ('none' ou 'peer') ou diretamente a constante (`OpenSSL::SSL::VERIFY_NONE` ou `OpenSSL::SSL::VERIFY_PEER`).</li><li>`:ssl/:tls` - Permite que a conexão SMTP use SMTP / TLS (SMTPS: SMTP sobre conexão TLS direta)</li></ul>|
|`sendmail_settings`|Permite que você substitua as opções do método de entrega `: sendmail`.<ul><li>`:location` - A localização do executável sendmail. Padrões para `/usr/sbin/sendmail`.</li><li>`:arguments` - Os argumentos da linha de comando a serem passados ​​ao sendmail. Padrões para `-i`.</li></ul>|
|`raise_delivery_errors`|Se erros devem ou não ser levantados se o e-mail não for entregue. This only works if the external email server is configured for immediate delivery.|
|`delivery_method`|Define um método de entrega. Os valores possíveis são:<ul><li>`:smtp` (default), pode ser configurado usando `config.action_mailer.smtp_settings`.</li><li>`:sendmail`, pode ser configurado usando `config.action_mailer.sendmail_settings`.</li><li>`:file`: salva e-mails em arquivos; pode ser configurado usando `config.action_mailer.file_settings`.</li><li>`:test`: salvar e-mails para `ActionMailer::Base.deliveries` array.</li></ul>Veja[API docs](https://api.rubyonrails.org/classes/ActionMailer/Base.html) para mais informações.|
|`perform_deliveries`|Determina se as entregas são realmente realizadas quando o método `entrega` é invocado na mensagem do _Mail_. Por padrão, eles são, mas isso pode ser desligado para ajudar nos testes funcionais. Se este valor for `false`, o _array_ `deliveries` não será preenchido, mesmo se `delivery_method` for `:test`.|
|`deliveries`|Mantém um _array_ de todos os emails enviados através do _Action Mailer_ com delivery_method: test. Muito útil para testes de unidade e funcional.|
|`default_options`|Permite definir valores padrão para as opções do método `mail` (`:from`, `:reply_to`, etc.).|

Para uma descrição completa das configurações possíveis, consulte o
[Configuring Action Mailer](configuring.html#configuring-action-mailer) dentro do
nosso guia de configuração de aplicativos Rails.

### Exemplo de configuração do _Action Mailer_

Um exemplo seria adicionar o seguinte ao seu
arquivo `config/environments/$RAILS_ENV.rb`:

```ruby
config.action_mailer.delivery_method = :sendmail
# Defaults to:
# config.action_mailer.sendmail_settings = {
#   location: '/usr/sbin/sendmail',
#   arguments: '-i'
# }
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_options = {from: 'no-reply@example.com'}
```

### Configuração do _Action Mailer_ para Gmail

Como o Action Mailer agora usa a [gem Mail](https://github.com/mikel/mail),
torna-se tão simples quanto adicionar ao arquivo `config/environment/$ RAILS_ENV.rb`:

```ruby
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'example.com',
  user_name:            '<username>',
  password:             '<password>',
  authentication:       'plain',
  enable_starttls_auto: true }
```

NOTE: Em 15 de julho de 2014, o Google aumentou [suas medidas de segurança](https://support.google.com/accounts/answer/6010255) e agora bloqueia as tentativas de aplicativos que considera menos seguros.
Você pode alterar suas configurações do Gmail [aqui](https://www.google.com/settings/security/lesssecureapps) para permitir as tentativas. Se sua conta do Gmail tiver a autenticação de dois fatores ativada
em seguida, você precisará definir uma [senha de aplicativo](https://myaccount.google.com/apppasswords) e usá-la em vez de sua senha normal. Alternativamente, você pode
use outro ESP para enviar e-mail substituindo 'smtp.gmail.com' acima pelo endereço do seu provedor.

Testes de *Mailer*
--------------

Você encontrará instruções detalhadas de como testar seus *mailers* no
[guia de teste](testing.html#testing-your-mailers).

Interceptando e Observando Emails
-------------------

_Action Mailer_ fornece ganchos para os métodos observador e interceptor do Mail. Eles permitem que você registre classes que são chamadas durante o ciclo de vida de entrega de cada e-mail enviado.

### Interceptando Emails

Os interceptores permitem que você faça modificações em emails antes que eles sejam entregues aos agentes de entrega. Uma classe de interceptor deve implementar o método `::delivering_email(message)` que será chamado antes do e-mail ser enviado.

```ruby
class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['sandbox@example.com']
  end
end
```

Antes que o interceptor possa fazer seu trabalho, você precisa registrá-lo
usando `register_interceptor`. Você pode fazer isso em um arquivo inicializador
como `config/initializers/sandbox_email_interceptor.rb`:

```ruby
if Rails.env.staging?
  ActionMailer::Base.register_interceptor(SandboxEmailInterceptor)
end
```

NOTE: O exemplo acima usa um ambiente personalizado chamado "staging" para um
servidor como em produção, mas para fins de teste. Você pode ler
[Criação de Ambientes Rails](configuring.html#creating-rails-environments)
para mais informações sobre ambientes Rails personalizados.

### Observando Emails

Os observadores fornecem acesso à mensagem de e-mail após ela ter sido enviada. Uma classe de observador deve implementar o método `:delivered_email(message)`, que será chamado após o e-mail ser enviado.

```ruby
class EmailDeliveryObserver
  def self.delivered_email(message)
    EmailDelivery.log(message)
  end
end
```

Como os interceptores, você precisa registrar observadores usando `register_observer`. Você pode fazer isso em um arquivo inicializador
como `config/initializers/email_delivery_observer.rb`

```ruby
ActionMailer::Base.register_observer(EmailDeliveryObserver)
```
