**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Atualizando o Ruby on Rails
=======================

Este guia fornece os passos a serem seguidos quando você for atualizar suas aplicações
para uma versão mais nova do Ruby on Rails. Estes passos também estão disponíveis em guias de *releases* individuais.

--------------------------------------------------------------------------------

Conselho Geral
--------------

Antes de tentar atualizar uma aplicação existente, você deve ter certeza que possui uma boa razão para fazê-lo. Então tenha em mente alguns fatores: a necessidade de novas funcionalidades, a crescente dificuldade de encontrar suporte para código mais antigo, seu tempo disponível e habilidades, entre outros.

### Cobertura de Testes

A melhor maneira de garantir que sua aplicação ainda funciona após a atualização é possuir uma boa cobertura de testes antes de começar o processo. Se você não tiver testes automatizados para a maior parte de sua aplicação, será necessário gastar algum tempo realizando testes manuais de todas as partes alteradas. No caso da atualização do Rails, isso significa cada umas das funcionalidades dentro da aplicação. Faça a si mesmo um favor e tenha certeza de ter uma boa cobertura de teste **antes** de iniciar uma atualização.

### Versões Ruby

Rails geralmente se mantém próximo à versão mais recente do Ruby quando é liberado:

* Rails 7 requer Ruby 2.7.0 ou mais recente.
* Rails 6 requer Ruby 2.5.0 ou mais recente.
* Rails 5 requer Ruby 2.2.2 ou mais recente.

É uma boa ideia atualizar Ruby e Rails separadamente. Atualize para o Ruby mais recente que puder primeiro e, em seguida, atualize o Rails.

### O Processo de Atualização

Quando estiver atualizando a versão do Rails, o melhor é ir devagar, uma versão *Minor* por vez, para fazer bom uso dos avisos de depreciação. As versões do Rails são numeradas da maneira *Major*.*Minor*.*Patch*. Versões *Major* e *Minor* têm permissão para alterar API pública, isso pode causar erros em sua aplicação. Versões *Patch* incluem apenas correções de *bug*, e não alteram nenhuma API pública.

O processo deve correr da seguinte maneira:

1. Escreva os testes e garanta que eles passem.
2. Atualize para a última versão *Patch* após a versão atual de seu projeto.
3. Conserte os testes e funcionalidades depreciadas.
4. Atualize para a última versão *Patch* da versão *Minor* seguinte.

Repita este processo até chegar na versão desejada do Rails.

#### Movendo-se entre as versões

Para alternar entre as versões:

1. Altere o número da versão do Rails no `Gemfile` e execute o `bundle update`.
2. Altere as versões dos pacotes JavaScript do Rails em `package.json` e execute `yarn install`, se estiver executando no Webpacker.
3. Execute a [Tarefa de atualização](#the-update-task).
4. Execute seus testes.

Você pode encontrar uma lista de todas as gems do Rails lançadas [aqui](https://rubygems.org/gems/rails/versions).

### A Tarefa de Atualização

Rails fornece o comando `rails app:update`. Execute este comando após atualizar a versão do Rails no `Gemfile`. Isto lhe ajudará na criação de novos arquivos e na alteração de arquivos antigos em uma sessão interativa.

```bash
$ bin/rails app:update
       exist  config
    conflict  config/application.rb
Overwrite /myapp/config/application.rb? (enter "h" for help) [Ynaqdh]
       force  config/application.rb
      create  config/initializers/new_framework_defaults_7_0.rb
...
```

Não esqueça de revisar a diferença, para verificar se houveram mudanças inesperadas.

### Configurar Padrões de Framework

A nova versão do Rails pode ter configurações padrão diferentes da versão anterior. No entanto, após seguir os passos descritos acima, sua aplicação ainda estaria rodando com configurações padrão da versão **anterior** do Rails. Isso porque o valor para `config.load_defaults` em `config/application.rb` ainda não foi alterado.

Para permitir que você atualize para novos padrões um por um, a tarefa de atualização criou um arquivo `config/initializers/new_framework_defaults_X.Y.rb` (com a versão desejada do Rails no nome do arquivo). Você deve habilitar os novos padrões de configuração descomentando-os no arquivo; isso pode ser feito gradualmente ao longo de várias implantações. Assim que sua aplicação estiver pronta para rodar com novos padrões, você pode remover este arquivo e inverter o valor `config.load_defaults`.

Upgrading from Rails 6.1 to Rails 7.0
-------------------------------------

### `ActionView::Helpers::UrlHelper#button_to` changed behavior

Starting from Rails 7.0 `button_to` renders a `form` tag with `patch` HTTP verb if a persisted Active Record object is used to build button URL.
To keep current behavior consider explicitly passing `method:` option:

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)], method: :post)
```

or using helper to build the URL:

```diff
-button_to("Do a POST", [:my_custom_post_action_on_workshop, Workshop.find(1)])
+button_to("Do a POST", my_custom_post_action_on_workshop_workshop_path(Workshop.find(1)))
```

### Spring

If your application uses Spring, it needs to be upgraded to at least version 3.0.0. Otherwise you'll get

```
undefined method `mechanism=' for ActiveSupport::Dependencies:Module
```

Also, make sure [`config.cache_classes`][] is set to `false` in `config/environments/test.rb`.

[`config.cache_classes`]: configuring.html#config-cache-classes

### Sprockets is now an optional dependency

The gem `rails` doesn't depend on `sprockets-rails` anymore. If your application still needs to use Sprockets,
make sure to add `sprockets-rails` to your Gemfile.

```
gem "sprockets-rails"
```

### Applications need to run in `zeitwerk` mode

Applications still running in `classic` mode have to switch to `zeitwerk` mode. Please check the [Classic to Zeitwerk HOWTO](https://guides.rubyonrails.org/classic_to_zeitwerk_howto.html) guide for details.

### The setter `config.autoloader=` has been deleted

In Rails 7 there is no configuration point to set the autoloading mode, `config.autoloader=` has been deleted. If you had it set to `:zeitwerk` for whatever reason, just remove it.

### `ActiveSupport::Dependencies` private API has been deleted

The private API of `ActiveSupport::Dependencies` has been deleted. That includes methods like `hook!`, `unhook!`, `depend_on`, `require_or_load`, `mechanism`, and many others.

A few of highlights:

* If you used `ActiveSupport::Dependencies.constantize` or `ActiveSupport::Dependencies.safe_constantize`, just change them to `String#constantize` or `String#safe_constantize`.

  ```ruby
  ActiveSupport::Dependencies.constantize("User") # NO LONGER POSSIBLE
  "User".constantize # 👍
  ```

* Any usage of `ActiveSupport::Dependencies.mechanism`, reader or writer, has to be replaced by accessing `config.cache_classes` accordingly.

* If you want to trace the activity of the autoloader, `ActiveSupport::Dependencies.verbose=` is no longer available, just throw `Rails.autoloaders.log!` in `config/application.rb`.

Auxiliary internal classes or modules are also gone, like like `ActiveSupport::Dependencies::Reference`, `ActiveSupport::Dependencies::Blamable`, and others.

### Autoloading during initialization

Applications that autoloaded reloadable constants during initialization outside of `to_prepare` blocks got those constants unloaded and had this warning issued since Rails 6.0:

```
DEPRECATION WARNING: Initialization autoloaded the constant ....

Being able to do this is deprecated. Autoloading during initialization is going
to be an error condition in future versions of Rails.

...
```

If you still get this warning in the logs, please check the section about autoloading when the application boots in the [autoloading guide](https://guides.rubyonrails.org/v7.0/autoloading_and_reloading_constants.html#autoloading-when-the-application-boots). You'd get a `NameError` in Rails 7 otherwise.

### Ability to configure `config.autoload_once_paths`

[`config.autoload_once_paths`][] can be set in the body of the application class defined in `config/application.rb` or in the configuration for environments in `config/environments/*`.

Similarly, engines can configure that collection in the class body of the engine class or in the configuration for environments.

After that, the collection is frozen, and you can autoload from those paths. In particular, you can autoload from there during initialization. They are managed by the `Rails.autoloaders.once` autoloader, which does not reload, only autoloads/eager loads.

If you configured this setting after the environments configuration has been processed and are getting `FrozenError`, please just move the code.

[`config.autoload_once_paths`]: configuring.html#config-autoload-once-paths

### `ActionDispatch::Request#content_type` now returned Content-Type header as it is.

Previously, `ActionDispatch::Request#content_type` returned value does NOT contain charset part.
This behavior changed to returned Content-Type header containing charset part as it is.

If you want just MIME type, please use `ActionDispatch::Request#media_type` instead.

Before:

```ruby
request = ActionDispatch::Request.new("CONTENT_TYPE" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv"
```

After:

```ruby
request = ActionDispatch::Request.new("Content-Type" => "text/csv; header=present; charset=utf-16", "REQUEST_METHOD" => "GET")
request.content_type #=> "text/csv; header=present; charset=utf-16"
request.media_type   #=> "text/csv"
```

### Key generator digest class changing to use SHA256

The default digest class for the key generator is changing from SHA1 to SHA256.
This has consequences in any encrypted message generated by Rails, including
encrypted cookies.

In order to be able to read messages using the old digest class it is necessary
to register a rotator.

The following is an example for rotator for the encrypted cookies.

```ruby
# config/initializers/cookie_rotator.rb
Rails.application.config.after_initialize do
  Rails.application.config.action_dispatch.cookies_rotations.tap do |cookies|
    salt = Rails.application.config.action_dispatch.authenticated_encrypted_cookie_salt
    secret_key_base = Rails.application.secret_key_base

    key_generator = ActiveSupport::KeyGenerator.new(
      secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1
    )
    key_len = ActiveSupport::MessageEncryptor.key_len
    secret = key_generator.generate_key(salt, key_len)

    cookies.rotate :encrypted, secret
  end
end
```

### Digest class for ActiveSupport::Digest changing to SHA256

The default digest class for ActiveSupport::Digest is changing from SHA1 to SHA256.
This has consequences for things like Etags that will change and cache keys as well.
Changing these keys can have impact on cache hit rates, so be careful and watch out
for this when upgrading to the new hash.

### New ActiveSupport::Cache serialization format

A faster and more compact serialization format was introduced.

To enable it you must set `config.active_support.cache_format_version = 7.0`:

```ruby
# config/application.rb

config.load_defaults 6.1
config.active_support.cache_format_version = 7.0
```

Or simply:

```ruby
# config/application.rb

config.load_defaults 7.0
```

However Rails 6.1 applications are not able to read this new serialization format,
so to ensure a seamless upgrade you must first deploy your Rails 7.0 upgrade with
`config.active_support.cache_format_version = 6.1`, and then only once all Rails
processes have been updated you can set `config.active_support.cache_format_version = 7.0`.

Rails 7.0 is able to read both formats so the cache won't be invalidated during the
upgrade.

### Active Storage video preview image generation

Video preview image generation now uses FFmpeg's scene change detection to generate
more meaningful preview images. Previously the first frame of the video would be used
and that caused problems if the video faded in from black. This change requires
FFmpeg v3.4+.

### Active Storage default variant processor changed to `:vips`

For new apps, image transformation will use libvips instead of ImageMagick. This will reduce
the time taken to generate variants as well as CPU and memory usage, improving response
times in apps that rely on Active Storage to serve their images.

The `:mini_magick` option is not being deprecated, so it is fine to keep using it.

To migrate an existing app to libvips, set:

```ruby
Rails.application.config.active_storage.variant_processor = :vips
```

You will then need to change existing image transformation code to the
`image_processing` macros, and replace ImageMagick's options with libvips' options.

#### Replace resize with resize_to_limit
```diff
- variant(resize: "100x")
+ variant(resize_to_limit: [100, nil])
```

If you don't do this, when you switch to vips you will see this error: `no implicit conversion to float from string`.

#### Use an array when cropping
```diff
- variant(crop: "1920x1080+0+0")
+ variant(crop: [0, 0, 1920, 1080])
```

If you don't do this when migrating to vips, you will see the following error: `unable to call crop: you supplied 2 arguments, but operation needs 5`.

#### Clamp your crop values:

Vips is more strict than ImageMagick when it comes to cropping:

1. It will not crop if `x` and/or `y` are negative values. e.g.: `[-10, -10, 100, 100]`
2. It will not crop if position (`x` or `y`) plus crop dimension (`width`, `height`) is larger than the image. e.g.: a 125x125 image and a crop of `[50, 50, 100, 100]`

If you don't do this when migrating to vips, you will see the following error: `extract_area: bad extract area`

#### Adjust the background color used for `resize_and_pad`
Vips uses black as the default background color `resize_and_pad`, instead of white like ImageMagick. Fix that by using the `background` option:

```diff
- variant(resize_and_pad: [300, 300])
+ variant(resize_and_pad: [300, 300, background: [255]])
```

#### Remove any EXIF based rotation
Vips will auto rotate images using the EXIF value when processing variants. If you were storing rotation values from user uploaded photos to apply rotation with ImageMagick, you must stop doing that:

```diff
- variant(format: :jpg, rotate: rotation_value)
+ variant(format: :jpg)
```

#### Replace monochrome with colourspace
Vips uses a different option to make monochrome images:

```diff
- variant(monochrome: true)
+ variant(colourspace: "b-w")
```

#### Switch to libvips options for compressing images
JPEG

```diff
- variant(strip: true, quality: 80, interlace: "JPEG", sampling_factor: "4:2:0", colorspace: "sRGB")
+ variant(saver: { strip: true, quality: 80, interlace: true })
```

PNG

```diff
- variant(strip: true, quality: 75)
+ variant(saver: { strip: true, compression: 9 })
```

WEBP

```diff
- variant(strip: true, quality: 75, define: { webp: { lossless: false, alpha_quality: 85, thread_level: 1 } })
+ variant(saver: { strip: true, quality: 75, lossless: false, alpha_q: 85, reduction_effort: 6, smart_subsample: true })
```

GIF

```diff
- variant(layers: "Optimize")
+ variant(saver: { optimize_gif_frames: true, optimize_gif_transparency: true })
```

#### Deploy to production
Active Storage encodes into the url for the image the list of transformations that must be performed.
If your app is caching these urls, your images will break after you deploy the new code to production.
Because of this you must manually invalidate your affected cache keys.

For example, if you have something like this in a view:

```erb
<% @products.each do |product| %>
  <% cache product do %>
    <%= image_tag product.cover_photo.variant(resize: "200x") %>
  <% end %>
<% end %>
```

You can invalidate the cache either by touching the product, or changing the cache key:

```erb
<% @products.each do |product| %>
  <% cache ["v2", product] do %>
    <%= image_tag product.cover_photo.variant(resize_to_limit: [200, nil]) %>
  <% end %>
<% end %>
```

### Rails version is now included in the Active Record schema dump

Rails 7.0 changed some default values for some column types. To avoid that application upgrading from 6.1 to 7.0
load the current schema using the new 7.0 defaults, Rails now includes the version of the framework in the schema dump.

Before loading the schema for the first time in Rails 7.0, make sure to run `rails app:update` to ensure that the
version of the schema is included in the schema dump.

The schema file will look like this:

```ruby
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[6.1].define(version: 2022_01_28_123512) do
```

NOTE: The first time you dump the schema with Rails 7.0, you will see many changes to that file, including
some column information. Make sure to review the new schema file content and commit it to your repository.

Atualizando do Rails 6.0 para o Rails 6.1
-------------------------------------

Para mais informações sobre as mudanças feitas no Rails 6.1 consulte as [notas de lançamento](6_1_release_notes.html).

### `Rails.application.config_for` o valor de retorno não oferece mais suporte para acesso com chaves *String*.

Dado um arquivo de configuração como este:

```yaml
# config/example.yml
development:
  options:
    key: value
```

```ruby
Rails.application.config_for(:example).options
```

Isso costumava retornar um *hash* no qual você podia acessar valores com chaves *String*. Isso foi descontinuado no 6.0 e agora não funciona mais.

Você pode chamar `with_indifferent_access` no valor de retorno de` config_for` se ainda quiser acessar valores com chaves *String*, por exemplo:

```ruby
Rails.application.config_for(:example).with_indifferent_access.dig('options', 'key')
```

### Respostas do tipo de conteúdo ao utilizar `respond_to#any`

O cabeçalho (*header*) do tipo de conteúdo (*Content-Type*) retornado na resposta pode ser diferente do que o Rails 6.0 retornou,
mais especificamente se sua aplicação usa o formato `respond_to { |format| format.any }`.
O tipo de conteúdo será baseado no bloco fornecido e não no formato da solicitação.

Exemplo:

```ruby
def my_action
  respond_to do |format|
    format.any { render(json: { foo: 'bar' }) }
  end
end
```

```ruby
get('my_action.csv')
```

O comportamento anterior era retornar um tipo de conteúdo de resposta `text/csv` que é impreciso uma vez que uma resposta JSON está sendo renderizada.
O comportamento atual retorna corretamente o tipo de conteúdo de uma resposta `application/json`.

Se sua aplicação depende do comportamento incorreto anterior, você é incentivado a especificar
quais formatos sua ação aceita, ou seja.

```ruby
format.any(:xml, :json) { render request.format.to_sym => @people }
```

### `ActiveSupport::Callbacks#halted_callback_hook` agora recebe um segundo argumento

*Active Support* permite que você substitua o `halted_callback_hook` sempre que um retorno de chamada
pare a sequência. Este método agora recebe um segundo argumento que é o nome do retorno de chamada que está sendo interrompido.
Se você tiver classes que substituem esse método, certifique-se de que ele aceite dois argumentos. Observe que isso é uma mudança
significativa sem um ciclo de depreciação anterior (por motivos de desempenho).

Exemplo:

```ruby
class Book < ApplicationRecord
  before_save { throw(:abort) }
  before_create { throw(:abort) }

  def halted_callback_hook(filter, callback_name) # => Este método agora aceita 2 argumentos em vez de 1
    Rails.logger.info("Book couldn't be #{callback_name}d")
  end
end
```

### O método de classe `helper` nos *controllers* usa `String#constantize`

Conceitualmente antes do Rails 6.1

```ruby
helper "foo/bar"
```

resultou em

```ruby
require_dependency "foo/bar_helper"
module_name = "foo/bar_helper".camelize
module_name.constantize
```

Agora ele faz isso:

```ruby
prefix = "foo/bar".camelize
"#{prefix}Helper".constantize
```

Essa mudança é compatível com as versões anteriores para a maioria das aplicações, nesse caso, você não precisa fazer nada.

Tecnicamente, no entanto, os controllers podem configurar `helpers_path` para apontar para um diretório em `$LOAD_PATH` que não estava nos caminhos de carregamento automático. Esse caso de uso não é mais compatível com o uso imediato. Se o módulo auxiliar não for auto-carregável, a aplicação é responsável por carregá-lo antes de chamar o `helper`.

### Redirecionamento para HTTPS vindo de HTTP agora usará o código de status 308 HTTP

O código de status HTTP padrão usado em `ActionDispatch::SSL` ao redirecionar solicitações não GET/HEAD de HTTP para HTTPS foi alterado para `308` conforme definido em https://tools.ietf.org/html/rfc7538.

### Active Storage agora requer Processamento de Imagem

Ao processar variantes no Active Storage, agora é necessário ter a *gem* [image_processing](https://github.com/janko/image_processing) empacotada em vez de usar diretamente `mini_magick`. O processamento de imagem é configurado por padrão para usar `mini_magick` nos bastidores, então a maneira mais fácil de atualizar é substituindo a gem `mini_magick` pela gem `image_processing` e certificando-se de remover o uso explícito de `combine_options`, uma vez que não é mais necessário.

Para facilitar a leitura, você pode desejar alterar as chamadas `resize` brutas para macros `image_processing`. Por exemplo, em vez de:

```ruby
video.preview(resize: "100x100")
video.preview(resize: "100x100>")
video.preview(resize: "100x100^")
```

você pode fazer respectivamente:

```ruby
video.preview(resize_to_fit: [100, 100])
video.preview(resize_to_limit: [100, 100])
video.preview(resize_to_fill: [100, 100])
```

Atualizando do Rails 5.2 para o Rails 6.0
-------------------------------------

Para mais informações sobre as mudanças feitas no Rails 6.0 consulte as [notas de lançamento](6_0_release_notes.html).

### Usando Webpacker

[Webpacker](https://github.com/rails/webpacker)
é o compilador *JavaScript* padrão para Rails 6. Mas se você estiver atualizando a aplicação, ele não é ativado por padrão.
Se você quiser usar o *Webpacker*, adicione ele em seu *Gemfile* e instale:

```ruby
gem "webpacker"
```

```bash
$ bin/rails webpacker:install
```

### Forçar SSL

O método `force_ssl` nos *controllers* foi descontinuado e será removido no
Rails 6.1. Você é encorajado a habilitar [`config.force_ssl`][] para impor conexões
HTTPS ao longo de sua aplicação. Se você precisar isentar certos *endpoints*
do redirecionamento, você pode usar [`config.ssl_options`][] para configurar esse comportamento.

[`config.force_ssl`]: configuring.html#config-force-ssl
[`config.ssl_options`]: configuring.html#config-ssl-options

### Propósito (*Purpose*) e metadados de expiração agora estão incorporados em cookies assinados e criptografados para maior segurança

Para melhorar a segurança, o Rails incorpora os metadados de propósito e expiração dentro do valor de cookies criptografados ou assinados.

Rails pode então impedir ataques que tentam copiar o valor assinado/criptografado
de um *cookie* e usá-lo como o valor de outro *cookie*.

Esses novos metadados incorporados tornam esses *cookies* incompatíveis com versões do Rails anteriores a 6.0.

Se você deseja que seus *cookies* sejam lidos pelo Rails 5.2 e anteriores, ou ainda está validando seu *deploy* do 6.0 e deseja ser capaz de reverter (*rollback*)
`Rails.application.config.action_dispatch.use_cookies_with_metadata` para `false`.

### Todos os pacotes npm foram movidos para o escopo `@rails`

Se você estava anteriormente carregando qualquer um dos pacotes `actioncable`, `activestorage`,
ou `rails-ujs` através de npm/yarn, você deve atualizar os nomes destas
dependências antes de atualizá-los para o `6.0.0`:

```
actioncable   → @rails/actioncable
activestorage → @rails/activestorage
rails-ujs     → @rails/ujs
```

### Mudanças na API do *Action Cable JavaScript*

O pacote *Action Cable JavaScript* foi convertido do *CoffeeScript*
para *ES2015*, e agora publicamos o código-fonte via distribuição pelo npm.

Esta versão inclui algumas mudanças importantes para partes opcionais da
*API JavaScript Action Cable*:

- A configuração do adaptador *WebSocket* e do adaptador *logger* foi movida
  das propriedades de `ActionCable` para as propriedades de `ActionCable.adapters`.
  Se você estiver configurando esses adaptadores, você precisará fazer
  estas alterações:

    ```diff
    -    ActionCable.WebSocket = MyWebSocket
    +    ActionCable.adapters.WebSocket = MyWebSocket
    ```

    ```diff
    -    ActionCable.logger = myLogger
    +    ActionCable.adapters.logger = myLogger
    ```

- Os métodos `ActionCable.startDebugging()` e `ActionCable.stopDebugging()`
  foram movidos e substituídos pela propriedade
  `ActionCable.logger.enabled`. Se você estiver usando esse métodos, você
  precisará fazer estas alterações:

    ```diff
    -    ActionCable.startDebugging()
    +    ActionCable.logger.enabled = true
    ```

    ```diff
    -    ActionCable.stopDebugging()
    +    ActionCable.logger.enabled = false
    ```

### `ActionDispatch::Response#content_type` agora retorna o cabeçalho (*header*) do tipo de conteúdo (*Content-Type*) sem modificação

Anteriormente, o valor de retorno de `ActionDispatch::Response#content_type` NÃO continha a parte do conjunto de caracteres.
Este comportamento foi alterado para incluir também a parte do conjunto de caracteres omitida anteriormente.

Se você quiser apenas o tipo *MIME*, use `ActionDispatch::Response#media_type` em seu lugar.

Antes:

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present"
```

Depois:

```ruby
resp = ActionDispatch::Response.new(200, "Content-Type" => "text/csv; header=present; charset=utf-16")
resp.content_type #=> "text/csv; header=present; charset=utf-16"
resp.media_type   #=> "text/csv"
```

### Carregamento Automático

A configuração padrão para Rails 6

```ruby
# config/application.rb

config.load_defaults 6.0
```

ativa o modo de carregamento automático `zeitwerk` no CRuby. Nesse modo, o carregamento automático, o recarregamento e o carregamento antecipado são gerenciados pelo [Zeitwerk](https://github.com/fxn/zeitwerk).


Se você estiver usando os padrões de uma versão anterior do Rails, você pode habilitar o zeitwerk assim:

```ruby
# config/application.rb

config.autoloader = :zeitwerk
```

#### API Pública

Em geral, as aplicações não precisam usar a API do *Zeitwerk* diretamente. Rails configura as coisas de acordo com o contrato existente: `config.autoload_paths`,`config.cache_classes`, etc.

Embora as aplicações devam seguir essa interface, o objeto do carregador *Zeitwerk* atual pode ser acessado como

```ruby
Rails.autoloaders.main
```

Isso pode ser útil se você precisar pré-carregar classes com herança de tabela única (Single Table Inheritance - STIs) ou configurar um *inflector* customizado, por exemplo.

#### Estrutura do Projeto

Se a aplicação que está sendo atualizada for carregada automaticamente de forma correta, a estrutura do projeto já deve ser compatível.

No entanto, o modo `clássico` entende nomes de arquivos com (`underscore`), enquanto o modo `zeitwerk` entende nomes de arquivos (`camelize`). Esses *helpers* nem sempre são inversos entre si, especialmente se houver acrônimos envolvidos. Por exemplo, `"FOO".underscore` é `"foo"`, mas `"foo".camelize` é `"Foo"`, não `"FOO "`.

A compatibilidade pode ser verificada com a tarefa `zeitwerk:check`:

```bash
$ bin/rails zeitwerk:check
Hold on, I am eager loading the application.
All is good!
```

#### *require_dependency*

Todos os casos de uso conhecidos de `require_dependency` foram eliminados, você deve executar o *grep* no projeto e excluí-los.

Se sua aplicação usa herança de tabela única (STI), consulte a [seção Herança de tabela única](autoloading_and_reloading_constants.html#single-table-inheritance) do guia Autoloading and Reloading Constants (Zeitwerk Mode).

#### Nomes qualificados nas definições de classe e módulo

Agora você pode usar *constant paths* de forma robusta nas definições de classe e módulo:

```ruby
# O carregamento automático no corpo desta classe corresponde à semântica Ruby agora.
class Admin::UsersController < ApplicationController
  # ...
end
```

Um problema a ter em conta é que, dependendo da ordem de execução, o auto carregamento clássico pode às vezes ser capaz de carregar automaticamente `Foo::Wadus` em

```ruby
class Foo::Bar
  Wadus
end
```

Isso não corresponde à semântica Ruby porque `Foo` não está no aninhamento e não funcionará no modo `zeitwerk`. Se você encontrar esse caso, você pode usar o nome qualificado `Foo::Wadus`:

```ruby
class Foo::Bar
  Foo::Wadus
end
```

ou adicione `Foo` ao aninhamento:

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

#### (*Concerns*)

Você pode carregar automaticamente e antecipadamente a partir de uma estrutura padrão como

```
app/models
app/models/concerns
```

Nesse caso, `app/models/concerns` é considerado um diretório raiz (porque pertence aos caminhos de carregamento automático) e é ignorado como *namespace*. Portanto, `app/models/concern/foo.rb` deve definir `Foo`, não `Concerns::Foo`.

O *namespace* `Concerns::` funcionou com o carregamento automático clássico como um efeito colateral da implementação, mas não foi realmente um comportamento pretendido. Uma aplicação que usa `Concerns::` precisa renomear essas classes e módulos para poder rodar no modo `zeitwerk`.

#### Tendo `app` nos caminhos de carregamento automático

Alguns projetos querem algo como `app/api/base.rb` para definir `API::Base`, e adicionar `app` aos caminhos de carregamento automático para fazer isso no modo `clássico`. Já que Rails adiciona todos os subdiretórios de `app` aos caminhos de carregamento automático automaticamente, temos outra situação em que há diretórios raiz aninhados, de forma que a configuração não funciona mais. Princípio semelhante que explicamos acima com `concerns`.

Se quiser manter essa estrutura, você precisará excluir o subdiretório dos caminhos de carregamento automático em um inicializador:

```ruby
ActiveSupport::Dependencies.autoload_paths.delete("#{Rails.root}/app/api")
```

#### Constantes carregadas automaticamente e *namespaces* explícitos

Se um *namespace* for definido em um arquivo, como `Hotel` está aqui:

```
app/models/hotel.rb         # Defines Hotel.
app/models/hotel/pricing.rb # Defines Hotel::Pricing.
```

a constante `Hotel` deve ser definida usando as palavras-chave `class` ou `module`. Por exemplo:

```ruby
class Hotel
end
```

é bom.

Alternativas como

```ruby
Hotel = Class.new
```

ou

```ruby
Hotel = Struct.new
```

não funcionará, objetos filhos como `Hotel::Pricing` não serão encontrados.

Essa restrição se aplica apenas a *namespaces* explícitos. Classes e módulos que não definem um *namespace* podem ser definidos usando esses idiomas.

#### Um arquivo, uma constante (no mesmo nível superior)

No modo `classic`, você pode definir tecnicamente várias constantes no mesmo nível superior e ter todas elas recarregadas. Por exemplo, dado

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

enquanto `Bar` não pôde ser carregado automaticamente, o carregamento automático de `Foo` marcaria `Bar` como carregado automaticamente também. Este não é o caso no modo `zeitwerk`, você precisa mover `Bar` para seu próprio arquivo `bar.rb`. Um arquivo, uma constante.

Isso se aplica apenas as constantes no mesmo nível superior do exemplo acima. Classes e módulos internos são adequados. Por exemplo, considere

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

Se a aplicação recarregar `Foo`, ela irá recarregar `Foo::InnerClass` também.

#### *Spring* e o ambiente `test`

*Spring* recarrega o código da aplicação se algo mudar. No ambiente `test`, você precisa habilitar o recarregamento para que funcione:

```ruby
# config/environments/test.rb

config.cache_classes = false
```

Caso contrário, você obterá este erro:

```
reloading is disabled because config.cache_classes is true
```

#### *Bootsnap*

O *Bootsnap* deve ter pelo menos a versão 1.4.2.

Além disso, o *Bootsnap* precisa desabilitar o cache *iseq* devido a um bug no interpretador se estiver executando o Ruby 2.5. Certifique-se de depender de pelo menos Bootsnap 1.4.4 nesse caso.

#### `config.add_autoload_paths_to_load_path`

O novo ponto de configuração [`config.add_autoload_paths_to_load_path`][] é `true` por padrão para compatibilidade com versões anteriores, mas permite que você opte por não adicionar os caminhos de carregamento automático a `$LOAD_PATH`.

Isso faz sentido na maioria das aplicações, já que você nunca deve requerer um arquivo em `app/models`, por exemplo, e o *Zeitwerk* só usa nomes de arquivo absolutos internamente.

Ao optar pela exclusão, você otimiza as pesquisas ao `$LOAD_PATH` (menos diretórios para verificar) e economiza o trabalho do *Bootsnap* e o consumo de memória, já que não é necessário construir um índice para esses diretórios.

[`config.add_autoload_paths_to_load_path`]: configuring.html#config-add-autoload-paths-to-load-path

#### *Thread-safety*

No modo clássico, o carregamento automático constante não é *thread-safe*, embora o Rails tenha travas, por exemplo, para tornar as solicitações da web *thread-safe* quando o carregamento automático está habilitado, como é comum no ambiente de desenvolvimento.

O carregamento automático constante é *thread-safe* no modo `zeitwerk`. Por exemplo, agora você pode carregar automaticamente em scripts *multi-threaded* executados pelo comando `runner`.

#### *Globs* em *config.autoload_paths*

Cuidado com configurações como

```ruby
config.autoload_paths += Dir["#{config.root}/lib/**/"]
```

Cada elemento de `config.autoload_paths` deve representar o *namespace* de nível superior (`Object`) e eles não podem ser aninhados em consequência (com exceção dos diretórios `concerns` explicados acima).

Para corrigir isso, basta remover os curingas (*wildcards*):

```ruby
config.autoload_paths << "#{config.root}/lib"
```

#### Carregamento rápido (*Eager loading*) e carregamento automático são consistentes

No modo `clássico`, se `app/models/foo.rb` define `Bar`, você não será capaz de carregar automaticamente aquele arquivo, mas o carregamento rápido funcionará porque carrega os arquivos recursivamente às cegas. Isso pode ser uma fonte de erros se você testar as coisas primeiro com carregamento rápido; a execução pode falhar no carregamento automático posterior.

No modo `zeitwerk` ambos os modos de carregamento são consistentes, eles falham e erram nos mesmos arquivos.

#### Como usar o Carregamento Automático Clássico no Rails 6

As aplicações podem carregar os padrões do Rails 6 e ainda usar o carregamento automático clássico definindo `config.autoloader` desta forma:

```ruby
# config/application.rb

config.load_defaults 6.0
config.autoloader = :classic
```

Ao usar o Carregamento Automático Clássico na aplicação Rails 6, é recomendado definir o nível de simultaneidade (*concurrency*) como 1 no ambiente de desenvolvimento, para os servidores web e processadores de segundo plano, devido às questões de *thread-safety*.

### Alteração de comportamento de atribuição do *Active Storage*

Com os padrões de configuração para Rails 5.2, atribuir a uma coleção de anexos declarados com `has_many_attached` acrescenta novos arquivos:

```ruby
class User < ApplicationRecord
  has_many_attached :highlights
end

user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

Com os padrões de configuração do Rails 6.0, atribuir a uma coleção de anexos substitui os arquivos existentes em vez de anexar a eles. Isso corresponde ao comportamento do *Active Record* ao atribuir a uma associação de coleção:

```ruby
user.highlights.attach(filename: "funky.jpg", ...)
user.highlights.count # => 1

blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.update!(highlights: [ blob ])

user.highlights.count # => 1
user.highlights.first.filename # => "town.jpg"
```

`#attach` pode ser usado para adicionar novos anexos sem remover os existentes:

```ruby
blob = ActiveStorage::Blob.create_after_upload!(filename: "town.jpg", ...)
user.highlights.attach(blob)

user.highlights.count # => 2
user.highlights.first.filename # => "funky.jpg"
user.highlights.second.filename # => "town.jpg"
```

As aplicações existentes podem aceitar este novo comportamento definindo [`config.active_storage.replace_on_assign_to_many`][] como `true`. O comportamento antigo será descontinuado no Rails 7.0 e removido no Rails 7.1.

[`config.active_storage.replace_on_assign_to_many`]: configuring.html#config-active-storage-replace-on-assign-to-many

Atualizando do Rails 5.1 para o Rails 5.2
-------------------------------------

Para mais informações sobre as mudanças feitas no Rails 5.2 consulte as [notas de lançamento](5_2_release_notes.html).

### *Bootsnap*

Rails 5.2 adiciona a *gem bootsnap* no [novo Gemfile](https://github.com/rails/rails/pull/29313).
O comando `app:update` o configura em `boot.rb`. Se você quiser utilizá-lo, então adicione-o no Gemfile:

```ruby
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false
```

Caso contrário, mude o `boot.rb` para não utilizar o *bootsnap*.

### A expiração em *cookies* assinados ou criptografados está agora incorporada nos valores dos *cookies*

Para melhorar a segurança, Rails agora incorpora as informações de expiração também no valor de cookies criptografados ou assinados.

Estas novas informações incorporadas tornam estes *cookies* incompatíveis com versões do Rails mais antigas que 5.2.

Se você quer que seus cookies sejam lidos até 5.1 e anteriores, ou se ainda estiver validando seu *deploy* 5.2 e quiser permitir o *rollback* configure
 `Rails.application.config.action_dispatch.use_authenticated_cookie_encryption` para `false'.

Atualizando do Rails 5.0 para o Rails 5.1
-------------------------------------

Para mais informações sobre as mudanças feitas no Rails 5.1 consulte as [notas de lançamento](5_1_release_notes.html).

### `HashWithIndifferentAccess` de nível superior está descontinuado

Se sua aplicação usa a classe `HashWithIndifferentAccess` de nível superior, você
 deve mover lentamente seu código para usar `ActiveSupport::HashWithIndifferentAccess`.

Está apenas descontinuado, o que significa que seu código não quebrará no momento e nenhum aviso de descontinuação será exibido, mas esta constante será removida no futuro.

Além disso, se você tiver documentos *YAML* muito antigos contendo despejos (*dumps*) de tais objetos, pode ser necessário carregá-los e despejá-los novamente para ter certeza de que referenciam à constante correta, e que carregá-los não quebrará no futuro.

### `application.secrets` agora é carregado com todas as chaves como símbolos

Se sua aplicação armazena configuração aninhada em `config/secrets.yml`, todas as chaves agora são carregadas como símbolos, então o acesso usando *strings* deve ser alterado.

De:

```ruby
Rails.application.secrets[:smtp_settings]["address"]
```

Para:

```ruby
Rails.application.secrets[:smtp_settings][:address]
```

### Removido suporte obsoleto para `:text` e `:nothing` em `render`

Se seus *controllers* estiverem usando `render :text`, elas não funcionarão mais. O novo método de renderização de texto com o tipo MIME de `text/plain` é usar `render :plain`.

Similarmente, `render :nothing` também é removido e você deve usar o método `head` para enviar respostas que contenham apenas cabeçalhos (*headers*). Por exemplo, `head :ok` envia uma resposta 200 sem corpo (*body*) para renderizar.

### Removido suporte obsoleto para `redirect_to :back`

No Rails 5.0, `redirect_to :back` foi descontinuado. No Rails 5.1, foi removido completamente.

Como alternativa, use `redirect_back`. É importante notar que `redirect_back` também leva
uma opção `fallback_location` que será usada caso o `HTTP_REFERER` esteja faltando.

```
redirect_back(fallback_location: root_path)
```

Atualizando do Rails 4.2 para o Rails 5.0
-------------------------------------

Para mais informações sobre as mudanças feitas no Rails 5.0 consulte as [notas de lançamento](5_0_release_notes.html).

### Necessário Ruby 2.2.2+

Do Ruby on Rails 5.0 em diante, Ruby 2.2.2+ é a única versão do Ruby suportada.
Certifique-se de ter a versão Ruby 2.2.2 ou superior, antes de prosseguir.

### *Active Record Models* agora herdam de *ApplicationRecord* por padrão

No Rails 4.2, um *Active Record model* herda de `ActiveRecord::Base`. No Rails 5.0,
todos os *models* são herdados de `ApplicationRecord`.

`ApplicationRecord` é uma nova superclasse para todos os *models* da aplicação, análogo ao que o
`ApplicationController` é para os *controllers* em vez de `ActionController::Base`. Isso dá as aplicações um único local para configurar o comportamento dos *models*.

Ao atualizar do Rails 4.2 para o Rails 5.0, você precisa criar um arquivo `application_record.rb` em `app/models/` e adicionar o seguinte conteúdo:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
```

Em seguida, certifique-se de que todos os seus *models* herdem dele.

### Interrompendo Sequências de *Callback* via `throw(:abort)`

No Rails 4.2, quando um *'before' callback* retorna `false` no *Active Record*
e *Active Model*, então toda a sequência de *callback* é interrompida. Em outras palavras,
sucessivos *'before' callback* não são executados, e nem é a ação encapsulada
em *callbacks*.

No Rails 5.0, ao retornar `false` em um *callback* no *Active Record* ou *Active Model*
não terá o efeito colateral de interromper a sequência de *callback*. Em vez disso, a sequência de *callback* deve ser interrompida explicitamente chamando `throw(:abort)`.

Quando você atualiza do Rails 4.2 para o Rails 5.0, retornando `false` nesse tipo de
*callback* a sequência de *callback* ainda será interrompida, mas você receberá um aviso de suspensão de uso sobre esta mudança futura.

Quando estiver pronto, você pode optar pelo novo comportamento e remover o aviso de suspensão de uso adicionando a seguinte configuração ao seu `config/application.rb`:

```ruby
ActiveSupport.halt_callback_chains_on_return_false = false
```

Observe que esta opção não afetará os *callbacks* do *Active Support*, uma vez que eles nunca
interrompem a sequência quando algum valor foi retornado.

Consulte [#17227](https://github.com/rails/rails/pull/17227) para obter mais detalhes.

### *ActiveJob* agora herda de *ApplicationJob* por padrão

No Rails 4.2, um *Active Job* herda de `ActiveJob::Base`. No Rails 5.0, este
comportamento mudou para agora herdar de `ApplicationJob`.

Ao atualizar do Rails 4.2 para o Rails 5.0, você precisa criar um
arquivo `application_job.rb` em `app/jobs/` e adicionar o seguinte conteúdo:

```ruby
class ApplicationJob < ActiveJob::Base
end
```

Em seguida, certifique-se de que todas as classes *job* herdam dele.

Veja [#19034](https://github.com/rails/rails/pull/19034) para maiores detalhes.

### Testando Rails *Controller*

#### Extração de alguns métodos auxiliares (*helper*) para `rails-controller-testing`

`assigns` e `assert_template` foram extraídos para a gem `rails-controller-testing`. Para
continuar usando esses métodos em seus testes de *controller*, adicione a `gem 'rails-controller-testing'` para seu `Gemfile`.

Se você estiver usando RSpec para teste, consulte a configuração extra necessária na
documentação da gem.

#### Novo comportamento ao enviar arquivos

Se você estiver usando `ActionDispatch::Http::UploadedFile` em seus testes para
envio de arquivos, você precisará alterar para usar a classe `Rack::Test::UploadedFile`.

Veja [#26404](https://github.com/rails/rails/issues/26404) para maiores detalhes.

### Carregamento automático é desabilitado após a inicialização no ambiente de produção

O carregamento automático agora está desativado após a inicialização no ambiente de produção por padrão.

O carregamento rápido (*Eager loading*) da aplicação faz parte do processo de inicialização, portanto, constantes de alto nível estão bem e ainda são carregadas automaticamente, não há necessidade de exigir seus arquivos.

Constantes em locais mais profundos são executados apenas em tempo de execução, como corpos de métodos regulares, também estão bem porque o arquivo que os define terá sido carregado durante a inicialização.

Para a grande maioria das aplicações, essa alteração não exige nenhuma ação. Mas no
evento muito raro em que sua aplicação precisa de carregamento automático durante a execução em
produção, defina `Rails.application.config.enable_dependency_loading` para *true*.

### Serialização XML

`ActiveModel::Serializers::Xml` foi extraído do Rails para a *gem* `activemodel-serializers-xml`.
Para continuar usando a serialização XML em sua aplicação, adicione a `gem 'activemodel-serializers-xml'` para o seu `Gemfile`.

### Removido o suporte para o antigo adaptador de banco de dados `mysql`

O Rails 5 remove o suporte para o antigo adaptador de banco de dados `mysql`. A maioria dos usuários devem usar o `mysql2` em vez disso. Será convertido em uma *gem* separada quando encontrarmos alguém para manter.

### Removido suporte para o *Debugger*

`debugger` não é suportado pelo Ruby 2.2 que é requerido pelo Rails 5. Use `byebug` ao invés.

### Use `bin/rails` para executar tarefas e testes

Rails 5 adiciona a habilidade de executar tarefas e testes através de `bin/rails` ao invés de *rake*.
Geralmente essas mudanças ocorrem em paralelo com o *rake*, mas algumas foram portadas completamente.

Para usar o novo executor de teste, simplesmente digite `bin/rails test`.

`rake dev:cache` é agora `bin/rails dev:cache`.

Execute `bin/rails` dentro do diretório raiz da sua aplicação para ver a lista de comandos disponíveis.

### `ActionController::Parameters` Não herda mais de `HashWithIndifferentAccess`

Chamar `params` em sua aplicação agora retornará um objeto em vez de um *hash*. Se seus
parâmetros já são permitidos, então você não precisará fazer nenhuma alteração. Se você estiver usando `map`
e outros métodos que dependem de ser capaz de ler o *hash* independentemente de `permitted?` você
precisará atualizar sua aplicação para primeiro permitir e depois converter para um *hash*.

```ruby
params.permit([:proceed_to, :return_to]).to_h
```

### `protect_from_forgery` Agora assume como padrão `prepend:false`

O padrão `protect_from_forgery` é `prepend: false`, o que significa que será inserido no
*callback* no ponto em que você a chama em sua aplicação. Se você quiser
`protect_from_forgery` para sempre executar primeiro, então você deve alterar sua aplicação para usar
`protect_from_forgery prepend: true`.

### O *Template Handler* padrão agora é *RAW*

Os arquivos sem um *template handler* em sua extensão serão renderizados usando o *raw handler*.
Anteriormente, o Rails renderizava arquivos usando o *ERB template handler*.

Se você não deseja que seu arquivo seja tratado por meio do *raw handler*, você deve adicionar uma extensão
ao seu arquivo que pode ser analisado pelo *template handler* apropriado.

### Adicionada correspondência de curinga (*Wildcard*) para *Template Dependencies*

Agora você pode usar a correspondência de curinga para suas *template dependencies*. Por exemplo, se você
definisse seus *templates* como:

```erb
<% # Template Dependency: recordings/threads/events/subscribers_changed %>
<% # Template Dependency: recordings/threads/events/completed %>
<% # Template Dependency: recordings/threads/events/uncompleted %>
```

Agora você pode chamar a dependência apenas uma vez com um curinga.

```erb
<% # Template Dependency: recordings/threads/events/* %>
```

### `ActionView::Helpers::RecordTagHelper` movido para a *gem* externa (record_tag_helper)

`content_tag_for` e `div_for` foram removidos em favor de usar apenas `content_tag`. Para continuar usando os métodos mais antigos, adicione a *gem* `record_tag_helper` ao seu `Gemfile`:

```ruby
gem 'record_tag_helper', '~> 1.0'
```

Veja [#18411](https://github.com/rails/rails/pull/18411) para mais detalhes.

### Removido suporte para a *Gem* `protected_attributes`

A *gem* `protected_attributes` não é mais suportada no Rails 5.

### Removido o suporte para a *gem* `activerecord-deprecated_finders`

A *gem* `activerecord-deprecated_finders` não é mais suportada no Rails 5.

### A ordem do teste padrão `ActiveSupport::TestCase` agora é aleatória

Quando os testes são executados em sua aplicação, a ordem padrão agora é `:random`
em vez de `:sorted`. Use a seguinte opção de configuração para defini-lo de volta para `:sorted`.

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted
end
```

### `ActionController::Live` tornou-se uma `Concern`

Se você incluir `ActionController::Live` em outro módulo que está incluído em seu *controller*, então você
também deve estender o módulo com `ActiveSupport::Concern`. Alternativamente, você pode usar o gancho (*hook*)
`self.included` para incluir `ActionController::Live` diretamente no *controller* uma vez que o `StreamingSupport` está incluído.

Isso significa que se sua aplicação costumava ter seu próprio módulo de *streaming*, o código a seguir
seria interrompido em produção:

```ruby
# Esta é uma solução alternativa para *streamed controllers* realizando autenticação com *Warden/Devise*.
# Veja https://github.com/plataformatec/devise/issues/2332
# Autenticando no *router* é outra solução, conforme sugerido nessa *issue*
class StreamingSupport
  include ActionController::Live # isso não funcionará em produção para Rails 5
  # extend ActiveSupport::Concern # a menos que você descomente esta linha.

  def process(name)
    super(name)
  rescue ArgumentError => e
    if e.message == 'uncaught throw :warden'
      throw :warden
    else
      raise e
    end
  end
end
```

### Novos Padrões do Framework

#### *Active Record* `belongs_to` Exigido por Padrão

`belongs_to` agora irá disparar um erro de validação por padrão se a associação não estiver presente.

Isso pode ser desativado por associação com `optional: true`.

Este padrão será configurado automaticamente em novas aplicações. Se uma aplicação existente
deseja adicionar este recurso, ele precisará ser ativado em um *initializer*:

```ruby
config.active_record.belongs_to_required_by_default = true
```

A configuração é global por padrão para todos os seus *models*, mas você pode
sobrepor individualmente por *model*. Isso deve ajudá-lo a migrar todos os seus *models* para ter suas
associações exigidas por padrão.

```ruby
class Book < ApplicationRecord
  # model ainda não está pronto para ter sua associação exigida por padrão

  self.belongs_to_required_by_default = false
  belongs_to(:author)
end

class Car < ApplicationRecord
  # model está pronto para ter sua associação exigida por padrão

  self.belongs_to_required_by_default = true
  belongs_to(:pilot)
end
```

#### *Tokens* CSRF por formulário

Rails 5 agora suporta *tokens* CSRF por formulário para mitigar ataques de injeção de código com formulários
criados por JavaScript. Com esta opção ativada, cada formulário em sua aplicação terá seu
próprio *token* CSRF que é específico para a ação e o método desse formulário.

```ruby
config.action_controller.per_form_csrf_tokens = true
```

#### Proteção contra Falsificação com Verificação de Origem

Agora você pode configurar sua aplicação para verificar se o cabeçalho (*header*) HTTP `Origin` deve ser
verificado contra a origem do site como uma defesa adicional de CSRF. Defina o seguinte em sua configuração para
true:

```ruby
config.action_controller.forgery_protection_origin_check = true
```

#### Permitir Configuração do Nome da Fila do *Action Mailer*

O nome da fila do *mailer* padrão é `mailers`. Esta opção de configuração permite que você mude globalmente
o nome da fila. Defina o seguinte em sua configuração:

```ruby
config.action_mailer.deliver_later_queue_name = :new_queue_name
```

#### Suportar *Fragment Caching* na *Action Mailer Views*

Defina [`config.action_mailer.perform_caching`][] em sua configuração para determinar se sua *Action Mailer views*
deve suportar cache.

```ruby
config.action_mailer.perform_caching = true
```

[`config.action_mailer.perform_caching`]: configuring.html#config-action-mailer-perform-caching

#### Configure a Saída de `db:structure:dump`

Se você estiver usando `schema_search_path` ou outras extensões PostgreSQL, você pode controlar como o esquema é
despejado. Defina como `:all` para gerar todos os *dumps*, ou como `:schema_search_path` para gerar a partir do caminho de pesquisa do esquema.

```ruby
config.active_record.dump_schemas = :all
```

#### Configurar Opções de SSL para Habilitar HSTS com Subdomínios

Defina o seguinte em sua configuração para habilitar HSTS ao usar subdomínios:

```ruby
config.ssl_options = { hsts: { subdomains: true } }
```

#### Preservar Fuso Horário do Receptor

Ao usar Ruby 2.4, você pode preservar o fuso horário do receptor ao chamar `to_time`.

```ruby
ActiveSupport.to_time_preserves_timezone = false
```

### Mudanças na Serialização JSON/JSONB

No Rails 5.0, como os atributos JSON/JSONB são serializados e desserializados foram alterados. Agora se
você definir uma coluna igual a uma `String`, *Active Record* não irá mais transformar essa *string*
em um `Hash` e, em vez disso, apenas retornará a *string*. Isso não se limita ao código que
interage com os *models*, mas também afeta as configurações da coluna `:default` em `db/schema.rb`.
É recomendado que você não defina colunas iguais a `String`, mas passe `Hash`
em vez disso, que será convertido de e para uma *string* JSON automaticamente.

Atualizando do Rails 4.1 para o Rails 4.2
-------------------------------------

### *Web Console*

Primeiro, adicione a `gem 'web-console', '~> 2.0'` ao grupo `:development` em seu `Gemfile` e execute `bundle install` (ela não foi incluída quando você atualizou o Rails). Depois de instalado, você pode simplesmente colocar uma referência ao *console helper* (ou seja, `<%= console %>`) em qualquer *view* para a qual deseja habilitá-lo. Um *console* também será fornecido em qualquer página de erro exibida em seu ambiente de desenvolvimento.

### *Responders*

Os métodos de classe `respond_with` e `respond_to` foram extraídos para a *gem* `responders`. Para usá-los, simplesmente adicione a `gem 'responders', '~> 2.0'` ao seu `Gemfile`. Chamadas para `respond_with` e `respond_to` (novamente, no nível de classe) não funcionarão mais sem incluir a *gem* `responders` em suas dependências:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  respond_to :html, :json

  def show
    @user = User.find(params[:id])
    respond_with @user
  end
end
```

`respond_to` em nível de instância não é afetado e não requer a *gem* adicional:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @user }
    end
  end
end
```

Veja [#16526](https://github.com/rails/rails/pull/16526) para mais detalhes.

### Tratamento de erros em *transaction callbacks*

Atualmente, o *Active Record* suprime os erros levantados dentro de *callbacks* `after_rollback` ou `after_commit` e apenas os imprime para os logs.
Na próxima versão, esses erros não serão mais suprimidos. Em vez disso, os erros serão propagados normalmente como em outros *Active Record callbacks*.

Quando você define um *callback* `after_rollback` ou `after_commit`, você receberá um aviso de suspensão de uso sobre essa mudança futura.
Quando você estiver pronto, pode optar pelo novo comportamento e remover o aviso de suspensão de uso, adicionando a seguinte configuração ao seu
`config/application.rb`:

```ruby
config.active_record.raise_in_transactional_callbacks = true
```

Veja [#14488](https://github.com/rails/rails/pull/14488) e
[#16537](https://github.com/rails/rails/pull/16537) para mais detalhes.

### Ordenando os casos de teste

No Rails 5.0, os casos de teste serão executados em ordem aleatória por padrão. Em antecipação a esta mudança, Rails 4.2 introduziu uma nova opção de configuração
`active_support.test_order` para especificar explicitamente a ordem dos testes. Isso permite que você bloqueie o comportamento atual, definindo a opção para
`:sorted`, ou opte pelo comportamento futuro configurando a opção para `:random`.

Se você não especificar um valor para esta opção, um aviso de suspensão de uso será emitido. Para evitar isso, adicione a seguinte linha ao seu ambiente de teste:

```ruby
# config/environments/test.rb
Rails.application.configure do
  config.active_support.test_order = :sorted # ou `:random` se você preferir
end
```

### Atributos serializados

Ao usar um codificador personalizado (por exemplo, `serialize :metadata, JSON`), atribuir `nil` a um atributo serializado irá salvá-lo no banco de dados
como `NULL` em vez de passar o valor `nil` através do codificador (por exemplo, `"null"` quando usando o codificador `JSON`).

### Nível de *log* em produção

No Rails 5, o nível de *log* padrão para o ambiente de produção será alterado para `:debug` (de `:info`). Para preservar o padrão atual, adicione a seguinte linha para o seu `production.rb`:

```ruby
# Defina como `:info` para corresponder ao padrão atual, ou defina como `:debug` para ativar o padrão futuro.
config.log_level = :info
```

### `after_bundle` em Rails *templates*

Se você tem um *Rails template* que adiciona todos os arquivos no controle de versão, isso falhará ao adicionar os *binstubs* gerados porque ele é executado antes do Bundler:

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }
```

Agora você pode envolver as chamadas `git` em um bloco `after_bundle`. Isso será executado depois que os *binstubs* foram gerados.

```ruby
# template.rb
generate(:scaffold, "person name:string")
route "root to: 'people#index'"
rake("db:migrate")

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
```

### Rails *HTML Sanitizer*

Há uma nova opção para sanitizar fragmentos de HTML em suas aplicações. A venerável abordagem *html-scanner* agora está oficialmente sendo descontinuada em favor de
[`Rails HTML Sanitizer`](https://github.com/rails/rails-html-sanitizer).

Isso significa que os métodos `sanitize`, `sanitize_css`, `strip_tags` e `strip_links` são apoiados por uma nova implementação.

Este novo *sanitizer* usa internamente [Loofah](https://github.com/flavorjones/loofah). Loofah, por sua vez, usa Nokogiri, que
envolve analisadores XML escritos em C e Java, portanto, a sanitização deve ser mais rápida não importa qual versão do Ruby você execute.

A nova versão atualiza `sanitize`, então pode usar um `Loofah::Scrubber` para uma depuração poderosa.
[Veja alguns exemplos de depuradores aqui](https://github.com/flavorjones/loofah#loofahscrubber).

Dois novos depuradores também foram adicionados: `PermitScrubber` e `TargetScrubber`.
Leia o [*gem's readme*](https://github.com/rails/rails-html-sanitizer) para mais informações.

A documentação para `PermitScrubber` e `TargetScrubber` explica como você pode obter controle total sobre quando e como os elementos devem ser removidos.

Se sua aplicação precisa usar a implementação antiga do *sanitizer*, inclua `rails-deprecated_sanitizer` em seu `Gemfile`:

```ruby
gem 'rails-deprecated_sanitizer'
```

### Testando *Rails DOM*

O [módulo `TagAssertions`](https://api.rubyonrails.org/v4.1/classes/ActionDispatch/Assertions/TagAssertions.html) (contendo métodos como `assert_tag`), [foi descontinuado](https://github.com/rails/rails/blob/6061472b8c310158a2a2e8e9a6b81a1aef6b60fe/actionpack/lib/action_dispatch/testing/assertions/dom.rb) em favor dos métodos `assert_select` do módulo `SelectorAssertions`, que foi extraído para a [*gem rails-dom-testing*](https://github.com/rails/rails-dom-testing).

### Tokens de autenticidade mascarados

A fim de mitigar ataques SSL, `form_authenticity_token` agora é mascarado para que varie com cada solicitação (*request*). Assim, os *tokens* são validados desmascarando e depois descriptografando. Como resultado, quaisquer estratégias para verificar solicitações de formulários não-rails que dependiam de um *token* CSRF de sessão estática devem levar isso em consideração.

### *Action Mailer*

Anteriormente, chamar um método *mailer* em uma classe *mailer* resultaria no método de instância correspondente sendo executado diretamente. Com a introdução de
*Active Job* e `#deliver_later`, isso não é mais verdade. No Rails 4.2, a invocação dos métodos de instância é adiada até `deliver_now` ou
`deliver_later` sejam chamados. Por exemplo:

```ruby
class Notifier < ActionMailer::Base
  def notify(user, ...)
    puts "Called"
    mail(to: user.email, ...)
  end
end
```

```ruby
mail = Notifier.notify(user, ...) # Notifier#notify ainda não é chamado neste momento
mail = mail.deliver_now           # Imprime "Called"
```

Isso não deve resultar em diferenças perceptíveis para a maioria das aplicações.
No entanto, se você precisar que alguns métodos não-*mailer* sejam executados de forma síncrona, e
você estava contando anteriormente com o comportamento de *proxy* síncrono, você deve
definí-los como métodos de classe na classe *mailer* diretamente:

```ruby
class Notifier < ActionMailer::Base
  def self.broadcast_notifications(users, ...)
    users.each { |user| Notifier.notify(user, ...) }
  end
end
```

### Suporte para chave estrangeira

A migração DSL foi expandida para suportar definições de chave estrangeira. Se
você tem usado a *gem Foreigner*, você pode querer considerar removê-la.
Observe que o suporte de chave estrangeira do Rails é um subconjunto de *Foreigner*. Isso significa
que nem todas as definições *Foreigner* podem ser totalmente substituídas pela contraparte
DSL de migração Rails.

O procedimento de migração é o seguinte:

1. remova `gem "foreigner"` do `Gemfile`.
2. execute `bundle install`.
3. execute `bin/rake db:schema:dump`.
4. certifique-se de que `db/schema.rb` contém todas as definições de chave estrangeira com
as opções necessárias.

Upgrading from Rails 4.0 to Rails 4.1
-------------------------------------

### CSRF protection from remote `<script>` tags

Or, "whaaat my tests are failing!!!?" or "my `<script>` widget is busted!!"

Cross-site request forgery (CSRF) protection now covers GET requests with
JavaScript responses, too. This prevents a third-party site from remotely
referencing your JavaScript with a `<script>` tag to extract sensitive data.

This means that your functional and integration tests that use

```ruby
get :index, format: :js
```

will now trigger CSRF protection. Switch to

```ruby
xhr :get, :index, format: :js
```

to explicitly test an `XmlHttpRequest`.

NOTE: Your own `<script>` tags are treated as cross-origin and blocked by
default, too. If you really mean to load JavaScript from `<script>` tags,
you must now explicitly skip CSRF protection on those actions.

### Spring

If you want to use Spring as your application preloader you need to:

1. Add `gem 'spring', group: :development` to your `Gemfile`.
2. Install spring using `bundle install`.
3. Generate the Spring binstub with `bundle exec spring binstub`.

NOTE: User defined rake tasks will run in the `development` environment by
default. If you want them to run in other environments consult the
[Spring README](https://github.com/rails/spring#rake).

### `config/secrets.yml`

If you want to use the new `secrets.yml` convention to store your application's
secrets, you need to:

1. Create a `secrets.yml` file in your `config` folder with the following content:

    ```yaml
    development:
      secret_key_base:

    test:
      secret_key_base:

    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
    ```

2. Use your existing `secret_key_base` from the `secret_token.rb` initializer to
   set the `SECRET_KEY_BASE` environment variable for whichever users running the
   Rails application in production. Alternatively, you can simply copy the existing
   `secret_key_base` from the `secret_token.rb` initializer to `secrets.yml`
   under the `production` section, replacing `<%= ENV["SECRET_KEY_BASE"] %>`.

3. Remove the `secret_token.rb` initializer.

4. Use `rake secret` to generate new keys for the `development` and `test` sections.

5. Restart your server.

### Changes to test helper

If your test helper contains a call to
`ActiveRecord::Migration.check_pending!` this can be removed. The check
is now done automatically when you `require "rails/test_help"`, although
leaving this line in your helper is not harmful in any way.

### Cookies serializer

Applications created before Rails 4.1 uses `Marshal` to serialize cookie values into
the signed and encrypted cookie jars. If you want to use the new `JSON`-based format
in your application, you can add an initializer file with the following content:

```ruby
Rails.application.config.action_dispatch.cookies_serializer = :hybrid
```

This would transparently migrate your existing `Marshal`-serialized cookies into the
new `JSON`-based format.

When using the `:json` or `:hybrid` serializer, you should beware that not all
Ruby objects can be serialized as JSON. For example, `Date` and `Time` objects
will be serialized as strings, and `Hash`es will have their keys stringified.

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

It's advisable that you only store simple data (strings and numbers) in cookies.
If you have to store complex objects, you would need to handle the conversion
manually when reading the values on subsequent requests.

If you use the cookie session store, this would apply to the `session` and
`flash` hash as well.

### Flash structure changes

Flash message keys are
[normalized to strings](https://github.com/rails/rails/commit/a668beffd64106a1e1fedb71cc25eaaa11baf0c1). They
can still be accessed using either symbols or strings. Looping through the flash
will always yield string keys:

```ruby
flash["string"] = "a string"
flash[:symbol] = "a symbol"

# Rails < 4.1
flash.keys # => ["string", :symbol]

# Rails >= 4.1
flash.keys # => ["string", "symbol"]
```

Make sure you are comparing Flash message keys against strings.

### Changes in JSON handling

There are a few major changes related to JSON handling in Rails 4.1.

#### MultiJSON removal

MultiJSON has reached its [end-of-life](https://github.com/rails/rails/pull/10576)
and has been removed from Rails.

If your application currently depends on MultiJSON directly, you have a few options:

1. Add 'multi_json' to your `Gemfile`. Note that this might cease to work in the future

2. Migrate away from MultiJSON by using `obj.to_json`, and `JSON.parse(str)` instead.

WARNING: Do not simply replace `MultiJson.dump` and `MultiJson.load` with
`JSON.dump` and `JSON.load`. These JSON gem APIs are meant for serializing and
deserializing arbitrary Ruby objects and are generally [unsafe](https://ruby-doc.org/stdlib-2.2.2/libdoc/json/rdoc/JSON.html#method-i-load).

#### JSON gem compatibility

Historically, Rails had some compatibility issues with the JSON gem. Using
`JSON.generate` and `JSON.dump` inside a Rails application could produce
unexpected errors.

Rails 4.1 fixed these issues by isolating its own encoder from the JSON gem. The
JSON gem APIs will function as normal, but they will not have access to any
Rails-specific features. For example:

```ruby
class FooBar
  def as_json(options = nil)
    { foo: 'bar' }
  end
end
```

```irb
irb> FooBar.new.to_json
=> "{\"foo\":\"bar\"}"
irb> JSON.generate(FooBar.new, quirks_mode: true)
=> "\"#<FooBar:0x007fa80a481610>\""
```

#### New JSON encoder

The JSON encoder in Rails 4.1 has been rewritten to take advantage of the JSON
gem. For most applications, this should be a transparent change. However, as
part of the rewrite, the following features have been removed from the encoder:

1. Circular data structure detection
2. Support for the `encode_json` hook
3. Option to encode `BigDecimal` objects as numbers instead of strings

If your application depends on one of these features, you can get them back by
adding the [`activesupport-json_encoder`](https://github.com/rails/activesupport-json_encoder)
gem to your `Gemfile`.

#### JSON representation of Time objects

`#as_json` for objects with time component (`Time`, `DateTime`, `ActiveSupport::TimeWithZone`)
now returns millisecond precision by default. If you need to keep old behavior with no millisecond
precision, set the following in an initializer:

```ruby
ActiveSupport::JSON::Encoding.time_precision = 0
```

### Usage of `return` within inline callback blocks

Previously, Rails allowed inline callback blocks to use `return` this way:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { return false } # BAD
end
```

This behavior was never intentionally supported. Due to a change in the internals
of `ActiveSupport::Callbacks`, this is no longer allowed in Rails 4.1. Using a
`return` statement in an inline callback block causes a `LocalJumpError` to
be raised when the callback is executed.

Inline callback blocks using `return` can be refactored to evaluate to the
returned value:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save { false } # GOOD
end
```

Alternatively, if `return` is preferred it is recommended to explicitly define
a method:

```ruby
class ReadOnlyModel < ActiveRecord::Base
  before_save :before_save_callback # GOOD

  private
    def before_save_callback
      return false
    end
end
```

This change applies to most places in Rails where callbacks are used, including
Active Record and Active Model callbacks, as well as filters in Action
Controller (e.g. `before_action`).

See [this pull request](https://github.com/rails/rails/pull/13271) for more
details.

### Methods defined in Active Record fixtures

Rails 4.1 evaluates each fixture's ERB in a separate context, so helper methods
defined in a fixture will not be available in other fixtures.

Helper methods that are used in multiple fixtures should be defined on modules
included in the newly introduced `ActiveRecord::FixtureSet.context_class`, in
`test_helper.rb`.

```ruby
module FixtureFileHelpers
  def file_sha(path)
    OpenSSL::Digest::SHA256.hexdigest(File.read(Rails.root.join('test/fixtures', path)))
  end
end

ActiveRecord::FixtureSet.context_class.include FixtureFileHelpers
```

### I18n enforcing available locales

Rails 4.1 now defaults the I18n option `enforce_available_locales` to `true`. This
means that it will make sure that all locales passed to it must be declared in
the `available_locales` list.

To disable it (and allow I18n to accept *any* locale option) add the following
configuration to your application:

```ruby
config.i18n.enforce_available_locales = false
```

Note that this option was added as a security measure, to ensure user input
cannot be used as locale information unless it is previously known. Therefore,
it's recommended not to disable this option unless you have a strong reason for
doing so.

### Mutator methods called on Relation

`Relation` no longer has mutator methods like `#map!` and `#delete_if`. Convert
to an `Array` by calling `#to_a` before using these methods.

It intends to prevent odd bugs and confusion in code that call mutator
methods directly on the `Relation`.

```ruby
# Instead of this
Author.where(name: 'Hank Moody').compact!

# Now you have to do this
authors = Author.where(name: 'Hank Moody').to_a
authors.compact!
```

### Changes on Default Scopes

Default scopes are no longer overridden by chained conditions.

In previous versions when you defined a `default_scope` in a model
it was overridden by chained conditions in the same field. Now it
is merged like any other scope.

Before:

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

After:

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'inactive'
```

To get the previous behavior it is needed to explicitly remove the
`default_scope` condition using `unscoped`, `unscope`, `rewhere` or
`except`.

```ruby
class User < ActiveRecord::Base
  default_scope { where state: 'pending' }
  scope :active, -> { unscope(where: :state).where(state: 'active') }
  scope :inactive, -> { rewhere state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active'

User.inactive
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

### Rendering content from string

Rails 4.1 introduces `:plain`, `:html`, and `:body` options to `render`. Those
options are now the preferred way to render string-based content, as it allows
you to specify which content type you want the response sent as.

* `render :plain` will set the content type to `text/plain`
* `render :html` will set the content type to `text/html`
* `render :body` will *not* set the content type header.

From the security standpoint, if you don't expect to have any markup in your
response body, you should be using `render :plain` as most browsers will escape
unsafe content in the response for you.

We will be deprecating the use of `render :text` in a future version. So please
start using the more precise `:plain`, `:html`, and `:body` options instead.
Using `render :text` may pose a security risk, as the content is sent as
`text/html`.

### PostgreSQL json and hstore datatypes

Rails 4.1 will map `json` and `hstore` columns to a string-keyed Ruby `Hash`.
In earlier versions, a `HashWithIndifferentAccess` was used. This means that
symbol access is no longer supported. This is also the case for
`store_accessors` based on top of `json` or `hstore` columns. Make sure to use
string keys consistently.

### Explicit block use for `ActiveSupport::Callbacks`

Rails 4.1 now expects an explicit block to be passed when calling
`ActiveSupport::Callbacks.set_callback`. This change stems from
`ActiveSupport::Callbacks` being largely rewritten for the 4.1 release.

```ruby
# Previously in Rails 4.0
set_callback :save, :around, ->(r, &block) { stuff; result = block.call; stuff }

# Now in Rails 4.1
set_callback :save, :around, ->(r, block) { stuff; result = block.call; stuff }
```

Atualizando do Rails 3.2 para o Rails 4.0
-------------------------------------

Se sua aplicação está em qualquer versão do Rails anterior a 3.2.x, você deve atualizar para o Rails 3.2 antes de tentar atualizar para o Rails 4.0.

As seguintes mudanças são necessárias a atualizar seu aplicativo para Rails 4.0.

### HTTP PATCH

O Rails 4 agora usa `PATCH` como o verbo HTTP primário para atualizações quando um RESTful
`resource` é declarado em `config/routes.rb`. A *action* `update` ainda é usada,
e as solicitações `PUT` continuarão a ser roteadas para a *action* `update` também.
Portanto, se você estiver usando apenas as rotas RESTful padrão, nenhuma alteração precisa ser feita:

```ruby
resources :users
```

```erb
<%= form_for @user do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update
    # Nenhuma mudança necessária; PATCH será preferido e PUT ainda funcionará.
  end
end
```

No entanto, você precisará fazer uma mudança se estiver usando `form_for` para atualizar
um recurso em conjunto com uma rota personalizada usando o verbo HTTP `PUT`:

```ruby
resources :users do
  put :update_name, on: :member
end
```

```erb
<%= form_for [ :update_name, @user ] do |f| %>
```

```ruby
class UsersController < ApplicationController
  def update_name
    # Mudança necessária; form_for tentará usar uma rota PATCH inexistente.
  end
end
```

Se a *action* não estiver sendo usada em uma API pública e você estiver livre para alterar o
verbo HTTP, você pode atualizar sua rota para usar `patch` em vez de `put`:

```ruby
resources :users do
  patch :update_name, on: :member
end
```

Requisições `PUT` para `/users/:id` no Rails 4 são encaminhadas para `update` como estão
hoje. Portanto, se você tiver uma API que recebe solicitações `PUT` reais, ela funcionará.
O roteador também roteia solicitações `PATCH` para `/users/:id` para a *action* `update`.

Se a *action* está sendo usada em uma API pública e você não pode mudar para o verbo HTTP
usado, você pode atualizar seu formulário para usar o método `PUT` no lugar:

```erb
<%= form_for [ :update_name, @user ], method: :put do |f| %>
```

Para mais informações sobre o PATCH e por que essa mudança foi feita, consulte [esta postagem](https://weblog.rubyonrails.org/2012/2/26/edge-rails-patch-is-the-new-primary-http-method -for-updates/)
no blog do Rails.

#### Uma nota sobre os tipos de mídia

A errata para o verbo `PATCH` [especifica que um tipo de mídia 'diff' deve ser
usado com `PATCH`](http://www.rfc-editor.org/errata_search.php?rfc=5789). Um
desses formatos é [JSON Patch](https://tools.ietf.org/html/rfc6902). Enquanto o Rails
não oferece suporte nativo ao JSON Patch, é fácil adicionar suporte:

```ruby
# em seu controller:
def update
  respond_to do |format|
    format.json do
      # executa uma atualização parcial
      @article.update params[:article]
    end

    format.json_patch do
      # realizar mudanças sofisticadas
    end
  end
end
```

```ruby
# config/initializers/json_patch.rb
Mime::Type.register 'application/json-patch+json', :json_patch
```

Como o JSON Patch foi transformado recentemente em um RFC, não há muitas
Bibliotecas Ruby ainda. A `gem` do Aaron Patterson
[hana](https://github.com/tenderlove/hana) é uma dessas, mas não tem
suporte total para as últimas mudanças na especificação.

### Gemfile

O Rails 4.0 removeu o grupo `assets` do `Gemfile`. Você precisaria remover essa
linha de seu `Gemfile` ao atualizar. Você também deve atualizar seu arquivo da
aplicação (em `config/application.rb`):

```ruby
# Requer as gems listadas no Gemfile, incluindo todas as gems que
# você limitou a :test, :development ou :production.
Bundler.require(*Rails.groups)
```

### vendor/plugins

O Rails 4.0 não suporta mais o carregamento de *plugins* de `vendor/plugins`. Você deve substituir quaisquer *plugins*, extraindo-os para *gems* e adicionando-os ao seu `Gemfile`. Se você escolher não torná-los *gems*, você pode movê-los para, digamos, `lib/my_plugin/*` e adicionar um inicializador apropriado em `config/initializers/my_plugin.rb`.

### *Active Record*

* O Rails 4.0 removeu o mapa de identidade do Active Record, devido a [algumas inconsistências com associações](https://github.com/rails/rails/commit/302c912bf6bcd0fa200d964ec2dc4a44abe328a6). Se você o habilitou manualmente em sua aplicação, você terá que remover a seguinte configuração que não tem mais efeito: `config.active_record.identity_map`.

* O método `delete` em associações de coleção agora pode receber argumentos` Integer` ou `String` como ids de registro, além de registros, muito parecido com o método `destroy`. Anteriormente, ele gerava `ActiveRecord::AssociationTypeMismatch` para tais argumentos. Do Rails 4.0 em `delete` automaticamente tenta encontrar os registros que combinam com os ids fornecidos antes de excluí-los.

* No Rails 4.0, quando uma coluna ou tabela é renomeada, os índices relacionados também são renomeados. Se você tiver migrações que renomeiam os índices, eles não serão mais necessários.

* Rails 4.0 mudou `serialized_attributes` e `attr_readonly` apenas para métodos de classe. Você não deve usar os métodos de instância, pois agora está obsoleto. Você deve alterá-los para usar métodos de classe, por exemplo, `self.serialized_attributes` para `self.class.serialized_attributes`.

* Ao usar o codificador padrão, atribuir `nil` a um atributo serializado irá salvá-lo
para o banco de dados como `NULL` em vez de passar o valor `nil` por meio de YAML (`"---\n...\n"`).

* Rails 4.0 removeu os recursos `attr_accessible` e `attr_protected` em favor dos parâmetros fortes (*Strong Parameters*). Você pode usar a [gem Protected Attributes](https://github.com/rails/protected_attributes) para uma atualização mais suave.

* Se não estiver usando *Protected Attributes*, você pode remover todas as opções relacionadas a
esta *gem* como as opções `whitelist_attributes` ou `mass_assignment_sanitizer`.

* O Rails 4.0 requer que os escopos (*scopes*) usem um objeto que pode ser chamado, como Proc ou lambda:

    ```ruby
      scope :active, where(active: true)

      # torna-se
      scope :active, -> { where active: true }
    ```

* O Rails 4.0 tornou o `ActiveRecord::Fixtures` obsoleto em favor do `ActiveRecord::FixtureSet`.

* O Rails 4.0 tornou o `ActiveRecord::TestCase` obsoleto em favor do `ActiveSupport::TestCase`.

* Rails 4.0 descontinuou a API de localização baseada em hash usando o estilo antigo. Isso significa que
  métodos que anteriormente aceitavam "opções para localização" não servem mais. Por exemplo, `Book.find(:all, conditions: {name: '1984'})` foi substituído por `Book.where(name: '1984')`

* Todos os métodos dinâmicos, exceto `find_by_..` e `find_by_...!` Estão obsoletos.
  Veja como você pode lidar com as mudanças:

      * `find_all_by_...`           torna-se `where(...)`.
      * `find_last_by_...`          torna-se `where(...).last`.
      * `scoped_by_...`             torna-se `where(...)`.
      * `find_or_initialize_by_...` torna-se `find_or_initialize_by(...)`.
      * `find_or_create_by_...`     torna-se `find_or_create_by(...)`.

* Observe que `where(...)` retorna uma relação, não um array como os antigos localizadores. Se você precisar de um `Array`, use `where(...).to_a`.

* Esses métodos apesar de equivalentes podem não executar o mesmo SQL da implementação anterior.

* Para reativar os localizadores antigos, você pode usar a [gem activerecord-deprecated_finders](https://github.com/rails/activerecord-deprecated_finders).

* O Rails 4.0 mudou para a tabela de junção (*join*) padrão para relações `has_and_belongs_to_many` para retirar o prefixo comum do nome da segunda tabela. Qualquer relacionamento `has_and_belongs_to_many` existente entre os *models* com um prefixo comum deve ser especificado com a opção `join_table`. Por exemplo:

    ```ruby
    CatalogCategory < ActiveRecord::Base
      has_and_belongs_to_many :catalog_products, join_table: 'catalog_categories_catalog_products'
    end

    CatalogProduct < ActiveRecord::Base
      has_and_belongs_to_many :catalog_categories, join_table: 'catalog_categories_catalog_products'
    end
    ```

* Observe que o prefixo leva os escopos (*scopes*) em consideração também, portanto, as relações entre `Catalog::Category` e `Catalog::Product` ou `Catalog::Category` e `CatalogProduct` precisam ser atualizadas de forma semelhante.

### *Active Resource*

O Rails 4.0 extraiu o *Active Resource* para sua própria *gem*. Se você ainda precisa do recurso, pode adicionar a [gem *Active Resource*](https://github.com/rails/activeresource) em seu `Gemfile`.

### *Active Model*

* O Rails 4.0 mudou a forma como os erros são anexados ao `ActiveModel::Validations::ConfirmationValidator`. Agora, quando as validações de confirmação falham, o erro será anexado a `:#{attribute}_confirmation` ao invés de `attribute`.

* Rails 4.0 mudou o valor padrão de `ActiveModel::Serializers::JSON.include_root_in_json` para `false`. Agora, os *Active Model Serializers* e os objetos *Active Record* têm o mesmo comportamento padrão. Isso significa que você pode comentar ou remover a seguinte opção no arquivo `config/initializers/wrap_parameters.rb`:

    ```ruby
    # Desative o elemento raiz em JSON por padrão.
    # ActiveSupport.on_load(:active_record) do
    #   self.include_root_in_json = false
    # end
    ```

### *Action Pack*

*   Rails 4.0 introduz `ActiveSupport::KeyGenerator` e usa isso como uma base para gerar e verificar *cookies* assinados (entre outras coisas). Os *cookies* assinados existentes gerados com o Rails 3.x serão atualizados de forma transparente se você deixar seu `secret_token` existente e adicionar o novo `secret_key_base`.

    ```ruby
      # config/initializers/secret_token.rb
      Myapp::Application.config.secret_token = 'existing secret token'
      Myapp::Application.config.secret_key_base = 'new secret key base'
    ```

    Observe que você deve esperar para definir `secret_key_base` até ter 100% de sua base de usuários no Rails 4.x e estar razoavelmente certo de que não precisará fazer *rollback* para voltar para o Rails 3.x. Isso ocorre porque os *cookies* assinados com base no novo `secret_key_base` no Rails 4.x não são compatíveis com versões anteriores do Rails 3.x. Você é livre para deixar seu `secret_token` existente no lugar, não definir o novo `secret_key_base` e ignorar os avisos de depreciação até que esteja razoavelmente certo de que sua atualização está completa.

    Se você está contando com a capacidade de aplicações externas ou JavaScript de ler os *cookies* de sessão assinada da sua aplicação Rails (ou *cookies* assinados em geral), você não deve definir `secret_key_base` até que tenha não tenha mais essas preocupações.

*   O Rails 4.0 criptografa o conteúdo de sessões baseadas em *cookies* se `secret_key_base` tiver sido definido. O Rails 3.x assinou, mas não criptografou, o conteúdo da sessão baseada em cookie. Os cookies assinados são "seguros" no sentido de que são verificados se foram gerados pela sua aplicação e são à prova de adulteração. No entanto, o conteúdo pode ser visualizado pelos usuários finais e criptografar o conteúdo elimina essa advertência/preocupação sem uma penalidade de desempenho significativa.

    Leia [Pull Request #9978](https://github.com/rails/rails/pull/9978) para obter detalhes sobre a mudança para *cookies* de sessão criptografada.

* O Rails 4.0 removeu a opção `ActionController::Base.asset_path`. Use o recurso da nova *asset pipeline*.

* O Rails 4.0 tornou a opção `ActionController::Base.page_cache_extension` obsoleta. Use `ActionController::Base.default_static_extension` ao invés.

* O Rails 4.0 removeu o *cache* de *Action* e *Page* do Action Pack. Você precisará adicionar a gem `actionpack-action_caching` para usar `caches_action` e `actionpack-page_caching` para usar `caches_page` em seus *controllers*.

* O Rails 4.0 removeu o analisador de parâmetros XML. Você precisará adicionar a gem `actionpack-xml_parser` se precisar deste recurso.

* O Rails 4.0 muda o conjunto de pesquisa do `layout` padrão usando símbolos ou procs que retornam `nil`. Para obter o comportamento "sem layout", retorne false em vez de `nil`.

* O Rails 4.0 muda o cliente memcached padrão de `memcache-client` para `dalli`. Para atualizar, simplesmente adicione `gem 'dalli'` ao seu` Gemfile`.

* O Rails 4.0 descontinuará em breve os métodos `dom_id` e `dom_class` em *controllers* (eles podem ser usados em *views*). Você precisará incluir o módulo `ActionView::RecordIdentifier` nos *controllers* que requerem este recurso.

* O Rails 4.0 descontinuará em breve a opção `:confirm` para o helper `link_to`. Você deve
em vez disso, usar um atributo de dados (por exemplo, `data: {confirm: 'Are you sure?'}`).
Esta depreciação também diz respeito aos *helpers* baseados neste (como `link_to_if`
ou `link_to_unless`).

* O Rails 4.0 mudou como `assert_generates`, `assert_recognizes` e `assert_routing` funcionam. Agora todas essas asserções geram `Assertion` ao invés de` ActionController::RoutingError`.

*  O Rails 4.0 levanta um `ArgumentError` se rotas nomeadas conflitantes são definidas. Isso pode ser acionado por rotas nomeadas explicitamente definidas ou pelo método `resources`. Aqui estão dois exemplos que conflitam usando o nome `example_path`:

    ```ruby
    get 'one' => 'test#example', as: :example
    get 'two' => 'test#example', as: :example
    ```

    ```ruby
    resources :examples
    get 'clashing/:id' => 'test#example', as: :example
    ```

    No primeiro caso, você pode simplesmente evitar usar o mesmo nome para várias
    rotas. No segundo, você pode usar as opções `only` ou `except` fornecidas pelo
    método `resources` para restringir as rotas criadas conforme detalhado no
    [Guia de roteamento](routing.html #restting-the-routes-created).

*   O Rails 4.0 também mudou a forma como as rotas de caracteres Unicode são definidas. Agora você pode definir rotas de caracteres Unicode diretamente. Se você já usou tais rotas, deve alterá-las, por exemplo:

    ```ruby
    get Rack::Utils.escape('こんにちは'), controller: 'welcome', action: 'index'
    ```

    torna-se

    ```ruby
    get 'こんにちは', controller: 'welcome', action: 'index'
    ```

*   Rails 4.0 requer que as rotas que usam `match` especifiquem o método de solicitação. Por exemplo:

    ```ruby
      # Rails 3.x
      match '/' => 'root#index'

      # torna-se
      match '/' => 'root#index', via: :get

      # ou
      get '/' => 'root#index'
    ```

*   O Rails 4.0 removeu o *middleware* `ActionDispatch::BestStandardsSupport`, `<!DOCTYPE html> `já aciona o modo de padrões de https://msdn.microsoft.com/en-us/library/jj676915(v=vs.85). Os cabeçalhos aspx e ChromeFrame foram movidos para `config.action_dispatch.default_headers`.

    Lembre-se de que você também deve remover todas as referências ao *middleware* do código da sua aplicação, por exemplo:

    ```ruby
    # Levanta exceção
    config.middleware.insert_before(Rack::Lock, ActionDispatch::BestStandardsSupport)
    ```

    Verifique também suas configurações de ambiente por `config.action_dispatch.best_standards_support` e remova-o se houver.

*   Rails 4.0 permite a configuração de cabeçalhos (*headers*) HTTP definindo `config.action_dispatch.default_headers`. Os padrões são os seguintes:

    ```ruby
      config.action_dispatch.default_headers = {
        'X-Frame-Options' => 'SAMEORIGIN',
        'X-XSS-Protection' => '1; mode=block'
      }
    ```

    Observe que se sua aplicação depende do carregamento de certas páginas em um `<frame>` ou `<iframe>`, então você pode precisar definir explicitamente `X-Frame-Options` para `ALLOW-FROM ... `ou `ALLOWALL`.

* No Rails 4.0, os recursos de pré-compilação não copiam mais recursos não JS/CSS automaticamente de `vendor/assets` e `lib/assets`. As pessoas desenvolvedoras de aplicações e *engine* Rails devem colocar esses *assets* em `app/assets` ou configurar [`config.assets.precompile`][].

* No Rails 4.0, o erro `ActionController::UnknownFormat` é gerado quando a *action* não manipula o formato da solicitação. Por padrão, a exceção é tratada respondendo com 406 Não Aceitável, mas você pode substituir isso agora. No Rails 3, 406 Não Aceitável sempre foi retornado. Sem substituições.

* No Rails 4.0, uma exceção genérica `ActionDispatch::ParamsParser::ParseError` é levantada quando `ParamsParser` falha em analisar os parâmetros da solicitação. Você desejará resgatar esta exceção em vez do baixo nível `MultiJson::DecodeError`, por exemplo.

* No Rails 4.0, `SCRIPT_NAME` é devidamente aninhado quando os *engines* são montados em uma aplicação e é servido a partir de um prefixo de URL. Você não precisa mais definir `default_url_options[:script_name]` para contornar os prefixos de URL sobrescritos.

* Rails 4.0 torna obsoleto `ActionController::Integration` em favor de `ActionDispatch :: Integration`.
* Rails 4.0 torna obsoleto `ActionController::IntegrationTest` em favor de `ActionDispatch::IntegrationTest`.
* Rails 4.0 torna obsoleto `ActionController::PerformanceTest` em favor de `ActionDispatch::PerformanceTest`.
* Rails 4.0 torna obsoleto `ActionController::AbstractRequest` em favor de `ActionDispatch::Request`.
* Rails 4.0 torna obsoleto `ActionController::Request` em favor de `ActionDispatch::Request`.
* Rails 4.0 torna obsoleto `ActionController::AbstractResponse` em favor de `ActionDispatch::Response`.
* Rails 4.0 torna obsoleto `ActionController::Response` em favor de `ActionDispatch::Response`.
* Rails 4.0 torna obsoleto `ActionController::Routing` em favor de `ActionDispatch::Routing`.

[`config.assets.precompile`]: configuring.html#config-assets-precompile

### *Active Support*

O Rails 4.0 remove o alias `j` para `ERB::Util#json_escape` visto que `j` já é usado para `ActionView::Helpers::JavaScriptHelper#escape_javascript`.

#### *Cache*

The caching method changed between Rails 3.x and 4.0. You should [change the cache namespace](https://guides.rubyonrails.org/caching_with_rails.html#activesupport-cache-store) and roll out with a cold cache.
O método de *cache* mudou entre Rails 3.x e 4.0. Você deve [alterar o *namespace* do *cache*](https://guides.rubyonrails.org/caching_with_rails.html#activesupport-cache-store) e implementar com um *cold cache*.

### Ordem de Carregamento de *Helpers*

A ordem na qual *helpers* de mais de um diretório são carregados mudou no Rails 4.0. Anteriormente, eles eram reunidos e classificados em ordem alfabética. Após atualizar para o Rails 4.0, os *helpers* irão preservar a ordem dos diretórios carregados e serão classificados em ordem alfabética apenas dentro de cada diretório. A menos que você use explicitamente o parâmetro `helpers_path`, essa mudança só afetará a maneira de carregar os helpers nas *engines*. Se você precisa de uma ordem, deve verificar se os métodos corretos estão disponíveis após a atualização. Se você gostaria de mudar a ordem em que as *engines* são carregados, você pode usar o método `config.railties_order=`.

### *Active Record Observer* e *Action Controller Sweeper*

`ActiveRecord::Observer` e` ActionController::Caching::Sweeper` foram extraídos para a gem `rails-observers`. Você precisará adicionar a *gem* `rails-observers` se precisar desses recursos.

### sprockets-rails

* `assets:precompile:primary` e` assets:precompile:all` foram removidos. Em vez disso, use `assets:precompile`.
* A opção `config.assets.compress` deve ser alterada para [`config.assets.js_compressor`][] como por exemplo:

    ```ruby
    config.assets.js_compressor = :uglifier
    ```

[`config.assets.js_compressor`]: configuring.html#config-assets-js-compressor

### sass-rails

* `asset-url` com dois argumentos está deprecado. Por exemplo: `asset-url("rails.png", image)` torna-se `asset-url("rails.png")`.

Atualizando do Rails 3.1 para o Rails 3.2
-------------------------------------

Se sua aplicação está atualmente em qualquer versão do Rails anterior a 3.1.x, você
deve atualizar para o Rails 3.1 antes de tentar uma atualização para o Rails 3.2.

As seguintes mudanças são destinadas a atualizar sua aplicação para a mais recente
versão 3.2.x do Rails.

### Gemfile

Faça as seguintes alterações em seu `Gemfile`.

```ruby
gem 'rails', '3.2.21'

group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
end
```

### config/environments/development.rb

Existem algumas novas definições de configuração que você deve adicionar ao seu ambiente de desenvolvimento:

```ruby
# Levantar exceção na proteção de atribuição em massa para models Active Record
config.active_record.mass_assignment_sanitizer = :strict

# Registrar o log da query para consultas que ocupem mais do que isso (funciona
# com SQLite, MySQL e PostgreSQL)
config.active_record.auto_explain_threshold_in_seconds = 0.5
```

### config/environments/test.rb

A definição de configuração `mass_assignment_sanitizer` também deve ser adicionada a`config/environment/test.rb`:

```ruby
# Levantar exceção na proteção de atribuição em massa para models Active Record
config.active_record.mass_assignment_sanitizer = :strict
```

### vendor/plugins

O Rails 3.2 depreca `vendor/plugins` e o Rails 4.0 irá removê-los completamente. Embora não seja estritamente necessário como parte de uma atualização do Rails 3.2, você pode começar a substituir quaisquer *plugins*, extraindo-os para *gems* e adicionando-os ao seu `Gemfile`. Se você escolher não torná-los *gems*, você pode movê-los para, digamos, `lib/my_plugin/*` e adicionar um inicializador apropriado em `config/initializers/my_plugin.rb`.

### Active Record

A opção `:dependent =>: restrict` foi removida de `belongs_to`. Se você quiser evitar a exclusão do objeto se houver algum objeto associado, você pode definir `:dependent => :destroy` e retornar `false` após verificar a existência de associação de qualquer retorno de chamada de destruição do objeto associado.

Atualizando do Rails 3.0 para o Rails 3.1
-------------------------------------

Se sua aplicação estiver em qualquer versão do Rails anterior a 3.0.x, você deve atualizar para o Rails 3.0 antes de tentar uma atualização para o Rails 3.1.

As seguintes mudanças são destinadas para atualizar sua aplicação para o Rails 3.1.12, a última versão 3.1.x do Rails.

### Gemfile

Faça as seguintes mudanças no seu `Gemfile`.

```ruby
gem 'rails', '3.1.12'
gem 'mysql2'

# Necessário para o novo pipeline de assets
group :assets do
  gem 'sass-rails',   '~> 3.1.7'
  gem 'coffee-rails', '~> 3.1.1'
  gem 'uglifier',     '>= 1.0.3'
end

# jQuery é a biblioteca JavaScript padrão no Rails 3.1
gem 'jquery-rails'
```

### config/application.rb

A pipeline de *assets* requer as seguintes adições:

```ruby
config.assets.enabled = true
config.assets.version = '1.0'
```

Se sua aplicação estiver usando uma rota "/assets" para um `resource`, você pode querer alterar o prefixo usado para *assets* para evitar conflitos:

```ruby
# O padrão é '/assets'
config.assets.prefix = '/asset-files'
```

### config/environments/development.rb

Remova a configuração RJS `config.action_view.debug_rjs = true`.

Adicione essas configurações se você habilitar a pipeline de *assets*:

```ruby
# Não comprimir os assets
config.assets.compress = false

# Expande as linhas que carregam os assets
config.assets.debug = true
```

### config/environments/production.rb

Novamente, a maioria das mudanças abaixo são para a pipeline de *assets*. Você pode ler mais sobre isso no guia [Asset Pipeline](asset_pipeline.html).

```ruby
# Comprime JavaScripts e CSS
config.assets.compress = true

# Não use a compilação da pipeline de assets se um ativo pré-compilado for perdido
config.assets.compile = false

# Gera uma URLs especifica para assets
config.assets.digest = true

# O padrão é Rails.root.join("public/assets")
# config.assets.manifest = YOUR_PATH

# Pré-compilar recursos adicionais (application.js, application.css e todos os não JS/CSS já foram adicionados)
# config.assets.precompile += %w( admin.js admin.css )

# Force todo o acesso da aplicação por SSL, use Strict-Transport-Security e use cookies seguros.
# config.force_ssl = true
```

### config/environments/test.rb

Você pode ajudar a testar o desempenho com estas adições ao seu ambiente de teste:

```ruby
# Configure o servidor de ativos estáticos para testes com Cache-Control para melhor performance
config.public_file_server.enabled = true
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=3600'
}
```

### config/initializers/wrap_parameters.rb

Adicione este arquivo com o seguinte conteúdo, se desejar agrupar os parâmetros em um *hash* aninhado. Isso está ativado por padrão em novas aplicações.

```ruby
# Certifique-se de reiniciar o servidor ao modificar este arquivo.
# Este arquivo contém configurações para ActionController::ParamsWrapper que
# está habilitado por padrão.

# Habilite o agrupamento de parâmetros para JSON. Você pode desabilitar isso configurando: format para um array vazio.
ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json]
end

# Desative o elemento raiz em JSON por padrão.
ActiveSupport.on_load(:active_record) do
  self.include_root_in_json = false
end
```

### config/initializers/session_store.rb

Você precisa alterar sua chave de sessão para algo novo ou remover todas as sessões:

```ruby
# em config/initializers/session_store.rb
AppName::Application.config.session_store :cookie_store, key: 'SOMETHINGNEW'
```

or

```bash
$ bin/rake db:sessions:clear
```

### Remover opções de :cache e :concat em referências de *helpers* para *assets* em *views*

* Com a *Asset Pipeline*, as opções :cache e :concat não são mais usadas, exclua essas opções de suas *views*.
