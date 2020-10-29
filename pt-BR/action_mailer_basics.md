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

Enviar e-mails
--------------

Esta seção fornecerá um guia passo a passo para criar uma mala direta e seu
Visualizações.

### Passo a passo para gerar um mailer

#### Crie o Mailer

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

Como você pode ver, você pode gerar mailers assim como usa outros geradores com
Trilhos.

Se você não quiser usar um gerador, você pode criar seu próprio arquivo dentro de
`app/mailers`, apenas certifique-se de que herda de `ActionMailer::Base`:

```ruby
class MyMailer < ActionMailer::Base
end
```

#### Edite o Mailer

Mailers têm métodos chamados "ações" e eles usam visualizações para estruturar seu conteúdo.
Onde um controlador gera conteúdo como HTML para enviar de volta ao cliente, um Mailer
cria uma mensagem a ser entregue por e-mail.

`app/mailers/user_mailer.rb` contains an empty mailer:

```ruby
class UserMailer < ApplicationMailer
end
```

Vamos adicionar um método chamado `welcome_email`, que irá enviar um e-mail para o usuário
endereço de email registrado:

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

Aqui está uma explicação rápida dos itens apresentados no método anterior. 
Parauma lista completa de todas as opções disponíveis, dê uma olhada mais abaixo no
Lista completa de seção de atributos definidos pelo usuário do Action Mailer.

* `Hash padrão` - Este é um hash de valores padrão para qualquer e-mail enviado de
este mailer. Neste caso, estamos definindo o `:a partir de` cabeçalho para um valor para todos
mensagens nesta aula. Isso pode ser substituído por e-mail.
* `enviar` - A mensagem de e-mail real, estamos passando o `:para` and `:subject`
cabeçalhos em.

#### Criar uma Visualização do Mailer

Crie um arquivo chamado `welcome_email.html.erb` in `app/views/user_mailer/`. Esta
será o modelo usado para o e-mail, formatado em HTML:

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

Vamos também fazer uma parte de texto para este e-mail. Nem todos os clientes preferem e-mails em HTML, e enviar ambos é a prática recomendada. Para fazer isso, crie um arquivo chamado
`welcome_email.text.erb` in `app/views/user_mailer/`:

```erb
Welcome to example.com, <%= @user.name %>
===============================================

Você se inscreveu com sucesso em example.com,
Seu nome de usuário é: <%= @user.login %>.

Para acessar o site, basta seguir este link: <%= @url %>.

Obrigado por aderir e tenha um ótimo dia!
```

Quando você chamar o método `mail` agora, Action Mailer irá detectar os dois modelos
(texto e HTML) e gerar automaticamente um e-mail `multipart / alternative`.

#### Ligando para o Mailer

Mailers são apenas outra maneira de renderizar uma visualização. Em vez de renderizar um
visualizar e enviá-lo pelo protocolo HTTP, eles estão apenas enviando-o por meio de
os protocolos de e-mail em vez. Devido a isso, faz sentido apenas ter seu
controlador diz ao Mailer para enviar um e-mail quando um usuário é criado com sucesso.

Configurar isso é simples.

First, let's create a simple `User` scaffold:

```bash
$ rails generate scaffold user name email login
$ rails db:migrate
```

Agora que temos um modelo de usuário para brincar, vamos apenas editar o
`app/controllers/users_controller.rb` faça instruir o `UserMailer` 
entregarum e-mail para o usuário recém-criado, editando a ação criar e inserindo um
ligar para `UserMailer.with(user: @user).welcome_email` logo após o usuário ser salvo com sucesso.

Action Mailer está bem integrado com Active Job para que você possa enviar e-mails para fora
do ciclo de solicitação-resposta, para que o usuário não precise esperar:

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

NOTA: O comportamento padrão do Active Job é executar jobs via adaptador `: async`. Então, você pode usar
`Deliver_later` agora para enviar emails de forma assíncrona.
O adaptador padrão do Active Job executa trabalhos com um pool de threads em processo.
É adequado para os ambientes de desenvolvimento / teste, uma vez que não requer
qualquer infraestrutura externa, mas é um ajuste ruim para a produção, pois cai
trabalhos pendentes ao reiniciar.
Se você precisar de um back-end persistente, você precisará usar um adaptador Active Job
que tem um back-end persistente (Sidekiq, Resque, etc).

NOTA: Ao ligar `deliver_later` o trabalho será colocado sob `mailers` fila. Certifique-se de que o adaptador Active Job o suporte, caso contrário, o trabalho pode ser ignorado silenciosamente, impedindo a entrega de e-mail. Você pode mudar isso especificando `config.action_mailer.deliver_later_queue_name` opção.

Se você quiser enviar e-mails imediatamente (de um cronjob, por exemplo) apenas ligue
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

Qualquer par de valores-chave passado para `with` apenas se torna o `params` 
para o maileraçao. So `with(user: @user, account: @user.account)` makes `params[:user]` and
`params[:account]` disponível na ação mailer. Assim como os controladores
params.

O método `welcome_email` retorna um `ActionMailer::MessageDelivery` 
objeto quepode então ser apenas dito `deliver_now` or `deliver_later` enviar-se para fora. The
`ActionMailer::MessageDelivery` objeto é apenas um invólucro em torno de um `Mail::Message`. 
E sevocê deseja inspecionar, alterar ou fazer qualquer outra coisa com o `Mail::Message` objeto você pode
acesse-o com o `message` método no `ActionMailer::MessageDelivery` objeto.

### Valores de cabeçalho de codificação automática

Action Mailer lida com a codificação automática de caracteres multibyte dentro de
cabeçalhos e corpos.

Para exemplos mais complexos, como definir conjuntos de caracteres alternativos ou
texto auto-codificado primeiro, consulte o
[Mail](https://github.com/mikel/mail) library.

### Lista completa de métodos do Action Mailer

Existem apenas três métodos que você precisa para enviar praticamente qualquer e-mail
mensagem:

* `headers` - Especifica qualquer cabeçalho do email que você deseja. Você pode passar um hash de
  nomes de campos de cabeçalho e pares de valores, ou você pode chamar `headers[:field_name] =
  'value'`.
* `attachments` - Permite que você adicione anexos ao seu e-mail. For example,
  `attachments['file-name.jpg'] = File.read('file-name.jpg')`.
* `mail` - Envia o próprio e-mail. Você pode passar cabeçalhos como um hash para
  o método mail como parâmetro, o mail criará um e-mail, simples
  texto ou multiparte, dependendo de quais modelos de e-mail você definiu.

#### Adicionando anexos

Action Mailer torna muito fácil adicionar anexos.

* Passe o nome do arquivo e conteúdo e Action Mailer e o
  [Mail gem](https://github.com/mikel/mail) irá adivinhar automaticamente o
  mime_type, defina a codificação e crie o anexo.

    ```ruby
    attachments['filename.jpg'] = File.read('/path/to/filename.jpg')
    ```

  Quando o `enviar` método será acionado, ele enviará um e-mail multiparte com
  um anexo, devidamente aninhado com o nível superior sendo `multipart/mixed` e
  a primeira parte sendo um `multipart/alternative` contendo o texto simples e
  Mensagens de e-mail em HTML.

NOTA: O Mail codificará automaticamente em Base64 um anexo. Se você quer algo
diferente, codifique seu conteúdo e passe o conteúdo codificado e a codificação em um
`Hash` para o método ʻattachments`.

* Passe o nome do arquivo e especifique cabeçalhos e conteúdo e Action Mailer e Mail
  usará as configurações que você passar.

    ```ruby
    encoded_content = SpecialEncode(File.read('/path/to/filename.jpg'))
    attachments['filename.jpg'] = {
      mime_type: 'application/gzip',
      encoding: 'SpecialEncoding',
      content: encoded_content
    }
    ```

NOTA: Se você especificar uma codificação, o Mail irá assumir que seu conteúdo já está
codificado e não tente codificá-lo em Base64.

#### Criação de anexos inline

Action Mailer 3.0 cria anexos embutidos, que envolviam muitos hackers nas versões anteriores à 3.0, muito mais simples e triviais como deveriam ser.

* Primeiro, para dizer ao Mail para transformar um anexo em um anexo embutido, basta chamar `# inline` no método de anexos dentro do seu Mailer:

    ```ruby
    def welcome
      attachments.inline['image.jpg'] = File.read('/path/to/image.jpg')
    end
    ```

* Então, em sua visão, você pode apenas referenciar "anexos" como um hash e especificar
  qual anexo você deseja mostrar, chamando ʻurl` nele e depois passando o
  resultado no método ʻimage_tag`:

    ```html+erb
    <p>Hello there, this is our image</p>

    <%= image_tag attachments['image.jpg'].url %>
    ```

* Como esta é uma chamada padrão para ʻimage_tag`, você pode passar um hash de opções
  após o URL do anexo, como faria com qualquer outra imagem:

    ```html+erb
    <p>Hello there, this is our image</p>

    <%= image_tag attachments['image.jpg'].url, alt: 'My Photo', class: 'photos' %>
    ```

#### Enviando e-mail para vários destinatários

É possível enviar e-mail para um ou mais destinatários em um e-mail (por exemplo,
informando todos os administradores de uma nova inscrição) definindo a lista de e-mails para `: to`
chave. A lista de e-mails pode ser uma matriz de endereços de e-mail ou uma única string
com os endereços separados por vírgulas.

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

O mesmo formato pode ser usado para definir a cópia carbono (Cc :) e a cópia oculta
(Destinatários Bcc :), usando as chaves `: cc` e`: bcc` respectivamente.

#### Enviando Email com Nome

Às vezes você deseja mostrar o nome da pessoa em vez de apenas seu e-mail
endereço ao receberem o e-mail. O truque para fazer isso é formatar o
endereço de e-mail no formato `" Nome Completo "<email>`.

```ruby
def welcome_email
  @user = params[:user]
  email_with_name = %("#{@user.name}" <#{@user.email}>)
  mail(to: email_with_name, subject: 'Welcome to My Awesome Site')
end
```

### Visualizações do Mailer

As visualizações do Mailer estão localizadas no diretório ʻapp / views / name_of_mailer_class`. o
a visão específica do mailer é conhecida pela classe porque seu nome é o mesmo que o
método mailer. Em nosso exemplo acima, nossa visualização de mala direta para o
método `welcome_email` estará em ʻapp / views / user_mailer / welcome_email.html.erb`
para a versão HTML e `welcome_email.text.erb` para a versão de texto simples.

Para alterar a visualização padrão do mailer para sua ação, você faz algo como:

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

Neste caso, ele procurará por modelos em ʻapp / views / Notifications` com o nome
ʻAnother`. Você também pode especificar uma matriz de caminhos para `template_path`, e eles
será pesquisado em ordem.

Se você quiser mais flexibilidade, você também pode passar um bloco e renderizar
modelos ou até mesmo renderizar inline ou texto sem usar um arquivo de modelo:

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

Isso renderizará o modelo 'another_template.html.erb' para a parte HTML e
use o texto renderizado para a parte do texto. O comando de renderização é o mesmo usado
dentro do Action Controller, para que você possa usar todas as mesmas opções, como
`: text`,`: inline` etc.

Se você gostaria de renderizar um template localizado fora do diretório padrão ʻapp / views / mailer_name / `, você pode aplicar o` prepend_view_path`, assim:

```ruby
class UserMailer < ApplicationMailer
  prepend_view_path "custom/path/to/mailer/view"

  # This will try to load "custom/path/to/mailer/view/welcome_email" template
  def welcome_email
    # ...
  end
end
```

Você também pode considerar o uso do método [append_view_path](https://guides.rubyonrails.org/action_view_overview.html#view-paths).

#### Visualização da mala direta em cache

Você pode realizar o cache de fragmentos em visualizações de mailer como em visualizações de aplicativos usando o método `cache`.

```
<% cache do %>
  <%= @company.name %>
<% end %>
```

E para usar este recurso, você precisa configurar seu aplicativo com este:

```
  config.action_mailer.perform_caching = true
```

O armazenamento em cache de fragmentos também é compatível com e-mails multipartes.
Leia mais sobre caching no [Rails caching guide](caching_with_rails.html).

### Layouts do Action Mailer

Assim como as visualizações do controlador, você também pode ter layouts de mailer. O nome do layout
precisa ser igual ao seu mailer, como ʻuser_mailer.html.erb` e
ʻUser_mailer.text.erb` seja automaticamente reconhecido por seu mailer como um
layout.

Para usar um arquivo diferente, chame `layout` em seu mailer:

```ruby
class UserMailer < ApplicationMailer
  layout 'awesome' # use awesome.(html|text).erb as the layout
end
```

Assim como com visualizações de controlador, use `yield` para renderizar a visualização dentro do
layout.

Você também pode passar uma opção `layout: 'layout_name'` para a chamada de renderização dentro
o bloco de formato para especificar layouts diferentes para formatos diferentes:

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

Irá renderizar a parte HTML usando o arquivo `my_layout.html.erb` e a parte de texto
com o arquivo usual ʻuser_mailer.text.erb` se ele existir.

### Visualizando e-mails

As visualizações do Action Mailer fornecem uma maneira de ver a aparência dos e-mails visitando um
URL especial que os renderiza. No exemplo acima, a classe de visualização para
ʻUserMailer` deve ser nomeado ʻUserMailerPreview` e localizado em
`test / mailers / previews / user_mailer_preview.rb`. Para ver a prévia de
`welcome_email`, implemente um método que tenha o mesmo nome e chame
ʻUserMailer.welcome_email`:

```ruby
class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(user: User.first).welcome_email
  end
end
```

Em seguida, a visualização estará disponível em  
<http://localhost:3000/rails/mailers/user_mailer/welcome_email>.

Se você mudar algo em ʻapp / views / user_mailer / welcome_email.html.erb`
ou o próprio mailer, ele irá recarregar e renderizar automaticamente para que você possa
veja visualmente o novo estilo instantaneamente. Uma lista de visualizações também está disponível
dentro <http://localhost:3000/rails/mailers>.

Por padrão, essas classes de visualização vivem em `test / mailers / previews`.
Isso pode ser configurado usando a opção `preview_path`. Por exemplo, se você
deseja alterá-lo para `lib / mailer_previews`, você pode configurá-lo em
`config/application.rb`:

```ruby
config.action_mailer.preview_path = "#{Rails.root}/lib/mailer_previews"
```

### Generating URLs in Action Mailer Views

Ao contrário dos controladores, a instância do mailer não tem nenhum contexto sobre o
solicitação de entrada, então você precisará fornecer o parâmetro `: host` você mesmo.

Enquanto o `:host` geralmente é consistente em todo o aplicativo, você pode configurá-lo
globalmente em `config/application.rb`:

```ruby
config.action_mailer.default_url_options = { host: 'example.com' }
```

Devido a este comportamento, você não pode usar nenhum dos ajudantes `* _path` dentro de
um email. Em vez disso, você precisará usar o auxiliar `* _url` associado. Por exemplo
ao invés de usar

```
<%= link_to 'welcome', welcome_path %>
```

Você precisará usar:

```
<%= link_to 'welcome', welcome_url %>
```

Ao usar o URL completo, seus links agora funcionarão em seus e-mails.

#### Gerando URLs com ʻurl_for`

`url_for` gera um URL completo por padrão em modelos.

Se você não configurou o `:host` opção globalmente, certifique-se de passá-la para
`url_for`.


```erb
<%= url_for(host: 'example.com',
            controller: 'welcome',
            action: 'greeting') %>
```

#### Gerando URLs com Rotas Nomeadas

Os clientes de e-mail não têm contexto da web e, portanto, os caminhos não têm URL base para completar o formulário endereços da web. Portanto, você deve sempre usar a variante "_url" da rota nomeada
ajudantes.

Se você não configurou a opção `:host` globalmente, certifique-se de passá-la para o
Ajudante de URL.

```erb
<%= user_url(@user, host: 'example.com') %>
```

NOTA: non-`GET` links require [rails-ujs](https://github.com/rails/rails/blob/master/actionview/app/assets/javascripts) or
[jQuery UJS](https://github.com/rails/jquery-ujs), e não funcionará em modelos de mailer.
Eles resultarão em solicitações `GET` normais.

### Adicionando imagens no Action Mailer Views

Ao contrário dos controladores, a instância do mailer não tem nenhum contexto sobre o
solicitação de entrada, então você precisará fornecer o parâmetro `: asset_host` você mesmo.

Como o `: asset_host` geralmente é consistente em todo o aplicativo, você pode
configurá-lo globalmente em `config/application.rb`:

```ruby
config.action_mailer.asset_host = 'http://example.com'
```

Agora você pode exibir uma imagem dentro do seu e-mail.

```ruby
<%= image_tag 'image.jpg' %>
```

### Enviando Emails Multipartes

O Action Mailer enviará automaticamente e-mails com várias partes se você tiver
modelos para a mesma ação. Então, para o nosso exemplo de ʻUserMailer`, se você tiver
`welcome_email.text.erb` e` welcome_email.html.erb` em
ʻApp / views / user_mailer`, Action Mailer irá enviar automaticamente um e-mail multipartes
com o HTML e as versões de texto configuradas como partes diferentes.

A ordem das partes sendo inseridas é determinada pelo `: parts_order`
dentro do método ʻActionMailer :: Base.default`.

### Envio de e-mails com opções de entrega dinâmica

Se você deseja substituir as opções de entrega padrão (por exemplo, credenciais SMTP)
ao entregar e-mails, você pode fazer isso usando `delivery_method_options` no
ação mailer.

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

### Envio de e-mails sem renderização de modelo

Pode haver casos em que você deseja pular a etapa de renderização do modelo e
forneça o corpo do email como uma string. Você pode fazer isso usando o método `: body`
opção. Nesses casos, não se esqueça de adicionar a opção `: content_type`. Trilhos
será o padrão para `text / plain` caso contrário.

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

Callbacks do Action Mailer
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
