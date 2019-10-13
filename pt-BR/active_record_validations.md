**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

*Active Record* Validações
=========================

Este guia te ensina a validar os estados dos objetos antes deles serem incluídos no 
banco de dados usando as validações do *Active Record*.

Depois de ler este guia, você saberá:

* Como usar as validações já inclusas no *Active Record*.
* Como criar seus próprios métodos de validação.
* Como trabalhar com mensagens de erro geradas pelo processo de validação.

--------------------------------------------------------------------------------

Resumo das Validações
----------------------

Este é um exemplo de uma validação simples:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

Person.create(name: "John Doe").valid? # => true
Person.create(name: nil).valid? # => false
```

Como você pode ver, nossa validação nos deixa saber que nossa *`Person`* não é
válida sem o atributo *`name`*. A segunda *`Person`* não existirá no banco de dados.

Antes de entrarmos em maiores detalhes, vamos falar sobre como as validações
funcionam na nossa aplicação.

### Por que usar validações?

Validações são usadas para garantir que só dados válidos sejam salvos no seu
banco de dados. Por exemplo, pode ser importante para sua aplicação garantir
que todo usuário forneça um endereço de e-mail e endereço de correspondência
válidos. Validações de *model* são a melhor maneira de garantir que só
dados válidos sejam salvos em seu banco de dados. Eles são bancos de dados
agnóticos, não podem ser contornador por usuários, e são fáceis de manter e
de testar. Rails faz que elas sejam fáceis de usar, e fornece ajudantes 
*build-in* para necessidades comuns, e também permite que você crie seus 
próprios métodos de validação.

Exitem outros modos de validar dados antes deles serem salvos no seu banco de
dados, incluindo restrições nativas do banco de dados, validações no lado do 
cliente e valições no nível do *controller*. Este é um sumário dos prós
e contras:

* Restrições no banco de dados e/ou procedimentos armazenados tornam as validações
  dependententes do banco de dados e podem tornar o processo de testar e a manutenção 
  mais difíceis. No entanto, se seu banco de dados é usado por outras aplicações, pode 
  ser uma boa ideia usar algumas restrições diretamente no banco de dados. Adicionalmente, 
  validações no nível de banco de dados são seguras para lidar com algumas coisas
  (como singularidade em tabelas muito utilizadas) que seriam difíceis de
  implementar de outra forma.
* Validações no lado do cliente são úteis, mas no geral não são seguras quando 
  utilizadas sozinhas. Se elas forem implementadas usando JavaScript, elas podem
  ser contornadas se o JavaScript estiver desligado no navegador do usuário. No
  entanto se forem combinadas com outras técnicas, essas validações podem ser um
  método mais conveniente de fornecer ao usuário um retorno imediato enquanto 
  eles navegam no seu site.
* Utilizar validações no nível do *controller* pode ser tentador,
  mas frequentemente se tornam pesadas e de manutenção e testagem difíceis. Sempre
  que possível, é uma boa prática manter seus *controllers* leves, o que irá
  tornar a sua aplicação prazerosa de se trabalhar com o passar do tempo.

Escolha essa opção de validação em alguns casos específicos. É da opinião da equipe do Rails que as
validações de *model* são mais apropriadas na maior parte das circunstâncias.

### Quando as validações ocorrem?

Existem dois tipos de objetos de *Active Record*: aqueles que correspondem
a uma linha no seu banco de dados e aqueles que não correspondem. Quando você cria
um objeto novo, por exemplo, usando o método `new`, esse objeto ainda não existe no
banco de dados. Uma vez que você chame o `save` sob esse objeto ele será salvo na
tabela apropriada no seu banco de dados. O *Active Record* usa o método de
instância `new_record?` para determinar se o objeto já existe no banco de dados ou
não.
Considere a seguinte classe do *Active Record*: 

```ruby
class Person < ApplicationRecord
end
```

Podemos ver como ela funciona olhando para o resultado no `rails console`:

```ruby
$ rails console
>> p = Person.new(name: "John Doe")
=> #<Person id: nil, name: "John Doe", created_at: nil, updated_at: nil>
>> p.new_record?
=> true
>> p.save
=> true
>> p.new_record?
=> false
```

Criando e salvando um novo *record* irá mandar uma operação SQL de 
`INSERT` para o seu banco de dados. Atualizando um registro 
existente irá mandar uma operação SQL de `UPDATE` no lugar. 
Validações são tipicamente realizadas antes que esses comandos sejam 
enviados para seu banco de dados. Se alguma validação falhar, o objeto será
marcados como inválido e o *Active Record* não irá executar as
operações de `INSERT` ou `UPDATE`. Isso evita que um dado
inválido seja armazenado no banco de dados. Você pode escolher validações
específicas que atuem quando um objeto for criado, salvo, ou editado. 

ADVERTÊNCIA: Existem muitos modos de alterar o estado de um objeto no banco
de dados. Alguns métodos irão acionar validações, mas alguns não vão. Isso
significa que é possível salvar um objeto inválido no banco de dados se você
não tomar cuidado.

Os métodos a seguir acionam validações e só vão salvar objetos que 
forem válidos no banco de dados: 

* `create`
* `create!`
* `save`
* `save!`
* `update`
* `update!`

As versões *bang* (ex: `save!`) levantam uma exceção se o objeto for 
inválido. As versões normais não fazem isso: `save` e `update` retornam `false`,
e `create` retorna o objeto.

### Pulando Validações

Os seguintes métodos pulam validações, e irão salvar o objeto no banco 
de dados independente da sua validez. Eles devem ser usados com cuidado.

* `decrement!`
* `decrement_counter`
* `increment!`
* `increment_counter`
* `toggle!`
* `touch`
* `update_all`
* `update_attribute`
* `update_column`
* `update_columns`
* `update_counters`

Note que `save` também tem a habilidade de pular validações se for 
estabelecido `validate: false` como argumento. Essa técnica deve ser
usada com cuidado.

* `save(validate: false)`

### `valid?` e `invalid?`

Antes de salvar um objeto do *Active Record*, Rails executa suas
validações. Se essas validações produzirem um erro, o Rails não salva
o objeto.

Você também pode executar essas validações por si só. *`valid?`* ativa suas validações
e retorna *true* se nenhum erro for encontrado no objeto, e *false* 
caso contrário.
Como dito acima:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

Person.create(name: "John Doe").valid? # => true
Person.create(name: nil).valid? # => false
```

Depois do *Active Record* executar as validações, qualquer erro encontrado
pode ser acessado através do método de instância *`errors.messages`*, que
retorna uma coleção de erros. Por definição, um objeto é válida se essa coleção 
estiver vazia após serem executadas as validações.

Note que um objeto instanciado como *`new`* não irá informar nenhum erro mesmo que 
ele seja tecnicamente inválido, porque as validações são executadas automaticamente
apenas quando o objeto é salvo, como quando acontecem com os métodos *`create`* 
ou *`save`*.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

>> p = Person.new
# => #<Person id: nil, name: nil>
>> p.errors.messages
# => {}

>> p.valid?
# => false
>> p.errors.messages
# => {name:["can't be blank"]}

>> p = Person.create
# => #<Person id: nil, name: nil>
>> p.errors.messages
# => {name:["can't be blank"]}

>> p.save
# => false

>> p.save!
# => ActiveRecord::RecordInvalid: Validation failed: Name can't be blank

>> Person.create!
# => ActiveRecord::RecordInvalid: Validation failed: Name can't be blank
```

`invalid?` é simplesmente o inverso de `valid?`. Desencadeia suas validações e
retornam *true* se algum erro for encontrado no objeto, e *false* 
caso contrário.

### *`errors[]`*

Para verificar se um determinado atributo de um objeto é válido, você pode 
usar *`errors[:attribute]`*. Isso retorna um *array* com todos os 
erros para o *`:attribute`*. Se não houver nenhum erro para o atributo 
especificado, um *array* vazia é exibida.

Esse método só é útil **após** as validações terem sido executadas, porque ele só 
inspeciona as coleções de erros e não aciona nenhuma validação em si. É 
diferente do método `ActiveRecord::Base#invalid?` explicado acima porque 
não verifica ao todo se um objeto é válido. Apenas verifica se existem 
erros em um determinado atributo do objeto.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

>> Person.new.errors[:name].any? # => false
>> Person.create.errors[:name].any? # => true
```

Nós vamos cobrir os erros das validações em maior detalhe na seção [Trabalhando com 
Erros de Validações](#trabalhando-com-erros-de-validações).

### `errors.details`

Para checar quais validações falharam em um atributo inválido, você pode usar 
`errors.details[:attribute]`. Isso retorna um *array* de *hashes*
com uma chave `:error` para conseguir o símbolo do validador:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end

>> person = Person.new
>> person.valid?
>> person.errors.details[:name] # => [{error: :blank}]
```

O uso de `details` juntamente com validadores é tratado na seção 
[Trabalhando com Erros de Validações](#trabalhando-com-erros-de-validações).

Validation Helpers
------------------

Active Record offers many pre-defined validation helpers that you can use
directly inside your class definitions. These helpers provide common validation
rules. Every time a validation fails, an error message is added to the object's
`errors` collection, and this message is associated with the attribute being
validated.

Each helper accepts an arbitrary number of attribute names, so with a single
line of code you can add the same kind of validation to several attributes.

All of them accept the `:on` and `:message` options, which define when the
validation should be run and what message should be added to the `errors`
collection if it fails, respectively. The `:on` option takes one of the values
`:create` or `:update`. There is a default error
message for each one of the validation helpers. These messages are used when
the `:message` option isn't specified. Let's take a look at each one of the
available helpers.

### `acceptance`

This method validates that a checkbox on the user interface was checked when a
form was submitted. This is typically used when the user needs to agree to your
application's terms of service, confirm that some text is read, or any similar
concept.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end
```

This check is performed only if `terms_of_service` is not `nil`.
The default error message for this helper is _"must be accepted"_.
You can also pass custom message via the `message` option.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { message: 'must be abided' }
end
```

It can also receive an `:accept` option, which determines the allowed values
that will be considered as accepted. It defaults to `['1', true]` and can be
easily changed.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { accept: 'yes' }
  validates :eula, acceptance: { accept: ['TRUE', 'accepted'] }
end
```

This validation is very specific to web applications and this
'acceptance' does not need to be recorded anywhere in your database. If you
don't have a field for it, the helper will just create a virtual attribute. If
the field does exist in your database, the `accept` option must be set to
or include `true` or else the validation will not run.

### `validates_associated`

You should use this helper when your model has associations with other models
and they also need to be validated. When you try to save your object, `valid?`
will be called upon each one of the associated objects.

```ruby
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

This validation will work with all of the association types.

CAUTION: Don't use `validates_associated` on both ends of your associations.
They would call each other in an infinite loop.

The default error message for `validates_associated` is _"is invalid"_. Note
that each associated object will contain its own `errors` collection; errors do
not bubble up to the calling model.

### `confirmation`

You should use this helper when you have two text fields that should receive
exactly the same content. For example, you may want to confirm an email address
or a password. This validation creates a virtual attribute whose name is the
name of the field that has to be confirmed with "_confirmation" appended.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
end
```

In your view template you could use something like

```erb
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>
```

This check is performed only if `email_confirmation` is not `nil`. To require
confirmation, make sure to add a presence check for the confirmation attribute
(we'll take a look at `presence` later on in this guide):

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end
```

There is also a `:case_sensitive` option that you can use to define whether the
confirmation constraint will be case sensitive or not. This option defaults to
true.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: { case_sensitive: false }
end
```

The default error message for this helper is _"doesn't match confirmation"_.

### `exclusion`

This helper validates that the attributes' values are not included in a given
set. In fact, this set can be any enumerable object.

```ruby
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} is reserved." }
end
```

The `exclusion` helper has an option `:in` that receives the set of values that
will not be accepted for the validated attributes. The `:in` option has an
alias called `:within` that you can use for the same purpose, if you'd like to.
This example uses the `:message` option to show how you can include the
attribute's value. For full options to the message argument please see the
[message documentation](#message).

The default error message is _"is reserved"_.

### `format`

This helper validates the attributes' values by testing whether they match a
given regular expression, which is specified using the `:with` option.

```ruby
class Product < ApplicationRecord
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "only allows letters" }
end
```

Alternatively, you can require that the specified attribute does _not_ match the regular expression by using the `:without` option.

The default error message is _"is invalid"_.

### `inclusion`

This helper validates that the attributes' values are included in a given set.
In fact, this set can be any enumerable object.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }
end
```

The `inclusion` helper has an option `:in` that receives the set of values that
will be accepted. The `:in` option has an alias called `:within` that you can
use for the same purpose, if you'd like to. The previous example uses the
`:message` option to show how you can include the attribute's value. For full
options please see the [message documentation](#message).

The default error message for this helper is _"is not included in the list"_.

### `length`

This helper validates the length of the attributes' values. It provides a
variety of options, so you can specify length constraints in different ways:

```ruby
class Person < ApplicationRecord
  validates :name, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
end
```

The possible length constraint options are:

* `:minimum` - The attribute cannot have less than the specified length.
* `:maximum` - The attribute cannot have more than the specified length.
* `:in` (or `:within`) - The attribute length must be included in a given
  interval. The value for this option must be a range.
* `:is` - The attribute length must be equal to the given value.

The default error messages depend on the type of length validation being
performed. You can personalize these messages using the `:wrong_length`,
`:too_long`, and `:too_short` options and `%{count}` as a placeholder for the
number corresponding to the length constraint being used. You can still use the
`:message` option to specify an error message.

```ruby
class Person < ApplicationRecord
  validates :bio, length: { maximum: 1000,
    too_long: "%{count} characters is the maximum allowed" }
end
```

Note that the default error messages are plural (e.g., "is too short (minimum
is %{count} characters)"). For this reason, when `:minimum` is 1 you should
provide a personalized message or use `presence: true` instead. When
`:in` or `:within` have a lower limit of 1, you should either provide a
personalized message or call `presence` prior to `length`.

### `numericality`

This helper validates that your attributes have only numeric values. By
default, it will match an optional sign followed by an integral or floating
point number. To specify that only integral numbers are allowed set
`:only_integer` to true.

If you set `:only_integer` to `true`, then it will use the

```ruby
/\A[+-]?\d+\z/
```

regular expression to validate the attribute's value. Otherwise, it will try to
convert the value to a number using `Float`.

```ruby
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: { only_integer: true }
end
```

Besides `:only_integer`, this helper also accepts the following options to add
constraints to acceptable values:

* `:greater_than` - Specifies the value must be greater than the supplied
  value. The default error message for this option is _"must be greater than
  %{count}"_.
* `:greater_than_or_equal_to` - Specifies the value must be greater than or
  equal to the supplied value. The default error message for this option is
  _"must be greater than or equal to %{count}"_.
* `:equal_to` - Specifies the value must be equal to the supplied value. The
  default error message for this option is _"must be equal to %{count}"_.
* `:less_than` - Specifies the value must be less than the supplied value. The
  default error message for this option is _"must be less than %{count}"_.
* `:less_than_or_equal_to` - Specifies the value must be less than or equal to
  the supplied value. The default error message for this option is _"must be
  less than or equal to %{count}"_.
* `:other_than` - Specifies the value must be other than the supplied value.
  The default error message for this option is _"must be other than %{count}"_.
* `:odd` - Specifies the value must be an odd number if set to true. The
  default error message for this option is _"must be odd"_.
* `:even` - Specifies the value must be an even number if set to true. The
  default error message for this option is _"must be even"_.

NOTE: By default, `numericality` doesn't allow `nil` values. You can use `allow_nil: true` option to permit it.

The default error message is _"is not a number"_.

### `presence`

This helper validates that the specified attributes are not empty. It uses the
`blank?` method to check if the value is either `nil` or a blank string, that
is, a string that is either empty or consists of whitespace.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, presence: true
end
```

If you want to be sure that an association is present, you'll need to test
whether the associated object itself is present, and not the foreign key used
to map the association. This way, it is not only checked that the foreign key
is not empty but also that the referenced object exists.

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, presence: true
end
```

In order to validate associated records whose presence is required, you must
specify the `:inverse_of` option for the association:

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

If you validate the presence of an object associated via a `has_one` or
`has_many` relationship, it will check that the object is neither `blank?` nor
`marked_for_destruction?`.

Since `false.blank?` is true, if you want to validate the presence of a boolean
field you should use one of the following validations:

```ruby
validates :boolean_field_name, inclusion: { in: [true, false] }
validates :boolean_field_name, exclusion: { in: [nil] }
```

By using one of these validations, you will ensure the value will NOT be `nil`
which would result in a `NULL` value in most cases.

### `absence`

This helper validates that the specified attributes are absent. It uses the
`present?` method to check if the value is not either nil or a blank string, that
is, a string that is either empty or consists of whitespace.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, absence: true
end
```

If you want to be sure that an association is absent, you'll need to test
whether the associated object itself is absent, and not the foreign key used
to map the association.

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, absence: true
end
```

In order to validate associated records whose absence is required, you must
specify the `:inverse_of` option for the association:

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

If you validate the absence of an object associated via a `has_one` or
`has_many` relationship, it will check that the object is neither `present?` nor
`marked_for_destruction?`.

Since `false.present?` is false, if you want to validate the absence of a boolean
field you should use `validates :field_name, exclusion: { in: [true, false] }`.

The default error message is _"must be blank"_.

### `uniqueness`

This helper validates that the attribute's value is unique right before the
object gets saved. It does not create a uniqueness constraint in the database,
so it may happen that two different database connections create two records
with the same value for a column that you intend to be unique. To avoid that,
you must create a unique index on that column in your database.

```ruby
class Account < ApplicationRecord
  validates :email, uniqueness: true
end
```

The validation happens by performing an SQL query into the model's table,
searching for an existing record with the same value in that attribute.

There is a `:scope` option that you can use to specify one or more attributes that
are used to limit the uniqueness check:

```ruby
class Holiday < ApplicationRecord
  validates :name, uniqueness: { scope: :year,
    message: "should happen once per year" }
end
```
Should you wish to create a database constraint to prevent possible violations of a uniqueness validation using the `:scope` option, you must create a unique index on both columns in your database. See [the MySQL manual](https://dev.mysql.com/doc/refman/5.7/en/multiple-column-indexes.html) for more details about multiple column indexes or [the PostgreSQL manual](https://www.postgresql.org/docs/current/static/ddl-constraints.html) for examples of unique constraints that refer to a group of columns.

There is also a `:case_sensitive` option that you can use to define whether the
uniqueness constraint will be case sensitive or not. This option defaults to
true.

```ruby
class Person < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
end
```

WARNING. Note that some databases are configured to perform case-insensitive
searches anyway.

The default error message is _"has already been taken"_.

### `validates_with`

This helper passes the record to a separate class for validation.

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors[:base] << "This person is evil"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator
end
```

NOTE: Errors added to `record.errors[:base]` relate to the state of the record
as a whole, and not to a specific attribute.

The `validates_with` helper takes a class, or a list of classes to use for
validation. There is no default error message for `validates_with`. You must
manually add errors to the record's errors collection in the validator class.

To implement the validate method, you must have a `record` parameter defined,
which is the record to be validated.

Like all other validations, `validates_with` takes the `:if`, `:unless` and
`:on` options. If you pass any other options, it will send those options to the
validator class as `options`:

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any?{|field| record.send(field) == "Evil" }
      record.errors[:base] << "This person is evil"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator, fields: [:first_name, :last_name]
end
```

Note that the validator will be initialized *only once* for the whole application
life cycle, and not on each validation run, so be careful about using instance
variables inside it.

If your validator is complex enough that you want instance variables, you can
easily use a plain old Ruby object instead:

```ruby
class Person < ApplicationRecord
  validate do |person|
    GoodnessValidator.new(person).validate
  end
end

class GoodnessValidator
  def initialize(person)
    @person = person
  end

  def validate
    if some_complex_condition_involving_ivars_and_private_methods?
      @person.errors[:base] << "This person is evil"
    end
  end

  # ...
end
```

### `validates_each`

This helper validates attributes against a block. It doesn't have a predefined
validation function. You should create one using a block, and every attribute
passed to `validates_each` will be tested against it. In the following example,
we don't want names and surnames to begin with lower case.

```ruby
class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, 'must start with upper case') if value =~ /\A[[:lower:]]/
  end
end
```

The block receives the record, the attribute's name, and the attribute's value.
You can do anything you like to check for valid data within the block. If your
validation fails, you should add an error message to the model, therefore
making it invalid.

Common Validation Options
-------------------------

These are common validation options:

### `:allow_nil`

The `:allow_nil` option skips the validation when the value being validated is
`nil`.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }, allow_nil: true
end
```

For full options to the message argument please see the
[message documentation](#message).

### `:allow_blank`

The `:allow_blank` option is similar to the `:allow_nil` option. This option
will let validation pass if the attribute's value is `blank?`, like `nil` or an
empty string for example.

```ruby
class Topic < ApplicationRecord
  validates :title, length: { is: 5 }, allow_blank: true
end

Topic.create(title: "").valid?  # => true
Topic.create(title: nil).valid? # => true
```

### `:message`

As you've already seen, the `:message` option lets you specify the message that
will be added to the `errors` collection when validation fails. When this
option is not used, Active Record will use the respective default error message
for each validation helper. The `:message` option accepts a `String` or `Proc`.

A `String` `:message` value can optionally contain any/all of `%{value}`,
`%{attribute}`, and `%{model}` which will be dynamically replaced when
validation fails. This replacement is done using the I18n gem, and the
placeholders must match exactly, no spaces are allowed.

A `Proc` `:message` value is given two arguments: the object being validated, and
a hash with `:model`, `:attribute`, and `:value` key-value pairs.

```ruby
class Person < ApplicationRecord
  # Hard-coded message
  validates :name, presence: { message: "must be given please" }

  # Message with dynamic attribute value. %{value} will be replaced with
  # the actual value of the attribute. %{attribute} and %{model} also
  # available.
  validates :age, numericality: { message: "%{value} seems wrong" }

  # Proc
  validates :username,
    uniqueness: {
      # object = person object being validated
      # data = { model: "Person", attribute: "Username", value: <username> }
      message: ->(object, data) do
        "Hey #{object.name}!, #{data[:value]} is taken already! Try again #{Time.zone.tomorrow}"
      end
    }
end
```

### `:on`

The `:on` option lets you specify when the validation should happen. The
default behavior for all the built-in validation helpers is to be run on save
(both when you're creating a new record and when you're updating it). If you
want to change it, you can use `on: :create` to run the validation only when a
new record is created or `on: :update` to run the validation only when a record
is updated.

```ruby
class Person < ApplicationRecord
  # it will be possible to update email with a duplicated value
  validates :email, uniqueness: true, on: :create

  # it will be possible to create the record with a non-numerical age
  validates :age, numericality: true, on: :update

  # the default (validates on both create and update)
  validates :name, presence: true
end
```

You can also use `on:` to define custom contexts. Custom contexts need to be
triggered explicitly by passing the name of the context to `valid?`,
`invalid?`, or `save`.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
end

person = Person.new(age: 'thirty-three')
person.valid? # => true
person.valid?(:account_setup) # => false
person.errors.messages
 # => {:email=>["has already been taken"], :age=>["is not a number"]}
```

`person.valid?(:account_setup)` executes both the validations without saving
the model. `person.save(context: :account_setup)` validates `person` in the
`account_setup` context before saving.

When triggered by an explicit context, validations are run for that context,
as well as any validations _without_ a context.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
  validates :name, presence: true
end

person = Person.new
person.valid?(:account_setup) # => false
person.errors.messages
 # => {:email=>["has already been taken"], :age=>["is not a number"], :name=>["can't be blank"]}
```

Strict Validations
------------------

You can also specify validations to be strict and raise
`ActiveModel::StrictValidationFailed` when the object is invalid.

```ruby
class Person < ApplicationRecord
  validates :name, presence: { strict: true }
end

Person.new.valid?  # => ActiveModel::StrictValidationFailed: Name can't be blank
```

There is also the ability to pass a custom exception to the `:strict` option.

```ruby
class Person < ApplicationRecord
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end

Person.new.valid?  # => TokenGenerationException: Token can't be blank
```

Conditional Validation
----------------------

Sometimes it will make sense to validate an object only when a given predicate
is satisfied. You can do that by using the `:if` and `:unless` options, which
can take a symbol, a `Proc` or an `Array`. You may use the `:if`
option when you want to specify when the validation **should** happen. If you
want to specify when the validation **should not** happen, then you may use the
`:unless` option.

### Using a Symbol with `:if` and `:unless`

You can associate the `:if` and `:unless` options with a symbol corresponding
to the name of a method that will get called right before validation happens.
This is the most commonly used option.

```ruby
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == "card"
  end
end
```

### Using a Proc with `:if` and `:unless`

It is possible to associate `:if` and `:unless` with a `Proc` object
which will be called. Using a `Proc` object gives you the ability to write an
inline condition instead of a separate method. This option is best suited for
one-liners.

```ruby
class Account < ApplicationRecord
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end
```

As `Lambdas` are a type of `Proc`, they can also be used to write inline
conditions in a shorter way.

```ruby
validates :password, confirmation: true, unless: -> { password.blank? }
```

### Grouping Conditional validations

Sometimes it is useful to have multiple validations use one condition. It can
be easily achieved using `with_options`.

```ruby
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end
```

All validations inside of the `with_options` block will have automatically
passed the condition `if: :is_admin?`

### Combining Validation Conditions

On the other hand, when multiple conditions define whether or not a validation
should happen, an `Array` can be used. Moreover, you can apply both `:if` and
`:unless` to the same validation.

```ruby
class Computer < ApplicationRecord
  validates :mouse, presence: true,
                    if: [Proc.new { |c| c.market.retail? }, :desktop?],
                    unless: Proc.new { |c| c.trackpad.present? }
end
```

The validation only runs when all the `:if` conditions and none of the
`:unless` conditions are evaluated to `true`.

Performing Custom Validations
-----------------------------

When the built-in validation helpers are not enough for your needs, you can
write your own validators or validation methods as you prefer.

### Custom Validators

Custom validators are classes that inherit from `ActiveModel::Validator`. These
classes must implement the `validate` method which takes a record as an argument
and performs the validation on it. The custom validator is called using the
`validates_with` method.

```ruby
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.starts_with? 'X'
      record.errors[:name] << 'Need a name starting with X please!'
    end
  end
end

class Person
  include ActiveModel::Validations
  validates_with MyValidator
end
```

The easiest way to add custom validators for validating individual attributes
is with the convenient `ActiveModel::EachValidator`. In this case, the custom
validator class must implement a `validate_each` method which takes three
arguments: record, attribute, and value. These correspond to the instance, the
attribute to be validated, and the value of the attribute in the passed
instance.

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors[attribute] << (options[:message] || "is not an email")
    end
  end
end

class Person < ApplicationRecord
  validates :email, presence: true, email: true
end
```

As shown in the example, you can also combine standard validations with your
own custom validators.

### Custom Methods

You can also create methods that verify the state of your models and add
messages to the `errors` collection when they are invalid. You must then
register these methods by using the `validate`
([API](https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validate))
class method, passing in the symbols for the validation methods' names.

You can pass more than one symbol for each class method and the respective
validations will be run in the same order as they were registered.

The `valid?` method will verify that the errors collection is empty,
so your custom validation methods should add errors to it when you
wish validation to fail:

```ruby
class Invoice < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "can't be in the past")
    end
  end

  def discount_cannot_be_greater_than_total_value
    if discount > total_value
      errors.add(:discount, "can't be greater than total value")
    end
  end
end
```

By default, such validations will run every time you call `valid?`
or save the object. But it is also possible to control when to run these
custom validations by giving an `:on` option to the `validate` method,
with either: `:create` or `:update`.

```ruby
class Invoice < ApplicationRecord
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "is not active") unless customer.active?
  end
end
```

Working with Validation Errors
------------------------------

In addition to the `valid?` and `invalid?` methods covered earlier, Rails provides a number of methods for working with the `errors` collection and inquiring about the validity of objects.

The following is a list of the most commonly used methods. Please refer to the `ActiveModel::Errors` documentation for a list of all the available methods.

### `errors`

Returns an instance of the class `ActiveModel::Errors` containing all errors. Each key is the attribute name and the value is an array of strings with all errors.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

person = Person.new
person.valid? # => false
person.errors.messages
 # => {:name=>["can't be blank", "is too short (minimum is 3 characters)"]}

person = Person.new(name: "John Doe")
person.valid? # => true
person.errors.messages # => {}
```

### `errors[]`

`errors[]` is used when you want to check the error messages for a specific attribute. It returns an array of strings with all error messages for the given attribute, each string with one error message. If there are no errors related to the attribute, it returns an empty array.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

person = Person.new(name: "John Doe")
person.valid? # => true
person.errors[:name] # => []

person = Person.new(name: "JD")
person.valid? # => false
person.errors[:name] # => ["is too short (minimum is 3 characters)"]

person = Person.new
person.valid? # => false
person.errors[:name]
 # => ["can't be blank", "is too short (minimum is 3 characters)"]
```

### `errors.add`

The `add` method lets you add an error message related to a particular attribute. It takes as arguments the attribute and the error message.

The `errors.full_messages` method (or its equivalent, `errors.to_a`) returns the error messages in a user-friendly format, with the capitalized attribute name prepended to each message, as shown in the examples below.

```ruby
class Person < ApplicationRecord
  def a_method_used_for_validation_purposes
    errors.add(:name, "cannot contain the characters !@#%*()_-+=")
  end
end

person = Person.create(name: "!@#")

person.errors[:name]
 # => ["cannot contain the characters !@#%*()_-+="]

person.errors.full_messages
 # => ["Name cannot contain the characters !@#%*()_-+="]
```

### `errors.details`

You can specify a validator type to the returned error details hash using the
`errors.add` method.

```ruby
class Person < ApplicationRecord
  def a_method_used_for_validation_purposes
    errors.add(:name, :invalid_characters)
  end
end

person = Person.create(name: "!@#")

person.errors.details[:name]
# => [{error: :invalid_characters}]
```

To improve the error details to contain the unallowed characters set for instance,
you can pass additional keys to `errors.add`.

```ruby
class Person < ApplicationRecord
  def a_method_used_for_validation_purposes
    errors.add(:name, :invalid_characters, not_allowed: "!@#%*()_-+=")
  end
end

person = Person.create(name: "!@#")

person.errors.details[:name]
# => [{error: :invalid_characters, not_allowed: "!@#%*()_-+="}]
```

All built in Rails validators populate the details hash with the corresponding
validator type.

### `errors[:base]`

You can add error messages that are related to the object's state as a whole, instead of being related to a specific attribute. You can use this method when you want to say that the object is invalid, no matter the values of its attributes. Since `errors[:base]` is an array, you can simply add a string to it and it will be used as an error message.

```ruby
class Person < ApplicationRecord
  def a_method_used_for_validation_purposes
    errors[:base] << "This person is invalid because ..."
  end
end
```

### `errors.clear`

The `clear` method is used when you intentionally want to clear all the messages in the `errors` collection. Of course, calling `errors.clear` upon an invalid object won't actually make it valid: the `errors` collection will now be empty, but the next time you call `valid?` or any method that tries to save this object to the database, the validations will run again. If any of the validations fail, the `errors` collection will be filled again.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

person = Person.new
person.valid? # => false
person.errors[:name]
 # => ["can't be blank", "is too short (minimum is 3 characters)"]

person.errors.clear
person.errors.empty? # => true

person.save # => false

person.errors[:name]
# => ["can't be blank", "is too short (minimum is 3 characters)"]
```

### `errors.size`

The `size` method returns the total number of error messages for the object.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end

person = Person.new
person.valid? # => false
person.errors.size # => 2

person = Person.new(name: "Andrea", email: "andrea@example.com")
person.valid? # => true
person.errors.size # => 0
```

Displaying Validation Errors in Views
-------------------------------------

Once you've created a model and added validations, if that model is created via
a web form, you probably want to display an error message when one of the
validations fail.

Because every application handles this kind of thing differently, Rails does
not include any view helpers to help you generate these messages directly.
However, due to the rich number of methods Rails gives you to interact with
validations in general, it's fairly easy to build your own. In addition, when
generating a scaffold, Rails will put some ERB into the `_form.html.erb` that
it generates that displays the full list of errors on that model.

Assuming we have a model that's been saved in an instance variable named
`@article`, it looks like this:

```ruby
<% if @article.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@article.errors.count, "error") %> prohibited this article from being saved:</h2>

    <ul>
    <% @article.errors.full_messages.each do |msg| %>
      <li><%= msg %></li>
    <% end %>
    </ul>
  </div>
<% end %>
```

Furthermore, if you use the Rails form helpers to generate your forms, when
a validation error occurs on a field, it will generate an extra `<div>` around
the entry.

```
<div class="field_with_errors">
 <input id="article_title" name="article[title]" size="30" type="text" value="">
</div>
```

You can then style this div however you'd like. The default scaffold that
Rails generates, for example, adds this CSS rule:

```
.field_with_errors {
  padding: 2px;
  background-color: red;
  display: table;
}
```

This means that any field with an error ends up with a 2 pixel red border.
