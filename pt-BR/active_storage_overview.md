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

Usando *Active Storage*, uma aplicação pode transformar *uploads* de imagens com
[ImageMagick](https://www.imagemagick.org), gerar representações de imagens de
*uploads* que não são imagens como PDFs e vídeos, e extrai metadados de arquivos arbitrários.

## Configuração

O *Active Storage* usa duas tabelas no banco de dados da sua aplicação chamadas
`active_storage_blobs` e `active_storage_attachments`. Depois de criar uma nova
aplicação (ou atualizar sua aplicação para Rails 5.2), execute
`bin/rails active_storage:install` para gerar uma *migration* que cria essas
tabelas. Use `bin/rails db:migrate` para executar a *migration*.

WARNING: `active_storage_attachments` é uma tabela de junção (*join table*) polimórfica que armazena o nome da classe do seu *model*. Se o nome da classe do seu *model* mudar, você precisará executar uma *migration* nesta tabela para atualizar o `record_type` implícito para o novo nome da classe do seu *model*.

WARNING: Se você estiver usando UUIDs em vez de inteiros como a chave primária em seus *models*, você precisará alterar o tipo de coluna de `record_id` da tabela` active_storage_attachments` na migração.

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
    server_side_encryption: "" # 'aws:kms' or 'AES256'
```

TIP: Defina tempos limites de HTTP *timeout* e limites de nova tentativa para sua aplicação.
Em certos cenários de falha, a configuração do cliente AWS padrão pode fazer
com que as conexões sejam retidas por vários minutos e levar à enfileiramento de requisições.

Adicione a gem [`aws-sdk-s3`](https://github.com/aws/aws-sdk-ruby) no seu `Gemfile`:

```ruby
gem "aws-sdk-s3", require: false
```

NOTE: Os principais recursos do *Active Storage* requerem as seguintes permissões: `s3:ListBucket`, `s3:PutObject`, `s3:GetObject`, e `s3:DeleteObject`. Se você tiver opções de *upload* adicionais configuradas como configurações de ACLs, então permissões adicionais podem ser necessárias.

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
  # ...and other options
```

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
diretamente carregado para o serviço principal. Quando um arquivo enviado é
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

Tenha certeza que seus *buckets* estão configurados para acesso público. Veja a documentação sobre como ativar permissão de leitura pública para os serviços [Amazon S3](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/block-public-access-bucket.html), [Google Cloud Storage](https://cloud.google.com/storage/docs/access-control/making-data-public#buckets), e [Microsoft Azure](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-manage-access-to-resources#set-container-public-access-level-in-the-azure-portal).

Anexar Arquivos a Registros
--------------------------

### `has_one_attached`

O macro [`has_one_attached`][] configura um mapeamento um-para-um entre registros e
arquivos. Cada registro pode ter um arquivo anexado a ele.

Por exemplo, imagine que sua aplicação tenha um *model* `User`. Se você quiser que cada usuário
tenha uma avatar, defina o *model* `User` assim:

```ruby
class User < ApplicationRecord
  has_one_attached :avatar
end
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

[`has_one_attached`]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/Model.html#method-i-has_one_attached
[Attached::One#attach]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-attach
[Attached::One#attached?]: https://api.rubyonrails.org/classes/ActiveStorage/Attached/One.html#method-i-attached-3F


### `has_many_attached`

O macro [`has_many_attached`][] configura um relacionamento um-para-muitos entre os registros
e arquivos. Cada registro pode ter muitos arquivos anexados a ele.

Por exemplo, imagine que sua aplicação tem um *model* `Message`. Se você quiser que cada
mensagem tenha muitas imagens, defina o *model* `Message` assim:

```ruby
class Message < ApplicationRecord
  has_many_attached :images
end
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
@message.image.attach(io: File.open('/path/to/file'), filename: 'file.pdf')
```

Quando possível, forneça um tipo de conteúdo também. O *Active Storage* tenta
determinar o tipo de conteúdo de um arquivo a partir de seus dados. Depende do tipo
de conteúdo que você fornece se não for possível.

```ruby
@message.image.attach(io: File.open('/path/to/file'), filename: 'file.pdf', content_type: 'application/pdf')
```

Você pode ignorar a inferência do tipo de conteúdo a partir dos dados passando
`identify: false` junto com o `content_type`.

```ruby
@message.image.attach(
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

Conectando (_Linking_) arquivos
----------------

Cria uma _URL_ permanente da sua aplicação para o _blob_. Quando acessado,
o cliente é redirecionado para a rota (_endpoint_) correta. Está indireção
desacopla a URL do serviço da atual, e permite, por exemplo, espelhar anexos em
diferentes serviços de grande disponibilidade. O redirecionamento tem um tempo
de expiração de 5 minutos.

```ruby
url_for(user.avatar)
```

Para criar um _link_ para baixar o arquivo use o seguinte _helper_:
`rails_blob_{path|url}`. Usando esse _helper_ permite que você configure a
disposição (`disposition`) de como deseja apresentar:

```ruby
rails_blob_path(user.avatar, disposition: "attachment")
```

WARNING: Para evitar ataques XSS, *ActiveStorage* força o cabeçalho Content-Disposition para "anexos" 
para alguns tipos de arquivo. Para alterar este comportamento, consulte as
opções de configuração disponíveis em [Configurando aplicações Rails](configuring.html#configuring-active-storage).

Se você precisar criar um _link_ fora do escopo do _controller_ ou _view_ (Um
serviço que execute tarefas assíncronas, _Cronjob_ etc), você pode acessar o
_helper_ `rails_blob_path` desta maneira:

```ruby
Rails.application.routes.url_helpers.rails_blob_path(user.avatar, only_path: true)
```

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

Analisando arquivos
---------------

O *Active Storage* [analisa](https://api.rubyonrails.org/classes/ActiveStorage/Blob/Analyzable.html#method-i-analyze)
arquivos assim que eles são enviados através do enfileiramento de um *job* no *Active Job*. Arquivos analisados armazenarão
informações adicionais no *hash* de metadados, incluindo `analyzed: true`. Você pode verificar se um *blob* foi analisado
chamando [`analyzed?`][] nele.

A análise de imagens fornece os atributos `width` e `height`. A análise de vídeos fornece ambos citados anteriormente, assim
como `duration`, `angle` e `display_aspect_ratio`.

A análise necessita da gem `mini_magick`. A análise de vídeos também necessita da biblioteca [FFmpeg](https://www.ffmpeg.org/),
que você deve incluir separadamente.

[`analyzed?`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Analyzable.html#method-i-analyzed-3F

Transformando Imagens
-------------------

Para ativar variações, adicione a _gem_  `image_processing`  no seu `Gemfile`:

```ruby
gem 'image_processing'
```

Para criar uma variação de uma imagem, chame [`variant`][] no `Blob`. Você pode passar qualquer transformação para o método suportado pelo processador. O processador padrão para _Active Storage_ é o MiniMagick, mas você também pode usar o [Vips](https://www.rubydoc.info/gems/ruby-vips/Vips/Image).

Quando o navegador acessa a _URL_ da variação, o _Active Storage_ vai lentamente transformar o _blob+ original para o formato especificado e redirecionar para sua nova localização de serviço.

```erb
<%= image_tag user.avatar.variant(resize_to_limit: [100, 100]) %>
```

Para trocar para o processador Vips, você teria que adicionar o seguinte trecho no `config/application.rb`:

```ruby
# Use o Vips para processar variações.
config.active_storage.variant_processor = :vips
```

[`variant`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-variant

Pré-visualização de arquivos
----------------

Alguns arquivos que não são imagens podem ser pré-visualizados: isto é, eles podem
ser apresentados como imagens. Por exemplo, um arquivo de vídeo pode ser pré-visualizado
através da extração de seu primeiro *frame*. O *Active Storage* por padrão já oferece
suporte para a pré-visualização de vídeos e documentos PDF. Para criar um link e
gerar um preview use o método [`preview`][]:

```erb
<ul>
  <% @message.files.each do |file| %>
    <li>
      <%= image_tag file.preview(resize_to_limit: [100, 100]) %>
    </li>
  <% end %>
</ul>
```

WARNING: Extrair pré-visualizações necessita de aplicações de terceiros, *FFmpeg* para
vídeo e *muPDF* para PDFs, e no *macOS* também são necessários *XQuartz* e *Poppler*.
Estas bibliotecas não são fornecidas pelo Rails. Você deve instalá-las para poder
utilizar as pré-visualizações embutidas no *Active Storage*. Antes de instalar e utilizar
o *software* de terceiros, certifique-se de entender as implicações da licença para
essas ações.

[`preview`]: https://api.rubyonrails.org/classes/ActiveStorage/Blob/Representable.html#method-i-preview

Direct Uploads
--------------

Active Storage, with its included JavaScript library, supports uploading
directly from the client to the cloud.

### Usage

1. Include `activestorage.js` in your application's JavaScript bundle.

    Using the asset pipeline:

    ```js
    //= require activestorage

    ```

    Using the npm package:

    ```js
    import * as ActiveStorage from "@rails/activestorage"
    ActiveStorage.start()
    ```

2. Add `direct_upload: true` to your [`file_field`](form_helpers.html#uploading-files).

    ```erb
    <%= form.file_field :attachments, multiple: true, direct_upload: true %>
    ```

    If you aren't using a [FormBuilder](form_helpers.html#customizing-form-builders), add the data attribute directly:

    ```erb
    <input type=file data-direct-upload-url="<%= rails_direct_uploads_url %>" />
    ```

3. Configure CORS on third-party storage services to allow direct upload requests.

4. That's it! Uploads begin upon form submission.

### Cross-Origin Resource Sharing (CORS) configuration

To make direct uploads to a third-party service work, you’ll need to configure the service to allow cross-origin requests from your app. Consult the CORS documentation for your service:

* [S3](https://docs.aws.amazon.com/AmazonS3/latest/dev/cors.html#how-do-i-enable-cors)
* [Google Cloud Storage](https://cloud.google.com/storage/docs/configuring-cors)
* [Azure Storage](https://docs.microsoft.com/en-us/rest/api/storageservices/cross-origin-resource-sharing--cors--support-for-the-azure-storage-services)

Take care to allow:

* All origins from which your app is accessed
* The `PUT` request method
* The following headers:
  * `Origin`
  * `Content-Type`
  * `Content-MD5`
  * `Content-Disposition` (except for Azure Storage)
  * `x-ms-blob-content-disposition` (for Azure Storage only)
  * `x-ms-blob-type` (for Azure Storage only)

No CORS configuration is required for the Disk service since it shares your app’s origin.

#### Example: S3 CORS configuration

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

#### Example: Google Cloud Storage CORS configuration

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

#### Example: Azure Storage CORS configuration

```xml
<Cors>
  <CorsRule>
    <AllowedOrigins>https://www.example.com</AllowedOrigins>
    <AllowedMethods>PUT</AllowedMethods>
    <AllowedHeaders>Origin, Content-Type, Content-MD5, x-ms-blob-content-disposition, x-ms-blob-type</AllowedHeaders>
    <MaxAgeInSeconds>3600</MaxAgeInSeconds>
  </CorsRule>
<Cors>
```

### Direct upload JavaScript events

| Event name | Event target | Event data (`event.detail`) | Description |
| --- | --- | --- | --- |
| `direct-uploads:start` | `<form>` | None | A form containing files for direct upload fields was submitted. |
| `direct-upload:initialize` | `<input>` | `{id, file}` | Dispatched for every file after form submission. |
| `direct-upload:start` | `<input>` | `{id, file}` | A direct upload is starting. |
| `direct-upload:before-blob-request` | `<input>` | `{id, file, xhr}` | Before making a request to your application for direct upload metadata. |
| `direct-upload:before-storage-request` | `<input>` | `{id, file, xhr}` | Before making a request to store a file. |
| `direct-upload:progress` | `<input>` | `{id, file, progress}` | As requests to store files progress. |
| `direct-upload:error` | `<input>` | `{id, file, error}` | An error occurred. An `alert` will display unless this event is canceled. |
| `direct-upload:end` | `<input>` | `{id, file}` | A direct upload has ended. |
| `direct-uploads:end` | `<form>` | None | All direct uploads have ended. |

### Example

You can use these events to show the progress of an upload.

![direct-uploads](https://user-images.githubusercontent.com/5355/28694528-16e69d0c-72f8-11e7-91a7-c0b8cfc90391.gif)

To show the uploaded files in a form:

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

Add styles:

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

### Integrating with Libraries or Frameworks

If you want to use the Direct Upload feature from a JavaScript framework, or
you want to integrate custom drag and drop solutions, you can use the
`DirectUpload` class for this purpose. Upon receiving a file from your library
of choice, instantiate a DirectUpload and call its create method. Create takes
a callback to invoke when the upload completes.

```js
import { DirectUpload } from "@rails/activestorage"

const input = document.querySelector('input[type=file]')

// Bind to file drop - use the ondrop on a parent element or use a
//  library like Dropzone
const onDrop = (event) => {
  event.preventDefault()
  const files = event.dataTransfer.files;
  Array.from(files).forEach(file => uploadFile(file))
}

// Bind to normal file selection
input.addEventListener('change', (event) => {
  Array.from(input.files).forEach(file => uploadFile(file))
  // you might clear the selected files from the input
  input.value = null
})

const uploadFile = (file) => {
  // your form needs the file_field direct_upload: true, which
  //  provides data-direct-upload-url
  const url = input.dataset.directUploadUrl
  const upload = new DirectUpload(file, url)

  upload.create((error, blob) => {
    if (error) {
      // Handle the error
    } else {
      // Add an appropriately-named hidden input to the form with a
      //  value of blob.signed_id so that the blob ids will be
      //  transmitted in the normal upload flow
      const hiddenField = document.createElement('input')
      hiddenField.setAttribute("type", "hidden");
      hiddenField.setAttribute("value", blob.signed_id);
      hiddenField.name = input.name
      document.querySelector('form').appendChild(hiddenField)
    }
  })
}
```

If you need to track the progress of the file upload, you can pass a third
parameter to the `DirectUpload` constructor. During the upload, DirectUpload
will call the object's `directUploadWillStoreFileWithXHR` method. You can then
bind your own progress handler on the XHR.

```js
import { DirectUpload } from "@rails/activestorage"

class Uploader {
  constructor(file, url) {
    this.upload = new DirectUpload(this.file, this.url, this)
  }

  upload(file) {
    this.upload.create((error, blob) => {
      if (error) {
        // Handle the error
      } else {
        // Add an appropriately-named hidden input to the form
        // with a value of blob.signed_id
      }
    })
  }

  directUploadWillStoreFileWithXHR(request) {
    request.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Use event.loaded and event.total to update the progress bar
  }
}
```

Discarding Files Stored During System Tests
-------------------------------------------

System tests clean up test data by rolling back a transaction. Because destroy
is never called on an object, the attached files are never cleaned up. If you
want to clear the files, you can do it in an `after_teardown` callback. Doing it
here ensures that all connections created during the test are complete and
you won't receive an error from Active Storage saying it can't find a file.

```ruby
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [1400, 1400]

  def remove_uploaded_files
    FileUtils.rm_rf("#{Rails.root}/storage_test")
  end

  def after_teardown
    super
    remove_uploaded_files
  end
end
```

If your system tests verify the deletion of a model with attachments and you're
using Active Job, set your test environment to use the inline queue adapter so
the purge job is executed immediately rather at an unknown time in the future.

You may also want to use a separate service definition for the test environment
so your tests don't delete the files you create during development.

```ruby
# Use inline job processing to make things happen immediately
config.active_job.queue_adapter = :inline

# Separate file storage in the test environment
config.active_storage.service = :local_test
```

Discarding Files Stored During Integration Tests
-------------------------------------------

Similarly to System Tests, files uploaded during Integration Tests will not be
automatically cleaned up. If you want to clear the files, you can do it in an
`after_teardown` callback. Doing it here ensures that all connections created
during the test are complete and you won't receive an error from Active Storage
saying it can't find a file.

```ruby
module RemoveUploadedFiles
  def after_teardown
    super
    remove_uploaded_files
  end

  private

  def remove_uploaded_files
    FileUtils.rm_rf(Rails.root.join('tmp', 'storage'))
  end
end

module ActionDispatch
  class IntegrationTest
    prepend RemoveUploadedFiles
  end
end
```

Implementing Support for Other Cloud Services
---------------------------------------------

If you need to support a cloud service other than these, you will need to
implement the Service. Each service extends
[`ActiveStorage::Service`](https://github.com/rails/rails/blob/master/activestorage/lib/active_storage/service.rb)
by implementing the methods necessary to upload and download files to the cloud.
