**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Active Model Basics
===================

This guide should provide you with all you need to get started using model
classes. Active Model allows for Action Pack helpers to interact with
plain Ruby objects. Active Model also helps build custom ORMs for use
outside of the Rails framework.

After reading this guide, you will know:

* How an Active Record model behaves.
* How Callbacks and validations work.
* How serializers work.
* How Active Model integrates with the Rails internationalization (i18n) framework.

--------------------------------------------------------------------------------

Introdução
------------

_Active Model_ é uma biblioteca contendo vários módulos usados para desenvolver
classes que precisam de alguma funcionalidade presente no _Active Record_.
Alguns desses módulos são explicados abaixo.

### _Attribute Methods_

O módulo _`ActiveModel::AttributeMethods`_ pode adicionar prefixos e sufixos 
customizados em métodos de uma classe. Ele é usado definindo os prefixos e 
sufixos, e quais os métodos do objeto que vão usá-los.

```ruby
class Person
  include ActiveModel::AttributeMethods

  attribute_method_prefix 'reset_'
  attribute_method_suffix '_highest?'
  define_attribute_methods 'age'

  attr_accessor :age

  private
    def reset_attribute(attribute)
      send("#{attribute}=", 0)
    end

    def attribute_highest?(attribute)
      send(attribute) > 100
    end
end

person = Person.new
person.age = 110
person.age_highest?  # => true
person.reset_age     # => 0
person.age_highest?  # => false
```

### _Callbacks_

_`ActiveModel::Callbacks`_ fornece _callbacks_ no estilo _Active Record_. Isso 
provê a habilidade de definir _callbacks_ que rodam em horas apropriadas.
Após definir os _callbacks_, você pode envolvê-los com _before_, _after_, 
e _around_ em métodos customizados.

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me

  def update
    run_callbacks(:update) do
      # Esse método é chamado quando _update_ é chamado em um objeto.
    end
  end

  def reset_me
    # Esse método é chamado quando _update_ é chamado em um objeto, pois um _callback_ _before_update_ foi definido.
  end
end
```

### _Conversion_

Se uma classe define os métodos _`persisted?`_ e _`id`_, você pode incluir o 
módulo _`ActiveModel::Conversion`_ nessa classe, e chamar os métodos de conversão 
do _Rails_ em objetos dessa classe.

```ruby
class Person
  include ActiveModel::Conversion

  def persisted?
    false
  end

  def id
    nil
  end
end

person = Person.new
person.to_model == person  # => true
person.to_key              # => nil
person.to_param            # => nil
```

### _Dirty_

Um objeto se torna "sujo" quando passou por uma ou mais mudanças em seus
atributos e não foi salvo. _`ActiveModel::Dirty`_ fornece a habilidade de 
verificar se um objeto foi modificado ou não. Ele também tem métodos assessores
baseados em atributos. Vamos considerar uma classe _Person_ com os atributos 
_`first_name`_ e _`last_name`_:

```ruby
class Person
  include ActiveModel::Dirty
  define_attribute_methods :first_name, :last_name

  def first_name
    @first_name
  end

  def first_name=(value)
    first_name_will_change!
    @first_name = value
  end

  def last_name
    @last_name
  end

  def last_name=(value)
    last_name_will_change!
    @last_name = value
  end

  def save
    # do save work...
    changes_applied
  end
end
```

#### Consultando diretamente o objeto para listar todos os atributos modificados.

```ruby
person = Person.new
person.changed? # => false

person.first_name = "First Name"
person.first_name # => "First Name"

# retorna _true_ se qualquer atributo possuir mudanças não salvas.
person.changed? # => true

# retorna uma lista de atributos que foram modificados antes de salvar.
person.changed # => ["first_name"]

# retorna um _Hash_ de atributos modificados e seus valores originais.
person.changed_attributes # => {"first_name"=>nil}

# retorna um _Hash_ das modificações, com os nomes dos atributos como chaves, 
# e os valores como um _array_ de valores novos e antigos daquele campo.
person.changes # => {"first_name"=>[nil, "First Name"]}
```

#### Métodos assessores baseados em atributos

Rastreia se um atributo em particular foi modificado ou não.

```ruby
# attr_name_changed?
person.first_name # => "First Name"
person.first_name_changed? # => true
```

Rastreia o valor anterior do atributo.

```ruby
# attr_name_was accessor
person.first_name_was # => nil
```

Rastreia ambos os valores anterior e atual do atributo modificado. Retorna um 
_array_ se foi modificado, caso contrário retorna _nil_

```ruby
# attr_name_change
person.first_name_change # => [nil, "First Name"]
person.last_name_change # => nil
```

### _Validations_

O módulo `ActiveModel::Validations` adiciona a habilidade de validar objetos como no Active Record.

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :email, :token

  validates :name, presence: true
  validates_format_of :email, with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i
  validates! :token, presence: true
end

person = Person.new
person.token = "2b1f325"
person.valid?                        # => false
person.name = 'vishnu'
person.email = 'me'
person.valid?                        # => false
person.email = 'me@vishnuatrai.com'
person.valid?                        # => true
person.token = nil
person.valid?                        # => raises ActiveModel::StrictValidationFailed
```

### Naming

`ActiveModel::Naming` adds a number of class methods which make naming and routing
easier to manage. The module defines the `model_name` class method which
will define a number of accessors using some `ActiveSupport::Inflector` methods.

```ruby
class Person
  extend ActiveModel::Naming
end

Person.model_name.name                # => "Person"
Person.model_name.singular            # => "person"
Person.model_name.plural              # => "people"
Person.model_name.element             # => "person"
Person.model_name.human               # => "Person"
Person.model_name.collection          # => "people"
Person.model_name.param_key           # => "person"
Person.model_name.i18n_key            # => :person
Person.model_name.route_key           # => "people"
Person.model_name.singular_route_key  # => "person"
```

### _Model_

`ActiveModel::Model` permite que uma classe funcione imediatamente com _Action Pack_ e _Action View_.

```ruby
class EmailContact
  include ActiveModel::Model

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # deliver email
    end
  end
end
```

Ao incluir _`ActiveModel::Model`_, você terá funcionalidades como:

- introspecção de nome de um _model_
- conversões
- traduções
- validações

Ele também fornece a habilidade de inicializar um objeto com um _hash_ de 
atributos, como qualquer objeto _Active Record_.

```ruby
email_contact = EmailContact.new(name: 'David',
                                 email: 'david@example.com',
                                 message: 'Hello World')
email_contact.name       # => 'David'
email_contact.email      # => 'david@example.com'
email_contact.valid?     # => true
email_contact.persisted? # => false
```

Qualquer classe que incluir _`ActiveModel::Model`_ pode ser usada com _`form_for`_, 
_`render`_ e quaisquer outros métodos auxiliares da _Action View_, como qualquer 
objeto _Active Record_.

### _Serialization_

_`ActiveModel::Serialization`_ provê serialização básica para seu objeto.
Você precisa declarar um _Hash_ de atributos que contém os atributos que você 
deseja serializar. Atributos devem ser _strings_ e não _symbols_.

```ruby
class Person
  include ActiveModel::Serialization

  attr_accessor :name

  def attributes
    {'name' => nil}
  end
end
```

Agora você pode acessar um _Hash_ serializado do seu objeto usando o método _`serializable_hash`_.

```ruby
person = Person.new
person.serializable_hash   # => {"name"=>nil}
person.name = "Bob"
person.serializable_hash   # => {"name"=>"Bob"}
```

#### _ActiveModel::Serializers_

O _Active Model_ também fornece o módulo _`ActiveModel::Serializers::Json`_ 
para serializar/desserializar _JSON_. Esse módulo inclui automaticamente o 
módulo _`ActiveModel::Serialization`_, discutido previamente.

##### _ActiveModel::Serializers::JSON_

Para usar o _`ActiveModel::Serializers::JSON`_, é necessário apenas alterar o 
módulo que você está incluindo de _`ActiveModel::Serialization`_ para 
`ActiveModel::Serializers::JSON`.

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes
    {'name' => nil}
  end
end
```

O método _`as_json`_, assim como o _`serializable_hash`_, provê um _Hash_ 
representando o _model_.

```ruby
person = Person.new
person.as_json # => {"name"=>nil}
person.name = "Bob"
person.as_json # => {"name"=>"Bob"}
```

Você também pode definir os atributos para um _model_ a partir de um _JSON_.
Porém, você precisa definir um método _`attributes=`_ na sua classe:

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes=(hash)
    hash.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes
    {'name' => nil}
  end
end
```

Agora é possível criar uma instância de _`Person`_ e incluir atributos usando _`from_json`_.

```ruby
json = { name: 'Bob' }.to_json
person = Person.new
person.from_json(json) # => #<Person:0x00000100c773f0 @name="Bob">
person.name            # => "Bob"
```

### Translation

`ActiveModel::Translation` provides integration between your object and the Rails
internationalization (i18n) framework.

```ruby
class Person
  extend ActiveModel::Translation
end
```

With the `human_attribute_name` method, you can transform attribute names into a
more human-readable format. The human-readable format is defined in your locale file(s).

* config/locales/app.pt-BR.yml

  ```yml
  pt-BR:
    activemodel:
      attributes:
        person:
          name: 'Nome'
  ```

```ruby
Person.human_attribute_name('name') # => "Nome"
```

### Lint Tests

`ActiveModel::Lint::Tests` allows you to test whether an object is compliant with
the Active Model API.

* `app/models/person.rb`

    ```ruby
    class Person
      include ActiveModel::Model
    end
    ```

* `test/models/person_test.rb`

    ```ruby
    require 'test_helper'

    class PersonTest < ActiveSupport::TestCase
      include ActiveModel::Lint::Tests

      setup do
        @model = Person.new
      end
    end
    ```

```bash
$ rails test

Run options: --seed 14596

# Running:

......

Finished in 0.024899s, 240.9735 runs/s, 1204.8677 assertions/s.

6 runs, 30 assertions, 0 failures, 0 errors, 0 skips
```

An object is not required to implement all APIs in order to work with
Action Pack. This module only intends to provide guidance in case you want all
features out of the box.

### SecurePassword

`ActiveModel::SecurePassword` provides a way to securely store any
password in an encrypted form. When you include this module, a
`has_secure_password` class method is provided which defines
a `password` accessor with certain validations on it by default.

#### Requirements

`ActiveModel::SecurePassword` depends on [`bcrypt`](https://github.com/codahale/bcrypt-ruby 'BCrypt'),
so include this gem in your `Gemfile` to use `ActiveModel::SecurePassword` correctly.
In order to make this work, the model must have an accessor named `XXX_digest`.
Where `XXX` is the attribute name of your desired password.
The following validations are added automatically:

1. Password should be present.
2. Password should be equal to its confirmation (provided `XXX_confirmation` is passed along).
3. The maximum length of a password is 72 (required by `bcrypt` on which ActiveModel::SecurePassword depends)

#### Examples

```ruby
class Person
  include ActiveModel::SecurePassword
  has_secure_password
  has_secure_password :recovery_password, validations: false

  attr_accessor :password_digest, :recovery_password_digest
end

person = Person.new

# When password is blank.
person.valid? # => false

# When the confirmation doesn't match the password.
person.password = 'aditya'
person.password_confirmation = 'nomatch'
person.valid? # => false

# When the length of password exceeds 72.
person.password = person.password_confirmation = 'a' * 100
person.valid? # => false

# When only password is supplied with no password_confirmation.
person.password = 'aditya'
person.valid? # => true

# When all validations are passed.
person.password = person.password_confirmation = 'aditya'
person.valid? # => true

person.recovery_password = "42password"

person.authenticate('aditya') # => person
person.authenticate('notright') # => false
person.authenticate_password('aditya') # => person
person.authenticate_password('notright') # => false

person.authenticate_recovery_password('42password') # => person
person.authenticate_recovery_password('notright') # => false

person.password_digest # => "$2a$04$gF8RfZdoXHvyTjHhiU4ZsO.kQqV9oonYZu31PRE4hLQn3xM2qkpIy"
person.recovery_password_digest # => "$2a$04$iOfhwahFymCs5weB3BNH/uXkTG65HR.qpW.bNhEjFP3ftli3o5DQC"
```
