**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Active Record Callbacks
=======================

This guide teaches you how to hook into the life cycle of your Active Record
objects.

After reading this guide, you will know:

* The life cycle of Active Record objects.
* How to create callback methods that respond to events in the object life cycle.
* How to create special classes that encapsulate common behavior for your callbacks.

--------------------------------------------------------------------------------

O Ciclo de Vida do Objeto
---------------------

Durante a operação normal de uma aplicação Rails,
objetos podem ser criados, atualizados e destruídos. O *Active Record* fornece *hooks* para este ciclo de vida do objeto para que você possa controlar sua aplicação e seus dados.

*Callbacks* permitem você desencadear a lógica antes ou depois de uma alteração do estado de um objeto.

Visão geral de *Callbacks*
------------------

*Callbacks* são métodos que são chamados em certos momentos do ciclo de vida de um objeto. Com *callbacks* é possível escrever código que rodará sempre que um objeto *Active Record* é criado, salvo, atualizado, deletado, validado ou carregado de um banco de dados.

### Registro de *Callback* 

Para usar os *callbacks* disponíveis, você precisa registrá-los. Você pode implementar os *callbacks* como métodos comuns e usar o método *macro-style* de uma classe para registrá-los como *callbacks*:

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_validation :ensure_login_has_a_value

  private
    def ensure_login_has_a_value
      if login.nil?
        self.login = email unless email.blank?
      end
    end
end
```

Os métodos *macro-style* de uma classe podem também receber um bloco. Considere usar esse estilo se o código dentro do seu bloco é tão curto que cabe em uma linha: 

```ruby
class User < ApplicationRecord
  validates :login, :email, presence: true

  before_create do
    self.name = login.capitalize if name.blank?
  end
end
```

*Callbacks* também podem ser registrados para rodar apenas em certos eventos do ciclo de vida:

```ruby
class User < ApplicationRecord
  before_validation :normalize_name, on: :create

  # :on takes an array as well
  after_validation :set_location, on: [ :create, :update ]

  private
    def normalize_name
      self.name = name.downcase.titleize
    end

    def set_location
      self.location = LocationService.query(self)
    end
end
```

É considerado uma boa prática declarar métodos de *callback* como privados. Se deixados como públicos, podem ser chamados de fora do *model* e violar o princípio de encapsulamento de um objeto.

Callbacks Disponíveis
-------------------

Aqui está uma lista com todos os *Active Record callbacks*, listados na mesma ordem na qual eles serão chamados durante as respectivas operações: 

### Criando um Objeto

* `before_validation`
* `after_validation`
* `before_save`
* `around_save`
* `before_create`
* `around_create`
* `after_create`
* `after_save`
* `after_commit/after_rollback`

### Atualizando um Objeto

* `before_validation`
* `after_validation`
* `before_save`
* `around_save`
* `before_update`
* `around_update`
* `after_update`
* `after_save`
* `after_commit/after_rollback`

### Destruindo um Objeto 

* `before_destroy`
* `around_destroy`
* `after_destroy`
* `after_commit/after_rollback`

WARNING. `after_save` roda tanto na criação quanto na atualização, mas sempre *depois* de *callbacks* mais específicos `after_create` e `after_update`, não importa a ordem que uma chamada macro foi executada.

WARNING. Deve-se tomar cuidado em *callbacks* para evitar atualizar atributos. Por exemplo, evite rodar `update(attribute: "value")` e código semelhante durante *callbacks*. Isto pode alterar o estado do *model* e pode resultar em efeitos colaterais inesperados durante o *commit*. Em vez disto, você deveria tentar atribuir valores no `before_create` ou *callbacks* recentes.

NOTE: Os *callbacks* `before_destroy` devem ser posicionados antes de associações `dependent: :destroy` (ou use a opção `prepend: true`), para garantir que executem antes dos registros serem deletados pelo `dependent: :destroy`.

### `after_initialize` e `after_find`

O *callback* `after_initialize` será chamado sempre que um objeto *Active Record* for instanciado, usando diretamente `new` ou quando um registro é carregado do banco de dados.
Isto pode ser útil para evitar a necessidade de substituir diretamente seu método `initialize` do *Active Record*.

O *callback* `after_find` será chamado sempre que o *Active Record* carregar um registro do banco de dados. `after_find` é chamado antes de `after_initialize` se ambos estiverem definidos. 

Os *callbacks* `after_initialize` e `after_find` não possuem complementos `before_*`, mas podem ser registrados como os outros *callbacks* de *Active Record*.

```ruby
class User < ApplicationRecord
  after_initialize do |user|
    puts "You have initialized an object!"
  end

  after_find do |user|
    puts "You have found an object!"
  end
end

>> User.new
You have initialized an object!
=> #<User id: nil>

>> User.first
You have found an object!
You have initialized an object!
=> #<User id: 1>
```

### `after_touch`

O *callback* `after_touch` será chamado sempre que um objeto *Active Record* for alcançado.

```ruby
class User < ApplicationRecord
  after_touch do |user|
    puts "You have touched an object"
  end
end

>> u = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

>> u.touch
You have touched an object
=> true
```
Pode ser usado junto de `belongs_to`:

```ruby
class Employee < ApplicationRecord
  belongs_to :company, touch: true
  after_touch do
    puts 'An Employee was touched'
  end
end

class Company < ApplicationRecord
  has_many :employees
  after_touch :log_when_employees_or_company_touched

  private
    def log_when_employees_or_company_touched
      puts 'Employee/Company was touched'
    end
end

>> @employee = Employee.last
=> #<Employee id: 1, company_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

# triggers @employee.company.touch
>> @employee.touch
An Employee was touched
Employee/Company was touched
=> true
```

Running Callbacks
-----------------

The following methods trigger callbacks:

* `create`
* `create!`
* `destroy`
* `destroy!`
* `destroy_all`
* `save`
* `save!`
* `save(validate: false)`
* `toggle!`
* `touch`
* `update_attribute`
* `update`
* `update!`
* `valid?`

Additionally, the `after_find` callback is triggered by the following finder methods:

* `all`
* `first`
* `find`
* `find_by`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`

The `after_initialize` callback is triggered every time a new object of the class is initialized.

NOTE: The `find_by_*` and `find_by_*!` methods are dynamic finders generated automatically for every attribute. Learn more about them at the [Dynamic finders section](active_record_querying.html#dynamic-finders)

Skipping Callbacks
------------------

Just as with validations, it is also possible to skip callbacks by using the following methods:

* `decrement!`
* `decrement_counter`
* `delete`
* `delete_all`
* `increment!`
* `increment_counter`
* `update_column`
* `update_columns`
* `update_all`
* `update_counters`

These methods should be used with caution, however, because important business rules and application logic may be kept in callbacks. Bypassing them without understanding the potential implications may lead to invalid data.

Halting Execution
-----------------

As you start registering new callbacks for your models, they will be queued for execution. This queue will include all your model's validations, the registered callbacks, and the database operation to be executed.

The whole callback chain is wrapped in a transaction. If any callback raises an exception, the execution chain gets halted and a ROLLBACK is issued. To intentionally stop a chain use:

```ruby
throw :abort
```

WARNING. Any exception that is not `ActiveRecord::Rollback` or `ActiveRecord::RecordInvalid` will be re-raised by Rails after the callback chain is halted. Raising an exception other than `ActiveRecord::Rollback` or `ActiveRecord::RecordInvalid` may break code that does not expect methods like `save` and `update` (which normally try to return `true` or `false`) to raise an exception.

*Callbacks* Relacionais
--------------------

*Callbacks* trabalham através de relacionamentos dos *models* e podem até ser definidos por eles. Suponha um exemplo onde um usuário tenha muitos artigos. Um artigo de um usuário deve ser apagado se o usuario for apagado. Vamos adicionar um *callback* `after_destroy` para o *model* `User` por meio de seu relacionamento com o *model* `Article`:

```ruby
class User < ApplicationRecord
  has_many :articles, dependent: :destroy
end

class Article < ApplicationRecord
  after_destroy :log_destroy_action

  def log_destroy_action
    puts 'Article destroyed'
  end
end

>> user = User.first
=> #<User id: 1>
>> user.articles.create!
=> #<Article id: 1, user_id: 1>
>> user.destroy
Article destroyed
=> #<User id: 1>
```

Conditional Callbacks
---------------------

As with validations, we can also make the calling of a callback method conditional on the satisfaction of a given predicate. We can do this using the `:if` and `:unless` options, which can take a symbol, a `Proc` or an `Array`. You may use the `:if` option when you want to specify under which conditions the callback **should** be called. If you want to specify the conditions under which the callback **should not** be called, then you may use the `:unless` option.

### Using `:if` and `:unless` with a `Symbol`

You can associate the `:if` and `:unless` options with a symbol corresponding to the name of a predicate method that will get called right before the callback. When using the `:if` option, the callback won't be executed if the predicate method returns false; when using the `:unless` option, the callback won't be executed if the predicate method returns true. This is the most common option. Using this form of registration it is also possible to register several different predicates that should be called to check if the callback should be executed.

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: :paid_with_card?
end
```

### Using `:if` and `:unless` with a `Proc`

It is possible to associate `:if` and `:unless` with a `Proc` object. This option is best suited when writing short validation methods, usually one-liners:

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number,
    if: Proc.new { |order| order.paid_with_card? }
end
```

As the proc is evaluated in the context of the object, it is also possible to write this as:

```ruby
class Order < ApplicationRecord
  before_save :normalize_card_number, if: Proc.new { paid_with_card? }
end
```

### Multiple Conditions for Callbacks

When writing conditional callbacks, it is possible to mix both `:if` and `:unless` in the same callback declaration:

```ruby
class Comment < ApplicationRecord
  after_create :send_email_to_author, if: :author_wants_emails?,
    unless: Proc.new { |comment| comment.article.ignore_comments? }
end
```

### Combining Callback Conditions

When multiple conditions define whether or not a callback should happen, an `Array` can be used. Moreover, you can apply both `:if` and `:unless` to the same callback.

```ruby
class Comment < ApplicationRecord
  after_create :send_email_to_author,
    if: [Proc.new { |c| c.user.allow_send_email? }, :author_wants_emails?],
    unless: Proc.new { |c| c.article.ignore_comments? }
end
```

The callback only runs when all the `:if` conditions and none of the `:unless` conditions are evaluated to `true`.

Callback Classes
----------------

Sometimes the callback methods that you'll write will be useful enough to be reused by other models. Active Record makes it possible to create classes that encapsulate the callback methods, so it becomes very easy to reuse them.

Here's an example where we create a class with an `after_destroy` callback for a `PictureFile` model:

```ruby
class PictureFileCallbacks
  def after_destroy(picture_file)
    if File.exist?(picture_file.filepath)
      File.delete(picture_file.filepath)
    end
  end
end
```

When declared inside a class, as above, the callback methods will receive the model object as a parameter. We can now use the callback class in the model:

```ruby
class PictureFile < ApplicationRecord
  after_destroy PictureFileCallbacks.new
end
```

Note that we needed to instantiate a new `PictureFileCallbacks` object, since we declared our callback as an instance method. This is particularly useful if the callbacks make use of the state of the instantiated object. Often, however, it will make more sense to declare the callbacks as class methods:

```ruby
class PictureFileCallbacks
  def self.after_destroy(picture_file)
    if File.exist?(picture_file.filepath)
      File.delete(picture_file.filepath)
    end
  end
end
```

If the callback method is declared this way, it won't be necessary to instantiate a `PictureFileCallbacks` object.

```ruby
class PictureFile < ApplicationRecord
  after_destroy PictureFileCallbacks
end
```

You can declare as many callbacks as you want inside your callback classes.

*Callbacks* de Transação
---------------------

Existem dois *callbacks* adicionais que são disparados quando se completa uma transação de banco de dados: `after_commit` e `after_rollback`. Estes *callbacks* são muito parecidos com o *callback* `after_save`, exceto que eles não são executados até que as mudanças no banco de dados sejam confirmadas ou desfeitas. Eles são mais úteis quando seus *active record models* precisam de interagir com sistemas externos que não fazem parte da transação do banco de dados.

Considere, por exemplo, o exemplo anterior onde o *model* `PictureFile` precisa de apagar um arquivo depois que um registro correspondente é destruído. Se algo lançar uma exceção depois que o *callback* `after_destroy` for chamado e a transação for desfeita, o arquivo terá sido deletado e o *model* será deixado em um estado inconsistente. Por exemplo, suponha que `picture_file_2` no código abaixo não é valido e o método `save!` lança um erro.

```ruby
PictureFile.transaction do
  picture_file_1.destroy
  picture_file_2.save!
end
```

Usando o *callback* `after_commit` nós podemos responder por esse caso.

```ruby
class PictureFile < ApplicationRecord
  after_commit :delete_picture_file_from_disk, on: :destroy

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

NOTE: A opção `:on` especifica quando um *callback* vai ser disparado. Se você
não fornecer a opção `:on` o *callback* será disparado para cada ação.

Já que usar o *callback* `after_commit` para criar, atualizar ou deletar é
comum, existem *aliases* para as operações:

* `after_create_commit`
* `after_update_commit`
* `after_destroy_commit`

```ruby
class PictureFile < ApplicationRecord
  after_destroy_commit :delete_picture_file_from_disk

  def delete_picture_file_from_disk
    if File.exist?(filepath)
      File.delete(filepath)
    end
  end
end
```

WARNING. Quando uma transação é completada, os *callbacks* `after_commit` ou `after_rollback` são chamados para todos os *models* criados, atualizados ou destruidos em uma transação. No entanto, se uma exceção é lançada em um desses *callbacks*, a exceção vai interromper a execução e quaisquer métodos restantes de `after_commit` ou `after_rollback` _não_ serão executados. Assim sendo, se o código do seu *callback* pode lançar uma exceção, você precisará recuperá-la e tratá-la dentro do *callback* para que outros callbacks possam ser executados.

WARNING. O código executado dentro dos *callbacks* de `after_commit` ou `after_rollback` não está incluido em uma transação.

WARNING. Usando ambos `after_create_commit` e `after_update_commit` no mesmo *model* permitirá somente que o último *callback* definido seja efetuado, sobrepondo todos os outros.

```ruby
class User < ApplicationRecord
  after_create_commit :log_user_saved_to_db
  after_update_commit :log_user_saved_to_db

  private
  def log_user_saved_to_db
    puts 'User was saved to database'
  end
end

# prints nothing
>> @user = User.create

# updating @user
>> @user.save
=> User was saved to database
```

Existe também um *alias* para o usar o *callback* `after_commit`, juntamente, tanto para criar quanto para atualizar:

* `after_save_commit`

```ruby
class User < ApplicationRecord
  after_save_commit :log_user_saved_to_db

  private
  def log_user_saved_to_db
    puts 'User was saved to database'
  end
end

# criando um Usuário
>> @user = User.create
=> User was saved to database

# atualizando o Usuário @user
>> @user.save
=> User was saved to database
```
