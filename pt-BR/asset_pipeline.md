**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

O *Asset Pipeline*
==================

Este guia aborda o *asset pipeline*.

Depois de ler este guia, você saberá:

* O que o *asset pipeline* é e o que ele faz.
* Como organizar apropriadamente seus *assets* da aplicação.
* Os benefícios do *asset pipeline*.
* Como adicionar um pré-processador ao *pipeline*.
* Como empacotar os *assets* com uma *gem*.

--------------------------------------------------------------------------------

O que é o *Asset Pipeline*?
---------------------------

O *asset pipeline* fornece um *framework* para concatenar e minificar ou comprimir
*assets* JavaScript e CSS. Ele também tem a habilidade de escrever esses *assets* em
outras linguagens e pré-processadores tais como CoffeeScript, Sass e ERB.
Isso permite que os *assets* da sua aplicação sejam automaticamente combinados com
*assets* de outras *gems*.

O *asset pipeline* é implementado pela *gem*
[sprockets-rails](https://github.com/rails/sprockets-rails),
e é habilitado por padrão. Você pode desabilitar enquanto está criando uma nova aplicação
passando a opção `--skip-sprockets`.

```bash
rails new appname --skip-sprockets
```

O Rails automaticamente adiciona a *gem* `sass-rails` no seu `Gemfile`, o qual é
usado pelo Sprockets para comprimir o *asset*:

```ruby
gem 'sass-rails'
```

Usando a opção `--skip-sprockets` previnirá que o Rails adicione ao seu `Gemfile`,
então se mais tarde você quiser habilitar o *asset pipeline* você terá que adicionar
essas *gems* ao seu `Gemfile`. Além disso, criando uma aplicação com a opção `--skip-sprockets`
gerará um arquivo `config/application.rb` levemente diferente, com a declaração de requerimento
para o *sprockets* que está comentado. Você terá de remover o operador de comentário nessa linha
para depois habilitar o *asset pipeline*:

```ruby
# require "sprockets/railtie"
```

Para configurar os métodos de compactação do *asset*, coloque as opções de configuração
apropriadas no `production.rb` - `config.assets.css_compressor` para o seu CSS e
`config.assets.js_compressor` para seu JavaScript:

```ruby
config.assets.css_compressor = :yui
config.assets.js_compressor = :uglifier
```

NOTE: A *gem* `sass-rails` é automaticamente usada para a compactação de CSS se estiver
incluída no `Gemfile` e nenhuma opção `config.assets.css_compressor` é definida.


### Principais Características

A primeira característica do *pipeline* é concatenar os *assets*, o qual pode
reduzir o número de requisições que o navegador faz para renderizar uma página web.
Os navegadores web são limitados no número de requisições que eles podem fazer em paralelo,
portanto, menos solicitações podem significar carregamento mais rápido de sua aplicação.

O *Sprockets* concatena todos os arquivos JavaScript em um arquivo principal `.js` e todos
os arquivos CSS em um arquivo principal `.css`. Como você aprenderá mais tarde neste guia,
você pode mudar esta estratégia para agrupar arquivos da maneira que quiser. Em produção,
o Rails insere uma impressão digital SHA256 dentro de cada nome de arquivo para que o arquivo
seja armazenado em cache no navegador. Você pode invalidar o armazenamento *cache* alterando essa
impressão digital, o qual acontece automaticamente sempre que você muda o conteúdo do arquivo.

A segunda característica do *asset pipeline* é a minificação ou compactação do *asset*.
Para arquivos CSS, isso é feito removendo espaços em branco e comentários. Para JavaScript,
mais processos complexos são aplicados. Você pode escolher entre um conjunto de opções ou
especificar a sua própria.

A terceira característica do *asset pipeline* é que permite a codificação dos
*assets* por meio de uma línguagem de alto nível, com pré-compilação até os
atuais *assets*. Línguagens suportadas incluem Sass para CSS, CoffeeScript para
JavaScript, e ERB para ambos por padrão.

### O que é Impressão Digital e Por Que Eu Deveria Me Importar?

Impressão digital é uma técnica que faz o nome do arquivo dependente do conteúdo
do arquivo. Quando o conteúdo do arquivo muda, o nome do arquivo muda também.
Para o conteúdo estático ou que muda com pouca frequência, ele tem uma forma
mais fácil para dizer se duas versões do arquivo são idênticas, mesmo através
de diferentes servidores ou datas de desenvolvimento.

Quando o nome do arquivo é único e baseado no seu conteúdo, os *headers* HTTP
podem ser configurados para encorajar armazenamento *caches* em todo lugar (seja
em CDNs, em ISPs, nos equipamentos de rede, ou nos navegadores web) para manter
suas próprias cópias do conteúdo. Quando o conteúdo é atualizado, a impressão digital
mudará. Isso fará com que os clientes remotos requisitem uma nova cópia do conteúdo.
Isso é geralmente conhecido como _cache busting_.

A técnica que o *Sprockets* usa para impressão digital é inserir um *hash* do
conteúdo no nome, geralmente no final. Por exemplo o arquivo CSS `global.css`

```
global-908e25f4bf641868d8683022a5b62f54.css
```

Essa é a estratégia adotada pelo *asset pipeline* do Rails.

A antiga estratégia do Rails era anexar uma *Query String*(string de consulta) baseada em data
para cada *asset* vinculado com um *helper* interno. Em resumo o código gerado
parecia com isso:

```
/stylesheets/global.css?1309495796
```

A estratégia de *Query String*(string de consulta) tinha várias desvantagens:

1. **Nem todos os *caches* irão armazenar o conteúdo onde o nome do arquivo se
diferencia apenas por parâmetros de busca**

    [recommendação do Steve Souders](https://www.stevesouders.com/blog/2008/08/23/revving-filenames-dont-use-querystring/),
 "...Evitando uma *Query String*(string de consulta) para recursos de armazenamento de *cache*".
Ele descobriu que nesse caso 5-20% das requisições não irão ser armazenadas em cache.
*Query String*(string de consulta) em particular nem sempre funcionam com alguns CDNs por invalidação de cache.

2. **O nome do arquivo pode mudar entre nós em ambientes de multi-servidores.**

    A *Query String*(string de consulta) padrão no Rails 2.x é baseada na data de modificação dos
arquivos. Quando os *assets* são implantados em um *cluster*, não há garantia que o
*timestamps* será o mesmo, resultando em diferentes valores sendo usados dependendo
de qual servidor lida com a requisição.

3. **Muita invalidação de cache**

    Quando *assets* estáticos são implementados com novas versões de código, o *mtime*
(horário da última modificação) de _todos_ esses arquivos muda, forçando todos
os clientes remotos a encontrarem eles de novo, mesmo quando o conteúdo desses
*assets* não mudaram.

A Impressão digital resolve esses problemas evitando *Query String*(string de consulta), e garantindo
que o nome dos arquivos sejam coerentes com base no seu conteúdo.

A impressão digital é habilitada por padrão para ambos os ambientes desenvolvimento e
produção. Você pode habilitar ou desabilitar isso na sua configuração através da opção
`config.assets.digest`.

Mais leitura:

* [Otimizar o armazenamento cache](https://developers.google.com/speed/docs/insights/LeverageBrowserCaching)
* [Acelerando nome dos arquivos: não use *Query String*(string de consulta)](http://www.stevesouders.com/blog/2008/08/23/revving-filenames-dont-use-querystring/)


Como usar o *Asset Pipeline*
----------------------------

Nas versões anteriores do Rails, todos os *assets* estavam localizados nos subdiretórios
abaixo de `public`, como `imagens`, `javascripts` and `stylesheets`. Com o *asset pipeline*,
a localização recomendada para esses *assets* é agora o diretório `app/assets`.
Arquivos nesse diretório serão servidos pelo *Sprockets middleware*.

Os *assets* podem ainda ser colocados na hierarquia do `public`. Qualquer *asset* sob
`public` ainda será servido como um arquivo estático pela aplicação ou servidor *web* quando
`config.public_file_server.enabled` estiver configurado como *true*. Você deve usar o 
`app/assets` para arquivos que devem ser pré-processados antes de serem servidos.

Em produção, o Rails pré-compila esses arquivos para `public/assets` por padrão.
As cópias dos arquivos pré-compilados serão então servidas como *assets* estáticos
pelo servidor *web*. Os arquivos em `app/assets` nunca serão servidos diretamente em produção.

### *Assets* Específicos de *Controllers*

Quando você gera um *scaffold* ou um *controller*, o Rails também  gera um
arquivo *Cascading Style Sheet* (ou SCSS se o `sass-rails` estiver no `Gemfile`)
para aquele *controller*. Adicionalmente, quando você gera um *scaffold*, o Rails
também gera o arquivo `scaffolds.css` (ou `scaffolds.scss` se o `sass-rails` 
estiver no `Gemfile`.)

Por exemplo, se você gerar um `ProjectsController`, o Rails também adicionará um novo
arquivo em `app/assets/stylesheets/projects.scss`. Por padrão, os arquivos estarão prontos
para serem usados pela sua aplicação imediatamente usando a diretiva `require_tree`.
Veja [Arquivos de Manifesto e Diretivas](#manifest-files-and-directives) para mais detalhes
sobre `require_tree`.

Você também pode optar por incluir *stylesheets* específicas do *controller* e
arquivos JavaScript apenas nos seus respectivos diretórios, usando o seguinte:

`<%= javascript_include_tag params[:controller] %>` ou `<%= stylesheet_link_tag
params[:controller] %>`

Ao fazer isso, certifique-se de que você não está usando a diretiva `require_tree`,
pois isso resultará em seus *assets* serem incluídos mais de uma vez.

WARNING: Ao usar pré-compilação de *assets*, você precisará certificar-se de que 
seus *assets* dos *controllers* sejam pré-compilados quando carregá-los por página.
Por padrão, arquivos `.coffee` e `.scss` não serão pré-compilados por conta própria.
Veja [Pré-compilando *Assets*](#precompiling-assets) para mais informações sobre
como a pré-compilação funciona.

NOTE: Você deve ter uma *runtime* de ExecJS para usar CoffeeScript.
Se você estiver usando macOS ou Windows, você deve ter uma *runtime* de JavaScript instalada 
no seu sistema operacional. Veja a documentação do [ExecJS](https://github.com/rails/execjs#readme) para conhecer todas as JavaScript *runtimes*.

Você também pode desabilitar a geração de arquivos de *assets* específicos dos *controllers* 
adicionando o seguinte à sua configuração `config/application.rb`:

```ruby
  config.generators do |g|
    g.assets false
  end
```

### Organização dos *Assets*

Os *pipeline assets* podem ser colocados dentro de uma aplicação nos três locais seguintes:
`app/assets`, `lib/assets` ou `vendor/assets`.

* `app/assets` é destinado aos *assets* que são proprietários da aplicação, como
imagens customizadas, arquivos JavaScript ou folhas de estilo.

* `lib/assets` é destinado ao código das suas próprias bibliotecas que não se encaixam
no escopo da aplicação ou àquelas bibliotecas que são compartilhadas entre aplicações.

* `vendor/assets` é destinado aos *assets* que são de propriedade de entidades externas,
como código para *plugins* de JavaScript e *frameworks* de CSS. Tenha em mente que códigos
de terceiros com referências à outros arquivos também processados pelo *asset Pipeline*
(imagens, folhas de estilo, etc.), terão que ser reescritos para usarem auxiliares como `asset_path`.

#### Caminhos de Busca

Quando um arquivo é referenciado a partir de um manifesto ou um *helper*, o *Sprockets* procura
por ele em três locais padrões de *assets*.

Os três locais padrões são: os diretórios `images`, `javascripts` e `stylesheets`
abaixo da pasta `app/assets`, mas esses subdiretórios não são especiais - qualquer caminho
sob `assets/*` será pesquisado.

Por exemplo, esses arquivos:

```
app/assets/javascripts/home.js
lib/assets/javascripts/moovinator.js
vendor/assets/javascripts/slider.js
vendor/assets/somepackage/phonebox.js
```

poderiam ser referenciados em um manifesto da seguinte maneira:

```js
//= require home
//= require moovinator
//= require slider
//= require phonebox
```

Os *assets* dentro dos subdiretórios também podem ser acessados.

```
app/assets/javascripts/sub/something.js
```

é referenciado como:

```js
//= require sub/something
```

Você pode visualizar o caminho de busca inspecionando
`Rails.application.config.assets.paths` no *console* do Rails.

Adicionalmente, além do caminho padrão `assets/*`, caminhos (completos)
podem ser adicionados ao *pipeline* em `config/initializers/assets.rb`. Por exemplo:

```ruby
Rails.application.config.assets.paths << Rails.root.join("lib", "videoplayer", "flash")
```

Os caminhos são percorridos na ordem em que eles aparecem no caminho de busca. Por padrão,
isso significa que os arquivos em `app/assets` tem precedência, e mascararão caminhos
correspondentes em `lib` e `vendor`.

É importante notar que os arquivos que você quiser referenciar fora de um manifesto devem
ser adicionados ao *array* de pré-compilação, caso contrário eles não estarão disponíveis
no ambiente de produção.

#### Usando Índices de Arquivos

O *Sprockets* usa arquivos nomeados como `index` (com a extensão relevante) para um propósito
especial.

Por exemplo, ser você tiver uma biblioteca jQuery com muitos módulos, que é armazenada em
`lib/assets/javascripts/library_name`, o arquivo `lib/assets/javascripts/library_name/index.js` serve como
manifesto para todos os arquivos desta biblioteca. Esse arquivo poderia incluir uma lista de
ordenada de todos os arquivos necessários ou uma simples diretiva `require_tree`.

A biblioteca como um todo pode ser acessada no manifesto da aplicação como:

```js
//= require library_name
```

Isso simplifica a manutenção e mantém as coisas limpas, permitindo que o código relacionado
seja agrupado antes da inclusão em outro lugar.

### Codificando *Links* para *Assets*

O *Sprockets* não adiciona nenhum método para acessar seus *assets* - você ainda usa
as familiares `javascript_include_tag` e `stylesheet_link_tag`:

```erb
<%= stylesheet_link_tag "application", media: "all" %>
<%= javascript_include_tag "application" %>
```

Se você estiver usando a *gem turbolinks*, que é incluída por padrão no Rails, então
inclua a opção 'data-turbolinks-track' que faz com que a turbolinks verifique se um *asset*
foi atualizado e então o carrega naquela página:

```erb
<%= stylesheet_link_tag "application", media: "all", "data-turbolinks-track" => "reload" %>
<%= javascript_include_tag "application", "data-turbolinks-track" => "reload" %>
```

Em *views* comuns você pode acessar imagens no diretório `app/assets/images`
como essa:

```erb
<%= image_tag "rails.png" %>
```

Se o *pipeline* estiver ativo na sua aplicação (e não desativado no contexto
do ambiente atual), esse arquivo é servido pelo *Sprockets*. Se um arquivo
existir em `public/assets/rails.png` ele é servido pelo servidor *web*.

Alternativamente, uma requisição para um arquivo com um *hash* SHA256 como
`public/assets/rails-f90d8a84c707a8dc923fca1ca1895ae8ed0a09237f6992015fef1e11be77c023.png`
é tratado da mesma maneira. A forma como esses *hashes* são gerados está coberta na seção
[Em Produção](#in-production), posteriormente nesse guia.

O *Sprockets* procurará através dos caminhos especificados em `config.assets.paths`,
que inclui os caminhos padrões da aplicação e quaisquer caminhos adicionados pelas *engines*
do Rails.

As imagens também podem ser organizadas em subdiretórios se necessário, e então
podem ser acessadas pelo nome do diretório na tag:

```erb
<%= image_tag "icons/rails.png" %>
```

WARNING: Se você estiver pré-compilando seus *assets* (veja [Em Produção](#in-production)
abaixo), fazer um *link* com um *asset* que não exista irá levantar uma *exception* 
na página chamadora. O mesmo vale se for especificado um *link* para uma *string* em branco.
Portanto, tenha cautela ao usar a `image_tag` e os outros *helpers* com dados informados pelos usuários.

#### CSS e ERB

O *asset pipeline* avalia automaticamente o ERB. Isso significa que se você adicionar
uma extensão `erb` a um *asset* CSS (por exemplo, `application.css.erb`), então
*helpers* como `asset_path` estarão disponíveis nas suas regras de CSS:

```css
.class { background-image: url(<%= asset_path 'image.png' %>) }
```

Isso escreve o caminho ao *asset* em particular que está sendo referenciado. Nesse exemplo,
faria sentido ter uma imagem em um dos caminhos carregados de *assets*, como 
`app/assets/images/image.png`, que seria referenciado aqui. Se essa imagem já está
disponível em `public/assets` como um arquivo com uma impressão digital, então aquele caminho
é referenciado.

Se você quiser usar [URI de dados](https://en.wikipedia.org/wiki/Data_URI_scheme) -
um método para embutir a imagem diretamente no arquivo de CSS - você pode usar
o *helper* `asset_data_uri`.

```css
#logo { background: url(<%= asset_data_uri 'logo.png' %>) }
```

Isso insere uma URI de dados corretamente formatada no CSS fonte.

Note que a tag de fechamento não pode ser do estilo `-%>`.

#### CSS e Sass

Ao utilizar o *asset pipeline*, os caminhos para os *assets* devem ser reescritos e
o `sass-rails` provê os *helpers* `-url` e `-path` (hifenizados em Sass,
separados por *underscore* em Ruby) para as seguintes classes de *assets*:
imagem, fonte, vídeo, áudio, JavaScript e folha de estilo.

* `image-url("rails.png")` returns `url(/assets/rails.png)`
* `image-path("rails.png")` returns `"/assets/rails.png"`

A forma mais genérica também pode ser usada:

* `asset-url("rails.png")` retorna `url(/assets/rails.png)`
* `asset-path("rails.png")` retorna `"/assets/rails.png"`

#### JavaScript/CoffeeScript e ERB

Se você adicionar uma extensão `erb` a um *asset* JavaScript, fazendo algo como
`application.js.erb`, você pode então usar o *helper* `asset_path` no seu
código JavaScript:

```js
$('#logo').attr({ src: "<%= asset_path('logo.png') %>" });
```

Isso escreve o caminho ao *asset* em particular que está sendo referenciado.

Similarmente, você pode usar o *helper* `asset_path` em arquivos CoffeeScript com
a extensão `erb` (i.e., `application.coffee.erb`).

```js
$('#logo').attr src: "<%= asset_path('logo.png') %>"
```

### Arquivos de Manifesto e Diretivas

O *Sprockets* usa arquivos de manifesto para determinar quais *assets* incluir e servir.
Esses arquivos de manifesto contém _diretivas_ - instruções que dirão ao *Sprockets*
quais arquivos solicitar para construir um arquivo CSS ou JavaScript único. Com
essas diretivas, o *Sprockets* carrega os arquivos especificados, processa-os se
necessário, concatena-os com em único arquivo e então comprime-os (baseado no valor
de `Rails.application.config.assets.js_compressor`). Ao servir um arquivo 
ao invés de muitos, o tempo de carregamento das páginas pode ser amplamente reduzido
porque o navegador faz menos requisições. A compressão também reduz o tamanho dos arquivos,
permitindo ao navegador baixá-los mais rapidamente.

Por exemplo, com um arquivo `app/assets/javascripts/application.js` contendo as
seguintes linhas:

```js
// ...
//= require rails-ujs
//= require turbolinks
//= require_tree .
```

Nos arquivos JavaScript, as diretivas do Sprocket começam com `//=`. No caso acima,
o arquivo está usando as diretivas `require` e `require_tree`. A diretiva `require`
é usada para instruir o *Sprockets* dos arquivos que você deseja solicitar. Aqui, você
está solicitando os arquivos `rails-ujs.js` e `turbolinks.js`, que estão disponíveis em
algum lugar no caminho de busca do *Sprockets*. Você não precisa informar as extensões
explicitamente. O *Sprockets* assume que você está solicitando um arquivo `.js` quando
feito de dentro de um arquivo `.js`.

A diretiva `require_tree` instrui ao *Sprockets* para recursivamente incluir _todos_
os arquivos JavaScript no diretório especificado no *output*. Esses caminhos
deverão ser especificados de maneira relativa ao arquivo de manifesto. Você também
pode usar a diretiva `require_directory`, que inclui todos os arquivos JavaScript
somente do diretório especificado, sem recursão.

As diretivas são processadas de cima para baixo, mas a ordem na qual os arquivos
são incluídos pelo `require_tree` não é garantida. Você não deve confiar em
nenhuma ordem particular entre eles. Se você precisar garantir que um JavaScript
em particular termine acima de outro no arquivo concatenado, solicite o pré-requisito
antes no manifesto. Note que a família de diretivas `require` previne arquivos de
serem incluídos duas vezes no *output*.

O Rails também cria um arquivo padrão `app/assets/stylesheets/application.css`
que contém essas linhas:

```css
/* ...
*= require_self
*= require_tree .
*/
```

O Rails cria o `app/assets/stylesheets/application.css` independentemente se
a opção --skip-sprockets é usada ao criar uma nova aplicação Rails. Isso permite
que você facilmente adicione o *asset pipelining* mais tarde se assim o quiser.

As diretivas que funcionam nos arquivos JavaScript também funcionam nas folhas de estilo
(que obviamente incluem folhas de estilo além de arquivos JavaScript). A diretiva
`require_tree` em um manifesto CSS funciona da mesma maneira que no JavaScript,
solicitando todas as folhas de estilo do diretório corrente.

Nesse exemplo, `require_self` é usado. Isso coloca o CSS contido dentro do 
arquivo (se houver algum) na localização exata da chamada `require_self`.

NOTE. Se você quiser usar múltiplos arquivos Saas, você deve, via de regra, usar a [regra Sass `@import`](https://sass-lang.com/docs/yardoc/file.SASS_REFERENCE.html#import)
ao invés de usar as diretivas *Sprockets*. Quando usando as diretivas Saas, arquivos Saas existem dentro de seu próprio
escopo, tornando variáveis ou mixins apenas disponíveis dentro do documento nas quais foram definidas.

Você pode fazer *globbing* dos arquivos usando `@import "*"` e `@import "**/*"` para adicionar a árvore completa, que é equivalente a como o `require_tree` funciona. Veja a [documentação do sass-rails](https://github.com/rails/sass-rails#features) para mais informações e ressalvas importantes.

Você pode ter quantos arquivos de manifesto quiser. Por exemplo, os manifestos
`admin.css` e `admin.js` podem conter os arquivos JS e CSS que são usados pela
seção de *admin* de uma aplicação.

As mesmas afirmações sobre ordens feitas acima também se aplicam. Em particular, você
pode especificar arquivos individuais e eles serão compilados na ordem especificada.
Por exemplo, você pode concatenar três arquivos CSS juntos da seguinte maneira:

```js
/* ...
*= require reset
*= require layout
*= require chrome
*/
```

### Pré-processamento

As extensões de arquivos usadas em um *asset* determinam qual pré-processamento é aplicado.
Quando um *controller* ou um *scaffold* é gerado com o gemset padrão do Rails, um arquivo
CoffeeScript e um arquivo SCSS são gerados no lugar de um arquivo comum de JavaScript e CSS.
O exemplo usado anteriormente era um *controller* chamado "*projects*", que gerou um
arquivo `app/assets/stylesheets/projects.scss`.

Em modo de desenvolvimento, se o *asset pipeline* estiver desabilitado, quando esses
arquivos são solicitados, eles serão processados pelos *processors* especificados
pelas gems de `coffee-script` e `sass` e então enviados de volta ao navegador como
JavaScript e CSS respectivamente. Quando o *asset pipelining* está habilitado, esses
arquivos são pré-processados e colocados no diretório `public/assets`, para serem servidos
seja pela aplicação Rails ou pelo servidor *web*.

Camadas adicionais de pré-processamento podem ser solicitadas ao se adicionar outras extensões,
onde cada extensão é processada da direita para a esquerda. Essas devem ser usadas para que
o processamento seja aplicado. Por exemplo, uma folha de estilos chamada
`app/assets/stylesheets/projects.scss.erb` é primeiramente processada como ERB,
depois como SCSS e finalmente servida como CSS. O mesmo se aplica a um arquivo JavaScript -
`app/assets/javascripts/projects.coffee.erb`, que é processado como ERB, depois CoffeeScript
e então servido como JavaScript.

Tenha em mente que a ordem desses pré-processadores é importante. Por exemplo, se
você chamou seu arquivo JavaScript de `app/assets/javascripts/projects.erb.coffee`,
então ele seria processado pelo interpretador do CoffeeScript primeiro, que não
entende ERB, o que te causaria problemas.


In Development
--------------

In development mode, assets are served as separate files in the order they are
specified in the manifest file.

This manifest `app/assets/javascripts/application.js`:

```js
//= require core
//= require projects
//= require tickets
```

would generate this HTML:

```html
<script src="/assets/core.js?body=1"></script>
<script src="/assets/projects.js?body=1"></script>
<script src="/assets/tickets.js?body=1"></script>
```

The `body` param is required by Sprockets.

### Raise an Error When an Asset is Not Found

If you are using sprockets-rails >= 3.2.0 you can configure what happens
when an asset lookup is performed and nothing is found. If you turn off "asset fallback"
then an error will be raised when an asset cannot be found.

```ruby
config.assets.unknown_asset_fallback = false
```

If "asset fallback" is enabled then when an asset cannot be found the path will be
output instead and no error raised. The asset fallback behavior is disabled by default.

### Turning Digests Off

You can turn off digests by updating `config/environments/development.rb` to
include:

```ruby
config.assets.digest = false
```

When this option is true, digests will be generated for asset URLs.

### Turning Debugging Off

You can turn off debug mode by updating `config/environments/development.rb` to
include:

```ruby
config.assets.debug = false
```

When debug mode is off, Sprockets concatenates and runs the necessary
preprocessors on all files. With debug mode turned off the manifest above would
generate instead:

```html
<script src="/assets/application.js"></script>
```

Assets are compiled and cached on the first request after the server is started.
Sprockets sets a `must-revalidate` Cache-Control HTTP header to reduce request
overhead on subsequent requests - on these the browser gets a 304 (Not Modified)
response.

If any of the files in the manifest have changed between requests, the server
responds with a new compiled file.

Debug mode can also be enabled in Rails helper methods:

```erb
<%= stylesheet_link_tag "application", debug: true %>
<%= javascript_include_tag "application", debug: true %>
```

The `:debug` option is redundant if debug mode is already on.

You can also enable compression in development mode as a sanity check, and
disable it on-demand as required for debugging.

In Production
-------------

In the production environment Sprockets uses the fingerprinting scheme outlined
above. By default Rails assumes assets have been precompiled and will be
served as static assets by your web server.

During the precompilation phase an SHA256 is generated from the contents of the
compiled files, and inserted into the filenames as they are written to disk.
These fingerprinted names are used by the Rails helpers in place of the manifest
name.

For example this:

```erb
<%= javascript_include_tag "application" %>
<%= stylesheet_link_tag "application" %>
```

generates something like this:

```html
<script src="/assets/application-908e25f4bf641868d8683022a5b62f54.js"></script>
<link href="/assets/application-4dd5b109ee3439da54f5bdfd78a80473.css" media="screen"
rel="stylesheet" />
```

NOTE: with the Asset Pipeline the `:cache` and `:concat` options aren't used
anymore, delete these options from the `javascript_include_tag` and
`stylesheet_link_tag`.

The fingerprinting behavior is controlled by the `config.assets.digest`
initialization option (which defaults to `true`).

NOTE: Under normal circumstances the default `config.assets.digest` option
should not be changed. If there are no digests in the filenames, and far-future
headers are set, remote clients will never know to refetch the files when their
content changes.

### Precompiling Assets

Rails comes bundled with a command to compile the asset manifests and other
files in the pipeline.

Compiled assets are written to the location specified in `config.assets.prefix`.
By default, this is the `/assets` directory.

You can call this command on the server during deployment to create compiled
versions of your assets directly on the server. See the next section for
information on compiling locally.

The command is:

```bash
$ RAILS_ENV=production rails assets:precompile
```

Capistrano (v2.15.1 and above) includes a recipe to handle this in deployment.
Add the following line to `Capfile`:

```ruby
load 'deploy/assets'
```

This links the folder specified in `config.assets.prefix` to `shared/assets`.
If you already use this shared folder you'll need to write your own deployment
command.

It is important that this folder is shared between deployments so that remotely
cached pages referencing the old compiled assets still work for the life of
the cached page.

The default matcher for compiling files includes `application.js`,
`application.css` and all non-JS/CSS files (this will include all image assets
automatically) from `app/assets` folders including your gems:

```ruby
[ Proc.new { |filename, path| path =~ /app\/assets/ && !%w(.js .css).include?(File.extname(filename)) },
/application.(css|js)$/ ]
```

NOTE: The matcher (and other members of the precompile array; see below) is
applied to final compiled file names. This means anything that compiles to
JS/CSS is excluded, as well as raw JS/CSS files; for example, `.coffee` and
`.scss` files are **not** automatically included as they compile to JS/CSS.

If you have other manifests or individual stylesheets and JavaScript files to
include, you can add them to the `precompile` array in `config/initializers/assets.rb`:

```ruby
Rails.application.config.assets.precompile += %w( admin.js admin.css )
```

NOTE. Always specify an expected compiled filename that ends with `.js` or `.css`,
even if you want to add Sass or CoffeeScript files to the precompile array.

The command also generates a `.sprockets-manifest-randomhex.json` (where `randomhex` is
a 16-byte random hex string) that contains a list with all your assets and their respective
fingerprints. This is used by the Rails helper methods to avoid handing the
mapping requests back to Sprockets. A typical manifest file looks like:

```ruby
{"files":{"application-aee4be71f1288037ae78b997df388332edfd246471b533dcedaa8f9fe156442b.js":{"logical_path":"application.js","mtime":"2016-12-23T20:12:03-05:00","size":412383,
"digest":"aee4be71f1288037ae78b997df388332edfd246471b533dcedaa8f9fe156442b","integrity":"sha256-ruS+cfEogDeueLmX3ziDMu39JGRxtTPc7aqPn+FWRCs="},
"application-86a292b5070793c37e2c0e5f39f73bb387644eaeada7f96e6fc040a028b16c18.css":{"logical_path":"application.css","mtime":"2016-12-23T19:12:20-05:00","size":2994,
"digest":"86a292b5070793c37e2c0e5f39f73bb387644eaeada7f96e6fc040a028b16c18","integrity":"sha256-hqKStQcHk8N+LA5fOfc7s4dkTq6tp/lub8BAoCixbBg="},
"favicon-8d2387b8d4d32cecd93fa3900df0e9ff89d01aacd84f50e780c17c9f6b3d0eda.ico":{"logical_path":"favicon.ico","mtime":"2016-12-23T20:11:00-05:00","size":8629,
"digest":"8d2387b8d4d32cecd93fa3900df0e9ff89d01aacd84f50e780c17c9f6b3d0eda","integrity":"sha256-jSOHuNTTLOzZP6OQDfDp/4nQGqzYT1DngMF8n2s9Dto="},
"my_image-f4028156fd7eca03584d5f2fc0470df1e0dbc7369eaae638b2ff033f988ec493.png":{"logical_path":"my_image.png","mtime":"2016-12-23T20:10:54-05:00","size":23414,
"digest":"f4028156fd7eca03584d5f2fc0470df1e0dbc7369eaae638b2ff033f988ec493","integrity":"sha256-9AKBVv1+ygNYTV8vwEcN8eDbxzaequY4sv8DP5iOxJM="}},
"assets":{"application.js":"application-aee4be71f1288037ae78b997df388332edfd246471b533dcedaa8f9fe156442b.js",
"application.css":"application-86a292b5070793c37e2c0e5f39f73bb387644eaeada7f96e6fc040a028b16c18.css",
"favicon.ico":"favicon-8d2387b8d4d32cecd93fa3900df0e9ff89d01aacd84f50e780c17c9f6b3d0eda.ico",
"my_image.png":"my_image-f4028156fd7eca03584d5f2fc0470df1e0dbc7369eaae638b2ff033f988ec493.png"}}
```

The default location for the manifest is the root of the location specified in
`config.assets.prefix` ('/assets' by default).

NOTE: If there are missing precompiled files in production you will get a
`Sprockets::Helpers::RailsHelper::AssetPaths::AssetNotPrecompiledError`
exception indicating the name of the missing file(s).

#### Far-future Expires Header

Precompiled assets exist on the file system and are served directly by your web
server. They do not have far-future headers by default, so to get the benefit of
fingerprinting you'll have to update your server configuration to add those
headers.

For Apache:

```apache
# The Expires* directives requires the Apache module
# `mod_expires` to be enabled.
<Location /assets/>
  # Use of ETag is discouraged when Last-Modified is present
  Header unset ETag
  FileETag None
  # RFC says only cache for 1 year
  ExpiresActive On
  ExpiresDefault "access plus 1 year"
</Location>
```

For NGINX:

```nginx
location ~ ^/assets/ {
  expires 1y;
  add_header Cache-Control public;

  add_header ETag "";
}
```

### Local Precompilation

There are several reasons why you might want to precompile your assets locally.
Among them are:

* You may not have write access to your production file system.
* You may be deploying to more than one server, and want to avoid
duplication of work.
* You may be doing frequent deploys that do not include asset changes.

Local compilation allows you to commit the compiled files into source control,
and deploy as normal.

There are three caveats:

* You must not run the Capistrano deployment task that precompiles assets.
* You must ensure any necessary compressors or minifiers are
available on your development system.
* You must change the following application configuration setting:

In `config/environments/development.rb`, place the following line:

```ruby
config.assets.prefix = "/dev-assets"
```

The `prefix` change makes Sprockets use a different URL for serving assets in
development mode, and pass all requests to Sprockets. The prefix is still set to
`/assets` in the production environment. Without this change, the application
would serve the precompiled assets from `/assets` in development, and you would
not see any local changes until you compile assets again.

In practice, this will allow you to precompile locally, have those files in your
working tree, and commit those files to source control when needed.  Development
mode will work as expected.

### Live Compilation

In some circumstances you may wish to use live compilation. In this mode all
requests for assets in the pipeline are handled by Sprockets directly.

To enable this option set:

```ruby
config.assets.compile = true
```

On the first request the assets are compiled and cached as outlined in
development above, and the manifest names used in the helpers are altered to
include the SHA256 hash.

Sprockets also sets the `Cache-Control` HTTP header to `max-age=31536000`. This
signals all caches between your server and the client browser that this content
(the file served) can be cached for 1 year. The effect of this is to reduce the
number of requests for this asset from your server; the asset has a good chance
of being in the local browser cache or some intermediate cache.

This mode uses more memory, performs more poorly than the default, and is not
recommended.

If you are deploying a production application to a system without any
pre-existing JavaScript runtimes, you may want to add one to your `Gemfile`:

```ruby
group :production do
  gem 'mini_racer'
end
```

### CDNs

CDN stands for [Content Delivery
Network](https://en.wikipedia.org/wiki/Content_delivery_network), they are
primarily designed to cache assets all over the world so that when a browser
requests the asset, a cached copy will be geographically close to that browser.
If you are serving assets directly from your Rails server in production, the
best practice is to use a CDN in front of your application.

A common pattern for using a CDN is to set your production application as the
"origin" server. This means when a browser requests an asset from the CDN and
there is a cache miss, it will grab the file from your server on the fly and
then cache it. For example if you are running a Rails application on
`example.com` and have a CDN configured at `mycdnsubdomain.fictional-cdn.com`,
then when a request is made to `mycdnsubdomain.fictional-
cdn.com/assets/smile.png`, the CDN will query your server once at
`example.com/assets/smile.png` and cache the request. The next request to the
CDN that comes in to the same URL will hit the cached copy. When the CDN can
serve an asset directly the request never touches your Rails server. Since the
assets from a CDN are geographically closer to the browser, the request is
faster, and since your server doesn't need to spend time serving assets, it can
focus on serving application code as fast as possible.

#### Set up a CDN to Serve Static Assets

To set up your CDN you have to have your application running in production on
the internet at a publicly available URL, for example `example.com`. Next
you'll need to sign up for a CDN service from a cloud hosting provider. When you
do this you need to configure the "origin" of the CDN to point back at your
website `example.com`, check your provider for documentation on configuring the
origin server.

The CDN you provisioned should give you a custom subdomain for your application
such as `mycdnsubdomain.fictional-cdn.com` (note fictional-cdn.com is not a
valid CDN provider at the time of this writing). Now that you have configured
your CDN server, you need to tell browsers to use your CDN to grab assets
instead of your Rails server directly. You can do this by configuring Rails to
set your CDN as the asset host instead of using a relative path. To set your
asset host in Rails, you need to set `config.action_controller.asset_host` in
`config/environments/production.rb`:

```ruby
config.action_controller.asset_host = 'mycdnsubdomain.fictional-cdn.com'
```

NOTE: You only need to provide the "host", this is the subdomain and root
domain, you do not need to specify a protocol or "scheme" such as `http://` or
`https://`. When a web page is requested, the protocol in the link to your asset
that is generated will match how the webpage is accessed by default.

You can also set this value through an [environment
variable](https://en.wikipedia.org/wiki/Environment_variable) to make running a
staging copy of your site easier:

```
config.action_controller.asset_host = ENV['CDN_HOST']
```



NOTE: You would need to set `CDN_HOST` on your server to `mycdnsubdomain
.fictional-cdn.com` for this to work.

Once you have configured your server and your CDN when you serve a webpage that
has an asset:

```erb
<%= asset_path('smile.png') %>
```

Instead of returning a path such as `/assets/smile.png` (digests are left out
for readability). The URL generated will have the full path to your CDN.

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile.png
```

If the CDN has a copy of `smile.png` it will serve it to the browser and your
server doesn't even know it was requested. If the CDN does not have a copy it
will try to find it at the "origin" `example.com/assets/smile.png` and then store
it for future use.

If you want to serve only some assets from your CDN, you can use custom `:host`
option your asset helper, which overwrites value set in
`config.action_controller.asset_host`.

```erb
<%= asset_path 'image.png', host: 'mycdnsubdomain.fictional-cdn.com' %>
```

#### Customize CDN Caching Behavior

A CDN works by caching content. If the CDN has stale or bad content, then it is
hurting rather than helping your application. The purpose of this section is to
describe general caching behavior of most CDNs, your specific provider may
behave slightly differently.

##### CDN Request Caching

While a CDN is described as being good for caching assets, in reality caches the
entire request. This includes the body of the asset as well as any headers. The
most important one being `Cache-Control` which tells the CDN (and web browsers)
how to cache contents. This means that if someone requests an asset that does
not exist `/assets/i-dont-exist.png` and your Rails application returns a 404,
then your CDN will likely cache the 404 page if a valid `Cache-Control` header
is present.

##### CDN Header Debugging

One way to check the headers are cached properly in your CDN is by using [curl](
https://explainshell.com/explain?cmd=curl+-I+http%3A%2F%2Fwww.example.com). You
can request the headers from both your server and your CDN to verify they are
the same:

```
$ curl -I http://www.example/assets/application-
d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK
Server: Cowboy
Date: Sun, 24 Aug 2014 20:27:50 GMT
Connection: keep-alive
Last-Modified: Thu, 08 May 2014 01:24:14 GMT
Content-Type: text/css
Cache-Control: public, max-age=2592000
Content-Length: 126560
Via: 1.1 vegur
```

Versus the CDN copy.

```
$ curl -I http://mycdnsubdomain.fictional-cdn.com/application-
d0e099e021c95eb0de3615fd1d8c4d83.css
HTTP/1.1 200 OK Server: Cowboy Last-
Modified: Thu, 08 May 2014 01:24:14 GMT Content-Type: text/css
Cache-Control:
public, max-age=2592000
Via: 1.1 vegur
Content-Length: 126560
Accept-Ranges:
bytes
Date: Sun, 24 Aug 2014 20:28:45 GMT
Via: 1.1 varnish
Age: 885814
Connection: keep-alive
X-Served-By: cache-dfw1828-DFW
X-Cache: HIT
X-Cache-Hits:
68
X-Timer: S1408912125.211638212,VS0,VE0
```

Check your CDN documentation for any additional information they may provide
such as `X-Cache` or for any additional headers they may add.

##### CDNs and the Cache-Control Header

The [cache control
header](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.9) is a W3C
specification that describes how a request can be cached. When no CDN is used, a
browser will use this information to cache contents. This is very helpful for
assets that are not modified so that a browser does not need to re-download a
website's CSS or JavaScript on every request. Generally we want our Rails server
to tell our CDN (and browser) that the asset is "public", that means any cache
can store the request. Also we commonly want to set `max-age` which is how long
the cache will store the object before invalidating the cache. The `max-age`
value is set to seconds with a maximum possible value of `31536000` which is one
year. You can do this in your Rails application by setting

```
config.public_file_server.headers = {
  'Cache-Control' => 'public, max-age=31536000'
}
```

Now when your application serves an asset in production, the CDN will store the
asset for up to a year. Since most CDNs also cache headers of the request, this
`Cache-Control` will be passed along to all future browsers seeking this asset,
the browser then knows that it can store this asset for a very long time before
needing to re-request it.

##### CDNs and URL based Cache Invalidation

Most CDNs will cache contents of an asset based on the complete URL. This means
that a request to

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile-123.png
```

Will be a completely different cache from

```
http://mycdnsubdomain.fictional-cdn.com/assets/smile.png
```

If you want to set far future `max-age` in your `Cache-Control` (and you do),
then make sure when you change your assets that your cache is invalidated. For
example when changing the smiley face in an image from yellow to blue, you want
all visitors of your site to get the new blue face. When using a CDN with the
Rails asset pipeline `config.assets.digest` is set to true by default so that
each asset will have a different file name when it is changed. This way you
don't have to ever manually invalidate any items in your cache. By using a
different unique asset name instead, your users get the latest asset.

Customizing the Pipeline
------------------------

### CSS Compression

One of the options for compressing CSS is YUI. The [YUI CSS
compressor](https://yui.github.io/yuicompressor/css.html) provides
minification.

The following line enables YUI compression, and requires the `yui-compressor`
gem.

```ruby
config.assets.css_compressor = :yui
```
The other option for compressing CSS if you have the sass-rails gem installed is

```ruby
config.assets.css_compressor = :sass
```

### JavaScript Compression

Possible options for JavaScript compression are `:closure`, `:uglifier` and
`:yui`. These require the use of the `closure-compiler`, `uglifier` or
`yui-compressor` gems, respectively.

Take the `uglifier` gem, for example.
This gem wraps [UglifyJS](https://github.com/mishoo/UglifyJS) (written for
NodeJS) in Ruby. It compresses your code by removing white space and comments,
shortening local variable names, and performing other micro-optimizations such
as changing `if` and `else` statements to ternary operators where possible.

The following line invokes `uglifier` for JavaScript compression.

```ruby
config.assets.js_compressor = :uglifier
```

NOTE: You will need an [ExecJS](https://github.com/rails/execjs#readme)
supported runtime in order to use `uglifier`. If you are using macOS or
Windows you have a JavaScript runtime installed in your operating system.



### GZipping your assets

By default, gzipped version of compiled assets will be generated, along with
the non-gzipped version of assets. Gzipped assets help reduce the transmission
of data over the wire. You can configure this by setting the `gzip` flag.

```ruby
config.assets.gzip = false # disable gzipped assets generation
```

Refer to your web server's documentation for instructions on how to serve gzipped assets.

### Using Your Own Compressor

The compressor config settings for CSS and JavaScript also take any object.
This object must have a `compress` method that takes a string as the sole
argument and it must return a string.

```ruby
class Transformer
  def compress(string)
    do_something_returning_a_string(string)
  end
end
```

To enable this, pass a new object to the config option in `application.rb`:

```ruby
config.assets.css_compressor = Transformer.new
```


### Changing the _assets_ Path

The public path that Sprockets uses by default is `/assets`.

This can be changed to something else:

```ruby
config.assets.prefix = "/some_other_path"
```

This is a handy option if you are updating an older project that didn't use the
asset pipeline and already uses this path or you wish to use this path for
a new resource.

### X-Sendfile Headers

The X-Sendfile header is a directive to the web server to ignore the response
from the application, and instead serve a specified file from disk. This option
is off by default, but can be enabled if your server supports it. When enabled,
this passes responsibility for serving the file to the web server, which is
faster. Have a look at [send_file](https://api.rubyonrails.org/classes/ActionController/DataStreaming.html#method-i-send_file)
on how to use this feature.

Apache and NGINX support this option, which can be enabled in
`config/environments/production.rb`:

```ruby
# config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
# config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX
```

WARNING: If you are upgrading an existing application and intend to use this
option, take care to paste this configuration option only into `production.rb`
and any other environments you define with production behavior (not
`application.rb`).

TIP: For further details have a look at the docs of your production web server:
- [Apache](https://tn123.org/mod_xsendfile/)
- [NGINX](https://www.nginx.com/resources/wiki/start/topics/examples/xsendfile/)

Assets Cache Store
------------------

By default, Sprockets caches assets in `tmp/cache/assets` in development
and production environments. This can be changed as follows:

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:memory_store,
                                                { size: 32.megabytes })
end
```

To disable the assets cache store:

```ruby
config.assets.configure do |env|
  env.cache = ActiveSupport::Cache.lookup_store(:null_store)
end
```

Adding Assets to Your Gems
--------------------------

Assets can also come from external sources in the form of gems.

A good example of this is the `jquery-rails` gem.
This gem contains an engine class which inherits from `Rails::Engine`.
By doing this, Rails is informed that the directory for this
gem may contain assets and the `app/assets`, `lib/assets` and
`vendor/assets` directories of this engine are added to the search path of
Sprockets.

Making Your Library or Gem a Pre-Processor
------------------------------------------

Sprockets uses Processors, Transformers, Compressors, and Exporters to extend
Sprockets functionality. Have a look at
[Extending Sprockets](https://github.com/rails/sprockets/blob/master/guides/extending_sprockets.md)
to learn more. Here we registered a preprocessor to add a comment to the end
of text/css (`.css`) files.

```ruby
module AddComment
  def self.call(input)
    { data: input[:data] + "/* Hello From my sprockets extension */" }
  end
end
```

Now that you have a module that modifies the input data, it's time to register
it as a preprocessor for your mime type.

```ruby
Sprockets.register_preprocessor 'text/css', AddComment
```
