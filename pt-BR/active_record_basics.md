**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Básico do Active Record
====================

Este guia é uma introdução ao *Active Record*.

Depois de ler este guia, você vai saber:

* O que são Mapeamento Objeto-Relacional (*Object Relational Mapping*) e Active Record, e
como eles são utilizados no Rails.
* Como o *Active Record* se encaixa no paradigma *Model-View-Controller*.
* Como usar *models* do *Active Record* para manipular dados armazenados em
  bancos de dados relacionais.
* Convenções de nomes no *schema* do *Active Record*.
* Os conceitos de migrações em bancos de dados, validações e *callbacks*.

--------------------------------------------------------------------------------

O que é Active Record?
----------------------

*Active Record* é o M em [MVC](https://pt.wikipedia.org/wiki/MVC) - o
*model* - que é a camada do sistema responsável pela representação da lógica e
dados de negócio. O *Active Record* facilita a criação e uso de objetos de
negócio cujos dados precisam ser persistidos num banco. Essa é uma implementação
do padrão do *Active Record* que por si só é a descrição de um sistema de
Mapeamento Objeto-Relacional (*Object Relational Mapping*).

### O Padrão Active Record

[O *Active Record* foi descrito por Martin Fowler](https://www.martinfowler.com/eaaCatalog/activeRecord.html)
no seu livro *Patterns of Enterprise Application Architecture*. No *Active
Record*, objetos possuem ambos dados persistentes e comportamento que opera
nesse dado. A filosofia do *Active Record* consiste em assegurar que lógica de acesso a dados seja
parte do objeto, e que o uso deste objeto vai permitir deduzir como escrever e ler o
banco de dados.

### Mapeamento Objeto-Relacional (*Object Relational Mapping*)

[Mapeamento
Objeto-Relacional](https://pt.wikipedia.org/wiki/Mapeamento_objeto-relacional),
comumente referido na sua abreviação ORM, é a técnica que conecta os objetos de
uma aplicação a tabelas em uma tabela de um banco de dados relacional de um sistema de
gerenciamento. Usando ORM, as propriedades e relações entre objetos e a
aplicação podem facilmente ser armazenadas e recuperadas do banco de dados sem a
necessidade de escrever comandos SQL diretamente e com menos código de acesso ao
banco de maneira geral.

NOTE: Conhecimentos básicos de sistemas de gerenciamento de bancos de dados
relacionais (sigla em inglês: RDBMS) e *structured query language* (SQL) são
úteis para compreender inteiramente o *Active Record*. Por favor, refira a [este tutorial](https://www.w3schools.com/sql/default.asp) (ou [este](http://www.sqlcourse.com/)) ou estude por outros meios se quiser aprender mais.

### Active Record como um Framework ORM

Active Record fornece diversos mecanismos, sendo o mais importante a habilidade
de:

* Representar *models* e seus dados.
* Representar associações entre estes *models*.
* Representar hierarquia de heranças pelos *models*.
* Validar *models* antes que sejam persistidos no banco de dados.
* Executar operações nos bancos de dados de maneira orientada a objetos.

Convention over Configuration in Active Record
----------------------------------------------

When writing applications using other programming languages or frameworks, it
may be necessary to write a lot of configuration code. This is particularly true
for ORM frameworks in general. However, if you follow the conventions adopted by
Rails, you'll need to write very little configuration (in some cases no
configuration at all) when creating Active Record models. The idea is that if
you configure your applications in the very same way most of the time then this
should be the default way. Thus, explicit configuration would be needed
only in those cases where you can't follow the standard convention.

### Naming Conventions

By default, Active Record uses some naming conventions to find out how the
mapping between models and database tables should be created. Rails will
pluralize your class names to find the respective database table. So, for
a class `Book`, you should have a database table called **books**. The Rails
pluralization mechanisms are very powerful, being capable of pluralizing (and
singularizing) both regular and irregular words. When using class names composed
of two or more words, the model class name should follow the Ruby conventions,
using the CamelCase form, while the table name must contain the words separated
by underscores. Examples:

* Model Class - Singular with the first letter of each word capitalized (e.g.,
`BookClub`).
* Database Table - Plural with underscores separating words (e.g., `book_clubs`).

| Model / Class    | Table / Schema |
| ---------------- | -------------- |
| `Article`        | `articles`     |
| `LineItem`       | `line_items`   |
| `Deer`           | `deers`        |
| `Mouse`          | `mice`         |
| `Person`         | `people`       |


### Schema Conventions

Active Record uses naming conventions for the columns in database tables,
depending on the purpose of these columns.

* **Foreign keys** - These fields should be named following the pattern
  `singularized_table_name_id` (e.g., `item_id`, `order_id`). These are the
  fields that Active Record will look for when you create associations between
  your models.
* **Primary keys** - By default, Active Record will use an integer column named
  `id` as the table's primary key (`bigint` for PostgreSQL and MySQL, `integer`
  for SQLite). When using [Active Record Migrations](active_record_migrations.html)
  to create your tables, this column will be automatically created.

There are also some optional column names that will add additional features
to Active Record instances:

* `created_at` - Automatically gets set to the current date and time when the
  record is first created.
* `updated_at` - Automatically gets set to the current date and time whenever
  the record is created or updated.
* `lock_version` - Adds [optimistic
  locking](https://api.rubyonrails.org/classes/ActiveRecord/Locking.html) to
  a model.
* `type` - Specifies that the model uses [Single Table
  Inheritance](https://api.rubyonrails.org/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance).
* `(association_name)_type` - Stores the type for
  [polymorphic associations](association_basics.html#polymorphic-associations).
* `(table_name)_count` - Used to cache the number of belonging objects on
  associations. For example, a `comments_count` column in an `Article` class that
  has many instances of `Comment` will cache the number of existent comments
  for each article.

NOTE: While these column names are optional, they are in fact reserved by Active Record. Steer clear of reserved keywords unless you want the extra functionality. For example, `type` is a reserved keyword used to designate a table using Single Table Inheritance (STI). If you are not using STI, try an analogous keyword like "context", that may still accurately describe the data you are modeling.

Criando Models do Active Record
-----------------------------

É muito fácil criar *models* do *Active Record*. Tudo que você precisa fazer é
subclassificar a classe `ApplicationRecord` e estará tudo pronto:  

```ruby
class Product < ApplicationRecord
end
```

Isso criará o *model* `Product`, mapeado em uma tabela `products` na base de dados. Fazendo isso, você também
possuirá a habilidade de mapear as colunas de cada linha da tabela com os atributos das instâncias do seu 
*model*. Suponha que a tabela `products` foi criada usando uma declaração SQL (ou uma de suas extensões) como:

```sql
CREATE TABLE products (
   id int(11) NOT NULL auto_increment,
   name varchar(255),
   PRIMARY KEY  (id)
);
```

O esquema acima declara uma tabela com duas colunas: `id` e `name`. Cada uma das 
linhas dessa tabela representa um certo produto com dois parâmetros. Portanto,
você será capaz de escrever códigos como o seguinte:

```ruby
p = Product.new
p.name = "Some Book"
puts p.name # "Some Book"
```

Sobrepondo Conveções de Nomes
---------------------------------

E se você precisar seguir convenções diferentes ou usar sua aplicação
Rails com um banco de dados legado? Sem problemas, você pode facilmente sobrepor
as convenções padrão.

`ApplicationRecord` herda de `ActiveRecord::Base`, que define vários métodos
úteis. Você pode usar o método `ActiveRecord::Base.table_name=` para especificar
o nome da tabela que deve ser usada:

```ruby
class Product < ApplicationRecord
  self.table_name = "my_products"
end
```

Se assim o fizer, você tem que definir manualmente o nome da classe que hospeda
as *fixtures* (my_products.yml) usando o método `set_fixture_class` na definição
do seu teste:

```ruby
class ProductTest < ActiveSupport::TestCase
  set_fixture_class my_products: Product
  fixtures :my_products
  ...
end
```

É possível sobrepor a coluna que deve ser usada como chave primária da tabela
usando o método `ActiveRecord::Base.primary_key=` method:

```ruby
class Product < ApplicationRecord
  self.primary_key = "product_id"
end
```

NOTE: O *Active Record* não suporta o uso de colunas que não são do tipo chave
primária nomeadas `id`.

CRUD: Reading and Writing Data
------------------------------

CRUD is an acronym for the four verbs we use to operate on data: **C**reate,
**R**ead, **U**pdate and **D**elete. Active Record automatically creates methods
to allow an application to read and manipulate data stored within its tables.

### Create

Active Record objects can be created from a hash, a block, or have their
attributes manually set after creation. The `new` method will return a new
object while `create` will return the object and save it to the database.

For example, given a model `User` with attributes of `name` and `occupation`,
the `create` method call will create and save a new record into the database:

```ruby
user = User.create(name: "David", occupation: "Code Artist")
```

Using the `new` method, an object can be instantiated without being saved:

```ruby
user = User.new
user.name = "David"
user.occupation = "Code Artist"
```

A call to `user.save` will commit the record to the database.

Finally, if a block is provided, both `create` and `new` will yield the new
object to that block for initialization:

```ruby
user = User.new do |u|
  u.name = "David"
  u.occupation = "Code Artist"
end
```

### Read

Active Record provides a rich API for accessing data within a database. Below
are a few examples of different data access methods provided by Active Record.

```ruby
# return a collection with all users
users = User.all
```

```ruby
# return the first user
user = User.first
```

```ruby
# return the first user named David
david = User.find_by(name: 'David')
```

```ruby
# find all users named David who are Code Artists and sort by created_at in reverse chronological order
users = User.where(name: 'David', occupation: 'Code Artist').order(created_at: :desc)
```

You can learn more about querying an Active Record model in the [Active Record
Query Interface](active_record_querying.html) guide.

### Update

Once an Active Record object has been retrieved, its attributes can be modified
and it can be saved to the database.

```ruby
user = User.find_by(name: 'David')
user.name = 'Dave'
user.save
```

A shorthand for this is to use a hash mapping attribute names to the desired
value, like so:

```ruby
user = User.find_by(name: 'David')
user.update(name: 'Dave')
```

This is most useful when updating several attributes at once. If, on the other
hand, you'd like to update several records in bulk, you may find the
`update_all` class method useful:

```ruby
User.update_all "max_login_attempts = 3, must_change_password = 'true'"
```

### Delete

Likewise, once retrieved an Active Record object can be destroyed which removes
it from the database.

```ruby
user = User.find_by(name: 'David')
user.destroy
```

If you'd like to delete several records in bulk, you may use `destroy_by`
or `destroy_all` method:

```ruby
# find and delete all users named David
User.destroy_by(name: 'David')

# delete all users
User.destroy_all
```

Validations
-----------

Active Record allows you to validate the state of a model before it gets written
into the database. There are several methods that you can use to check your
models and validate that an attribute value is not empty, is unique and not
already in the database, follows a specific format, and many more.

Validation is a very important issue to consider when persisting to the database, so
the methods `save` and `update` take it into account when
running: they return `false` when validation fails and they don't actually
perform any operations on the database. All of these have a bang counterpart (that
is, `save!` and `update!`), which are stricter in that
they raise the exception `ActiveRecord::RecordInvalid` if validation fails.
A quick example to illustrate:

```ruby
class User < ApplicationRecord
  validates :name, presence: true
end

user = User.new
user.save  # => false
user.save! # => ActiveRecord::RecordInvalid: Validation failed: Name can't be blank
```

You can learn more about validations in the [Active Record Validations
guide](active_record_validations.html).

Callbacks
---------

Os *callbacks* de um *Active Record* permitem que você vincule códigos para
alguns eventos no ciclo de vida de seus modelos. Isso permite que você adicione
comportamentos para seus modelos executando códigos de forma transparente quando
estes eventos acontecem, como quando você cria um novo registro, atualiza, destrói,
e outros. Você pode aprender mais sobre *callbacks* no 
[Guia de *callbacks* do *Active Record*](active_record_callbacks.html).

Migrations
----------

Rails provides a domain-specific language for managing a database schema called
migrations. Migrations are stored in files which are executed against any
database that Active Record supports using `rake`. Here's a migration that
creates a table:

```ruby
class CreatePublications < ActiveRecord::Migration[5.0]
  def change
    create_table :publications do |t|
      t.string :title
      t.text :description
      t.references :publication_type
      t.integer :publisher_id
      t.string :publisher_type
      t.boolean :single_issue

      t.timestamps
    end
    add_index :publications, :publication_type_id
  end
end
```

Rails keeps track of which files have been committed to the database and
provides rollback features. To actually create the table, you'd run `rails db:migrate`
and to roll it back, `rails db:rollback`.

Note that the above code is database-agnostic: it will run in MySQL,
PostgreSQL, Oracle, and others. You can learn more about migrations in the
[Active Record Migrations guide](active_record_migrations.html).
