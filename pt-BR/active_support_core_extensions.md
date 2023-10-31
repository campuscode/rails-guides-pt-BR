**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Active Support Core Extensions
==============================

O _Active Support_ é o componente em Ruby on Rails responsável por fornecer à linguagem Ruby extensões e utilidades.

Ele oferece um riquíssimo ponto de partida no nível da linguagem, onde pode-se aproveitar tanto para o desenvolvimento de aplicações Rails, quanto no próprio desenvolvimento da tecnologia Ruby on Rails.

Depois de ler esse guia, você saberá:

* O que são _Core Extensions_.
* Como carregar todas as extensões.
* Como escolher apenas as extensões que você precisa.
* Quais extensões o _Active Support_ fornece.

--------------------------------------------------------------------------------

Como Carregar _Core Extensions_
---------------------------

### _Active Support Stand-Alone_

Para ter o menor espaço padrão possível, o *Active Support* carrega as dependências mínimas por padrão. Ele é quebrado em pequenos pedaços para que apenas as extensões desejadas possam ser carregadas. Ele também possui alguns pontos de entrada convenientes para carregar extensões relacionadas de uma só vez, até mesmo tudo.

Portanto, é possível inicializar após o uso de um simples _require_ como:

```ruby
require "active_support"
```

apenas as extensões exigidas pela estrutura do *Active Support* são carregadas.

#### Escolhendo a Definição

Este exemplo mostra como carregar [`Hash#with_indifferent_access`][Hash#with_indifferent_access]. Esta extensão permite a conversão de um `Hash` em um [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess] que permite o acesso às chaves como *strings* ou *symbols*.

```ruby
{a: 1}.with_indifferent_access["a"] # => 1
```

Para cada método definido como _core extension_ esse guia possui uma nota que diz onde tal método é definido. No caso de `with_indifferent_access` a nota diz:

NOTE: Definido em `active_support/core_ext/hash/indifferent_access.rb`.

Isso significa que você pode fazer _requires_ assim:

```ruby
require "active_support"
require "active_support/core_ext/hash/indifferent_access"
```

O _Active Support_ foi cuidadosamente projetado para que as seleções de arquivos carreguem somente as dependências extremamente necessárias, caso existam.

#### Carregando _Core Extensions_ Agrupadas

O próximo passo é simplesmente carregar todas as extensões de `Hash`. Como regra geral, extensões para `SomeClass` estão disponíveis em um rápido carregamento de `active_support/core_ext/some_class`.

Portanto, para carregar todas as extensões de `Hash` (incluindo `with_indifferent_access`):

```ruby
require "active_support"
require "active_support/core_ext/hash"
```

#### Carregando Todas _Core Extensions_

Você pode escolher por carregar todas as extensões principais, há um arquivo para isso:

```ruby
require "active_support"
require "active_support/core_ext"
```

#### Carregando _Active Support_ Completamente

E finalmente, se você quer ter tudo que o _Active Support_ fornece, basta apenas:

```ruby
require "active_support/all"
```

Isso não vai inserir todo o _Active Support_ na memória antes do necessário, algumas funcionalidades são configuradas via _ʻautoload`_, então só são carregadas se usadas.

### _Active Support_ Em Uma Aplicação Ruby on Rails

Uma aplicação Ruby on Rails carrega todo o _Active Support_ a não ser que [`config.active_support.bare`][] esteja definida como `true`. Neste caso, a aplicação vai carregar apenas o que o próprio _framework_ escolhe como suas próprias necessidades, e ainda pode selecionar a si mesmo em qualquer nível de granularidade, conforme explicado na seção anterior.

[`config.active_support.bare`]: configuring.html#config-active-support-bare

Extensões para todos os objetos
-------------------------

### `blank?` e `present?`

Os seguintes valores são considerados _blank_ em uma aplicação Rails:

* `nil` e `false`,

* _strings_ compostas apenas por espaços em branco (veja a nota abaixo),

* _arrays_ e _hashes_ vazios, e

* qualquer outro objeto que responde a `empty?` como `true`.

INFO: A condicional é que as _strings_ usem a classe de caractere `[:space:]` do _Unicode-aware_, como por exemplo U+2029 (separador de parágrafo) é considerado um espaço em branco.

WARNING: Note que números não são mencionados. Em particular, 0 e 0.0 **não** são _blank_.

Por exemplo, este método de `ActionController::HttpAuthentication::Token::ControllerMethods` usa [`blank?`][Object#blank?] pra checar se o _token_ está presente:

```ruby
def authenticate(controller, &login_procedure)
  token, options = token_and_options(controller.request)
  unless token.blank?
    login_procedure.call(token, options)
  end
end
```

O método [`present?`][Object#present?] é equivalente ao `!blank?`. Este exemplo disponível em `ActionDispatch::Http::Cache::Response`:

```ruby
def set_conditional_cache_control!
  return if self["Cache-Control"].present?
  # ...
end
```

NOTE: Definido em `active_support/core_ext/object/blank.rb`.

[Object#blank?]: https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F
[Object#present?]: https://api.rubyonrails.org/classes/Object.html#method-i-present-3F

### `presence`

O método [`presence`][Object#presence] retorna seu valor se `present?` for `true`, e `nil` caso não seja. Isso é muito útil para expressões como esta:

```ruby
host = config[:host].presence || 'localhost'
```

NOTE: Definido em `active_support/core_ext/object/blank.rb`.

[Object#presence]: https://api.rubyonrails.org/classes/Object.html#method-i-presence

### `duplicable?`

A partir do Ruby 2.5, a maioria dos objetos podem ser duplicados com `dup` ou `clone`:

```ruby
"foo".dup           # => "foo"
"".dup              # => ""
Rational(1).dup     # => (1/1)
Complex(0).dup      # => (0+0i)
1.method(:+).dup    # => TypeError (allocator undefined for Method)
```

O _Active Support_ fornece o [`duplicable?`][Object#duplicable?] para consultar se o objeto pode ser duplicado:

```ruby
"foo".duplicable?           # => true
"".duplicable?              # => true
Rational(1).duplicable?     # => true
Complex(1).duplicable?      # => true
1.method(:+).duplicable?    # => false
```

WARNING: Qualquer classe pode ter a duplicação desabilitada a partir da remoção de `dup` e `clone` ou definindo exceções. Neste caso apenas `rescue` pode informar se determinado objeto arbitrável é duplicável. `duplicable?` depende da existência de uma lista de elementos a serem analisados, como no exemplo porém é muito mais veloz que `rescue`. Use apenas se você souber que a lista é suficiente em seu caso.

NOTE: Defined in `active_support/core_ext/object/duplicable.rb`.

[Object#duplicable?]: https://api.rubyonrails.org/classes/Object.html#method-i-duplicable-3F

### `deep_dup`

O método [`deep_dup`][Object#deep_dup] retorna uma cópia profunda de um objeto. Normalmente, quando você `dup` um objeto que contêm outros objetos, Ruby não executa o `dup`, então é criada uma cópia superficial do objeto. Caso você possua um _array_ com uma _string_, por exemplo, terá algo parecido com:

```ruby
array     = ['string']
duplicate = array.dup

duplicate.push 'another-string'

# the object was duplicated, so the element was added only to the duplicate
array     # => ['string']
duplicate # => ['string', 'another-string']

duplicate.first.gsub!('string', 'foo')

# first element was not duplicated, it will be changed in both arrays
array     # => ['foo']
duplicate # => ['foo', 'another-string']
```

Como podemos ver, depois de duplicar a instância de `Array`, possuímos agora outro objeto, portanto podemos modificá-lo sem alterar informações do objeto original. Isso não funciona para elementos de um _array_, entretanto. Desde que `dup` não faça a cópia profunda, a _string_ dentro do _array_ se manterá como o mesmo objeto.

Se você precisa de uma cópia profunda de um objeto, pode então usar o `deep_dup`. Confira um exemplo:

```ruby
array     = ['string']
duplicate = array.deep_dup

duplicate.first.gsub!('string', 'foo')

array     # => ['string']
duplicate # => ['foo']
```

Se o objeto não é duplicável, `deep_dup` apenas o retornará:

```ruby
number = 1
duplicate = number.deep_dup
number.object_id == duplicate.object_id   # => true
```

NOTE: Definido em `active_support/core_ext/object/deep_dup.rb`.

[Object#deep_dup]: https://api.rubyonrails.org/classes/Object.html#method-i-deep_dup

### `try`

Quando você quer chamar um método em um objeto somente se ele não for `nil`, a forma mais simples de conseguir isso é através de uma estrutura condicional, adicionando uma desnecessária desordem. A alternativa é usar [`try`][Object#try]. `try` é como `Object#public_send` exceto que o retorno seja `nil` se enviado para `nil`.

Eis um exemplo:

```ruby
# sem try
unless @number.nil?
  @number.next
end

# com try
@number.try(:next)
```

Outro exemplo é o código em `ActiveRecord::ConnectionAdapters::AbstractAdapter` onde `@logger` não pode ser `nil`. Você pode ver que o código usa `try` e evita uma verificação desnecessária.

```ruby
def log_info(sql, name, ms)
  if @logger.try(:debug?)
    name = '%s (%.1fms)' % [name || 'SQL', ms]
    @logger.debug(format_log_entry(name, sql.squeeze(' ')))
  end
end
```

`try` pode também ser chamada sem argumentos, porém em um bloco, no qual só será executado se o objeto não for `nil`:

```ruby
@person.try { |p| "#{p.first_name} #{p.last_name}" }
```

Perceba que `try` não exibirá as mensagens de erro caso elas ocorram, retornando `nil` em vez disso. Se você quiser se proteger de possíveis erros de digitação, use [`try!`][Object#try!]:

```ruby
@number.try(:nest)  # => nil
@number.try!(:nest) # NoMethodError: undefined method `nest' for 1:Integer
```

NOTE: Definido em `active_support/core_ext/object/try.rb`.

[Object#try]: https://api.rubyonrails.org/classes/Object.html#method-i-try
[Object#try!]: https://api.rubyonrails.org/classes/Object.html#method-i-try-21

### `class_eval(*args, &block)`

Você pode evoluir o código no contexto de um _singleton_ de qualquer objeto usando [`class_eval`][Kernel#class_eval]:

```ruby
class Proc
  def bind(object)
    block, time = self, Time.current
    object.class_eval do
      method_name = "__bind_#{time.to_i}_#{time.usec}"
      define_method(method_name, &block)
      method = instance_method(method_name)
      remove_method(method_name)
      method
    end.bind(object)
  end
end
```

NOTE: Definido em `active_support/core_ext/kernel/singleton_class.rb`.

[Kernel#class_eval]: https://api.rubyonrails.org/classes/Kernel.html#method-i-class_eval

### `acts_like?(duck)`

O método [`acts_like?`][Object#acts_like?] fornece um meio para conferir se alguma classe age como alguma outra classe baseada em uma simples convenção: a classe que fornece a mesma _interface_ é definida como `String`

```ruby
def acts_like_string?
end
```

que é apenas um marcador, seu corpo ou valor de retorno são irrelevantes. Então, o código do cliente pode consultar a tipagem desta forma:

```ruby
some_klass.acts_like?(:string)
```

Rails possui classes que agem como `Date` ou `Time` e seguem essa linha.

NOTE: Definido em `active_support/core_ext/object/acts_like.rb`.

[Object#acts_like?]: https://api.rubyonrails.org/classes/Object.html#method-i-acts_like-3F

### `to_param`

Todos objetos em Rails respondem ao método [`to_param`][Object#to_param], o qual é usado para retornar representações de valores em _strings_, no qual podem ser usadas em consultas, ou fragmentos de URL.

Por padrão, `to_param` apenas chama o método `to_s`:

```ruby
7.to_param # => "7"
```

O retorno de valores em `to_param` **não** deve ser ignorado:

```ruby
"Tom & Jerry".to_param # => "Tom & Jerry"
```

Várias classes em Rails sobrescrevem este método.

Por exemplo `nil`, `true`, e `false` retornam a si mesmo. [`Array#to_param`][Array#to_param] chama `to_param` para cada elemento, exibindo o resultado separando os elementos com "/":

```ruby
[0, true, String].to_param # => "0/true/String"
```

Notavelmente, as rotas de sistemas Rails chamam `to_param` em _models_ para obter o valor do campo `:id`. `ActiveRecord::Base#to_param` retorna o `id` do _model_, mas você pode redefinir esse método em seus _models_. Por exemplo, dado

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

nós temos:

```ruby
user_path(@user) # => "/users/357-john-smith"
```

WARNING. _Controllers_ precisam estar alinhados a qualquer redefinição de `to_param` porque quando uma requisição como essa chega em "357-john-smith" este é o valor de `params[:id]`.

NOTE: Definido em `active_support/core_ext/object/to_param.rb`.

[Array#to_param]: https://api.rubyonrails.org/classes/Array.html#method-i-to_param
[Object#to_param]: https://api.rubyonrails.org/classes/Object.html#method-i-to_param

### `to_query`

O método [`to_query`][Object#to_query] controi uma *query* em *string* que associam a `key` com o retorno de `to_param`. Por exemplo, dado a seguinte definição de `to_param`:

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

Temos:

```ruby
current_user.to_query('user') # => "user=357-john-smith"
```

Este método traz o que é necessário, tanto para chave, como para o valor:

```ruby
account.to_query('company[name]')
# => "company%5Bname%5D=Johnson+%26+Johnson"
```

então esse resultado esta pronto para ser usado em uma _string_ de busca.

_Arrays_ retornam o resultado da aplicação `to_query` para cada elemento com `key[]` como chave, e junta o resultado com "&":

```ruby
[3.4, -45.6].to_query('sample')
# => "sample%5B%5D=3.4&sample%5B%5D=-45.6"
```

_Hashes_ tambem respondem a `to_query` mas com uma diferença. Se não passar um argumento a chamada gera uma série ordenada de chaves/valores atribuídas chamando `to_query(key)` em seus valores. Em seguida, o resultado é mesclado com "&":

```ruby
{c: 3, b: 2, a: 1}.to_query # => "a=1&b=2&c=3"
```

O método [`Hash#to_query`][Hash#to_query] aceita um espaço para nomear as chaves:

```ruby
{id: 89, name: "John Smith"}.to_query('user')
# => "user%5Bid%5D=89&user%5Bname%5D=John+Smith"
```

NOTE: Definido em `active_support/core_ext/object/to_query.rb`.

[Hash#to_query]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_query
[Object#to_query]: https://api.rubyonrails.org/classes/Object.html#method-i-to_query

### `with_options`

O método [`with_options`][Object#with_options] fornece um meio de agrupar opções comuns em uma série de chamada de métodos.

Dado as opções _default_ de uma _hash_, `with_options` faz um objeto de "ponte" em um bloco. Dentro do bloco, métodos são chamados no objeto e são encaminhados ao receptor com suas opções mescladas. Por exemplo, você se livra da duplicação em:

```ruby
class Account < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :products,  dependent: :destroy
  has_many :invoices,  dependent: :destroy
  has_many :expenses,  dependent: :destroy
end
```

desta forma:

```ruby
class Account < ApplicationRecord
  with_options dependent: :destroy do |assoc|
    assoc.has_many :customers
    assoc.has_many :products
    assoc.has_many :invoices
    assoc.has_many :expenses
  end
end
```

Essa expressão pode transmitir um agrupamento para o leitor também. Por exemplo, digamos que você queira enviar um boletim informativo cujo idioma depende do usuário. Em algum lugar na _mailer_ você poderá agrupar os receptores por localidade como no exemplo:

```ruby
I18n.with_options locale: user.locale, scope: "newsletter" do |i18n|
  subject i18n.t :subject
  body    i18n.t :body, user_name: user.name
end
```

TIP: Desde que `with_options` envie chamadas para seus receptores eles podem ser aninhados. Cada nível de aninhamento mesclará os padrões herdados com os seus próprios.

NOTE: Definido em `active_support/core_ext/object/with_options.rb`.

[Object#with_options]: https://api.rubyonrails.org/classes/Object.html#method-i-with_options

### Suporte ao JSON

_Active Support_ fornece uma melhor implementação para `to_json` do que a _gem_ `json` normalmente fornece para objetos em Ruby. Isso é porque algumas classes, como `Hash`, e `Process::Status` precisam de manipulações especiais a fim de fornecer uma representação de JSON adequada.

NOTE: Definido em `active_support/core_ext/object/json.rb`.

### Variáveis de Instância

_Active Support_ fornece vários métodos para facilitar o acesso a variáveis de instância.

#### `instance_values`

O método [`instance_values`][Object#instance_values] retorna uma _hash_ que mapeia variáveis de instância de nomes sem "@" para seus
valores correspondentes. As chaves são _strings_:

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_values # => {"x" => 0, "y" => 1}
```

NOTE: Definido em `active_support/core_ext/object/instance_variables.rb`.

[Object#instance_values]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_values

#### `instance_variable_names`

O método [`instance_variable_names`][Object#instance_variable_names] retorna um _array_. Cada nome inclui o sinal "@".

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_variable_names # => ["@x", "@y"]
```

NOTE: Definido em `active_support/core_ext/object/instance_variables.rb`.

[Object#instance_variable_names]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_variable_names

### Silenciando _Warnings_ e Exceções

Os métodos [`silence_warnings`][Kernel#silence_warnings] e [`enable_warnings`][Kernel#enable_warnings] trocam o valor de `$VERBOSE` de acordo com a duração do seu bloco, e o reiniciam depois:

```ruby
silence_warnings { Object.const_set "RAILS_DEFAULT_LOGGER", logger }
```

Silenciar exceções também é possível com [`suppress`][Kernel#suppress]. Este método recebe um número arbitrário de classes de exceção. Se uma exceção é acionada durante a execução de um bloco e é `kind_of?` qualquer um dos argumentos, `suppress` captura e retorna silenciosamente. Caso contrário, a exceção não é capturada:

```ruby
# If the user is locked, the increment is lost, no big deal.
suppress(ActiveRecord::StaleObjectError) do
  current_user.increment! :visits
end
```

NOTE: Definido in `active_support/core_ext/kernel/reporting.rb`.

[Kernel#enable_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-enable_warnings
[Kernel#silence_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-silence_warnings
[Kernel#suppress]: https://api.rubyonrails.org/classes/Kernel.html#method-i-suppress

### `in?`

A expressão [`in?`][Object#in?] testa se um objeto é incluído em outro objeto. Uma exceção `ArgumentError` será acionada se o argumento passado não responder a `include?`.

Exemplos de `in?`:

```ruby
1.in?([1,2])        # => true
"lo".in?("hello")   # => true
25.in?(30..50)      # => false
1.in?(1)            # => ArgumentError
```

NOTE: Definido em `active_support/core_ext/object/inclusion.rb`.

[Object#in?]: https://api.rubyonrails.org/classes/Object.html#method-i-in-3F

Extensões de `Module`
----------------------

### Atributos

#### `alias_attribute`

Atributos de _models_ podem ser lidos, escritos e condicionados. Você pode criar um _alias_ para um atributo de _model_ correspondendo todos os três métodos definidos por você usando [`alias_attribute`][Module#alias_attribute]. Em outro métodos de _alias_, o novo nome é o primeiro argumento, e o antigo nome é o segundo (uma forma de memorizar é pensar que eles se apresentam na mesma ordem como se você fizesse uma atribuição):

```ruby
class User < ApplicationRecord
  # Você pode referenciar a coluna email como "login".
  # Isso pode ser importante para o código de autenticação.
  alias_attribute :login, :email
end
```

NOTE: Definido em `active_support/core_ext/module/aliasing.rb`.

[Module#alias_attribute]: https://api.rubyonrails.org/classes/Module.html#method-i-alias_attribute

#### Atributos Internos

Quando você esta definindo um atributo em uma classe que pode ser uma subclasse, os conflitos de nomes são um risco. Isso é extremamente importante para as bibliotecas.

_Active Support_ define as macros [`attr_internal_reader`][Module#attr_internal_reader], [`attr_internal_writer`][Module#attr_internal_writer], e [`attr_internal_accessor`][Module#attr_internal_accessor]. Elas comportam-se como seu próprio Ruby `attr_*` embutido, exceto pelos nomes de variáveis de instância que faz com que os conflitos sejam menos comuns.

A macro [`attr_internal`][Module#attr_internal] é um sinônimo para `attr_internal_accessor`:

```ruby
# biblioteca
class ThirdPartyLibrary::Crawler
  attr_internal :log_level
end

# código do cliente
class MyCrawler < ThirdPartyLibrary::Crawler
  attr_accessor :log_level
end
```

No exemplo anterior, poderia ser que no caso `:log_level` não pertença a interface pública da biblioteca e só seria usada em desenvolvimento. O código do cliente, não sabe do potencial conflito, subclasses e definições de seus próprios `:log_level`. Graças ao `attr_internal` não há conflito.

Por padrão, a variável de instancia interna é nomeada com uma _underscore_ na frente, `@_log_level` no exemplo acima. Isso é configurável via `Module.attr_internal_naming_format` apesar disso, você pode passar qualquer tipo de `sprintf` no formato _string_ com a inicial `@` e um `%s` em algum lugar, no qual é onde o nome será colocado. O padrão é `"@_%s"`.

Rails usa atributos internos em alguns pontos, para _views_ como por exemplo:

```ruby
module ActionView
  class Base
    attr_internal :captures
    attr_internal :request, :layout
    attr_internal :controller, :template
  end
end
```

NOTE: Definido em `active_support/core_ext/module/attr_internal.rb`.

[Module#attr_internal]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal
[Module#attr_internal_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_accessor
[Module#attr_internal_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_reader
[Module#attr_internal_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_writer

#### Atributos de Módulo

As macros [`mattr_reader`][Module#mattr_reader], [`mattr_writer`][Module#mattr_writer], e [`mattr_accessor`][Module#mattr_accessor] São iguais a `cattr_*` macros definidas na classe. De fato, `cattr_*` macros são apenas _aliases_ para as `mattr_*` macros. Confira a seção [Atributos de Classe](#atributos-de-classe).


Por exemplo, a API para o registrador do *Active Storage* é gerada com `mattr_accessor`:

```ruby
module ActiveStorage
  mattr_accessor :logger
end
```

NOTE: Definido em `active_support/core_ext/module/attribute_accessors.rb`.

[Module#mattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_accessor
[Module#mattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_reader
[Module#mattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_writer

### _Parents_

#### `module_parent`

O método [`module_parent`][Module#module_parent] em um módulo nomeado aninhado que retorna o módulo que contém uma constante correspondente:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent # => X::Y
M.module_parent       # => X::Y
```

Se o módulo é anônimo ou pertence a um nível superior, `module_parent` retorna `Object`.

WARNING: Note que neste caso `module_parent_name` retorna `nil`.

NOTE: Definido em `active_support/core_ext/module/introspection.rb`.

[Module#module_parent]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent

#### `module_parent_name`

O método [`module_parent_name`][Module#module_parent_name] em um modulo nomeado aninhado  retorna o nome completamente qualificado do módulo que contém sua constante correspondente:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent_name # => "X::Y"
M.module_parent_name       # => "X::Y"
```

Para módulos de nível superior ou anônimos `module_parent_name` retorna `nil`.

WARNING: Note que nesse caso `module_parent` retorna `Object`.

NOTE: Definido em `active_support/core_ext/module/introspection.rb`.

[Module#module_parent_name]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent_name

#### `module_parents`

O método [`module_parents`][Module#module_parents] chama `module_parent` no receptor e sobe até `Object` ser alcançado. A cadeia é retornada em uma matriz, de baixo para cima:

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parents # => [X::Y, X, Object]
M.module_parents       # => [X::Y, X, Object]
```

NOTE: Definido em `active_support/core_ext/module/introspection.rb`.

[Module#module_parents]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parents

### Anônimo

Um módulo pode ou não ter um nome:

```ruby
module M
end
M.name # => "M"

N = Module.new
N.name # => "N"

Module.new.name # => nil
```

Você pode verificar se um módulo possui um nome com a condicional [`anonymous?`][Module#anonymous?]:

```ruby
module M
end
M.anonymous? # => false

Module.new.anonymous? # => true
```

Observe que estar inacessível não significa ser anônimo:

```ruby
module M
end

m = Object.send(:remove_const, :M)

m.anonymous? # => false
```

Embora um módulo anônimo seja inacessível por definição.

NOTE: Definido em `active_support/core_ext/module/anonymous.rb`.

[Module#anonymous?]: https://api.rubyonrails.org/classes/Module.html#method-i-anonymous-3F

### Delegação de Método

#### `delegate`

A macro [`delegate`][Module#delegate] oferece uma maneira fácil de encaminhar métodos.

Vamos imaginar que os usuários de alguma aplicação possuem informações de _login_ no _model_ `User` além de nome e outro dado em um _model_ `Profile` separado:

```ruby
class User < ApplicationRecord
  has_one :profile
end
```

Com essa configuração você consegue o nome dos usuários partir da classe perfil, `user.profile.name`, mas isso poderia ser conveniente para habilitar o acesso ao atributo diretamente:

```ruby
class User < ApplicationRecord
  has_one :profile

  def name
    profile.name
  end
end
```

Isso é o que o `delegate` faz por você:

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate :name, to: :profile
end
```

É mais curto e a intenção mais óbvia.

O método deve ser público.

A macro `delegate` aceita vários métodos:

```ruby
delegate :name, :age, :address, :twitter, to: :profile
```

Quando interpolado em uma _string_, a opção `:to` deve se tornar uma expressão que avalia o objeto ao qual o método é delegado. Normalmente uma _string_ ou um _symbol_. Tal expressão é avaliada no contexto do receptor:

```ruby
# delega para as constantes Rails
delegate :logger, to: :Rails

# delega para as classes receptoras
delegate :table_name, to: :class
```

WARNING: Se a opção `:prefix` for `true` é menos genérica, veja abaixo.

Por padrão, se a delegação resulta em `NoMethodError` e o objeto é `nil` a exceção se propaga. Você pode perguntar se `nil` é retornado ao invés com a opção `:allow_nil`:

```ruby
delegate :name, to: :profile, allow_nil: true
```

Com `:allow_nil` a chamada `user.name` retorna `nil` se o usuário não tiver um perfil.

A opção `:prefix` adiciona um prefixo ao nome do método gerado. Isso pode ser útil, por exemplo, para obter um nome melhor:

```ruby
delegate :street, to: :address, prefix: true
```

Os exemplos prévios geram `address_street` ao invés de `street`.

WARNING: Já que neste caso o nome do método gerado é composto pelos nomes do objeto alvo e do método alvo, a opção `:to` deve ser um nome de método.

Um prefixo customizado pode também ser configurado:

```ruby
delegate :size, to: :attachment, prefix: :avatar
```

Os macro exemplos prévios geram `avatar_size` ao invés de `size`.

A opção `:private` mudam o escopo do método:

```ruby
delegate :date_of_birth, to: :profile, private: true
```

Os métodos delegados são públicos por padrão. Passe `private: true` para mudar isso.

NOTE: Definido em `active_support/core_ext/module/delegation.rb`

[Module#delegate]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate

#### `delegate_missing_to`

Imagine que você gostaria de delegar tudo o que está faltando no objeto `User`,
para um `Profile`. A macro [`delegate_missing_to`][Module#delegate_missing_to] permite que você implemente isso
de forma facilitada:

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate_missing_to :profile
end
```

O destino pode ser qualquer coisa que possa ser chamada dentro do objeto, por exemplo: instância de variáveis,
métodos, constantes etc. Somente métodos públicos do alvo são delegados.

NOTE: Definido em `active_support/core_ext/module/delegation.rb`.

[Module#delegate_missing_to]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate_missing_to

### Redefinindo Métodos

Existem casos onde você precisa definir um método com `define_method`, mas não sei se já existe um método com esse nome. Caso sim, um _warning_ é exibido se estiverem habilitados. Não é muito perigoso, mas não é uma boa prática.

O método [`redefine_method`][Module#redefine_method] previne um potencial _warning_, removendo um método existente, se necessário.

Você pode também usar [`silence_redefinition_of_method`][Module#silence_redefinition_of_method] se você precisa definir
o método de substituição (porque você está usando `delegate`, por
exemplo).

NOTE: Definido em `active_support/core_ext/module/redefine_method.rb`.

[Module#redefine_method]: https://api.rubyonrails.org/classes/Module.html#method-i-redefine_method
[Module#silence_redefinition_of_method]: https://api.rubyonrails.org/classes/Module.html#method-i-silence_redefinition_of_method

Extensões para `Class`
---------------------

### Atributos de classe

#### `class_attribute`

O método [`class_attribute`][Class#class_attribute] declara um ou mais atributos de classe herdáveis que podem ser substituídos em qualquer nível abaixo da hierarquia.

```ruby
class A
  class_attribute :x
end

class B < A; end

class C < B; end

A.x = :a
B.x # => :a
C.x # => :a

B.x = :b
A.x # => :a
C.x # => :b

C.x = :c
A.x # => :a
B.x # => :b
```

Por exemplo `ActionMailer::Base` define:

```ruby
class_attribute :default_params
self.default_params = {
  mime_version: "1.0",
  charset: "UTF-8",
  content_type: "text/plain",
  parts_order: [ "text/plain", "text/enriched", "text/html" ]
}.freeze
```

Eles também podem ser acessados e substituídos no nível de instância.

```ruby
A.x = 1

a1 = A.new
a2 = A.new
a2.x = 2

a1.x # => 1, vem de A
a2.x # => 2, substituído em a2
```

A criação de um método de instância de escrita pode ser prevenido configurando a opção `:instance_writer` para `false`.

```ruby
module ActiveRecord
  class Base
    class_attribute :table_name_prefix, instance_writer: false, default: "my"
  end
end
```

Essa opção pode ser útil para prevenir atribuições em massa ao definir o atributo.

A criação de um método de instância de leitura pode ser prevenido configurando a opção `:instance_reader` para `false`.

```ruby
class A
  class_attribute :x, instance_reader: false
end

A.new.x = 1
A.new.x # NoMethodError
```

Por conveniência `class_attribute` também define um predicado de instância que é uma negação dupla do que o leitor de instância retorna. No exemplo acima podemos usar `x?`.

Quando `:instance_reader` é `false`, o predicado de instância retorna `NoMethodError` assim como o método de leitura.

Se você não quiser o predicado de instância, passe `instance_predicate: false` e ele não será definido.

NOTE: Definido em `active_support/core_ext/class/attribute.rb`.

[Class#class_attribute]: https://api.rubyonrails.org/classes/Class.html#method-i-class_attribute

#### `cattr_reader`, `cattr_writer`, e `cattr_accessor`

As macros [`cattr_reader`][Module#cattr_reader], [`cattr_writer`][Module#cattr_writer], e [`cattr_accessor`][Module#cattr_accessor] são análogas às suas `attr_*` homólogas porém para classes. Eles inicializam a variável de classe com `nil` a menos que ela já exista, e gera os métodos de classe correspondentes para acessá-la:

```ruby
class MysqlAdapter < AbstractAdapter
  # Gera métodos de classe para acessar @@emulate_booleans.
  cattr_accessor :emulate_booleans
end
```

Além disso, você pode passar um bloco para `cattr_*` para configurar o atributo com um valor padrão.

```ruby
class MysqlAdapter < AbstractAdapter
  # Gera métodos de classe para acessar @@emulate_booleans com true como valor padrão.
  cattr_accessor :emulate_booleans, default: true
end
```

Métodos de instância são criados também por conveniência, eles são apenas uma forma de acesso ao atributo de classe. Logo, instâncias podem alterar o atributo de classe, porém não podem substituí-lo do mesmo modo que ocorre com `class_attribute` (veja acima). Por exemplo, dado

```ruby
module ActionView
  class Base
    cattr_accessor :field_error_proc, default: Proc.new { ... }
  end
end
```

podemos acessar `field_error_proc` nas *views*.

A geração do método de leitura de instância pode ser prevenido configurando `:instance_reader` para `false` e a geração dos métodos de escrita de instância podem ser prevenidos configurando `:instance_writer` para `false`. A geração de ambos os métodos podem ser prevenidos configurando `:instance_accessor` para `false`. Em todos os casos, o valor deve ser exatamente `false` e não qualquer outro valor falso.

```ruby
module A
  class B
    # Nenhuma leitura de instância first_name é gerada.
    cattr_accessor :first_name, instance_reader: false
    # Nenhuma escrita de instância last_name= é gerada.
    cattr_accessor :last_name, instance_writer: false
    # Nenhuma leitura surname ou escritor surname= de instância é gerada.
    cattr_accessor :surname, instance_accessor: false
  end
end
```

Pode ser útil configurar `:instance_accessor` para `false` no *model* como uma maneira de prevenir atribuições em massa ao definir o atributo.

NOTE: Definido em `active_support/core_ext/module/attribute_accessors.rb`.

[Module#cattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_accessor
[Module#cattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_reader
[Module#cattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_writer

### Subclasses e Descendentes

#### `subclasses`

O método [`subclasses`][Class#subclasses] retorna as subclasses do recebedor:

```ruby
class C; end
C.subclasses # => []

class B < C; end
C.subclasses # => [B]

class A < B; end
C.subclasses # => [B]

class D < C; end
C.subclasses # => [B, D]
```

A ordem em que essas classes são retornadas não é especificada.

NOTE: Definido em `active_support/core_ext/class/subclasses.rb`.

[Class#subclasses]: https://api.rubyonrails.org/classes/Class.html#method-i-subclasses

#### `descendants`

O método [`descendants`][Class#descendants] retorna todas as classes que são `<` pelo recebedor:

```ruby
class C; end
C.descendants # => []

class B < C; end
C.descendants # => [B]

class A < B; end
C.descendants # => [B, A]

class D < C; end
C.descendants # => [B, A, D]
```

A ordem em que essas classes são retornadas não é especificada.

NOTE: Definido em `active_support/core_ext/class/subclasses.rb`.

[Class#descendants]: https://api.rubyonrails.org/classes/Class.html#method-i-descendants

Extensões para `String`
----------------------

### Segurança de saída 

#### Motivação

Inserir dados em _templates_ HTML, necessita de cuidados extras. Por exemplo, você não pode apenas literalmente juntar `@review.title` em uma página HTML. Por outro lado, se o título do comentário é "Flanagan & Matz rules!" o retorno não será bem formada porque um 'e comercial' precisa ser usado como "&amp;amp;". Além do mais, dependendo da aplicação, isso pode ser uma grande falha de segurança porque os usuários podem injetar uma configuração HTML maliciosa em um título de revisão feito à mão. Confira a seção sobre _cross-site scripting_ em [Guia de Segurança](security.html#cross-site-scripting-xss) para maiores informações sobre os riscos.

#### _Strings_ Seguras

_Active Support_ possui o conceito de _(html)_ _strings_ seguras. Uma _string_ segura é aquela que é marcada como sendo inserível no HTML como é definida. Ela é confiável, não importando sua origem.

_Strings_ são consideradas como inseguras por padrão:

```ruby
"".html_safe? # => false
```

Pode-se obter uma _string_ segura de um dado com o método [`html_safe`][String#html_safe]:

```ruby
s = "".html_safe
s.html_safe? # => true
```

É importante entender que `html_safe` não executa nenhuma operação, é apenas uma afirmação:

```ruby
s = "<script>...</script>".html_safe
s.html_safe? # => true
s            # => "<script>...</script>"
```

É sua responsabilidade garantir a chamada `html_safe` em cada _string_ particular.

Se você anexar em uma _string_ segura, com `concat`/`<<`, ou com `+`, o resultado é uma _string_ segura. Argumentos inseguros são ignorados:

```ruby
"".html_safe + "<" # => "&lt;"
```

Argumentos seguros são anexados diretamente:

```ruby
"".html_safe + "<".html_safe # => "<"
```

Esses métodos não devem ser usados em _views_ comuns. Valores inseguros são ignorados automaticamente:

```erb
<%= @review.title %> <%# correto, ignora se necessário %>
```

Para inserir algo literal, use o _helper_ [`raw`][] ao invés de chamar `html_safe`:

```erb
<%= raw @cms.current_template %> <%# insere @cms.current_template como é %>
```

ou, equivalentemente, use `<%==`:

```erb
<%== @cms.current_template %> <%# insere @cms.current_template como é %>
```

O _helper_ `raw` chama `html_safe` pra você:

```ruby
def raw(stringish)
  stringish.to_s.html_safe
end
```

NOTE: Definido em `active_support/core_ext/string/output_safety.rb`.

[`raw`]: https://api.rubyonrails.org/classes/ActionView/Helpers/OutputSafetyHelper.html#method-i-raw
[String#html_safe]: https://api.rubyonrails.org/classes/String.html#method-i-html_safe

#### Transformação

De modo geral, exceto talvez para concatenação conforme explicado acima, qualquer método que possa alterar uma _string_ fornece uma _string_ insegura. Estes são `downcase`, `gsub`, `strip`, `chomp`, `underscore`, etc.

No caso de transformações locais, como com `gsub!` o próprio receptor se torna inseguro.

INFO: O bit de segurança é perdido sempre, não importa se a transformação realmente mudou algo.

#### Conversão e Coerção

Chamando `to_s` em uma _string_ segura retorna uma _string_ segura, mas a coerção com `to_str` retorna uma _string_ insegura.

#### Copiando

Chamando `dup` ou `clone` em _strings_ seguras produz outras _strings_ seguras.

### `remove`

O método [`remove`][String#remove] vai remover todas ocorrências com o padrão:

```ruby
"Hello World".remove(/Hello /) # => "World"
```

Há também a versão destrutiva `String#remove!`.

NOTE: Definido em `active_support/core_ext/string/filters.rb`.

[String#remove]: https://api.rubyonrails.org/classes/String.html#method-i-remove

### `squish`

O método [`squish`][String#squish] remove os espaços em branco à esquerda e à direita e substitui os espaços em branco por um único espaço cada:

```ruby
" \n  foo\n\r \t bar \n".squish # => "foo bar"
```

Há também a versão destrutiva `String#squish!`.

Observe que se lida com espaços em branco ASCII e Unicode.

NOTE: Definido em `active_support/core_ext/string/filters.rb`.

[String#squish]: https://api.rubyonrails.org/classes/String.html#method-i-squish

### `truncate`

O método [`truncate`][String#truncate] retorna uma cópia de seu receptor truncado após um determinado `length`:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20)
# => "Oh dear! Oh dear!..."
```

As reticências podem ser personalizadas com a opção `:omission`:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20, omission: '&hellip;')
# => "Oh dear! Oh &hellip;"
```

Observe em particular que o truncamento leva em consideração o comprimento da _string_ de omissão.

Passe o método `:separator` para truncar a _string_ em uma pausa natural:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18)
# => "Oh dear! Oh dea..."
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: ' ')
# => "Oh dear! Oh..."
```

A opção `:separator` pode ser uma regexp:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: /\s/)
# => "Oh dear! Oh..."
```

Nos exemplos acima "dear" é cortado primeiro, mas depois `:separator` impede isso.

NOTE: Definido em `active_support/core_ext/string/filters.rb`.

[String#truncate]: https://api.rubyonrails.org/classes/String.html#method-i-truncate

### `truncate_bytes`

O método [`truncate_bytes`][String#truncate_bytes] retorna uma cópia de seu receptor truncado para no máximo `bytesize` _bytes_:

```ruby
"👍👍👍👍".truncate_bytes(15)
# => "👍👍👍…"
```

As reticências podem ser personalizadas com a opção `:omission`:

```ruby
"👍👍👍👍".truncate_bytes(15, omission: "🖖")
# => "👍👍🖖"
```

NOTE: Definido em `active_support/core_ext/string/filters.rb`.

[String#truncate_bytes]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_bytes

### `truncate_words`

O método [`truncate_words`][String#truncate_words] retorna uma cópia da frase original truncada depois de receber um determinado número de palavras:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4)
# => "Oh dear! Oh dear!..."
```

Reticências podem ser customizadas com a opção `:omission`:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, omission: '&hellip;')
# => "Oh dear! Oh dear!&hellip;"
```

Chame `:separator` para truncar a _string_ na pausa natural:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(3, separator: '!')
# => "Oh dear! Oh dear! I shall be late..."
```

A opção `:separator` pode ser uma regexp:

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, separator: /\s/)
# => "Oh dear! Oh dear!..."
```

NOTE: Definido em `active_support/core_ext/string/filters.rb`.

[String#truncate_words]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_words

### `inquiry`

O método [`inquiry`][String#inquiry] converte uma _string_ em um objeto `StringInquirer` fazendo verificações de igualdade mais elegantes.

```ruby
"production".inquiry.production? # => true
"active".inquiry.inactive?       # => false
```

NOTE: Definido em `active_support/core_ext/string/inquiry.rb`.

[String#inquiry]: https://api.rubyonrails.org/classes/String.html#method-i-inquiry

### `starts_with?` e `ends_with?`

_Active Support_ define conjugação verbal para 3ª pessoa em `String#start_with?` e `String#end_with?`:

```ruby
"foo".starts_with?("f") # => true
"foo".ends_with?("o")   # => true
```

NOTE: Definido em `active_support/core_ext/string/starts_ends_with.rb`.

### `strip_heredoc`

O método [`strip_heredoc`][String#strip_heredoc] tira o recuo em _heredocs_.

Por exemplo em

```ruby
if options[:usage]
  puts <<-USAGE.strip_heredoc
    This command does such and such.

    Supported options are:
      -h         This message
      ...
  USAGE
end
```

o usuário veria a mensagem de uso alinhada à margem esquerda.

Tecnicamente, se procura a linha menos indentada em toda a _string_ e remove
essa quantidade de espaço em branco à esquerda.

NOTE: Defined in `active_support/core_ext/string/strip.rb`.

[String#strip_heredoc]: https://api.rubyonrails.org/classes/String.html#method-i-strip_heredoc

### `indent`

O método [`indent`][String#indent] indenta as linhas no receptor:

```ruby
<<EOS.indent(2)
def some_method
  some_code
end
EOS
# =>
  def some_method
    some_code
  end
```

O segundo argumento, `indent_string`, especifica qual _string_ de indentação usar. O padrão é `nil`, que diz ao método para fazer uma suposição conferindo a primeira linha indentada, e recuando para um espaço se não houver nenhuma.

```ruby
"  foo".indent(2)        # => "    foo"
"foo\n\t\tbar".indent(2) # => "\t\tfoo\n\t\t\t\tbar"
"foo".indent(2, "\t")    # => "\t\tfoo"
```

Enquanto `indent_string` é normalmente um espaço ou tabulação, essa pode ser qualquer _string_.

O terceiro argumento, `indent_empty_lines`, é uma sinalização que diz se as linhas vazias devem ser indentadas. O padrão é _false_.

```ruby
"foo\n\nbar".indent(2)            # => "  foo\n\n  bar"
"foo\n\nbar".indent(2, nil, true) # => "  foo\n  \n  bar"
```

O método [`indent!`][String#indent!] realiza recuo no local.

NOTE: Definido em `active_support/core_ext/string/indent.rb`.

[String#indent!]: https://api.rubyonrails.org/classes/String.html#method-i-indent-21
[String#indent]: https://api.rubyonrails.org/classes/String.html#method-i-indent

### Acesso

#### `at(position)`

O método [`at`][String#at] retorna o caractere da _string_ na posição `position`:

```ruby
"hello".at(0)  # => "h"
"hello".at(4)  # => "o"
"hello".at(-1) # => "o"
"hello".at(10) # => nil
```

NOTE: Definido em `active_support/core_ext/string/access.rb`.

[String#at]: https://api.rubyonrails.org/classes/String.html#method-i-at

#### `from(position)`

O método [`from`][String#from] retorna a _substring_ da _string_ iniciada na posição `position`:

```ruby
"hello".from(0)  # => "hello"
"hello".from(2)  # => "llo"
"hello".from(-2) # => "lo"
"hello".from(10) # => nil
```

NOTE: Definido em `active_support/core_ext/string/access.rb`.

[String#from]: https://api.rubyonrails.org/classes/String.html#method-i-from

#### `to(position)`

O método [`to`][String#to] retorna a _substring_ da _string_ até a posição `position`:

```ruby
"hello".to(0)  # => "h"
"hello".to(2)  # => "hel"
"hello".to(-2) # => "hell"
"hello".to(10) # => "hello"
```

NOTE: Definido em `active_support/core_ext/string/access.rb`.

[String#to]: https://api.rubyonrails.org/classes/String.html#method-i-to

#### `first(limit = 1)`

O método [`first`][String#first] retorna a _substring_ contendo os primeiros `limit` caracteres da _string_.

A chamada `str.first(n)` é equivalente a `str.to(n-1)` se `n` > 0, e retorna uma _string_ vazia para `n` == 0.

NOTE: Definido em `active_support/core_ext/string/access.rb`.

[String#first]: https://api.rubyonrails.org/classes/String.html#method-i-first

#### `last(limit = 1)`

O método [`last`][String#last] retorna a _substring_ contendo os últimos `limit` caracteres da _string_.

A chamada `str.last(n)` é equivalente a `str.from(-n)` se `n` > 0, e retorna uma _string_ vazia para `n` == 0.

NOTE: Definido em `active_support/core_ext/string/access.rb`.

[String#last]: https://api.rubyonrails.org/classes/String.html#method-i-last

### Inflexões

#### `pluralize`

O método [`pluralize`][String#pluralize] retorna o plural do receptor:

```ruby
"table".pluralize     # => "tables"
"ruby".pluralize      # => "rubies"
"equipment".pluralize # => "equipment"
```

Como mostra o exemplo anterior, _Active Support_ conhece alguns plurais irregulares e substantivos incontáveis. As regras integradas podem ser estendidas em `config/initializers/inflections.rb`. Este arquivo é gerado por padrão, pelo comando `rails new` e tem instruções nos comentários.

`pluralize` também pode fazer um parâmetro `count` opcional. Se `count == 1` a forma singular será retornada. Para qualquer outro valor de `count` a forma plural será retornada:

```ruby
"dude".pluralize(0) # => "dudes"
"dude".pluralize(1) # => "dude"
"dude".pluralize(2) # => "dudes"
```

_Active Record_ usa esse método pra computar a o nome da tabela padrão correspondente ao _model_:

```ruby
# active_record/model_schema.rb
def undecorated_table_name(model_name)
  table_name = model_name.to_s.demodulize.underscore
  pluralize_table_names ? table_name.pluralize : table_name
end
```

NOTE: Definido `active_support/core_ext/string/inflections.rb`.

[String#pluralize]: https://api.rubyonrails.org/classes/String.html#method-i-pluralize

#### `singularize`

O método [`singularize`][String#singularize] é o inverso do `pluralize`:

```ruby
"tables".singularize    # => "table"
"rubies".singularize    # => "ruby"
"equipment".singularize # => "equipment"
```

As associações calculam o nome padrão da classe associada correspondente usando este método:

```ruby
# active_record/reflection.rb
def derive_class_name
  class_name = name.to_s.camelize
  class_name = class_name.singularize if collection?
  class_name
end
```

NOTE: Definido em `active_support/core_ext/string/inflections.rb`.

[String#singularize]: https://api.rubyonrails.org/classes/String.html#method-i-singularize

#### `camelize`

O método [`camelize`][String#camelize] retorna o receptor em _camel case_:

```ruby
"product".camelize    # => "Product"
"admin_user".camelize # => "AdminUser"
```

Como regra geral, você pode pensar neste método como aquele que transforma pastas em nomes de classes ou módulos _Ruby_, em que barras separam os subarquivos:

```ruby
"backoffice/session".camelize # => "Backoffice::Session"
```

Por exemplo, o _Action Pack_ usa este método para carregar a classe que fornece um determinado armazenamento de sessão:

```ruby
# action_controller/metal/session_management.rb
def session_store=(store)
  @@session_store = store.is_a?(Symbol) ?
    ActionDispatch::Session.const_get(store.to_s.camelize) :
    store
end
```

`camelize` aceita um argumento opcional, que pode ser `:upper` (padrão), ou `:lower`. Com o último, a primeira letra torna-se minúscula:

```ruby
"visual_effect".camelize(:lower) # => "visualEffect"
```

Isso pode ser útil para calcular nomes de métodos em uma linguagem que segue essa convenção, por exemplo, _JavaScript_.

INFO: Como regra geral, você pode pensar em `camelize` como o inverso do `underscore`, embora haja casos em que isso não se aplica: `"SSLError".underscore.camelize` devolve `"SslError"`. Para apoiar casos como este, o _Active Support_ permite que você especifique acrônimos em `config/initializers/inflections.rb`:

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'SSL'
end

"SSLError".underscore.camelize # => "SSLError"
```

`camelize` é o mesmo que usar [`camelcase`][String#camelcase].

NOTE: Definido em `active_support/core_ext/string/inflections.rb`.

[String#camelcase]: https://api.rubyonrails.org/classes/String.html#method-i-camelcase
[String#camelize]: https://api.rubyonrails.org/classes/String.html#method-i-camelize

#### `underscore`

O método [`underscore`][String#underscore] vai ao contrário, de _camel case_ para pastas:

```ruby
"Product".underscore   # => "product"
"AdminUser".underscore # => "admin_user"
```

Também converte "::" back para "/":

```ruby
"Backoffice::Session".underscore # => "backoffice/session"
```

e entende _strings_ que começam com start letra minúscula:

```ruby
"visualEffect".underscore # => "visual_effect"
```

`underscore` não aceita nenhum argumento.

O Rails usa de `underscore` para inferir o nome de um controller ou class:

```ruby
# actionpack/lib/abstract_controller/base.rb
def controller_path
  @controller_path ||= name.delete_suffix("Controller").underscore
end
```

Por exemplo, esse valor é aquele que você obtém em `params[:controller]`.

INFO: Como regra geral, pode-se pensar em `underscore` como o inverso de `camelize`, embora haja casos em que isso não se aplica. Por exemplo, `"SSLError".underscore.camelize` devolve `"SslError"`.

NOTE: Definido em `active_support/core_ext/string/inflections.rb`.

[String#underscore]: https://api.rubyonrails.org/classes/String.html#method-i-underscore

#### `titleize`

O método [`titleize`][String#titleize] coloca cada palavra com letra maiúscula:

```ruby
"alice in wonderland".titleize # => "Alice In Wonderland"
"fermat's enigma".titleize     # => "Fermat's Enigma"
```

`titleize` é o mesmo que usar [`titlecase`][String#titlecase].

NOTE: Definido em `active_support/core_ext/string/inflections.rb`.

[String#titlecase]: https://api.rubyonrails.org/classes/String.html#method-i-titlecase
[String#titleize]: https://api.rubyonrails.org/classes/String.html#method-i-titleize

#### `dasherize`

O método [`dasherize`][String#dasherize] troca _underscores_ no receptor por traços:

```ruby
"name".dasherize         # => "name"
"contact_data".dasherize # => "contact-data"
```

O _serializer_ XML de _models_ usa este método para colocar traços nos nomes de seus nós:

```ruby
# active_model/serializers/xml.rb
def reformat_name(name)
  name = name.camelize if camelize?
  dasherize? ? name.dasherize : name
end
```

NOTE: Definido em `active_support/core_ext/string/inflections.rb`.

[String#dasherize]: https://api.rubyonrails.org/classes/String.html#method-i-dasherize

#### `demodulize`

Dado uma _string_ com um nome de constante em módulo, [`demodulize`][String#demodulize] retorna o real nome da constante, ou seja, a parte mais à direita dela:

```ruby
"Product".demodulize                        # => "Product"
"Backoffice::UsersController".demodulize    # => "UsersController"
"Admin::Hotel::ReservationUtils".demodulize # => "ReservationUtils"
"::Inflections".demodulize                  # => "Inflections"
"".demodulize                               # => ""
```

_Active Record_ por exemplo, usa este método para calcular o nome de uma coluna de cache do contador:

```ruby
# active_record/reflection.rb
def counter_cache_column
  if options[:counter_cache] == true
    "#{active_record.name.demodulize.underscore.pluralize}_count"
  elsif options[:counter_cache]
    options[:counter_cache]
  end
end
```

NOTE: Definido em `active_support/core_ext/string/inflections.rb`.

[String#demodulize]: https://api.rubyonrails.org/classes/String.html#method-i-demodulize

#### `deconstantize`

Dada uma _string_ com uma expressão de referência a uma constante, [`deconstantize`][String#deconstantize] remove o segmento mais à direita, geralmente deixando o nome do contêiner da constante:

```ruby
"Product".deconstantize                        # => ""
"Backoffice::UsersController".deconstantize    # => "Backoffice"
"Admin::Hotel::ReservationUtils".deconstantize # => "Admin::Hotel"
```

NOTE: Definido em `active_support/core_ext/string/inflections.rb`.

[String#deconstantize]: https://api.rubyonrails.org/classes/String.html#method-i-deconstantize

#### `parameterize`

O método [`parameterize`][String#parameterize] normaliza seu receptor de uma forma que pode ser usada em URLs de forma mais elegante.

```ruby
"John Smith".parameterize # => "john-smith"
"Kurt Gödel".parameterize # => "kurt-godel"
```

Para preservar a caixa da _string_, defina o argumento `preserve_case` para _true_. Por padrão, `preserve_case` será configurado como `false`.

```ruby
"John Smith".parameterize(preserve_case: true) # => "John-Smith"
"Kurt Gödel".parameterize(preserve_case: true) # => "Kurt-Godel"
```

Para usar um separador customizado, sobrescreva o argumento `separator`.

```ruby
"John Smith".parameterize(separator: "_") # => "john_smith"
"Kurt Gödel".parameterize(separator: "_") # => "kurt_godel"
```

NOTE: Definido em `active_support/core_ext/string/inflections.rb`.

[String#parameterize]: https://api.rubyonrails.org/classes/String.html#method-i-parameterize

#### `tableize`

O método [`tableize`][String#tableize] é `underscore` seguido por `pluralize`.

```ruby
"Person".tableize      # => "people"
"Invoice".tableize     # => "invoices"
"InvoiceLine".tableize # => "invoice_lines"
```

Como um princípio básico, `tableize` retorna o nome da tabela que corresponde a um determinado modelo para casos simples. A implementação real de `tableize` no _Active Record_ na verdade não é direta, porque também desmodulariza o nome da classe e verifica algumas opções que podem afetar a _string_ retornada.

NOTE: Definido em `active_support/core_ext/string/inflections.rb`.

[String#tableize]: https://api.rubyonrails.org/classes/String.html#method-i-tableize

#### `classify`

O método [`classify`][String#classify] é o inverso de `tableize`. Ele da o nome da classe correspondente ao nome da tabela:

```ruby
"people".classify        # => "Person"
"invoices".classify      # => "Invoice"
"invoice_lines".classify # => "InvoiceLine"
```

O método compreende nomes de tabela associadas:

```ruby
"highrise_production.companies".classify # => "Company"
```

Note que `classify` retorna um nome de classe como uma _string_. Você pode obter o objeto de classe real invocando `constantize` sobre isso, será explicado a seguir.

NOTE: Definido em `active_support/core_ext/string/inflections.rb`.

[String#classify]: https://api.rubyonrails.org/classes/String.html#method-i-classify

#### `constantize`

O método [`constantize`][String#constantize] resolve a expressão de referência constante em seu receptor:

```ruby
"Integer".constantize # => Integer

module M
  X = 1
end
"M::X".constantize # => 1
```

Se a _string_ não for avaliada como uma constante conhecida ou seu conteúdo nem mesmo for um nome de constante válido, `constantize` executa `NameError`.

Resolução de nome constante por `constantize` inicia sempre no nível superior de `Object` mesmo se não começar com "::".

```ruby
X = :in_Object
module M
  X = :in_M

  X                 # => :in_M
  "::X".constantize # => :in_Object
  "X".constantize   # => :in_Object (!)
end
```

So, it is in general not equivalent to what Ruby would do in the same spot, had a real constant be evaluated.

Mailer test cases obtain the mailer being tested from the name of the test class using `constantize`:

```ruby
# action_mailer/test_case.rb
def determine_default_mailer(name)
  name.delete_suffix("Test").constantize
rescue NameError => e
  raise NonInferrableMailerError.new(name)
end
```

NOTE: Definido em `active_support/core_ext/string/inflections.rb`.

[String#constantize]: https://api.rubyonrails.org/classes/String.html#method-i-constantize

#### `humanize`

O método [`humanize`][String#humanize] ajusta um nome de atributo para exibir aos usuários.

Especificamente, ele realiza estas transformações:

  * Aplica regras de inflexão humana ao argumento.
  * Exclui os _underlines_ iniciais, se houver.
  * Remove um sufixo "_id", se houver.
  * Substitui _underlines_ por espaços, se houver.
  * Reduz todas as palavras, exceto siglas.
  * Coloca em maiúscula a primeira palavra.

A capitalização da primeira palavra pode ser desativada configurando o
`:capitalize` opção para `false` (o padrão é `true`).

```ruby
"name".humanize                         # => "Name"
"author_id".humanize                    # => "Author"
"author_id".humanize(capitalize: false) # => "author"
"comments_count".humanize               # => "Comments count"
"_id".humanize                          # => "Id"
```

Se "SSL" for definido como uma sigla:

```ruby
'ssl_error'.humanize # => "SSL error"
```

O método _helper_ `full_messages` usa `humanize` como alternativa para incluir
nomes de atributos:

```ruby
def full_messages
  map { |attribute, message| full_message(attribute, message) }
end

def full_message
  # ...
  attr_name = attribute.to_s.tr('.', '_').humanize
  attr_name = @base.class.human_attribute_name(attribute, default: attr_name)
  # ...
end
```

NOTE: Definido em `active_support/core_ext/string/inflections.rb`.

[String#humanize]: https://api.rubyonrails.org/classes/String.html#method-i-humanize

#### `foreign_key`

O método [`foreign_key`][String#foreign_key] fornece um nome de coluna de chave estrangeira a partir de um nome de classe. Para fazer isso, ele desmoduliza, separa com _underline_ e adiciona "_id":

```ruby
"User".foreign_key           # => "user_id"
"InvoiceLine".foreign_key    # => "invoice_line_id"
"Admin::Session".foreign_key # => "session_id"
```

Passe `false` como argumento se você não quiser o _underline_ em "_id":

```ruby
"User".foreign_key(false) # => "userid"
```

As associações usam este método para inferir chaves estrangeiras, por exemplo `has_one` e `has_many` fazem isto:

```ruby
# active_record/associations.rb
foreign_key = options[:foreign_key] || reflection.active_record.name.foreign_key
```

NOTE: Definido em `active_support/core_ext/string/inflections.rb`.

[String#foreign_key]: https://api.rubyonrails.org/classes/String.html#method-i-foreign_key

### Conversões

#### `to_date`, `to_time`, `to_datetime`

Os métodos [`to_date`][String#to_date], [`to_time`][String#to_time], e [`to_datetime`][String#to_datetime] são basicamente  variações convenientes de `Date._parse`:

```ruby
"2010-07-27".to_date              # => Tue, 27 Jul 2010
"2010-07-27 23:37:00".to_time     # => 2010-07-27 23:37:00 +0200
"2010-07-27 23:37:00".to_datetime # => Tue, 27 Jul 2010 23:37:00 +0000
```

`to_time` recebe an um argumento opcional `:utc` ou `:local`, para indicar qual fuso horário you quer se basear:

```ruby
"2010-07-27 23:42:00".to_time(:utc)   # => 2010-07-27 23:42:00 UTC
"2010-07-27 23:42:00".to_time(:local) # => 2010-07-27 23:42:00 +0200
```

O padrão é `:local`.

Por favor, consulte a documentação de `Date._parse` para mais detalhes.

INFO: Os três exemplos retornam `nil` caso não recebam argumentos.

NOTE: Definido em `active_support/core_ext/string/conversions.rb`.

[String#to_date]: https://api.rubyonrails.org/classes/String.html#method-i-to_date
[String#to_datetime]: https://api.rubyonrails.org/classes/String.html#method-i-to_datetime
[String#to_time]: https://api.rubyonrails.org/classes/String.html#method-i-to_time

Extensões para `Symbol`
----------------------

### `starts_with?` e `ends_with?`

O Active Support define _aliases_ (nomes simbólicos) de terceira pessoa de `Symbol#start_with?` e `Symbol#end_with?`:

```ruby
:foo.starts_with?("f") # => true
:foo.ends_with?("o")   # => true
```

NOTE: Definido em `active_support/core_ext/symbol/starts_ends_with.rb`.

Extensões para `Numeric`
-----------------------

### Bytes

Todos os números respondem a estes métodos:

* [`bytes`][Numeric#bytes]
* [`kilobytes`][Numeric#kilobytes]
* [`megabytes`][Numeric#megabytes]
* [`gigabytes`][Numeric#gigabytes]
* [`terabytes`][Numeric#terabytes]
* [`petabytes`][Numeric#petabytes]
* [`exabytes`][Numeric#exabytes]

Eles retornam a quantidade correspondente de bytes, usando um fator de conversão de 1024:

```ruby
2.kilobytes   # => 2048
3.megabytes   # => 3145728
3.5.gigabytes # => 3758096384
-4.exabytes   # => -4611686018427387904
```

As formas singulares têm um _alias_ para que você possa dizer:

```ruby
1.megabyte # => 1048576
```

NOTE: Definido em `active_support/core_ext/numeric/bytes.rb`.

[Numeric#bytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-bytes
[Numeric#exabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-exabytes
[Numeric#gigabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-gigabytes
[Numeric#kilobytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-kilobytes
[Numeric#megabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-megabytes
[Numeric#petabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-petabytes
[Numeric#terabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-terabytes

### Time

Os seguintes métodos:

* [`seconds`][Numeric#seconds]
* [`minutes`][Numeric#minutes]
* [`hours`][Numeric#hours]
* [`days`][Numeric#days]
* [`weeks`][Numeric#weeks]
* [`fortnights`][Numeric#fortnights]

habilitar declarações e cálculos de tempo, como `45.minutes + 2.hours + 4.weeks`. Seus valores de retorno também podem ser adicionados ou subtraídos dos objetos Time.

Esses métodos podem ser combinados com [`from_now`][Duration#from_now], [`ago`][Duration#ago], etc, para cálculos de datas precisos. Por exemplo:

```ruby
# equivalent to Time.current.advance(days: 1)
1.day.from_now

# equivalent to Time.current.advance(weeks: 2)
2.weeks.from_now

# equivalent to Time.current.advance(days: 4, weeks: 5)
(4.days + 5.weeks).from_now
```

WARNING. Para outras durações, consulte as extensões de tempo para `Integer`.

NOTE: Definido em `active_support/core_ext/numeric/time.rb`.

[Duration#ago]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-ago
[Duration#from_now]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-from_now
[Numeric#days]: https://api.rubyonrails.org/classes/Numeric.html#method-i-days
[Numeric#fortnights]: https://api.rubyonrails.org/classes/Numeric.html#method-i-fortnights
[Numeric#hours]: https://api.rubyonrails.org/classes/Numeric.html#method-i-hours
[Numeric#minutes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-minutes
[Numeric#seconds]: https://api.rubyonrails.org/classes/Numeric.html#method-i-seconds
[Numeric#weeks]: https://api.rubyonrails.org/classes/Numeric.html#method-i-weeks

### Formatação

Permite a formatação de números de várias maneiras.

Produz uma representação de _string_ de um número como um número de telefone:

```ruby
5551234.to_fs(:phone)
# => 555-1234
1235551234.to_fs(:phone)
# => 123-555-1234
1235551234.to_fs(:phone, area_code: true)
# => (123) 555-1234
1235551234.to_fs(:phone, delimiter: " ")
# => 123 555 1234
1235551234.to_fs(:phone, area_code: true, extension: 555)
# => (123) 555-1234 x 555
1235551234.to_fs(:phone, country_code: 1)
# => +1-123-555-1234
```

Produz uma representação de _string_ de um número como moeda:

```ruby
1234567890.50.to_fs(:currency)                 # => $1,234,567,890.50
1234567890.506.to_fs(:currency)                # => $1,234,567,890.51
1234567890.506.to_fs(:currency, precision: 3)  # => $1,234,567,890.506
```

Produz uma representação de _string_ de um número como uma porcentagem:

```ruby
100.to_fs(:percentage)
# => 100.000%
100.to_fs(:percentage, precision: 0)
# => 100%
1000.to_fs(:percentage, delimiter: '.', separator: ',')
# => 1.000,000%
302.24398923423.to_fs(:percentage, precision: 5)
# => 302.24399%
```

Produz uma representação de _string_ de um número na forma delimitada:

```ruby
12345678.to_fs(:delimited)                     # => 12,345,678
12345678.05.to_fs(:delimited)                  # => 12,345,678.05
12345678.to_fs(:delimited, delimiter: ".")     # => 12.345.678
12345678.to_fs(:delimited, delimiter: ",")     # => 12,345,678
12345678.05.to_fs(:delimited, separator: " ")  # => 12,345,678 05
```

Produz uma representação de _string_ de um número arredondado para uma precisão:

```ruby
111.2345.to_fs(:rounded)                     # => 111.235
111.2345.to_fs(:rounded, precision: 2)       # => 111.23
13.to_fs(:rounded, precision: 5)             # => 13.00000
389.32314.to_fs(:rounded, precision: 0)      # => 389
111.2345.to_fs(:rounded, significant: true)  # => 111
```

Produz uma representação de _string_ de um número como um número de bytes legível para humanos:

```ruby
123.to_fs(:human_size)                  # => 123 Bytes
1234.to_fs(:human_size)                 # => 1.21 KB
12345.to_fs(:human_size)                # => 12.1 KB
1234567.to_fs(:human_size)              # => 1.18 MB
1234567890.to_fs(:human_size)           # => 1.15 GB
1234567890123.to_fs(:human_size)        # => 1.12 TB
1234567890123456.to_fs(:human_size)     # => 1.1 PB
1234567890123456789.to_fs(:human_size)  # => 1.07 EB
```

Produz uma representação de _string_ de um número em palavras legíveis para humanos:

```ruby
123.to_fs(:human)               # => "123"
1234.to_fs(:human)              # => "1.23 Thousand"
12345.to_fs(:human)             # => "12.3 Thousand"
1234567.to_fs(:human)           # => "1.23 Million"
1234567890.to_fs(:human)        # => "1.23 Billion"
1234567890123.to_fs(:human)     # => "1.23 Trillion"
1234567890123456.to_fs(:human)  # => "1.23 Quadrillion"
```

NOTE: Definido em `active_support/core_ext/numeric/conversions.rb`.

Extensões para `Integer`
-----------------------

### `multiple_of?`

O método [`multiple_of?`][Integer#multiple_of?] testa se um inteiro é múltiplo do argumento:

```ruby
2.multiple_of?(1) # => true
1.multiple_of?(2) # => false
```

NOTE: Definido em `active_support/core_ext/integer/multiple.rb`.

[Integer#multiple_of?]: https://api.rubyonrails.org/classes/Integer.html#method-i-multiple_of-3F

### `ordinal`

O método [`ordinal`][Integer#ordinal] retorna a *string* de sufixo ordinal correspondente ao inteiro receptor:

```ruby
1.ordinal    # => "st"
2.ordinal    # => "nd"
53.ordinal   # => "rd"
2009.ordinal # => "th"
-21.ordinal  # => "st"
-134.ordinal # => "th"
```

NOTE: Definido em `active_support/core_ext/integer/inflections.rb`.

[Integer#ordinal]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinal

### `ordinalize`

O método [`ordinalize`][Integer#ordinalize] retorna a *string* ordinal correspondente ao inteiro receptor. Em comparação, observe que o método `ordinal` retorna **apenas** a string de sufixo.

```ruby
1.ordinalize    # => "1st"
2.ordinalize    # => "2nd"
53.ordinalize   # => "53rd"
2009.ordinalize # => "2009th"
-21.ordinalize  # => "-21st"
-134.ordinalize # => "-134th"
```

NOTE: Definido em `active_support/core_ext/integer/inflections.rb`.

[Integer#ordinalize]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinalize

### Time

Os seguintes métodos:

* [`months`][Integer#months]
* [`years`][Integer#years]

habilitar declarações de tempo e cálculos, como `4.months + 5.years`. Seus valores de retorno também podem ser adicionados ou subtraídos dos objetos Time.

Esses métodos podem ser combinados com [`from_now`][Duration#from_now], [`ago`][Duration#ago], etc, para cálculos de data precisos. Por exemplo:

```ruby
# equivalente ao Time.current.advance(months: 1)
1.month.from_now

# eequivalente ao Time.current.advance(years: 2)
2.years.from_now

# equivalente ao Time.current.advance(months: 4, years: 5)
(4.months + 5.years).from_now
```

WARNING. Para outras durações, consulte as extensões de tempo para `Numeric`.

NOTE: Definido em `active_support/core_ext/integer/time.rb`.

[Integer#months]: https://api.rubyonrails.org/classes/Integer.html#method-i-months
[Integer#years]: https://api.rubyonrails.org/classes/Integer.html#method-i-years

Extensões para `BigDecimal`
--------------------------

### `to_s`

O método `to_s` fornece um especificador padrão de "F". Isso significa que uma simples chamada para `to_s` resultará em representação de ponto flutuante em vez de notação de engenharia:

```ruby
BigDecimal(5.00, 6).to_s       # => "5.0"
```

e que especificadores  usando *symbols* também são suportados:

```ruby
BigDecimal(5.00, 6).to_s(:db)  # => "5.0"
```

A notação de engenharia ainda é suportada:

```ruby
BigDecimal(5.00, 6).to_s("e")  # => "0.5E1"
```

Extensões para `Enumerable`
--------------------------

### `sum`

O método [`sum`][Enumerable#sum] adiciona os elementos de um *enumerable*:

```ruby
[1, 2, 3].sum # => 6
(1..100).sum  # => 5050
```

A adição apenas assume que os elementos respondem a `+`:

```ruby
[[1, 2], [2, 3], [3, 4]].sum    # => [1, 2, 2, 3, 3, 4]
%w(foo bar baz).sum             # => "foobarbaz"
{a: 1, b: 2, c: 3}.sum          # => [:a, 1, :b, 2, :c, 3]
```

A soma de uma coleção vazia é zero por padrão, mas isto é customizável:

```ruby
[].sum    # => 0
[].sum(1) # => 1
```

Se um bloco for fornecido, `sum` se torna um iterador que fornece os elementos da coleção e soma os valores retornados:

```ruby
(1..5).sum {|n| n * 2 } # => 30
[2, 4, 6, 8, 10].sum    # => 30
```

A soma de um recipiente vazio pode ser customizado nessa forma também:

```ruby
[].sum(1) {|n| n**3} # => 1
```

NOTE: Definido em `active_support/core_ext/enumerable.rb`.

[Enumerable#sum]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-sum

### `index_by`

O método [`index_by`][Enumerable#index_by] gera um  *hash* com os elementos de um *enumerable* indexados por alguma chave.

Ele itera pela coleção e passa cada elemento para um bloco. O elemento será chaveado pelo valor retornado pelo bloco:

```ruby
invoices.index_by(&:number)
# => {'2009-032' => <Invoice ...>, '2009-008' => <Invoice ...>, ...}
```

WARNING. As chaves normalmente devem ser exclusivas. Se o bloco retornar o mesmo valor para elementos diferentes, nenhuma coleção será construida para essa chave. O último item irá ganhar.

NOTE: Definido em `active_support/core_ext/enumerable.rb`.

[Enumerable#index_by]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_by

### `index_with`

O método [`index_with`][Enumerable#index_with] gera um *hash* com os elementos de um `enumerable` como chaves. O valor será o que foi passado como padrão ou o retornado em um bloco.

```ruby
post = Post.new(title: "hey there", body: "what's up?")

%i( title body ).index_with { |attr_name| post.public_send(attr_name) }
# => { title: "hey there", body: "what's up?" }

WEEKDAYS.index_with(Interval.all_day)
# => { monday: [ 0, 1440 ], … }
```

NOTE: Definido em `active_support/core_ext/enumerable.rb`.

[Enumerable#index_with]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_with

### `many?`

O método [`many?`][Enumerable#many?] é um atalho para `collection.size > 1`:

```erb
<% if pages.many? %>
  <%= pagination_links %>
<% end %>
```

Se for fornecido um bloco opcional, `many?` leva em consideração apenas aqueles elementos que retornam *true*:

```ruby
@see_more = videos.many? {|video| video.category == params[:category]}
```

NOTE: Definido em `active_support/core_ext/enumerable.rb`.

[Enumerable#many?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-many-3F

### `exclude?`

O predicado [`exclude?`][Enumerable#exclude?] testa se um dado objeto **não** pertence à coleção. É a negação do método embutido `include?`:

```ruby
to_visit << node if visited.exclude?(node)
```

NOTE: Definido em `active_support/core_ext/enumerable.rb`.

[Enumerable#exclude?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-exclude-3F

### `including`

O método [`including`][Enumerable#including] retorna um novo `enumerable` que inclui os elementos passados:

```ruby
[ 1, 2, 3 ].including(4, 5)                    # => [ 1, 2, 3, 4, 5 ]
["David", "Rafael"].including %w[ Aaron Todd ] # => ["David", "Rafael", "Aaron", "Todd"]
```

NOTE: Definido em `active_support/core_ext/enumerable.rb`.

[Enumerable#including]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-including

### `excluding`

O método [`excluding`][Enumerable#excluding] retorna uma cópia de um `enumerable` com os elementos especificados removidos:

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
```

`excluding` é um *alias* para [`without`][Enumerable#without].

NOTE: Definido em `active_support/core_ext/enumerable.rb`.

[Enumerable#excluding]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-excluding
[Enumerable#without]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-without

### `pluck`

O método [`pluck`][Enumerable#pluck] extrai a chave fornecida de cada elemento:

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pluck(:name) # => ["David", "Rafael", "Aaron"]
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pluck(:id, :name) # => [[1, "David"], [2, "Rafael"]]
```

NOTE: Definido em `active_support/core_ext/enumerable.rb`.

[Enumerable#pluck]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pluck

### `pick`

O método [`pick`][Enumerable#pick] extrai a chave fornecida do primeiro elemento:

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pick(:name) # => "David"
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pick(:id, :name) # => [1, "David"]
```

NOTE: Definido em `active_support/core_ext/enumerable.rb`.

[Enumerable#pick]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pick

Extensões para `Array`
---------------------

### Acessando

O *Active Support* aumenta a API de *arrays* para facilitar certas maneiras de acessá-los. Por exemplo, [`to`][Array#to] retorna o *subarray* de elementos até aquele no índice passado:

```ruby
%w(a b c d).to(2) # => ["a", "b", "c"]
[].to(7)          # => []
```

Da mesma forma, [`from`][Array#from] retorna os elementos a partir do elemento no índice passado até o final. Se o índice for maior que o comprimento do *array*, será retornado um *array* vazio.

```ruby
%w(a b c d).from(2)  # => ["c", "d"]
%w(a b c d).from(10) # => []
[].from(0)           # => []
```

O método [`including`][Array#including] retorna um novo *array* que inclui os elementos passados:

```ruby
[ 1, 2, 3 ].including(4, 5)          # => [ 1, 2, 3, 4, 5 ]
[ [ 0, 1 ] ].including([ [ 1, 0 ] ]) # => [ [ 0, 1 ], [ 1, 0 ] ]
```

O método [`excluding`][Array#excluding] retorna uma cópia do *array* excluindo os elementos especificados.
Esta é uma otimização de `Enumerable#excluding` que usa `Array#-`
ao invés de `Array#reject` por questão de desempenho.

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
[ [ 0, 1 ], [ 1, 0 ] ].excluding([ [ 1, 0 ] ])                  # => [ [ 0, 1 ] ]
```

Os métodos [`second`][Array#second], [`third`][Array#third], [`fourth`][Array#fourth], e [`fifth`][Array#fifth] retornam o elemento correspondente, assim como [`second_to_last`][Array#second_to_last] e [`third_to_last`][Array#third_to_last] (`first` e `last` são embutidos). Graças à sabedoria social e construtividade positiva ao redor, [`forty_two`][Array#forty_two] também está disponível.

```ruby
%w(a b c d).third # => "c"
%w(a b c d).fifth # => nil
```

NOTE: Definido em `active_support/core_ext/array/access.rb`.

[Array#excluding]: https://api.rubyonrails.org/classes/Array.html#method-i-excluding
[Array#fifth]: https://api.rubyonrails.org/classes/Array.html#method-i-fifth
[Array#forty_two]: https://api.rubyonrails.org/classes/Array.html#method-i-forty_two
[Array#fourth]: https://api.rubyonrails.org/classes/Array.html#method-i-fourth
[Array#from]: https://api.rubyonrails.org/classes/Array.html#method-i-from
[Array#including]: https://api.rubyonrails.org/classes/Array.html#method-i-including
[Array#second]: https://api.rubyonrails.org/classes/Array.html#method-i-second
[Array#second_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-second_to_last
[Array#third]: https://api.rubyonrails.org/classes/Array.html#method-i-third
[Array#third_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-third_to_last
[Array#to]: https://api.rubyonrails.org/classes/Array.html#method-i-to

### Extraindo

O método [`extract!`][Array#extract!] remove e retorna os elementos para os quais o bloco retorna um valor *true*.
Se nenhum bloco for fornecido, um *Enumerator* será retornado.

```ruby
numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
odd_numbers = numbers.extract! { |number| number.odd? } # => [1, 3, 5, 7, 9]
numbers # => [0, 2, 4, 6, 8]
```

NOTE: Definido em `active_support/core_ext/array/extract.rb`.

[Array#extract!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract-21

### Extração de opções

Quando o último argumento em uma chamada de método é um *hash*, exceto talvez por um argumento do tipo `&block`, o Ruby permite que você omita os colchetes:

```ruby
User.exists?(email: params[:email])
```

Esse *syntactic sugar* é muito usado no Rails para evitar argumentos posicionais onde haveria muitos, oferecendo interfaces que emulam os parâmetros nomeados. Em particular, é muito idiomático usar um *hash* no final para opções.

Se um método espera um número variável de argumentos e usa `*` em sua declaração, entretanto, tal *hash* de opções acaba sendo um item do *array* de argumentos, onde perde seu papel.

Nesses casos, você pode dar um tratamento diferenciado ao *hash* de opções com [`extract_options!`][Array#extract_options!]. Este método verifica o tipo do último item de um *array*. Se for um *hash*, ele o exibe e o retorna, caso contrário, retorna um *hash* vazio.

Vejamos, por exemplo, a definição da macro do controlador `caches_action`:

```ruby
def caches_action(*actions)
  return unless cache_configured?
  options = actions.extract_options!
  # ...
end
```

Este método recebe um número arbitrário de nomes de ações e um *hash* opcional de opções como último argumento. Com a chamada a `extract_options!` você obtém o *hash* de opções e o remove de `actions` de forma simples e explícita.

NOTE: Definido em `active_support/core_ext/array/extract_options.rb`.

[Array#extract_options!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract_options-21

### Conversões

#### `to_sentence`

O método [`to_sentence`][Array#to_sentence] transforma um *array* em uma *string* contendo uma frase que enumera seus itens:

```ruby
%w().to_sentence                # => ""
%w(Earth).to_sentence           # => "Earth"
%w(Earth Wind).to_sentence      # => "Earth and Wind"
%w(Earth Wind Fire).to_sentence # => "Earth, Wind, and Fire"
```

Este método aceita três opções:

* `:two_words_connector`: O que é usado para *arrays* de comprimento 2. O padrão é " e ".
* `:words_connector`: O que é usado para unir os elementos de *arrays* com 3 ou mais elementos, exceto os dois últimos. O padrão é ", ".
* `:last_word_connector`: O que é usado para unir os últimos itens de um *array* com 3 ou mais elementos. O padrão é ", e ".

Os padrões para essas opções podem ser localizados, suas chaves são:

| Opção                  | Chave I18n                          |
| ---------------------- | ----------------------------------- |
| `:two_words_connector` | `support.array.two_words_connector` |
| `:words_connector`     | `support.array.words_connector`     |
| `:last_word_connector` | `support.array.last_word_connector` |

NOTE: Definido em `active_support/core_ext/array/conversions.rb`.

[Array#to_sentence]: https://api.rubyonrails.org/classes/Array.html#method-i-to_sentence

#### `to_fs`

O método [`to_fs`][Array#to_formatted_s] age como `to_s` por padrão.

No entanto, se o *array* contém itens que respondem a `id`, o símbolo 
`:db` pode ser passado como argumento. Isso é normalmente usado em coleções de objetos do *Active Record*. As *strings* retornadas são:

```ruby
[].to_fs(:db)            # => "null"
[user].to_fs(:db)        # => "8456"
invoice.lines.to_fs(:db) # => "23,567,556,12"
```

Os inteiros no exemplo acima devem vir das respectivas chamadas para `id`.

NOTE: Definido em `active_support/core_ext/array/conversions.rb`.

[Array#to_fs]: https://api.rubyonrails.org/classes/Array.html#method-i-to_fs

#### `to_xml`

O método [`to_xml`][Array#to_xml] retorna uma string contendo uma representação em XML do seu recipiente:

```ruby
Contributor.limit(2).order(:rank).to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors type="array">
#   <contributor>
#     <id type="integer">4356</id>
#     <name>Jeremy Kemper</name>
#     <rank type="integer">1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id type="integer">4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank type="integer">2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

Para fazer isso, ele envia `to_xml` para cada item e coleta os resultados em um nó raiz. Todos os itens devem responder a `to_xml`, caso contrário, uma exceção é provocada.

Por padrão, o nome do elemento raiz é o plural sublinhado e tracejado do nome da classe do primeiro item, desde que os demais elementos pertençam a esse tipo (verificado com `is_a?`) e não sejam *hashes*. No exemplo acima são "*contributors*".

Se houver algum elemento que não pertença ao tipo do primeiro, o nó raiz se torna "*objects*":

```ruby
[Contributor.first, Commit.first].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <id type="integer">4583</id>
#     <name>Aaron Batalion</name>
#     <rank type="integer">53</rank>
#     <url-id>aaron-batalion</url-id>
#   </object>
#   <object>
#     <author>Joshua Peek</author>
#     <authored-timestamp type="datetime">2009-09-02T16:44:36Z</authored-timestamp>
#     <branch>origin/master</branch>
#     <committed-timestamp type="datetime">2009-09-02T16:44:36Z</committed-timestamp>
#     <committer>Joshua Peek</committer>
#     <git-show nil="true"></git-show>
#     <id type="integer">190316</id>
#     <imported-from-svn type="boolean">false</imported-from-svn>
#     <message>Kill AMo observing wrap_with_notifications since ARes was only using it</message>
#     <sha1>723a47bfb3708f968821bc969a9a3fc873a3ed58</sha1>
#   </object>
# </objects>
```

Se o recipiente é um *array* de *hashes*, o elemento raiz também é, por padrão, "*objects*":

```ruby
[{a: 1, b: 2}, {c: 3}].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <b type="integer">2</b>
#     <a type="integer">1</a>
#   </object>
#   <object>
#     <c type="integer">3</c>
#   </object>
# </objects>
```

WARNING. Se a coleção estiver vazia, o elemento raiz é, por padrão, "*nil-classes*". If the collection is empty the root element is by default "nil-classes". Isso é uma pegadinha, por exemplo, o elemento raiz da lista de *contributors* acima não seria "*contributors*" se a coleção estivesse vazia, e sim "*nil-classes*". Você pode usar a opção `:root` para garantir um elemento raiz consistente.

O nome dos nós filhos é, por padrão, o nome do nó raiz singularizado. Nos exemplos acima vimos "*contributor*" e "*object*". A opção `:children` permite que você defina esses nomes de nós.

O construtor XML padrão é uma nova instância de `Builder::XmlMarkup`. Você pode configurar seu próprio construtor através da opção `:builder`. O método também aceita opções como `:dasherize` e afins, elas são encaminhadas para o construtor:

```ruby
Contributor.limit(2).order(:rank).to_xml(skip_types: true)
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors>
#   <contributor>
#     <id>4356</id>
#     <name>Jeremy Kemper</name>
#     <rank>1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id>4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank>2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

NOTE: Definido em `active_support/core_ext/array/conversions.rb`.

[Array#to_xml]: https://api.rubyonrails.org/classes/Array.html#method-i-to_xml

### Invólucro

O método [`Array.wrap`][Array.wrap] envolve seu argumento em um *array*, a menos que já seja um *array* (ou semelhante a um *array*).

Especificamente:

* Se o argumento for `nil` um *array* vazio é retornado.
* Caso contrário, se o argumento responde a `to_ary` ele será invocado, e se o valor de `to_ary` não for `nil`, ele será retornado.
* Caso contrário, um *array* com o argumento como seu único elemento é retornado.

```ruby
Array.wrap(nil)       # => []
Array.wrap([1, 2, 3]) # => [1, 2, 3]
Array.wrap(0)         # => [0]
```

Este método é semelhante em propósito ao `Kernel#Array`, mas há algumas diferenças:

* Se o argumento responde a `to_ary` o método é invocado. `Kernel#Array` segue em frente para tentar chamar `to_a` se o valor retornado for `nil`, mas `Array.wrap` retorna um *array* com o argumento como seu único elemento imediatamente.
* Se o valor retornado de `to_ary` não for `nil` nem um objeto `Array`, `Kernel#Array` gera uma exceção, enquanto `Array.wrap` não, apenas retorna o valor.
* Ele não chama `to_a` no argumento, se o argumento não responde a `to_ary` ele retorna um *array* com o argumento como seu único elemento.

O último ponto é particularmente digno de comparação para alguns *enumerables*:

```ruby
Array.wrap(foo: :bar) # => [{:foo=>:bar}]
Array(foo: :bar)      # => [[:foo, :bar]]
```

Há também um idioma relacionado que usa o operador *splat*:

```ruby
[*object]
```

NOTE: Definido em `active_support/core_ext/array/wrap.rb`.

[Array.wrap]: https://api.rubyonrails.org/classes/Array.html#method-c-wrap

### Duplicando

O método [`Array#deep_dup`][Array#deep_dup] duplica a si mesmo e todos os objetos dentro
recursivamente com o método do Active Support `Object#deep_dup`. Funciona como um `Array#map`, enviando o método `deep_dup` para cada objeto dentro.

```ruby
array = [1, [2, 3]]
dup = array.deep_dup
dup[1][2] = 4
array[1][2] == nil   # => true
```

NOTE: Definido em `active_support/core_ext/object/deep_dup.rb`.

[Array#deep_dup]: https://api.rubyonrails.org/classes/Array.html#method-i-deep_dup

### Agrupamento

#### `in_groups_of(number, fill_with = nil)`

O método [`in_groups_of`][Array#in_groups_of] divide um *array* em grupos consecutivos de um determinado tamanho. Ele retorna um *array* com os grupos:

```ruby
[1, 2, 3].in_groups_of(2) # => [[1, 2], [3, nil]]
```

ou os fornece por sua vez se um bloco for passado:

```html+erb
<% sample.in_groups_of(3) do |a, b, c| %>
  <tr>
    <td><%= a %></td>
    <td><%= b %></td>
    <td><%= c %></td>
  </tr>
<% end %>
```

O primeiro elemento mostra como `in_groups_of` preenche o último grupo com quantos elementos `nil` forem necessários para ter o tamanho solicitado. Você pode alterar esse valor de preenchimento usando o segundo argumento opcional:

```ruby
[1, 2, 3].in_groups_of(2, 0) # => [[1, 2], [3, 0]]
```

E você pode dizer ao método para não preencher o último grupo passando `false`:

```ruby
[1, 2, 3].in_groups_of(2, false) # => [[1, 2], [3]]
```

Como consequência, `false` não pode ser usado como valor de preenchimento.

NOTE: Definido em `active_support/core_ext/array/grouping.rb`.

[Array#in_groups_of]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups_of

#### `in_groups(number, fill_with = nil)`

O método [`in_groups`][Array#in_groups] divide um *array* em um certo número de grupos. O método retorna um *array* com os grupos:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3)
# => [["1", "2", "3"], ["4", "5", nil], ["6", "7", nil]]
```

ou os fornece por sua vez se um bloco for passado:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3) {|group| p group}
["1", "2", "3"]
["4", "5", nil]
["6", "7", nil]
```

Os exemplos acima mostram que `in_groups` preenche alguns grupos com um elemento `nil` à direita conforme necessário. Um grupo pode obter no máximo um desses elementos extras, o mais à direita, se houver. E os grupos que os possuem são sempre os últimos.

Você pode alterar esse valor de preenchimento usando o segundo argumento opcional:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, "0")
# => [["1", "2", "3"], ["4", "5", "0"], ["6", "7", "0"]]
```

E você pode dizer ao método para não preencher os grupos menores passando `false`:

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, false)
# => [["1", "2", "3"], ["4", "5"], ["6", "7"]]
```

Como consequência, `false` não pode ser usado como valor de preenchimento.

NOTE: Definido em `active_support/core_ext/array/grouping.rb`.

[Array#in_groups]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups

#### `split(value = nil)`

O método [`split`][Array#split] divide um *array* por um separador e retorna os pedaços resultantes.

Se um bloco é passado, os separadores são os elementos do *array* para os quais o bloco retorna *true*:

```ruby
(-5..5).to_a.split { |i| i.multiple_of?(4) }
# => [[-5], [-3, -2, -1], [1, 2, 3], [5]]
```

Caso contrário, o valor recebido como argumento, cujo padrão é `nil`, é o separador:

```ruby
[0, 1, -5, 1, 1, "foo", "bar"].split(1)
# => [[0], [-5], [], ["foo", "bar"]]
```

TIP: Observe no exemplo anterior que separadores consecutivos resultam em *arrays* vazios.

NOTE: Definido em `active_support/core_ext/array/grouping.rb`.

[Array#split]: https://api.rubyonrails.org/classes/Array.html#method-i-split

Extensions to `Hash`
--------------------

### Conversions

#### `to_xml`

The method [`to_xml`][Hash#to_xml] returns a string containing an XML representation of its receiver:

```ruby
{"foo" => 1, "bar" => 2}.to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <hash>
#   <foo type="integer">1</foo>
#   <bar type="integer">2</bar>
# </hash>
```

To do so, the method loops over the pairs and builds nodes that depend on the _values_. Given a pair `key`, `value`:

* If `value` is a hash there's a recursive call with `key` as `:root`.

* If `value` is an array there's a recursive call with `key` as `:root`, and `key` singularized as `:children`.

* If `value` is a callable object it must expect one or two arguments. Depending on the arity, the callable is invoked with the `options` hash as first argument with `key` as `:root`, and `key` singularized as second argument. Its return value becomes a new node.

* If `value` responds to `to_xml` the method is invoked with `key` as `:root`.

* Otherwise, a node with `key` as tag is created with a string representation of `value` as text node. If `value` is `nil` an attribute "nil" set to "true" is added. Unless the option `:skip_types` exists and is true, an attribute "type" is added as well according to the following mapping:

```ruby
XML_TYPE_NAMES = {
  "Symbol"     => "symbol",
  "Integer"    => "integer",
  "BigDecimal" => "decimal",
  "Float"      => "float",
  "TrueClass"  => "boolean",
  "FalseClass" => "boolean",
  "Date"       => "date",
  "DateTime"   => "datetime",
  "Time"       => "datetime"
}
```

By default the root node is "hash", but that's configurable via the `:root` option.

The default XML builder is a fresh instance of `Builder::XmlMarkup`. You can configure your own builder with the `:builder` option. The method also accepts options like `:dasherize` and friends, they are forwarded to the builder.

NOTE: Defined in `active_support/core_ext/hash/conversions.rb`.

[Hash#to_xml]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_xml

### Merging

Ruby has a built-in method `Hash#merge` that merges two hashes:

```ruby
{a: 1, b: 1}.merge(a: 0, c: 2)
# => {:a=>0, :b=>1, :c=>2}
```

Active Support defines a few more ways of merging hashes that may be convenient.

#### `reverse_merge` and `reverse_merge!`

In case of collision the key in the hash of the argument wins in `merge`. You can support option hashes with default values in a compact way with this idiom:

```ruby
options = {length: 30, omission: "..."}.merge(options)
```

Active Support defines [`reverse_merge`][Hash#reverse_merge] in case you prefer this alternative notation:

```ruby
options = options.reverse_merge(length: 30, omission: "...")
```

And a bang version [`reverse_merge!`][Hash#reverse_merge!] that performs the merge in place:

```ruby
options.reverse_merge!(length: 30, omission: "...")
```

WARNING. Take into account that `reverse_merge!` may change the hash in the caller, which may or may not be a good idea.

NOTE: Defined in `active_support/core_ext/hash/reverse_merge.rb`.

[Hash#reverse_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge-21
[Hash#reverse_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge

#### `reverse_update`

The method [`reverse_update`][Hash#reverse_update] is an alias for `reverse_merge!`, explained above.

WARNING. Note that `reverse_update` has no bang.

NOTE: Defined in `active_support/core_ext/hash/reverse_merge.rb`.

[Hash#reverse_update]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_update

#### `deep_merge` and `deep_merge!`

As you can see in the previous example if a key is found in both hashes the value in the one in the argument wins.

Active Support defines [`Hash#deep_merge`][Hash#deep_merge]. In a deep merge, if a key is found in both hashes and their values are hashes in turn, then their _merge_ becomes the value in the resulting hash:

```ruby
{a: {b: 1}}.deep_merge(a: {c: 2})
# => {:a=>{:b=>1, :c=>2}}
```

The method [`deep_merge!`][Hash#deep_merge!] performs a deep merge in place.

NOTE: Defined in `active_support/core_ext/hash/deep_merge.rb`.

[Hash#deep_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge-21
[Hash#deep_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge

### Deep Duplicating

The method [`Hash#deep_dup`][Hash#deep_dup] duplicates itself and all keys and values
inside recursively with Active Support method `Object#deep_dup`. It works like `Enumerator#each_with_object` with sending `deep_dup` method to each pair inside.

```ruby
hash = { a: 1, b: { c: 2, d: [3, 4] } }

dup = hash.deep_dup
dup[:b][:e] = 5
dup[:b][:d] << 5

hash[:b][:e] == nil      # => true
hash[:b][:d] == [3, 4]   # => true
```

NOTE: Defined in `active_support/core_ext/object/deep_dup.rb`.

[Hash#deep_dup]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_dup

### Working with Keys

#### `except` and `except!`

The method [`except`][Hash#except] returns a hash with the keys in the argument list removed, if present:

```ruby
{a: 1, b: 2}.except(:a) # => {:b=>2}
```

If the receiver responds to `convert_key`, the method is called on each of the arguments. This allows `except` to play nice with hashes with indifferent access for instance:

```ruby
{a: 1}.with_indifferent_access.except(:a)  # => {}
{a: 1}.with_indifferent_access.except("a") # => {}
```

There's also the bang variant [`except!`][Hash#except!] that removes keys in place.

NOTE: Defined in `active_support/core_ext/hash/except.rb`.

[Hash#except!]: https://api.rubyonrails.org/classes/Hash.html#method-i-except-21
[Hash#except]: https://api.rubyonrails.org/classes/Hash.html#method-i-except

#### `stringify_keys` and `stringify_keys!`

The method [`stringify_keys`][Hash#stringify_keys] returns a hash that has a stringified version of the keys in the receiver. It does so by sending `to_s` to them:

```ruby
{nil => nil, 1 => 1, a: :a}.stringify_keys
# => {"" => nil, "1" => 1, "a" => :a}
```

In case of key collision, the value will be the one most recently inserted into the hash:

```ruby
{"a" => 1, a: 2}.stringify_keys
# The result will be
# => {"a"=>2}
```

This method may be useful for example to easily accept both symbols and strings as options. For instance `ActionView::Helpers::FormHelper` defines:

```ruby
def to_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
  options = options.stringify_keys
  options["type"] = "checkbox"
  # ...
end
```

The second line can safely access the "type" key, and let the user to pass either `:type` or "type".

There's also the bang variant [`stringify_keys!`][Hash#stringify_keys!] that stringifies keys in place.

Besides that, one can use [`deep_stringify_keys`][Hash#deep_stringify_keys] and [`deep_stringify_keys!`][Hash#deep_stringify_keys!] to stringify all the keys in the given hash and all the hashes nested in it. An example of the result is:

```ruby
{nil => nil, 1 => 1, nested: {a: 3, 5 => 5}}.deep_stringify_keys
# => {""=>nil, "1"=>1, "nested"=>{"a"=>3, "5"=>5}}
```

NOTE: Defined in `active_support/core_ext/hash/keys.rb`.

[Hash#deep_stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys-21
[Hash#deep_stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys
[Hash#stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys-21
[Hash#stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys

#### `symbolize_keys` and `symbolize_keys!`

The method [`symbolize_keys`][Hash#symbolize_keys] returns a hash that has a symbolized version of the keys in the receiver, where possible. It does so by sending `to_sym` to them:

```ruby
{nil => nil, 1 => 1, "a" => "a"}.symbolize_keys
# => {nil=>nil, 1=>1, :a=>"a"}
```

WARNING. Note in the previous example only one key was symbolized.

In case of key collision, the value will be the one most recently inserted into the hash:

```ruby
{"a" => 1, a: 2}.symbolize_keys
# => {:a=>2}
```

This method may be useful for example to easily accept both symbols and strings as options. For instance `ActionText::TagHelper` defines

```ruby
def rich_text_area_tag(name, value = nil, options = {})
  options = options.symbolize_keys

  options[:input] ||= "trix_input_#{ActionText::TagHelper.id += 1}"
  # ...
end
```

The third line can safely access the `:input` key, and let the user to pass either `:input` or "input".

There's also the bang variant [`symbolize_keys!`][Hash#symbolize_keys!] that symbolizes keys in place.

Besides that, one can use [`deep_symbolize_keys`][Hash#deep_symbolize_keys] and [`deep_symbolize_keys!`][Hash#deep_symbolize_keys!] to symbolize all the keys in the given hash and all the hashes nested in it. An example of the result is:

```ruby
{nil => nil, 1 => 1, "nested" => {"a" => 3, 5 => 5}}.deep_symbolize_keys
# => {nil=>nil, 1=>1, nested:{a:3, 5=>5}}
```

NOTE: Defined in `active_support/core_ext/hash/keys.rb`.

[Hash#deep_symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys-21
[Hash#deep_symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys
[Hash#symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys-21
[Hash#symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys

#### `to_options` and `to_options!`

The methods [`to_options`][Hash#to_options] and [`to_options!`][Hash#to_options!] are aliases of `symbolize_keys` and `symbolize_keys!`, respectively.

NOTE: Defined in `active_support/core_ext/hash/keys.rb`.

[Hash#to_options!]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options-21
[Hash#to_options]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options

#### `assert_valid_keys`

The method [`assert_valid_keys`][Hash#assert_valid_keys] receives an arbitrary number of arguments, and checks whether the receiver has any key outside that list. If it does `ArgumentError` is raised.

```ruby
{a: 1}.assert_valid_keys(:a)  # passes
{a: 1}.assert_valid_keys("a") # ArgumentError
```

Active Record does not accept unknown options when building associations, for example. It implements that control via `assert_valid_keys`.

NOTE: Defined in `active_support/core_ext/hash/keys.rb`.

[Hash#assert_valid_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-assert_valid_keys

### Working with Values

#### `deep_transform_values` and `deep_transform_values!`

The method [`deep_transform_values`][Hash#deep_transform_values] returns a new hash with all values converted by the block operation. This includes the values from the root hash and from all nested hashes and arrays.

```ruby
hash = { person: { name: 'Rob', age: '28' } }

hash.deep_transform_values{ |value| value.to_s.upcase }
# => {person: {name: "ROB", age: "28"}}
```

There's also the bang variant [`deep_transform_values!`][Hash#deep_transform_values!] that destructively converts all values by using the block operation.

NOTE: Defined in `active_support/core_ext/hash/deep_transform_values.rb`.

[Hash#deep_transform_values!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values-21
[Hash#deep_transform_values]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values

### Slicing

The method [`slice!`][Hash#slice!] replaces the hash with only the given keys and returns a hash containing the removed key/value pairs.

```ruby
hash = {a: 1, b: 2}
rest = hash.slice!(:a) # => {:b=>2}
hash                   # => {:a=>1}
```

NOTE: Defined in `active_support/core_ext/hash/slice.rb`.

[Hash#slice!]: https://api.rubyonrails.org/classes/Hash.html#method-i-slice-21

### Extracting

The method [`extract!`][Hash#extract!] removes and returns the key/value pairs matching the given keys.

```ruby
hash = {a: 1, b: 2}
rest = hash.extract!(:a) # => {:a=>1}
hash                     # => {:b=>2}
```

The method `extract!` returns the same subclass of Hash that the receiver is.

```ruby
hash = {a: 1, b: 2}.with_indifferent_access
rest = hash.extract!(:a).class
# => ActiveSupport::HashWithIndifferentAccess
```

NOTE: Defined in `active_support/core_ext/hash/slice.rb`.

[Hash#extract!]: https://api.rubyonrails.org/classes/Hash.html#method-i-extract-21

### Indifferent Access

The method [`with_indifferent_access`][Hash#with_indifferent_access] returns an [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess] out of its receiver:

```ruby
{a: 1}.with_indifferent_access["a"] # => 1
```

NOTE: Defined in `active_support/core_ext/hash/indifferent_access.rb`.

[ActiveSupport::HashWithIndifferentAccess]: https://api.rubyonrails.org/classes/ActiveSupport/HashWithIndifferentAccess.html
[Hash#with_indifferent_access]: https://api.rubyonrails.org/classes/Hash.html#method-i-with_indifferent_access

Extensões para `Regexp`
----------------------

### `multiline?`

O método [`multiline?`][Regexp#multiline?] diz se uma *regexp* tem o sinalizador `/m` definido, ou seja, se o ponto corresponde a novas linhas.

```ruby
%r{.}.multiline?  # => false
%r{.}m.multiline? # => true

Regexp.new('.').multiline?                    # => false
Regexp.new('.', Regexp::MULTILINE).multiline? # => true
```

O Rails usa esse método em um único lugar, também no código de roteamento. *Regexps* de várias linhas não são permitidas para requisitos de rota e esse sinalizador facilita a aplicação dessa restrição.

```ruby
def verify_regexp_requirements(requirements)
  # ...
  if requirement.multiline?
    raise ArgumentError, "Regexp multiline option is not allowed in routing requirements: #{requirement.inspect}"
  end
  # ...
end
```

NOTE: Definido em `active_support/core_ext/regexp.rb`.

[Regexp#multiline?]: https://api.rubyonrails.org/classes/Regexp.html#method-i-multiline-3F

Extensions to `Range`
---------------------

### `to_s`

Active Support extends the method `Range#to_s` so that it understands an optional format argument. As of this writing the only supported non-default format is `:db`:

```ruby
(Date.today..Date.tomorrow).to_s
# => "2009-10-25..2009-10-26"

(Date.today..Date.tomorrow).to_s(:db)
# => "BETWEEN '2009-10-25' AND '2009-10-26'"
```

As the example depicts, the `:db` format generates a `BETWEEN` SQL clause. That is used by Active Record in its support for range values in conditions.

NOTE: Defined in `active_support/core_ext/range/conversions.rb`.

### `===` and `include?`

The methods `Range#===` and `Range#include?` say whether some value falls between the ends of a given instance:

```ruby
(2..3).include?(Math::E) # => true
```

Active Support extends these methods so that the argument may be another range in turn. In that case we test whether the ends of the argument range belong to the receiver themselves:

```ruby
(1..10) === (3..7)  # => true
(1..10) === (0..7)  # => false
(1..10) === (3..11) # => false
(1...9) === (3..9)  # => false

(1..10).include?(3..7)  # => true
(1..10).include?(0..7)  # => false
(1..10).include?(3..11) # => false
(1...9).include?(3..9)  # => false
```

NOTE: Defined in `active_support/core_ext/range/compare_range.rb`.

### `overlaps?`

The method [`Range#overlaps?`][Range#overlaps?] says whether any two given ranges have non-void intersection:

```ruby
(1..10).overlaps?(7..11)  # => true
(1..10).overlaps?(0..7)   # => true
(1..10).overlaps?(11..27) # => false
```

NOTE: Defined in `active_support/core_ext/range/overlaps.rb`.

[Range#overlaps?]: https://api.rubyonrails.org/classes/Range.html#method-i-overlaps-3F

Extensions to `Date`
--------------------

### Calculations

INFO: The following calculation methods have edge cases in October 1582, since days 5..14 just do not exist. This guide does not document their behavior around those days for brevity, but it is enough to say that they do what you would expect. That is, `Date.new(1582, 10, 4).tomorrow` returns `Date.new(1582, 10, 15)` and so on. Please check `test/core_ext/date_ext_test.rb` in the Active Support test suite for expected behavior.

#### `Date.current`

Active Support defines [`Date.current`][Date.current] to be today in the current time zone. That's like `Date.today`, except that it honors the user time zone, if defined. It also defines [`Date.yesterday`][Date.yesterday] and [`Date.tomorrow`][Date.tomorrow], and the instance predicates [`past?`][DateAndTime::Calculations#past?], [`today?`][DateAndTime::Calculations#today?], [`tomorrow?`][DateAndTime::Calculations#tomorrow?], [`next_day?`][DateAndTime::Calculations#next_day?], [`yesterday?`][DateAndTime::Calculations#yesterday?], [`prev_day?`][DateAndTime::Calculations#prev_day?], [`future?`][DateAndTime::Calculations#future?], [`on_weekday?`][DateAndTime::Calculations#on_weekday?] and [`on_weekend?`][DateAndTime::Calculations#on_weekend?], all of them relative to `Date.current`.

When making Date comparisons using methods which honor the user time zone, make sure to use `Date.current` and not `Date.today`. There are cases where the user time zone might be in the future compared to the system time zone, which `Date.today` uses by default. This means `Date.today` may equal `Date.yesterday`.

NOTE: Defined in `active_support/core_ext/date/calculations.rb`.

[Date.current]: https://api.rubyonrails.org/classes/Date.html#method-c-current
[Date.tomorrow]: https://api.rubyonrails.org/classes/Date.html#method-c-tomorrow
[Date.yesterday]: https://api.rubyonrails.org/classes/Date.html#method-c-yesterday
[DateAndTime::Calculations#future?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-future-3F
[DateAndTime::Calculations#on_weekday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekday-3F
[DateAndTime::Calculations#on_weekend?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekend-3F
[DateAndTime::Calculations#past?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-past-3F

#### Named Dates

##### `beginning_of_week`, `end_of_week`

The methods [`beginning_of_week`][DateAndTime::Calculations#beginning_of_week] and [`end_of_week`][DateAndTime::Calculations#end_of_week] return the dates for the
beginning and end of the week, respectively. Weeks are assumed to start on
Monday, but that can be changed passing an argument, setting thread local
`Date.beginning_of_week` or [`config.beginning_of_week`][].

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.beginning_of_week          # => Mon, 03 May 2010
d.beginning_of_week(:sunday) # => Sun, 02 May 2010
d.end_of_week                # => Sun, 09 May 2010
d.end_of_week(:sunday)       # => Sat, 08 May 2010
```

`beginning_of_week` is aliased to [`at_beginning_of_week`][DateAndTime::Calculations#at_beginning_of_week] and `end_of_week` is aliased to [`at_end_of_week`][DateAndTime::Calculations#at_end_of_week].

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.

[`config.beginning_of_week`]: configuring.html#config-beginning-of-week
[DateAndTime::Calculations#at_beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_week
[DateAndTime::Calculations#at_end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_week
[DateAndTime::Calculations#beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_week
[DateAndTime::Calculations#end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_week

##### `monday`, `sunday`

The methods [`monday`][DateAndTime::Calculations#monday] and [`sunday`][DateAndTime::Calculations#sunday] return the dates for the previous Monday and
next Sunday, respectively.

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.monday                     # => Mon, 03 May 2010
d.sunday                     # => Sun, 09 May 2010

d = Date.new(2012, 9, 10)    # => Mon, 10 Sep 2012
d.monday                     # => Mon, 10 Sep 2012

d = Date.new(2012, 9, 16)    # => Sun, 16 Sep 2012
d.sunday                     # => Sun, 16 Sep 2012
```

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.

[DateAndTime::Calculations#monday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-monday
[DateAndTime::Calculations#sunday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-sunday

##### `prev_week`, `next_week`

The method [`next_week`][DateAndTime::Calculations#next_week] receives a symbol with a day name in English (default is the thread local [`Date.beginning_of_week`][Date.beginning_of_week], or [`config.beginning_of_week`][], or `:monday`) and it returns the date corresponding to that day.

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.next_week              # => Mon, 10 May 2010
d.next_week(:saturday)   # => Sat, 15 May 2010
```

The method [`prev_week`][DateAndTime::Calculations#prev_week] is analogous:

```ruby
d.prev_week              # => Mon, 26 Apr 2010
d.prev_week(:saturday)   # => Sat, 01 May 2010
d.prev_week(:friday)     # => Fri, 30 Apr 2010
```

`prev_week` is aliased to [`last_week`][DateAndTime::Calculations#last_week].

Both `next_week` and `prev_week` work as expected when `Date.beginning_of_week` or `config.beginning_of_week` are set.

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.

[Date.beginning_of_week]: https://api.rubyonrails.org/classes/Date.html#method-c-beginning_of_week
[DateAndTime::Calculations#last_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_week
[DateAndTime::Calculations#next_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_week
[DateAndTime::Calculations#prev_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_week

##### `beginning_of_month`, `end_of_month`

The methods [`beginning_of_month`][DateAndTime::Calculations#beginning_of_month] and [`end_of_month`][DateAndTime::Calculations#end_of_month] return the dates for the beginning and end of the month:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_month     # => Sat, 01 May 2010
d.end_of_month           # => Mon, 31 May 2010
```

`beginning_of_month` is aliased to [`at_beginning_of_month`][DateAndTime::Calculations#at_beginning_of_month], and `end_of_month` is aliased to [`at_end_of_month`][DateAndTime::Calculations#at_end_of_month].

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.

[DateAndTime::Calculations#at_beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_month
[DateAndTime::Calculations#at_end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_month
[DateAndTime::Calculations#beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_month
[DateAndTime::Calculations#end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_month

##### `beginning_of_quarter`, `end_of_quarter`

The methods [`beginning_of_quarter`][DateAndTime::Calculations#beginning_of_quarter] and [`end_of_quarter`][DateAndTime::Calculations#end_of_quarter] return the dates for the beginning and end of the quarter of the receiver's calendar year:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_quarter   # => Thu, 01 Apr 2010
d.end_of_quarter         # => Wed, 30 Jun 2010
```

`beginning_of_quarter` is aliased to [`at_beginning_of_quarter`][DateAndTime::Calculations#at_beginning_of_quarter], and `end_of_quarter` is aliased to [`at_end_of_quarter`][DateAndTime::Calculations#at_end_of_quarter].

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.

[DateAndTime::Calculations#at_beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_quarter
[DateAndTime::Calculations#at_end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_quarter
[DateAndTime::Calculations#beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_quarter
[DateAndTime::Calculations#end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_quarter

##### `beginning_of_year`, `end_of_year`

The methods [`beginning_of_year`][DateAndTime::Calculations#beginning_of_year] and [`end_of_year`][DateAndTime::Calculations#end_of_year] return the dates for the beginning and end of the year:

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_year      # => Fri, 01 Jan 2010
d.end_of_year            # => Fri, 31 Dec 2010
```

`beginning_of_year` is aliased to [`at_beginning_of_year`][DateAndTime::Calculations#at_beginning_of_year], and `end_of_year` is aliased to [`at_end_of_year`][DateAndTime::Calculations#at_end_of_year].

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.

[DateAndTime::Calculations#at_beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_year
[DateAndTime::Calculations#at_end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_year
[DateAndTime::Calculations#beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_year
[DateAndTime::Calculations#end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_year

#### Other Date Computations

##### `years_ago`, `years_since`

The method [`years_ago`][DateAndTime::Calculations#years_ago] receives a number of years and returns the same date those many years ago:

```ruby
date = Date.new(2010, 6, 7)
date.years_ago(10) # => Wed, 07 Jun 2000
```

[`years_since`][DateAndTime::Calculations#years_since] moves forward in time:

```ruby
date = Date.new(2010, 6, 7)
date.years_since(10) # => Sun, 07 Jun 2020
```

If such a day does not exist, the last day of the corresponding month is returned:

```ruby
Date.new(2012, 2, 29).years_ago(3)     # => Sat, 28 Feb 2009
Date.new(2012, 2, 29).years_since(3)   # => Sat, 28 Feb 2015
```

[`last_year`][DateAndTime::Calculations#last_year] is short-hand for `#years_ago(1)`.

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.

[DateAndTime::Calculations#last_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_year
[DateAndTime::Calculations#years_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_ago
[DateAndTime::Calculations#years_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_since

##### `months_ago`, `months_since`

The methods [`months_ago`][DateAndTime::Calculations#months_ago] and [`months_since`][DateAndTime::Calculations#months_since] work analogously for months:

```ruby
Date.new(2010, 4, 30).months_ago(2)   # => Sun, 28 Feb 2010
Date.new(2010, 4, 30).months_since(2) # => Wed, 30 Jun 2010
```

If such a day does not exist, the last day of the corresponding month is returned:

```ruby
Date.new(2010, 4, 30).months_ago(2)    # => Sun, 28 Feb 2010
Date.new(2009, 12, 31).months_since(2) # => Sun, 28 Feb 2010
```

[`last_month`][DateAndTime::Calculations#last_month] is short-hand for `#months_ago(1)`.

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.

[DateAndTime::Calculations#last_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_month
[DateAndTime::Calculations#months_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_ago
[DateAndTime::Calculations#months_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_since

##### `weeks_ago`

The method [`weeks_ago`][DateAndTime::Calculations#weeks_ago] works analogously for weeks:

```ruby
Date.new(2010, 5, 24).weeks_ago(1)    # => Mon, 17 May 2010
Date.new(2010, 5, 24).weeks_ago(2)    # => Mon, 10 May 2010
```

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.

[DateAndTime::Calculations#weeks_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-weeks_ago

##### `advance`

The most generic way to jump to other days is [`advance`][Date#advance]. This method receives a hash with keys `:years`, `:months`, `:weeks`, `:days`, and returns a date advanced as much as the present keys indicate:

```ruby
date = Date.new(2010, 6, 6)
date.advance(years: 1, weeks: 2)  # => Mon, 20 Jun 2011
date.advance(months: 2, days: -2) # => Wed, 04 Aug 2010
```

Note in the previous example that increments may be negative.

NOTE: Defined in `active_support/core_ext/date/calculations.rb`.

[Date#advance]: https://api.rubyonrails.org/classes/Date.html#method-i-advance

#### Changing Components

The method [`change`][Date#change] allows you to get a new date which is the same as the receiver except for the given year, month, or day:

```ruby
Date.new(2010, 12, 23).change(year: 2011, month: 11)
# => Wed, 23 Nov 2011
```

This method is not tolerant to non-existing dates, if the change is invalid `ArgumentError` is raised:

```ruby
Date.new(2010, 1, 31).change(month: 2)
# => ArgumentError: invalid date
```

NOTE: Defined in `active_support/core_ext/date/calculations.rb`.

[Date#change]: https://api.rubyonrails.org/classes/Date.html#method-i-change

#### Durations

[`Duration`][ActiveSupport::Duration] objects can be added to and subtracted from dates:

```ruby
d = Date.current
# => Mon, 09 Aug 2010
d + 1.year
# => Tue, 09 Aug 2011
d - 3.hours
# => Sun, 08 Aug 2010 21:00:00 UTC +00:00
```

They translate to calls to `since` or `advance`. For example here we get the correct jump in the calendar reform:

```ruby
Date.new(1582, 10, 4) + 1.day
# => Fri, 15 Oct 1582
```

[ActiveSupport::Duration]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html

#### Timestamps

INFO: The following methods return a `Time` object if possible, otherwise a `DateTime`. If set, they honor the user time zone.

##### `beginning_of_day`, `end_of_day`

The method [`beginning_of_day`][Date#beginning_of_day] returns a timestamp at the beginning of the day (00:00:00):

```ruby
date = Date.new(2010, 6, 7)
date.beginning_of_day # => Mon Jun 07 00:00:00 +0200 2010
```

The method [`end_of_day`][Date#end_of_day] returns a timestamp at the end of the day (23:59:59):

```ruby
date = Date.new(2010, 6, 7)
date.end_of_day # => Mon Jun 07 23:59:59 +0200 2010
```

`beginning_of_day` is aliased to [`at_beginning_of_day`][Date#at_beginning_of_day], [`midnight`][Date#midnight], [`at_midnight`][Date#at_midnight].

NOTE: Defined in `active_support/core_ext/date/calculations.rb`.

[Date#at_beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-at_beginning_of_day
[Date#at_midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-at_midnight
[Date#beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-beginning_of_day
[Date#end_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-end_of_day
[Date#midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-midnight

##### `beginning_of_hour`, `end_of_hour`

The method [`beginning_of_hour`][DateTime#beginning_of_hour] returns a timestamp at the beginning of the hour (hh:00:00):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_hour # => Mon Jun 07 19:00:00 +0200 2010
```

The method [`end_of_hour`][DateTime#end_of_hour] returns a timestamp at the end of the hour (hh:59:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_hour # => Mon Jun 07 19:59:59 +0200 2010
```

`beginning_of_hour` is aliased to [`at_beginning_of_hour`][DateTime#at_beginning_of_hour].

NOTE: Defined in `active_support/core_ext/date_time/calculations.rb`.

##### `beginning_of_minute`, `end_of_minute`

The method [`beginning_of_minute`][DateTime#beginning_of_minute] returns a timestamp at the beginning of the minute (hh:mm:00):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_minute # => Mon Jun 07 19:55:00 +0200 2010
```

The method [`end_of_minute`][DateTime#end_of_minute] returns a timestamp at the end of the minute (hh:mm:59):

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_minute # => Mon Jun 07 19:55:59 +0200 2010
```

`beginning_of_minute` is aliased to [`at_beginning_of_minute`][DateTime#at_beginning_of_minute].

INFO: `beginning_of_hour`, `end_of_hour`, `beginning_of_minute`, and `end_of_minute` are implemented for `Time` and `DateTime` but **not** `Date` as it does not make sense to request the beginning or end of an hour or minute on a `Date` instance.

NOTE: Defined in `active_support/core_ext/date_time/calculations.rb`.

[DateTime#at_beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_minute
[DateTime#beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_minute
[DateTime#end_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_minute

##### `ago`, `since`

The method [`ago`][Date#ago] receives a number of seconds as argument and returns a timestamp those many seconds ago from midnight:

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.ago(1)         # => Thu, 10 Jun 2010 23:59:59 EDT -04:00
```

Similarly, [`since`][Date#since] moves forward:

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.since(1)       # => Fri, 11 Jun 2010 00:00:01 EDT -04:00
```

NOTE: Defined in `active_support/core_ext/date/calculations.rb`.

[Date#ago]: https://api.rubyonrails.org/classes/Date.html#method-i-ago
[Date#since]: https://api.rubyonrails.org/classes/Date.html#method-i-since

Extensions to `DateTime`
------------------------

WARNING: `DateTime` is not aware of DST rules and so some of these methods have edge cases when a DST change is going on. For example [`seconds_since_midnight`][DateTime#seconds_since_midnight] might not return the real amount in such a day.

### Calculations

The class `DateTime` is a subclass of `Date` so by loading `active_support/core_ext/date/calculations.rb` you inherit these methods and their aliases, except that they will always return datetimes.

The following methods are reimplemented so you do **not** need to load `active_support/core_ext/date/calculations.rb` for these ones:

* [`beginning_of_day`][DateTime#beginning_of_day] / [`midnight`][DateTime#midnight] / [`at_midnight`][DateTime#at_midnight] / [`at_beginning_of_day`][DateTime#at_beginning_of_day]
* [`end_of_day`][DateTime#end_of_day]
* [`ago`][DateTime#ago]
* [`since`][DateTime#since] / [`in`][DateTime#in]

On the other hand, [`advance`][DateTime#advance] and [`change`][DateTime#change] are also defined and support more options, they are documented below.

The following methods are only implemented in `active_support/core_ext/date_time/calculations.rb` as they only make sense when used with a `DateTime` instance:

* [`beginning_of_hour`][DateTime#beginning_of_hour] / [`at_beginning_of_hour`][DateTime#at_beginning_of_hour]
* [`end_of_hour`][DateTime#end_of_hour]

[DateTime#ago]: https://api.rubyonrails.org/classes/DateTime.html#method-i-ago
[DateTime#at_beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_day
[DateTime#at_beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_hour
[DateTime#at_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_midnight
[DateTime#beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_day
[DateTime#beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_hour
[DateTime#end_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_day
[DateTime#end_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_hour
[DateTime#in]: https://api.rubyonrails.org/classes/DateTime.html#method-i-in
[DateTime#midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-midnight

#### Named Datetimes

##### `DateTime.current`

Active Support defines [`DateTime.current`][DateTime.current] to be like `Time.now.to_datetime`, except that it honors the user time zone, if defined. The instance predicates [`past?`][DateAndTime::Calculations#past?] and [`future?`][DateAndTime::Calculations#future?] are defined relative to `DateTime.current`.

NOTE: Defined in `active_support/core_ext/date_time/calculations.rb`.

[DateTime.current]: https://api.rubyonrails.org/classes/DateTime.html#method-c-current

#### Other Extensions

##### `seconds_since_midnight`

The method [`seconds_since_midnight`][DateTime#seconds_since_midnight] returns the number of seconds since midnight:

```ruby
now = DateTime.current     # => Mon, 07 Jun 2010 20:26:36 +0000
now.seconds_since_midnight # => 73596
```

NOTE: Defined in `active_support/core_ext/date_time/calculations.rb`.

[DateTime#seconds_since_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-seconds_since_midnight

##### `utc`

The method [`utc`][DateTime#utc] gives you the same datetime in the receiver expressed in UTC.

```ruby
now = DateTime.current # => Mon, 07 Jun 2010 19:27:52 -0400
now.utc                # => Mon, 07 Jun 2010 23:27:52 +0000
```

This method is also aliased as [`getutc`][DateTime#getutc].

NOTE: Defined in `active_support/core_ext/date_time/calculations.rb`.

[DateTime#getutc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-getutc
[DateTime#utc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc

##### `utc?`

The predicate [`utc?`][DateTime#utc?] says whether the receiver has UTC as its time zone:

```ruby
now = DateTime.now # => Mon, 07 Jun 2010 19:30:47 -0400
now.utc?           # => false
now.utc.utc?       # => true
```

NOTE: Defined in `active_support/core_ext/date_time/calculations.rb`.

[DateTime#utc?]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc-3F

##### `advance`

The most generic way to jump to another datetime is [`advance`][DateTime#advance]. This method receives a hash with keys `:years`, `:months`, `:weeks`, `:days`, `:hours`, `:minutes`, and `:seconds`, and returns a datetime advanced as much as the present keys indicate.

```ruby
d = DateTime.current
# => Thu, 05 Aug 2010 11:33:31 +0000
d.advance(years: 1, months: 1, days: 1, hours: 1, minutes: 1, seconds: 1)
# => Tue, 06 Sep 2011 12:34:32 +0000
```

This method first computes the destination date passing `:years`, `:months`, `:weeks`, and `:days` to `Date#advance` documented above. After that, it adjusts the time calling [`since`][DateTime#since] with the number of seconds to advance. This order is relevant, a different ordering would give different datetimes in some edge-cases. The example in `Date#advance` applies, and we can extend it to show order relevance related to the time bits.

If we first move the date bits (that have also a relative order of processing, as documented before), and then the time bits we get for example the following computation:

```ruby
d = DateTime.new(2010, 2, 28, 23, 59, 59)
# => Sun, 28 Feb 2010 23:59:59 +0000
d.advance(months: 1, seconds: 1)
# => Mon, 29 Mar 2010 00:00:00 +0000
```

but if we computed them the other way around, the result would be different:

```ruby
d.advance(seconds: 1).advance(months: 1)
# => Thu, 01 Apr 2010 00:00:00 +0000
```

WARNING: Since `DateTime` is not DST-aware you can end up in a non-existing point in time with no warning or error telling you so.

NOTE: Defined in `active_support/core_ext/date_time/calculations.rb`.

[DateTime#advance]: https://api.rubyonrails.org/classes/DateTime.html#method-i-advance
[DateTime#since]: https://api.rubyonrails.org/classes/DateTime.html#method-i-since

#### Changing Components

The method [`change`][DateTime#change] allows you to get a new datetime which is the same as the receiver except for the given options, which may include `:year`, `:month`, `:day`, `:hour`, `:min`, `:sec`, `:offset`, `:start`:

```ruby
now = DateTime.current
# => Tue, 08 Jun 2010 01:56:22 +0000
now.change(year: 2011, offset: Rational(-6, 24))
# => Wed, 08 Jun 2011 01:56:22 -0600
```

If hours are zeroed, then minutes and seconds are too (unless they have given values):

```ruby
now.change(hour: 0)
# => Tue, 08 Jun 2010 00:00:00 +0000
```

Similarly, if minutes are zeroed, then seconds are too (unless it has given a value):

```ruby
now.change(min: 0)
# => Tue, 08 Jun 2010 01:00:00 +0000
```

This method is not tolerant to non-existing dates, if the change is invalid `ArgumentError` is raised:

```ruby
DateTime.current.change(month: 2, day: 30)
# => ArgumentError: invalid date
```

NOTE: Defined in `active_support/core_ext/date_time/calculations.rb`.

[DateTime#change]: https://api.rubyonrails.org/classes/DateTime.html#method-i-change

#### Durations

[`Duration`][ActiveSupport::Duration] objects can be added to and subtracted from datetimes:

```ruby
now = DateTime.current
# => Mon, 09 Aug 2010 23:15:17 +0000
now + 1.year
# => Tue, 09 Aug 2011 23:15:17 +0000
now - 1.week
# => Mon, 02 Aug 2010 23:15:17 +0000
```

They translate to calls to `since` or `advance`. For example here we get the correct jump in the calendar reform:

```ruby
DateTime.new(1582, 10, 4, 23) + 1.hour
# => Fri, 15 Oct 1582 00:00:00 +0000
```

Extensions to `Time`
--------------------

### Calculations

They are analogous. Please refer to their documentation above and take into account the following differences:

* [`change`][Time#change] accepts an additional `:usec` option.
* `Time` understands DST, so you get correct DST calculations as in

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>

# In Barcelona, 2010/03/28 02:00 +0100 becomes 2010/03/28 03:00 +0200 due to DST.
t = Time.local(2010, 3, 28, 1, 59, 59)
# => Sun Mar 28 01:59:59 +0100 2010
t.advance(seconds: 1)
# => Sun Mar 28 03:00:00 +0200 2010
```

* If [`since`][Time#since] or [`ago`][Time#ago] jumps to a time that can't be expressed with `Time` a `DateTime` object is returned instead.

[Time#ago]: https://api.rubyonrails.org/classes/Time.html#method-i-ago
[Time#change]: https://api.rubyonrails.org/classes/Time.html#method-i-change
[Time#since]: https://api.rubyonrails.org/classes/Time.html#method-i-since

#### `Time.current`

Active Support defines [`Time.current`][Time.current] to be today in the current time zone. That's like `Time.now`, except that it honors the user time zone, if defined. It also defines the instance predicates [`past?`][DateAndTime::Calculations#past?], [`today?`][DateAndTime::Calculations#today?], [`tomorrow?`][DateAndTime::Calculations#tomorrow?], [`next_day?`][DateAndTime::Calculations#next_day?], [`yesterday?`][DateAndTime::Calculations#yesterday?], [`prev_day?`][DateAndTime::Calculations#prev_day?] and [`future?`][DateAndTime::Calculations#future?], all of them relative to `Time.current`.

When making Time comparisons using methods which honor the user time zone, make sure to use `Time.current` instead of `Time.now`. There are cases where the user time zone might be in the future compared to the system time zone, which `Time.now` uses by default. This means `Time.now.to_date` may equal `Date.yesterday`.

NOTE: Defined in `active_support/core_ext/time/calculations.rb`.

[DateAndTime::Calculations#next_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_day-3F
[DateAndTime::Calculations#prev_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_day-3F
[DateAndTime::Calculations#today?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-today-3F
[DateAndTime::Calculations#tomorrow?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-tomorrow-3F
[DateAndTime::Calculations#yesterday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-yesterday-3F

#### `all_day`, `all_week`, `all_month`, `all_quarter`, and `all_year`

The method [`all_day`][DateAndTime::Calculations#all_day] returns a range representing the whole day of the current time.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_day
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Mon, 09 Aug 2010 23:59:59 UTC +00:00
```

Analogously, [`all_week`][DateAndTime::Calculations#all_week], [`all_month`][DateAndTime::Calculations#all_month], [`all_quarter`][DateAndTime::Calculations#all_quarter] and [`all_year`][DateAndTime::Calculations#all_year] all serve the purpose of generating time ranges.

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_week
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Sun, 15 Aug 2010 23:59:59 UTC +00:00
now.all_week(:sunday)
# => Sun, 16 Sep 2012 00:00:00 UTC +00:00..Sat, 22 Sep 2012 23:59:59 UTC +00:00
now.all_month
# => Sat, 01 Aug 2010 00:00:00 UTC +00:00..Tue, 31 Aug 2010 23:59:59 UTC +00:00
now.all_quarter
# => Thu, 01 Jul 2010 00:00:00 UTC +00:00..Thu, 30 Sep 2010 23:59:59 UTC +00:00
now.all_year
# => Fri, 01 Jan 2010 00:00:00 UTC +00:00..Fri, 31 Dec 2010 23:59:59 UTC +00:00
```

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.

[DateAndTime::Calculations#all_day]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_day
[DateAndTime::Calculations#all_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_month
[DateAndTime::Calculations#all_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_quarter
[DateAndTime::Calculations#all_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_week
[DateAndTime::Calculations#all_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_year
[Time.current]: https://api.rubyonrails.org/classes/Time.html#method-c-current

#### `prev_day`, `next_day`

[`prev_day`][Time#prev_day] and [`next_day`][Time#next_day] return the time in the last or next day:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_day               # => 2010-05-07 00:00:00 +0900
t.next_day               # => 2010-05-09 00:00:00 +0900
```

NOTE: Defined in `active_support/core_ext/time/calculations.rb`.

[Time#next_day]: https://api.rubyonrails.org/classes/Time.html#method-i-next_day
[Time#prev_day]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_day

#### `prev_month`, `next_month`

[`prev_month`][Time#prev_month] and [`next_month`][Time#next_month] return the time with the same day in the last or next month:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_month             # => 2010-04-08 00:00:00 +0900
t.next_month             # => 2010-06-08 00:00:00 +0900
```

If such a day does not exist, the last day of the corresponding month is returned:

```ruby
Time.new(2000, 5, 31).prev_month # => 2000-04-30 00:00:00 +0900
Time.new(2000, 3, 31).prev_month # => 2000-02-29 00:00:00 +0900
Time.new(2000, 5, 31).next_month # => 2000-06-30 00:00:00 +0900
Time.new(2000, 1, 31).next_month # => 2000-02-29 00:00:00 +0900
```

NOTE: Defined in `active_support/core_ext/time/calculations.rb`.

[Time#next_month]: https://api.rubyonrails.org/classes/Time.html#method-i-next_month
[Time#prev_month]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_month

#### `prev_year`, `next_year`

[`prev_year`][Time#prev_year] and [`next_year`][Time#next_year] return a time with the same day/month in the last or next year:

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_year              # => 2009-05-08 00:00:00 +0900
t.next_year              # => 2011-05-08 00:00:00 +0900
```

If date is the 29th of February of a leap year, you obtain the 28th:

```ruby
t = Time.new(2000, 2, 29) # => 2000-02-29 00:00:00 +0900
t.prev_year               # => 1999-02-28 00:00:00 +0900
t.next_year               # => 2001-02-28 00:00:00 +0900
```

NOTE: Defined in `active_support/core_ext/time/calculations.rb`.

[Time#next_year]: https://api.rubyonrails.org/classes/Time.html#method-i-next_year
[Time#prev_year]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_year

#### `prev_quarter`, `next_quarter`

[`prev_quarter`][DateAndTime::Calculations#prev_quarter] and [`next_quarter`][DateAndTime::Calculations#next_quarter] return the date with the same day in the previous or next quarter:

```ruby
t = Time.local(2010, 5, 8) # => 2010-05-08 00:00:00 +0300
t.prev_quarter             # => 2010-02-08 00:00:00 +0200
t.next_quarter             # => 2010-08-08 00:00:00 +0300
```

If such a day does not exist, the last day of the corresponding month is returned:

```ruby
Time.local(2000, 7, 31).prev_quarter  # => 2000-04-30 00:00:00 +0300
Time.local(2000, 5, 31).prev_quarter  # => 2000-02-29 00:00:00 +0200
Time.local(2000, 10, 31).prev_quarter # => 2000-07-31 00:00:00 +0300
Time.local(2000, 11, 31).next_quarter # => 2001-03-01 00:00:00 +0200
```

`prev_quarter` is aliased to [`last_quarter`][DateAndTime::Calculations#last_quarter].

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.

[DateAndTime::Calculations#last_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_quarter
[DateAndTime::Calculations#next_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_quarter
[DateAndTime::Calculations#prev_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_quarter

### Time Constructors

Active Support defines [`Time.current`][Time.current] to be `Time.zone.now` if there's a user time zone defined, with fallback to `Time.now`:

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>
Time.current
# => Fri, 06 Aug 2010 17:11:58 CEST +02:00
```

Analogously to `DateTime`, the predicates [`past?`][DateAndTime::Calculations#past?], and [`future?`][DateAndTime::Calculations#future?] are relative to `Time.current`.

If the time to be constructed lies beyond the range supported by `Time` in the runtime platform, usecs are discarded and a `DateTime` object is returned instead.

#### Durations

[`Duration`][ActiveSupport::Duration] objects can be added to and subtracted from time objects:

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now + 1.year
# => Tue, 09 Aug 2011 23:21:11 UTC +00:00
now - 1.week
# => Mon, 02 Aug 2010 23:21:11 UTC +00:00
```

They translate to calls to `since` or `advance`. For example here we get the correct jump in the calendar reform:

```ruby
Time.utc(1582, 10, 3) + 5.days
# => Mon Oct 18 00:00:00 UTC 1582
```

Extensions to `File`
--------------------

### `atomic_write`

With the class method [`File.atomic_write`][File.atomic_write] you can write to a file in a way that will prevent any reader from seeing half-written content.

The name of the file is passed as an argument, and the method yields a file handle opened for writing. Once the block is done `atomic_write` closes the file handle and completes its job.

For example, Action Pack uses this method to write asset cache files like `all.css`:

```ruby
File.atomic_write(joined_asset_path) do |cache|
  cache.write(join_asset_file_contents(asset_paths))
end
```

To accomplish this `atomic_write` creates a temporary file. That's the file the code in the block actually writes to. On completion, the temporary file is renamed, which is an atomic operation on POSIX systems. If the target file exists `atomic_write` overwrites it and keeps owners and permissions. However there are a few cases where `atomic_write` cannot change the file ownership or permissions, this error is caught and skipped over trusting in the user/filesystem to ensure the file is accessible to the processes that need it.

NOTE. Due to the chmod operation `atomic_write` performs, if the target file has an ACL set on it this ACL will be recalculated/modified.

WARNING. Note you can't append with `atomic_write`.

The auxiliary file is written in a standard directory for temporary files, but you can pass a directory of your choice as second argument.

NOTE: Defined in `active_support/core_ext/file/atomic.rb`.

[File.atomic_write]: https://api.rubyonrails.org/classes/File.html#method-c-atomic_write

Extensions to `NameError`
-------------------------

Active Support adds [`missing_name?`][NameError#missing_name?] to `NameError`, which tests whether the exception was raised because of the name passed as argument.

The name may be given as a symbol or string. A symbol is tested against the bare constant name, a string is against the fully qualified constant name.

TIP: A symbol can represent a fully qualified constant name as in `:"ActiveRecord::Base"`, so the behavior for symbols is defined for convenience, not because it has to be that way technically.

For example, when an action of `ArticlesController` is called Rails tries optimistically to use `ArticlesHelper`. It is OK that the helper module does not exist, so if an exception for that constant name is raised it should be silenced. But it could be the case that `articles_helper.rb` raises a `NameError` due to an actual unknown constant. That should be reraised. The method `missing_name?` provides a way to distinguish both cases:

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

NOTE: Defined in `active_support/core_ext/name_error.rb`.

[NameError#missing_name?]: https://api.rubyonrails.org/classes/NameError.html#method-i-missing_name-3F

Extensions to `LoadError`
-------------------------

Active Support adds [`is_missing?`][LoadError#is_missing?] to `LoadError`.

Given a path name `is_missing?` tests whether the exception was raised due to that particular file (except perhaps for the ".rb" extension).

For example, when an action of `ArticlesController` is called Rails tries to load `articles_helper.rb`, but that file may not exist. That's fine, the helper module is not mandatory so Rails silences a load error. But it could be the case that the helper module does exist and in turn requires another library that is missing. In that case Rails must reraise the exception. The method `is_missing?` provides a way to distinguish both cases:

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

NOTE: Defined in `active_support/core_ext/load_error.rb`.

[LoadError#is_missing?]: https://api.rubyonrails.org/classes/LoadError.html#method-i-is_missing-3F

Extensions to Pathname
-------------------------

### `existência`

O [`existence`][Pathname#existence] retorna o receptor se o arquivo nomeado existir, caso contrário retorna `nil`. É útil para expressões idiomáticas como esta:

```ruby
content = Pathname.new("file").existence&.read
```

NOTE: Definido em `active_support/core_ext/pathname/existence.rb`.

[Pathname#existence]: https://api.rubyonrails.org/classes/Pathname.html#method-i-existence
