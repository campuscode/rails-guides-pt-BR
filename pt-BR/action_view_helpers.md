**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Action View Helpers
====================

After reading this guide, you will know:

* How to format dates, strings and numbers
* How to link to images, videos, stylesheets, etc...
* How to sanitize content
* How to localize content

--------------------------------------------------------------------------------

Overview of helpers provided by Action View
-------------------------------------------

WIP: Not all the helpers are listed here. For a full list see the [API documentation](https://api.rubyonrails.org/classes/ActionView/Helpers.html)

The following is only a brief overview summary of the helpers available in Action View. It's recommended that you review the [API Documentation](https://api.rubyonrails.org/classes/ActionView/Helpers.html), which covers all of the helpers in more detail, but this should serve as a good starting point.

### AssetTagHelper

This module provides methods for generating HTML that links views to assets such as images, JavaScript files, stylesheets, and feeds.

By default, Rails links to these assets on the current host in the public folder, but you can direct Rails to link to assets from a dedicated assets server by setting `config.asset_host` in the application configuration, typically in `config/environments/production.rb`. For example, let's say your asset host is `assets.example.com`:

```ruby
config.asset_host = "assets.example.com"
image_tag("rails.png")
# => <img src="http://assets.example.com/images/rails.png" />
```

#### auto_discovery_link_tag

Returns a link tag that browsers and feed readers can use to auto-detect an RSS, Atom, or JSON feed.

```ruby
auto_discovery_link_tag(:rss, "http://www.example.com/feed.rss", { title: "RSS Feed" })
# => <link rel="alternate" type="application/rss+xml" title="RSS Feed" href="http://www.example.com/feed.rss" />
```

#### image_path

Computes the path to an image asset in the `app/assets/images` directory. Full paths from the document root will be passed through. Used internally by `image_tag` to build the image path.

```ruby
image_path("edit.png") # => /assets/edit.png
```

Fingerprint will be added to the filename if config.assets.digest is set to true.

```ruby
image_path("edit.png")
# => /assets/edit-2d1a2db63fc738690021fedb5a65b68e.png
```

#### image_url

Computes the URL to an image asset in the `app/assets/images` directory. This will call `image_path` internally and merge with your current host or your asset host.

```ruby
image_url("edit.png") # => http://www.example.com/assets/edit.png
```

#### image_tag

Returns an HTML image tag for the source. The source can be a full path or a file that exists in your `app/assets/images` directory.

```ruby
image_tag("icon.png") # => <img src="/assets/icon.png" />
```

#### javascript_include_tag

Returns an HTML script tag for each of the sources provided. You can pass in the filename (`.js` extension is optional) of JavaScript files that exist in your `app/assets/javascripts` directory for inclusion into the current page or you can pass the full path relative to your document root.

```ruby
javascript_include_tag "common"
# => <script src="/assets/common.js"></script>
```

#### javascript_path

Computes the path to a JavaScript asset in the `app/assets/javascripts` directory. If the source filename has no extension, `.js` will be appended. Full paths from the document root will be passed through. Used internally by `javascript_include_tag` to build the script path.

```ruby
javascript_path "common" # => /assets/common.js
```

#### javascript_url

Computes the URL to a JavaScript asset in the `app/assets/javascripts` directory. This will call `javascript_path` internally and merge with your current host or your asset host.

```ruby
javascript_url "common"
# => http://www.example.com/assets/common.js
```

#### stylesheet_link_tag

Returns a stylesheet link tag for the sources specified as arguments. If you don't specify an extension, `.css` will be appended automatically.

```ruby
stylesheet_link_tag "application"
# => <link href="/assets/application.css" media="screen" rel="stylesheet" />
```

#### stylesheet_path

Computes the path to a stylesheet asset in the `app/assets/stylesheets` directory. If the source filename has no extension, `.css` will be appended. Full paths from the document root will be passed through. Used internally by `stylesheet_link_tag` to build the stylesheet path.

```ruby
stylesheet_path "application" # => /assets/application.css
```

#### stylesheet_url

Computes the URL to a stylesheet asset in the `app/assets/stylesheets` directory. This will call `stylesheet_path` internally and merge with your current host or your asset host.

```ruby
stylesheet_url "application"
# => http://www.example.com/assets/application.css
```

### AtomFeedHelper

#### atom_feed

This helper makes building an Atom feed easy. Here's a full usage example:

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

Allows you to measure the execution time of a block in a template and records the result to the log. Wrap this block around expensive operations or possible bottlenecks to get a time reading for the operation.

```html+erb
<% benchmark "Process data files" do %>
  <%= expensive_files_operation %>
<% end %>
```

This would add something like "Process data files (0.34523)" to the log, which you can then use to compare timings when optimizing your code.

### CacheHelper

#### cache

A method for caching fragments of a view rather than an entire action or page. This technique is useful for caching pieces like menus, lists of news topics, static HTML fragments, and so on. This method takes a block that contains the content you wish to cache. See `AbstractController::Caching::Fragments` for more information.

```erb
<% cache do %>
  <%= render "shared/footer" %>
<% end %>
```

### CaptureHelper

#### capture

The `capture` method allows you to extract part of a template into a variable. You can then use this variable anywhere in your templates or layout.

```html+erb
<% @greeting = capture do %>
  <p>Welcome! The date and time is <%= Time.now %></p>
<% end %>
```

The captured variable can then be used anywhere else.

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

Calling `content_for` stores a block of markup in an identifier for later use. You can make subsequent calls to the stored content in other templates or the layout by passing the identifier as an argument to `yield`.

For example, let's say we have a standard application layout, but also a special page that requires certain JavaScript that the rest of the site doesn't need. We can use `content_for` to include this JavaScript on our special page without fattening up the rest of the site.

**app/views/layouts/application.html.erb**

```html+erb
<html>
  <head>
    <title>Welcome!</title>
    <%= yield :special_script %>
  </head>
  <body>
    <p>Welcome! The date and time is <%= Time.now %></p>
  </body>
</html>
```

**app/views/articles/special.html.erb**

```html+erb
<p>This is a special page.</p>

<% content_for :special_script do %>
  <script>alert('Hello!')</script>
<% end %>
```

### DateHelper

#### distance_of_time_in_words

Reports the approximate distance in time between two Time or Date objects or integers as seconds. Set `include_seconds` to true if you want more detailed approximations.

```ruby
distance_of_time_in_words(Time.now, Time.now + 15.seconds)
# => less than a minute
distance_of_time_in_words(Time.now, Time.now + 15.seconds, include_seconds: true)
# => less than 20 seconds
```

#### time_ago_in_words

Like `distance_of_time_in_words`, but where `to_time` is fixed to `Time.now`.

```ruby
time_ago_in_words(3.minutes.from_now) # => 3 minutes
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

Se as opções `:attributes` (atributos) ou `:tags` são passadas, apenas os atributos e tags mencionados são permitidos e nada mais.

```ruby
sanitize @article.body, tags: %w(table tr td), attributes: %w(id class style)
```

Para alterar os padrões para múltiplos usos, por exemplo, adicionando tags de tabela ao padrão:

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
strip_tags("Sem <b>Bold</b> mais!  <a href='more.html'>Olhar mais</a>")
# => Sem bold mais!  Olhar mais
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
