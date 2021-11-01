**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Action View Helpers
====================

Depois de ler este guia, você saberá:

* Como formatar datas, *strings* e números
* Como vincular imagens, vídeos, folhas de estilo, etc ...
* Como deixar o conteúdo limpo
* Como posicionar o conteúdo

--------------------------------------------------------------------------------

Visão geral dos *helpers* fornecidos pelo Action View
-------------------------------------------

WIP: Nem todos os *helpers* estão listados aqui. Para uma lista completa, consulte a [documentação da API](https://api.rubyonrails.org/classes/ActionView/Helpers.html)

O que se segue é apenas um breve resumo geral dos *helpers* disponíveis no Action View. É recomendável que você revise a [documentação da API](https://api.rubyonrails.org/classes/ActionView/Helpers.html), que cobre todos os *helpers* de forma mais detalhada, mas esse conteúdo deve servir como um bom ponto de partida.

### AssetTagHelper

Este módulo fornece métodos para gerar HTML que vincula *views* aos *assets*, como imagens, arquivos JavaScript, folhas de estilo e feeds.

Por padrão, o Rails disponibiliza esses *assets* no *host* atual na pasta `public`, mas você pode direcionar o Rails para disponibilizar os *assets* de um servidor de *assets* dedicado definindo `config.asset_host` na configuração da aplicação, normalmente em `config/environment/production.rb`. Por exemplo, digamos que seu *host* de *assets* seja `assets.example.com`:

```ruby
config.asset_host = "assets.example.com"
image_tag("rails.png")
# => <img src="http://assets.example.com/images/rails.png" />
```

#### auto_discovery_link_tag

Retorna uma tag de link que navegadores e leitores de feed podem usar para detectar automaticamente um feed RSS, Atom ou JSON.

```ruby
auto_discovery_link_tag(:rss, "http://www.example.com/feed.rss", { title: "RSS Feed" })
# => <link rel="alternate" type="application/rss+xml" title="RSS Feed" href="http://www.example.com/feed.rss" />
```

#### image_path

Gera o caminho para uma imagem no diretório `app/assets/images`. Caminhos completos da raiz do documento são interpretados como caminhos absolutos, ignorando as configurações da *asset pipeline*.  Usado internamente por `image_tag` para construir o caminho da imagem.

```ruby
image_path("edit.png") # => /assets/edit.png
```

Uma *fingerprint* será adicionada ao nome do arquivo se config.assets.digest for definido como verdadeiro.

```ruby
image_path("edit.png")
# => /assets/edit-2d1a2db63fc738690021fedb5a65b68e.png
```

#### image_url

Gera a URL para um *asset* de imagem no diretório `app/assets/images`. Isso chamará `image_path` internamente e mesclará com seu *host* atual ou seu *host* de *assets*.

```ruby
image_url("edit.png") # => http://www.example.com/assets/edit.png
```

#### image_tag

Retorna uma tag de imagem HTML para a fonte. A fonte pode ser um caminho completo ou um arquivo que existe em seu diretório `app/assets/images`.

```ruby
image_tag("icon.png") # => <img src="/assets/icon.png" />
```

#### javascript_include_tag

Retorna uma *tag* de *script* HTML para cada uma das fontes fornecidas. Você pode passar o nome de arquivos JavaScript (a extensão `.js` é opcional) que existem no seu diretório `app/assets/javascripts` para inclusão na página atual ou você pode passar o caminho completo relativo à raiz do seu documento.

```ruby
javascript_include_tag "common"
# => <script src="/assets/common.js"></script>
```

#### javascript_path

Gera o caminho para um *asset* JavaScript no diretório `app/assets/javascripts`. Se o nome do arquivo fonte não tiver extensão, `.js` será anexado. Caminhos completos da raiz do documento podem ser passados. Usado internamente por `javascript_include_tag` para construir o caminho do *script*.

```ruby
javascript_path "common" # => /assets/common.js
```

#### javascript_url

Gera a URL para um *asset* JavaScript no diretório `app/assets/javascripts`. Isso chamará `javascript_path` internamente e mesclará com seu *host* atual ou seu *host* de *assets*.

```ruby
javascript_url "common"
# => http://www.example.com/assets/common.js
```

#### stylesheet_link_tag

Retorna uma *tag* com *link* de folha de estilo para as fontes especificadas como argumentos. Se você não especificar uma extensão, `.css` será anexado automaticamente.

```ruby
stylesheet_link_tag "application"
# => <link href="/assets/application.css" media="screen" rel="stylesheet" />
```

#### stylesheet_path

Gera o caminho para um recurso de *stylesheet* no diretório `app/assets/stylesheets`. Se o nome do arquivo fonte não tiver extensão, `.css` será anexado automaticamente. Caminhos completos da raiz do documento podem ser passados. Usado internamente por `stylesheet_link_tag` para construir o caminho da folha de estilo.

```ruby
stylesheet_path "application" # => /assets/application.css
```

#### stylesheet_url

Gera a URL para um *asset* de folha de estilo no diretório `app/assets/stylesheets`. Isso chamará `stylesheet_path` internamente e mesclará com seu *host* atual ou seu *host* de *asset*.

```ruby
stylesheet_url "application"
# => http://www.example.com/assets/application.css
```

### AtomFeedHelper

#### atom_feed

Este *helper* facilita a construção de um feed *Atom*. Aqui está um exemplo completo de uso:

**config/routes.rb**

```ruby
resources :articles
```

**app/controllers/articles_controller.rb**

```ruby
def index
  @articles = Article.all

  respond_to do |format|
    format.html
    format.atom
  end
end
```

**app/views/articles/index.atom.builder**

```ruby
atom_feed do |feed|
  feed.title("Articles Index")
  feed.updated(@articles.first.created_at)

  @articles.each do |article|
    feed.entry(article) do |entry|
      entry.title(article.title)
      entry.content(article.body, type: 'html')

      entry.author do |author|
        author.name(article.author_name)
      end
    end
  end
end
```

### BenchmarkHelper

#### benchmark

Permite medir o tempo de execução de um bloco em um *template* e registra o resultado no log. Para tal, envolva este bloco em torno de operações custosas, ou com possíveis gargalos, para obter o tempo de leitura da operação.

```html+erb
<% benchmark "Process data files" do %>
  <%= expensive_files_operation %>
<% end %>
```

Isso adicionaria algo como "Process data files (0.34523)" ao log, que você pode usar para comparar tempos ao otimizar seu código.

### CacheHelper

#### cache

Um método para armazenar em *cache* fragmentos de uma *view*, em vez de uma ação ou página inteira. Essa técnica é útil para armazenar componentes como: menus, listas de tópicos de notícias, fragmentos de *HTML* estáticos e assim por diante. Este método pega um bloco que contém o conteúdo que você deseja armazenar em *cache*. Veja `AbstractController::Caching::Fragments` para mais informações.

```erb
<% cache do %>
  <%= render "shared/footer" %>
<% end %>
```

### CaptureHelper

#### capture

O método `capture` permite que você extraia parte de um *template* em uma variável. Você pode então usar essa variável em qualquer lugar nos *templates* ou *layout*.

```html+erb
<% @greeting = capture do %>
  <p>Welcome! The date and time is <%= Time.now %></p>
<% end %>
```

A variável capturada pode então ser usada em qualquer outro lugar.

```html+erb
<html>
  <head>
    <title>Welcome!</title>
  </head>
  <body>
    <%= @greeting %>
  </body>
</html>
```

#### content_for

Chamar `content_for` permite armazena um bloco de marcação em um *identificador* para uso posterior. Você pode fazer chamadas subsequentes para o conteúdo armazenado em outros *templates* ou no *layout*, passando o identificador como um argumento para `yield`.

Por exemplo, digamos que temos um *layout* padrão da aplicação, mas também uma página especial que requer determinado código *JavaScript* que o resto do site não precisa. Podemos usar `content_for` para incluir este código *JavaScript* em nossa página especial sem inflar o resto do site.

**app/views/layouts/application.html.erb**

```html+erb
<html>
  <head>
    <title>Boas vindas!</title>
    <%= yield :special_script %>
  </head>
  <body>
    <p>Boas vindas! A data e hora são <%= Time.now %></p>
  </body>
</html>
```

**app/views/articles/special.html.erb**

```html+erb
<p>Esta é a página especial.</p>

<% content_for :special_script do %>
  <script>alert('Ola!')</script>
<% end %>
```

### DateHelper

#### distance_of_time_in_words

Informa a distância aproximada de tempo entre dois objetos *Time*, *Date* ou *integers* como segundos. Defina `include_seconds` como *true* se você quiser aproximações mais detalhadas.

```ruby
distance_of_time_in_words(Time.now, Time.now + 15.seconds)
# => menos de um minuto
distance_of_time_in_words(Time.now, Time.now + 15.seconds, include_seconds: true)
# => menos de 20 segundos
```

#### time_ago_in_words

Como `distance_of_time_in_words`, mas onde `to_time` é fixado em `Time.now`.

```ruby
time_ago_in_words(3.minutes.from_now) # => 3 minutos
```

### DebugHelper

Retorna uma tag `pre` com um objeto YAML. Isso cria uma maneira muito legível de inspecionar um objeto.

```ruby
my_hash = { 'first' => 1, 'second' => 'two', 'third' => [1,2,3] }
debug(my_hash)
```

```html
<pre class='debug_dump'>---
first: 1
second: two
third:
- 1
- 2
- 3
</pre>
```

### FormHelper

*FormHelper* são projetados para tornar o trabalho com *models* muito mais fácil em comparação com o uso apenas de elementos HTML padrão, fornecendo um conjunto de métodos para a criação de formulários com base em seus *models*. Este auxiliar gera o HTML para os formulários, fornecendo um método para cada tipo de entrada (por exemplo, texto (*text*), senha (*password*), seleção (*select*), e assim por diante). Quando o formulário é enviado (ou seja, quando o usuário clica no botão de envio, ou através de *form.submit* chamado via JavaScript), as entradas do formulário são agrupadas dentro de parâmetros de um objeto e devolvidas ao controlador.

Você pode aprender mais sobre os *helpers* de formulário em [Action View Form Helpers Guide](form_helpers.html).

### JavaScriptHelper

Fornece funcionalidades para trabalhar com JavaScript em suas *views*.

#### escape_javascript

*Escapa* retornos, aspas simples e aspas duplas para segmentos JavaScript.

#### javascript_tag

Retorna uma tag JavaScript envolvendo o código fornecido.

```ruby
javascript_tag "alert('Tudo está bem')"
```

```html
<script>
//<![CDATA[
alert('Tudo está bem')
//]]>
</script>
```

### NumberHelper

Fornece métodos para converter números em *strings* formatadas. Métodos são fornecidos para números de telefone, moeda, porcentagem, precisão, notação posicional e tamanhos de arquivo.

#### number_to_currency

Formata um número em uma *string* de moeda (por exemplo, $13.65).

```ruby
number_to_currency(1234567890.50) # => $1,234,567,890.50
```

#### number_to_human_size

Formata os *bytes* em tamanho em uma representação mais compreensível; útil para relatar tamanhos de arquivo aos usuários.

```ruby
number_to_human_size(1234)    # => 1.2 KB
number_to_human_size(1234567) # => 1.2 MB
```

#### number_to_percentage

Formata um número como *string* de porcentagem.

```ruby
number_to_percentage(100, precision: 0) # => 100%
```

#### number_to_phone

Formata um número em um número de telefone (formato dos EUA por padrão).

```ruby
number_to_phone(1235551234) # => 123-555-1234
```

#### number_with_delimiter

Formata um número com casas de milhar usando um delimitador.

```ruby
number_with_delimiter(12345678) # => 12,345,678
```

#### number_with_precision

Formata um número com o nível especificado de `precision` (precisão), cujo o padrão é 3.

```ruby
number_with_precision(111.2345)               # => 111.235
number_with_precision(111.2345, precision: 2) # => 111.23
```

### SanitizeHelper

O módulo *SanitizeHelper* fornece um conjunto de métodos para limpar o texto de elementos HTML indesejados.

#### sanitize

Este *helper* de limpeza codificará em HTML todas as tags e removerá todos os atributos que não são especificamente permitidos.

```ruby
sanitize @article.body
```

Se as opções `:attributes` (atributos) ou `:tags` são passadas, apenas os atributos e *tags* mencionados são permitidos e nada mais.

```ruby
sanitize @article.body, tags: %w(table tr td), attributes: %w(id class style)
```

Para alterar os padrões para múltiplos usos, por exemplo, adicionando *tags* de tabela ao padrão:

```ruby
class Application < Rails::Application
  config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td'
end
```

#### sanitize_css(style)

Limpa um bloco de código CSS.

#### strip_links(html)

Remove todas as tags de link do texto, deixando apenas o texto do link.

```ruby
strip_links('<a href="https://rubyonrails.org">Ruby on Rails</a>')
# => Ruby on Rails
```

```ruby
strip_links('e-mails para <a href="mailto:me@email.com">me@email.com</a>.')
# => e-mails para me@email.com.
```

```ruby
strip_links('Blog: <a href="http://myblog.com/">Visite</a>.')
# => Blog: Visite.
```

#### strip_tags(html)

Retira todas as tags HTML do html, incluindo comentários.
Essa funcionalidade é alimentada pela *gem rails-html-sanitizer*.

```ruby
strip_tags("Remova <i>essas</i> tags!")
# => Remova essas tags!
```

```ruby
strip_tags("Sem <b>Bold</b> mais!  <a href='more.html'>Ver mais</a>")
# => Sem bold mais!  Ver mais
```

Nota: A saída ainda pode conter caracteres '<', '>', '&' sem ser escapadas e confundir os navegadores.

### UrlHelper

Provides methods to make links and get URLs that depend on the routing subsystem.

#### url_for

Returns the URL for the set of `options` provided.

##### Examples

```ruby
url_for @profile
# => /profiles/1

url_for [ @hotel, @booking, page: 2, line: 3 ]
# => /hotels/1/bookings/1?line=3&page=2
```

#### link_to

Links to a URL derived from `url_for` under the hood. Primarily used to
create RESTful resource links, which for this example, boils down to
when passing models to `link_to`.

**Examples**

```ruby
link_to "Profile", @profile
# => <a href="/profiles/1">Profile</a>
```

You can use a block as well if your link target can't fit in the name parameter. ERB example:

```html+erb
<%= link_to @profile do %>
  <strong><%= @profile.name %></strong> -- <span>Check it out!</span>
<% end %>
```

would output:

```html
<a href="/profiles/1">
  <strong>David</strong> -- <span>Check it out!</span>
</a>
```

See [the API Documentation for more information](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)

#### button_to

Generates a form that submits to the passed URL. The form has a submit button
with the value of the `name`.

##### Examples

```html+erb
<%= button_to "Sign in", sign_in_path %>
```

would roughly output something like:

```html
<form method="post" action="/sessions" class="button_to">
  <input type="submit" value="Sign in" />
</form>
```

See [the API Documentation for more information](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)

### CsrfHelper

Returns meta tags "csrf-param" and "csrf-token" with the name of the cross-site
request forgery protection parameter and token, respectively.

```html
<%= csrf_meta_tags %>
```

NOTE: Regular forms generate hidden fields so they do not use these tags. More
details can be found in the [Rails Security Guide](security.html#cross-site-request-forgery-csrf).
