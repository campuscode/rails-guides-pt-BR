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

Returns a `pre` tag that has object dumped by YAML. This creates a very readable way to inspect an object.

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

Form helpers are designed to make working with models much easier compared to using just standard HTML elements by providing a set of methods for creating forms based on your models. This helper generates the HTML for forms, providing a method for each sort of input (e.g., text, password, select, and so on). When the form is submitted (i.e., when the user hits the submit button or form.submit is called via JavaScript), the form inputs will be bundled into the params object and passed back to the controller.

You can learn more about form helpers in the [Action View Form Helpers
Guide](form_helpers.html).

### JavaScriptHelper

Provides functionality for working with JavaScript in your views.

#### escape_javascript

Escape carrier returns and single and double quotes for JavaScript segments.

#### javascript_tag

Returns a JavaScript tag wrapping the provided code.

```ruby
javascript_tag "alert('All is good')"
```

```html
<script>
//<![CDATA[
alert('All is good')
//]]>
</script>
```

### NumberHelper

Provides methods for converting numbers into formatted strings. Methods are provided for phone numbers, currency, percentage, precision, positional notation, and file size.

#### number_to_currency

Formats a number into a currency string (e.g., $13.65).

```ruby
number_to_currency(1234567890.50) # => $1,234,567,890.50
```

#### number_to_human_size

Formats the bytes in size into a more understandable representation; useful for reporting file sizes to users.

```ruby
number_to_human_size(1234)    # => 1.2 KB
number_to_human_size(1234567) # => 1.2 MB
```

#### number_to_percentage

Formats a number as a percentage string.

```ruby
number_to_percentage(100, precision: 0) # => 100%
```

#### number_to_phone

Formats a number into a phone number (US by default).

```ruby
number_to_phone(1235551234) # => 123-555-1234
```

#### number_with_delimiter

Formats a number with grouped thousands using a delimiter.

```ruby
number_with_delimiter(12345678) # => 12,345,678
```

#### number_with_precision

Formats a number with the specified level of `precision`, which defaults to 3.

```ruby
number_with_precision(111.2345)               # => 111.235
number_with_precision(111.2345, precision: 2) # => 111.23
```

### SanitizeHelper

The SanitizeHelper module provides a set of methods for scrubbing text of undesired HTML elements.

#### sanitize

This sanitize helper will HTML encode all tags and strip all attributes that aren't specifically allowed.

```ruby
sanitize @article.body
```

If either the `:attributes` or `:tags` options are passed, only the mentioned attributes and tags are allowed and nothing else.

```ruby
sanitize @article.body, tags: %w(table tr td), attributes: %w(id class style)
```

To change defaults for multiple uses, for example adding table tags to the default:

```ruby
class Application < Rails::Application
  config.action_view.sanitized_allowed_tags = 'table', 'tr', 'td'
end
```

#### sanitize_css(style)

Sanitizes a block of CSS code.

#### strip_links(html)
Strips all link tags from text leaving just the link text.

```ruby
strip_links('<a href="https://rubyonrails.org">Ruby on Rails</a>')
# => Ruby on Rails
```

```ruby
strip_links('emails to <a href="mailto:me@email.com">me@email.com</a>.')
# => emails to me@email.com.
```

```ruby
strip_links('Blog: <a href="http://myblog.com/">Visit</a>.')
# => Blog: Visit.
```

#### strip_tags(html)

Strips all HTML tags from the html, including comments.
This functionality is powered by the rails-html-sanitizer gem.

```ruby
strip_tags("Strip <i>these</i> tags!")
# => Strip these tags!
```

```ruby
strip_tags("<b>Bold</b> no more!  <a href='more.html'>See more</a>")
# => Bold no more!  See more
```

NB: The output may still contain unescaped '<', '>', '&' characters and confuse browsers.

### UrlHelper

Fornece métodos para criar links e obter URLs que dependem do *subsistema de roteamento*.

#### url_for

Retorna a URL para o conjunto de `options` fornecido.

##### Exemplos

```ruby
url_for @profile
# => /profiles/1

url_for [ @hotel, @booking, page: 2, line: 3 ]
# => /hotels/1/bookings/1?line=3&page=2
```

#### link_to

Links para uma URL derivada de `url_for` nos bastidores. Usado principalmente 
para criar links de recursos RESTful, que, para este exemplo, se resumem a
ao passar *models* para `link_to`.

**Exemplos**

```ruby
link_to "Profile", @profile
# => <a href="/profiles/1">Profile</a>
```

Você também pode usar um bloco se o destino do link não couber no parâmetro de nome. Exemplo de ERB:

```html+erb
<%= link_to @profile do %>
  <strong><%= @profile.name %></strong> -- <span>Confira!</span>
<% end %>
```

produziria:

```html
<a href="/profiles/1">
  <strong>David</strong> -- <span>Confira!</span>
</a>
```

Consulte [a documentação da API para obter mais informações](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to)

#### button_to

Gera um formulário que submete para a URL passada. O formulário tem um botão de envio
com o valor do `name` (*nome*).

##### Examples

```html+erb
<%= button_to "Entrar", sign_in_path %>
```

produziria aproximadamente algo como:

```html
<form method="post" action="/sessions" class="button_to">
  <input type="submit" value="Entrar" />
</form>
```

Consulte [a documentação da API para obter mais informações](https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-button_to)

### CsrfHelper

Retorna *meta-tags* "*csrf-param*" e "*csrf-token*" com o nome do *cross-site*.
Solicita parâmetros de proteção contra falsificação e token, respectivamente.

```html
<%= csrf_meta_tags %>
```

NOTE: Os formulários regulares geram campos ocultos, portanto, não usam essas tags. Mais
detalhes podem ser encontrados no [Rails Security Guide](security.html#cross-site-request-forgery-csrf).
