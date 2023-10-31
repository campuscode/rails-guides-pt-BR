**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Active Record Migrations
========================

*Migrations* são uma funcionalidade do *Active Record* que permitem expandir nosso esquema do banco de dados com o tempo. Ao invés de escrever modificações no esquema em SQL puro, *migrations* permitem o uso de uma [Linguagem Específica de Domínio (DSL)](https://pt.wikipedia.org/wiki/Linguagem_de_dom%C3%ADnio_espec%C3%ADfico) em *Ruby* para descrever as mudanças em nossas tabelas.

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
class CreateProducts < ActiveRecord::Migration[7.0]
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
class ChangeProductsPrice < ActiveRecord::Migration[7.0]
  def change
    reversible do |direction|
      change_table :products do |t|
        direction.up   { t.change :price, :string }
        direction.down { t.change :price, :integer }
      end
    end
  end
end
```

Alternativamente, você pode usar `up` e `down` ao invés de `change`:

```ruby
class ChangeProductsPrice < ActiveRecord::Migration[7.0]
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
$ bin/rails generate migration AddPartNumberToProducts
```

Isso criará uma *migration* vazia nomeada devidamente:

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.0]
  def change
  end
end
```

Esse gerador pode fazer muito mais do que acrescentar uma *timestamp* ao nome do arquivo.
Com base em convenções de nomenclatura e argumentos (opcionais) adicionais, ele pode
também começar a concretizar a *migration*.

Se o nome da migração estiver no formato "AddColumnToTable" ou
"RemoveColumnFromTable" e é seguido por uma lista de nomes de colunas e
tipos de dados, então uma *migration* contendo as intruções [`add_column`][] e
[`remove_column`][] serão criadas apropriadamente.

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string
```

irá gerar

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :part_number, :string
  end
end
```

Se você deseja adicionar um índice na nova coluna, você também pode fazer isso.

```bash
$ bin/rails generate migration AddPartNumberToProducts part_number:string:index
```

irá gerar o `add_column` apropriado e o [`add_index`][]

```ruby
class AddPartNumberToProducts < ActiveRecord::Migration[7.0]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```

Da mesma forma, você pode gerar uma *migration* para remover uma coluna via linha de comando:

```bash
$ bin/rails generate migration RemovePartNumberFromProducts part_number:string
```

gera

```ruby
class RemovePartNumberFromProducts < ActiveRecord::Migration[7.0]
  def change
    remove_column :products, :part_number, :string
  end
end
```

Você não tem a limitação de apenas uma coluna ser gerada magicamente. Por exemplo:

```bash
$ bin/rails generate migration AddDetailsToProducts part_number:string price:decimal
```

gera

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.0]
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
$ bin/rails generate migration CreateProducts name:string part_number:string
```

gera

```ruby
class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :part_number

      t.timestamps
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
$ bin/rails generate migration AddUserRefToProducts user:references
```

gera a seguinte chamada a [`add_references`][]:

```ruby
class AddUserRefToProducts < ActiveRecord::Migration[7.0]
  def change
    add_reference :products, :user, foreign_key: true
  end
end
```

Essa migração criará uma coluna `user_id`. [References](#references) é um
abreviação para criar colunas, índices, chaves estrangeiras ou mesmo colunas polimórficas
de associação.

Também existe um gerador que produzirá *join tables* se `JoinTable` fizer parte do nome:

```bash
$ bin/rails g migration CreateJoinTableCustomerProduct customer product
```

produzirá a seguinte migração:

```ruby
class CreateJoinTableCustomerProduct < ActiveRecord::Migration[7.0]
  def change
    create_join_table :customers, :products do |t|
      # t.index [:customer_id, :product_id]
      # t.index [:product_id, :customer_id]
    end
  end
end
```

[`add_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_column
[`add_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index
[`add_reference`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference
[`remove_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_column

### Model Generators

Os geradores de *model*, *resource* e *scaffold* criarão migrações apropriadas para adicionar
um novo *model*. Essa migração já irá conter as instruções para criar a
tabela. Se você disser ao Rails quais colunas você deseja, as instruções para
adicionar essas colunas também serão criadas. Por exemplo, executando:

```bash
$ bin/rails generate model Product name:string description:text
```

criará uma migração que se parece com isso

```ruby
class CreateProducts < ActiveRecord::Migration[7.0]
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

Alguns [modificadores de tipo](#modificadores-de-coluna) podem utilizados diretamente via
linha de comando. Eles são delimitados por chaves e vem após o tipo de campo:

Por exemplo, executando:

```bash
$ bin/rails generate migration AddDetailsToProducts 'price:decimal{5,2}' supplier:references{polymorphic}
```

produzirá uma migração que se parece com isso

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[7.0]
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

O método [`create_table`][] é um dos mais fundamentais, mas na maioria das vezes,
ele será criado para você usando um gerador de *model*, *resource* ou *scaffold*. Um uso
típico seria:

```ruby
create_table :products do |t|
  t.string :name
end
```

Que cria uma tabela `products` com uma coluna chamada `name`.

Por padrão, o `create_table` criará uma chave primária chamada `id`. Você pode mudar
o nome da chave primária com a opção `:primary_key` ou, se você não quer uma chave primária, você
pode passar a opção `id: false`. Se você precisa passar opções específicas do banco de dados
você pode colocar um fragmento SQL na opção `:option`. Por exemplo:

```ruby
create_table :products, options: "ENGINE=BLACKHOLE" do |t|
  t.string :name, null: false
end
```

acrescentará `ENGINE=BLACKHOLE` à instrução SQL usada para criar a tabela.

Um índice pode ser criado nas colunas criadas dentro do bloco `create_table`
passando `true` ou um `hash` para a opção `:index`:

```ruby
create_table :users do |t|
  t.string :name, index: true
  t.string :email, index: { unique: true, name: 'unique_emails' }
end
```

Você também pode passar a opção `:comment` com qualquer descrição para a tabela
que serão armazenados no próprio bando de dados e poderão ser visualizados com ferramentas de administração
de banco de dados, como MySQL Workbench ou PgAdmin III. É altamente recomendável especificar
comentários nas *migrations* para aplicações com grandes bancos de dados, pois ajudam as pessoas
a entender o modelo de dados e gerar documentação.
Atualmente, apenas os adaptadores MySQL e PostgreSQL suportam comentários.

[`create_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_table

### Criando uma Tabela de Junção (Join Table)

O método de *migration* [`create_join_table`][] cria uma tabela *join* HABTM (tem e pertence a
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
Para customizar o nome da tabela, forneça uma opção `:table_name`:

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

[`create_join_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-create_join_table

### Mudando Tabelas

Um primo próximo do `create_table` é [`change_table`][], usado para mudar tabelas
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

[`change_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table

### Mudando Colunas

Assim como o `remove_column` e `add_column`, o Rails fornece o método de
*migration* [`change_column`][].

```ruby
change_column :products, :part_number, :text
```

Isso muda a coluna `part_number` na tabela produtos para ser um campo `:text`.
Note que o comando `change_column` é irreversível.

Além do `change_column`, os métodos [`change_column_null`][] e [`change_column_default`][]
são usados especificamente para alterar uma restrição de não ser nulo e valores
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

[`change_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column
[`change_column_default`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_default
[`change_column_null`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_null

### Modificadores de Coluna

Modificadores de coluna podem ser aplicados ao criar ou alterar uma coluna:

* `comment`      Adiciona um comentário para a coluna.
* `collation`    Especifica a *collation* para uma coluna `string` ou `text`.
* `default`      Permite definir um valor padrão na coluna. Note que se você
estiver usando um valor dinâmico (como uma data), o padrão será calculado
apenas na primeira vez (ou seja, na data em que a *migration* é aplicada). Use `nil` para `NULL`.
* `limit`        Define o número máximo de caracteres para uma coluna `string` e o número máximo de bytes para colunas do tipo `text/binary/integer`.
* `null`         Permite ou não permite valores `NULL` na coluna.
* `precision`    Define a precisão para colunas de tipo `decimal/numeric/datetime/time`.
* `scale`        Define a escala para os campos `decimal` e `numeric`, representando o
número de digitos após o ponto decimal.

NOTE: Para `add_column` ou `change_column` não há opção para adicionar índices.
Eles precisam ser adicionados separadamente usando `add_index`.

Alguns adaptadores podem suportar opções adicionais; consulte a documentação da API de um adaptador específico
para maiores informações.

NOTE: `null` e `default` não podem ser especificados via linha de comando.

### References

O método `add_reference` permite a criação de uma coluna apropriadamente nomeada.

```ruby
add_reference :users, :role
```

Essa migração criará uma coluna `role_id` na tabela de usuários. Ela cria um
index para esta coluna também, a menos que explicitamente informado com o
opção `index: false`:

```ruby
add_reference :users, :role, index: false
```

O método `add_belongs_to` é um *alias* para `add_reference`.

```ruby
add_belongs_to :taggings, :taggable, polymorphic: true
```

A opção polimórfica criará duas colunas na tabela de tags que podem
ser usado para associações polimórficas: `taggable_type` e `taggable_id`.

Uma chave estrangeira pode ser criada com a opção `foreign_key`.

```ruby
add_reference :users, :role, foreign_key: true
```

Para obter mais opções de `add_reference`, visite a [documentação da API](https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_reference).

As referências também podem ser removidas:

```ruby
remove_reference :products, :user, foreign_key: true, index: false
```

### Foreign Keys (Chaves Estrangeiras)

Embora não seja necessário, você pode adicionar restrições de foreign key (chave estrangeira) para
[garantir a integridade referencial](#active-record-e-integridade-referencial).

```ruby
add_foreign_key :articles, :authors
```

A chamada [`add_foreign_key`][] adiciona uma nova restrição à tabela `articles`.
A restrição garante que existe uma linha na tabela `authors` onde
a coluna `id` corresponde ao `articles.author_id`.

Se o nome da coluna `from_table` não puder ser derivado do nome `to_table`,
você pode usar a opção `:column`. Use a opção `:primary_key` se a
chave primária referenciada não é `:id`.

Por exemplo, para adicionar uma chave estrangeira em `articles.reviewer` referenciando `authors.email`:

```ruby
add_foreign_key :articles, :authors, column: :reviewer, primary_key: :email
```

`add_foreign_key` também suporta opções como `name`, `on_delete`,
`if_not_exists`, `validate` e `deferrable`.

NOTE: O Active Record suporta apenas *foreign keys* (chaves estrangeiras) de coluna única. `execute` e
`structure.sql` são obrigados a usar foreign keys (chaves estrangeiras) compostas. Consulte
[Schema Dumping e Você](#schema-dumping-e-voce).

Foreign key (chave estrangeira) também podem ser removidas:

```ruby
# let Active Record figure out the column name
remove_foreign_key :accounts, :branches

# remove foreign key for a specific column
remove_foreign_key :accounts, column: :owner_id
```

### Quando os Helpers não são Suficientes

Se os *helpers* fornecidos pelo Active Record não forem suficientes, você poderá usar o método [`execute`][]
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

[`execute`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/DatabaseStatements.html#method-i-execute

### Usando o Método `change`

O método `change` é a principal maneira de escrever *migrations*. Funciona para a
maioria dos casos, onde o *Active Record* sabe como reverter a *migration*
automaticamente. Abaixo estão algumas ações que o método `change` suporta:

* [`add_check_constraint`][]
* [`add_column`][]
* [`add_foreign_key`][]
* [`add_index`][]
* [`add_reference`][]
* [`add_timestamps`][]
* [`change_column_comment`][] (must supply a `:from` and `:to` option)
* [`change_column_default`][] (must supply a `:from` and `:to` option)
* [`change_column_null`][]
* [`change_table_comment`][] (must supply a `:from` and `:to` option)
* [`create_join_table`][]
* [`create_table`][]
* `disable_extension`
* [`drop_join_table`][]
* [`drop_table`][] (must supply a block)
* `enable_extension`
* [`remove_check_constraint`][] (must supply a constraint expression)
* [`remove_column`][] (must supply a type)
* [`remove_columns`][] (must supply a `:type` option)
* [`remove_foreign_key`][] (must supply a second table)
* [`remove_index`][]
* [`remove_reference`][]
* [`remove_timestamps`][]
* [`rename_column`][]
* [`rename_index`][]
* [`rename_table`][]

[`change_table`][] também é reversível, desde que o bloco não chame operações reversíveis como as listadas abaixo.

`remove_column` é reversível se você fornecer o tipo de coluna como o terceiro
argumento. Forneça também as opções da coluna original, caso contrário, o Rails não poderá
recriar a coluna exatamente ao reverter:

```ruby
remove_column :posts, :slug, :string, null: false, default: ''
```

Se você precisar usar outros métodos, você deve usar `reversible`
ou escrever os métodos `up` e `down` em vez de usar o médoto `change`.

[`add_check_constraint`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_check_constraint
[`add_foreign_key`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_foreign_key
[`add_timestamps`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_timestamps
[`change_column_comment`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_column_comment
[`change_table_comment`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-change_table_comment
[`drop_join_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_join_table
[`drop_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-drop_table
[`remove_check_constraint`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_check_constraint
[`remove_foreign_key`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_foreign_key
[`remove_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_index
[`remove_reference`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_reference
[`remove_timestamps`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_timestamps
[`rename_column`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_column
[`remove_columns`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-remove_columns
[`rename_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_index
[`rename_table`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-rename_table

### Usando `reversible`

*Migrations* complexas podem exigir processamento que o *Active Record* não sabe como
reverter. Você pode usar [`reversible`][] para especificar o que fazer ao executar uma
*migration* e o que mais fazer ao revertê-la. Por exemplo:

```ruby
class ExampleMigration < ActiveRecord::Migration[7.0]
  def change
    create_table :distributors do |t|
      t.string :zipcode
    end

    reversible do |direction|
      direction.up do
        # create a distributors view
        execute <<-SQL
          CREATE VIEW distributors_view AS
          SELECT id, zipcode
          FROM distributors;
        SQL
      end
      direction.down do
        execute <<-SQL
          DROP VIEW distributors_view;
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
o bloco `down` será executado depois que a coluna `home_page_url` for removida e
logo antes da tabela `distributors` for apagada.

Às vezes sua *migration* fará algo que é simplesmente irreversível;
por exemplo, pode destruir alguns dados. Em alguns casos, você pode levantar o
`ActiveRecord::IrreversibleMigration` no seu bloco `down`. Se alguém tentar
reverter sua *migration*, uma mensagem de erro será exibida dizendo que isso
não pode ser feito.

[`reversible`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-reversible

### Usando os métodos `up`/`down`

Você também pode usar o estilo antigo de *migration* usando os métodos `up` e `down`
em vez do método `change`.
O método `up` deve descrever a transformação que você deseja fazer no seu
*schema*, e o método `down` da sua *migration* deve reverter as
transformações feitas pelo método `up`. Em outras palavas, o *schema* do banco de dados
deve permanecer inalterado se você fizer um `up` seguido por um `down`. Por exemplo, se você
criar uma tabela em um método `up`, você deve apagá-la no método `down`. É
aconselhável realizar as transformações precisamente na ordem inversa em que foram
feitas no método `up`. O exemplo na seção `reversible` é equivalente a:

```ruby
class ExampleMigration < ActiveRecord::Migration[7.0]
  def up
    create_table :distributors do |t|
      t.string :zipcode
    end

    # create a distributors view
    execute <<-SQL
      CREATE VIEW distributors_view AS
      SELECT id, zipcode
      FROM distributors;
    SQL

    add_column :users, :home_page_url, :string
    rename_column :users, :email, :email_address
  end

  def down
    rename_column :users, :email_address, :email
    remove_column :users, :home_page_url

    execute <<-SQL
      DROP VIEW distributors_view;
    SQL

    drop_table :distributors
  end
end
```

Se sua *migration* é irreversível, você deve dar `raise` num
`ActiveRecord::IrreversibleMigration` do seu método `down`. Se alguém tentar
reveter sua *migration*, uma mensagem de erro será exibida dizendo que isso
não pode ser feito.

### Revertendo *Migrations* Anteriores

Você pode usar a capacidade do Active Record de reverter *migrations* usando o método [`revert`][]:

```ruby
require_relative "20121212123456_example_migration"

class FixupExampleMigration < ActiveRecord::Migration[7.0]
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
mais tarde decidimos que *view* `Distributors` não é mais necessária.

```ruby
class DontUseDistributorsViewMigration < ActiveRecord::Migration[7.0]
  def change
    revert do
      # copy-pasted code from ExampleMigration
      reversible do |direction|
        direction.up do
          # create a distributors view
          execute <<-SQL
            CREATE VIEW distributors_view AS
            SELECT id, zipcode
            FROM distributors;
          SQL
        end
        direction.down do
          execute <<-SQL
            DROP VIEW distributors_view;
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

[`revert`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-revert

Executando as *Migrations*
------------------

O Rails fornece uma série de comandos para executar certos conjuntos de
*migrations*.

O primeiro comando rails relacionado à *migration* (migração) que você
utilizará, provavelmente será `bin/rails db:migrate`. Basicamente, ele executa o
método `change` ou `up` para todas as *migrations* que ainda não foram
executadas até o momento. Se não houver nenhuma dessas *migrations*, nada é executado. O
comando executará as *migrations* com base na ordem da data da *migration*.

Observe que ao executar o comando `db:migrate` também é chamado o comando
`db:schema:dump`, que atualizará seu arquivo `db/schema.rb` para corresponder a
estrutura do seu banco de dados.

Se você especificar uma versão alvo, o *Active Record* executará as *migrations*
necessárias (`change`, `up`, `down`) até atingir a versão especificada. A versão
é o prefixo numérico do nome do arquivo da *migration*. Por exemplo, para migrar
para a versão 20080906120000 execute:

```bash
$ bin/rails db:migrate VERSION=20080906120000
```

Se a versão 20080906120000 for maior que a versão atual (ou seja, está migrando
para cima), será executado o método `change` (ou `up`) em todas as *migrations*
até a 20080906120000 (incluindo ela na execução) e não será executada nenhuma *migration*
posterior. Se estiver migrando para baixo, será executado o método `down` em
todas as *migrations* até a 20080906120000, não incluindo ela na execução.

### Revertendo a *Migration*

Uma tarefa comum é reverter a última *migration*. Por exemplo, se você cometeu
um erro e deseja corrigí-lo. Ao invés de rastrear o número da versão associada
à *migration* anterior, você pode executar:

```bash
$ bin/rails db:rollback
```

Isso reverterá a *migration* mais recente, seja revertendo o método `change` ou
executando o método `down`. Se precisar desfazer várias *migrations*, você pode
passar um parâmetro `STEP`:

```bash
$ bin/rails db:rollback STEP=3
```

vai reverter as últimas 3 *migrations*.

O comando `db:migrate:redo` é um atalho para fazer um *rollback* e então refazer
uma *migration* de volta. Assim como o comando `db:rollback`, você pode utilizar
o parâmetro `STEP` se precisar voltar mais de uma versão, por exemplo:

```bash
$ bin/rails db:migrate:redo STEP=3
```

Nenhum desses comandos do rails fazem nada do que você não pudesse fazer com o
`db:migrate`. Eles são apenas mais convenientes, já que você não precisa
especificar explicitamente a versão para a qual migrar.

### Setup do Banco de Dados

O comando `bin/rails db:setup` vai criar o banco de dados, carregar o *schema* e
inicializar com os dados iniciais.

### Reinicializando o Banco de Dados

O comando `bin/rails db:reset` vai eliminar o banco de dados e configurá-lo
novamente. Isso é funcionalmente equivalente ao comando `bin/rails db:drop db:setup`.

NOTE: Isso não é o mesmo que executar todas as *migrations*. Ele usará apenas o
conteúdo do arquivo atual `db/schema.rb` ou `db/structure.sql`. Se uma
*migration* não pode ser revertida, o comando `bin/rails db:reset` pode não ser
útil. Para saber mais sobre como descartar o `schema`, consulte a seção [Schema
Dumping e Você](#schema-dumping-e-voce).

### Executando *Migrations* Específicas

Se você precisar executar uma *migration* específica para cima ou para baixo, os
comandos `db:migrate:up` e `db:migration:down` farão isso. Basta especificar a
versão correta e a *migration* correspondente terá o método `change`, `up` ou
`down` chamado, por exemplo:

```bash
$ bin/rails db:migrate:up VERSION=20080906120000
```

vai executar a *migration* 20080906120000 executando o método `change` (ou o
método `up`). Este comando verificará primeiro se a *migration* já foi realizada
e não fará nada se o *Active Record* entender que já foi executada.

### Executando *Migrations* em Ambientes Diferentes

Por padrão, ao rodar o `bin/rails db:migrate` ele será executado no ambiente
`development` (desenvolvimento). Para executar as *migrations* em outro
ambiente, você pode especificá-lo usando a variável de ambiente `RAILS_ENV`
enquanto executa o comando. Por exemplo, para executar as *migrations*no
ambiente `test` (teste), você pode executar:

```bash
$ bin/rails db:migrate RAILS_ENV=test
```

### Alterando o Output (Saída) de *Migrations* em Execução

Por padrão, as *migrations* informam exatamente o que estão fazendo e o quanto
tempo levou.
Uma *migration* criando uma tabela e adicionando um índice pode produzir um
*output* como esse:

```
==  CreateProducts: migrating =================================================
-- create_table(:products)
   -> 0.0028s
==  CreateProducts: migrated (0.0028s) ========================================
```

Vários métodos são fornecidos nas *migrations* que permitem que você controle
tudo isso:

| Método                     | Objetivo
| -------------------------- | -------
| [`suppress_messages`][]    | Pega um bloco como argumento e suprime qualquer *output* gerado pelo bloco.
| [`say`][]                  | Pega um argumento de mensagem e o exibe como está. Um segundo argumento booleano pode ser passado para especificar se deve ser indentado ou não.
| [`say_with_time`][]        | Produz um texto junto com o tempo que levou para executar seu bloco. Se o bloco retornar um inteiro, ele assume que é o número de linhas afetadas.

Por exemplo, esta *migration*

```ruby
class CreateProducts < ActiveRecord::Migration[7.0]
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

gera o seguinte *output*

```
==  CreateProducts: migrating =================================================
-- Created a table
   -> and an index!
-- Waiting for a while
   -> 10.0013s
   -> 250 rows
==  CreateProducts: migrated (10.0054s) =======================================
```

Se você deseja que o *Active Record* não produza nada, execute `bin/rails db:migrate
VERBOSE=false` e isso irá suprimir todos os *outputs*

[`say`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say
[`say_with_time`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-say_with_time
[`suppress_messages`]: https://api.rubyonrails.org/classes/ActiveRecord/Migration.html#method-i-suppress_messages

Mudando *Migrations* Existentes
----------------------------

Ocasionalmente, você cometerá um erro ao escrever uma *migration*. Se você já executou a *migration*, você não pode editá-la e rodá-la novamente: o Rails assume que você já rodou a *migration*, então não irá fazer nada quando você executar o comando `bin/rails db:migrate`. Você deve reverter a *migration* (por exemplo com `bin/rails db:rollback`), editar a *migration*, e então rodar o comando `bin/rails db:migrate` para que a versão correta seja executada.

Em geral, a edição de *migrations* existentes não é uma boa ideia. Você criará trabalho extra para si mesmo e seus colegas de trabalho e causará dores de cabeça maiores se a versão existente da *migration* já tiver sido executada nas máquinas de produção.

Como alternativa, você deveria escrever uma nova *migration* que execute as mudanças necessárias. Editar uma *migration* recentemente gerada e que ainda não foi feito um *commit* para o *source control* (ou, de forma geral, que não foi propagada além de sua máquina de desenvolvimento) é relativamente inofensivo.

O método `revert` pode ajudar ao escrever uma nova *migration* para desfazer *migrations* anteriores no todo ou em partes (veja [Revertendo *Migrations* Anteriores](#revertendo-migrations-anteriores) acima).

*Schema Dumping* e Você
----------------------

### Para que servem arquivos de Schema?

*Migrations*, poderosas como podem ser, não são a fonte oficial para o *schema* do seu banco de dados. Seu banco de dados permanece sendo a fonte oficial. Por padrão, o Rails gera o arquivo `db/schema.rb` (um [*schema dump*](https://pt.wikipedia.org/wiki/Dump_de_banco_de_dados)), que tenta capturar o estado atual do *schema* do seu banco de dados.

Costuma ser mais rápido e menos suscetível a erros criar uma nova instância do banco de dados da sua aplicação caregando o arquivo de *schema* por meio do comando `bin/rails db:schema:load` ao invés de reexecutar todo o histórico de *migrations*.
[*Migrations* Antigas](#migrations-antigas) podem falhar em sua execução se estas *migrations* usam dependências externas que estejam em constante mudança ou se dependem de um código de aplicação que evolui separadamente das suas *migrations*.

Arquivos de *schema* também são úteis se você deseja verificar rapidamente quais atributos um objeto do tipo *Active Record* possui. Essa informação não está no código do *model* e é frequentemente espalhada em diversas *migrations*, mas a informação é facilmente acessível no arquivo de *schema*.

### Tipos de Schema Dumps

O formato dos arquivos de *schema* gerados pelo Rails é controlado pela configuração [`config.active_record.schema_format`][] em `config/application.rb`. Por padrão, o formato é `:ruby`, mas pode ser também alterado para `:sql`.

Se `:ruby` está selecionado, então o arquivo de *schema* é salvo em `db/schema.rb`. Se você analisar este arquivo perceberá que ele se parece muito com uma *migration* gigante.

```ruby
ActiveRecord::Schema[7.0].define(version: 2008_09_06_171750) do
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

De muitas maneiras é exatamente isso. Este arquivo é criado ao inspecionar o banco de dados, expressando sua estrutura através dos comandos `create_table`, `add_index`, e por aí vai.

O arquivo `db/schema.rb` não consegue expressar tudo o que o seu banco de dados suporta como *triggers*, *sequences*, *stored procedures*, etc. Enquanto outras *migrations* podem utilizar o comando `execute` para criar estruturas do banco de dados que não são suportadas pela DSL de *migrations* do Ruby, estas estruturas podem não ser possíveis de serem reconstituídas ao gerar um novo *schema* padrão. Se você estiver utilizando estes tipos de funcionalidades, você deve então alterar o formato do *schema* para `:sql` para conseguir obter um arquivo de *schema* mais preciso e que possa ser utilizado para criar novas instâncias do banco de dados.

Quando o formato do *schema* é definido como `:sql`, a estrutura do banco de dados será reproduzida utilizando uma ferramenta específica para o banco de dados sendo usado no arquivo `db/structure.sql`. Por exemplo, para o PostgreSQL, a ferramenta `pg_dump` é utilizada. Para MySQL e MariaDB, este arquivo irá conter a saída de `SHOW CREATE TABLE` para as tabelas do banco.

Para carregar o *schema* de `db/structure.sql`, execute `bin/rails db:schema:load`. O carregamento deste arquivo é realizado executando os comandos em SQL que ele contém. Por definição, isso irá criar uma cópia perfeita da estrutura do banco de dados.

[`config.active_record.schema_format`]: configuring.html#config-active-record-schema-format

### Schema Dumps e o Controle de Versão

Como os arquivos de *schema* são comumente utilizados para criar novos bancos de dados, é fortemente recomendado que você adicione seu arquivo de *schema* ao controle de versão.

Conflitos de *merge* podem acontecer no seu arquivo de *schema* quando duas *branches* o modificam. Para resolver estes conflitos execute `bin/rails db:migrate` para gerar novamente o arquivo de *schema*.

*Active Record* e Integridade Referencial
---------------------------------------

A maneira do *Active Record* trabalhar presume que a inteligência pertence aos seus *models*, não ao banco de dados. Desta forma, funcionalidades como *triggers* ou *constraints*, que enviam um pouco desta inteligência de volta para o banco de dados, não são usadas com frequência.

Validações como `validates :foreign_key, uniqueness: true` são uma maneira pela qual os *models* podem impor integridade dos dados. A opção `:dependent` nas associações permite aos *models* destruir automaticamente objetos filhos quando o objeto pai é destruído. Como qualquer coisa que opera no nível da aplicação, estas validações não podem garantir integridade referencial e assim algumas pessoas as aprimoram com [vínculos de chaves estrangeiras](#foreign-keys-chaves-estrangeiras) no banco de dados.

Embora o *Active Record* não forneça todas as ferramentas para trabalhar diretamente com estas funcionalidades, o método `execute` pode ser usado para executar SQL arbitrário.

Migrações e Dados de *Seed*
------------------------

O propósito principal da funcionalidade de migração do Rails é enviar comandos que modificam o *schema* usando um processo consistente. Migrações também podem ser usadas para inserir ou modificar dados. Isto é útil em um banco de dados existente que não pode ser destruído e criado de novo, como por exemplo um banco de dados em produção.

```ruby
class AddInitialProducts < ActiveRecord::Migration[7.0]
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

Para inserir dados depois que um banco de dados for criado, o Rails tem uma funcionalidade padrão de *seeds* que torna o processo rápido. Isto é especialmente útil ao recarregar o banco de dados com frequência nos ambientes de teste e desenvolvimento. Para começar a usar estafuncionalidade, preencha o arquivo `db/seeds.rb` com código Ruby, e execute `bin/rails db:seed`:

```ruby
5.times do |i|
  Product.create(name: "Product ##{i}", description: "A product.")
end
```

Isto é, geralmente, uma maneira mais limpa para preparar o banco de dados de uma aplicação em branco.

*Migrations* Antigas
--------------------

Os arquivos `db/schema.rb` ou `db/structure.sql` refletem o estado atual do seu
banco de dados e são a fonte oficial para reconstruí-lo. Isto torna possível
excluir arquivos antigos de *migration*.

Quando você exclui arquivos de *migration* no diretório `db/migrate`, qualquer
ambiente no qual `bin/rails db:migrate` foi executado quando estes arquivos ainda
existiam irá manter uma referência às suas *timestamps* específicas dentro de uma
tabela interna do Rails chamada `schema_migrations`. Esta tabela é usada para manter
um acompanhamento de quais *migrations* foram executadas em um ambiente específico.

Se você executar o comando `bin/rails db:migrate:status`, que mostra o estado (`up` ou
`down`) de cada *migration*, você verá o texto `********** NO FILE **********`
próximo a cada arquivo de *migration* excluído que foi anteriormente executado
em um ambiente específico mas não se encontra mais no diretório `db/migrate/`.

Porém, há uma advertência. As tarefas `rake` para instalar *migrations* de *engines* são idempotentes. As *migrations* presentes na aplicação principal vindas de uma instalação anterior são ignoradas e as que faltam são copiadas com um novo carimbo de data/hora (*timestamp*). Se você excluiu as *migrations* de *engines* antigas e executou a tarefa de instalação novamente, você obteria novos arquivos com novos carimbos de data/hora e o comando `db: migrate` tentaria executá-las novamente.

Portanto, geralmente você deseja preservar as *migrations* provenientes de *engines*. Elas têm um comentário especial como este:

```
# This migration comes from blorgh (originally 20210621082949)
```
