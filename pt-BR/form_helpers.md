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

O principal auxiliar de formulário (*form helper*) é o [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with).

```erb
<%= form_with do |form| %>
  Conteúdo do formulário
<% end %>
```

Quando chamado sem nenhum argumento como este, é criado uma *tag* de formulário que, quando enviado, fará uma requisição HTTP usando o verbo POST para a página atual. Por exemplo, supondo que a página atual seja a inicial, o HTML gerado terá a seguinte aparência:

```html
<form accept-charset="UTF-8" action="/" method="post">
  <input name="authenticity_token" type="hidden" value="J7CBxfHalt49OSHp27hblqK20c9PgwJ108nDHX/8Cts=" />
  Form contents
</form>
```

Note que o HTML contém um elemento `input` do tipo `hidden`. Este `input` é importante porque os formulários não podem ser enviados com sucesso sem ele, exceto formulários com método GET. Esse elemento oculto com o nome `authenticity_token` é um recurso de segurança do Rails chamado **proteção contra falsificação de solicitação entre sites** ([**cross-site request forgery protection**](https://pt.wikipedia.org/wiki/Cross-site_request_forgery)), e os *helpers* de formulário o geram para todos os formulários não GET (desde que esse recurso de segurança esteja ativado). Você poderá ler mais sobre isso no guia [Segurança em Aplicações Rails](security.html#cross-site-request-forgery-csrf).

### Formulário de pesquisa genérica

Um dos formulários mais básicos que você vê na web é um formulário de pesquisa. Este formulário contém:

* Um *input* de formulário com o método GET.
* Um *label* para entrada.
* Um *input* de entrada de texto.
* Um *input* de envio.

Para criar este formulário você usará `form_with` e o objeto para contrução de formulário que o método nos dá. Como o exemplo abaixo:

```erb
<%= form_with url: "/search", method: :get do |form| %>
  <%= form.label :query, "Search for:" %>
  <%= form.text_field :query %>
  <%= form.submit "Search" %>
<% end %>
```

Isso irá gerar o seguinte HTML:

```html
<form action="/search" method="get" accept-charset="UTF-8" >
  <label for="query">Search for:</label>
  <input id="query" name="query" type="text" />
  <input name="commit" type="submit" value="Search" data-disable-with="Search" />
</form>
```

TIP: Passando `url: my_speccified_path` para `form_with` indica ao formulário onde fazer a requisição. No entanto, conforme explicado abaixo, você também pode passar objetos ActiveRecord para o formulário.

TIP: Para cada entrada de formulário, um atributo ID é gerado a partir de seu nome ("query" no exemplo acima). Esses IDs podem ser muito úteis para estilizar CSS ou manipular controles de formulário com JavaScript.

IMPORTANT: Use "GET" como o método para buscas em formulários. Isso permitirá aos usuários marcar uma busca específica e depois retornar nessa mesma busca. De forma geral, o Rails recomenda que você utilize o verbo correto para a ação desejada.

### Helpers para gerar elementos de formulário

O objeto construtor de formulário gerado pelo `form_with` fornece vários métodos auxiliares para gerar elementos de formulário, como campos de texto, caixas de seleção (*checkboxes*) e botões de rádio (*radio buttons*). O primeiro parâmetro para esses métodos é sempre o nome do *input*. Quando o formulário for enviado, o nome será passado junto com os dados do formulário e será direcionado para `params` o controlador com o valor inserido pelo usuário para esse campo. Por exemplo, se o formulário contiver `<%= form.text_field :query %>`, podendo obter o valor deste campo no controlador com `params[:query]` .

Ao nomear entradas, o Rails usa certas convenções que possibilitam enviar parâmetros com valores não escalares, como matrizes ou hashes, que também estarão acessíveis `params`. Poderá ser lido mais sobre eles no capítulo [Noções básicas sobre convenções de nomenclatura de parâmetros](#entendendo-convencoes-de-nomeacao-de-parametros) deste guia. Para detalhes de como usar com precisão esses auxiliares, consulte a [documentação da API](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).

#### *Checkboxes* Caixas de seleção

As caixas de seleção são controles de formulário que fornecem ao usuário um conjunto de opções que podem ser ativados ou desativados pelo usuário.

```erb
<%= form.check_box :pet_dog %>
<%= form.label :pet_dog, "I own a dog" %>
<%= form.check_box :pet_cat %>
<%= form.label :pet_cat, "I own a cat" %>
```

Isso gera o seguinte:

```html
<input type="checkbox" id="pet_dog" name="pet_dog" value="1" />
<label for="pet_dog">I own a dog</label>
<input type="checkbox" id="pet_cat" name="pet_cat" value="1" />
<label for="pet_cat">I own a cat</label>
```

O primeiro parâmetro para [`check_box`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-check_box), é o nome da entrada. O segundo parâmetro, é o valor da entrada. Este valor será incluído nos dados do formulário (e está presente em `params`) quando a caixa de seleção estiver marcada.

#### *Radio Buttons* Botões de opção

Os botões de opção embora semelhantes às caixas de seleção, são controles que especificam um conjunto de opções mutuamente exclusivos (ou seja, o usuário pode escolher apenas uma).

```erb
<%= form.radio_button :age, "child" %>
<%= form.label :age_child, "I am younger than 21" %>
<%= form.radio_button :age, "adult" %>
<%= form.label :age_adult, "I am over 21" %>
```

Resultado:

```html
<input type="radio" id="age_child" name="age" value="child" />
<label for="age_child">I am younger than 21</label>
<input type="radio" id="age_adult" name="age" value="adult" />
<label for="age_adult">I am over 21</label>
```

Assim como `check_box`, o segundo parâmetro para [`radio_button`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-radio_button) é o valor da entrada. Como esses dois botões compartilham o mesmo nome (`age`), o usuário poderá selecionar apenas um deles, e `params[:age]` receberá `"child"` ou `"adult"`.

NOTE: Sempre use *labels* para a caixa de seleção e botões de opção. Eles associam o texto a uma opção específica e, ao expandir a região clicável, facilita o clique dos usuários nas entradas.

### Outros auxiliares interessantes

Outros controles de formulários que valem a pena falar são áreas de texto, campos ocultos, campos de senha, campos de número, campos de data e hora e muitos outros:

```erb
<%= form.text_area :message, size: "70x5" %>
<%= form.hidden_field :parent_id, value: "foo" %>
<%= form.password_field :password %>
<%= form.number_field :price, in: 1.0..20.0, step: 0.5 %>
<%= form.range_field :discount, in: 1..100 %>
<%= form.date_field :born_on %>
<%= form.time_field :started_at %>
<%= form.datetime_local_field :graduation_day %>
<%= form.month_field :birthday_month %>
<%= form.week_field :birthday_week %>
<%= form.search_field :name %>
<%= form.email_field :address %>
<%= form.telephone_field :phone %>
<%= form.url_field :homepage %>
<%= form.color_field :favorite_color %>
```

Resultado:

```html
<textarea name="message" id="message" cols="70" rows="5"></textarea>
<input type="hidden" name="parent_id" id="parent_id" value="foo" />
<input type="password" name="password" id="password" />
<input type="number" name="price" id="price" step="0.5" min="1.0" max="20.0" />
<input type="range" name="discount" id="discount" min="1" max="100" />
<input type="date" name="born_on" id="born_on" />
<input type="time" name="started_at" id="started_at" />
<input type="datetime-local" name="graduation_day" id="graduation_day" />
<input type="month" name="birthday_month" id="birthday_month" />
<input type="week" name="birthday_week" id="birthday_week" />
<input type="search" name="name" id="name" />
<input type="email" name="address" id="address" />
<input type="tel" name="phone" id="phone" />
<input type="url" name="homepage" id="homepage" />
<input type="color" name="favorite_color" id="favorite_color" value="#000000" />
```

Entradas ocultas não são exibidas ao usuário, mas retêm dados como qualquer entrada de texto. Os valores dentro deles podem ser alterados com JavaScript.

IMPORTANT: As entradas de pesquisa, telefone, data, hora, cor, data e hora local e data, mês, semana, URL, email, número e intervalo são controles HTML5. Se você precisar que sua aplicação tenha uma experiência consistente em navegadores antigos, precisará de um polyfill HTML5 (fornecido por css e/ou JavaScript). Definiticamente, [não faltam soluções disponíveis](https://github.com/Modernizr/Modernizr/wiki/HTML5-Cross-Browser-Polyfills), embora uma ferramenta popular no momento seja o [Modernizr](https://modernizr.com/), que fornece uma maneira simples de adicionar funcionalidade com base na presença de recursos HTML5 detectados.

TIP: Se você estiver usando campos de entradas de senha (para qualquer finalidade), convêm configurar sua aplicação para impedir que esses parâmetros sejam registrados. Você pode aprender sobre este assunto no guia [Protegendo aplicações Rails](security.html#logging)


Trabalhando com Objetos *Model*
--------------------------

### Vinculando um Formulário a um Objeto

O argumento `:model` do `form_with` nos permite ligar o objeto construtor de um formulário a um objeto *model*. Isso significa que o escopo do formulário será aquele objeto *model* e os campos do formulário serão preenchidos com valores desse objeto.

Por exemplo, se temos um objeto *model* como `@article`:

```ruby
@article = Article.find(42)
# => #<Article id: 42, title: "My Title", body: "My Body">
```

O seguinte formulário:

```erb
<%= form_with model: @article do |form| %>
  <%= form.text_field :title %>
  <%= form.text_area :body, size: "60x10" %>
  <%= form.submit %>
<% end %>
```

Cria o seguinte código:

```html
<form action="/articles/42" method="post" accept-charset="UTF-8" >
  <input name="authenticity_token" type="hidden" value="..." />
  <input type="text" name="article[title]" id="article_title" value="My Title" />
  <textarea name="article[body]" id="article_body" cols="60" rows="10">
    My Body
  </textarea>
  <input type="submit" name="commit" value="Update Article" data-disable-with="Update Article">
</form>
```

Existem algumas coisas a serem observadas aqui:

* A `action` do formulário é automaticamente preenchida com um valor apropriado para `@article`.
* Os campos do formulário são preenchidos automaticamente com os valores correspondentes do `@article`.
* Os nomes dos campos do formulário têm como escopo `article[...]`. Isso significa que `params[:article]` será um *hash* contendo todos os valores desses campos. Você pode ler mais sobre a importância dos nomes de entradas no capítulo [Entendendo as Convenções de Nomeação de Parâmetros](#entendendo-convencoes-de-nomeacao-de-parametros) deste guia.
* O botão de envio (*submit*) recebe automaticamente um valor de texto apropriado.

TIP: Convencionalmente, suas entradas espelharão os atributos do *model*. No entanto, eles não precisam! Se houver outras informações de que você precisa, você pode incluí-las em seu formulário da mesma forma que os atributos e acessá-las via `params[:article][:my_nifty_non_attribute_input]`.

#### O auxiliar `fields_for`

Você pode criar uma vinculação semelhante sem realmente criar uma tag `<form>` com o *helper* [`fields_for`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-fields_for). Isso é útil para editar objetos *model* adicionais com o mesmo formulário. Por exemplo, se você tem um *model* `Person` vinculado à um *model* `ContactDetail`, você pode criar um formulário para criar os dois, assim:

```erb
<%= form_with model: @person do |person_form| %>
  <%= person_form.text_field :name %>
  <%= fields_for :contact_detail, @person.contact_detail do |contact_detail_form| %>
    <%= contact_detail_form.text_field :phone_number %>
  <% end %>
<% end %>
```

que produz a seguinte saída:

```html
<form action="/people" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="bL13x72pldyDD8bgtkjKQakJCpd4A8JdXGbfksxBDHdf1uC0kCMqe2tvVdUYfidJt0fj3ihC4NxiVHv8GVYxJA==" />
  <input type="text" name="person[name]" id="person_name" />
  <input type="text" name="contact_detail[phone_number]" id="contact_detail_phone_number" />
</form>
```

O objeto produzido por `fields_for` é um construtor de formulário igual ao produzido por `form_with`.

### Confiando na Identificação de Registro

O *model* Article está disponível para os usuários da aplicação, portanto - seguindo as melhores praticas para desenvolvimento com Rails - você deve declará-lo **um recurso (*resource*)**:

```ruby
resources :articles
```

TIP: Declarar um recurso tem vários efeitos colaterais. Consulte [o guia Rotas do Rails de Fora pra Dentro](routing.html#roteando-resources-recursos-o-padrao-do-rails) para obter mais informações como configurar e usar recursos.

Ao lidar com recursos RESTful, as chamadas de `form_with` ficam significativamente mais fáceis se você contar com a **identificação de registros**. Resumindo, você pode apenas passar a instância do modelo e fazer com que o Rails descubra o nome do modelo e o resto:

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

Observe como a chamada de estilo abreviado `form_with` é convenientemente a mesma, independentemente de o registro ser novo ou existente. A identificação de registros é inteligente o suficiente para descobrir se o registro é novo, chamando `record.persisted?`. Ele também seleciona o caminho correto para enviar e o nome com base na classe do objeto.

WARNING: Quando você está usando herança de tabela única (STI ou *single-table inheritance*) em seus objetos *model*, você não pode confiar na identificação de registro em uma subclasse se apenas sua classe pai for declarada um recurso. Você terá que especificar `:url`, e `:scope` (o nome do *model*) explicitamente.

#### Trabalhando com *Namespaces*

Se você criou rotas com *namespaces*, `form_with` tem uma abreviatura bacana para isso também. Se o seu aplicativo tiver um *namespace* de administrador,

```ruby
form_with model: [:admin, @article]
```

irá criar um formulário que submete ao `ArticlesController` dentro do *namespace* do administrador (submetendo a `admin_article_path(@article)` no caso de uma atualização). Se você tiver vários níveis de *namespacing*, a sintaxe será semelhante:

```ruby
form_with model: [:admin, :management, @article]
```

Para mais informações sobre o sistema de roteamento Rails e as convenções associadas, consulte o [guia Rotas do Rails de Fora pra Dentro](routing.html).

### Como os formulários funcionam com os métodos *PATCH*, *PUT*, ou *DELETE*?

O *framework* Rails  incentiva o design *RESTful* de seus aplicativos, o que significa que você fará muitas requisições *"PATCH"*, *"PUT"*, e *"DELETE"* (além de *"GET"* e *"POST"*). Entretanto, a maioria dos navegadores _não suportam_ métodos diferentes de *"GET"* e *"POST"* quando se trata de envio de formulários.

O Rails contorna esse problema emulando outros métodos no *POST* com uma entrada oculta `"_method"`, que é definida para refletir o método desejado:

```ruby
form_with(url: search_path, method: "patch")
```

Resultado:

```html
<form accept-charset="UTF-8" action="/search" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  ...
</form>
```

Ao analisar os dados submetidos pelo *POST*, o Rails levará em consideração o parâmetro especial `_method` e agirá como se o método HTTP fosse aquele especificado dentro dele (*"PATCH"* nesse exemplo).

IMPORTANT: No Rails 6.0 e 5.2, todos os formulários usando `form_with` implementam `remote: true` por padrão. Esses formulários enviarão dados usando requisições XHR (*Ajax*). Para desabilitar isso, inclua `local: true`. Para se aprofundar, veja o guia [Trabalhando com JavaScript no Rails](working_with_javascript_in_rails.html#elementos-remotos).

Criando Caixas de Seleção (*Select Boxes*) com Facilidade
-----------------------------

As caixas de seleção em HTML requerem uma quantidade significativa de marcação, um elemento `<option>` para cada opção de escolha. Então o Rails provê métodos auxiliares para reduzir esse fardo.

Por exemplo, digamos que temos uma lista de cidades para o usuário escolher. Podemos usar o auxiliar [`select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-select) assim:

```erb
<%= form.select :city, ["Berlin", "Chicago", "Madrid"] %>
```

que gera:

```html
<select name="city" id="city">
  <option value="Berlin">Berlin</option>
  <option value="Chicago">Chicago</option>
  <option value="Madrid">Madrid</option>
</select>
```


Também podemos designar valores para `<option>` que diferem de seus rótulos:

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
```

que gera:

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

Desta forma, o usuário verá o nome completo da cidade, mas `params[: city]` será um dos tipos `"BE"`, `"CHI"` ou `"MD"`.

Por último, podemos especificar uma escolha padrão para a caixa de seleção com o argumento `:selected`:

```erb
<%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]], selected: "CHI" %>
```

que gera:

```html
<select name="city" id="city">
  <option value="BE">Berlin</option>
  <option value="CHI" selected="selected">Chicago</option>
  <option value="MD">Madrid</option>
</select>
```

### Grupos de Opção

Em alguns casos, podemos querer melhorar a experiência do usuário agrupando opções relacionadas. Podemos fazer isso passando um `Hash` (ou `Array` compatível) para `select`:

```erb
<%= form.select :city,
      {
        "Europe" => [ ["Berlin", "BE"], ["Madrid", "MD"] ],
        "North America" => [ ["Chicago", "CHI"] ],
      },
      selected: "CHI" %>
```

que gera:

```html
<select name="city" id="city">
  <optgroup label="Europe">
    <option value="BE">Berlin</option>
    <option value="MD">Madrid</option>
  </optgroup>
  <optgroup label="North America">
    <option value="CHI" selected="selected">Chicago</option>
  </optgroup>
</select>
```

### Caixas de Seleção (*Select Boxes*) com Objetos *Model*

Como outros formulários, uma caixa de seleção pode ser associada a um atributo de *model*. Por exemplo, se tivermos um objeto *model* `@person` como:

```ruby
@person = Person.new(city: "MD")
```

O seguinte formulário:

```erb
<%= form_with model: @person do |form| %>
  <%= form.select :city, [["Berlin", "BE"], ["Chicago", "CHI"], ["Madrid", "MD"]] %>
<% end %>
```

produz um resultado semelhante a:

```html
<select name="person[city]" id="person_city">
  <option value="BE">Berlin</option>
  <option value="CHI">Chicago</option>
  <option value="MD" selected="selected">Madrid</option>
</select>
```

Observe que a opção apropriada foi marcada automaticamente como `selected=" selected"`. Visto que esta caixa de seleção estava ligada a um *model*, não precisamos especificar um argumento `:selected`!

### Fuso horário e Seleção de País

Para usar o suporte de fuso horário no Rails, você tem que perguntar aos seus usuários em que fuso horário eles estão. Fazer isso exigiria a geração de opções selecionadas de uma lista de objetos *[`ActiveSupport::TimeZone`](https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html)* usando `collection_select`, mas você pode simplesmente usar o *helper* [`time_zone_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_zone_select) que já resolve isto:

```erb
<%= form.time_zone_select :time_zone %>
```

O Rails tinha um *helper* `country_select` para escolher os países, mas foi extraído para o [plugin country_select](https://github.com/stefanpenner/country_select).

Usando *Form Helpers* para Data e Hora
--------------------------------

Se você não deseja usar os *helpers* de formulário que geram campos de data e hora em HTML5, o Rails fornece *helpers* de data e hora alternativos que renderizam formulários em texto simples. Esses *helpers* renderizam uma caixa de seleção para cada componente de tempo (por exemplo, ano, mês, dia, etc.). Por exemplo, se tivermos um objeto de *model* `@person` como:

```ruby
@person = Person.new(birth_date: Date.new(1995, 12, 21))
```

O seguinte formulário:

```erb
<%= form_with model: @person do |form| %>
  <%= form.date_select :birth_date %>
<% end %>
```

vai gerar algo como:

```html
<select name="person[birth_date(1i)]" id="person_birth_date_1i">
  <option value="1990">1990</option>
  <option value="1991">1991</option>
  <option value="1992">1992</option>
  <option value="1993">1993</option>
  <option value="1994">1994</option>
  <option value="1995" selected="selected">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999">1999</option>
  <option value="2000">2000</option>
</select>
<select name="person[birth_date(2i)]" id="person_birth_date_2i">
  <option value="1">January</option>
  <option value="2">February</option>
  <option value="3">March</option>
  <option value="4">April</option>
  <option value="5">May</option>
  <option value="6">June</option>
  <option value="7">July</option>
  <option value="8">August</option>
  <option value="9">September</option>
  <option value="10">October</option>
  <option value="11">November</option>
  <option value="12" selected="selected">December</option>
</select>
<select name="person[birth_date(3i)]" id="person_birth_date_3i">
  <option value="1">1</option>
  ...
  <option value="21" selected="selected">21</option>
  ...
  <option value="31">31</option>
</select>
```

Observe que, quando o formulário for enviado, não haverá um único valor no _hash_ `params` que contenha a data completa. Em vez disso, haverá vários valores com nomes especiais como `"birth_date(1i) "`. O _Active Record_ sabe como reunir esses valores com nomes especiais em uma data ou hora completa, com base no tipo declarado do atributo do *model*. Portanto, podemos passar `params [:person]` para, por exemplo, `Person.new` ou `Person#update` exatamente como faríamos se o formulário usasse um único campo para representar a data completa.

Além do auxiliar [`date_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-date_select), o Rails provê os auxiliares [`time_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-time_select) e [`datetime_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-datetime_select).

### Caixas de Seleção (*Select Boxes*) para Componentes Individuais de Tempo

O Rails também fornece auxiliares para renderizar caixas de seleção para componentes temporais individuais: [`select_year`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_year), [`select_month`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_month), [`select_day`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_day), [`select_hour`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_hour), [`select_minute`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_minute), and [`select_second`](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html#method-i-select_second). Esses auxiliares são métodos "básicos", o que significa que não são chamados em uma instância do construtor de formulários. Por exemplo:

```erb
<%= select_year 1999, prefix: "party" %>
```

Cria uma caixa de seleção como essa:

```html
<select name="party[year]" id="party_year">
  <option value="1994">1994</option>
  <option value="1995">1995</option>
  <option value="1996">1996</option>
  <option value="1997">1997</option>
  <option value="1998">1998</option>
  <option value="1999" selected="selected">1999</option>
  <option value="2000">2000</option>
  <option value="2001">2001</option>
  <option value="2002">2002</option>
  <option value="2003">2003</option>
  <option value="2004">2004</option>
</select>
```

Para cada um desses auxiliares, você pode especificar um objeto de data ou hora em vez de um número como o valor padrão e o componente temporal apropriado será extraído e usado.

Escolhas a partir de uma Coleção de Objetos Arbitrários
----------------------------------------------

Frequentemente desejamos gerar um conjunto de escolhas em um formulário a partir de uma coleção de objetos. Por exemplo, quando queremos que um usuário escolha cidades a partir do nosso banco de dados, e temos um modelo `City` conforme:

```ruby
City.order(:name).to_a
# => [
#      #<City id: 3, name: "Berlin">,
#      #<City id: 1, name: "Chicago">,
#      #<City id: 2, name: "Madrid">
#    ]
```

O Rails oferece *helpers* que geram escolhas a partir de uma coleção sem ser necessário iterar explicitamente sobre ela. Esses *helpers* determinam o valor e o texto descritivo de cada escolha chamando métodos especificados em cada objeto na coleção.

### O auxiliar `collection_select`

Para gerar uma caixa de seleção (*select box*) para nossas cidades, podemos utilizar [`collection_select`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_select):

```erb
<%= form.collection_select :city_id, City.order(:name), :id, :name %>
```

Resultado:

```html
<select name="city_id" id="city_id">
  <option value="3">Berlin</option>
  <option value="1">Chicago</option>
  <option value="2">Madrid</option>
</select>
```

NOTE: Utilizando `collection_select` devemos especificar primeiramente o método para o valor (`:id` no exemplo acima), e em seguida o método do texto descritivo (`:name` no exemplo acima).  Essa ordem é inversa a quando especificamos escolhas para o *helper* `select`, onde primeiramente passamos o texto descritivo e em seguida o valor.

### O auxiliar `collection_radio_buttons`

Para gerar um conjunto de botões de rádio (*radio buttons*) para nossas cidades, podemos utilizar [`collection_radio_buttons`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_radio_buttons):

```erb
<%= form.collection_radio_buttons :city_id, City.order(:name), :id, :name %>
```

Resultado:

```html
<input type="radio" name="city_id" value="3" id="city_id_3">
<label for="city_id_3">Berlin</label>
<input type="radio" name="city_id" value="1" id="city_id_1">
<label for="city_id_1">Chicago</label>
<input type="radio" name="city_id" value="2" id="city_id_2">
<label for="city_id_2">Madrid</label>
```

### O auxiliar `collection_check_boxes`

Para gerar um conjunto de *check boxes* para nossas cidades (que permite que usuários escolham mais de uma opção), podemos utilizar [`collection_check_boxes`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-collection_check_boxes):

```erb
<%= form.collection_check_boxes :city_id, City.order(:name), :id, :name %>
```

Resultado:

```html
<input type="checkbox" name="city_id[]" value="3" id="city_id_3">
<label for="city_id_3">Berlin</label>
<input type="checkbox" name="city_id[]" value="1" id="city_id_1">
<label for="city_id_1">Chicago</label>
<input type="checkbox" name="city_id[]" value="2" id="city_id_2">
<label for="city_id_2">Madrid</label>
```

Enviando Arquivos
---------------

Uma tarefa muito comum é fazer o envio de arquivos, seja a imagem de uma pessoa ou um arquivo CSV contendo dados a serem processados. Campos para upload de arquivos podem ser renderizados com o auxiliar [`file_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-file_field). O mais importante a se lembrar quando se faz envio de arquivos é que o atributo `enctype` do formulário renderizado **deve** ser "multipart/form-data". Se você usar `form_with` com `:model`, isso é feito automaticamente:

```erb
<%= form_with model: @person do |form| %>
  <%= form.file_field :picture %>
<% end %>
```

Se você usar `form_with` sem o `:model`, você deve preencher os campos:

```erb
<%= form_with url: "/uploads", multipart: true do |form| %>
  <%= form.file_field :picture %>
<% end %>
```

Observe que, de acordo com as convenções do `form_with`, os nomes dos campos nas duas formas acima também serão diferentes. Ou seja, o nome do campo no primeiro formulário será `person[picture]` (acessível via `params[:person][:picture]`), e o nome do campo no segundo formulário será apenas `picture` (acessível via `params[:picture]`).

### O que é enviado

O objeto em `params` é uma instância de [`ActionDispatch::Http::UploadedFile`](https://api.rubyonrails.org/classes/ActionDispatch/Http/UploadedFile.html). O trecho de código a seguir salva o arquivo enviado em `#{Rails.root}/public/uploads` contendo o mesmo nome do arquivo original.

```ruby
def upload
  uploaded_file = params[:picture]
  File.open(Rails.root.join('public', 'uploads', uploaded_file.original_filename), 'wb') do |file|
    file.write(uploaded_file.read)
  end
end
```

Uma vez que o arquivo é enviado, há uma infinidade de tarefas em potencial, variando entre onde armazenar os arquivos (no Disco, Amazon S3, etc), associá-lo com models, redimensionar arquivos de imagem e gerar miniaturas, etc. O [Active Storage](active_storage_overview.html) é destinado a ajudar com essas tarefas.

Customizando os Construtores de Formulários
-------------------------

O objeto que é dado para o *yield* no `form_with` e `fields_for` é uma instância de
[`ActionView::Helpers::FormBuilder`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html).
Construtores de Formulários encapsulam a noção de exibir os elementos do formulário para um único objeto.
Enquanto você pode escrever *helpers* para seus formulários da forma usual, você também pode criar uma subclasse
de `ActionView::Helpers::FormBuilder` e adicionar os *helpers* lá. Por exemplo,

```erb
<%= form_with model: @person do |form| %>
  <%= text_field_with_label form, :first_name %>
<% end %>
```

pode ser substituído por

```erb
<%= form_with model: @person, builder: LabellingFormBuilder do |form| %>
  <%= form.text_field :first_name %>
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

O construtor de formulários utilizado também determina o que acontece quando você escreve:

```erb
<%= render partial: f %>
```

Se `f` for uma instância de `ActionView::Helpers::FormBuilder`, então isso vai renderizar a *partial* `form`,
passando o objeto da *partial* para o construtor de formulários. Se o construtor de formulário for da classe
`LabellingFormBuilder` então a partial `labelling_form` é que seria renderizada.

Entendendo Convenções de Nomeação de Parâmetros
------------------------------------------

Valores de formulários podem ficar no topo do *hash* `params` ou aninhados em outro *hash*. Por exemplo, numa ação `create` padrão para um *model* `Person`, `params[:person]` normalmente seria um *hash* de todos os atributos necessários para criar uma pessoa. O *hash* `params` também pode conter *arrays*, *arrays* de *hashes*, e por aí vai.

Fundamentalmente formulários HTML não tem conhecimento de nenhum tipo de dado estruturado, tudo que eles geram são pares de nomes e valores, onde os pares são *strings* simples. Os *arrays* e *hashes* que você vê na sua aplicação são o resultado de algumas convenções de nomeação que o Rails utiliza.

### Estruturas Básicas

As duas estruturas básicas são *arrays* e *hashes*. *Hashes* copiam a sintaxe utilizada para acessar o valor em `params`. Por exemplo, se um formulário contém:

```html
<input id="person_name" name="person[name]" type="text" value="Henry"/>
```

o *hash* `params` conterá

```ruby
{'person' => {'name' => 'Henry'}}
```

e `params[:person][:name]` buscará o valor enviado dentro do *controller*.

*Hashes* podem ser aninhados em quantos níveis for necessário, por exemplo:

```html
<input id="person_address_city" name="person[address][city]" type="text" value="New York"/>
```

resultará no *hash* `params` como

```ruby
{'person' => {'address' => {'city' => 'New York'}}}
```

Normalmente o Rails ignora nomes de parâmetros duplicados. Se o parâmetro *name* termina em um conjunto vazio de colchetes `[]` então eles serão acumulados em um *array*. Se você queria que os usuários pudessem informar vários números de telefone, você poderia colocar isto no formulário:

```html
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
<input name="person[phone_number][]" type="text"/>
```

Isto resultará em `params[:person][:phone_number]` como um *array* contendo os números de telefone informados.

### Combinando os Conceitos

Podemos combinar estes dois conceitos. Um elemento de um *hash* pode ser um *array* como no exemplo anterior, ou você pode ter um *array* de *hashes*. Por exemplo, um formulário pode permitir a criação de um número arbitrário de *addresses* ao repetir o fragmento de formulário seguinte

```html
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
<input name="person[addresses][][line1]" type="text"/>
<input name="person[addresses][][line2]" type="text"/>
<input name="person[addresses][][city]" type="text"/>
```

Isto resultará em `params[:person][:addresses]` como um *array* de *hashes* com as chaves `line1`, `line2`, e `city`.

Porém, há uma restrição. Enquanto os *hashes* podem ser aninhados de forma arbitrária, só é permitido um nível de *"arrayness"*. *Arrays* normalmente podem ser trocados por *hashes*; por exemplo, ao invés de usar um *array* de *model objects*, é possível usar um *hash* de *model objects* distinguidos pelo seu *id*, um índice do *array*, ou algum outro parâmetro.

WARNING: Parâmetros de *array* não funcionam bem com o *helper* `check_box`. De acordo com a especificação HTML *checkboxes* desmarcadas não enviam nenhum valor. Porém pode ser conveniente fazer com que uma *checkbox* sempre envie um valor. O *helper* `check_box` simula isto ao criar um *input* auxiliar com o mesmo nome. Se a *checkbox* estiver desmarcada apenas o *input* escondido será enviado e se estiver marcada então os dois serão enviados mas o valor da *checkbox* recebe uma prioridade maior.

### Utilizando o auxiliar `fields_for` Helper

Digamos que queremos renderizar um formulário com um conjunto de campos para cada endereço de uma pessoa. O auxiliar `fields_for` e seu argumento`: index` podem ajudar com isso:
Você pode querer renderizar um formulário com um conjunto de campos de edição pra cada *address* de uma `person`. Por exemplo:

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

Presumindo que a pessoa (person) tenha dois endereços (addresses), com *ids* 23 e 45 isto trará um resultado similar a este:

```html
<form accept-charset="UTF-8" action="/people/1" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input id="person_name" name="person[name]" type="text" />
  <input id="person_address_23_city" name="person[address][23][city]" type="text" />
  <input id="person_address_45_city" name="person[address][45][city]" type="text" />
</form>
```

Isto resultará em um *hash* `params` parecido com

```ruby
{'person' => {'name' => 'Bob', 'address' => {'23' => {'city' => 'Paris'}, '45' => {'city' => 'London'}}}}
```

O Rails sabe que todos estes *inputs* devem ser parte do *hash* person porque você chamou `fields_for` no primeiro *builder* do formulário. Ao especificar uma opção `:index`
você diz ao Rails que ao invés de nomear os *inputs* `person[address][city]`
ele deve inserir aquele índice dentro de [] entre o *address* e a *city*.
Isso geralmente é útil porque deixa mais fácil para saber qual registro *Address* deve ser modificado. Você pode passar números com algum outro significado,
*strings* ou mesmo `nil` (que resultará em um *array* de parâmetros sendo criado).

Para criar aninhamentos mais complexos, você pode especificar a primeira parte do nome do *input* (`person[address]` no exemplo anterior) de forma explícita:

```erb
<%= fields_for 'person[address][primary]', address, index: address.id do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

criará *inputs* como

```html
<input id="person_address_primary_1_city" name="person[address][primary][1][city]" type="text" value="Bologna" />
```

Como uma regra geral o nome final do *input* é uma concatenação do nome passado para `fields_for`/`form_with`, o valor do índice, e o nome do atributo. Você também pode passar uma opção `:index` diretamente para os *helpers* como `text_field`, mas normalmente é menos repetitivo especificar isto dentro do *builder* do formulário ao invés de especificar nos controles individuais de *input*.

Como um atalho você pode adicionar `[]` ao nome e omitir a opção `:index`. Isto é o mesmo que especificar `index: address.id` portanto

```erb
<%= fields_for 'person[address][primary][]', address do |address_form| %>
  <%= address_form.text_field :city %>
<% end %>
```

produz exatamente o mesmo resultado que o exemplo anterior.

Formulários para Recursos Externos
---------------------------

Os *helpers* de formulários do Rails também podem ser usados para construir formulários para enviar dados para recursos externos. Entretanto em alguns momentos pode ser necessário definir um `authenticity_token` para o recurso; isso pode ser feito passando um parâmetro `authenticity_token: 'your_external_token'` para as opções do `form_with`


```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: 'external_token' do %>
  Form contents
<% end %>
```

Às vezes ao submeter dados para um recurso externo, como um *gateway* de pagamento, os campos que podem ser usado no formulário são limitados por uma API externa e pode ser indesejável gerar um `authenticity_token`. Para não enviar um token, simplesmente passe `false` para o parâmetro `:authenticity_token`:

```erb
<%= form_with url: 'http://farfar.away/form', authenticity_token: false do %>
  Form contents
<% end %>
```

Trabalhando com Formulários Complexos
----------------------

Muitas aplicações vão além de uma edição de um único objeto em um formulário simples. Por exemplo, quando estamos criando um *model* `Person` você pode querer que o usuário permita (no mesmo formulário) criar múltiplos registros de endereços (casa, trabalho, etc.). Mais tarde, quando estivesse editando este formulário, seria possível adicionar, remover, ou corrigir os endereços relacionados caso fosse necessário.

### Configurando o Model

O Active Record fornece suporte a níveis de modelo através do método [`accepts_nested_attributes_for`](https://api.rubyonrails.org/classes/ActiveRecord/NestedAttributes/ClassMethods.html#method-i-accepts_nested_attributes_for):

```ruby
class Pessoa < ApplicationRecord
  has_many :enderecos, inverse_of: :pessoa
  accepts_nested_attributes_for :enderecos
end

class Endereco < ApplicationRecord
  belongs_to :pessoa
end
```

Isso criará um método chamado `enderecos_attributes=` no model `Pessoa` para permitir criar, atualizar e (opcionalmente) destruir endereços.

### Formulários Aninhados

O formulário a seguir permite ao usuário criar uma `Pessoa` e seus endereços associados.

```html+erb
<%= form_with model: @pessoa do |form| %>
  Endereços:
  <ul>
    <%= form_with model: @pessoa do |f| %>
      <li>
        <%= addresses_form.label :tipo %>
        <%= addresses_form.text_field :tipo %>

        <%= addresses_form.label :nome_rua %>
        <%= addresses_form.text_field :nome_rua %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

Quando uma associação aceita atributos aninhados, o método `fields_for` renderiza esse bloco uma vez para cada elemento da associação. Em particular, se a pessoa não tiver endereços nada será renderizado. Um padrão comum é o controller criar um ou mais filhos vazios para que pelo menos um bloco de campos seja exibido ao usuário. O exemplo a seguir irá resultar em dois blocos de campos de endereços no formulário de uma nova pessoa.

```ruby
def new
  @pessoa = Pessoa.new
  2.times { @pessoa.enderecos.build }
end
```

O método`fields_for` produz um construtor de formulário. Os nomes dos parâmetros serão o que o
`accepts_nested_attributes_for` espera. Por exemplo, quando criamos uma pessoa com dois endereços,
os parâmetros enviados serão:

```ruby
{
  'pessoa' => {
    'nome' => 'John Doe',
    'enderecos_attributes' => {
      '0' => {
        'tipo' => 'Casa',
        'nome_rua' => 'Rua da Paz'
      },
      '1' => {
        'tipo' => 'Escritório',
        'nome_rua' => 'Av. Brasil'
      }
    }
  }
}
```

As chaves da hash `:addresses_attributes` não são importantes, eles apenas precisam ser diferentes para cada endereço.

Se o objeto associado já estiver salvo, o método `fields_for` ir gerá automaticamente uma entrada oculta com o `id` do registro salvo.
Você pode desabilitar isso passando `include_id: false` para o `fields_for`.

### O *Controller*

Como de costume, você precisa [declarar os parâmetros permitidos](action_controller_overview.html#parametros-fortes)
dentro do controller antes de enviá-los para o *model*:

```ruby
def create
  @pessoa = Pessoa.new(pessoa_params)
  # ...
end

private
  def pessoa_params
    params.require(:pessoa).permit(:nome, enderecos_attributes: [:id, :tipo, :nome_rua])
  end
```

### Removendo objetos

Você pode permitir os usuários deletarem os objetos associados ao passar o parâmetro `allow_destroy: true` para o `accepts_nested_attributes_for`

```ruby
class Pessoa < ApplicationRecord
  has_many :enderecos
  accepts_nested_attributes_for :enderecos, allow_destroy: true
end
```

Se a hash de atributos de um objeto contém a chave `_destroy` com um valor que
representa `true` (ex: 1, '1', true ou 'true'), então o objeto será destruído.
O formulário a seguir permite o usuário remover endereços:

```erb
<%= form_with model: @pessoa do |form| %>
  Addresses:
  <ul>
    <%= form.fields_for :enderecos do |enderecos_form| %>
      <li>
        <%= enderecos_form.check_box :_destroy %>
        <%= enderecos_form.label :tipo %>
        <%= enderecos_form.text_field :tipo %>
        ...
      </li>
    <% end %>
  </ul>
<% end %>
```

Não esqueça de atualizar a lista de parâmetros permitidos no seu controller para
incluir também o campo `_destroy`:

```ruby
def pessoa_params
  params.require(:pessoa).
    permit(:nome, enderecos_attributes: [:id, :tipo, :nome_rua, :_destroy])
end
```

### Prevenindo Registros Vazios

Pode ser útil ignorar um conjunto de campos que o usuário não preencheu. Você pode controlar isso ao passar um proc `:reject_if` para o
`accepts_nested_attributes_for`. Essa proc será chamada com cada hash de atributos enviados pelo formulário. Se a proc retornar `false` então o Active Record não irá construir o objeto associado para essa hash. O exemplo abaixo tenta construir um endereço apenas se o campo `tipo` for informado.

```ruby
class Pessoa < ApplicationRecord
  has_many :addresses
  accepts_nested_attributes_for :enderecos, reject_if: lambda {|attributes| attributes['tipo'].blank?}
end
```

Para facilitar, você pode passar o symbol `:all_blank` no lugar, que irá criar uma proc para rejeitar os registros onde todos os atributos
são vazios, excluindo qualquer valor para o `_destroy`.

### Adicionando campos dinamicamente

No lugar de renderizar múltiplos blocos de campos antecipadamente, você pode desejar adicioná-los apenas quando o usuário clicar em um botão "Adicionar novo endereço". O Rails não possui nenhum suporte nativo para isso. Quando geramos um novo bloco de campos, devemos
garantir que a chave do array associado é único - utilizar a data atual via JavaScript em milisegundos [epoch](https://en.wikipedia.org/wiki/Unix_time), é bastante comum.

Utilizando Tags Auxiliares (*Tag Helpers*) Sem Um Construtor de Formulário
----------------------------------------

Caso você precise renderizar campos de formulário fora do contexto de um construtor de formulário, o Rails oferece tags auxiliares para elementos comuns de formulário. Por exemplo, [`check_box_tag`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html#method-i-check_box_tag):

```erb
<%= check_box_tag "accept" %>
```

Resultado:

```html
<input type="checkbox" name="accept" id="accept" value="1" />
```

Geralmente, esses *helpers* tem o mesmo nome dos *helpers* do Construtor de Formulários, porém adicionando o sufixo `_tag`.  Para uma lista completa, consulte a [documentação da API `FormTagHelper`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormTagHelper.html).

Usando `form_for` e `form_tag`
---------------------------

Antes do `form_with` ser introduzido no Rails 5.1 sua funcionalidade costumava ser divida entre [`form_tag`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormTagHelper.html#method-i-form_tag) e [`form_for`](https://api.rubyonrails.org/v5.2/classes/ActionView/Helpers/FormHelper.html#method-i-form_for). Ambos estão agora depreciados (_soft-deprecated_). A documentação sobre seu uso pode ser encontrada na [versão antiga deste guia](https://guides.rubyonrails.org/v5.2/form_helpers.html).
