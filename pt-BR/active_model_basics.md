**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Básico do _Active Model_
===================

Esse guia deverá prover tudo que você precisa para começar a usar classes de modelo (`models`).
O _Active Model_ permite que o _Action Pack Helpers_ interaja com os objetos ruby. O _Active model_ também auxilia a criação de _ORMs_ (mapeamento de objetos relacionais) para o uso fora do framework Rails.

Após a leitura desse guia você saberá:

* Como um _Active Record_ se comporta.
* Como _Callbacks_ e _Validações_ funcionam.
* Como _serializers_ funcionam.
* Como _Active Model_ integra com o framework de internacionalização (`i18n`) do Rails.

---

O que é _Active Model_?

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
```

```irb
irb> person = Person.new
irb> person.age = 110
irb> person.age_highest?
=> true
irb> person.reset_age
=> 0
irb> person.age_highest?
=> false
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
      # Este método é chamado quando a atualização é chamada em um objeto.
    end
  end

  def reset_me
    # Este método é chamado quando a atualização é chamada em um objeto, quando um retorno de chamada before_update é definida.
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
```

```irb
irb> person = Person.new
irb> person.to_model == person
=> true
irb> person.to_key
=> nil
irb> person.to_param
=> nil
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
    # salva trabalho...
    changes_applied
  end
end
```

#### Consultando o objeto diretamente para obter uma lista de todos os atributos alterados.

```irb
irb> person = Person.new
irb> person.changed?
=> false

irb> person.first_name = "First Name"
irb> person.first_name
=> "First Name"

# Retorna true se algum dos atributos tem mudanças não salvas.
irb> person.changed?
=> true

# Retorna uma lista de atributos que mudaram antes de salvar.
irb> person.changed
=> ["first_name"]

# Retorna um Hash dos atributos que mudaram junto com seu valor original.
irb> person.changed_attributes
=> {"first_name"=>nil}

# Retorna um Hash de mudanças, com o nome dos atributos como chave, e o valor da chave como um array de valores antigos e novos para aquele campo.
irb> person.changes
=> {"first_name"=>[nil, "First Name"]}
```

#### Atributos baseados em métodos de acesso

Rastreia se o atributo específico foi alterado ou não.

```irb
irb> person.first_name
=> "First Name"

# attr_name_changed?
irb> person.first_name_changed?
=> true
```

Rastreia o valor anterior do atributo.

```irb
# attr_name_was accessor
irb> person.first_name_was
=> nil
```

Rastreia o valor anterior e atual do atributo alterado. Retorna um _array_ se
alterado; caso contrário, retorna `nil`.

```irb
# attr_name_change
irb> person.first_name_change
=> [nil, "First Name"]
irb> person.last_name_change
=> nil
```

### Validações

O módulo `ActiveModel::Validations` adiciona a habilidade de validar objetos como no _Active Record_.

```ruby
class Person
  include ActiveModel::Validations

  attr_accessor :name, :email, :token

  validates :name, presence: true
  validates_format_of :email, with: /\A([^\s]+)((?:[-a-z0-9]\.)[a-z]{2,})\z/i
  validates! :token, presence: true
end
```

```irb
irb> person = Person.new
irb> person.token = "2b1f325"
irb> person.valid?
=> false
irb> person.name = 'vishnu'
irb> person.email = 'me'
irb> person.valid?
=> false
irb> person.email = 'me@vishnuatrai.com'
irb> person.valid?
=> true
irb> person.token = nil
irb> person.valid?
ActiveModel::StrictValidationFailed
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

### _Model_

O `ActiveModel::Model` adiciona a capacidade de uma classe trabalhar com o _Action Pack_ e _Action View_ imediatamente.

```ruby
class EmailContact
  include ActiveModel::Model

  attr_accessor :name, :email, :message
  validates :name, :email, :message, presence: true

  def deliver
    if valid?
      # envia email
    end
  end
end
```

Ao incluir o `ActiveModel::Model`, você obtém alguns recursos como:

- introspecção do nome de _model_
- conversões
- traduções
- validações

Também oferece a capacidade de inicializar um objeto com um hash de atributos, muito parecido com qualquer objeto _Active Record_.

```irb
irb> email_contact = EmailContact.new(name: 'David', email: 'david@example.com', message: 'Hello World')
irb> email_contact.name
=> "David"
irb> email_contact.email
=> "david@example.com"
irb> email_contact.valid?
=> true
irb> email_contact.persisted?
=> false
```

Qualquer classe que inclua `ActiveModel::Model` pode ser usada com `form_with`, `render` e quaisquer outros métodos auxiliares do _Action View_, assim como o _Active Record_ objetos.

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

```irb
irb> person = Person.new
irb> person.serializable_hash
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.serializable_hash
=> {"name"=>"Bob"}
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

```irb
irb> person = Person.new
irb> person.as_json
=> {"name"=>nil}
irb> person.name = "Bob"
irb> person.as_json
=> {"name"=>"Bob"}
```

Você também pode definir os atributos para um modelo a partir de uma sequência JSON. No entanto, você precisa definir o método `attribute=` na sua classe:

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

Agora é possível criar uma instância de `Person` e definir atributos usando `from_json`.

```irb
irb> json = { name: 'Bob' }.to_json
irb> person = Person.new
irb> person.from_json(json)
=> #<Person:0x00000100c773f0 @name="Bob">
irb> person.name
=> "Bob"
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

```yaml
pt-BR:
  activemodel:
    attributes:
      person:
        name: "Nome"
```

```ruby
Person.human_attribute_name('name') # => "Nome"
```

### Testes de Lint

O `ActiveModel::Lint::Tests` permite testar se um objeto é compatível com a API do _model_ ativo.

- `app/models/person.rb`

  ```ruby
  class Person
    include ActiveModel::Model
  end
  ```

- `test/models/person_test.rb`

  ```ruby
  require "test_helper"

  class PersonTest < ActiveSupport::TestCase
    include ActiveModel::Lint::Tests

    setup do
      @model = Person.new
    end
  end
  ```

```bash
$ bin/rails test

Run options: --seed 14596

# Running:

......

Finished in 0.024899s, 240.9735 runs/s, 1204.8677 assertions/s.

6 runs, 30 assertions, 0 failures, 0 errors, 0 skips
```

Não é necessário um objeto para implementar todas as APIs para trabalhar com _Action Pack_. Este módulo pretende apenas fornecer orientação caso você queira que todos recursos prontos para uso.

### SecurePassword

O `ActiveModel::SecurePassword` fornece uma maneira de armazenar com segurança qualquer senha de forma criptografada. Quando você inclui este módulo, é fornecido o método da classe `has_secure_password` que define um acessador de `senha` com certas validações por padrão.

#### Requerimentos

O `ActiveModel::SecurePassword` depende de [`bcrypt`](https://github.com/codahale/bcrypt-ruby "BCrypt"),
portanto, inclua esta `gem` no seu `Gemfile` para usar o` ActiveModel::SecurePassword` corretamente.
Para fazer isso funcionar, o _model_ deve ter um acessador chamado `XXX_digest`.
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
```

```irb
irb> person = Person.new

# Quando a senha está em branco.
irb> person.valid?
=> false

# Quando a confirmação não é igual a senha.
irb> person.password = 'aditya'
irb> person.password_confirmation = 'nomatch'
irb> person.valid?
=> false

# Quando o tamanho da senha é maior que 72 caracteres.
irb> person.password = person.password_confirmation = 'a' * 100
irb> person.valid?
=> false

# Quando só a senha é enviada sem a password_confirmation.
irb> person.password = 'aditya'
irb> person.valid?
=> true

# Quando todas as validações foram atendidas.
irb> person.password = person.password_confirmation = 'aditya'
irb> person.valid?
=> true

irb> person.recovery_password = "42password"

irb> person.authenticate('aditya')
=> #<Person> # == person
irb> person.authenticate('notright')
=> false
irb> person.authenticate_password('aditya')
=> #<Person> # == person
irb> person.authenticate_password('notright')
=> false

irb> person.authenticate_recovery_password('42password')
=> #<Person> # == person
irb> person.authenticate_recovery_password('notright')
=> false

irb> person.password_digest
=> "$2a$04$gF8RfZdoXHvyTjHhiU4ZsO.kQqV9oonYZu31PRE4hLQn3xM2qkpIy"
irb> person.recovery_password_digest
=> "$2a$04$iOfhwahFymCs5weB3BNH/uXkTG65HR.qpW.bNhEjFP3ftli3o5DQC"
```
