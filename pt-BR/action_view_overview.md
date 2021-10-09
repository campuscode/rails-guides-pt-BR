**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Action View Overview
====================

Depois de ler este guia, você vai saber:

* O que é *Action View* e como é utilizada no Rails.
* A melhor forma de usar *templates*, *partials* e *layouts*.
* Como utilizar *views* localizadas.

--------------------------------------------------------------------------------

O que é *Action View*?
----------------------

No *Rails*, as requisições web são tratadas por [*Action Controller*](action_controller_overview.html) e *Action View*. Normalmente, o *Action Controller* é responsável por se comunicar com o banco de dados e realizar ações de *CRUD* quando necessário. A *Action View* é responsável por compilar a resposta.

Os templates *Action View* são escritos usando Ruby embutido em tags mescladas com HTML. Para evitar poluir os templates com código clichê (*boilerplate code*), uma variedade de classes utilitárias (*helpers*) disponibilizam comportamentos comuns para lidar com *forms*, datas e *strings*. Também é fácil adicionar novas classes utilitárias (*helpers*) em sua aplicação conforme ela evolui.

NOTE: Alguns recursos da *Action View* estão vinculados ao *Active Record*, mas isso não significa que a *Action View* depende do *Active Record*. *Action View* é um pacote independente que pode ser usado com qualquer tipo de biblioteca Ruby.

Usando *Action View* com Rails
----------------------------

Para cada *controller* há um diretório associado em `app/views` que contém os arquivos de *template* que compõe as *views* associadas aos seus respectivos *controllers*. Esses arquivos são utilizados para exibir a *view* que resulta de cada ação do *controller*.

Vamos dar uma olhada no que o Rails faz por padrão quando um novo recurso é criado utilizando o *generator scaffold*:

```bash
$ bin/rails generate scaffold article
      [...]
      invoke  scaffold_controller
      create    app/controllers/articles_controller.rb
      invoke    erb
      create      app/views/articles
      create      app/views/articles/index.html.erb
      create      app/views/articles/edit.html.erb
      create      app/views/articles/show.html.erb
      create      app/views/articles/new.html.erb
      create      app/views/articles/_form.html.erb
      [...]
```

Há uma convenção de nomenclatura para as *views* no Rails. Normalmente, as *views* compartilham seu nome com a *action* do *controller* à qual ela é associada, conforme pode ser visto no exemplo acima.
Por exemplo, a ação *index* do *controller* `articles_controller.rb` utilizará o arquivo de *view* `index.html.erb` no diretório `app/views/articles`.
O HTML completo que é retornado ao *client* é composto de uma combinação desse arquivo ERB, um *template* de *layout* que o envolve, e todas as *partials* que a *view* pode referenciar. Dentro deste guia você encontrará documentações mais detalhadas sobre cada um desses três componentes.


*Templates*, *Partials*, e *Layouts*
------------------------------------

Como já mencionado, a saída HTML final é uma composição de três elementos: `Templates`, `Partials` e `Layouts`.
Abaixo está uma breve visão geral de cada um deles.

### Templates

*Templates* *Action View* podem ser escritos de várias maneiras. Se o arquivo de *template* tiver a extensão `.erb` ele usará uma mistura de ERB (*Embedded Ruby*) com HTML. Se o arquivo de template tiver a extensão `.builder`, a biblioteca (*library*) `Builder::XmlMarkup` é utilizada.

O Rails suporta múltiplos sistemas de *template* e utiliza a extensão do arquivo para distingui-los. Por exemplo, um arquivo HTML usando o sistema de *template* ERB terá a extensão do arquivo como `.html.erb`.

#### ERB

Dentro de um *template* ERB, o código Ruby pode ser incluído usando ambas as tags `<% %>` e `<%= %>`. As tags `<% %>` são utilizadas para executar código Ruby que não possui retorno, como condições, *loops*, ou blocos, e as tags `<%= %>` são utilizadas quando você deseja uma saída.

Considere o seguinte *loop* de nomes:

```html+erb
<h1>Names of all the people</h1>
<% @people.each do |person| %>
  Name: <%= person.name %><br>
<% end %>
```

O *loop* é configurado usando tags de incorporação regulares (`<% %>`) e o nome é inserido usando as tags de incorporação de saída (`<%= %>`). Note que isso não é somente uma sugestão de uso: funções de saída regulares como `print` e `puts` não serão renderizadas na *view* usando *template* ERB. Então, isso estaria errado:

```html+erb
<%# WRONG %>
Hi, Mr. <% puts "Frodo" %>
```

Para suprimir espaços em branco à esquerda e à direita, você pode usar `<%-` `-%>` alternadamente com `<%` e `%>`.

#### Builder

Os *templates* *Builder* são uma alternativa mais programática ao ERB. Eles são especialmente úteis para gerar conteúdo *XML*. Um objeto *XmlMarkup* denominado `xml` é automaticamente disponibilizado para *templates* com extensão` .builder`.

Aqui estão alguns exemplos básicos:

```ruby
xml.em("emphasized")
xml.em { xml.b("emph & bold") }
xml.a("A Link", "href" => "https://rubyonrails.org")
xml.target("name" => "compile", "option" => "fast")
```

que produziria:

```html
<em>emphasized</em>
<em><b>emph &amp; bold</b></em>
<a href="https://rubyonrails.org">A link</a>
<target option="fast" name="compile" />
```

Qualquer método com um bloco será tratado como uma tag de marcação *XML* com marcação aninhada no bloco. Por exemplo, o seguinte:

```ruby
xml.div {
  xml.h1(@person.name)
  xml.p(@person.bio)
}
```

produziria algo como:

```html
<div>
  <h1>David Heinemeier Hansson</h1>
  <p>A product of Danish Design during the Winter of '79...</p>
</div>
```

Abaixo está um exemplo completo de *RSS* que foi usado de verdade no Basecamp:

```ruby
xml.rss("version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/") do
  xml.channel do
    xml.title(@feed_title)
    xml.link(@url)
    xml.description "Basecamp: Recent items"
    xml.language "en-us"
    xml.ttl "40"

    for item in @recent_items
      xml.item do
        xml.title(item_title(item))
        xml.description(item_description(item)) if item_description(item)
        xml.pubDate(item_pubDate(item))
        xml.guid(@person.firm.account.url + @recent_items.url(item))
        xml.link(@person.firm.account.url + @recent_items.url(item))
        xml.tag!("dc:creator", item.author_name) if item_has_creator?(item)
      end
    end
  end
end
```

#### Jbuilder
[Jbuilder](https://github.com/rails/jbuilder) é uma *gem* que é
mantida pelo time do Rails e incluída por padrão no `Gemfile` do Rails.
É similar ao *Builder*, mas é usada para gerar *JSON*, ao invés de *XML*.

Se você não tiver, você pode adicionar o seguinte ao seu `Gemfile`:

```ruby
gem 'jbuilder'
```

Um objeto *Jbuilder* denominado `json` é automaticamente disponibilizado para *templates* com extensão `.jbuilder`.

Aqui está um exemplo básico:

```ruby
json.name("Alex")
json.email("alex@example.com")
```

produziria:

```json
{
  "name": "Alex",
  "email": "alex@example.com"
}
```

Veja a [documentação do Jbuilder](https://github.com/rails/jbuilder#jbuilder) para mais exemplos e informação.

#### Template Caching

Por padrão, o Rails compila cada *template* em um método para renderizá-la. Em ambiente de desenvolvimento, quando você altera um *template*, o Rails verifica a hora de modificação do arquivo e o recompila.

### *Partials*

*Templates* parciais (*partials*) - normalmente chamados apenas de *partials* - são outro instrumento para quebrar o processo de renderização em partes mais gerenciáveis. Com *partials*, você consegue extrair pedaços de código de seus *templates* para separar em arquivos e também reusá-los em seus *templates*.

#### Nomeando *Partials*

Para renderizar uma *partial* como parte de uma *view*, utiliza-se o método `render` dentro da *view*:

```erb
<%= render "menu" %>
```

Isso renderizará o arquivo `_menu.html.erb` naquele ponto dentro da *view* sendo renderizada. Note o caractere de sublinhado no início: as *partials* são nomeadass com um sublinhado no início para distingui-las das *views* regulares, embora sejam referidas sem o sublinhado. Isso é valido mesmo quando utilizamos uma *partial* de uma pasta diferente:

```erb
<%= render "shared/menu" %>
```

Esse código pegará a *partial* de `app/views/shared/_menu.html.erb`.

#### Usando *Partials* para simplificar *Views*

Uma maneira de usar *partials* é tratando-as como se fossem sub-rotinas; uma maneira de mover detalhes para fora da *view* para que você consiga entender o que está acontecendo com mais facilidade. Por exemplo, você pode ter uma *view* parecida com essa:

```html+erb
<%= render "shared/ad_banner" %>

<h1>Products</h1>

<p>Here are a few of our fine products:</p>
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>

<%= render "shared/footer" %>
```

Aqui, as *partials* `_ad_banner.html.erb` e `_footer.html.erb` podem ter conteúdos que são compartilhados entre muitas páginas em sua aplicação. Você não precisa ver os detalhes dessas seções quando estiver se concentrando em uma página específica.

#### `render` sem os parâmetros `partial` e `locals`

No exemplo acima, o método `render` recebe 2 parâmetros: `partial` e `locals`.
Mas se esses forem os únicos parâmetros que você deseja passar, você pode ignorá-los.
Por exemplo, ao invés de:

```erb
<%= render partial: "product", locals: { product: @product } %>
```

Você também pode usar:

```erb
<%= render "product", product: @product %>
```

#### Os parâmetros `as` e `object`

Por padrão o `ActionView::Partials::PartialRenderer` tem seu objeto em uma variável local com o mesmo nome do *template*. Então, dado que:

```erb
<%= render partial: "product" %>
```

dentro da *partial* `_product` nós teremos o `@product` dentro da variável local `product`, como se tivéssemos escrito:

```erb
<%= render partial: "product", locals: { product: @product } %>
```

O parâmetro `object` pode ser usado para especificar diretamente qual objeto é renderizado na *partial*; útil quando o objeto do *template* está em outro lugar (por exemplo, em uma variável de instância diferente ou em uma variável local).

Por exemplo, ao invés de:

```erb
<%= render partial: "product", locals: { product: @item } %>
```

Faríamos:

```erb
<%= render partial: "product", object: @item %>
```

Com o parâmetro `as` nós podemos especificar um nome diferente para a variável local. Por exemplo, se quisermos que seja `item` em vez de `product`, faríamos:

```erb
<%= render partial: "product", object: @item, as: "item" %>
```

Isso é equivalente a:

```erb
<%= render partial: "product", locals: { item: @item } %>
```

#### Renderizando Coleções

É muito comum que um *template* precise iterar sobre uma coleção e renderizar um *sub-template* para cada um dos elementos. Esse padrão foi implementado como um método único que recebe um *array* e renderiza uma *partial* para cada um dos elementos do *array*.

Logo, este exemplo para renderizar todos os produtos:

```erb
<% @products.each do |product| %>
  <%= render partial: "product", locals: { product: product } %>
<% end %>
```

pode ser reescrito em uma linha:

```erb
<%= render partial: "product", collection: @products %>
```

Quando uma *partial* é chamada com uma coleção, as instâncias individuais da *partial* tem acesso ao membro da coleção que está sendo renderizado por meio de uma variável com o mesmo nome da *partial*. Nesse caso, a *partial* é `_product`, e dentro dele você pode se referir a `product` para obter o membro da coleção que está sendo renderizado.

Você pode usar uma sintaxe abreviada para renderizar coleções. Supondo que `@products` é uma coleção de instâncias de `Product`, você pode simplesmente escrever o seguinte para produzir o mesmo resultado:

```erb
<%= render @products %>
```

O Rails determina o nome da *partial* a ser usada observando o nome do *model* na coleção, `Product` neste caso. Na verdade, você pode até renderizar uma coleção composta de instâncias de diferentes *models* usando essa abreviação, e o Rails escolherá a *partial* adequada para cada membro da coleção.

#### *Spacer Templates*

Você também pode especificar uma segunda *partial* a ser renderizada entre as instâncias da *partial* principal usando o parâmetro `:spacer_template`:

```erb
<%= render partial: @products, spacer_template: "product_ruler" %>
```

O Rails renderizará a *partial* `_product_ruler` (sem passar nenhum dado pra ela) entre cada par da *partial* `_product`.

### Layouts

Os *Layouts* podem ser usados para renderizar um *template* em torno dos resultados das *actions* do *controller* do Rails. Normalmente, uma aplicação Rails terá alguns *layouts* nos quais as páginas serão renderizadas. Por exemplo, um site pode ter um *layout* para um usuário conectado e outra página para marketing ou vendas do site. O *layout* do usuário conectado pode incluir navegação de nível superior (*top-level*), que deve estar presente em muitas *actions* do *controller*. O *layout* de vendas de uma aplicação SaaS pode incluir navegação de nível superior para páginas de "Preços" e "Fale conosco", onde esperaria que cada *layout* tivesse uma aparência e sensação diferentes. Você pode ler sobre *layout* com mais detalhes em [Layouts e Renderização no Rails](layouts_and_rendering.html).

Partial Layouts
---------------

Partials can have their own layouts applied to them. These layouts are different from those applied to a controller action, but they work in a similar fashion.

Let's say we're displaying an article on a page which should be wrapped in a `div` for display purposes. Firstly, we'll create a new `Article`:

```ruby
Article.create(body: 'Partial Layouts are cool!')
```

In the `show` template, we'll render the `_article` partial wrapped in the `box` layout:

**articles/show.html.erb**

```erb
<%= render partial: 'article', layout: 'box', locals: { article: @article } %>
```

The `box` layout simply wraps the `_article` partial in a `div`:

**articles/_box.html.erb**

```html+erb
<div class='box'>
  <%= yield %>
</div>
```

Note that the partial layout has access to the local `article` variable that was passed into the `render` call. However, unlike application-wide layouts, partial layouts still have the underscore prefix.

You can also render a block of code within a partial layout instead of calling `yield`. For example, if we didn't have the `_article` partial, we could do this instead:

**articles/show.html.erb**

```html+erb
<% render(layout: 'box', locals: { article: @article }) do %>
  <div>
    <p><%= article.body %></p>
  </div>
<% end %>
```

Supposing we use the same `_box` partial from above, this would produce the same output as the previous example.

View Paths
----------

When rendering a response, the controller needs to resolve where the different
views are located. By default it only looks inside the `app/views` directory.

We can add other locations and give them a certain precedence when resolving
paths using the `prepend_view_path` and `append_view_path` methods.

### Prepend view path

This can be helpful for example, when we want to put views inside a different
directory for subdomains.

We can do this by using:

```ruby
prepend_view_path "app/views/#{request.subdomain}"
```

Then Action View will look first in this directory when resolving views.

### Append view path

Similarly, we can append paths:

```ruby
append_view_path "app/views/direct"
```

This will add `app/views/direct` to the end of the lookup paths.

Helpers
-------

Rails provides many helper methods to use with Action View. These include methods for:

* Formatting dates, strings and numbers
* Creating HTML links to images, videos, stylesheets, etc...
* Sanitizing content
* Creating forms
* Localizing content

You can learn more about helpers in the [Action View Helpers
Guide](action_view_helpers.html) and the [Action View Form Helpers
Guide](form_helpers.html).

Localized Views
---------------

Action View has the ability to render different templates depending on the current locale.

For example, suppose you have an `ArticlesController` with a show action. By default, calling this action will render `app/views/articles/show.html.erb`. But if you set `I18n.locale = :de`, then `app/views/articles/show.de.html.erb` will be rendered instead. If the localized template isn't present, the undecorated version will be used. This means you're not required to provide localized views for all cases, but they will be preferred and used if available.

You can use the same technique to localize the rescue files in your public directory. For example, setting `I18n.locale = :de` and creating `public/500.de.html` and `public/404.de.html` would allow you to have localized rescue pages.

Since Rails doesn't restrict the symbols that you use to set I18n.locale, you can leverage this system to display different content depending on anything you like. For example, suppose you have some "expert" users that should see different pages from "normal" users. You could add the following to `app/controllers/application.rb`:

```ruby
before_action :set_expert_locale

def set_expert_locale
  I18n.locale = :expert if current_user.expert?
end
```

Then you could create special views like `app/views/articles/show.expert.html.erb` that would only be displayed to expert users.

You can read more about the Rails Internationalization (I18n) API [here](i18n.html).
