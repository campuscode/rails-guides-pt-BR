**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Active Storage Overview
=======================

This guide covers how to attach files to your Active Record models.

After reading this guide, you will know:

* How to attach one or many files to a record.
* How to delete an attached file.
* How to link to an attached file.
* How to use variants to transform images.
* How to generate an image representation of a non-image file, such as a PDF or a video.
* How to send file uploads directly from browsers to a storage service,
  bypassing your application servers.
* How to clean up files stored during testing.
* How to implement support for additional storage services.

--------------------------------------------------------------------------------

O que é *Active Storage*?
-----------------------

O *Active Storage* facilita o *upload* de arquivos para um serviço de armazenamento como
*Amazon S3*, *Google Cloud Storage*, ou *Microsoft Azure Storage* e anexa esses
arquivos para objetos *Active Record*. Ele vem com um serviço local baseado em disco para
desenvolvimento e teste e oferece suporte a espelhamento de arquivos em serviços destinados para
*backups* e *migrations*.

Usando o *Active Storage*, uma aplicação pode transformar *uploads* de imagens ou gerar 
representações de *uploads* que não são imagens, como PDFs e vídeos, e extrair metadados de
arquivos arbitrários.

### Requirements

Vários recursos do *Active Storage* dependem de softwares de terceiros que o Rails
não não instala e deve ser instalado separadamente:

* [libvips](https://github.com/libvips/libvips) v8.6+ ou [ImageMagick](https://imagemagick.org/index.php) para análise de imagens e modificações
* [ffmpeg](http://ffmpeg.org/) v3.4+ para análise de vídeo/áudio e pre-visualização de vídeos
* [poppler](https://poppler.freedesktop.org/) ou [muPDF](https://mupdf.com/) para pre-visualização de PDF

Análise e transformações de imagem também requerem a *gem* `image_processing`. Descomente-a em seu `Gemfile` ou adicione-a se necessário:

```ruby
gem "image_processing", ">= 1.2"
```

TIP: Comparado a libvips, a ImageMagick é mais conhecida e mais amplamente disponível. No entanto, libvips pode ser [até 10x mais rápido e consumir 1/10 da memória](https://github.com/libvips/libvips/wiki/Speed-and-memory-use). Para arquivos JPEG, isso pode ser melhorado substituindo `libjpeg-dev` por `libjpeg-turbo-dev`, que é [2-7x mais rápido](https://libjpeg-turbo.org/About/Performance).

WARNING: Antes de instalar e usar software de terceiros, certifique-se de compreender as implicações de licenciamento de fazê-lo. O MuPDF, em particular, é licenciado sob AGPL e requer uma licença comercial para alguns usos.

## Configuração

O *Active Storage* usa três tabelas no banco de dados da sua aplicação chamadas
`active_storage_blobs`, `active_storage_variant_records` e `active_storage_attachments`. Depois de criar uma nova aplicação (ou atualizar sua aplicação para Rails 5.2), execute
`bin/rails active_storage:install` para gerar uma *migration* que cria essas
tabelas. Use `bin/rails db:migrate` para executar a *migration*.

WARNING: `active_storage_attachments` é uma tabela de junção (*join table*) polimórfica que armazena o nome da classe do seu *model*. Se o nome da classe do seu *model* mudar, você precisará executar uma *migration* nesta tabela para atualizar o `record_type` implícito para o novo nome da classe do seu *model*.

WARNING: Se você estiver usando UUIDs em vez de inteiros como a chave primária em seus *models*, você precisará alterar o tipo de coluna de `active_storage_attachments.record_id` e ` active_storage_variant_records.id` na migração.

Declare os serviços do *Active Storage* em `config/storage.yml`. Para cada serviço que sua
aplicação usa, forneça um nome e a configuração necessária. O exemplo
abaixo declara três serviços chamados `local`, `test` e `amazon`:

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  bucket: ""
  region: "" # e.g. 'us-east-1'
```

Tell Active Storage which service to use by setting
`Rails.application.config.active_storage.service`. Because each environment will
likely use a different service, it is recommended to do this on a
per-environment basis. To use the disk service from the previous example in the
development environment, you would add the following to
`config/environments/development.rb`:

```ruby
# Store files locally.
config.active_storage.service = :local
```

Para usar o serviço S3 em produção, você adiciona o seguinte ao
`config/environments/production.rb`:

```ruby
# Store files on Amazon S3.
config.active_storage.service = :amazon
```

Para usar o serviço *test* durante o teste, você adiciona o seguinte ao
`config/environments/test.rb`:

```ruby
# Store uploaded files on the local file system in a temporary directory.
config.active_storage.service = :test
```

Continue lendo para obter mais informações sobre os adaptadores de serviço integrados (por exemplo,
`Disk` e `S3`) e configurações que ele exigem.

NOTE: Os arquivos de configuração específicos do ambiente terão precedência:
em produção, por exemplo, o arquivo `config/storage/production.yml` (se existente)
terá precedência sobre o arquivo `config/storage.yml`.

É recomendado usar `Rails.env` nos nomes dos buckets para reduzir ainda mais o risco de destruição acidental de dados de produção.

```yaml
amazon:
  service: S3
  # ...
  bucket: your_own_bucket-<%= Rails.env %>

google:
  service: GCS
  # ...
  bucket: your_own_bucket-<%= Rails.env %>

azure:
  service: AzureStorage
  # ...
  container: your_container_name-<%= Rails.env %>
```

### Serviço Disk

Declare um serviço Disk em `config/storage.yml`:

```yaml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>
```

### Serviço S3 (Amazon S3 e APIs compatíveis com S3)

Para conectar ao Amazon S3, declare um serviço S3 em `config/storage.yml`:

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
```

Opcionalmente, você pode fornecer opções de cliente e upload:

```yaml
amazon:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""
  http_open_timeout: 0
  http_read_timeout: 0
  retry_limit: 0
  upload:
    server_side_encryption: "" # 'aws:kms' ou 'AES256'
```

TIP: Defina tempos limites de HTTP *timeout* e limites de nova tentativa para sua aplicação.
Em certos cenários de falha, a configuração do cliente AWS padrão pode fazer
com que as conexões sejam retidas por vários minutos e levar à enfileiramento de requisições.

Adicione a gem [`aws-sdk-s3`](https://github.com/aws/aws-sdk-ruby) no seu `Gemfile`:

```ruby
gem "aws-sdk-s3", require: false
```

NOTE: Os principais recursos do *Active Storage* requerem as seguintes permissões: `s3:ListBucket`, `s3:PutObject`, `s3:GetObject`, e `s3:DeleteObject`. [Acesso público](#acesso-publico) requer também `s3:PutObjectAcl`. Se você tiver opções de *upload* adicionais configuradas como configurações de ACLs, então permissões adicionais podem ser necessárias.

NOTE: Se você quiser usar variáveis de ambiente, arquivos de configuração padrão do SDK, perfis,
perfis de instância do IAM ou funções de tarefa, você pode omitir as chaves `access_key_id`, `secret_access_key`,
e `region` no exemplo acima. O serviço S3 suporta todas as opções de
autenticação descritas na [documentação AWS SDK](https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/setup-config.html).

Para se conectar a uma API de armazenamento de objetos compatíveis com S3, como DigitalOcean Spaces, forneça o `endpoint`:

```yaml
digitalocean:
  service: S3
  endpoint: https://nyc3.digitaloceanspaces.com
  access_key_id: ...
  secret_access_key: ...
  # ...e outras opções
```

Existem muitas outras opções disponíveis. Você pode verificá-los na documentação do [AWS S3 Client](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/S3/Client.html#initialize-instance_method).

### Serviço Armazenamento da Microsoft Azure

Declare um serviço Azure Storage em `config/storage.yml`:

```yaml
azure:
  service: AzureStorage
  storage_account_name: ""
  storage_access_key: ""
  container: ""
```

Adicione a gem [`azure-storage-blob`](https://github.com/Azure/azure-storage-ruby) no seu `Gemfile`:

```ruby
gem "azure-storage-blob", require: false
```

### Serviço Google Cloud Storage

Declare um serviço Google Cloud Storage service in `config/storage.yml`:

```yaml
google:
  service: GCS
  credentials: <%= Rails.root.join("path/to/keyfile.json") %>
  project: ""
  bucket: ""
```

Opcionalmente forneça uma _Hash_ de credenciais em vez de um caminho para o arquivo de chave:

```yaml
google:
  service: GCS
  credentials:
    type: "service_account"
    project_id: ""
    private_key_id: <%= Rails.application.credentials.dig(:gcs, :private_key_id) %>
    private_key: <%= Rails.application.credentials.dig(:gcs, :private_key).dump %>
    client_email: ""
    client_id: ""
    auth_uri: "https://accounts.google.com/o/oauth2/auth"
    token_uri: "https://accounts.google.com/o/oauth2/token"
    auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs"
    client_x509_cert_url: ""
  project: ""
  bucket: ""
```

Opcionalmente, forneça metadados Cache-Control para serem definidos nos recursos enviados:

```yaml
google:
  service: GCS
  ...
  cache_control: "public, max-age=3600"
```

Opcionalmente, use [IAM](https://cloud.google.com/storage/docs/access-control/signed-urls#signing-iam) em vez das `credentials` ao assinar URLs. Isso é útil se você estiver autenticando suas aplicações do GKE com o Workload Identity. Consulte [esta postagem do blog do Google Cloud](https://cloud.google.com/blog/products/containers-kubernetes/introducing-workload-identity-better-authentication -for-your-gke-applications) para obter mais informações.

```yaml
google:
  service: GCS
  ...
  iam: true
```

Opcionalmente, use um GSA específico ao assinar URLs. Ao usar o IAM, o [servidor de metadados](https://cloud.google.com/compute/docs/storing-retrieving-metadata) será contatado para obter o e-mail do GSA, mas esse servidor de metadados nem sempre está presente (por exemplo, em ambientes locais ou testes) e você pode querer usar um GSA não padrão.

```yaml
google:
  service: GCS
  ...
  iam: true
  gsa_email: "foobar@baz.iam.gserviceaccount.com"
```

Adicione a gem [`google-cloud-storage`](https://github.com/GoogleCloudPlatform/google-cloud-ruby/tree/master/google-cloud-storage) no seu `Gemfile`:

```ruby
gem "google-cloud-storage", "~> 1.11", require: false
```

### Serviço Espelho

Você pode manter múltiplos serviços sincronizados definindo um serviço espelho.
Quando um arquivo é carregado ou deletado, isso é feito em todos serviços espelhados.

Serviços espelhados podem ser usados para facilitar a migração entre serviços em produção.
Você pode começar a espelhar para o novo serviço, copiar os arquivos existentes do antigo
serviço para o novo, e então muda para o novo serviço.

NOTE: O espelhamento não é atômico. É possível que um upload seja bem-sucedido no
serviço principal e falha em qualquer um dos serviços subordinados. Antes de ir
totalmente para um novo serviço, verifique se todos os arquivos foram copiados.

Defina cada um dos serviços que você gostaria de usar conforme descrito acima e faça referência para um serviço
espelhado.

```yaml
s3_west_coast:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""

s3_east_coast:
  service: S3
  access_key_id: ""
  secret_access_key: ""
  region: ""
  bucket: ""

production:
  service: Mirror
  primary: s3_east_coast
  mirrors:
    - s3_west_coast
```

Embora todos os serviços secundários recebam uploads, os downloads são sempre
tratados pelo serviço principal.

Os serviços de espelho são compatíveis com uploads diretos. Novos arquivos são
diretamente carregados para o serviço principal. Quando um arquivo enviado é
anexado a um registro, um *job* em segundo plano é enfileirado para copiá-lo para os
serviços secundários.

### Acesso público

Por padrão, o *Active Storage* assume acesso privado aos serviços. Isso significa gerar URLs assinadas e de uso único para os blobs. Se você preferir tornar os blobs acessíveis publicamente, especifique `public: true` em `config/storage.yml` na sua aplicação:

```yaml
gcs: &gcs
  service: GCS
  project: ""

private_gcs:
  <<: *gcs
  credentials: <%= Rails.root.join("path/to/private_keyfile.json") %>
  bucket: ""

public_gcs:
  <<: *gcs
  credentials: <%= Rails.root.join("path/to/public_keyfile.json") %>
  bucket: ""
  public: true
```

Tenha certeza que seus *buckets* estão configurados para acesso público. Veja a documentação sobre como ativar permissão de leitura pública para os serviços [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/block-public-access-bucket.html), [Google Cloud Storage](https://cloud.google.com/storage/docs/access-control/making-data-public#buckets), e [Microsoft Azure](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-manage-access-to-resources#set-container-public-access-level-in-the-azure-portal). A Amazon S3 requer também que você tenha permissão `s3:PutObjectAcl.

Ao converter uma aplicação existente para usar `public: true`, certifique-se de atualizar cada arquivo individual no *bucket* para ser lido publicamente antes de alternar.

Anexar Arquivos a Registros
--------------------------

### `has_one_attached`

O macro [`has_one_attached`][] configura um mapeamento um-para-um entre registros e
arquivos. Cada registro pode ter um arquivo anexado a ele.

Por exemplo, imagine que sua aplicação tenha um *model* `User`. Se você quiser que cada usuário
tenha uma avatar, defina o *model* `User` da seguinte forma:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
end
```

ou se você estiver usando Rails 6.0+, você pode executar um comando gerador de *model* como este:

```ruby
bin/rails generate model User avatar:attachment
```

Você pode criar um usuário com um avatar:

```erb
<%= form.file_field :avatar %>
```

```ruby
class SignupController < ApplicationController
  def create
    user = User.create!(user_params)
    session[:user_id] = user.id
    redirect_to root_path
  end

  private
    def user_params
      params.require(:user).permit(:email_address, :password, :avatar)
    end
end
```

Chamar [`avatar.attach`][Attached::One#attach] para anexar um avatar a um usuário existente:

```ruby
user.avatar.attach(params[:avatar])
```

Chamar [`avatar.attached?`][Attached::One#attached?] para determinar se um usuário em particular tem um avatar:

```ruby
user.avatar.attached?
```

Em alguns casos, você pode querer substituir um serviço padrão para um anexo específico.
Você pode configurar serviços específicos por anexo usando a opção `service`:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar, service: :s3
end
```

Você pode configurar variantes específicas por objeto carregado chamando o método `variant` no objeto gerado:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize: "100x100"
  end
end
```

Chame `avatar.variant(:thumb)` para obter uma variante thumb de um avatar:

```erb
<%= image_tag user.avatar.variant(:thumb) %>
```

[`has_one_attached`]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Model.html#method-i-has_one_attached
[Attached::One#attach]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-attach
[Attached::One#attached?]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-attached-3F


### `has_many_attached`

O macro [`has_many_attached`][] configura um relacionamento um-para-muitos entre os registros
e arquivos. Cada registro pode ter muitos arquivos anexados a ele.

Por exemplo, imagine que sua aplicação tem um *model* `Message`. Se você quiser que cada
mensagem tenha muitas imagens, defina o *model* `Message` da seguinte forma:

```ruby
class Message < ApplicationRecord
  has_many_attached :images
end
```

ou se você estiver usando Rails 6.0+, você pode executar um comando gerador de *model* como este:

```ruby
bin/rails generate model Message images:attachments
```

Você pode criar uma mensagem com images:

```ruby
class MessagesController < ApplicationController
  def create
    message = Message.create!(message_params)
    redirect_to message
  end

  private
    def message_params
      params.require(:message).permit(:title, :content, images: [])
    end
end
```

Chamar [`images.attach`][Attached::Many#attach] para adicionar novas imagens para uma mensagem existente:

```ruby
@message.images.attach(params[:images])
```

Chamar [`images.attached?`][Attached::Many#attached?] para determinar se uma mensagem em particular alguma imagem:

```ruby
@message.images.attached?
```

Substituir o serviço padrão é feito da mesma maneira que `has_one_attached`, usando a opção `service`:

```ruby
class Message < ApplicationRecord
  has_many_attached :images, service: :s3
end
```

A configuração de variantes específicas é feita da mesma forma que `has_one_attached`, chamando o método `variant` no objeto gerado:

```ruby
class Message < ApplicationRecord
  has_many_attached :images do |attachable|
    attachable.variant :thumb, resize: "100x100"
  end
end
```

[`has_many_attached`]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Model.html#method-i-has_many_attached
[Attached::Many#attach]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Many.html#method-i-attach
[Attached::Many#attached?]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Many.html#method-i-attached-3F

### Anexando Objetos *File/IO*

Às vezes você precisa anexar um arquivo que não chega por meio de uma requisição HTTP.
Por exemplo, você pode querer anexar um arquivo que você gerou no disco ou baixou
de uma URL enviada pelo usuário. Você também pode querer anexar um arquivo de fixação em um
*model* de test. Para fazer isso, forneça uma *Hash* contendo pelo menos um objeto *open IO*
e um *filename*:

```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf')
```

Quando possível, forneça um tipo de conteúdo também. O *Active Storage* tenta
determinar o tipo de conteúdo de um arquivo a partir de seus dados. Depende do tipo
de conteúdo que você fornece se não for possível.

```ruby
@message.images.attach(io: File.open('/path/to/file'), filename: 'file.pdf', content_type: 'application/pdf')
```

Você pode ignorar a inferência do tipo de conteúdo a partir dos dados passando
`identify: false` junto com o `content_type`.

```ruby
@message.images.attach(
  io: File.open('/path/to/file'),
  filename: 'file.pdf',
  content_type: 'application/pdf',
  identify: false
)
```

Se você não fornecer um tipo de conteúdo e o *Active Storage* não puder determinar o
tipo de conteúdo do arquivo automaticamente, o padrão é *application/octet-stream*.


Removendo arquivos
--------------

Para remover um arquivo anexado de um _model_, use o método [`purge`][Attached::One#purge] no anexo.
Se a aplicação está configurada para usar *Active Job*, a remoção pode ser feita de maneira assíncrona
chamando [`purge_later`][Attached::One#purge_later]. `Purge` remove o _blob_ (O arquivo em sua versão binaria salvo no banco de
dados) e o arquivo do seu serviço de armazenamento.

```ruby
# Maneira usada para remover um avatar e seus arquivos de maneira síncrona.
user.avatar.purge

# Maneira usada para remover um avatar e seus arquivos de maneira assíncrona.
user.avatar.purge_later
```

[Attached::One#purge]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-purge
[Attached::One#purge_later]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-purge_later

Serving Files
-------------

Active Storage supports two ways to serve files: redirecting and proxying.

WARNING: All Active Storage controllers are publicly accessible by default. The
generated URLs are hard to guess, but permanent by design. If your files
require a higher level of protection consider implementing
[Authenticated Controllers](#authenticated-controllers).

### Redirect mode

To generate a permanent URL for a blob, you can pass the blob to the
[`url_for`][ActionView::RoutingUrlFor#url_for] view helper. This generates a
URL with the blob's [`signed_id`][ActiveStorage::Blob#signed_id]
that is routed to the blob's [`RedirectController`][`ActiveStorage::Blobs::RedirectController`]

```ruby
url_for(user.avatar)
# => /rails/active_storage/blobs/:signed_id/my-avatar.png
```

The `RedirectController` redirects to the actual service endpoint. This
indirection decouples the service URL from the actual one, and allows, for
example, mirroring attachments in different services for high-availability. The
redirection has an HTTP expiration of 5 minutes.

To create a download link, use the `rails_blob_{path|url}` helper. Using this
helper allows you to set the disposition.

```ruby
rails_blob_path(user.avatar, disposition: "attachment")
```

WARNING: To prevent XSS attacks, Active Storage forces the Content-Disposition header
to "attachment" for some kind of files. To change this behaviour see the
available configuration options in [Configuring Rails Applications](configuring.html#configuring-active-storage).

If you need to create a link from outside of controller/view context (Background
jobs, Cronjobs, etc.), you can access the `rails_blob_path` like this:

```ruby
Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)
```

[ActionView::RoutingUrlFor#url_for]: https://api.rubyonrails.org/classes/ActionView/RoutingUrlFor.html#method-i-url_for
[ActiveStorage::Blob#signed_id]: https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-signed_id

### Proxy mode

Optionally, files can be proxied instead. This means that your application servers will download file data from the storage service in response to requests. This can be useful for serving files from a CDN.

You can configure Active Storage to use proxying by default:

```ruby
# config/initializers/active_storage.rb
Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy
```

Or if you want to explicitly proxy specific attachments there are URL helpers you can use in the form of `rails_storage_proxy_path` and `rails_storage_proxy_url`.

```erb
<%= image_tag rails_storage_proxy_path(@user.avatar) %>
```

#### Putting a CDN in front of Active Storage

Additionally, in order to use a CDN for Active Storage attachments, you will need to generate URLs with proxy mode so that they are served by your app and the CDN will cache the attachment without any extra configuration. This works out of the box because the default Active Storage proxy controller sets an HTTP header indicating to the CDN to cache the response.

You should also make sure that the generated URLs use the CDN host instead of your app host. There are multiple ways to achieve this, but in general it involves tweaking your `config/routes.rb` file so that you can generate the proper URLs for the attachments and their variations. As an example, you could add this:

```ruby
# config/routes.rb
direct :cdn_image do |model, options|
  if model.respond_to?(:signed_id)
    route_for(
      :rails_service_blob_proxy,
      model.signed_id,
      model.filename,
      options.merge(host: ENV['CDN_HOST'])
    )
  else
    signed_blob_id = model.blob.signed_id
    variation_key  = model.variation.key
    filename       = model.blob.filename

    route_for(
      :rails_blob_representation_proxy,
      signed_blob_id,
      variation_key,
      filename,
      options.merge(host: ENV['CDN_HOST'])
    )
  end
end
```

and then generate routes like this:

```erb
<%= cdn_image_url(user.avatar.variant(resize_to_limit: [128, 128])) %>
```

### Authenticated Controllers

All Active Storage controllers are publicly accessible by default. The generated
URLs use a plain [`signed_id`][ActiveStorage::Blob#signed_id], making them hard to
guess but permanent. Anyone that knows the blob URL will be able to access it,
even if a `before_action` in your `ApplicationController` would otherwise
require a login. If your files require a higher level of protection, you can
implement your own authenticated controllers, based on the
[`ActiveStorage::Blobs::RedirectController`][],
[`ActiveStorage::Blobs::ProxyController`][],
[`ActiveStorage::Representations::RedirectController`][] and
[`ActiveStorage::Representations::ProxyController`][]

To only allow an account to access their own logo you could do the following:

```ruby
# config/routes.rb
resource :account do
  resource :logo
end
```

```ruby
# app/controllers/logos_controller.rb
class LogosController < ApplicationController
  # Through ApplicationController:
  # include Authenticate, SetCurrentAccount

  def show
    redirect_to Current.account.logo.url
  end
end
```

```erb
<%= image_tag account_logo_path %>
```

And then you might want to disable the Active Storage default routes with:

```ruby
config.active_storage.draw_routes = false
```

to prevent files being accessed with the publicly accessible URLs.

[`ActiveStorage::Blobs::RedirectController`]: https://api.rubyonrails.org/classes/ActiveStorage/Blobs/RedirectController.html
[`ActiveStorage::Blobs::ProxyController`]: https://api.rubyonrails.org/classes/ActiveStorage/Blobs/ProxyController.html
[`ActiveStorage::Representations::RedirectController`]: https://api.rubyonrails.org/classes/ActiveStorage/Representations/RedirectController.html
[`ActiveStorage::Representations::ProxyController`]: https://api.rubyonrails.org/classes/ActiveStorage/Representations/ProxyController.html

Baixando arquivos
-----------------

Algumas vezes você vai precisar processar um _blob_ depois dele ter sido
_uploaded_ (Transferir um arquivo da maquina do cliente para o servidor da sua
aplicação) para, por exemplo, converte-lo para um formato diferente. Use o
[`download`][Blob#download] para ler o conteúdo binário do _blob_ na
memória:

```ruby
binary = user.avatar.download
```

Caso deseje baixar o _blob_ para um arquivo no disco para um programa externo
(Um antivírus, por exemplo) possa operar nele. Use o método [`open`][Blob#open]
para baixar o _blob_ para um arquivo temporário no disco:

```ruby
message.video.open do |file|
  system '/caminho/para/o/antivirus', file.path
  # ...
end
```

É importante saber que o arquivo ainda não está disponível no *callback* `after_create`, mas apenas no `after_create_commit`.

[Blob#download]: https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-download
[Blob#open]: https://api.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-open

Analyzing Files
---------------

Active Storage analyzes files once they've been uploaded by queuing a job in Active Job. Analyzed files will store additional information in the metadata hash, including `analyzed: true`. You can check whether a blob has been analyzed by calling [`analyzed?`][] on it.

Image analysis provides `width` and `height` attributes. Video analysis provides these, as well as `duration`, `angle`, `display_aspect_ratio`, and `video` and `audio` booleans to indicate the presence of those channels. Audio analysis provides `duration` and `bit_rate` attributes.

[`analyzed?`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Analyzable.html#method-i-analyzed-3F

Displaying Images, Videos, and PDFs
---------------

Active Storage supports representing a variety of files. You can call
[`representation`][] on an attachment to display an image variant, or a
preview of a video or PDF. Before calling `representation`, check if the
attachment can be represented by calling [`representable?`]. Some file formats
can't be previewed by Active Storage out of the box (e.g. Word documents); if
`representable?` returns false you may want to [link to](#serving-files)
the file instead.

```erb
<ul>
  <% @message.files.each do |file| %>
    <li>
      <% if file.representable? %>
        <%= image_tag file.representation(resize_to_limit: [100, 100]) %>
      <% else %>
        <%= link_to rails_blob_path(file, disposition: "attachment") do %>
          <%= image_tag "placeholder.png", alt: "Download file" %>
        <% end %>
      <% end %>
    </li>
  <% end %>
</ul>
```

Internally, `representation` calls `variant` for images, and `preview` for
previewable files. You can also call these methods directly.

[`representable?`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-representable-3F
[`representation`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-representation

### Lazy vs Immediate Loading

By default, Active Storage will process representations lazily. This code:

```ruby
image_tag file.representation(resize_to_limit: [100, 100])
```

Will generate an `<img>` tag with the `src` pointing to the
[`ActiveStorage::Representations::RedirectController`][]. The browser will
make a request to that controller, which will return a `302` redirect to the
file on the remote service (or in [proxy mode](#proxy-mode), return the file
contents). Loading the file lazily allows features like
[single use URLs](#public-access) to work without slowing down your initial page loads.

This works fine for most cases.

If you want to generate URLs for images immediately, you can call `.processed.url`:

```ruby
image_tag file.representation(resize_to_limit: [100, 100]).processed.url
```

The Active Storage variant tracker improves performance of this, by storing a
record in the database if the requested representation has been processed before.
Thus, the above code will only make an API call to the remote service (e.g. S3)
once, and once a variant is stored, will use that. The variant tracker runs
automatically, but can be disabled through `config.active_storage.track_variants`.

If you're rendering lots of images on a page, the above example could result
in N+1 queries loading all the variant records. To avoid these N+1 queries,
use the named scopes on [`ActiveStorage::Attachment`][].

```ruby
message.images.with_all_variant_records.each do |file|
  image_tag file.representation(resize_to_limit: [100, 100]).processed.url
end
```

[`ActiveStorage::Representations::RedirectController`]: https://api.rubyonrails.org/classes/ActiveStorage/Representations/RedirectController.html
[`ActiveStorage::Attachment`]: https://api.rubyonrails.org/classes/ActiveStorage/Attachment.html

### Transforming Images

Transforming images allows you to display the image at your choice of dimensions. 
To create a variation of an image, call [`variant`][] on the attachment. You
can pass any transformation supported by the variant processor to the method.
When the browser hits the variant URL, Active Storage will lazily transform
the original blob into the specified format and redirect to its new service
location.

```erb
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100]) %>
```

If a variant is requested, Active Storage will automatically apply
transformations depending on the image's format:

1. Content types that are variable (as dictated by `config.active_storage.variable_content_types`)
  and not considered web images (as dictated by `config.active_storage.web_image_content_types`),
  will be converted to PNG.

2. If `quality` is not specified, the variant processor's default quality for the format will be used.

The default processor for Active Storage is MiniMagick, but you can also use
[Vips][]. To switch to Vips, add the following to `config/application.rb`:

```ruby
config.active_storage.variant_processor = :vips
```

The two processors are not fully compatible, so when migrating an existing application 
using MiniMagick to Vips, some changes have to be made if using options that are format
specific:

```rhtml
<!-- MiniMagick -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, sampling_factor: "4:2:0", strip: true, interlace: "JPEG", colorspace: "sRGB", quality: 80) %>

<!-- Vips -->
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100], format: :jpeg, saver: { subsample_mode: "on", strip: true, interlace: true, quality: 80 }) %>
```

[`variant`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-variant
[Vips]: https://www.rubydoc.info/gems/ruby-vips/Vips/Image

### Pré-visualização de arquivos

Alguns arquivos que não são imagens podem ser pré-visualizados: isto é, eles podem
ser apresentados como imagens. Por exemplo, um arquivo de vídeo pode ser pré-visualizado
através da extração de seu primeiro *frame*. O *Active Storage* por padrão já oferece
suporte para a pré-visualização de vídeos e documentos PDF. Para criar um link e
gerar um preview use o método [`preview`][]:

```erb
<%= image_tag message.video.preview(resize_to_limit: [100, 100]) %>
```

Para adicionar suporte para outros formatos, adicione seu próprio visualizador. Veja a documentação de
[`ActiveStorage::Preview`][] para mais informações.

[`preview`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-preview
[`ActiveStorage::Preview`]: https://api.rubyonrails.org/classes/ActiveStorage/Preview.html

*Uploads* Diretos
--------------

O *Active Storage* com a sua biblioteca JavaScript incluída suporta *uploads* direto do cliente (*front-end*) para a nuvem.

### Uso

1. Inclua o `activestorage.js` na sua aplicação.

    Usando o *asset pipeline*:

    ```js
    //= require activestorage
    ```

    Usando o pacote npm:

    ```js
    import * as ActiveStorage from "@rails/activestorage"
    ActiveStorage.start()
    ```

2. Adicione `direct_upload: true` no seu [`file_field`](form_helpers.html#enviando-arquivos).

    ```erb
    <%= form.file_field :attachments, multiple: true, direct_upload: true %>
    ```

    Se você não está usando um [FormBuilder](form_helpers.html#customizando-os-construtores-de-formularios) adicione o `direct_upload: true` diretamente:

    ```erb
    <input type=file data-direct-upload-url="<%= rails_direct_uploads_url %>" />
    ```

3. Configure o serviço de armazenamento de terceiros do CORS para permitir requisições de *upload* direto.

4. E é isso! Os *uploads* começam após o envio do formulário.

### Configuração do *Cross-Origin Resource Sharing* (CORS)

Para que o *upload* direto a partir de terceiros funcione você vai precisar configurar o seu serviço de nuvem para aceitar requisições de múltiplas origens. Consulte a documentação sobre CORS do seu serviço:

* [S3](https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html#how-do-i-enable-cors)
* [Google Cloud Storage](https://cloud.google.com/storage/docs/configuring-cors)
* [Azure Storage](https://docs.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services)

Tome cuidado em permitir:

* Todas as origens pela qual a sua aplicação é acessada.
* O método de requisição `PUT`
* Os seguintes cabeçalhos de requisição:
  * `Origin`
  * `Content-Type`
  * `Content-MD5`
  * `Content-Disposition` (exceto para o Azure Storage)
  * `x-ms-blob-content-disposition` (somente para o Azure Storage)
  * `x-ms-blob-type` (somente para o Azure Storage)
  * `Cache-Control` (para GCS, somente se `cache_control` estiver definido)

Se você for utilizar seu disco como armazenamento e ele compartilhar a mesma origem da sua aplicação não é necessário configurar o CORS.

#### Exemplo: Configuração do CORS para o S3

```json
[
  {
    "AllowedHeaders": [
      "*"
    ],
    "AllowedMethods": [
      "PUT"
    ],
    "AllowedOrigins": [
      "https://www.example.com"
    ],
    "ExposeHeaders": [
      "Origin",
      "Content-Type",
      "Content-MD5",
      "Content-Disposition"
    ],
    "MaxAgeSeconds": 3600
  }
]
```

#### Exemplo: Configuração do CORS para o Google Cloud Storage

```json
[
  {
    "origin": ["https://www.example.com"],
    "method": ["PUT"],
    "responseHeader": ["Origin", "Content-Type", "Content-MD5", "Content-Disposition"],
    "maxAgeSeconds": 3600
  }
]
```

#### Exemplo: Configuração do CORS para o Azure Storage

```xml
<Cors>
  <CorsRule>
    <AllowedOrigins>https://www.example.com</AllowedOrigins>
    <AllowedMethods>PUT</AllowedMethods>
    <AllowedHeaders>Origin, Content-Type, Content-MD5, x-ms-blob-content-disposition, x-ms-blob-type</AllowedHeaders>
    <MaxAgeInSeconds>3600</MaxAgeInSeconds>
  </CorsRule>
</Cors>
```

### Eventos de *upload* do JavaScript

| Nome do evento | Alvo do evento | Dados do evento (`event.detail`) | Descrição |
| --- | --- | --- | --- |
| `direct-uploads:start` | `<form>` | Nenhum | Um formulário contendo campos para *upload* direto foi submetido. |
| `direct-upload:initialize` | `<input>` | `{id, file}` | Disparado para cada arquivo após a submissão do formulário. |
| `direct-upload:start` | `<input>` | `{id, file}` | O *upload* direto está iniciando. |
| `direct-upload:before-blob-request` | `<input>` | `{id, file, xhr}` | Antes de fazer uma requisição de *upload* direto de metadados para a sua aplicação. |
| `direct-upload:before-storage-request` | `<input>` | `{id, file, xhr}` | Antes de fazer uma requisição para armazenar um arquivo. |
| `direct-upload:progress` | `<input>` | `{id, file, progress}` | O progresso da requisição para armazenar um arquivo. |
| `direct-upload:error` | `<input>` | `{id, file, error}` | Um erro ocorreu. Um `alert` deve ser exibido, a menos que esse evento seja cancelado. |
| `direct-upload:end` | `<input>` | `{id, file}` | Um *upload* direto foi finalizado. |
| `direct-uploads:end` | `<form>` | Nenhum | Todos os *uploads* diretos foram finalizados. |

### Exemplo

Você pode usar esses eventos para exibir o progresso de um *upload*.

![direct-uploads](https://user-images.githubusercontent.com/5355/28694528-16e69d0c-72f8-11e7-91a7-c0b8cfc90391.gif)

Para mostrar os arquivos enviados em um formulário:

```js
// direct_uploads.js

addEventListener("direct-upload:initialize", event => {
  const { target, detail } = event
  const { id, file } = detail
  target.insertAdjacentHTML("beforebegin", `
    <div id="direct-upload-${id}" class="direct-upload direct-upload--pending">
      <div id="direct-upload-progress-${id}" class="direct-upload__progress" style="width: 0%"></div>
      <span class="direct-upload__filename"></span>
    </div>
  `)
  target.previousElementSibling.querySelector(`.direct-upload__filename`).textContent = file.name
})

addEventListener("direct-upload:start", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.remove("direct-upload--pending")
})

addEventListener("direct-upload:progress", event => {
  const { id, progress } = event.detail
  const progressElement = document.getElementById(`direct-upload-progress-${id}`)
  progressElement.style.width = `${progress}%`
})

addEventListener("direct-upload:error", event => {
  event.preventDefault()
  const { id, error } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add("direct-upload--error")
  element.setAttribute("title", error)
})

addEventListener("direct-upload:end", event => {
  const { id } = event.detail
  const element = document.getElementById(`direct-upload-${id}`)
  element.classList.add("direct-upload--complete")
})
```

Adicionar estilos:

```css
/* direct_uploads.css */

.direct-upload {
  display: inline-block;
  position: relative;
  padding: 2px 4px;
  margin: 0 3px 3px 0;
  border: 1px solid rgba(0, 0, 0, 0.3);
  border-radius: 3px;
  font-size: 11px;
  line-height: 13px;
}

.direct-upload--pending {
  opacity: 0.6;
}

.direct-upload__progress {
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  opacity: 0.2;
  background: #0076ff;
  transition: width 120ms ease-out, opacity 60ms 60ms ease-in;
  transform: translate3d(0, 0, 0);
}

.direct-upload--complete .direct-upload__progress {
  opacity: 0.4;
}

.direct-upload--error {
  border-color: red;
}

input[type=file][data-direct-upload-url][disabled] {
  display: none;
}
```

### Integrando com Bibliotecas ou *Frameworks*

Se você quer utilizar a funcionalidade de *upload* direto a partir de um *framework* JavaScript, ou se você quiser integrar uma funcionalidade de *drag and drop* (arrastar e soltar), você poderá utilizar a classe `DirectUpload` para fazer a integração. Ao receber um arquivo da sua biblioteca de escolha, instancie um `DirectUpload` e chame o seu método de criação. O método de criação recebe uma *callback* para ser executada quando o *upload* é concluído.

```js
import { DirectUpload } from "@rails/activestorage"

const input = document.querySelector('input[type=file]')

// Vincular ao arquivo solto - use o onDrop em um elemento pai ou use uma
//  biblioteca com o Dropzone
const onDrop = (event) => {
  event.preventDefault()
  const files = event.dataTransfer.files;
  Array.from(files).forEach(file => uploadFile(file))
}

// Vincular à seleção de arquivo normal
input.addEventListener('change', (event) => {
  Array.from(input.files).forEach(file => uploadFile(file))
  // você pode limpar os arquivos selecionados da entrada
  input.value = null
})

const uploadFile = (file) => {
  // seu formulário precisa do file_field direct_upload: true, que
  //  fornece o data-direct-upload-url, data-direct-upload-token
  // e data-direct-upload-attachment-name
  const url = input.dataset.directUploadUrl
  const token = input.dataset.directUploadToken
  const attachmentName = input.dataset.directUploadAttachmentName
  const upload = new DirectUpload(file, url, token, attachmentName)

  upload.create((error, blob) => {
    if (error) {
      // Trata o erro
    } else {
      // Adiciona uma entrada oculta apropriadamente nomeada ao formulário com o
      //  valor blob.signed_id, assim os blob ids podem ser
      //  transmitidos no fluxo normal de upload
      const hiddenField = document.createElement('input')
      hiddenField.setAttribute("type", "hidden");
      hiddenField.setAttribute("value", blob.signed_id);
      hiddenField.name = input.name
      document.querySelector('form').appendChild(hiddenField)
    }
  })
}
```

Se você precisa acompanhar o progresso de *upload* do arquivo, você pode passar um quinto
parâmetro para o construtor do `DirectUpload`. Durante o *upload*, o DirectUpload
irá chamar o método `directUploadWillStoreFileWithXHR` do objeto. Você poderá então
vincular o seu manipulador de progresso no XHR.

```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url, token, attachmentName) {
    this.upload = new DirectUpload(file, url, token, attachmentName, this)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // Trata o erro
      } else {
        // Adiciona uma entrada oculta apropriadamente nomeada no formulário
        // com o valor blob.signed_id
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Usa o event.loaded e o event.total para atualizar a barra de progresso
  }
}
```

NOTA: O uso de [Uploads Diretos](#direct-uploads) às vezes pode resultar em um arquivo que é carregado, mas nunca anexado a um registro. Considere [limpar uploads não anexados](#purging-unattached-uploads).

Testando
-------------------------------------------

Use [`fixture_file_upload`][] para testar o *upload* de um arquivo em um teste de integração ou *controller*.
O Rails lida com arquivos como qualquer outro parâmetro.

```ruby
class SignupController < ActionDispatch::IntegrationTest
  test "can sign up" do
    post signup_path, params: {
      name: "David",
      avatar: fixture_file_upload("david.png", "image/png")
    }

    user = User.order(:created_at).last
    assert user.avatar.attached?
  end
end
```

[`fixture_file_upload`]: https://api.rubyonrails.org/classes/ActionDispatch/TestProcess/FixtureFile.html

### Descartando arquivos criados durante os testes

Os testes de sistema limpam os dados de testes revertendo uma transação. Como o
`destroy` nunca é chamado em um objeto, os arquivos anexados nunca são limpos. Se
quiser limpar os arquivos, podemos usar um *callback* `after_teardown`.
Fazendo isso garantimos que todas as conexões criadas durante o teste sejam
concluídas sem que recebamos um erro do *Active Storage* informando que não
foi possível encontrar um arquivo.

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # ...
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
  # ...
end
```

Se você estiver usando [testes paralelos][] e o `DiskService`, você deve configurar cada processo para usar sua própria
pasta para o *Active Storage*. Dessa forma, o retorno de chamada `teardown` só excluirá arquivos do processo do teste relevante.

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # ...
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
  # ...
end
```

Se os testes de sistema verificarem a exclusão de um *model* com anexos e
estivermos usando o *Active Job*, configure seu ambiente de testes para usar
o adaptador de fila para que o trabalho de limpeza seja executado imediatamente,
em vez de em um momento desconhecido no futuro.

```ruby
# Usa o processamento de trabalho em linha para fazer as coisas
# acontecerem imediatamente
config.active_job.queue_adapter = :inline
```

[parallel tests]: https://guides.rubyonrails.org/testing.html#parallel-testing

#### Testes de Integração

Similar aos testes de sistema, arquivos enviados durante testes de integração
não serão automaticamente descartados. Se você deseja limpar esses arquivos, você
pode fazer isso usando o *callback* `teardown`.

```ruby
class ActionDispatch::IntegrationTest
  def after_teardown
    super
    FileUtils.rm_rf(ActiveStorage::Blob.service.root)
  end
end
```

Se você estiver usando [testes paralelos][] e o serviço em disco, deverá configurar cada processo para usar sua própria
pasta para o *Active Storage*. Dessa forma, o retorno de chamada `teardown` só excluirá arquivos do processo do teste relevante.

```ruby
class ActionDispatch::IntegrationTest
  parallelize_setup do |i|
    ActiveStorage::Blob.service.root = "#{ActiveStorage::Blob.service.root}-#{i}"
  end
end
```

[parallel tests]: https://guides.rubyonrails.org/testing.html#parallel-testing

### Adicionando arquivos em fixtures

Você pode adicionar anexos às suas [fixtures][]. Primeiro, você desejará criar um serviço de armazenamento separado:

```yml
# config/storage.yml

test_fixtures:
  service: Disk
  root: <%= Rails.root.join("tmp/storage_fixtures") %>
```

Isso informa ao *Active Storage* para onde "carregar" os arquivos de fixture, então deve ser um diretório temporário. Ao fazê-lo
um diretório diferente do seu serviço `test` regular, você pode separar os arquivos de fixtures dos arquivos carregados durante um teste.

Em seguida, crie arquivos de fixture para as classes *Active Storage*:

```yml
# active_storage/attachments.yml
david_avatar:
  name: avatar
  record: david (User)
  blob: david_avatar_blob
```

```yml
# active_storage/blobs.yml
david_avatar_blob: <%= ActiveStorage::FixtureSet.blob filename: "david.png", service_name: "test_fixtures" %>
```

Em seguida, coloque um arquivo em seu diretório de fixtures (o caminho padrão é `test/fixtures/files`) com o nome de arquivo correspondente.
Veja a documentação [`ActiveStorage::FixtureSet`][] para mais informações.

Depois que tudo estiver configurado, você poderá acessar os anexos em seus testes:

```ruby
class UserTest < ActiveSupport::TestCase
  def test_avatar
    avatar = users(:david).avatar

    assert avatar.attached?
    assert_not_nil avatar.download
    assert_equal 1000, avatar.byte_size
  end
end
```

#### Limpando as fixtures

Enquanto os arquivos enviados nos testes são limpos [no final de cada teste](#discarding-files-created-durante-tests),
você só precisa limpar os arquivos de fixtures uma vez: quando todos os seus testes forem concluídos.

Se você estiver usando testes paralelos, chame `parallelize_teardown`:

```ruby
class ActiveSupport::TestCase
  # ...
  parallelize_teardown do |i|
    FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
  end
  # ...
end
```

Se você não estiver executando testes paralelos, use `Minitest.after_run` ou equivalente para seu teste
framework (por exemplo, `after(:suite)` para RSpec):

```ruby
# test_helper.rb

Minitest.after_run do
  FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
end
```

[fixtures]: https://guides.rubyonrails.org/testing.html#the-low-down-on-fixtures
[`ActiveStorage::FixtureSet`]: https://api.rubyonrails.org/classes/ActiveStorage/FixtureSet.html

Implementando Suporte a Outros Serviços *Cloud*
---------------------------------------------


Se for necessário dar suporte a algum outro serviço *cloud* além desses, você precisa implementá-lo. Cada serviço estende [`ActiveStorage::Service`](https://api.rubyonrails.org/classes/ActiveStorage/Service.html) implementando os métodos necessários para fazer o *upload* e *download* de arquivos para a nuvem.

Purging Unattached Uploads
--------------------------

There are cases where a file is uploaded but never attached to a record. This can happen when using [Direct Uploads](#direct-uploads). You can query for unattached records using the [unattached scope](https://github.com/rails/rails/blob/8ef5bd9ced351162b673904a0b77c7034ca2bc20/activestorage/app/models/active_storage/blob.rb#L49). Below is an example using a [custom rake task](command_line.html#custom-rake-tasks).

```ruby
namespace :active_storage do
  desc "Purges unattached Active Storage blobs. Run regularly."
  task purge_unattached: :environment do
    ActiveStorage::Blob.unattached.where("active_storage_blobs.created_at <= ?", 2.days.ago).find_each(&:purge_later)
  end
end
```

WARNING: The query generated by `ActiveStorage::Blob.unattached` can be slow and potentially disruptive on applications with larger databases.