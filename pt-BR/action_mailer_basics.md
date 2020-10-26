**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Começando a usar _Action Mailer_
====================

Este guia provê todos os conhecimentos que você precisa para iniciar
a enviar e-mails da sua aplicação e outros conhecimentos das entranhas
do _Action Mailer_. Ele também ensina como testar seus _mailers_.

Após a leitura deste guia, você saberá:

* Como enviar um e-mail usando sua aplicação Rails;
* Como gerar e editar uma classe _Action Mailer_ e uma _mailer view_;
* Como configurar o _Action Mailer_ para o seu ambiente;
* Como Testar suas classes do _Action Mailer_.

--------------------------------------------------------------------------------

Introdução
------------

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
$ rails generate mailer UserMailer
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
  default from: "from@example.com"
  layout 'mailer'
end

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
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email, subject: 'Welcome to My Awesome Site')
  end
end
```

Uma breve explicação sobre os itens apresentados no método acima. Para uma lista completa de todas as opções disponiveis, por favor, dê uma olhada mais abaixo na seção: Lista completa de atributos de configuração do _Action Mailer_.

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
    <h1>Welcome to example.com, <%= @user.name %></h1>
    <p>
      You have successfully signed up to example.com,
      your username is: <%= @user.login %>.<br>
    </p>
    <p>
      To login to the site, just follow this link: <%= @url %>.
    </p>
    <p>Thanks for joining and have a great day!</p>
  </body>
</html>
```

Vamos criar também um modelo usando somente texto para este e-mail. Nem todos os programas de e-mail leem HTML, então enviar os dois formatos é uma boa prática. Para isto criaremos um arquivo com o nome `welcome_email.text.erb` em `app/views/user_mailer/`:

```erb
Welcome to example.com, <%= @user.name %>
===============================================

You have successfully signed up to example.com,
your username is: <%= @user.login %>.

To login to the site, just follow this link: <%= @url %>.

Thanks for joining and have a great day!
```
Quando você chamar o método `mail`, `ActionMailer` detectará que existem dois modelos para esse e-mail (Um em HTML e outro somente texto) e automaticamente irá gerar um `multipart/alternative` (Opção que indica ao programa de e-mail que essa mensagem tem uma versão em HTML e outra em somente texto) e-mail.

#### Chamando o _Mailer_

_Mailers_ são somente outra maneira de renderizar uma _view_. Ao invés de renderizar uma _view_ e envia-la usando o protocolo HTTP, um _Mailer_ envia através dos protocolos de e-mail. Por esse motivo, faz sentido, para o exemplo anterior, que o _controller_ informe ao _mailer_ para enviar uma mensagem assim que um usuário complete seu cadastro com sucesso.

Configurar isto é muito simples.

Primeiro, criaremos um simples _scaffold_ (Esqueleto) para nosso _model_ `User`:

```bash
$ rails generate scaffold user name e-mail login
$ rails db:migrate
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
        # Tell the UserMailer to send a welcome e-mail after save
        UserMailer.with(user: @user).welcome_email.deliver_later

        format.html { redirect_to(@user, notice: 'User was successfully created.') }
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

NOTE: Quando chamar o método `deliver_later` o serviço será posto sob uma fila com o nome de `mailers`. Confirme se o adaptador de filas (_Active Job_, Sidekiq, Resque etc) é compatível com essa fila, caso contrário seu serviço vai acabar sendo ignorado, o que vai impedir os e-mails de serem enviados. Você pode mudar isso especificando uma opção de fila compatível na configuração `config.action_mailer.deliver_later_queue_name`.

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
O objeto `ActionMailer::MessageDelivery` é somente um _wrapper_ (Embrulho) para a classe `Mail::Message`. Se você quiser inspecionar, alterar, ou fazer qualquer coisa com o objeto `Mail::Message` você pode acessa-lo através do método `message` do objeto `ActionMailer::MessageDelivery`.

### Codificação automática

_Action Mailer_ gerencia automaticamente a codificação de caracteres _multibytes_ (Caracteres asiaticos, emojis etc) dentro do cabeçalho e corpo.

Para exemplos mais complexos como definir uma lista alternativa de caracteres ou codificar o texto de maneira diferente, use essa biblioteca como referência: [Mail](https://github.com/mikel/mail).

### Lista Completa de Métodos do _Action Mailer_

Somente há três métodos que você precisa para enviar qualquer mensagem de e-mail:

* `headers` — Especifica qualquer cabeçalho no e-mail como você desejar. Você pode passar uma _hash_ contendo os campos do cabeçalho seguindo o padrão `chave: valor`, ou você pode chamar a variável `headers[:field_name] = value`.
* `attachments` — Permite adicionar anexos ao e-mail. Exemplo: `attachments['file-name.jpg'] = File.read('file-name.jpg')` que irá adicionar o arquivo `file-name.jpg` como anexo no e-mail.
* `mail` — Método usado para enviar o e-mail. Você pode usar a _hash_ `headers` como um dos parâmetros.
`mail` vai criar o e-mail, tanto em texto puro ou _multipart_, dependendo dos modelos disponiveis que você definiu.

#### Adicionando Anexos

Com o _Action Mailer_ é muito fácil trabalhar com anexos.

* Passe o nome do arquivo e o contéudo para o _Action Mailer_ e a [Mail gem](https://github.com/mikel/mail) irá descobrir o _mime type_ do arquivo, configurar a codificação e criar o anexo.

    ```ruby
    attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    ```

  Quando o método `mail` for invocado, enviará um e-mail no modo _multipart_
  com o anexo, corretamente configurado, sendo o anexo a primeira parte
  como `multipart/mixed` e a mensagem sendo a segunda com `multipart/alternative`
  com o texto e o HTML do e-mail.

NOTE: O anexo será codificado usando _Base64_ pelo `Mail`. Se você precisar de algo diferente, codifique previamente o contéudo e adicione o anexo e qual a codificação na _hash_ `attachments`.

* Passe o nome do arquivo, cabeçalhos especificos e o contéudo e o _Action Mailer_ e `Mail` irão usar as configurações:

    ```ruby
    encoded_content = SpecialEncode(File.read('/path/to/filename.jpg'))
    attachments['filename.jpg'] = {
      mime_type: 'application/gzip',
      encoding: 'SpecialEncoding',
      content: encoded_content
    }
    ```

NOTE: Se você especificar a codificação, `Mail` assumirá que o contéudo já está codificado e não irá codificar usando o padrão _Base64_.

#### Criando Anexos dentro da Mensagem de E-mail (_Inline_)

_Action Mailer_ 3.0 cria anexos dentro da mensagem de e-mail, algo que antes da versão 3.0 envolvia algumas gambiarras, de maneira muito simples e trivia como sempre deveria ter sido.

* Primeiro, para informar ao `Mail` que o anexo deve ser enviado dentro da própria mensagem você pode encadear o método `#inline` no `attachments` dentro da _action_ do seu _Mailer_:

    ```ruby
    def welcome
      attachments.inline['image.jpg'] = File.read('/path/to/image.jpg')
    end
    ```

* Na _view_, você só precisa especificar qual o anexo dentro de `attachments`, que é uma _hash_, você quer mostrar, encadeando o método `url` no anexo irá retornar o endereço do anexo e você pode passar o resultado para o método `image_tag` que renderiza uma imagem, veja o exemplo abaixo:

    ```html+erb
    <p>Hello there, this is our image</p>

    <%= image_tag attachments['image.jpg'].url %>
    ```

* Como isso é uma chamada normal ao método `image_tag` você pode passar uma _hash_ de opções após a _URL_ do anexo como você faria para qualquer outra imagem:

    ```html+erb
    <p>Hello there, this is our image</p>

    <%= image_tag attachments['image.jpg'].url, alt: 'My Photo', class: 'photos' %>
    ```

#### Enviando E-mail para Vários Destinatários

É possível enviar e-mail para um ou mais destinatários usando uma mensagem de e-mail (Por exemplo: notificando os administradores que houve um novo cadastro) bastando configurar uma lista de e-mails no parâmetro `:to`. Essa lista de e-mails pode ser um _Array_ de endereços de e-mails ou uma _String_ contendo todos os e-mails separados por vírgulas.

```ruby
class AdminMailer < ApplicationMailer
  default to: -> { Admin.pluck(:email) },
          from: 'notification@example.com'

  def new_registration(user)
    @user = user
    mail(subject: "New User Signup: #{@user.email}")
  end
end
```

```ruby
class AdminMailer < ApplicationMailer
  default to: 'email_one@test.com,email_two@test.com,email_three@test.com',
          from: 'notification@example.com'

  def new_registration(user)
    @user = user
    mail(subject: "New User Signup: #{@user.email}")
  end
end
```


O mesmo formato pode ser usado para enviar e-mails com cópia (Cc:) ou com cópia oculta (Cco: ou Bcc: em inglês), adicione `:cc` ou `:bcc` para enviar seguindo os padrões descritos acima.

#### Enviando E-mail com Nome

Em alguns momentos você deseja exibir o nome da pessoa que enviou ou recebe a mensagem ao inves de mostrar somente o e-mail. O truque para conseguir isso é usar a seguinte formatação no endereço de e-mail `"Nome Complete" <endereço_de_email>`.

```ruby
def welcome_email
  @user = params[:user]
  email_with_name = %("#{@user.name}" <#{@user.email}>)
  mail(to: email_with_name, subject: 'Welcome to My Awesome Site')
end
```

### Mailer Views

Mailer views are located in the `app/views/name_of_mailer_class` directory. The
specific mailer view is known to the class because its name is the same as the
mailer method. In our example from above, our mailer view for the
`welcome_email` method will be in `app/views/user_mailer/welcome_email.html.erb`
for the HTML version and `welcome_email.text.erb` for the plain text version.

To change the default mailer view for your action you do something like:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'Welcome to My Awesome Site',
         template_path: 'notifications',
         template_name: 'another')
  end
end
```

In this case it will look for templates at `app/views/notifications` with name
`another`.  You can also specify an array of paths for `template_path`, and they
will be searched in order.

If you want more flexibility you can also pass a block and render specific
templates or even render inline or text without using a template file:

```ruby
class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def welcome_email
    @user = params[:user]
    @url  = 'http://example.com/login'
    mail(to: @user.email,
         subject: 'Welcome to My Awesome Site') do |format|
      format.html { render 'another_template' }
      format.text { render plain: 'Render text' }
    end
  end
end
```

This will render the template 'another_template.html.erb' for the HTML part and
use the rendered text for the text part. The render command is the same one used
inside of Action Controller, so you can use all the same options, such as
`:text`, `:inline` etc.

If you would like to render a template located outside of the default `app/views/mailer_name/` directory, you can apply the `prepend_view_path`, like so:

```ruby
class UserMailer < ApplicationMailer
  prepend_view_path "custom/path/to/mailer/view"

  # This will try to load "custom/path/to/mailer/view/welcome_email" template
  def welcome_email
    # ...
  end
end
```

You can also consider using the [append_view_path](https://guides.rubyonrails.org/action_view_overview.html#view-paths) method.

#### Caching mailer view

You can perform fragment caching in mailer views like in application views using the `cache` method.

```
<% cache do %>
  <%= @company.name %>
<% end %>
```

And in order to use this feature, you need to configure your application with this:

```
  config.action_mailer.perform_caching = true
```

Fragment caching is also supported in multipart emails.
Read more about caching in the [Rails caching guide](caching_with_rails.html).

### Action Mailer Layouts

Just like controller views, you can also have mailer layouts. The layout name
needs to be the same as your mailer, such as `user_mailer.html.erb` and
`user_mailer.text.erb` to be automatically recognized by your mailer as a
layout.

In order to use a different file, call `layout` in your mailer:

```ruby
class UserMailer < ApplicationMailer
  layout 'awesome' # use awesome.(html|text).erb as the layout
end
```

Just like with controller views, use `yield` to render the view inside the
layout.

You can also pass in a `layout: 'layout_name'` option to the render call inside
the format block to specify different layouts for different formats:

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

Will render the HTML part using the `my_layout.html.erb` file and the text part
with the usual `user_mailer.text.erb` file if it exists.

### Previewing Emails

Action Mailer previews provide a way to see how emails look by visiting a
special URL that renders them. In the above example, the preview class for
`UserMailer` should be named `UserMailerPreview` and located in
`test/mailers/previews/user_mailer_preview.rb`. To see the preview of
`welcome_email`, implement a method that has the same name and call
`UserMailer.welcome_email`:

```ruby
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end
end
```

Then the preview will be available in <http://localhost:3000/rails/mailers/user_mailer/welcome_email>.

If you change something in `app/views/user_mailer/welcome_email.html.erb`
or the mailer itself, it'll automatically reload and render it so you can
visually see the new style instantly. A list of previews are also available
in <http://localhost:3000/rails/mailers>.

By default, these preview classes live in `test/mailers/previews`.
This can be configured using the `preview_path` option. For example, if you
want to change it to `lib/mailer_previews`, you can configure it in
`config/application.rb`:

```ruby
config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"
```

### Generating URLs in Action Mailer Views

Unlike controllers, the mailer instance doesn't have any context about the
incoming request so you'll need to provide the `:host` parameter yourself.

As the `:host` usually is consistent across the application you can configure it
globally in `config/application.rb`:

```ruby
config.action_mailer.default_url_options = { host: 'example.com' }
```

Because of this behavior you cannot use any of the `*_path` helpers inside of
an email. Instead you will need to use the associated `*_url` helper. For example
instead of using

```
<%= link_to 'welcome', welcome_path %>
```

You will need to use:

```
<%= link_to 'welcome', welcome_url %>
```

By using the full URL, your links will now work in your emails.

#### Generating URLs with `url_for`

`url_for` generates a full URL by default in templates.

If you did not configure the `:host` option globally make sure to pass it to
`url_for`.


```erb
<%= url_for(host: 'example.com',
            controller: 'welcome',
            action: 'greeting') %>
```

#### Generating URLs with Named Routes

Email clients have no web context and so paths have no base URL to form complete
web addresses. Thus, you should always use the "_url" variant of named route
helpers.

If you did not configure the `:host` option globally make sure to pass it to the
URL helper.

```erb
<%= user_url(@user, host: 'example.com') %>
```

NOTE: non-`GET` links require [rails-ujs](https://github.com/rails/rails/blob/master/actionview/app/assets/javascripts) or
[jQuery UJS](https://github.com/rails/jquery-ujs), and won't work in mailer templates.
They will result in normal `GET` requests.

### Adding images in Action Mailer Views

Unlike controllers, the mailer instance doesn't have any context about the
incoming request so you'll need to provide the `:asset_host` parameter yourself.

As the `:asset_host` usually is consistent across the application you can
configure it globally in `config/application.rb`:

```ruby
config.action_mailer.asset_host = 'http://example.com'
```

Now you can display an image inside your email.

```ruby
<%= image_tag 'image.jpg' %>
```

### Sending Multipart Emails

Action Mailer will automatically send multipart emails if you have different
templates for the same action. So, for our `UserMailer` example, if you have
`welcome_email.text.erb` and `welcome_email.html.erb` in
`app/views/user_mailer`, Action Mailer will automatically send a multipart email
with the HTML and text versions setup as different parts.

The order of the parts getting inserted is determined by the `:parts_order`
inside of the `ActionMailer::Base.default` method.

### Sending Emails with Dynamic Delivery Options

If you wish to override the default delivery options (e.g. SMTP credentials)
while delivering emails, you can do this using `delivery_method_options` in the
mailer action.

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

### Sending Emails without Template Rendering

There may be cases in which you want to skip the template rendering step and
supply the email body as a string. You can achieve this using the `:body`
option. In such cases don't forget to add the `:content_type` option. Rails
will default to `text/plain` otherwise.

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

Action Mailer Callbacks
-----------------------

*Action Mailer* permite que você especifique o `before_action`, `after_action` e
`around_action`.

* Filtros podem ser especificados com um bloco ou um *symbol* para um  método no *Mailer*, similar a um *controller*

* Você pode usar um `before_action` para preencher o objeto de email com valores padrões, `delivery_method_options` ou inserir *headers* e anexos padrões. 

```ruby
class InvitationsMailer < ApplicationMailer
  before_action { @inviter, @invitee = params[:inviter], params[:invitee] }
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
end
```

* Você pode usar um `after_action` para fazer uma configuração semelhante ao `before_action`, mas usando variáveis de instância definidas em sua *action* do *mailer*.

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

O *Action Mailer* agora herda apenas do `AbstractController`, para que você tenha acesso aos mesmos *helpers* genéricos que no *Action Controller*.

Action Mailer Configuration
---------------------------

The following configuration options are best made in one of the environment
files (environment.rb, production.rb, etc...)

| Configuration | Description |
|---------------|-------------|
|`logger`|Generates information on the mailing run if available. Can be set to `nil` for no logging. Compatible with both Ruby's own `Logger` and `Log4r` loggers.|
|`smtp_settings`|Allows detailed configuration for `:smtp` delivery method:<ul><li>`:address` - Allows you to use a remote mail server. Just change it from its default `"localhost"` setting.</li><li>`:port` - On the off chance that your mail server doesn't run on port 25, you can change it.</li><li>`:domain` - If you need to specify a HELO domain, you can do it here.</li><li>`:user_name` - If your mail server requires authentication, set the username in this setting.</li><li>`:password` - If your mail server requires authentication, set the password in this setting.</li><li>`:authentication` - If your mail server requires authentication, you need to specify the authentication type here. This is a symbol and one of `:plain` (will send the password in the clear), `:login` (will send password Base64 encoded) or `:cram_md5` (combines a Challenge/Response mechanism to exchange information and a cryptographic Message Digest 5 algorithm to hash important information)</li><li>`:enable_starttls_auto` - Detects if STARTTLS is enabled in your SMTP server and starts to use it. Defaults to `true`.</li><li>`:openssl_verify_mode` - When using TLS, you can set how OpenSSL checks the certificate. This is really useful if you need to validate a self-signed and/or a wildcard certificate. You can use the name of an OpenSSL verify constant ('none' or 'peer') or directly the constant (`OpenSSL::SSL::VERIFY_NONE` or `OpenSSL::SSL::VERIFY_PEER`).</li><li>`:ssl/:tls` - Enables the SMTP connection to use SMTP/TLS (SMTPS: SMTP over direct TLS connection)</li></ul>|
|`sendmail_settings`|Allows you to override options for the `:sendmail` delivery method.<ul><li>`:location` - The location of the sendmail executable. Defaults to `/usr/sbin/sendmail`.</li><li>`:arguments` - The command line arguments to be passed to sendmail. Defaults to `-i`.</li></ul>|
|`raise_delivery_errors`|Whether or not errors should be raised if the email fails to be delivered. This only works if the external email server is configured for immediate delivery.|
|`delivery_method`|Defines a delivery method. Possible values are:<ul><li>`:smtp` (default), can be configured by using `config.action_mailer.smtp_settings`.</li><li>`:sendmail`, can be configured by using `config.action_mailer.sendmail_settings`.</li><li>`:file`: save emails to files; can be configured by using `config.action_mailer.file_settings`.</li><li>`:test`: save emails to `ActionMailer::Base.deliveries` array.</li></ul>See [API docs](https://api.rubyonrails.org/classes/ActionMailer/Base.html) for more info.|
|`perform_deliveries`|Determines whether deliveries are actually carried out when the `deliver` method is invoked on the Mail message. By default they are, but this can be turned off to help functional testing. If this value is `false`, `deliveries` array will not be populated even if `delivery_method` is `:test`.|
|`deliveries`|Keeps an array of all the emails sent out through the Action Mailer with delivery_method :test. Most useful for unit and functional testing.|
|`default_options`|Allows you to set default values for the `mail` method options (`:from`, `:reply_to`, etc.).|

For a complete writeup of possible configurations see the
[Configuring Action Mailer](configuring.html#configuring-action-mailer) in
our Configuring Rails Applications guide.

### Example Action Mailer Configuration

An example would be adding the following to your appropriate
`config/environments/$RAILS_ENV.rb` file:

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

### Action Mailer Configuration for Gmail

As Action Mailer now uses the [Mail gem](https://github.com/mikel/mail), this
becomes as simple as adding to your `config/environments/$RAILS_ENV.rb` file:

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
NOTE: As of July 15, 2014, Google increased [its security measures](https://support.google.com/accounts/answer/6010255) and now blocks attempts from apps it deems less secure.
You can change your Gmail settings [here](https://www.google.com/settings/security/lesssecureapps) to allow the attempts. If your Gmail account has 2-factor authentication enabled,
then you will need to set an [app password](https://myaccount.google.com/apppasswords) and use that instead of your regular password. Alternatively, you can
use another ESP to send email by replacing 'smtp.gmail.com' above with the address of your provider.

Testes de *Mailer*
--------------

Você encontrará instruções detalhadas de como testar seus *mailers* no 
[guia de teste](testing.html#testing-your-mailers).

Intercepting and Observing Emails
-------------------

Action Mailer provides hooks into the Mail observer and interceptor methods. These allow you to register classes that are called during the mail delivery life cycle of every email sent.

### Intercepting Emails

Interceptors allow you to make modifications to emails before they are handed off to the delivery agents. An interceptor class must implement the `:delivering_email(message)` method which will be called before the email is sent.

```ruby
class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['sandbox@example.com']
  end
end
```

Before the interceptor can do its job you need to register it with the Action
Mailer framework. You can do this in an initializer file
`config/initializers/sandbox_email_interceptor.rb`

```ruby
if Rails.env.staging?
  ActionMailer::Base.register_interceptor(SandboxEmailInterceptor)
end
```

NOTE: The example above uses a custom environment called "staging" for a
production like server but for testing purposes. You can read
[Creating Rails environments](configuring.html#creating-rails-environments)
for more information about custom Rails environments.

### Observing Emails

Observers give you access to the email message after it has been sent. An observer class must implement the `:delivered_email(message)` method, which will be called after the email is sent.

```ruby
class EmailDeliveryObserver
  def self.delivered_email(message)
    EmailDelivery.log(message)
  end
end
```
Like interceptors, you need to register observers with the Action Mailer framework. You can do this in an initializer file
`config/initializers/email_delivery_observer.rb`

```ruby
ActionMailer::Base.register_observer(EmailDeliveryObserver)
```
