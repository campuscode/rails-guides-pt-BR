**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Active Record Callbacks
=======================

Este guia ensina como se conectar ao ciclo de vida de seus objetos _Active
Record_.

Depois de ler esse guia, você saberá:

* O ciclo de vida de objetos _Active Record_.
* Como criar métodos de _callback_ que respondem a eventos no ciclo de vida do
  objeto.
* Como criar classes especiais que encapsulam o comportamento comum para seus
  _callbacks_.

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

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_create`][]
* [`around_create`][]
* [`after_create`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]

[`after_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_create
[`after_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_commit
[`after_rollback`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_rollback
[`after_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_save
[`after_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-after_validation
[`around_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_create
[`around_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_save
[`before_create`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_create
[`before_save`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_save
[`before_validation`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/Callbacks/ClassMethods.html#method-i-before_validation

### Atualizando um Objeto

* [`before_validation`][]
* [`after_validation`][]
* [`before_save`][]
* [`around_save`][]
* [`before_update`][]
* [`around_update`][]
* [`after_update`][]
* [`after_save`][]
* [`after_commit`][] / [`after_rollback`][]

[`after_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_update
[`around_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_update
[`before_update`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_update

### Destruindo um Objeto 

* [`before_destroy`][]
* [`around_destroy`][]
* [`after_destroy`][]
* [`after_commit`][] / [`after_rollback`][]

[`after_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_destroy
[`around_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-around_destroy
[`before_destroy`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-before_destroy

WARNING. `after_save` roda tanto na criação quanto na atualização, mas sempre *depois* de *callbacks* mais específicos `after_create` e `after_update`, não importa a ordem que uma chamada macro foi executada.

WARNING. Evite atualizar ou salvar atributos em *callbacks*. Por exemplo, não chame `update(attribute: "value")` em um *callback*. Isso pode alterar o estado do *model* e resultar em efeitos colaterais inesperados durante a confirmação. Em vez disso, você pode atribuir valores diretamente com segurança (por exemplo, `self.attribute = "value"`) em `before_create` / `before_update` ou *callbacks* anteriores.

NOTE: Os *callbacks* `before_destroy` devem ser posicionados antes de associações `dependent: :destroy` (ou use a opção `prepend: true`), para garantir que executem antes dos registros serem deletados pelo `dependent: :destroy`.

### `after_initialize` e `after_find`

O *callback* [`after_initialize`][] será chamado sempre que um objeto *Active Record* for instanciado, usando diretamente `new` ou quando um registro é carregado do banco de dados.
Isto pode ser útil para evitar a necessidade de substituir diretamente seu método `initialize` do *Active Record*.

O *callback* [`after_find`][] será chamado sempre que o *Active Record* carregar um registro do banco de dados. `after_find` é chamado antes de `after_initialize` se ambos estiverem definidos. 

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
```

```irb
irb> User.new
You have initialized an object!
=> #<User id: nil>

irb> User.first
You have found an object!
You have initialized an object!
=> #<User id: 1>
```

[`after_find`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_find
[`after_initialize`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_initialize

### `after_touch`

O *callback* [`after_touch`][] será chamado sempre que um objeto *Active Record* for alcançado.

```ruby
class User < ApplicationRecord
  after_touch do |user|
    puts "You have touched an object"
  end
end
```

```irb
irb> u = User.create(name: 'Kuldeep')
=> #<User id: 1, name: "Kuldeep", created_at: "2013-11-25 12:17:49", updated_at: "2013-11-25 12:17:49">

irb> u.touch
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
```

```irb
irb> @employee = Employee.last
=> #<Employee id: 1, company_id: 1, created_at: "2013-11-25 17:04:22", updated_at: "2013-11-25 17:05:05">

irb> @employee.touch # também executa @employee.company.touch
An Employee was touched
Employee/Company was touched
=> true
```

[`after_touch`]: https://api.rubyonrails.org/classes/ActiveRecord/Callbacks/ClassMethods.html#method-i-after_touch

Executando *Callbacks*
-----------------

Os métodos a seguir acionam *callbacks*:

* `create`
* `create!`
* `destroy`
* `destroy!`
* `destroy_all`
* `destroy_by`
* `save`
* `save!`
* `save(validate: false)`
* `toggle!`
* `touch`
* `update_attribute`
* `update`
* `update!`
* `valid?`

Adicionalmente, o *callback* `after_find` é acionado pelos seguintes métodos de localização:

* `all`
* `first`
* `find`
* `find_by`
* `find_by_*`
* `find_by_*!`
* `find_by_sql`
* `last`

O *callback* `after_initialize`  é acionado toda vez que um novo objeto da classe é inicializado. 

NOTE: Os métodos `find_by_*` e `find_by_*!` são localizadores dinâmicos gerados automaticamente para cada atributo. Aprenda mais sobre eles na [seção de Localizadores Dinâmicos](active_record_querying.html#localizadores-dinamicos) 

Ignorando *Callbacks*
------------------

Assim como nas validações, também é possível ignorar os *callbacks* usando os seguintes métodos:

* `decrement!`
* `decrement_counter`
* `delete`
* `delete_all`
* `delete_by`
* `increment!`
* `increment_counter`
* `insert`
* `insert!`
* `insert_all`
* `insert_all!`
* `touch_all`
* `update_column`
* `update_columns`
* `update_all`
* `update_counters`
* `upsert`
* `upsert_all`

Contudo, esses métodos devem ser usados com cautela, porque regras de negócio importantes e lógica da aplicação podem ser mantidos nos *callbacks*. Contorná-los sem entender as potenciais implicações pode levar a dados inválidos.

Interrompendo uma Execução
-----------------

Quando você começar a registrar novos *callbacks* para seus *models*, eles serão enfileirados para a execução. Esta fila incluirá todas as validações do seu *model*, os *callbacks* registrados e a operação do banco de dados a ser executada.

Toda a cadeia do *callback* é empacotada em uma transação. Se algum *callback* lança uma exceção, a cadeia de execução é interrompida e um *ROLLBACK* é emitido. Para interromper intencionalmente uma cadeia, use:

```ruby
throw :abort
```

WARNING: Qualquer exceção que não seja `ActiveRecord::Rollback` ou `ActiveRecord::RecordInvalid` serão lançadas novamente pelo Rails após a cadeia do *callback* ser interrompida. Lançar uma outra exceção que não `ActiveRecord::Rollback` ou `ActiveRecord::RecordInvalid` pode quebrar um código que não espera por métodos como `save` ou `update` (os quais normalmente tentam retornar `true` ou `false`) para lançar uma exceção.

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
```

```irb
irb> user = User.first
=> #<User id: 1>
irb> user.articles.create!
=> #<Article id: 1, user_id: 1>
irb> user.destroy
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

Classes *Callback*
----------------

Em algumas situações, os métodos de *Callback* que iremos escrever serão úteis para serem reutilizados por outros *models*. O *Active Record* possibilita a criação de classes que encapsulam os métodos *callback* , para que eles possam ser reutilizados.

Aqui está um exemplo onde criamos uma classe com um *callback* `after_destroy` para o *model* `PictureFile`:

```ruby
class PictureFileCallbacks
  def after_destroy(picture_file)
    if File.exist?(picture_file.filepath)
      File.delete(picture_file.filepath)
    end
  end
end
```

Quando declaramos dentro da classe, como foi feito acima, os métodos *callback* irão receber o *model* como parâmetro. Agora poderemos usar a classe *callback* no *model*:

```ruby
class PictureFile < ApplicationRecord
  after_destroy PictureFileCallbacks.new
end
```

Perceba que precisamos instanciar um novo objeto chamado `PictureFileCallbacks`, já que declaramos nosso *callback* como um método de instância. Particularmente, isso é útil se os *callbacks* fazem uso do estado do objeto instanciado. Porém fará mais sentido declarar os *callbacks* como métodos de classe com mais frequência:

```ruby
class PictureFileCallbacks
  def self.after_destroy(picture_file)
    if File.exist?(picture_file.filepath)
      File.delete(picture_file.filepath)
    end
  end
end
```

Se o método *callback* é declarado dessa forma, não será necessário instanciar o objeto `PictureFileCallbacks`

```ruby
class PictureFile < ApplicationRecord
  after_destroy PictureFileCallbacks
end
```

Você pode declarar dentro de suas classes *callback* quantos *callback* achar necessário.

*Callbacks* de Transação
---------------------

Existem dois *callbacks* adicionais que são disparados quando se completa uma transação de banco de dados: [`after_commit`][] e [`after_rollback`][]. Estes *callbacks* são muito parecidos com o *callback* `after_save`, exceto que eles não são executados até que as mudanças no banco de dados sejam confirmadas ou desfeitas. Eles são mais úteis quando seus *active record models* precisam de interagir com sistemas externos que não fazem parte da transação do banco de dados.

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

* [`after_create_commit`][]
* [`after_update_commit`][]
* [`after_destroy_commit`][]

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
```

```irb
irb> @user = User.create # não imprime nada

irb> @user.save # atualizando @user
User was saved to database
```

Existe também um *alias* para o usar o *callback* `after_commit`, juntamente, tanto para criar quanto para atualizar:

* [`after_save_commit`][]

```ruby
class User < ApplicationRecord
  after_save_commit :log_user_saved_to_db

  private
  def log_user_saved_to_db
    puts 'User was saved to database'
  end
end
```

```irb
irb> @user = User.create # criando um Usuário
User was saved to database

irb> @user.save # atualizando o Usuário @user
User was saved to database
```

[`after_create_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_create_commit
[`after_destroy_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_destroy_commit
[`after_save_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_save_commit
[`after_update_commit`]: https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#method-i-after_update_commit
