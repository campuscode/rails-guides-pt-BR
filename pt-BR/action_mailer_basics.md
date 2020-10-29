**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Noções básicas do _Action Mailer_
====================

Este guia fornece tudo que você precisa para começar a enviar
e-mails de e para seu aplicativo e muitos componentes internos do _Action Mailer_. 
Também aborda como testar seus mailers.

Depois de ler este guia, você saberá:

* Como enviar e-mail em uma aplicação Rails.
* Como gerar e editar uma classe do _Action Mailer_ e uma visão do _mailer view_.
* Como configurar o _Action Mailer_ para o seu ambiente.
* Como testar suas classes do _Action Mailer_.

--------------------------------------------------------------------------------

Introdução
------------

*Action Mailer* permite que você envie emails direto da sua aplicação usando as 
classes e views *Mailer*

#### Mailers são semelhantes a controllers

Eles herdam do `ActionMailer::Base` e se encontram na `app/mailers`. Os Mailers também funcionam de maneira muito semelhante aos controllers. Alguns exemplos de semelhanças são mostrados abaixo.
Mailers tem:

* *Actions*, e também, *views* associadas que aparecem em `app/views`.
* Variáveis de instância acessíveis nas *views*.
* A capacidade de utilizar *layouts* e *partials*.
* A capacidade de acessar um hash de parâmetros.

Sending Emails
--------------

This section will provide a step-by-step guide to creating a mailer and its
views.

### Walkthrough to Generating a Mailer

#### Create the Mailer

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

As you can see, you can generate mailers just like you use other generators with
Rails.

If you didn't want to use a generator, you could create your own file inside of
`app/mailers`, just make sure that it inherits from `ActionMailer::Base`:

```ruby
class MyMailer < ActionMailer::Base
end
```

#### Edit the Mailer

Mailers have methods called "actions" and they use views to structure their content.
Where a controller generates content like HTML to send back to the client, a Mailer
creates a message to be delivered via email.

`app/mailers/user_mailer.rb` contains an empty mailer:

```ruby
class UserMailer < ApplicationMailer
end
```

Let's add a method called `welcome_email`, that will send an email to the user's
registered email address:

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

Here is a quick explanation of the items presented in the preceding method. For
a full list of all available options, please have a look further down at the
Complete List of Action Mailer user-settable attributes section.

* `default Hash` - This is a hash of default values for any email you send from
this mailer. In this case we are setting the `:from` header to a value for all
messages in this class. This can be overridden on a per-email basis.
* `mail` - The actual email message, we are passing the `:to` and `:subject`
headers in.

#### Create a Mailer View

Create a file called `welcome_email.html.erb` in `app/views/user_mailer/`. This
will be the template used for the email, formatted in HTML:

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

Let's also make a text part for this email. Not all clients prefer HTML emails,
and so sending both is best practice. To do this, create a file called
`welcome_email.text.erb` in `app/views/user_mailer/`:

```erb
Welcome to example.com, <%= @user.name %>
===============================================

You have successfully signed up to example.com,
your username is: <%= @user.login %>.

To login to the site, just follow this link: <%= @url %>.

Thanks for joining and have a great day!
```

When you call the `mail` method now, Action Mailer will detect the two templates
(text and HTML) and automatically generate a `multipart/alternative` email.

#### Calling the Mailer

Mailers are really just another way to render a view. Instead of rendering a
view and sending it over the HTTP protocol, they are just sending it out through
the email protocols instead. Due to this, it makes sense to just have your
controller tell the Mailer to send an email when a user is successfully created.

Setting this up is simple.

First, let's create a simple `User` scaffold:

```bash
$ rails generate scaffold user name email login
$ rails db:migrate
```

Now that we have a user model to play with, we will just edit the
`app/controllers/users_controller.rb` make it instruct the `UserMailer` to deliver
an email to the newly created user by editing the create action and inserting a
call to `UserMailer.with(user: @user).welcome_email` right after the user is successfully saved.

Action Mailer is nicely integrated with Active Job so you can send emails outside
of the request-response cycle, so the user doesn't have to wait on it:

```ruby
class UsersController < ApplicationController
  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        # Tell the UserMailer to send a welcome email after save
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

NOTE: Active Job's default behavior is to execute jobs via the `:async` adapter. So, you can use
`deliver_later` now to send emails asynchronously.
Active Job's default adapter runs jobs with an in-process thread pool.
It's well-suited for the development/test environments, since it doesn't require
any external infrastructure, but it's a poor fit for production since it drops
pending jobs on restart.
If you need a persistent backend, you will need to use an Active Job adapter
that has a persistent backend (Sidekiq, Resque, etc).

NOTE: When calling `deliver_later` the job will be placed under `mailers` queue. Make sure Active Job adapter support it otherwise the job may be silently ignored preventing email delivery. You can change that by specifying `config.action_mailer.deliver_later_queue_name` option.

If you want to send emails right away (from a cronjob for example) just call
`deliver_now`:

```ruby
class SendWeeklySummary
  def run
    User.find_each do |user|
      UserMailer.with(user: user).weekly_summary.deliver_now
    end
  end
end
```

Any key value pair passed to `with` just becomes the `params` for the mailer
action. So `with(user: @user, account: @user.account)` makes `params[:user]` and
`params[:account]` available in the mailer action. Just like controllers have
params.

The method `welcome_email` returns an `ActionMailer::MessageDelivery` object which
can then just be told `deliver_now` or `deliver_later` to send itself out. The
`ActionMailer::MessageDelivery` object is just a wrapper around a `Mail::Message`. If
you want to inspect, alter, or do anything else with the `Mail::Message` object you can
access it with the `message` method on the `ActionMailer::MessageDelivery` object.

### Auto encoding header values

Action Mailer handles the auto encoding of multibyte characters inside of
headers and bodies.

For more complex examples such as defining alternate character sets or
self-encoding text first, please refer to the
[Mail](https://github.com/mikel/mail) library.

### Complete List of Action Mailer Methods

There are just three methods that you need to send pretty much any email
message:

* `headers` - Specifies any header on the email you want. You can pass a hash of
  header field names and value pairs, or you can call `headers[:field_name] =
  'value'`.
* `attachments` - Allows you to add attachments to your email. For example,
  `attachments['file-name.jpg'] = File.read('file-name.jpg')`.
* `mail` - Sends the actual email itself. You can pass in headers as a hash to
  the mail method as a parameter, mail will then create an email, either plain
  text, or multipart, depending on what email templates you have defined.

#### Adding Attachments

Action Mailer makes it very easy to add attachments.

* Pass the file name and content and Action Mailer and the
  [Mail gem](https://github.com/mikel/mail) will automatically guess the
  mime_type, set the encoding, and create the attachment.

    ```ruby
    attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    ```

  When the `mail` method will be triggered, it will send a multipart email with
  an attachment, properly nested with the top level being `multipart/mixed` and
  the first part being a `multipart/alternative` containing the plain text and
  HTML email messages.

NOTE: Mail will automatically Base64 encode an attachment. If you want something
different, encode your content and pass in the encoded content and encoding in a
`Hash` to the `attachments` method.

* Pass the file name and specify headers and content and Action Mailer and Mail
  will use the settings you pass in.

    ```ruby
    encoded_content = SpecialEncode(File.read('/path/to/filename.jpg'))
    attachments['filename.jpg'] = {
      mime_type: 'application/gzip',
      encoding: 'SpecialEncoding',
      content: encoded_content
    }
    ```

NOTE: If you specify an encoding, Mail will assume that your content is already
encoded and not try to Base64 encode it.

#### Making Inline Attachments

Action Mailer 3.0 makes inline attachments, which involved a lot of hacking in pre 3.0 versions, much simpler and trivial as they should be.

* First, to tell Mail to turn an attachment into an inline attachment, you just call `#inline` on the attachments method within your Mailer:

    ```ruby
    def welcome
      attachments.inline['image.jpg'] = File.read('/path/to/image.jpg')
    end
    ```

* Then in your view, you can just reference `attachments` as a hash and specify
  which attachment you want to show, calling `url` on it and then passing the
  result into the `image_tag` method:

    ```html+erb
    <p>Hello there, this is our image</p>

    <%= image_tag attachments['image.jpg'].url %>
    ```

* As this is a standard call to `image_tag` you can pass in an options hash
  after the attachment URL as you could for any other image:

    ```html+erb
    <p>Hello there, this is our image</p>

    <%= image_tag attachments['image.jpg'].url, alt: 'My Photo', class: 'photos' %>
    ```

#### Sending Email To Multiple Recipients

It is possible to send email to one or more recipients in one email (e.g.,
informing all admins of a new signup) by setting the list of emails to the `:to`
key. The list of emails can be an array of email addresses or a single string
with the addresses separated by commas.

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

The same format can be used to set carbon copy (Cc:) and blind carbon copy
(Bcc:) recipients, by using the `:cc` and `:bcc` keys respectively.

#### Sending Email With Name

Sometimes you wish to show the name of the person instead of just their email
address when they receive the email. The trick to doing that is to format the
email address in the format `"Full Name" <email>`.

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

Callbacks do _Action Mailer_
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

Configuração do _Action Mailer_
---------------------------

As seguintes opções de configuração são feitas melhor em um dos ambientes
arquivos (environment.rb, production.rb, etc...)

| Configuração  | Descrição |
|---------------|-------------|
|`logger`|Gera informações sobre a execução de correspondência, se disponível. Pode ser definido como `nil` para nenhum registro. Compatível com os _loggers_ `Logger` e `Log4r` do Ruby.|
|`smtp_settings`|Permite configuração detalhada para `:smtp` Método de Entrega:<ul><li>`:address` - Permite que você use um servidor de e-mail remoto. Basta alterá-lo do padrão `"localhost"` configuração.</li><li>`:port` - Na chance de seu servidor de e-mail não funcionar na porta 25, você pode alterá-lo.</li><li>`:domain` - Se você precisar especificar um domínio HELO, pode fazê-lo aqui.</li><li>`:user_name` - Se o seu servidor de e-mail requer autenticação, defina o nome de usuário neste configuração.</li><li>`:password` - Se o seu servidor de e-mail requer autenticação, defina a senha neste configuração.</li><li>`:authentication` - Se o seu servidor de e-mail requer autenticação, você precisa especificar o tipo de autenticação aqui. Este é um símbolo e um dos `:plain` (irá enviar a senha em claro), `:login` (irá enviar senha codificada em Base64) or `:cram_md5` (combina um mecanismo de desafio / resposta para trocar informações e um algoritmo criptográfico Message Digest 5 para hash informações importantes)</li><li>`:enable_starttls_auto` - Detecta se STARTTLS está habilitado em seu servidor SMTP e começa a usá-lo. Defaults to `true`.</li><li>`:openssl_verify_mode` - Ao usar TLS, você pode definir como o OpenSSL verifica o certificado. Isso é realmente útil se você precisar validar um certificado autoassinado e / ou curinga. Você pode usar o nome de uma constante de verificação OpenSSL ('nenhum' ou 'par') ou diretamente a constante (`OpenSSL::SSL::VERIFY_NONE` ou `OpenSSL::SSL::VERIFY_PEER`).</li><li>`:ssl/:tls` - Permite que a conexão SMTP use SMTP / TLS (SMTPS: SMTP sobre conexão TLS direta)</li></ul>|
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

Os interceptores permitem que você faça modificações em emails antes que eles sejam entregues aos agentes de entrega. Uma classe de interceptor deve implementar o método `:delivering_email(message)` que será chamado antes do e-mail ser enviado.

```ruby
class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['sandbox@example.com']
  end
end
```

Antes que o interceptor possa fazer seu trabalho, você precisa registrá-lo com o _Action Mailer_. 
Você pode fazer isso em um arquivo inicializador
`config/initializers/sandbox_email_interceptor.rb`

```ruby
if Rails.env.staging?
  ActionMailer::Base.register_interceptor(SandboxEmailInterceptor)
end
```

NOTE: O exemplo acima usa um ambiente personalizado chamado "staging" para um
servidor como em produção, mas para fins de teste. Você pode ler
[Criação de ambientes Rails](configuring.html#creating-rails-environments)
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
Como os interceptores, você precisa registrar observadores com a estrutura do _Action Mailer_. Você pode fazer isso em um arquivo inicializador
`config/initializers/email_delivery_observer.rb`

```ruby
ActionMailer::Base.register_observer(EmailDeliveryObserver)
```
