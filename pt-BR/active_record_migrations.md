**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Active Record Migrations
========================

*Migrations* são uma funcionalidade do *Active Record* que permitem expandir nosso esquema do banco de dados com o tempo. Ao invés de escrever modificações no esquema em SQL puro,*migrations* permitem o uso de uma [Linguagem Específica de Domínio (DSL)](https://pt.wikipedia.org/wiki/Linguagem_de_dom%C3%ADnio_espec%C3%ADfico) em *Ruby* para descrever as mudanças em nossas tabelas.

Depois de ler esse guia, você vai saber:

* Os *generators* que você pode usar para criar as *migrations*.
* Os métodos que o *Active Record* provê para manipular seu banco de dados.
* Os comandos `rails` que manipulam *migrations* e o esquema do seu banco.
* Como *migrations* e `schema.rb` se relacionam.

--------------------------------------------------------------------------------

Visão Geral de Migration
----------------------------

*Migrations* são uma forma conveniente de
[alterar nosso esquema de banco de dados com o tempo](https://en.wikipedia.org/wiki/Schema_migration) de uma forma fácil e consistente. Elas usam uma *Ruby DSL* para que você não precise escrever SQL puro, permitindo que seu esquema e as alterações sejam independentes do banco de dados utilizado.

Você pode pensar em cada *migration* como sendo uma nova 'versão' do banco de dados. Um esquema é vazio no início, e após cada *migration* ele é modificado para adicionar ou remover tabelas, colunas, ou entradas de dados. O *Active Record* sabe como atualizar seu esquema nessa linha do tempo, trazendo-o de qualquer ponto em que ele esteja no histórico, para a última versão. O *Active Record* também atualizará seu arquivo `db/schema.rb` para igualar a estrutura mais atualizada do seu banco de dados.

Aqui temos um exemplo de uma *migration*:

```ruby
class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

Essa *migration* adiciona uma tabela chamada `products` com uma coluna do tipo *string* chamada `name` e uma coluna do tipo *text* chamada `description`. Uma coluna do tipo chave primária chamada `id` também será adicionada implicitamente, pois ela é a chave primária padrão para todos os *models* de *Active Record*. A macro `timestamps` adiciona duas colunas, `created_at` e `updated_at`. Essas colunas especiais são automaticamente gerenciadas pelo *Active Record*, se existirem.

Note que nós definimos as mudanças que queremos que aconteçam no futuro.
Antes desta *migration* ser executada, não há sequer a tabela. Depois, a tabela será criada. O *Active Record* também sabe como reverter essa *migration*: se a desfizermos, ele removerá a tabela.

Em bancos de dados que suportem transações com declarações que alterem o esquema,
*migrations* são incluídas na transação. Se o banco de dados não suportar esses tipos de declarações, então, quando uma *migration* falhar, as partes dela que tiveram sucesso não serão desfeitas. Você terá que desfazer as mudanças que fez manualmente.

NOTE: Há certos tipos de *queries* que não podem ser executadas dentro de uma transação. Se o seu adaptador de conexão suporta transações DDL você pode usar `disable_ddl_transaction!` para desabilitá-las para uma única *migration*.

Se você quiser que uma *migration* faça algo que o *Active Record* não sabe como reverter, pode usar `reversible`:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[5.0]
  def change
    reversible do |dir|
      change_table :products do |t|
        dir.up   { t.change :price, :string }
        dir.down { t.change :price, :integer }
      end
    end
  end
end
```

Alternativamente, você pode usar `up` e `down` ao invés de `change`:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[5.0]
  def up
    change_table :products do |t|
      t.change :price, :string
    end
  end

  def down
    change_table :products do |t|
      t.change :price, :integer
    end
  end
end
```

Criando uma *Migration*
--------------------

### Criando uma *Migration* Independente

*Migrations* são armazenadas em arquivos no diretório `db/migrate`, um para cada classe de
*migration*. O nome do arquivo tem o seguinte formato
`YYYYMMDDHHMMSS_create_products.rb`, isto é uma *timestamp* (marcação de data/hora) em UTC identificando a 
*migration* seguida por um underline seguido pelo 
nome da *migration*. O nome da classe da migration 
(em CamelCase) deve corresponder à última parte do nome do arquivo. Por exemplo
`20080906120000_create_products.rb` deve definir a classe `CreateProducts` e
`20080906120001_add_details_to_products.rb` deve definir
`AddDetailsToProducts`. O Rails usa esse registro de data e hora para determinar qual *migration*
deve ser executada e em que ordem, portanto, se você estiver copiando uma *migration* de outra
aplicação ou gerar um arquivo você mesmo, esteja ciente de sua posição na ordem.

Obviamente, calcular *timestamps* não é divertido, portanto, o *Active Record* fornece um
gerador para fazer isso por você:

```bash
$ rails generate migration AddPartNumberToProducts
```

Isso criará uma *migration* vazia nomeada devidamente:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[5.0]
  def change
  end
end
```

Esse gerador pode fazer muito mais do que acrescentar uma *timestamp* ao nome do arquivo.
Com base em convenções de nomenclatura e argumentos (opcionais) adicionais, ele pode
também começar a concretizar a *migration*.

Se o nome da migração estiver no formato "AddColumnToTable" ou
"RemoveColumnFromTable" e é seguido por uma lista de nomes de colunas e
tipos de dados, então uma *migration* contendo as intruções `add_column` e
`remove_column` serão criadas apropriadamente.

```bash
$ rails generate migration AddPartNumberToProducts part_number:string
```

irá gerar

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :part_number, :string
  end
end
```

Se você deseja adicionar um índice na nova coluna, você também pode fazer isso:

```bash
$ rails generate migration AddPartNumberToProducts part_number:string:index
```

irá gerar

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```


Da mesma forma, você pode gerar uma *migration* para remover uma coluna via linha de comando:

```bash
$ rails generate migration RemovePartNumberFromProducts part_number:string
```

gera

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration[5.0]
  def change
    remove_column :products, :part_number, :string
  end
end
```

Você não tem a limitação de apenas uma coluna ser gerada magicamente. Por exemplo:

```bash
$ rails generate migration AddDetailsToProducts part_number:string price:decimal
```

gera

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :part_number, :string
    add_column :products, :price, :decimal
  end
end
```

Se o nome da migração estiver no formato "CreateXXX" e for
seguido por uma lista de nomes e tipos de colunas, em seguida, uma *migration* criando a tabela
XXX com as colunas listadas será gerado. Por exemplo:

```bash
$ rails generate migration CreateProducts name:string part_number:string
```

gera

```ruby
class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :part_number
    end
  end
end
```

Como sempre, o que foi gerado para você é apenas um ponto de partida. Você pode adicionar
ou remover conteúdo como achar melhor, editando o arquivo
`db/migrate/YYYYMMDDHHMMSS_add_details_to_products.rb`.

Além disso, o gerador aceita o tipo de coluna `references` (também disponível como
`belongs_to`). Por exemplo:

```bash
$ rails generate migration AddUserRefToProducts user:references
```

gera

```ruby
class AddUserRefToProducts < ActiveRecord::Migration[5.0]
  def change
    add_reference :products, :user, foreign_key: true
  end
end
```

Essa migração criará uma coluna `user_id` e o índice apropriado.
Para mais opções `add_reference`, visite a [documentação da API](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference).

Também existe um gerador que produzirá *join tables* se `JoinTable` fizer parte do nome:

```bash
$ rails g migration CreateJoinTableCustomerProduct customer product
```

produzirá a seguinte migração:

```ruby
class CreateJoinTableCustomerProduct < ActiveRecord::Migration[5.0]
  def change
    create_join_table :customers, :products do |t|
      # t.index [:customer_id, :product_id]
      # t.index [:product_id, :customer_id]
    end
  end
end
```

### Model Generators

Os geradores de *model* e *scaffold* criarão migrações apropriadas para adicionar
um novo *model*. Essa migração já irá conter as instruções para criar a
tabela. Se você disser ao Rails quais colunas você deseja, as instruções para
adicionar essas colunas também serão criadas. Por exemplo, executando:

```bash
$ rails generate model Product name:string description:text
```

criará uma migração que se parece com isso

```ruby
class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
```

Você pode utilizar quantos pares de nome/tipo de coluna desejar.

### Usando Modificadores

Alguns [modificadores de tipo](#column-modifiers) podem utilizados diretamente via
linha de comando. Eles são delimitados por chaves e vem após o tipo de campo:

Por exemplo, executando:

```bash
$ rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
```

produzirá uma migração que se parece com isso

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :price, :decimal, precision: 5, scale: 2
    add_reference :products, :supplier, polymorphic: true
  end
end
```

TIP: Dê uma olhada no `--help` dos *generators* (geradores) obter mais detalhes.

Escrevendo uma *Migration*
-------------------

Depois de criar sua *migration* usando um dos geradores, é hora de
começar os trabalhos!

### Criando uma Tabela 

O método `create_table` é um dos mais fundamentais, mas na maioria das vezes,
ele será criado para você usando um gerador de *scaffold* ou *model*. Um uso
típico seria:

```ruby
create_table :products do |t|
  t.string :name
end
```

Que cria uma tabela `produtos` com uma coluna chamada `nome` (e como discutido
abaixo, uma coluna implícita `id`.

Por padrão, o `create_table` criará uma chave primária chamada `id`. Você pode mudar
o nome da chave primária com a opção `:primary_key` (não esqueça de
atualizar o *model* correspondente) ou, se você não quer uma chave primária, você
pode passar a opção `id: false`. Se você precisa passar opções específicas do banco de dados 
você pode colocar um fragmento SQL na opção `:option`. Por exemplo:

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

acrescentará `ENGINE=BLACKHOLE` à instrução SQL usada para criar a tabela.

Você também pode passar a opção `:comment` com qualquer descrição para a tabela
que serão armazenados no próprio bando de dados e poderão ser visualizados com ferramentas de administração
de bando de dados, como MySQL Workbench ou PgAdmin III. É altamente recomendável especificar
comentários nas *migrations* para aplicações com grandes bancos de dados, pois ajuda as pessoas
a entender o modelo de dados e gerar documentação.
Atualmente, apenas os adaptadores MySQL e PostgreSQL suportam comentários.

### Criando uma Tabela de Junção (Join Table)

O método de *migration* `create_join_table` cria uma tabela *join* HABTM (tem e pertence a
muitos). Um uso comum seria:

```ruby
create_join_table :products, :categories
```

que cria uma tabela `categories_products` com duas colunas chamadas
`category_id` e `product_id`. Essas colunas têm a opção `:null` definida como
`false` por padrão. Isso pode ser substituído, especificando a opção
`:column_options`:

```ruby
create_join_table :products, :categories, column_options: { null: true }
```

Por padrão, o nome da tabela de *join* vem da união dos dois primeiros
argumentos fornecidos para `create_join_table` em ordem alfabética.
Para customizar o nome da table, forneça uma opção `:table_name`:

```ruby
create_join_table :products, :categories, table_name: :categorization
```

cria uma tabela `categorization`.

`create_join_table` também aceita um bloco, que você pode usar para adicionar índices
(que não são criados por padrão) ou colunas adicionais:

```ruby
create_join_table :products, :categories do |t|
  t.index :product_id
  t.index :category_id
end
```

### Mudando tabelas

Um primo próximo do `create_table` é `change_table`, usado para mudar tabelas
existentes. É usado de maneira semelhante ao `create_table` mas o objeto
produzido no bloco conhece mais truques. Por exemplo:

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

remove as colunas `description` e `name`, cria uma coluna de string `part_number`
e adiciona um índice nela. Finalmente renomeia a coluna `upccode`.

### Mundado Colunas

Assim como o `remove_column` e `add_column`, o Rails fornece o método de
*migration* `change_column`.

```ruby
change_column :products, :part_number, :text
```

Isso muda a coluna `part_number` na tabela produtos para ser um campo `:text`.
Note que o comando `change_column` é irreversível.

Além do `change_column`, os métodos `change_column_null` e `change_column_default`
são usados especificamente para alterar uma *not null constraint* e valores
padrão de uma coluna.

```ruby
change_column_null :products, :name, false
change_column_default :products, :approved, from: true, to: false
```

Isso define o campo `:name` em produtos para uma coluna `NOT NULL` e o valor
padrão do campo `:approved` de `true` para `false`.

NOTE: Você também pode escrever a *migration* `change_column_default` acima como
`change_column_default :products, :approved, false`, mas diferente do exemplo
anterior, isso tornaria sua *migration* irreversível.

### Modificadores de Coluna

Modificadores de coluna podem ser aplicados ao criar ou alterar uma coluna:

* `limit`        Define o tamanho máximo dos campos `string/text/binary/integer`.
* `precision`    Define a precisão para os campos `decimal`, representando a
quantidade total de dígitos no número.
* `scale`        Define a escala para os campos `decimal`, representando o
número de digitos após o ponto decimal.
* `polymorphic`  Adiciona uma coluna `type` para a associação `belongs_to`.
* `null`         Autoriza ou não valores `NULL` na coluna.
* `default`      Permite definir um valor padrão na coluna. Note que se você
estiver usando um valor dinâmico (como uma data), o padrão será calculado
apenas na primeira vez (ou seja, na data em que a *migration* é aplicada).
* `comment`      Adiciona um comentário para a coluna.

Alguns adaptadores podem suportar opções adicionais; consulte a documentação da API de um adaptador espécifico
para maiores informações.

NOTE: `null` e `default` não podem ser especificados via linha de comando.

### Foreign Keys (Chaves Estrangeiras)

Embora não seja necessário, você pode adicionar restrições de foreign key (chave estrageira) para
[garantir a integridade referencial](#active-record-and-referential-integrity).

```ruby
add_foreign_key :articles, :authors
```

Isso adiciona uma nova foreign key (chave estrangeira) à coluna `author_id` da tabela
`articles`. A chave referencia a coluna `id` para a tabela `authors`. Se os
nomes da coluna não puderem ser derivados dos nomes das tabelas, você poderá usar as
opções `:column` e `:primary_key`.
O Rails irá gerar um nome para cada foreign key (chave estrangeira) começando com
`fk_rails_` seguido por 10 caracteres que são gerados
deterministicamente a partir do `from_table` e `column`.
Existe uma opção `:name` para especificar um nome diferente se necessário.

NOTE: O Active Record suporta apenas *foreign keys* (chaves estrangeiras) de coluna única. `execute` e
`structure.sql` são obrigados a usar foreign keys (chaves estrangeiras) compostas. Consulte
[Schema Dumping e Você](#schema-dumping-and-you).

A remoção de uma foreign key (chave estrangeira) também é fácil:

```ruby
# let Active Record figure out the column name
remove_foreign_key :accounts, :branches

# remove foreign key for a specific column
remove_foreign_key :accounts, column: :owner_id

# remove foreign key by name
remove_foreign_key :accounts, name: :special_fk_name
```

### Quando os Helpers não são Suficientes

Se os *helpers* fornecidos pelo Active Record não forem suficientes, você poderá usar o método `execute`
para executar SQL arbitrário:

```ruby
Product.connection.execute("UPDATE products SET price = 'free' WHERE 1=1")
```

Para mais detalhes e exemplos de métodos individuais, consulte a documentação da API.
Em particular, a documentação para
[`ActiveRecord::ConnectionAdapters::SchemaStatements`](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html)
(que fornece os métodos disponíveis nos métodos `change`, `up` e `down`),
[`ActiveRecord::ConnectionAdapters::TableDefinition`](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html)
(que fornece os métodos disponíveis no objeto gerado por `create_table`)
e
[`ActiveRecord::ConnectionAdapters::Table`](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/Table.html)
(que fornece os métodos disponíveis no objeto gerado por `change_table`).

### Usando o Método `change`

O método `change` é a principal maneira de escrever *migrations*. Funciona para a
maioria dos casos, onde o *Active Record* sabe como reverter a *migration*
automaticamente. Atualmente, o método `change` suporta apenas estas definições de
*migrations*:

* add_column
* add_foreign_key
* add_index
* add_reference
* add_timestamps
* change_column_default (must supply a :from and :to option)
* change_column_null
* create_join_table
* create_table
* disable_extension
* drop_join_table
* drop_table (must supply a block)
* enable_extension
* remove_column (must supply a type)
* remove_foreign_key (must supply a second table)
* remove_index
* remove_reference
* remove_timestamps
* rename_column
* rename_index
* rename_table

`change_table` também é reversível, desde que o bloco não chame `change`,
`change_default` ou `remove`.

`remove_column` é reversível se você fornecer o tipo de coluna como o terceiro
argumento. Forneça também as opções da coluna original, caso contrário, o Rails poderá
recriar a coluna exatamente ao reverter:

```ruby
remove_column :posts, :slug, :string, null: false, default: ''
```

Se você precisar usar outros métodos, você deve usar `reversible`
ou escrever os métodos `up` e `down` em vez de usar o médoto `change`.

### Usando `reversible`

*Migrations* complexas podem exigir processamento que o *Active Record* não sabe como
reverter. Você pode usar `reversible` para especificar o que fazer ao executar uma
*migration* e o que mais fazer ao revertê-la. Por exemplo:

```ruby
class ExampleMigration < ActiveRecord::Migration[5.0]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end

    reversible do |dir|
      dir.up do
        # add a CHECK constraint
        execute <<-SQL
          ALTER TABLE distributors
            ADD CONSTRAINT zipchk
              CHECK (char_length(zipcode) = 5) NO INHERIT;
        SQL
      end
      dir.down do
        execute <<-SQL
          ALTER TABLE distributors
            DROP CONSTRAINT zipchk
        SQL
      end
    end

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end
end
```

O uso de `reversible` garantirá que as instruções também sejam executadas na
ordem certa. Se o exemplo anterior de *migration* for revertido,
o bloco `down` será executado depois da coluna `home_page_url` for removida e
logo antes da tabela `distributors` for apagada.

Às vezes sua *migration* fará algo que é simplesmente irreversível;
por exemplo, pode destruir alguns dados. Em alguns casos, você pode levantar o
`ActiveRecord::IrreversibleMigration` no seu bloco `down`. Se alguém tentar
reverter sua *migration*, uma mensagem de erro será exibida dizendo que isso
não pode ser feito.

### Usando os métodos `up`/`down`

Você também pode usar o estilo antigo de *migration* usando os métodos `up` e `down`
em vez do método `change`.
O método `up` deve descrever a transformação que você deseja fazer no seu
*schema*, e o método `down` da sua *migration* deve reverter as
transformações feitas pelo método `up`. Em outras palavas, o *schema* do bando de dados
deve permanecer inalterado se você fizer um `up` seguido por um `down`. Por exemplo, se você
criar uma tabela em um método `up`, você deve apagá-la no método `down`. É
aconselhável realizar as transformações precisamente na ordem inversa em que foram
feitas no método `up`. O exemplo na seção `reversible` é equivalente a:

```ruby
class ExampleMigration < ActiveRecord::Migration[5.0]
  def up
    create_table :distributors do |t|
      t.string :zipcode
    end

    # add a CHECK constraint
    execute <<-SQL
      ALTER TABLE distributors
        ADD CONSTRAINT zipchk
        CHECK (char_length(zipcode) = 5);
    SQL

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end

  def down
    rename_column :users, :email_address, :email
    remove_column :users, :home_page_url

    execute <<-SQL
      ALTER TABLE distributors
        DROP CONSTRAINT zipchk
    SQL

    drop_table :distributors
  end
end
```

Se sua *migration* é irreversível, você deve levandatar um
`ActiveRecord::IrreversibleMigration` do seu método `down`. Se alguém tentar
reveter sua *migration*, uma mensagem de erro será exibida dizendo que isso
não pode ser feito.

### Revertendo *Migrations* Anteriores

You can use Active Record's ability to rollback migrations using the `revert` method:
Você pode usar a capacidade do Active Record de reverter *migrations* usando o método `revert`:

```ruby
require_relative '20121212123456_example_migration'

class FixupExampleMigration < ActiveRecord::Migration[5.0]
  def change
    revert ExampleMigration

    create_table(:apples) do |t|
      t.string :variety
    end
  end
end
```

O método `revert` também aceita um bloco de instruções para reverter.
Isso pode ser útil para reverter partes selecionadas de *migrations* anteriores.
Por exemplo, vamos imaginar que `ExampleMigration` seja executado e
mais tarde decidimos que seria melhor usar as validações do Active Record,
no lugar da *constraint* (restrição) `CHECK`, para verificar o CEP.

```ruby
class DontUseConstraintForZipcodeValidationMigration < ActiveRecord::Migration[5.0]
  def change
    revert do
      # copy-pasted code from ExampleMigration
      reversible do |dir|
        dir.up do
          # add a CHECK constraint
          execute <<-SQL
            ALTER TABLE distributors
              ADD CONSTRAINT zipchk
                CHECK (char_length(zipcode) = 5);
          SQL
        end
        dir.down do
          execute <<-SQL
            ALTER TABLE distributors
              DROP CONSTRAINT zipchk
          SQL
        end
      end

      # The rest of the migration was ok
    end
  end
end
```

A mesma *migration* também poderia ter sido escrita sem o uso do `revert`
mas isso envolveria mais algumas etapas: reverter a ordem
de `create_table` e `reversible`, substituindo `create_table`
por `drop_table`, e finalmente mudando `up` para `down` e vice-versa.
Tudo isso é resolvido por `revert`.

NOTE: Se você quer adicionar verificadores de *constraints* (restrições) como nos exemplos acima,
você terá que usar `structure.sql` como método *dump*. Consulte
[Schema Dumping e Você](#schema-dumping-and-you).

Running Migrations
------------------

Rails provides a set of rails commands to run certain sets of migrations.

The very first migration related rails command you will use will probably be
`rails db:migrate`. In its most basic form it just runs the `change` or `up`
method for all the migrations that have not yet been run. If there are
no such migrations, it exits. It will run these migrations in order based
on the date of the migration.

Note that running the `db:migrate` command also invokes the `db:schema:dump` command, which
will update your `db/schema.rb` file to match the structure of your database.

If you specify a target version, Active Record will run the required migrations
(change, up, down) until it has reached the specified version. The version
is the numerical prefix on the migration's filename. For example, to migrate
to version 20080906120000 run:

```bash
$ rails db:migrate VERSION=20080906120000
```

If version 20080906120000 is greater than the current version (i.e., it is
migrating upwards), this will run the `change` (or `up`) method
on all migrations up to and
including 20080906120000, and will not execute any later migrations. If
migrating downwards, this will run the `down` method on all the migrations
down to, but not including, 20080906120000.

### Rolling Back

A common task is to rollback the last migration. For example, if you made a
mistake in it and wish to correct it. Rather than tracking down the version
number associated with the previous migration you can run:

```bash
$ rails db:rollback
```

This will rollback the latest migration, either by reverting the `change`
method or by running the `down` method. If you need to undo
several migrations you can provide a `STEP` parameter:

```bash
$ rails db:rollback STEP=3
```

will revert the last 3 migrations.

The `db:migrate:redo` command is a shortcut for doing a rollback and then migrating
back up again. As with the `db:rollback` command, you can use the `STEP` parameter
if you need to go more than one version back, for example:

```bash
$ rails db:migrate:redo STEP=3
```

Neither of these rails commands do anything you could not do with `db:migrate`. They
are simply more convenient, since you do not need to explicitly specify the
version to migrate to.

### Setup the Database

The `rails db:setup` command will create the database, load the schema, and initialize
it with the seed data.

### Resetting the Database

The `rails db:reset` command will drop the database and set it up again. This is
functionally equivalent to `rails db:drop db:setup`.

NOTE: This is not the same as running all the migrations. It will only use the
contents of the current `db/schema.rb` or `db/structure.sql` file. If a migration can't be rolled back,
`rails db:reset` may not help you. To find out more about dumping the schema see
[Schema Dumping and You](#schema-dumping-and-you) section.

### Running Specific Migrations

If you need to run a specific migration up or down, the `db:migrate:up` and
`db:migrate:down` commands will do that. Just specify the appropriate version and
the corresponding migration will have its `change`, `up` or `down` method
invoked, for example:

```bash
$ rails db:migrate:up VERSION=20080906120000
```

will run the 20080906120000 migration by running the `change` method (or the
`up` method). This command will
first check whether the migration is already performed and will do nothing if
Active Record believes that it has already been run.

### Running Migrations in Different Environments

By default running `rails db:migrate` will run in the `development` environment.
To run migrations against another environment you can specify it using the
`RAILS_ENV` environment variable while running the command. For example to run
migrations against the `test` environment you could run:

```bash
$ rails db:migrate RAILS_ENV=test
```

### Changing the Output of Running Migrations

By default migrations tell you exactly what they're doing and how long it took.
A migration creating a table and adding an index might produce output like this

```bash
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

Several methods are provided in migrations that allow you to control all this:

| Method               | Purpose
| -------------------- | -------
| suppress_messages    | Takes a block as an argument and suppresses any output generated by the block.
| say                  | Takes a message argument and outputs it as is. A second boolean argument can be passed to specify whether to indent or not.
| say_with_time        | Outputs text along with how long it took to run its block. If the block returns an integer it assumes it is the number of rows affected.

For example, this migration:

```ruby
class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    suppress_messages do
      create_table :products do |t|
        t.string :name
        t.text :description
        t.timestamps
      end
    end

    say "Created a table"

    suppress_messages {add_index :products, :name}
    say "and an index!", true

    say_with_time 'Waiting for a while' do
      sleep 10
      250
    end
  end
end
```

generates the following output

```bash
==  CreateProducts: migrating =================================================
-- Created a table
   -> and an index!
-- Waiting for a while
   -> 10.0013s
   -> 250 rows
==  CreateProducts: migrated (10.0054s) =======================================
```

If you want Active Record to not output anything, then running `rails db:migrate
VERBOSE=false` will suppress all output.

Changing Existing Migrations
----------------------------

Occasionally you will make a mistake when writing a migration. If you have
already run the migration, then you cannot just edit the migration and run the
migration again: Rails thinks it has already run the migration and so will do
nothing when you run `rails db:migrate`. You must rollback the migration (for
example with `rails db:rollback`), edit your migration, and then run
`rails db:migrate` to run the corrected version.

In general, editing existing migrations is not a good idea. You will be
creating extra work for yourself and your co-workers and cause major headaches
if the existing version of the migration has already been run on production
machines. Instead, you should write a new migration that performs the changes
you require. Editing a freshly generated migration that has not yet been
committed to source control (or, more generally, which has not been propagated
beyond your development machine) is relatively harmless.

The `revert` method can be helpful when writing a new migration to undo
previous migrations in whole or in part
(see [Reverting Previous Migrations](#reverting-previous-migrations) above).

Schema Dumping and You
----------------------

### What are Schema Files for?

Migrations, mighty as they may be, are not the authoritative source for your
database schema. Your database remains the authoritative source. By default,
Rails generates `db/schema.rb` which attempts to capture the current state of
your database schema.

It tends to be faster and less error prone to create a new instance of your
application's database by loading the schema file via `rails db:schema:load`
than it is to replay the entire migration history.
[*Migrations* Antigas](#migrations-antigas) may fail to apply correctly if those
migrations use changing external dependencies or rely on application code which
evolves separately from your migrations.

Schema files are also useful if you want a quick look at what attributes an
Active Record object has. This information is not in the model's code and is
frequently spread across several migrations, but the information is nicely
summed up in the schema file.

### Types of Schema Dumps

The format of the schema dump generated by Rails is controlled by the
`config.active_record.schema_format` setting in `config/application.rb`. By
default, the format is `:ruby`, but can also be set to `:sql`.

If `:ruby` is selected, then the schema is stored in `db/schema.rb`. If you look
at this file you'll find that it looks an awful lot like one very big migration:

```ruby
ActiveRecord::Schema.define(version: 2008_09_06_171750) do
  create_table "authors", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "part_number"
  end
end
```

In many ways this is exactly what it is. This file is created by inspecting the
database and expressing its structure using `create_table`, `add_index`, and so
on.

`db/schema.rb` cannot express everything your database may support such as
triggers, sequences, stored procedures, check constraints, etc. While migrations
may use `execute` to create database constructs that are not supported by the
Ruby migration DSL, these constructs may not be able to be reconstituted by the
schema dumper. If you are using features like these, you should set the schema
format to `:sql` in order to get an accurate schema file that is useful to
create new database instances.

When the schema format is set to `:sql`, the database structure will be dumped
using a tool specific to the database into `db/structure.sql`. For example, for
PostgreSQL, the `pg_dump` utility is used. For MySQL and MariaDB, this file will
contain the output of `SHOW CREATE TABLE` for the various tables.

To load the schema from `db/structure.sql`, run `rails db:structure:load`.
Loading this file is done by executing the SQL statements it contains. By
definition, this will create a perfect copy of the database's structure.

### Schema Dumps and Source Control

Because schema files are commonly used to create new databases, it is strongly
recommended that you check your schema file into source control.

Merge conflicts can occur in your schema file when two branches modify schema.
To resolve these conflicts run `rails db:migrate` to regenerate the schema file.

Active Record and Referential Integrity
---------------------------------------

The Active Record way claims that intelligence belongs in your models, not in
the database. As such, features such as triggers or constraints,
which push some of that intelligence back into the database, are not heavily
used.

Validations such as `validates :foreign_key, uniqueness: true` are one way in
which models can enforce data integrity. The `:dependent` option on
associations allows models to automatically destroy child objects when the
parent is destroyed. Like anything which operates at the application level,
these cannot guarantee referential integrity and so some people augment them
with [foreign key constraints](#foreign-keys) in the database.

Although Active Record does not provide all the tools for working directly with
such features, the `execute` method can be used to execute arbitrary SQL.

Migrations and Seed Data
------------------------

The main purpose of Rails' migration feature is to issue commands that modify the
schema using a consistent process. Migrations can also be used
to add or modify data. This is useful in an existing database that can't be destroyed
and recreated, such as a production database.

```ruby
class AddInitialProducts < ActiveRecord::Migration[5.0]
  def up
    5.times do |i|
      Product.create(name: "Product ##{i}", description: "A product.")
    end
  end

  def down
    Product.delete_all
  end
end
```

To add initial data after a database is created, Rails has a built-in
'seeds' feature that makes the process quick and easy. This is especially
useful when reloading the database frequently in development and test environments.
It's easy to get started with this feature: just fill up `db/seeds.rb` with some
Ruby code, and run `rails db:seed`:

```ruby
5.times do |i|
  Product.create(name: "Product ##{i}", description: "A product.")
end
```

This is generally a much cleaner way to set up the database of a blank
application.

*Migrations* Antigas
--------------------

Os arquivos `db/schema.rb` ou `db/structure.sql` refletem o estado atual do seu
banco de dados e são a fonte oficial para reconstruí-lo. Isto torna possível
excluir arquivos antigos de *migration*.

Quando você exclui arquivos de *migration* no diretório `db/migrate`, qualquer
ambiente no qual `rails db:migrate` foi executado quando estes arquivos ainda
existiam irá manter uma referência às suas *timestamps* específicas dentro de uma
tabela interna do Rails chamada `schema_migrations`. Esta tabela é usada para manter
um acompanhamento de quais *migrations* foram executadas em um ambiente específico.

Se você executar o comando `rails db:migrate:status`, que mostra o estado (*up* ou
*down*) de cada *migration*, você verá o texto `********** NO FILE **********`
próximo a cada arquivo de *migration* excluído que foi anteriormente executado
em um ambiente específico mas não se encontra mais no diretório `db/migrate/`.
