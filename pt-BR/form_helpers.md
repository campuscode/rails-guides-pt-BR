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


Trabalhando com Objetos *Model*
--------------------------

### *Helpers* de Objetos *Model*

Uma tarefa particularmente comum para um formulário é editar ou criar um objeto *model*. Embora os *helpers* `*_tag` possam ser usados para essa tarefa, eles são um pouco verbosos, pois para cada *tag* você teria que garantir que o nome do parâmetro correto seja usado e atribuir o valor padrão de entrada de maneira apropriada. O Rails fornece *helpers* personalizados para essa função. Esses *helpers* não possuem o sufixo `_tag`, por exemplo `text_field`, `text_area`.

Para esses *helpers* o primeiro argumento é o nome de uma variável de instância e o segundo é o nome de um método (geralmente um atributo) para chamar esse objeto. O Rails vai definir o valor do controle de entrada para o valor de retorno daquele método para o objeto e definirá um nome de entrada apropriado. Se o seu *controller* definiu `@person` e o nome dessa pessoa é Henry, um formulário contendo:

```erb
<%= text_field(:person, :name) %>
```

produz uma saída semelhante à 

```erb
<input id="person_name" name="person[name]" type="text" value="Henry" />
```

Após o envio do formulário, o valor inserido pelo usuário fica armazenado em `params[:person][:name]`.

WARNING: Você deve passar o nome da instância da variável, i.e. `:person` ou `"person"`, não a instância atual do objeto *model*.

O Rails fornece *helpers* para exibição de validação de erros associados ao objeto *model*. Esses são abordados em detalhes no guia de [Validação do *Active Record*](active_record_validations.html#displaying-validation-errors-in-views).

### Vinculando um Formulário a um Objeto

Embora isso seja muito confortável, está longe de ser perfeito. Se `Person` tiver muitos atributos para editar, estaríamos repetindo o nome do objeto editado várias vezes. O que queremos fazer é de alguma forma vincular um formulário a um objeto *model*, que é exatamente o que `form_with` com `:model` faz.

Suponha que temos um *controller* para lidar com *articles* `app/controllers/articles_controller.rb`:

```ruby
def new
  @article = Article.new
end
```

A *view* correspondente `app/views/articles/new.html.erb` usando `form_with` fica algo parecido com:

```erb
<%= form_with model: @article, class: "nifty_form" do |f| %>
  <%= f.text_field :title %>
  <%= f.text_area :body, size: "60x12" %>
  <%= f.submit "Create" %>
<% end %>
```

Existem algumas coisas a serem observadas aqui:

* `@article` é o objeto real que está sendo editado.
* Existe um único *hash* de opções. Opções HTML (exceto `id` e `class`) são passadas no *hash* `:html`. Além disso, você pode fornecer uma opção `:namespace` no seu formulário para garantir a exclusividade dos atributos de *id* nos elementos do formulário. O atributo de escopo será prefixado com sublinhado no id HTML gerado.
* O método `form_with` produz um objeto **construtor de formulário** (a variável `f`).
* Se você deseja direcionar sua requisição de formulário para uma URL específica, use `form_with url: my_nifty_url_path`. Para ver as opções mais detalhadas sobre o que `form_with` aceita, [verifique a documentação da API](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with).
* Métodos para criar controles de formulário são chamados **no** objeto construtor de formulário `f`.

O HTML produzido é:

```html
<form class="nifty_form" action="/articles" accept-charset="UTF-8" data-remote="true" method="post">
  <input type="hidden" name="authenticity_token" value="NRkFyRWxdYNfUg7vYxLOp2SLf93lvnl+QwDWorR42Dp6yZXPhHEb6arhDOIWcqGit8jfnrPwL781/xlrzj63TA==" />
  <input type="text" name="article[title]" id="article_title" />
  <textarea name="article[body]" id="article_body" cols="60" rows="12"></textarea>
  <input type="submit" name="commit" value="Create" data-disable-with="Create" />
</form>
```

O objeto passado como `:model` em `form_with` controla a chave usada em `params` para acessar os valores do fomulário. Aqui está o nome `article` e, portanto, todas as entradas tem nomes do formulário `article[attribute_name]`. Assim, na ação `create` haverá um *hash* `params[:article]` com as chaves `:title` e `:body`. Você pode ler mais sobre a importância dos nomes de entrada no capítulo [Entendendo Convenções de Nomeação de Parâmetros](#entendendo-convencoes-de-nomeacao-de-parametros) deste guia.

TIP: Convencionalmente, suas entradas espelharão os atributos do *model*. No entanto, eles não precisam! Se houver outras informações de que você precisa, você pode incluí-las em seu formulário da mesma forma que os atributos e acessá-las via `params[:article][:my_nifty_non_attribute_input]`.

Os métodos *helper* chamados no construtor de formulário (*form builder*) são identicos ao objeto *model helper*, exceto que não é necessário especificar qual objeto está sendo editado, pois isso já é gerenciado pelo construtor de formulário.

Você pode criar uma vinculação semelhante sem realmente criar uma tag `<form>` com o *helper* `fields_for`. Isso é útil para editar objetos *model* adicionais com o mesmo formulário. Por exemplo, se você tem um *model* `Person` vinculado à um *model* `ContactDetail`, você pode criar um formulário para criar os dois, assim:

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
<form action="/people" accept-charset="UTF-8" data-remote="true" method="post">
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
<form accept-charset="UTF-8" action="/search" data-remote="true" method="post">
  <input name="_method" type="hidden" value="patch" />
  <input name="authenticity_token" type="hidden" value="f755bb0ed134b76c432144748a6d4b7a7ddf2b71" />
  ...
</form>
```

Ao analisar os dados submetidos pelo *POST*, o Rails levará em consideração o parâmetro especial `_method` e agirá como se o método HTTP fosse aquele especificado dentro dele (*"PATCH"* nesse exemplo).

IMPORTANT: Todos os formulários usando `form_with` implementam `remote: true` por padrão. Esses formulários enviarão dados usando requisições XHR (*Ajax*). Para desabilitar isso, inclua `local: true`. Para se aprofundar, veja o guia [Trabalhando com JavaScript no Rails](working_with_javascript_in_rails.html#elementos-remotos).

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

Usando *Form Helpers* para Data e Hora
--------------------------------

Você pode optar por não usar os *helpers* de formulário que geram campos de data e hora em HTML5 e usar os *helpers* de data e hora alternativos. Esses *helpers* de data e hora diferem de todos os outros *helpers* de formulário em dois aspectos importantes:

* Datas e horas não são representáveis por um único elemento de entrada. Em vez disso, você tem vários, um para cada componente (ano, mês, dia, etc.) e, portanto, não há um valor único em seu hash `params` com sua data ou hora.
* Outros *helpers* usam o sufixo `_tag` para indicar quando um *helper* é um  *barebone helper* ou um que trabalha em objetos *model*. Com datas e horas, `select_date`, `select_time` e `select_datetime` são *helpers* essenciais, `date_select`, `time_select` e `datetime_select` são os *helpers* equivalentes.

Ambas as famílias de *helpers* criarão uma série de caixas de seleção para os diferentes componentes (ano, mês, dia, etc.).

### *Helpers* Essenciais

A família de *helpers* `select_*` usam como primeiro argumento, uma instância de `Date`, `Time`, ou `DateTime` que é utilizada como o valor selecionado no momento. É possível omitir esse parâmetro, onde a data atual é utilizada. Por exemplo:

```erb
<%= select_date Date.today, prefix: :start_date %>
```

produz (com os valores das opções reais omitidos para simplificação)

```html
<select id="start_date_year" name="start_date[year]">
</select>
<select id="start_date_month" name="start_date[month]">
</select>
<select id="start_date_day" name="start_date[day]">
</select>
```

As entradas acima resultariam em um *hash* `params[:start_date]` com as chaves `:year`, `:month`, `:day`. Para pegar objetos com `Date`, `Time`, ou `DateTime` atuais,você deve extrair os valores e passá-los para o construtor apropriado, por exemplo: 

```ruby
Date.civil(params[:start_date][:year].to_i, params[:start_date][:month].to_i, params[:start_date][:day].to_i)
```

A opção `:prefix` é a chave utilizada para retornar a *hash* dos componentes de datas da *hash* `params`. Aqui foi definido como `start_date`, se omitido o valor padrão será `date`.

### *Helpers* para Objetos *Model*

O objeto `select_date` não funciona muito bem com formulários que atualizam ou criam objetos *Active Record* , pois *Active Record* espera que cada elemento da *hash* `params` corresponda a um atributo.
Os *helpers* para objetos *model* em datas e horas enviam parâmetros com nomes especiais; quando *Active Record* vê os parâmetros com estes nomes, ele sabe que eles devem ser combinados com os outros parâmetros e fornecidos a um construtor apropriado para o tipo de coluna. Por exemplo:

```erb
<%= date_select :person, :birth_date %>
```

produz (com os valores das opções reais omitidos para simplificação)

```html
<select id="person_birth_date_1i" name="person[birth_date(1i)]">
</select>
<select id="person_birth_date_2i" name="person[birth_date(2i)]">
</select>
<select id="person_birth_date_3i" name="person[birth_date(3i)]">
</select>
```

que produz um hash `params`

```ruby
{'person' => {'birth_date(1i)' => '2008', 'birth_date(2i)' => '11', 'birth_date(3i)' => '22'}}
```

Quando isso é passado para o `Person.new` (ou `update`), o *Active Record* mostra que todos esses parâmetros devem ser usados para construir o atributo `birth_date` e usa a informação no sufixo para determinar em que ordem deve passar esses parâmetros para funções como `Date.civil`.

### Opções Frequentes

Ambas familias de *helpers* usam o mesmo core de funções parar gerar as tags *select* individuais e ambas aceitam praticamente as mesmas opções. Em particular, por padrão o Rails gera opções de ano 5 anos em cada lado do ano atual. Se este intervalo não for suficiente, as opções `:start_year` e `:end_year` substituem esse intervalo. Para uma lista das opções completas disponível, consulte a [documentação da API](https://api.rubyonrails.org/classes/ActionView/Helpers/DateHelper.html).

Como regra geral, você deve usar `date_select` ao trabalhar com objetos *model* e `select_date` em outros casos, como em um formulário de pesquisa que filtra resultados por data.

### Componentes Individuais

Ocasionalmente, você precisa exibir apenas um único componente de data, como um ano ou um mês. O Rails fornece uma série de *helpers* para isso, uma para cada componente `select_year`, `select_month`, `select_day`, `select_hour`, `select_minute`, `select_second`. Esses *helpers* são bastante diretos. Por padrão eles geram um campo de entrada com o nome do componente de tempo (por exemplo, *"year"* para `select_year`, *"month"* para `select_month` etc.) embora isso possa ser substituído com a opção  `:field_name`. A opção `:prefix` funciona da mesma maneira em que `select_date` e `select_time` com o mesmo valor padrão.

O primeiro parâmetro especifica quais valores devem ser selecionados e pode ser uma instância de  `Date`, `Time`, ou `DateTime`, no caso em que o componente relevante irá ser extraído, ou um valor numérico. Por exemplo:

```erb
<%= select_year(2009) %>
<%= select_year(Time.new(2009)) %>
```

irá produzir o mesmo resultado e o valor escolhido pode ser retornado por `params[:date][:year]`.

Enviando Arquivos
---------------

Uma tarefa muito comum é fazer o envio de arquivos, seja a imagem de uma pessoa ou um arquivo CSV contendo dados a serem processados. O mais importante a se lembrar quando se faz envio de arquivos é que o atributo `enctype` do formulário renderizado **deve** ser "multipart/form-data". Se você usar `form_with` com `:model`, isso é feito automaticamente. Se você usar `form_with` sem `:model`, você deve colocar manualmente, assim como no exemplo a seguir.

Ambos formulários a seguir realizam o envio de um arquivo.

```erb
<%= form_with(url: {action: :upload}, multipart: true) do %>
  <%= file_field_tag 'picture' %>
<% end %>

<%= form_with model: @person do |f| %>
  <%= f.file_field :picture %>
<% end %>
```

O Rails já disponibiliza dois *helpers*: o simples `file_field_tag` e o orientado a *model* `file_field`. No primeiro caso, o arquivo enviado está no `params[:picture]` e no segundo está em `params[:person][:picture]`, assim como esperado.

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

Normalmente o Rails ignora nomes de parâmetros duplicados. Se o parâmetro *name* contém um conjunto vazio de colchetes `[]` então eles serão acumulados em um *array*. Se você queria que os usuários pudessem informar vários números de telefone, você poderia colocar isto no formulário:

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

### Utilizando *Form Helpers*

As seções anteriores não utilizavam os *form helpers* do Rails de maneira alguma. Embora você possa criar os nomes de *input* por conta própria e passá-los diretamente para *helpers* como `text_field_tag`, o Rails também fornece suporte em um nível maior. As duas ferramentas à sua disposição aqui são o nome de parâmetro para `form_with` e `fields_for` e a opção `:index` que os *helpers* recebem.

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
<form accept-charset="UTF-8" action="/people/1" data-remote="true" method="post">
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
