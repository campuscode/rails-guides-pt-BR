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

Chamar `content_for` permite armazena um bloco de marcação em um *identificador* para uso posterior. Você pode fazer chamadas subsequentes para o conteúdo armazenado em outros *templates* ou no *layout*, passando o *identificador* como um argumento para `yield`.

Por exemplo, digamos que temos um *layout* padrão da aplicação, mas também uma página especial que requer determinado código *JavaScript* que o resto do site não precisa. Podemos usar `content_for` para incluir este código *JavaScript* em nossa página especial sem engordar/afetar o resto do site.

**app/views/layouts/application.html.erb**

```html+erb
<html>
  <head>
    <title>Bem vindo!</title>
    <%= yield :special_script %>
  </head>
  <body>
    <p>Bem vindo! A data e hora são <%= Time.now %></p>
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
