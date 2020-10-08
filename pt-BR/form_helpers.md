**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Action View Form Helpers
========================

Formulários em uma aplicação web são uma interface essencial para interação do usuário com o sistema. No entanto, pode-se tornar entendiante manter este tipo de marcação devido à necessidade de lidar com a nomenclatura e controles de formulários e seus inúmeros atributos. O Rails acaba com essa complexidade pois há um assistente de exibição que gera uma marcação de formulário. Mas para um uso correto, como há casos de uso diferentes, é necessário que os desenvolvedores conheçam as diferenças entre os métodos auxiliares antes de usá-los.

Depois de ler este guia, você vai saber:

* Como criar formulários de pesquisa e tipos de semelhantes de formulários genéricos que não representam *model* específico da sua aplicação.
* Como criar formulários centrados em *models* pra criar e editar registros específicos no banco de dados.
* Como gerar *select boxes* (caixas de seleção) de vários tipos de dados.
* Que  helpers de data e hora do Rails fornecem.
* O que torna um formulário de upload de arquivo diferente.
* Como publicar formulários para recursos externos e especificar a configuração de um token de autenticidade (`authentic_token`).
* Como criar formulários complexos.

-------------------------------------------------------------------------------------

NOTE: Este guia não pretende ser uma documentação completa dos métodos auxiliares de formulários (*form helpers*) disponíveis e seus argumentos. Por favor para obter uma  referência completa visite [a documentação da API do Rails](https://api.rubyonrails.org/).

Trabalhando com formulários básicos.
------------------------------------

O principal auxiliar de formulário (*form helper*) é o `form_with` .

```erb
<%= form_with do %>
  Conteúdo do formulário
<% end %>
```

Quando chamado sem nenhum argumento como este, é criado uma *tag* de formulário que, quando enviado, fará uma requisição HTTP usando o verbo POST para a página atual. Por exemplo, supondo que a página atual seja a inicial, o HTML gerado terá a seguinte aparência:

```html
<form accept-charset="UTF-8" action="/" data-remote="true" method="post">
  <input name="authenticity_token" type="hidden" value="J7CBxfHalt49OSHp27hblqK20c9PgwJ108nDHX/8Cts=" />
  Form contents
</form>
```

Note que o HTML contém um elemento `input` do tipo `hidden`. Este `input` é importante porque o formulário não pode ser enviado com sucesso sem ele, exceto formulários com método GET. Esse elemento oculto com o nome `authenticity_token` é um recurso de segurança do Rails chamado **proteção contra falsificação de solicitação entre sites** ([**cross-site request forgery protection**](https://pt.wikipedia.org/wiki/Cross-site_request_forgery)), e os *helpers* de formulário o geram para todos os formulários não GET (desde que esse recurso de segurança esteja ativado). Você poderá ler mais sobre isso no guia [Segurança em Aplicações Rails](security.html#cross-site-request-forgery-csrf).

### Formulário de pesquisa genérica

Um dos formulários mais básicos que você vê na web é um formulário de pesquisa. Este formulário contém:

* Um *input* de formulário com o método GET.
* Um *label* para entrada.
* Um *input* de entrada de texto.
* Um *input* de envio.

Para criar este formulário você irá usar `form_with`, `label_tag`, `text_field_tag`, e `submit_tag`, respectivamente. Como o exemplo abaixo:

```erb
<%= form_with(url: "/search", method: "get") do %>
  <%= label_tag(:q, "Search for:") %>
  <%= text_field_tag(:q) %>
  <%= submit_tag("Search") %>
<% end %>
```

Isso irá gerar o seguinte HTML:

```html
<form accept-charset="UTF-8" action="/search" data-remote="true" method="get">
  <label for="q">Search for:</label>
  <input id="q" name="q" type="text" />
  <input name="commit" type="submit" value="Search" data-disable-with="Search" />
</form>
```

TIP: Passando `url: my_speccified_path` para `form_with` indica ao formulário onde fazer a requisição. No entanto, conforme explicado abaixo, você também pode passar objetos ActiveRecord para o formulário.

TIP: Para cada entrada de formulário, um atributo ID é gerado a partir de seu nome("q" no exemplo acima). Esses IDs podem ser muito úteis para estilizar CSS ou manipular controles de formulário com JavaScript.

IMPORTANT: Use "GET" como o método para buscas em formulários. Isso permitirá aos usuários marcar uma busca específica e depois retornar nessa mesma busca. De forma geral, o Rails recomenda que você utilize o verbo correto para a ação desejada.

### Helpers para gerar elementos de formulário

O Rails fornece  uma série de auxiliares para gerar elementos de formulário, como caixas de seleção, campos de texto e botões de opção. Esses auxiliares básicos, com nomes terminados em `_tag`(como `text_field` e `check_box_tag`), geram apenas um único elemento `<input>`. O primeiro parâmetro para estes será sempre o nome da entrada. Quando o formulário for enviado, o nome será passado junto com os dados do formulário e será direcionado para `params` o controlador com o valor inserido pelo usuário para esse campo. Por exemplo, se o formulário contiver `<%= text_field_tag(:query) %>`, podendo obter o valor deste campo no controlador com `params[:query]` .

Ao nomear entradas, o Rails usa certas convenções que possibilitam enviar parâmetros com valores não escalares, como matrizes ou hashes, que também estarão acessíveis `params`. Poderá ser lido mais sobre eles no capítulo [Noções básicas sobre convenções de nomenclatura de parâmetros](#understanding-parameter-naming-conventions) deste guia. Para detalhes de como usar com precisão esses auxiliares, consulte a [documentação da API](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).

#### *Checkboxes* Caixas de seleção

As caixas de seleção são controles de formulário que fornecem ao usuário um conjunto de opções que podem ser ativados ou desativados pelo usuário.

```erb
<%= check_box_tag(:pet_dog) %>
<%= label_tag(:pet_dog, "I own a dog") %>
<%= check_box_tag(:pet_cat) %>
<%= label_tag(:pet_cat, "I own a cat") %>
```

Isso gera o seguinte:

```html
<input id="pet_dog" name="pet_dog" type="checkbox" value="1" />
<label for="pet_dog">I own a dog</label>
<input id="pet_cat" name="pet_cat" type="checkbox" value="1" />
<label for="pet_cat">I own a cat</label>
```

O primeiro parâmetro para `check_box_tag`, é claro, é o nome da entrada. O segundo parâmetro, naturalmente, é o valor da entrada. Este valor será incluído nos dados do formulário (e está presente em `params`) quando a caixa de seleção estiver marcada.

#### *Radio Buttons* Botões de opção

Os botões de opção embora semelhantes às caixas de seleção, são controles que especificam um conjunto de opções mutuamente exclusivos (ou seja, o usuário pode escolher apenas uma).

```erb
<%= radio_button_tag(:age, "child") %>
<%= label_tag(:age_child, "I am younger than 21") %>
<%= radio_button_tag(:age, "adult") %>
<%= label_tag(:age_adult, "I am over 21") %>
```

Resultado:

```html
<input id="age_child" name="age" type="radio" value="child" />
<label for="age_child">I am younger than 21</label>
<input id="age_adult" name="age" type="radio" value="adult" />
<label for="age_adult">I am over 21</label>
```

Assim como `check_box_tag`, o segundo parâmetro para `radio_button_tag` é o valor da entrada. Como esses dois botões compartilham o mesmo nome (`age`), o usuário poderá selecionar apenas um deles, e `params[:age]` receberá `"child"` ou `"adult"`.

NOTE: Sempre use *labels* para a caixa de seleção e botões de opção. Eles associam o texto a uma opção específica e, ao expandir a região clicável, facilita o clique dos usuários nas entradas.

### Outros auxiliares interessantes

Outros controles de formulários que vale a pena falar são áreas de texto, campos de senha, campos ocultos, campos de pesquisa, campos telefônicos, campos de data, campos de hora, campos de cores, campos locais de data e hora, campos de mês, mês, semana, URL, campo de email, número e campos de intervalo:

```erb
<%= text_area_tag(:message, "Hi, nice site", size: "24x6") %>
<%= password_field_tag(:password) %>
<%= hidden_field_tag(:parent_id, "5") %>
<%= search_field(:user, :name) %>
<%= telephone_field(:user, :phone) %>
<%= date_field(:user, :born_on) %>
<%= datetime_local_field(:user, :graduation_day) %>
<%= month_field(:user, :birthday_month) %>
<%= week_field(:user, :birthday_week) %>
<%= url_field(:user, :homepage) %>
<%= email_field(:user, :address) %>
<%= color_field(:user, :favorite_color) %>
<%= time_field(:task, :started_at) %>
<%= number_field(:product, :price, in: 1.0..20.0, step: 0.5) %>
<%= range_field(:product, :discount, in: 1..100) %>
```

Resultado:

```html
<textarea id="message" name="message" cols="24" rows="6">Hi, nice site</textarea>
<input id="password" name="password" type="password" />
<input id="parent_id" name="parent_id" type="hidden" value="5" />
<input id="user_name" name="user[name]" type="search" />
<input id="user_phone" name="user[phone]" type="tel" />
<input id="user_born_on" name="user[born_on]" type="date" />
<input id="user_graduation_day" name="user[graduation_day]" type="datetime-local" />
<input id="user_birthday_month" name="user[birthday_month]" type="month" />
<input id="user_birthday_week" name="user[birthday_week]" type="week" />
<input id="user_homepage" name="user[homepage]" type="url" />
<input id="user_address" name="user[address]" type="email" />
<input id="user_favorite_color" name="user[favorite_color]" type="color" value="#000000" />
<input id="task_started_at" name="task[started_at]" type="time" />
<input id="product_price" max="20.0" min="1.0" name="product[price]" step="0.5" type="number" />
<input id="product_discount" max="100" min="1" name="product[discount]" type="range" />
```

Entradas ocultas não são exibidas ao usuário, mas retêm dados como qualquer entrada de texto. Os valores dentro deles podem ser alterados com JavaScript.

IMPORTANT: As entradas de pesquisa, telefone, data, hora, cor, data e hora local e data, mês, semana, URL, email, número e intervalo são controles HTML5. Se você precisar que sua aplicação tenha uma experiência consistente em navegadores antigos, precisará de um polyfill HTML5 (fornecido por css e/ou JavaScript). Definiticamente, [não faltam soluções disponíveis](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills), embora uma ferramenta popular no momento seja o [Modernizr](https://modernizr.com/), que fornece uma maneira simples de adicionar funcionalidade com base na presença de recursos HTML5 detectados.

TIP: Se você estiver usando campos de entradas de senha (para qualquer finalidade), convêm configurar sua aplicação para impedir que esses parâmetros sejam registrados. Você pode aprender sobre este assunto no guia [Protegendo aplicações Rails](security.html#logging)


Dealing with Model Objects
--------------------------

### Model Object Helpers

A particularly common task for a form is editing or creating a model object. While the `*_tag` helpers can certainly be used for this task they are somewhat verbose as for each tag you would have to ensure the correct parameter name is used and set the default value of the input appropriately. Rails provides helpers tailored to this task. These helpers lack the `_tag` suffix, for example `text_field`, `text_area`.

For these helpers the first argument is the name of an instance variable and the second is the name of a method (usually an attribute) to call on that object. Rails will set the value of the input control to the return value of that method for the object and set an appropriate input name. If your controller has defined `@person` and that person's name is Henry then a form containing:

```erb
<%= text_field(:person, :name) %>
```

will produce output similar to

```erb
<input id="person_name" name="person[name]" type="text" value="Henry" />
```

Upon form submission the value entered by the user will be stored in `params[:person][:name]`.

WARNING: You must pass the name of an instance variable, i.e. `:person` or `"person"`, not an actual instance of your model object.

Rails provides helpers for displaying the validation errors associated with a model object. These are covered in detail by the [Active Record Validations](active_record_validations.html#displaying-validation-errors-in-views) guide.

### Binding a Form to an Object

While this is an increase in comfort it is far from perfect. If `Person` has many attributes to edit then we would be repeating the name of the edited object many times. What we want to do is somehow bind a form to a model object, which is exactly what `form_with` with `:model` does.

Assume we have a controller for dealing with articles `app/controllers/articles_controller.rb`:

```ruby
def new
  @article = Article.new
end
```

The corresponding view `app/views/articles/new.html.erb` using `form_with` looks like this:

```erb
<%= form_with model: @article, class: "nifty_form" do |f| %>
  <%= f.text_field :title %>
  <%= f.text_area :body, size: "60x12" %>
  <%= f.submit "Create" %>
<% end %>
```

There are a few things to note here:

* `@article` is the actual object being edited.
* There is a single hash of options. HTML options (except `id` and `class`) are passed in the `:html` hash. Also you can provide a `:namespace` option for your form to ensure uniqueness of id attributes on form elements. The scope attribute will be prefixed with underscore on the generated HTML id.
* The `form_with` method yields a **form builder** object (the `f` variable).
* If you wish to direct your form request to a particular URL, you would use `form_with url: my_nifty_url_path` instead. To see more in depth options on what `form_with` accepts be sure to [check out the API documentation](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with).
* Methods to create form controls are called **on** the form builder object `f`.

The resulting HTML is:

```html
<form class="nifty_form" action="/articles" accept-charset="UTF-8" data-remote="true" method="post">
  <input type="hidden" name="authenticity_token" value="NRkFyRWxdYNfUg7vYxLOp2SLf93lvnl+QwDWorR42Dp6yZXPhHEb6arhDOIWcqGit8jfnrPwL781/xlrzj63TA==" />
  <input type="text" name="article[title]" id="article_title" />
  <textarea name="article[body]" id="article_body" cols="60" rows="12"></textarea>
  <input type="submit" name="commit" value="Create" data-disable-with="Create" />
</form>
```

The object passed as `:model` in `form_with` controls the key used in `params` to access the form's values. Here the name is `article` and so all the inputs have names of the form `article[attribute_name]`. Accordingly, in the `create` action `params[:article]` will be a hash with keys `:title` and `:body`. You can read more about the significance of input names in chapter [Understanding Parameter Naming Conventions](#understanding-parameter-naming-conventions) of this guide.

TIP: Conventionally your inputs will mirror model attributes. However, they don't have to! If there is other information you need you can include it in your form just as with attributes and access it via `params[:article][:my_nifty_non_attribute_input]`.

The helper methods called on the form builder are identical to the model object helpers except that it is not necessary to specify which object is being edited since this is already managed by the form builder.

You can create a similar binding without actually creating `<form>` tags with the `fields_for` helper. This is useful for editing additional model objects with the same form. For example, if you had a `Person` model with an associated `ContactDetail` model, you could create a form for creating both like so:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <%= fields_for :contact_detail, @person.contact_detail do |contact_detail_form| %>
    <%= contact_detail_form.text_field :phone_number %>
  <% end %>
<% end %>
```

which produces the following output:

```html
<form action="/people" accept-charset="UTF-8" data-remote="true" method="post">
  <input type="hidden" name="authenticity_token" value="bL13x72pldyDD8bgtkjKQakJCpd4A8JdXGbfksxBDHdf1uC0kCMqe2tvVdUYfidJt0fj3ihC4NxiVHv8GVYxJA==" />
  <input type="text" name="person[name]" id="person_name" />
  <input type="text" name="contact_detail[phone_number]" id="contact_detail_phone_number" />
</form>
```

The object yielded by `fields_for` is a form builder like the one yielded by `form_with`.

### Relying on Record Identification

The Article model is directly available to users of the application, so - following the best practices for developing with Rails - you should declare it **a resource**:

```ruby
resources :articles
```

TIP: Declaring a resource has a number of side effects. See [Rails Routing from the Outside In](routing.html#resource-routing-the-rails-default) guide for more information on setting up and using resources.

When dealing with RESTful resources, calls to `form_with` can get significantly easier if you rely on **record identification**. In short, you can just pass the model instance and have Rails figure out model name and the rest:

```ruby
## Creating a new article
# long-style:
form_with(model: @article, url: articles_path)
# short-style:
form_with(model: @article)

## Editing an existing article
# long-style:
form_with(model: @article, url: article_path(@article), method: "patch")
# short-style:
form_with(model: @article)
```

Notice how the short-style `form_with` invocation is conveniently the same, regardless of the record being new or existing. Record identification is smart enough to figure out if the record is new by asking `record.persisted?`. It also selects the correct path to submit to, and the name based on the class of the object.

WARNING: When you're using STI (single-table inheritance) with your models, you can't rely on record identification on a subclass if only their parent class is declared a resource. You will have to specify `:url`, and `:scope` (the model name) explicitly.

#### Dealing with Namespaces

If you have created namespaced routes, `form_with` has a nifty shorthand for that too. If your application has an admin namespace then

```ruby
form_with model: [:admin, @article]
```

will create a form that submits to the `ArticlesController` inside the admin namespace (submitting to `admin_article_path(@article)` in the case of an update). If you have several levels of namespacing then the syntax is similar:

```ruby
form_with model: [:admin, :management, @article]
```

For more information on Rails' routing system and the associated conventions, please see [Rails Routing from the Outside In](routing.html) guide.

### How do forms with PATCH, PUT, or DELETE methods work?

The Rails framework encourages RESTful design of your applications, which means you'll be making a lot of "PATCH", "PUT", and "DELETE" requests (besides "GET" and "POST"). However, most browsers _don't support_ methods other than "GET" and "POST" when it comes to submitting forms.

Rails works around this issue by emulating other methods over POST with a hidden input named `"_method"`, which is set to reflect the desired method:

```ruby
form_with(url: search_path, method: "patch")
```

Resultado:

```html
<form accept-charset="UTF-8" action="/search" data-remote="true" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  ...
</form>
```

When parsing POSTed data, Rails will take into account the special `_method` parameter and act as if the HTTP method was the one specified inside it ("PATCH" in this example).

IMPORTANT: All forms using `form_with` implement `remote: true` by default. These forms will submit data using an XHR (Ajax) request. To disable this include `local: true`. To dive deeper see [Working with JavaScript in Rails](working_with_javascript_in_rails.html#remote-elements) guide.

Criando Caixas de Seleção (*Select Boxes*) com Facilidade
-----------------------------

As caixas de seleção em HTML requerem uma quantidade significativa de marcação (um elemento `OPTION` para cada opção de escolha), portanto, faz mais sentido que sejam geradas dinamicamente. 

Esta é a aparência da marcação:
```html
<select name="city_id" id="city_id">
  <option value="1">Lisbon</option>
  <option value="2">Madrid</option>
  <option value="3">Berlin</option>
</select>
```

Aqui você tem uma lista de cidades cujos nomes são apresentados ao usuário. Internamente, o aplicativo deseja apenas manipular seus IDs, para que sejam usados como o atributo de valor das opções. Vamos ver como o Rails pode ajudar aqui.

### As Tags de Seleção (*Select*) e Opção (*Option*)

O *helper* mais genérico é `select_tag`, que - como o nome indica - simplesmente gera a tag `SELECT` que encapsula uma *string* de opções:

```erb
<%= select_tag(:city_id, raw('<option value="1">Lisbon</option><option value="2">Madrid</option><option value="3">Berlin</option>')) %>
```

Isso é um começo, porém o *helper* `select_tag` não cria as tags de opção dinamicamente. Você pode gerar tags de opção com o *helper* `options_for_select`:

```html+erb
<%= options_for_select([['Lisbon', 1], ['Madrid', 2], ['Berlin', 3]]) %>
```

Resultado:

```html
<option value="1">Lisbon</option>
<option value="2">Madrid</option>
<option value="3">Berlin</option>
```

O primeiro argumento para `options_for_select` é um *array* aninhado onde cada elemento tem dois elementos: texto da opção (nome da cidade) e valor da opção (id da cidade). O valor da opção é o que será enviado ao seu *controller*. Frequentemente, esse será o id de um objeto de banco de dados correspondente, mas não precisa ser o caso.

Sabendo disso, é possível combinar `select_tag` e `options_for_select` para obter a marcação completa desejada:

```erb
<%= select_tag(:city_id, options_for_select(...)) %>
```

`options_for_select` permite pré-selecionar uma opção passando seu valor.

```html+erb
<%= options_for_select([['Lisbon', 1], ['Madrid', 2], ['Berlin', 3]], 2) %>
```

Resultado:

```html
<option value="1">Lisbon</option>
<option value="2" selected="selected">Madrid</option>
<option value="3">Berlin</option>
```

Sempre que o Rails vê que o valor interno de uma opção sendo gerada corresponde a este valor, ele adicionará o atributo `selected` aquela opção.

É possível adicionar atributos arbitrários às opções usando hashes:

```html+erb
<%= options_for_select(
  [
    ['Lisbon', 1, { 'data-size' => '2.8 million' }],
    ['Madrid', 2, { 'data-size' => '3.2 million' }],
    ['Berlin', 3, { 'data-size' => '3.4 million' }]
  ], 2
) %>
```

Resultado:

```html
<option value="1" data-size="2.8 million">Lisbon</option>
<option value="2" selected="selected" data-size="3.2 million">Madrid</option>
<option value="3" data-size="3.4 million">Berlin</option>
```

### Caixas de Seleção (*Select Boxes*) com Objetos *Model*

Na maioria dos casos, os controles de formulário serão vinculados a um *model* específico e, como você pode esperar, o Rails fornece *helpers* personalizados para esse propósito. Consistente com outros *helpers* de formulário, ao lidar com um objeto de *model* elimine o sufixo `_tag` de `select_tag`:

Se o *controller* definiu `@person` e o `city_id` dessa pessoa é 2:

```ruby
@person = Person.new(city_id: 2)
```

```erb
<%= select(:person, :city_id, [['Lisbon', 1], ['Madrid', 2], ['Berlin', 3]]) %>
```

produz um resultado semelhante a

```html
<select name="person[city_id]" id="person_city_id">
  <option value="1">Lisbon</option>
  <option value="2" selected="selected">Madrid</option>
  <option value="3">Berlin</option>
</select>
```

Observe que o terceiro parâmetro, o *array* de opções, é o mesmo tipo de argumento que você passa para `options_for_select`. Uma vantagem aqui é que você não precisa se preocupar em pré-selecionar a cidade correta se o usuário já tiver uma - o Rails fará isso para você lendo o atributo `@person.city_id`.

Tal como acontece com outros *helpers*, se você fosse usar o *helper* `select` em um construtor de formulário com escopo para o objeto `@person`, a sintaxe seria:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.select(:city_id, [['Lisbon', 1], ['Madrid', 2], ['Berlin', 3]]) %>
<% end %>
```

Você também pode passar um bloco para o *helper* `select`:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.select(:city_id) do %>
    <% [['Lisbon', 1], ['Madrid', 2], ['Berlin', 3]].each do |c| %>
      <%= content_tag(:option, c.first, value: c.last) %>
    <% end %>
  <% end %>
<% end %>
```

WARNING: Se você estiver usando `select` ou *helpers* semelhantes para definir uma associação `belongs_to`, você deve passar o nome da chave estrangeira (no exemplo acima `city_id`), não o nome da própria associação.

WARNING: Quando `:include_blank` ou `:prompt` não estão presentes, `:include_blank` é forçado a *true* se o atributo de seleção `required` for *true*, display `size` é um e `multiple` não é *true*.

### Tags de Opção (*Option Tags*) de uma Coleção de Objetos Arbitrários

Gerar tags de opções com `options_for_select` requer que você crie um *array* contendo o texto e valor para cada opção. Mas e se você tivesse um *model* `City` (talvez um Active Record) e quisesse gerar tags de opção de uma coleção desses objetos? Uma solução seria fazer um *array* aninhada iterando sobre eles:

```erb
<% cities_array = City.all.map { |city| [city.name, city.id] } %>
<%= options_for_select(cities_array) %>
```

Esta é uma solução perfeitamente válida, entretanto o Rails fornece uma alternativa menos verbosa: `options_from_collection_for_select`. Este *helper* espera uma coleção de objetos arbitrários e dois argumentos adicionais: os nomes dos métodos para ler a opção **value** e **text**, respectivamente:

```erb
<%= options_from_collection_for_select(City.all, :id, :name) %>
```

Como o nome indica, isso só gera *tags* de opção. Para gerar uma *select box* funcional, você precisará usar `collection_select`:

```erb
<%= collection_select(:person, :city_id, City.all, :id, :name) %>
```

Como com outros *helpers*, se você fosse usar o *helper* `collection_select` em um construtor de formulário com escopo para o objeto `@person`, a sintaxe seria:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.collection_select(:city_id, City.all, :id, :name) %>
<% end %>
```

NOTE: Pares passados para `options_for_select` devem ter o texto primeiro e o valor depois, entretanto, com `options_from_collection_for_select` devem ter o método do valor primeiro e o método do texto depois.

### Fuso horário e Seleção de País

Para usar o suporte de fuso horário no Rails, você tem que perguntar aos seus usuários em que fuso horário eles estão. Fazer isso exigiria a geração de opções selecionadas de uma lista de objetos *[`ActiveSupport::TimeZone`](https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html)* usando `collection_select`, mas você pode simplesmente usar o *helper* `time_zone_select` que já envolve isto:

```erb
<%= time_zone_select(:person, :time_zone) %>
```

Existe também o *helper* `time_zone_options_for_select` para uma maneira mais manual (portanto mais customizável) de fazer isso. Leia a [documentação da API](https://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-time_zone_options_for_select) para aprender sobre os possíveis argumentos para esses dois métodos.

O Rails tinha um *helper* `country_select` para escolher os países, mas foi extraído para o [plugin country_select](https://github.com/stefanpenner/country_select).

Using Date and Time Form Helpers
--------------------------------

You can choose not to use the form helpers generating HTML5 date and time input fields and use the alternative date and time helpers. These date and time helpers differ from all the other form helpers in two important respects:

* Dates and times are not representable by a single input element. Instead, you have several, one for each component (year, month, day etc.) and so there is no single value in your `params` hash with your date or time.
* Other helpers use the `_tag` suffix to indicate whether a helper is a barebones helper or one that operates on model objects. With dates and times, `select_date`, `select_time` and `select_datetime` are the barebones helpers, `date_select`, `time_select` and `datetime_select` are the equivalent model object helpers.

Both of these families of helpers will create a series of select boxes for the different components (year, month, day etc.).

### Barebones Helpers

The `select_*` family of helpers take as their first argument an instance of `Date`, `Time`, or `DateTime` that is used as the currently selected value. You may omit this parameter, in which case the current date is used. For example:

```erb
<%= select_date Date.today, prefix: :start_date %>
```

outputs (with actual option values omitted for brevity)

```html
<select id="start_date_year" name="start_date[year]">
</select>
<select id="start_date_month" name="start_date[month]">
</select>
<select id="start_date_day" name="start_date[day]">
</select>
```

The above inputs would result in `params[:start_date]` being a hash with keys `:year`, `:month`, `:day`. To get an actual `Date`, `Time`, or `DateTime` object you would have to extract these values and pass them to the appropriate constructor, for example:

```ruby
Date.civil(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i)
```

The `:prefix` option is the key used to retrieve the hash of date components from the `params` hash. Here it was set to `start_date`, if omitted it will default to `date`.

### Model Object Helpers

`select_date` does not work well with forms that update or create Active Record objects as Active Record expects each element of the `params` hash to correspond to one attribute.
The model object helpers for dates and times submit parameters with special names; when Active Record sees parameters with such names it knows they must be combined with the other parameters and given to a constructor appropriate to the column type. For example:

```erb
<%= date_select :person, :birth_date %>
```

outputs (with actual option values omitted for brevity)

```html
<select id="person_birth_date_1i" name="person[birth_date(1i)]">
</select>
<select id="person_birth_date_2i" name="person[birth_date(2i)]">
</select>
<select id="person_birth_date_3i" name="person[birth_date(3i)]">
</select>
```

which results in a `params` hash like

```ruby
{'person' => {'birth_date(1i)' => '2008', 'birth_date(2i)' => '11', 'birth_date(3i)' => '22'}}
```

When this is passed to `Person.new` (or `update`), Active Record spots that these parameters should all be used to construct the `birth_date` attribute and uses the suffixed information to determine in which order it should pass these parameters to functions such as `Date.civil`.

### Common Options

Both families of helpers use the same core set of functions to generate the individual select tags and so both accept largely the same options. In particular, by default Rails will generate year options 5 years either side of the current year. If this is not an appropriate range, the `:start_year` and `:end_year` options override this. For an exhaustive list of the available options, refer to the [API documentation](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html).

As a rule of thumb you should be using `date_select` when working with model objects and `select_date` in other cases, such as a search form which filters results by date.

### Individual Components

Occasionally you need to display just a single date component such as a year or a month. Rails provides a series of helpers for this, one for each component `select_year`, `select_month`, `select_day`, `select_hour`, `select_minute`, `select_second`. These helpers are fairly straightforward. By default they will generate an input field named after the time component (for example, "year" for `select_year`, "month" for `select_month` etc.) although this can be overridden with the `:field_name` option. The `:prefix` option works in the same way that it does for `select_date` and `select_time` and has the same default value.

The first parameter specifies which value should be selected and can either be an instance of a `Date`, `Time`, or `DateTime`, in which case the relevant component will be extracted, or a numerical value. For example:

```erb
<%= select_year(2009) %>
<%= select_year(Time.new(2009)) %>
```

will produce the same output and the value chosen by the user can be retrieved by `params[:date][:year]`.

Uploading Files
---------------

A common task is uploading some sort of file, whether it's a picture of a person or a CSV file containing data to process. The most important thing to remember with file uploads is that the rendered form's enctype attribute **must** be set to "multipart/form-data". If you use `form_with` with `:model`, this is done automatically. If you use `form_with` without `:model`, you must set it yourself, as per the following example.

The following two forms both upload a file.

```erb
<%= form_with(url: {action: :upload}, multipart: true) do %>
  <%= file_field_tag 'picture' %>
<% end %>

<%= form_with model: @person do |f| %>
  <%= f.file_field :picture %>
<% end %>
```

Rails provides the usual pair of helpers: the barebones `file_field_tag` and the model oriented `file_field`. As you would expect in the first case the uploaded file is in `params[:picture]` and in the second case in `params[:person][:picture]`.

### What Gets Uploaded

The object in the `params` hash is an instance of [`ActionDispatch::Http::UploadedFile`](https://api.rubyonrails.org/classes/ActionDispatch/Http/UploadedFile.html). The following snippet saves the uploaded file in `#{Rails.root}/public/uploads` under the same name as the original file.

```ruby
def upload
  uploaded_file = params[:picture]
  File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
    file.write(uploaded_file.read)
  end
end
```

Once a file has been uploaded, there are a multitude of potential tasks, ranging from where to store the files (on Disk, Amazon S3, etc), associating them with models, resizing image files, and generating thumbnails, etc. [Active Storage](active_storage_overview.html) is designed to assist with these tasks.

Customizando os Construtores de Formulários
-------------------------

O objeto que é dado para o *yield* no `form_with` e `fields_for` é uma instância de
[`ActionView::Helpers::FormBuilder`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html).
Construtores de Formulários encapsulam a noção de exibir os elementos do formulário para um único objeto.
Enquanto você pode escrever *helpers* para seus formulários da forma usual, você também pode criar uma subclasse
de `ActionView::Helpers::FormBuilder` e adicionar os *helpers* lá. Por exemplo:

```erb
<%= form_with model: @person do |f| %>
  <%= text_field_with_label f, :first_name %>
<% end %>
```

pode ser substituído por

```erb
<%= form_with model: @person, builder: LabellingFormBuilder do |f| %>
  <%= f.text_field :first_name %>
<% end %>
```

Por meio da definição de uma classe `LabellingFormBuilder` parecida com a que segue:

```ruby
class LabellingFormBuilder < ActionView::Helpers::FormBuilder
  def text_field(attribute, options={})
    label(attribute) + super
  end
end
```

Se você reutilizar isso frequentemente, você pode definir um *helper* `labeled_form_with` que automaticamente
aplica a opção `builder: LabellingFormBuilder`:

```ruby
def labeled_form_with(model: nil, scope: nil, url: nil, format: nil, **options, &block)
  options.merge! builder: LabellingFormBuilder
  form_with model: model, scope: scope, url: url, format: format, **options, &block
end
```

O construtor de formulários utilizado também determina o que acontece quando você escreve

```erb
<%= render partial: f %>
```

Se `f` for uma instância de `ActionView::Helpers::FormBuilder` então isso vai renderizar a *partial* `form`,
passando o objeto da *partial* para o construtor de formulários. Se o construtor de formulário for da classe
`LabellingFormBuilder` então a partial `labelling_form` é que seria renderizada.

Understanding Parameter Naming Conventions
------------------------------------------

Values from forms can be at the top level of the `params` hash or nested in another hash. For example, in a standard `create` action for a Person model, `params[:person]` would usually be a hash of all the attributes for the person to create. The `params` hash can also contain arrays, arrays of hashes, and so on.

Fundamentally HTML forms don't know about any sort of structured data, all they generate is name-value pairs, where pairs are just plain strings. The arrays and hashes you see in your application are the result of some parameter naming conventions that Rails uses.

### Basic Structures

The two basic structures are arrays and hashes. Hashes mirror the syntax used for accessing the value in `params`. For example, if a form contains:

```html
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

the `params` hash will contain

```ruby
{'person' => {'name' => 'Henry'}}
```

and `params[:person][:name]` will retrieve the submitted value in the controller.

Hashes can be nested as many levels as required, for example:

```html
<input id="person_address_city" name="person[address][city]" type="text" value="New York"/>
```

will result in the `params` hash being

```ruby
{'person' => {'address' => {'city' => 'New York'}}}
```

Normally Rails ignores duplicate parameter names. If the parameter name contains an empty set of square brackets `[]` then they will be accumulated in an array. If you wanted users to be able to input multiple phone numbers, you could place this in the form:

```html
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
```

This would result in `params[:person][:phone_number]` being an array containing the inputted phone numbers.

### Combining Them

We can mix and match these two concepts. One element of a hash might be an array as in the previous example, or you can have an array of hashes. For example, a form might let you create any number of addresses by repeating the following form fragment

```html
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
```

This would result in `params[:person][:addresses]` being an array of hashes with keys `line1`, `line2`, and `city`.

There's a restriction, however, while hashes can be nested arbitrarily, only one level of "arrayness" is allowed. Arrays can usually be replaced by hashes; for example, instead of having an array of model objects, one can have a hash of model objects keyed by their id, an array index, or some other parameter.

WARNING: Array parameters do not play well with the `check_box` helper. According to the HTML specification unchecked checkboxes submit no value. However it is often convenient for a checkbox to always submit a value. The `check_box` helper fakes this by creating an auxiliary hidden input with the same name. If the checkbox is unchecked only the hidden input is submitted and if it is checked then both are submitted but the value submitted by the checkbox takes precedence.

### Using Form Helpers

The previous sections did not use the Rails form helpers at all. While you can craft the input names yourself and pass them directly to helpers such as `text_field_tag` Rails also provides higher level support. The two tools at your disposal here are the name parameter to `form_with` and `fields_for` and the `:index` option that helpers take.

You might want to render a form with a set of edit fields for each of a person's addresses. For example:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <% @person.addresses.each do |address| %>
    <%= person_form.fields_for address, index: address.id do |address_form| %>
      <%= address_form.text_field :city %>
    <% end %>
  <% end %>
<% end %>
```

Assuming the person had two addresses, with ids 23 and 45 this would create output similar to this:

```html
<form accept-charset="UTF-8" action="/people/1" data-remote="true" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input id="person_name" name="person[name]" type="text" />
  <input id="person_address_23_city" name="person[address][23][city]" type="text" />
  <input id="person_address_45_city" name="person[address][45][city]" type="text" />
</form>
```

This will result in a `params` hash that looks like

```ruby
{'person' => {'name' => 'Bob', 'address' => {'23' => {'city' => 'Paris'}, '45' => {'city' => 'London'}}}}
```

Rails knows that all these inputs should be part of the person hash because you
called `fields_for` on the first form builder. By specifying an `:index` option
you're telling Rails that instead of naming the inputs `person[address][city]`
it should insert that index surrounded by [] between the address and the city.
This is often useful as it is then easy to locate which Address record
should be modified. You can pass numbers with some other significance,
strings or even `nil` (which will result in an array parameter being created).

To create more intricate nestings, you can specify the first part of the input
name (`person[address]` in the previous example) explicitly:

```erb
<%= fields_for 'person[address][primary]', address, index: address.id do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

will create inputs like

```html
<input id="person_address_primary_1_city" name="person[address][primary][1][city]" type="text" value="Bologna" />
```

As a general rule the final input name is the concatenation of the name given to `fields_for`/`form_with`, the index value, and the name of the attribute. You can also pass an `:index` option directly to helpers such as `text_field`, but it is usually less repetitive to specify this at the form builder level rather than on individual input controls.

As a shortcut you can append [] to the name and omit the `:index` option. This is the same as specifying `index: address.id` so

```erb
<%= fields_for 'person[address][primary][]', address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

produces exactly the same output as the previous example.

Forms to External Resources
---------------------------

Rails' form helpers can also be used to build a form for posting data to an external resource. However, at times it can be necessary to set an `authenticity_token` for the resource; this can be done by passing an `authenticity_token: 'your_external_token'` parameter to the `form_with` options:

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: 'external_token' do %>
  Form contents
<% end %>
```

Sometimes when submitting data to an external resource, like a payment gateway, the fields that can be used in the form are limited by an external API and it may be undesirable to generate an `authenticity_token`. To not send a token, simply pass `false` to the `:authenticity_token` option:

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: false do %>
  Form contents
<% end %>
```

Building Complex Forms
----------------------

Many apps grow beyond simple forms editing a single object. For example, when creating a `Person` you might want to allow the user to (on the same form) create multiple address records (home, work, etc.). When later editing that person the user should be able to add, remove, or amend addresses as necessary.

### Configuring the Model

Active Record provides model level support via the `accepts_nested_attributes_for` method:

```ruby
class Person < ApplicationRecord
  has_many :addresses, inverse_of: :person
  accepts_nested_attributes_for :addresses
end

class Address < ApplicationRecord
  belongs_to :person
end
```

This creates an `addresses_attributes=` method on `Person` that allows you to create, update, and (optionally) destroy addresses.

### Nested Forms

The following form allows a user to create a `Person` and its associated addresses.

```html+erb
<%= form_with model: @person do |f| %>
  Addresses:
  <ul>
    <%= f.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>

        <%= addresses_form.label :street %>
        <%= addresses_form.text_field :street %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```


When an association accepts nested attributes `fields_for` renders its block once for every element of the association. In particular, if a person has no addresses it renders nothing. A common pattern is for the controller to build one or more empty children so that at least one set of fields is shown to the user. The example below would result in 2 sets of address fields being rendered on the new person form.

```ruby
def new
  @person = Person.new
  2.times { @person.addresses.build }
end
```

The `fields_for` yields a form builder. The parameters' name will be what
`accepts_nested_attributes_for` expects. For example, when creating a user with
2 addresses, the submitted parameters would look like:

```ruby
{
  'person' => {
    'name' => 'John Doe',
    'addresses_attributes' => {
      '0' => {
        'kind' => 'Home',
        'street' => '221b Baker Street'
      },
      '1' => {
        'kind' => 'Office',
        'street' => '31 Spooner Street'
      }
    }
  }
}
```

The keys of the `:addresses_attributes` hash are unimportant, they need merely be different for each address.

If the associated object is already saved, `fields_for` autogenerates a hidden input with the `id` of the saved record. You can disable this by passing `include_id: false` to `fields_for`.

### The Controller

As usual you need to
[declare the permitted parameters](action_controller_overview.html#strong-parameters) in
the controller before you pass them to the model:

```ruby
def create
  @person = Person.new(person_params)
  # ...
end

private
  def person_params
    params.require(:person).permit(:name, addresses_attributes: [:id, :kind, :street])
  end
```

### Removing Objects

You can allow users to delete associated objects by passing `allow_destroy: true` to `accepts_nested_attributes_for`

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, allow_destroy: true
end
```

If the hash of attributes for an object contains the key `_destroy` with a value that
evaluates to `true` (eg. 1, '1', true, or 'true') then the object will be destroyed.
This form allows users to remove addresses:

```erb
<%= form_with model: @person do |f| %>
  Addresses:
  <ul>
    <%= f.fields_for :addresses do |addresses_form| %>
      <li>
        <%= addresses_form.check_box :_destroy %>
        <%= addresses_form.label :kind %>
        <%= addresses_form.text_field :kind %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

Don't forget to update the permitted params in your controller to also include
the `_destroy` field:

```ruby
def person_params
  params.require(:person).
    permit(:name, addresses_attributes: [:id, :kind, :street, :_destroy])
end
```

### Preventing Empty Records

It is often useful to ignore sets of fields that the user has not filled in. You can control this by passing a `:reject_if` proc to `accepts_nested_attributes_for`. This proc will be called with each hash of attributes submitted by the form. If the proc returns `false` then Active Record will not build an associated object for that hash. The example below only tries to build an address if the `kind` attribute is set.

```ruby
class Person < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :addresses, reject_if: lambda {|attributes| attributes['kind'].blank?}
end
```

As a convenience you can instead pass the symbol `:all_blank` which will create a proc that will reject records where all the attributes are blank excluding any value for `_destroy`.

### Adding Fields on the Fly

Rather than rendering multiple sets of fields ahead of time you may wish to add them only when a user clicks on an 'Add new address' button. Rails does not provide any built-in support for this. When generating new sets of fields you must ensure the key of the associated array is unique - the current JavaScript date (milliseconds since the [epoch](https://en.wikipedia.org/wiki/Unix_time)) is a common choice.

Usando `form_for` e `form_tag`
---------------------------

Antes do `form_with` ser introduzido no Rails 5.1 sua funcionalidade costumava ser divida entre `form_tag` e `form_for`. Ambos estão agora depreciados (_soft-deprecated_). A documentação sobre seu uso pode ser encontrada na [versão antiga deste guia](https://guides.rubyonrails.org/v5.2/form_helpers.html).
