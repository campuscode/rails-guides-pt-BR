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

CRUD: Lendo e Escrevendo Dados
------------------------------

CRUD é um acrônimo para os quatro verbos que utilizamos na operação dos dados: ***C**reate* (criar), 
***R**ead* (ler, consultar), ***U**pdate* (atualizar) e ***D**elete* (deletar, destruir). O *Active Record*
criará, automaticamente, métodos que permitem uma aplicação ler e manipular dados armazenados em suas tabelas.

### *Create*

Os objetos do *Active Record* podem ser criados a partir de um *hash*, um bloco ou 
ter seus atributos definidos manualmente após a criação. O método `new` retornará 
um novo objeto, enquanto `create` retornará o objeto e o salvará no banco de dados.

Por exemplo, dado um *model* `User` com os atributos `name` e `occupation`, 
chamando o método `create` criará e salvará um novo registro no banco de dados:

```ruby
user = User.create(name: "David", occupation: "Code Artist")
```

Usando o método `new`, um objeto pode ser instanciado sem ser salvo:

```ruby
user = User.new
user.name = "David"
user.occupation = "Code Artist"
```

Uma chamada para `user.save` salvará o registro no banco de dados.

Finalmente, se um bloco for fornecido, ambos `create` e `new` passarão 
o novo objeto para aquele bloco executar a inicialização:

```ruby
user = User.new do |u|
  u.name = "David"
  u.occupation = "Code Artist"
end
```

### *Read*

O *Active Record* fornece uma API rica para acessar dados no banco de dados. Abaixo 
temos alguns exemplos de diferentes métodos para acessar os dados fornecidos pelo
*Active Record*.

```ruby
# retorna uma coleção com todos os usuários
users = User.all
```

```ruby
# retorna o primeiro usuário da lista
user = User.first
```

```ruby
# retorna o primeiro usuário com o nome David
david = User.find_by(name: 'David')
```

```ruby
# encontra todos os usuários com o nome David que são Code Artists e os ordena por created_at em ordem cronológica inversa
users = User.where(name: 'David', occupation: 'Code Artist').order(created_at: :desc)
```

Você pode aprender mais sobre como consultar um *model* do *Active Record* no guia 
[Active Record
Query Interface](active_record_querying.html).

### *Update*

Uma vez que o objeto do *Active Record* for recuperado, seus atributos podem
ser modificados e salvos no banco de dados.

```ruby
user = User.find_by(name: 'David')
user.name = 'Dave'
user.save
```

Um atalho para isso seria usar um *hash* mapeando o nome dos atributos para o valor
desejado, como a seguir:

```ruby
user = User.find_by(name: 'David')
user.update(name: 'Dave')
```

Isto é mais útil quando atualizamos diversos atributos de uma vez. Se, por outro lado, 
você gostaria de atualizar diversos registros em massa, você pode achar o método de
classe `update_all` útil:

```ruby
User.update_all "max_login_attempts = 3, must_change_password = 'true'"
```

### *Delete*

Da mesma forma, uma vez recuperado um objeto do *Active Record*, o mesmo pode ser
destruído, o que o remove do banco de dados.

```ruby
user = User.find_by(name: 'David')
user.destroy
```

Se você deseja excluir diversos registros em massa, você pode utilizar os métodos
`destroy_by` ou `destroy_all`:

```ruby
# encontra e deleta todos os usuários com o nome David
User.destroy_by(name: 'David')

# deleta todos os usuários
User.destroy_all
```

Validações
-----------

O *Active Record* permite que você valide o estado de um *model* antes que ele
seja gravado no banco de dados. Existem diversos métodos que você pode usar para
verificar seus *models* e validar que o valor de um atributo não é vazio, é único
e já não existe no banco de dados, segue um formato específico, e muito mais.

A validação é uma questão muito importante a se considerar quando se está persistindo
no banco de dados, então os métodos `save` e `update` levam isso em conta quando executados:
eles retornam `false` quando a validação falha e eles de fato não performam nenhuma
operação no banco de dados. Eles tem uma versão com *bang* (exclamação) (que são `save!`
e `update!`), que são mais rigorosos e retornam a exceção `ActiveRecord::RecordInvalid`
se a validação falha.
Um rápido exemplo para ilustrar:

```ruby
class User < ApplicationRecord
  validates :name, presence: true
end

user = User.new
user.save  # => false
user.save! # => ActiveRecord::RecordInvalid: Validation failed: Name can't be blank
```

Você pode aprender mais sobre validações no [Guia de Validaçes de Active Record (em inglês)](active_record_validations.html).

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

O Rails fornece uma Linguagem de Domínio Específico (DSL) para gerenciar o *schema* do banco de
dados, chamada de *migrations*. As *Migrations* são armazenadas em arquivos que são executados
diante de qualquer banco de dados que o *Active Record* suporta utilizando o `rake`. Aqui está
uma *migration* que cria uma tabela: 

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

O Rails mantém o controle de quais arquivos foram enviados ao banco de dados e fornece
ferramentas de reversão. Para realmente criar uma tabela, você deverá executar
`rails db:migrate` e para reverter, `rails db:rollback`

Observe que o código acima é agnóstico em relação ao banco de dados: irá rodar em MySQL,
PostgreSQL, Oracle, entre outros. Você pode aprender mais sobre *migrations*
no [Guia de *Migrations* do *Active Record*](active_record_migrations.html).
