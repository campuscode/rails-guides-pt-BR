**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Básico de *Active Model*
===================
Esse guia deverá prover tudo que você precisa para começar a usar classes de modelo (`models`).
O *Active Model* permite que o *Ation Pack Helpers* interaja com os objetos ruby. O *Active model* também auxilia a criação de *ORMs* (mapeamento de objetos relacionais) para o uso fora do framework Rails.

Após a leitura desse guia você saberá:
* Como um *Active Record* se comporta.
* Como Callbacks e Validações funcionam.
* Como serializers funcionam.
* Como *Active Model* integra com o framework de internacionalização(`i18n`) do Rails.

--------------------------------------------------------------------------------

Introdução
------------

O Active Model é uma biblioteca que contém vários módulos utilizados para desenvolvimento de classes que precisam de algumas funções (`features`) existentes no Active Record.

Alguns desses módulos serão explicados abaixo.

### Métodos de Atributo

O `ActiveModel::AttributeMethods`, módulo que pode adicionar prefixos e sufixos customizados nos metodos de uma classe.
Isso é feito pela definição dos prefixos e sufixos e quais métodos no objeto que vai utilizá-los.

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

### Callbacks

`ActiveModel::Callbacks` trazem os `callbacks` no padrão do Active Record. Isso provê a habilidade de definir o callback que rodará no tempo apropriado.
Após definir os callbacks, você pode envolvê-los com métodos customizados antes, depois e durante.

```ruby
class Person
  extend ActiveModel::Callbacks

  define_model_callbacks :update

  before_update :reset_me

  def update
    run_callbacks(:update) do
      # This method is called when update is called on an object.
    end
  end

  def reset_me
    # This method is called when update is called on an object as a before_update callback is defined.
  end
end
```

### Conversão

Se a classe define os métodos `persisted?` e `id`, então você pode incluir o módulo `ActiveModel::Conversion` naquela classe e chamar os métodos de conversão do Rails nos objetos daquela classe.

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

### Sujeira

Um objeto se torna sujo quando ele passa por uma ou mais mudanças nos seus atributos e isso não foi salvo. O `ActiveModel::Dirty` te concede a habilidade de checar quando um objeto foi alterado ou não. Também possui atributos baseados em métodos de acesso.
Vamos considerar a classe `Person` com os atributos `first_name` e `last_name`:

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

#### Consultando o objeto diretamente para obter uma lista de todos os atributos alterados.

```ruby
person = Person.new
person.changed? # => false

person.first_name = "First Name"
person.first_name # => "First Name"

# returns true if any of the attributes have unsaved changes.
person.changed? # => true

# returns a list of attributes that have changed before saving.
person.changed # => ["first_name"]

# returns a Hash of the attributes that have changed with their original values.
person.changed_attributes # => {"first_name"=>nil}

# returns a Hash of changes, with the attribute names as the keys, and the
# values as an array of the old and new values for that field.
person.changes # => {"first_name"=>[nil, "First Name"]}
```

#### Atributos baseados em métodos de acesso

Acompanhe se o atributo específico foi alterado ou não.

```ruby
# attr_name_changed?
person.first_name # => "First Name"
person.first_name_changed? # => true
```

Track the previous value of the attribute.

```ruby
# attr_name_was accessor
person.first_name_was # => nil
```

Track both previous and current value of the changed attribute. Returns an array
if changed, otherwise returns nil.

```ruby
# attr_name_change
person.first_name_change # => [nil, "First Name"]
person.last_name_change # => nil
```

### Validações

O módulo `ActiveModel::Validations` adiciona a habilidade de validar objetos como no *Active Record*.

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
### Nomeação

`ActiveModel::Naming` adiciona vários métodos de classe que tornam a nomeação e o roteamento mais fácil de administrar. O módulo define o método da classe `model_name` que definirá vários acessadores usando alguns métodos do `ActiveSupport::Inflector`.


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
### *Model*

O `ActiveModel::Model` adiciona a capacidade de uma classe trabalhar com o *Action Pack* e *Action View* imediatamente.


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
Ao incluir o `ActiveModel::Model`, você obtém alguns recursos como:

- introspecção do nome de *model*
- conversões
- traduções
- validações

Também oferece a capacidade de inicializar um objeto com um hash de atributos, muito parecido com qualquer objeto *Active Record*.

```ruby
email_contact = EmailContact.new(name: 'David',
                                 email: 'david@example.com',
                                 message: 'Hello World')
email_contact.name       # => 'David'
email_contact.email      # => 'david@example.com'
email_contact.valid?     # => true
email_contact.persisted? # => false
```

Qualquer classe que inclua `ActiveModel::Model` pode ser usada com `form_for`, `render` e quaisquer outros métodos auxiliares do *Action View*, assim como o *Active Record* objetos.

### Serialização

O `ActiveModel::Serialization` fornece serialização básica para o seu objeto. Você precisa declarar um Hash de atributos que contém os atributos que deseja serializar. Os atributos devem ser cadeias, não símbolos.

```ruby
class Person
  include ActiveModel::Serialization

  attr_accessor :name

  def attributes
    {'name' => nil}
  end
end
```
Agora você pode acessar um Hash serializado do seu objeto usando o método `serializable_hash`.

```ruby
person = Person.new
person.serializable_hash   # => {"name"=>nil}
person.name = "Bob"
person.serializable_hash   # => {"name"=>"Bob"}
```

#### ActiveModel::Serializers

O Active Model também fornece o módulo `ActiveModel::Serializers::JSON` para serialização / desserialização JSON. Este módulo inclui automaticamente o módulo `ActiveModel::Serialization` discutido anteriormente.

##### ActiveModel::Serializers::JSON

Para usar o `ActiveModel::Serializers::JSON`, você só precisa alterar o módulo que você está incluindo de `ActiveModel::Serialization` para` ActiveModel::Serializers::JSON`.

```ruby
class Person
  include ActiveModel::Serializers::JSON

  attr_accessor :name

  def attributes
    {'name' => nil}
  end
end
```
O método `as_json`, semelhante ao` serializable_hash`, fornece um Hash representando o modelo.


```ruby
person = Person.new
person.as_json # => {"name"=>nil}
person.name = "Bob"
person.as_json # => {"name"=>"Bob"}
```
Você também pode definir os atributos para um modelo a partir de uma sequência JSON. No entanto, você precisa definir o método `attribute =` na sua classe:

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
Agora é possível criar uma instância de `Person` e definir atributos usando` from_json`.

```ruby
json = { name: 'Bob' }.to_json
person = Person.new
person.from_json(json) # => #<Person:0x00000100c773f0 @name="Bob">
person.name            # => "Bob"
```

### Tradução

O `ActiveModel::Translation` fornece integração entre seu objeto e o Rails internacionalização (i18n).

```ruby
class Person
  extend ActiveModel::Translation
end
```

Com o método `human_attribute_name`, você pode transformar nomes de atributos em um formato mais legível por humanos. O formato legível por humanos é definido nos seus arquivos de localidade.

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

O `ActiveModel::Lint::Tests` permite testar se um objeto é compatível com a API do *model* ativo.

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

Não é necessário um objeto para implementar todas as APIs para trabalhar com *Action Pack*. Este módulo pretende apenas fornecer orientação caso você queira que todos recursos prontos para uso.

### SecurePassword

O `ActiveModel::SecurePassword` fornece uma maneira de armazenar com segurança qualquer senha de forma criptografada. Quando você inclui este módulo, é fornecido o método da classe `has_secure_password` que define um acessador de `senha` com certas validações por padrão.

#### Requerimentos

O `ActiveModel::SecurePassword` depende de [` bcrypt`](https://github.com/codahale/bcrypt-ruby 'BCrypt'),
portanto, inclua esta `gem` no seu `Gemfile` para usar o` ActiveModel::SecurePassword` corretamente.
Para fazer isso funcionar, o *model* deve ter um acessador chamado `XXX_digest`.
Onde `XXX` é o nome do atributo da sua senha desejada.
As seguintes validações são adicionadas automaticamente:

1. A senha deve estar presente.
2. A senha deve ser igual à sua confirmação (desde que `XXX_confirmation` seja passada adiante).
3. O tamanho máximo de uma senha é 72 (exigido pelo `bcrypt` do qual o ActiveModel::SecurePassword depende)

#### Exemplos


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
