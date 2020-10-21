**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Interface de Consulta do *Active Record*
=============================

Este guia cobre diferentes maneiras de recuperar dados de um banco de dados utilizando o *Active Record*

Após ler esse guia, você saberá:

* Como encontrar registros usando uma variedade de métodos e condições.
* Como especificar a ordem, os atributos recuperados, agrupamento e outras propriedades dos registros encontrados.
* Como usar o *eager loading* para reduzir o número de consultas necessárias no banco de dados para recuperar os dados.
* Como utilizar métodos localizadores dinâmicos.
* Como utilizar encadeamento de métodos para usar múltiplos métodos do *Active Record* em conjunto.
* Como checar a existência de determinados registros.
* Como executar diversos cálculos nos *models* do *Active Record*.
* Como executar o *EXPLAIN* nas relações.

--------------------------------------------------------------------------------

Se você está acostumado com SQL puro para encontrar registros no banco de dados, então você provavelmente encontrará
maneiras melhores de realizar as mesmas operações no Rails. O *Active Record* te isola da necessidade de usar o SQL
na maioria dos casos.

Os exemplos de código ao longo desse guia irão se referir à um ou mais dos seguintes modelos:

TIP: Todos os *models* seguintes utilizam `id` como *primary key* (chave primária), a não ser quando especificado o
contrário.

```ruby
class Client < ApplicationRecord
  has_one :address
  has_many :orders
  has_and_belongs_to_many :roles
end
```

```ruby
class Address < ApplicationRecord
  belongs_to :client
end
```

```ruby
class Order < ApplicationRecord
  belongs_to :client, counter_cache: true
end
```

```ruby
class Role < ApplicationRecord
  has_and_belongs_to_many :clients
end
```

O *Active Record* irá executar consultas no banco de dados para você e é compatível com a maioria dos sistemas de banco de dados,
incluindo MySQL, MariaDB, PostgreSQL e SQLite. Independente de qual sistema de banco de dados você utilize, o formato do método do *Active Record*
será sempre o mesmo.

Recuperando Objetos do Banco de Dados
------------------------------------

Para recuperar objetos do banco de dados, o *Active Record* fornece diversos métodos de localização. Cada método de localização permite que você
passe argumentos para o mesmo para executar determinada consulta no seu banco de dados sem a necessidade de escrever SQL puro.

Os métodos são:

* `annotate`
* `find`
* `create_with`
* `distinct`
* `eager_load`
* `extending`
* `extract_associated`
* `from`
* `group`
* `having`
* `includes`
* `joins`
* `left_outer_joins`
* `limit`
* `lock`
* `none`
* `offset`
* `optimizer_hints`
* `order`
* `preload`
* `readonly`
* `references`
* `reorder`
* `reselect`
* `reverse_order`
* `select`
* `where`

Métodos de localização que retornam uma coleção, como o `where` e `group`, retornam uma instância do `ActiveRecord::Relation`.
Os métodos que localizam uma única entidade, como o `find` e o `first`, retornam uma única instância do *model*.

A principal operação do `Model.find(options)` pode ser resumida como:

* Converter as opções fornecidas em uma consulta equivalente no SQL.
* Disparar uma consulta SQL e recuperar os resultados correspondentes no banco de dados.
* Instanciar o objeto Ruby equivalente do *model* apropriado para cada linha resultante.
* Executar `after_find` e, em seguida, retornos de chamada com `after_initialize`, se houver.

### Retornando um Único Objeto

O *Active Record* possui diferentes formas de retornar um único objeto.

#### `find`

Utilizando o método `find`, você pode retornar o objeto correspondente à *primary key* especificada que corresponde às opções fornecidas.
Por exemplo:

```ruby
# Encontra o cliente com a primary key (id) 10.
client = Client.find(10)
# => #<Client id: 10, first_name: "Ryan">
```

O equivalente ao de cima, em SQL, seria:

```sql
SELECT * FROM clients WHERE (clients.id = 10) LIMIT 1
```

O método `find` irá gerar uma exceção `ActiveRecord::RecordNotFound` se nenhum registro correspondente for encontrado.

Você pode, também, utilizar este método para consultar múltiplos objetos. Chame o método `find` e passe um array de *primary keys*.
Será retornado um array contendo todos os registros correspondentes para as *primary keys* fornecidas. Por exemplo:

```ruby
# Encontra os clientes com as primary keys 1 e 10.
clients = Client.find([1, 10]) # Or even Client.find(1, 10)
# => [#<Client id: 1, first_name: "Lifo">, #<Client id: 10, first_name: "Ryan">]
```

O equivalente ao de cima, em SQL, seria:

```sql
SELECT * FROM clients WHERE (clients.id IN (1,10))
```

WARNING: O método `find` irá gerar uma excecão `ActiveRecord::RecordNotFound` a não ser que um registro correspondente seja encontrado para **todas** as primary keys fornecidas.

#### `take`

O método `take` retorna um registro sem nenhuma ordem implícita. Por exemplo:

```ruby
client = Client.take
# => #<Client id: 1, first_name: "Lifo">
```

O equivalente ao de cima, em SQL, seria:

```sql
SELECT * FROM clients LIMIT 1
```

O método `take` retorna `nil` se nenhum registro for encontrado e nenhuma exceção será levantada.

Você pode passar um argumento numérico para o método `take` para retornar o mesmo número em resultados. Por exemplo:

```ruby
clients = Client.take(2)
# => [
#   #<Client id: 1, first_name: "Lifo">,
#   #<Client id: 220, first_name: "Sara">
# ]
```

O equivalente ao de cima, em SQL, seria:

```sql
SELECT * FROM clients LIMIT 2
```

O método `take!` se comporta exatamente como o `take`, exceto que irá gerar uma exceção `ActiveRecord::RecordNotFound` caso não encontre nenhum registro correspondente.

TIP: O registro retornado pode variar dependendo do mecanismo do banco de dados.

#### `first`

O método `first` encontra o primeiro registro ordenado pela *primary key* (padrão). Por exemplo:

```ruby
client = Client.first
# => #<Client id: 1, first_name: "Lifo">
```

O equivalente ao de cima, em SQL, seria:

```sql
SELECT * FROM clients ORDER BY clients.id ASC LIMIT 1
```

O método `first` retorna `nil` se não for encontrado nenhum registro correspondente e nenhuma exceção é gerada.

Se o seu [default scope](active_record_querying.html#applying-a-default-scope) contém um método de ordenação, `first` irá retornar o primeiro
registro de acordo com essa ordenação.

Você pode passar um argumento número para o métoddo `first` para retornar o mesmo número em resultados. Por exemplo:

```ruby
clients = Client.first(3)
# => [
#   #<Client id: 1, first_name: "Lifo">,
#   #<Client id: 2, first_name: "Fifo">,
#   #<Client id: 3, first_name: "Filo">
# ]
```

O equivalente ao de cima, em SQL, seria:

```sql
SELECT * FROM clients ORDER BY clients.id ASC LIMIT 3
```

Em uma coleção ordenada utilizando o `order`, `first` irá retornar o primeiro registro que foi ordenado com o atributo especificado em `order`.

```ruby
client = Client.order(:first_name).first
# => #<Client id: 2, first_name: "Fifo">
```

O equivalente ao de cima, em SQL, seria:

```sql
SELECT * FROM clients ORDER BY clients.first_name ASC LIMIT 1
```

O método `first!` se comporta exatamente como o `first`, exceto que irá gerar uma exceção `ActiveRecord::RecordNotFound` se nenhum registro
correspondente for encontrado.

#### `last`

O método `last` encontra o último registro ordenado pela *primary key* (padrão). Por exemplo:

```ruby
client = Client.last
# => #<Client id: 221, first_name: "Russel">
```

O equivalente ao de cima, em SQL, seria:

```sql
SELECT * FROM clients ORDER BY clients.id DESC LIMIT 1
```

O método `last` retorna `nil` se não encontrar nenhum registro correspondente e nenhuma exceção será levantada.

Se o seu [default scope](active_record_querying.html#applying-a-default-scope) contém um método de ordenação, `last` irá retornar
o último registro de acordo com essa ordenação.

Você pode passar um argumento número para o método `last` para retornar o mesmo número em resultados. Por exemplo:

```ruby
clients = Client.last(3)
# => [
#   #<Client id: 219, first_name: "James">,
#   #<Client id: 220, first_name: "Sara">,
#   #<Client id: 221, first_name: "Russel">
# ]
```

O equivalente ao de cima, em SQL, seria:

```sql
SELECT * FROM clients ORDER BY clients.id DESC LIMIT 3
```

Em uma coleção ordenada utilizando o `order`, `last` irá retornar o último registro que foi ordenado com o atributo especificado em `order`.

```ruby
client = Client.order(:first_name).last
# => #<Client id: 220, first_name: "Sara">
```

O equivalente ao de cima, em SQL, seria:

```sql
SELECT * FROM clients ORDER BY clients.first_name DESC LIMIT 1
```

O método `last!` se comporta exatamente como o `last`, exceto que irá gerar uma exceção `ActiveRecord::RecordNotFound` se nenhum registro
correspondente for encontrado.

#### `find_by`

O método `find_by` irá retornar o primeiro registro que corresponde às condições. Por exemplo:

```ruby
Client.find_by first_name: 'Lifo'
# => #<Client id: 1, first_name: "Lifo">

Client.find_by first_name: 'Jon'
# => nil
```

É equivalente à escrever:

```ruby
Client.where(first_name: 'Lifo').take
```

O equivalente ao de cima, em SQL, seria

```sql
SELECT * FROM clients WHERE (clients.first_name = 'Lifo') LIMIT 1
```

O método `find_by` se comporta exatamente como o `find_by`, exceto que irá gerar uma exceção `ActiveRecord::RecordNotFound` se nenhum registro
correspondente for encontrado. Por exemplo:

```ruby
Client.find_by! first_name: 'does not exist'
# => ActiveRecord::RecordNotFound
```

Isto é equivalente à escrever:

```ruby
Client.where(first_name: 'does not exist').take!
```

### Retornando Múltiplos Objetos em Lotes

Nós frequentemente precisamos iterar sobre um grande número de registros, seja quando precisamos enviar *newsletter* para
um grande número de usuários, ou quando vamos exportar dados.

Isso pode parecer simples:

```ruby
# Isso pode consumir muita memória se a tabela for grande.
User.all.each do |user|
  NewsMailer.weekly(user).deliver_now
end
```

Mas essa abordagem se torna cada vez mais impraticável à medida que o tamanho da tabela aumenta, pois o `User.all.each`
instrui o *Active Record* à buscar a **tabela inteira** em uma única passagem, cria um *model* de objeto por linha e
mantém todo o array de objetos de *model* na memória. De fato, se você tem um grande número de registros, a coleção inteira
pode exceder a quantidade de memória disponível.

O Rails fornece dois métodos para solucionar esse problema, dividindo os registros em lotes *memory-friendly* para o processamento.
O primeiro método, `find_each`, retorna um lote de registros e depois submete _cada_ registro individualmente para um bloco como um *model*.
O segundo método, `find_in_batches`, retorna um lote de registros e depois submete _o lote inteiro_ ao bloco como um array de *models*.

TIP: Os métodos `find_each` e `find_in_batches` são destinados ao uso no processamento em lotes de grandes numéros de registros
que não irão caber na memória de uma só vez. Se você apenas precisa fazer um  *loop* em milhares de registros, os métodos
regulares do `find` são a opção preferida.

#### `find_each`

O método `find_each` retorna os registros em lotes e depois aloca _cada_ um no bloco. No exemplo a seguir, `find_each` retorna
*users* em lotes de 1000 e os aloca no bloco um à um:

```ruby
User.find_each do |user|
  NewsMailer.weekly(user).deliver_now
end
```

Esse processo é repetido, buscando mais lotes sempre que preciso, até que todos os registros tenham sido processados.

`find_each` funciona com classes de *model*, como visto acima, assim como relações:

```ruby
User.where(weekly_subscriber: true).find_each do |user|
  NewsMailer.weekly(user).deliver_now
end
```

contanto que ele não tenha nenhuma ordenação, pois o método necessita forçar uma ordem interna para iterar.

Se houver uma ordem presente no receptor, o comportamento depende da *flag* `config.active_record.error_on_ignored_order`.
Se verdadeiro, `ArgumentError` é levantado, caso contrário a ordem será ignorada e um aviso gerado, que é o padrão. Isto pode
ser substituído com a opção `:error_on_ignore`, explicado abaixo.

##### Options for `find_each`

##### Opções para `find_each`

**`:batch_size`**

A opção `:batch_size` permite que você especifique o número de registros à serem retornados em cada lote, antes de serem passados, individualmente, para o bloco.
Por exemplo, para retornar registros de um lote de 5000:

```ruby
User.find_each(batch_size: 5000) do |user|
  NewsMailer.weekly(user).deliver_now
end
```

**`:start`**

Por padrão, os registros são buscados em ordem ascendente de *primary key*. A opção `:start` permite que você configure o primeiro ID da sequência sempre que o menor
ID não seja o que você precisa. Isto pode ser útil, por exemplo, se você quer retomar um processo interrompido de lotes, desde que você
tenha salvo o último ID processado como ponto de retorno.

Por exemplo, para enviar *newsletters* apenas para os usuários com a *primary key* começando com 2000:

```ruby
User.find_each(start: 2000) do |user|
  NewsMailer.weekly(user).deliver_now
end
```

**`:finish`**

Similar à opção `:start`, `:finish` permite que você configure o último ID da sequência sempre que o maior ID não seja o que você necessite.
Isso pode ser útil, por exemplo, se você quer executar um processo de lotes utilizando subconjuntos de registros baseados no `:start` e `:finish`

Por exemplo, para enviar *newsletters* apenas para os usuários com a *primary key* começando em 2000 e indo até 10000:

```ruby
User.find_each(start: 2000, finish: 10000) do |user|
  NewsMailer.weekly(user).deliver_now
end
```

Outro exemplo seria se você queira múltiplos *workers* manipulando a mesma fila de processamento. Você pode ter cada *worker*
lidando com 10000 registros atribuindo a opção `:start` e `finish` apropriadas para cada *worker*

**`:error_on_ignore`**

Sobrescreve as configurações da aplicação para especificar se um erro deve ser levantado quando a ordem está presente
na relação.

#### `find_in_batches`

O método `find_in_batches` é similar ao `find_each`, pois ambos retornam lotes de registros. A diferença é que o `find_in_batches` fornece _lotes_ ao bloco como um array de *models*,
em vez de individualmente. O exemplo à seguir irá produzir ao bloco fornecido um array com até 1000 notas fiscais de uma vez,
com o bloco final contendo qualquer nota fiscal remanescente:

```ruby
# Fornece à add_invoices um array com 1000 notas fiscais de uma vez.
Invoice.find_in_batches do |invoices|
  export.add_invoices(invoices)
end
```

`find_in_batches` funcional com classes de *model*, como visto acima, e também com relações:

```ruby
Invoice.pending.find_in_batches do |invoices|
  pending_invoices_export.add_invoices(invoices)
end
```

contanto que não há ordenação, pois o método irá forçar uma ordem interna para a iteração.

##### Opções para`find_in_batches`

O método `find_in_batches` aceita as mesmas opção que o `find_each`

Conditions
----------

The `where` method allows you to specify conditions to limit the records returned, representing the `WHERE`-part of the SQL statement. Conditions can either be specified as a string, array, or hash.

### Pure String Conditions

If you'd like to add conditions to your find, you could just specify them in there, just like `Client.where("orders_count = '2'")`. This will find all clients where the `orders_count` field's value is 2.

WARNING: Building your own conditions as pure strings can leave you vulnerable to SQL injection exploits. For example, `Client.where("first_name LIKE '%#{params[:first_name]}%'")` is not safe. See the next section for the preferred way to handle conditions using an array.

### Array Conditions

Now what if that number could vary, say as an argument from somewhere? The find would then take the form:

```ruby
Client.where("orders_count = ?", params[:orders])
```

Active Record will take the first argument as the conditions string and any additional arguments will replace the question marks `(?)` in it.

If you want to specify multiple conditions:

```ruby
Client.where("orders_count = ? AND locked = ?", params[:orders], false)
```

In this example, the first question mark will be replaced with the value in `params[:orders]` and the second will be replaced with the SQL representation of `false`, which depends on the adapter.

This code is highly preferable:

```ruby
Client.where("orders_count = ?", params[:orders])
```

to this code:

```ruby
Client.where("orders_count = #{params[:orders]}")
```

because of argument safety. Putting the variable directly into the conditions string will pass the variable to the database **as-is**. This means that it will be an unescaped variable directly from a user who may have malicious intent. If you do this, you put your entire database at risk because once a user finds out they can exploit your database they can do just about anything to it. Never ever put your arguments directly inside the conditions string.

TIP: For more information on the dangers of SQL injection, see the [Ruby on Rails Security Guide](security.html#sql-injection).

#### Placeholder Conditions

Similar to the `(?)` replacement style of params, you can also specify keys in your conditions string along with a corresponding keys/values hash:

```ruby
Client.where("created_at >= :start_date AND created_at <= :end_date",
  {start_date: params[:start_date], end_date: params[:end_date]})
```

This makes for clearer readability if you have a large number of variable conditions.

### Hash Conditions

Active Record also allows you to pass in hash conditions which can increase the readability of your conditions syntax. With hash conditions, you pass in a hash with keys of the fields you want qualified and the values of how you want to qualify them:

NOTE: Only equality, range, and subset checking are possible with Hash conditions.

#### Equality Conditions

```ruby
Client.where(locked: true)
```

This will generate SQL like this:

```sql
SELECT * FROM clients WHERE (clients.locked = 1)
```

The field name can also be a string:

```ruby
Client.where('locked' => true)
```

In the case of a belongs_to relationship, an association key can be used to specify the model if an Active Record object is used as the value. This method works with polymorphic relationships as well.

```ruby
Article.where(author: author)
Author.joins(:articles).where(articles: { author: author })
```

#### Range Conditions

```ruby
Client.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight)
```

This will find all clients created yesterday by using a `BETWEEN` SQL statement:

```sql
SELECT * FROM clients WHERE (clients.created_at BETWEEN '2008-12-21 00:00:00' AND '2008-12-22 00:00:00')
```

This demonstrates a shorter syntax for the examples in [Array Conditions](#array-conditions)

#### Subset Conditions

If you want to find records using the `IN` expression you can pass an array to the conditions hash:

```ruby
Client.where(orders_count: [1,3,5])
```

This code will generate SQL like this:

```sql
SELECT * FROM clients WHERE (clients.orders_count IN (1,3,5))
```

### NOT Conditions

`NOT` SQL queries can be built by `where.not`:

```ruby
Client.where.not(locked: true)
```

In other words, this query can be generated by calling `where` with no argument, then immediately chain with `not` passing `where` conditions.  This will generate SQL like this:

```sql
SELECT * FROM clients WHERE (clients.locked != 1)
```

### OR Conditions

`OR` conditions between two relations can be built by calling `or` on the first
relation, and passing the second one as an argument.

```ruby
Client.where(locked: true).or(Client.where(orders_count: [1,3,5]))
```

```sql
SELECT * FROM clients WHERE (clients.locked = 1 OR clients.orders_count IN (1,3,5))
```

Ordenando
--------

Para recuperar registros do banco de dados em uma ordem específica, você pode usar o método de `order`.

Por exemplo, se você deseja obter um conjunto de registros e ordená-los em ordem crescente pelo campo `created_at` na sua tabela:

```ruby
Client.order(:created_at)
# OU
Client.order("created_at")
```

Você também pode especificar `ASC` ou` DESC`:

```ruby
Client.order(created_at: :desc)
# OU
Client.order(created_at: :asc)
# OU
Client.order("created_at DESC")
# OU
Client.order("created_at ASC")
```

Ou ordenar por campos diversos:

```ruby
Client.order(orders_count: :asc, created_at: :desc)
# OU
Client.order(:orders_count, created_at: :desc)
# OU
Client.order("orders_count ASC, created_at DESC")
# OU
Client.order("orders_count ASC", "created_at DESC")
```

Se você quiser chamar `order` várias vezes, as ordens subsequentes serão anexados à primeira:

```ruby
Client.order("orders_count ASC").order("created_at DESC")
# SELECT * FROM clients ORDER BY orders_count ASC, created_at DESC
```

WARNING: Na maioria dos sistemas de banco de dados, ao selecionar campos com `distinct` de um conjunto de resultados usando métodos como` select`, `pluck` e `ids`; o método `order` gerará uma exceção `ActiveRecord::StatementInvalid`, a menos que o(s) campo(s) usados ​​na cláusula `order` estejam incluídos na lista de seleção. Consulte a próxima seção para selecionar campos do conjunto de resultados.

Selecting Specific Fields
-------------------------

By default, `Model.find` selects all the fields from the result set using `select *`.

To select only a subset of fields from the result set, you can specify the subset via the `select` method.

For example, to select only `viewable_by` and `locked` columns:

```ruby
Client.select(:viewable_by, :locked)
# OR
Client.select("viewable_by, locked")
```

The SQL query used by this find call will be somewhat like:

```sql
SELECT viewable_by, locked FROM clients
```

Be careful because this also means you're initializing a model object with only the fields that you've selected. If you attempt to access a field that is not in the initialized record you'll receive:

```bash
ActiveModel::MissingAttributeError: missing attribute: <attribute>
```

Where `<attribute>` is the attribute you asked for. The `id` method will not raise the `ActiveRecord::MissingAttributeError`, so just be careful when working with associations because they need the `id` method to function properly.

If you would like to only grab a single record per unique value in a certain field, you can use `distinct`:

```ruby
Client.select(:name).distinct
```

This would generate SQL like:

```sql
SELECT DISTINCT name FROM clients
```

You can also remove the uniqueness constraint:

```ruby
query = Client.select(:name).distinct
# => Returns unique names

query.distinct(false)
# => Returns all names, even if there are duplicates
```

Limit and Offset
----------------

To apply `LIMIT` to the SQL fired by the `Model.find`, you can specify the `LIMIT` using `limit` and `offset` methods on the relation.

You can use `limit` to specify the number of records to be retrieved, and use `offset` to specify the number of records to skip before starting to return the records. For example

```ruby
Client.limit(5)
```

will return a maximum of 5 clients and because it specifies no offset it will return the first 5 in the table. The SQL it executes looks like this:

```sql
SELECT * FROM clients LIMIT 5
```

Adding `offset` to that

```ruby
Client.limit(5).offset(30)
```

will return instead a maximum of 5 clients beginning with the 31st. The SQL looks like:

```sql
SELECT * FROM clients LIMIT 5 OFFSET 30
```

Group
-----

To apply a `GROUP BY` clause to the SQL fired by the finder, you can use the `group` method.

For example, if you want to find a collection of the dates on which orders were created:

```ruby
Order.select("date(created_at) as ordered_date, sum(price) as total_price").group("date(created_at)")
```

And this will give you a single `Order` object for each date where there are orders in the database.

The SQL that would be executed would be something like this:

```sql
SELECT date(created_at) as ordered_date, sum(price) as total_price
FROM orders
GROUP BY date(created_at)
```

### Total of grouped items

To get the total of grouped items on a single query, call `count` after the `group`.

```ruby
Order.group(:status).count
# => { 'awaiting_approval' => 7, 'paid' => 12 }
```

The SQL that would be executed would be something like this:

```sql
SELECT COUNT (*) AS count_all, status AS status
FROM "orders"
GROUP BY status
```

Having
------

SQL uses the `HAVING` clause to specify conditions on the `GROUP BY` fields. You can add the `HAVING` clause to the SQL fired by the `Model.find` by adding the `having` method to the find.

For example:

```ruby
Order.select("date(created_at) as ordered_date, sum(price) as total_price").
  group("date(created_at)").having("sum(price) > ?", 100)
```

The SQL that would be executed would be something like this:

```sql
SELECT date(created_at) as ordered_date, sum(price) as total_price
FROM orders
GROUP BY date(created_at)
HAVING sum(price) > 100
```

This returns the date and total price for each order object, grouped by the day they were ordered and where the price is more than $100.

Overriding Conditions
---------------------

### `unscope`

You can specify certain conditions to be removed using the `unscope` method. For example:

```ruby
Article.where('id > 10').limit(20).order('id asc').unscope(:order)
```

The SQL that would be executed:

```sql
SELECT * FROM articles WHERE id > 10 LIMIT 20

# Original query without `unscope`
SELECT * FROM articles WHERE id > 10 ORDER BY id asc LIMIT 20

```

You can also unscope specific `where` clauses. For example:

```ruby
Article.where(id: 10, trashed: false).unscope(where: :id)
# SELECT "articles".* FROM "articles" WHERE trashed = 0
```

A relation which has used `unscope` will affect any relation into which it is merged:

```ruby
Article.order('id asc').merge(Article.unscope(:order))
# SELECT "articles".* FROM "articles"
```

### `only`

You can also override conditions using the `only` method. For example:

```ruby
Article.where('id > 10').limit(20).order('id desc').only(:order, :where)
```

The SQL that would be executed:

```sql
SELECT * FROM articles WHERE id > 10 ORDER BY id DESC

# Original query without `only`
SELECT * FROM articles WHERE id > 10 ORDER BY id DESC LIMIT 20

```

### `reselect`

The `reselect` method overrides an existing select statement. For example:

```ruby
Post.select(:title, :body).reselect(:created_at)
```

The SQL that would be executed:

```sql
SELECT `posts`.`created_at` FROM `posts`
```

In case the `reselect` clause is not used,

```ruby
Post.select(:title, :body).select(:created_at)
```

the SQL executed would be:

```sql
SELECT `posts`.`title`, `posts`.`body`, `posts`.`created_at` FROM `posts`
```

### `reorder`

The `reorder` method overrides the default scope order. For example:

```ruby
class Article < ApplicationRecord
  has_many :comments, -> { order('posted_at DESC') }
end

Article.find(10).comments.reorder('name')
```

The SQL that would be executed:

```sql
SELECT * FROM articles WHERE id = 10 LIMIT 1
SELECT * FROM comments WHERE article_id = 10 ORDER BY name
```

In the case where the `reorder` clause is not used, the SQL executed would be:

```sql
SELECT * FROM articles WHERE id = 10 LIMIT 1
SELECT * FROM comments WHERE article_id = 10 ORDER BY posted_at DESC
```

### `reverse_order`

The `reverse_order` method reverses the ordering clause if specified.

```ruby
Client.where("orders_count > 10").order(:name).reverse_order
```

The SQL that would be executed:

```sql
SELECT * FROM clients WHERE orders_count > 10 ORDER BY name DESC
```

If no ordering clause is specified in the query, the `reverse_order` orders by the primary key in reverse order.

```ruby
Client.where("orders_count > 10").reverse_order
```

The SQL that would be executed:

```sql
SELECT * FROM clients WHERE orders_count > 10 ORDER BY clients.id DESC
```

This method accepts **no** arguments.

### `rewhere`

The `rewhere` method overrides an existing, named where condition. For example:

```ruby
Article.where(trashed: true).rewhere(trashed: false)
```

The SQL that would be executed:

```sql
SELECT * FROM articles WHERE `trashed` = 0
```

In case the `rewhere` clause is not used,

```ruby
Article.where(trashed: true).where(trashed: false)
```

the SQL executed would be:

```sql
SELECT * FROM articles WHERE `trashed` = 1 AND `trashed` = 0
```

Null Relation
-------------

The `none` method returns a chainable relation with no records. Any subsequent conditions chained to the returned relation will continue generating empty relations. This is useful in scenarios where you need a chainable response to a method or a scope that could return zero results.

```ruby
Article.none # returns an empty Relation and fires no queries.
```

```ruby
# The visible_articles method below is expected to return a Relation.
@articles = current_user.visible_articles.where(name: params[:name])

def visible_articles
  case role
  when 'Country Manager'
    Article.where(country: country)
  when 'Reviewer'
    Article.published
  when 'Bad User'
    Article.none # => returning [] or nil breaks the caller code in this case
  end
end
```

Readonly Objects
----------------

Active Record provides the `readonly` method on a relation to explicitly disallow modification of any of the returned objects. Any attempt to alter a readonly record will not succeed, raising an `ActiveRecord::ReadOnlyRecord` exception.

```ruby
client = Client.readonly.first
client.visits += 1
client.save
```

As `client` is explicitly set to be a readonly object, the above code will raise an `ActiveRecord::ReadOnlyRecord` exception when calling `client.save` with an updated value of _visits_.

Bloqueando registros para alteração
-----------------------------------

O bloqueio é útil para prevenir condições de corrida ao alterar registros no banco de dados e para garantir alterações atômicas.

O Active Record provê dois mecanismos de bloqueio:

* Bloqueio otimista
* Bloqueio pessimista

### Bloqueio Otimista

O bloqueio otimista permite que múltiplos usuários acessem o mesmo registro para edição e presume um mínimo de conflitos com os dados. Isto é feito verificando se outro processo fez mudanças em um registro desde que ele foi aberto. Uma exceção `ActiveRecord::StaleObjectError` é disparada se isso ocorreu e a alteração é ignorada.

**Coluna de bloqueio otimista**

Para usar o bloqueio otimista, a tabela precisa ter uma coluna chamada `lock_version` do tipo inteiro. Cada vez que o registro é alterado, o Active Record incrementa o valor na coluna `lock_version`. Se uma requisição de alteração é feita com um valor menor no campo `lock_version` do que o valor que está atualmente na coluna `lock_version` no banco de dados, a requisição de alteração falhará com um `ActiveRecord::StaleObjectError`. Por exemplo:

```ruby
c1 = Client.find(1)
c2 = Client.find(1)

c1.first_name = "Michael"
c1.save

c2.name = "vai falhar"
c2.save # Dispara um ActiveRecord::StaleObjectError
```

Você fica então responsável por lidar com o conflito tratando a exceção e desfazendo as alterações, agrupando-as ou aplicando a lógica de negócio necessária para resolver o conflito.

Este comportamento pode ser desativado definindo `ActiveRecord::Base.lock_optimistically = false`.

Para usar outro nome para a coluna `lock_version`, `ActiveRecord::Base` oferece um atributo de classe chamado `locking_column`:

```ruby
class Client < ApplicationRecord
  self.locking_column = :lock_client_column
end
```

### Bloqueio pessimista

O bloqueio pessimista usa um mecansimo de bloqueio fornecido pelo banco de dados subjacente. Ao usar `lock` quando uma *relation* (objeto do tipo ActiveRecord::Relation) é criada, obtém-se um bloqueio exclusivo nas linhas selecionadas. Relations usando `lock` são normalmente executadas dentro de uma transação para permitir condições de deadlock.

Por exemplo:

```ruby
Item.transaction do
  i = Item.lock.first
  i.name = 'Jones'
  i.save!
end
```

A sessão acima produz o seguinte SQL para um banco de dados MySQL:

```sql
SQL (0.2ms)   BEGIN
Item Load (0.3ms)   SELECT * FROM `items` LIMIT 1 FOR UPDATE
Item Update (0.4ms)   UPDATE `items` SET `updated_at` = '2009-02-07 18:05:56', `name` = 'Jones' WHERE `id` = 1
SQL (0.8ms)   COMMIT
```

Você também pode passar SQL diretamente para o método `lock` para permitir diferentes tipos de bloqueio. Por exemplo, MySQL tem uma expressão chamada `LOCK IN SHARE MODE` que permite bloquear um registro mas ainda assim permitir que outras consultas o leiam. Para especificar esta expressão, basta passá-la ao método `lock`:

```ruby
Item.transaction do
  i = Item.lock("LOCK IN SHARE MODE").find(1)
  i.increment!(:views)
end
```

Se você já tem uma instância do seu modelo, você pode iniciar uma transação e obter o bloqueio de uma vez só usando o código seguinte:

```ruby
item = Item.first
item.with_lock do
  # Este bloco é chamado dentro de uma transação,
  # o item já está bloqueado.
  item.increment!(:views)
end
```

Joining Tables
--------------

Active Record provides two finder methods for specifying `JOIN` clauses on the
resulting SQL: `joins` and `left_outer_joins`.
While `joins` should be used for `INNER JOIN` or custom queries,
`left_outer_joins` is used for queries using `LEFT OUTER JOIN`.

### `joins`

There are multiple ways to use the `joins` method.

#### Using a String SQL Fragment

You can just supply the raw SQL specifying the `JOIN` clause to `joins`:

```ruby
Author.joins("INNER JOIN posts ON posts.author_id = authors.id AND posts.published = 't'")
```

This will result in the following SQL:

```sql
SELECT authors.* FROM authors INNER JOIN posts ON posts.author_id = authors.id AND posts.published = 't'
```

#### Using Array/Hash of Named Associations

Active Record lets you use the names of the [associations](association_basics.html) defined on the model as a shortcut for specifying `JOIN` clauses for those associations when using the `joins` method.

For example, consider the following `Category`, `Article`, `Comment`, `Guest` and `Tag` models:

```ruby
class Category < ApplicationRecord
  has_many :articles
end

class Article < ApplicationRecord
  belongs_to :category
  has_many :comments
  has_many :tags
end

class Comment < ApplicationRecord
  belongs_to :article
  has_one :guest
end

class Guest < ApplicationRecord
  belongs_to :comment
end

class Tag < ApplicationRecord
  belongs_to :article
end
```

Now all of the following will produce the expected join queries using `INNER JOIN`:

##### Joining a Single Association

```ruby
Category.joins(:articles)
```

This produces:

```sql
SELECT categories.* FROM categories
  INNER JOIN articles ON articles.category_id = categories.id
```

Or, in English: "return a Category object for all categories with articles". Note that you will see duplicate categories if more than one article has the same category. If you want unique categories, you can use `Category.joins(:articles).distinct`.

#### Joining Multiple Associations

```ruby
Article.joins(:category, :comments)
```

This produces:

```sql
SELECT articles.* FROM articles
  INNER JOIN categories ON categories.id = articles.category_id
  INNER JOIN comments ON comments.article_id = articles.id
```

Or, in English: "return all articles that have a category and at least one comment". Note again that articles with multiple comments will show up multiple times.

##### Joining Nested Associations (Single Level)

```ruby
Article.joins(comments: :guest)
```

This produces:

```sql
SELECT articles.* FROM articles
  INNER JOIN comments ON comments.article_id = articles.id
  INNER JOIN guests ON guests.comment_id = comments.id
```

Or, in English: "return all articles that have a comment made by a guest."

##### Joining Nested Associations (Multiple Level)

```ruby
Category.joins(articles: [{ comments: :guest }, :tags])
```

This produces:

```sql
SELECT categories.* FROM categories
  INNER JOIN articles ON articles.category_id = categories.id
  INNER JOIN comments ON comments.article_id = articles.id
  INNER JOIN guests ON guests.comment_id = comments.id
  INNER JOIN tags ON tags.article_id = articles.id
```

Or, in English: "return all categories that have articles, where those articles have a comment made by a guest, and where those articles also have a tag."

#### Specifying Conditions on the Joined Tables

You can specify conditions on the joined tables using the regular [Array](#array-conditions) and [String](#pure-string-conditions) conditions. [Hash conditions](#hash-conditions) provide a special syntax for specifying conditions for the joined tables:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Client.joins(:orders).where('orders.created_at' => time_range)
```

An alternative and cleaner syntax is to nest the hash conditions:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Client.joins(:orders).where(orders: { created_at: time_range })
```

This will find all clients who have orders that were created yesterday, again using a `BETWEEN` SQL expression.

### `left_outer_joins`

If you want to select a set of records whether or not they have associated
records you can use the `left_outer_joins` method.

```ruby
Author.left_outer_joins(:posts).distinct.select('authors.*, COUNT(posts.*) AS posts_count').group('authors.id')
```

Which produces:

```sql
SELECT DISTINCT authors.*, COUNT(posts.*) AS posts_count FROM "authors"
LEFT OUTER JOIN posts ON posts.author_id = authors.id GROUP BY authors.id
```

Which means: "return all authors with their count of posts, whether or not they
have any posts at all"


Eager Loading Associations
--------------------------

Eager loading is the mechanism for loading the associated records of the objects returned by `Model.find` using as few queries as possible.

**N + 1 queries problem**

Consider the following code, which finds 10 clients and prints their postcodes:

```ruby
clients = Client.limit(10)

clients.each do |client|
  puts client.address.postcode
end
```

This code looks fine at the first sight. But the problem lies within the total number of queries executed. The above code executes 1 (to find 10 clients) + 10 (one per each client to load the address) = **11** queries in total.

**Solution to N + 1 queries problem**

Active Record lets you specify in advance all the associations that are going to be loaded. This is possible by specifying the `includes` method of the `Model.find` call. With `includes`, Active Record ensures that all of the specified associations are loaded using the minimum possible number of queries.

Revisiting the above case, we could rewrite `Client.limit(10)` to eager load addresses:

```ruby
clients = Client.includes(:address).limit(10)

clients.each do |client|
  puts client.address.postcode
end
```

The above code will execute just **2** queries, as opposed to **11** queries in the previous case:

```sql
SELECT * FROM clients LIMIT 10
SELECT addresses.* FROM addresses
  WHERE (addresses.client_id IN (1,2,3,4,5,6,7,8,9,10))
```

### Eager Loading Multiple Associations

Active Record lets you eager load any number of associations with a single `Model.find` call by using an array, hash, or a nested hash of array/hash with the `includes` method.

#### Array of Multiple Associations

```ruby
Article.includes(:category, :comments)
```

This loads all the articles and the associated category and comments for each article.

#### Nested Associations Hash

```ruby
Category.includes(articles: [{ comments: :guest }, :tags]).find(1)
```

This will find the category with id 1 and eager load all of the associated articles, the associated articles' tags and comments, and every comment's guest association.

### Specifying Conditions on Eager Loaded Associations

Even though Active Record lets you specify conditions on the eager loaded associations just like `joins`, the recommended way is to use [joins](#joining-tables) instead.

However if you must do this, you may use `where` as you would normally.

```ruby
Article.includes(:comments).where(comments: { visible: true })
```

This would generate a query which contains a `LEFT OUTER JOIN` whereas the
`joins` method would generate one using the `INNER JOIN` function instead.

```ruby
  SELECT "articles"."id" AS t0_r0, ... "comments"."updated_at" AS t1_r5 FROM "articles" LEFT OUTER JOIN "comments" ON "comments"."article_id" = "articles"."id" WHERE (comments.visible = 1)
```

If there was no `where` condition, this would generate the normal set of two queries.

NOTE: Using `where` like this will only work when you pass it a Hash. For
SQL-fragments you need to use `references` to force joined tables:

```ruby
Article.includes(:comments).where("comments.visible = true").references(:comments)
```

If, in the case of this `includes` query, there were no comments for any
articles, all the articles would still be loaded. By using `joins` (an INNER
JOIN), the join conditions **must** match, otherwise no records will be
returned.

NOTE: If an association is eager loaded as part of a join, any fields from a custom select clause will not be present on the loaded models.
This is because it is ambiguous whether they should appear on the parent record, or the child.

Scopes
------

Scoping allows you to specify commonly-used queries which can be referenced as method calls on the association objects or models. With these scopes, you can use every method previously covered such as `where`, `joins` and `includes`. All scope bodies should return an `ActiveRecord::Relation` or `nil` to allow for further methods (such as other scopes) to be called on it.

To define a simple scope, we use the `scope` method inside the class, passing the query that we'd like to run when this scope is called:

```ruby
class Article < ApplicationRecord
  scope :published, -> { where(published: true) }
end
```

Scopes are also chainable within scopes:

```ruby
class Article < ApplicationRecord
  scope :published,               -> { where(published: true) }
  scope :published_and_commented, -> { published.where("comments_count > 0") }
end
```

To call this `published` scope we can call it on either the class:

```ruby
Article.published # => [published articles]
```

Or on an association consisting of `Article` objects:

```ruby
category = Category.first
category.articles.published # => [published articles belonging to this category]
```

### Passing in arguments

Your scope can take arguments:

```ruby
class Article < ApplicationRecord
  scope :created_before, ->(time) { where("created_at < ?", time) }
end
```

Call the scope as if it were a class method:

```ruby
Article.created_before(Time.zone.now)
```

However, this is just duplicating the functionality that would be provided to you by a class method.

```ruby
class Article < ApplicationRecord
  def self.created_before(time)
    where("created_at < ?", time)
  end
end
```

Using a class method is the preferred way to accept arguments for scopes. These methods will still be accessible on the association objects:

```ruby
category.articles.created_before(time)
```

### Using conditionals

Your scope can utilize conditionals:

```ruby
class Article < ApplicationRecord
  scope :created_before, ->(time) { where("created_at < ?", time) if time.present? }
end
```

Like the other examples, this will behave similarly to a class method.

```ruby
class Article < ApplicationRecord
  def self.created_before(time)
    where("created_at < ?", time) if time.present?
  end
end
```

However, there is one important caveat: A scope will always return an `ActiveRecord::Relation` object, even if the conditional evaluates to `false`, whereas a class method, will return `nil`. This can cause `NoMethodError` when chaining class methods with conditionals, if any of the conditionals return `false`.

### Applying a default scope

If we wish for a scope to be applied across all queries to the model we can use the
`default_scope` method within the model itself.

```ruby
class Client < ApplicationRecord
  default_scope { where("removed_at IS NULL") }
end
```

When queries are executed on this model, the SQL query will now look something like
this:

```sql
SELECT * FROM clients WHERE removed_at IS NULL
```

If you need to do more complex things with a default scope, you can alternatively
define it as a class method:

```ruby
class Client < ApplicationRecord
  def self.default_scope
    # Should return an ActiveRecord::Relation.
  end
end
```

NOTE: The `default_scope` is also applied while creating/building a record
when the scope arguments are given as a `Hash`. It is not applied while
updating a record. E.g.:

```ruby
class Client < ApplicationRecord
  default_scope { where(active: true) }
end

Client.new          # => #<Client id: nil, active: true>
Client.unscoped.new # => #<Client id: nil, active: nil>
```

Be aware that, when given in the `Array` format, `default_scope` query arguments
cannot be converted to a `Hash` for default attribute assignment. E.g.:

```ruby
class Client < ApplicationRecord
  default_scope { where("active = ?", true) }
end

Client.new # => #<Client id: nil, active: nil>
```

### Merging of scopes

Just like `where` clauses scopes are merged using `AND` conditions.

```ruby
class User < ApplicationRecord
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.active.inactive
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active' AND "users"."state" = 'inactive'
```

We can mix and match `scope` and `where` conditions and the final sql
will have all conditions joined with `AND`.

```ruby
User.active.where(state: 'finished')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active' AND "users"."state" = 'finished'
```

If we do want the last `where` clause to win then `Relation#merge` can
be used.

```ruby
User.active.merge(User.inactive)
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

One important caveat is that `default_scope` will be prepended in
`scope` and `where` conditions.

```ruby
class User < ApplicationRecord
  default_scope { where state: 'pending' }
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.all
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending'

User.active
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'active'

User.where(state: 'inactive')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'pending' AND "users"."state" = 'inactive'
```

As you can see above the `default_scope` is being merged in both
`scope` and `where` conditions.

### Removing All Scoping

If we wish to remove scoping for any reason we can use the `unscoped` method. This is
especially useful if a `default_scope` is specified in the model and should not be
applied for this particular query.

```ruby
Client.unscoped.load
```

This method removes all scoping and will do a normal query on the table.

```ruby
Client.unscoped.all
# SELECT "clients".* FROM "clients"

Client.where(published: false).unscoped.all
# SELECT "clients".* FROM "clients"
```

`unscoped` can also accept a block.

```ruby
Client.unscoped {
  Client.created_before(Time.zone.now)
}
```

Dynamic Finders
---------------

For every field (also known as an attribute) you define in your table, Active Record provides a finder method. If you have a field called `first_name` on your `Client` model for example, you get `find_by_first_name` for free from Active Record. If you have a `locked` field on the `Client` model, you also get `find_by_locked` method.

You can specify an exclamation point (`!`) on the end of the dynamic finders to get them to raise an `ActiveRecord::RecordNotFound` error if they do not return any records, like `Client.find_by_name!("Ryan")`

If you want to find both by name and locked, you can chain these finders together by simply typing "`and`" between the fields. For example, `Client.find_by_first_name_and_locked("Ryan", true)`.

Enums
-----

The `enum` macro maps an integer column to a set of possible values.

```ruby
class Book < ApplicationRecord
  enum availability: [:available, :unavailable]
end
```

This will automatically create the corresponding [scopes](#scopes) to query the
model. Methods to transition between states and query the current state are also
added.

```ruby
# Both examples below query just available books.
Book.available
# or
Book.where(availability: :available)

book = Book.new(availability: :available)
book.available?   # => true
book.unavailable! # => true
book.available?   # => false
```

Read the full documentation about enums
[in the Rails API docs](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html).

Entendendo o Encadeamento de Métodos
---------------------------------

O *Active Record* implementa o padrão [Encadeamento de Métodos](https://en.wikipedia.org/wiki/Method_chaining)
(*method chaining*) que nos permite usar vários métodos do *Active Record* juntos de uma maneira simples e direta.

Você pode encadear métodos numa sentença quando o método chamado anteriormente retorna
uma `ActiveRecord::Relation`, como `all`, `where` e `joins`. Métodos que retornam um único objeto
(veja [a seção Retornando um Único Objeto](#retornando-um-unico-objeto)) devem estar no fim da sentença.

Há alguns exemplos abaixo. Esse guia não vai mostrar todas as possibilidades, só alguns exemplos.
Quando um método *Active Record* é chamado, a consulta não é imediatamente gerada e enviada para o banco
de dados, isso só acontece quando os dados são realmente necessários. Logo, cada exemplo abaixo só gera
uma consulta.

### Buscando dados filtrados de múltiplas tabelas

```ruby
Person
  .select('people.id, people.name, comments.text')
  .joins(:comments)
  .where('comments.created_at > ?', 1.week.ago)
```

O resultado deve ser algo parecido com isso:

```sql
SELECT people.id, people.name, comments.text
FROM people
INNER JOIN comments
  ON comments.person_id = people.id
WHERE comments.created_at > '2015-01-01'
```

### Buscando dados específicos de múltiplas tabelas

```ruby
Person
  .select('people.id, people.name, companies.name')
  .joins(:company)
  .find_by('people.name' => 'John') # this should be the last
```

O comando acima deve gerar:

```sql
SELECT people.id, people.name, companies.name
FROM people
INNER JOIN companies
  ON companies.person_id = people.id
WHERE people.name = 'John'
LIMIT 1
```

NOTE: Note que se uma consulta trouxer múltiplos registros, o
método `find_by` irá retornar somente o primeiro e ignorar o
restante (perceba a sentença `LIMIT 1` acima).

Encontrando ou Construindo um Novo Objeto
--------------------------

É comum que você precise localizar um registro ou criá-lo se ele não existir. Você pode fazer isso com os métodos `find_or_create_by` e `find_or_create_by!`.

### `find_or_create_by`

O método `find_or_create_by` verifica se existe um registro com os atributos especificados. Se não, então `create` é chamado. Vejamos um exemplo.

Suponha que você queira encontrar um cliente chamado 'Andy' e, se não houver nenhum, crie um. Você pode fazer isso executando:

```ruby
Client.find_or_create_by(first_name: 'Andy')
# => #<Client id: 1, first_name: "Andy", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">
```

O SQL gerado por esse método parece com isso:

```sql
SELECT * FROM clients WHERE (clients.first_name = 'Andy') LIMIT 1
BEGIN
INSERT INTO clients (created_at, first_name, locked, orders_count, updated_at) VALUES ('2011-08-30 05:22:57', 'Andy', 1, NULL, '2011-08-30 05:22:57')
COMMIT
```

`find_or_create_by` retorna o registro que já existe ou o novo registro. Em nosso caso, ainda não tínhamos um cliente chamado Andy, então o registro é criado e retornado.

O novo registro pode não ser salvo no banco de dados; isso depende se as validações foram aprovadas ou não (assim como `create`).

Suponha que queremos definir o atributo 'bloqueado' para `false` se estamos
criando um novo registro, mas não queremos incluí-lo na consulta. Então
queremos encontrar o cliente chamado "Andy", ou se esse cliente não
existir, crie um cliente chamado "Andy" que não esteja bloqueado.

Podemos conseguir isso de duas maneiras. A primeira é usar `create_with`:

```ruby
Client.create_with(locked: false).find_or_create_by(first_name: 'Andy')
```

A segunda maneira é usar um _lock_:

```ruby
Client.find_or_create_by(first_name: 'Andy') do |c|
  c.locked = false
end
```

O _lock_ só será executado se o cliente estiver sendo criado. A segunda vez que rodarmos este código, o todo o bloco será ignorado.

### `find_or_create_by!`

Você também pode usar `find_or_create_by!` Você também pode usar `find_or_create_by!` para gerar uma exceção se o novo registro for inválido. As validações não são abordadas neste guia, mas vamos supor por um momento que você adiciona temporariamente

```ruby
validates :orders_count, presence: true
```

ao seu _model_ `Client`. Se você tentar criar um novo `Client` sem passar `orders_count`, o registro será inválido e uma exceção será levantada:

```ruby
Client.find_or_create_by!(first_name: 'Andy')
# => ActiveRecord::RecordInvalid: Validation failed: Orders count can't be blank
```

### `find_or_initialize_by`

O método `find_or_initialize_by` funcionará como o
`find_or_create_by` mas irá chamar `new` ao invés de `create`. Isso significa que uma nova instância de modelo será criada na memória, mas não será salva no banco de dados. Continuando com o exemplo `find_or_create_by`, agora queremos o cliente chamado 'Nick':


```ruby
nick = Client.find_or_initialize_by(first_name: 'Nick')
# => #<Client id: nil, first_name: "Nick", orders_count: 0, locked: true, created_at: "2011-08-30 06:09:27", updated_at: "2011-08-30 06:09:27">

nick.persisted?
# => false

nick.new_record?
# => true
```

Como o objeto ainda não está armazenado no banco de dados, o SQL gerado tem a seguinte aparência:

```sql
SELECT * FROM clients WHERE (clients.first_name = 'Nick') LIMIT 1
```

Quando você quiser salvar no banco, apenas chame `save`:

```ruby
nick.save
# => true
```

Finding by SQL
--------------

If you'd like to use your own SQL to find records in a table you can use `find_by_sql`. The `find_by_sql` method will return an array of objects even if the underlying query returns just a single record. For example you could run this query:

```ruby
Client.find_by_sql("SELECT * FROM clients
  INNER JOIN orders ON clients.id = orders.client_id
  ORDER BY clients.created_at desc")
# =>  [
#   #<Client id: 1, first_name: "Lucas" >,
#   #<Client id: 2, first_name: "Jan" >,
#   ...
# ]
```

`find_by_sql` provides you with a simple way of making custom calls to the database and retrieving instantiated objects.

### `select_all`

`find_by_sql` has a close relative called `connection#select_all`. `select_all` will retrieve
objects from the database using custom SQL just like `find_by_sql` but will not instantiate them.
This method will return an instance of `ActiveRecord::Result` class and calling `to_a` on this
object would return you an array of hashes where each hash indicates a record.

```ruby
Client.connection.select_all("SELECT first_name, created_at FROM clients WHERE id = '1'").to_a
# => [
#   {"first_name"=>"Rafael", "created_at"=>"2012-11-10 23:23:45.281189"},
#   {"first_name"=>"Eileen", "created_at"=>"2013-12-09 11:22:35.221282"}
# ]
```

### `pluck`

`pluck` can be used to query single or multiple columns from the underlying table of a model. It accepts a list of column names as argument and returns an array of values of the specified columns with the corresponding data type.

```ruby
Client.where(active: true).pluck(:id)
# SELECT id FROM clients WHERE active = 1
# => [1, 2, 3]

Client.distinct.pluck(:role)
# SELECT DISTINCT role FROM clients
# => ['admin', 'member', 'guest']

Client.pluck(:id, :name)
# SELECT clients.id, clients.name FROM clients
# => [[1, 'David'], [2, 'Jeremy'], [3, 'Jose']]
```

`pluck` makes it possible to replace code like:

```ruby
Client.select(:id).map { |c| c.id }
# or
Client.select(:id).map(&:id)
# or
Client.select(:id, :name).map { |c| [c.id, c.name] }
```

with:

```ruby
Client.pluck(:id)
# or
Client.pluck(:id, :name)
```

Unlike `select`, `pluck` directly converts a database result into a Ruby `Array`,
without constructing `ActiveRecord` objects. This can mean better performance for
a large or often-running query. However, any model method overrides will
not be available. For example:

```ruby
class Client < ApplicationRecord
  def name
    "I am #{super}"
  end
end

Client.select(:name).map &:name
# => ["I am David", "I am Jeremy", "I am Jose"]

Client.pluck(:name)
# => ["David", "Jeremy", "Jose"]
```

You are not limited to querying fields from a single table, you can query multiple tables as well.

```
Client.joins(:comments, :categories).pluck("clients.email, comments.title, categories.name")
```

Furthermore, unlike `select` and other `Relation` scopes, `pluck` triggers an immediate
query, and thus cannot be chained with any further scopes, although it can work with
scopes already constructed earlier:

```ruby
Client.pluck(:name).limit(1)
# => NoMethodError: undefined method `limit' for #<Array:0x007ff34d3ad6d8>

Client.limit(1).pluck(:name)
# => ["David"]
```

### `ids`

`ids` can be used to pluck all the IDs for the relation using the table's primary key.

```ruby
Person.ids
# SELECT id FROM people
```

```ruby
class Person < ApplicationRecord
  self.primary_key = "person_id"
end

Person.ids
# SELECT person_id FROM people
```

Existência de Objetos
--------------------

Se você simplesmente quer checar a existência do objeto, existe um método chamado `exists?`.
Este método irá consultar o banco de dados usando a mesma consulta que `find`, mas ao invés de retornar um objeto ou uma coleção de objetos, irá retornar `true` ou `false`.

```ruby
Client.exists?(1)
```

O método `exists?` também assume valores múltiplos, mas o problema é que retornará `true` se algum desses registros existirem.

```ruby
Client.exists?(id: [1,2,3])
# or
Client.exists?(name: ['John', 'Sergei'])
```

É até possível usar `exists?` sem algum argumento em um *model* ou relação.

```ruby
Client.where(first_name: 'Ryan').exists?
```

O código acima retorna `true` se existir ao menos um cliente com o `first_name` 'Ryan' e `false` caso não exista.

```ruby
Client.exists?
```

O código acima retorna `false` se a tabela `clients` estiver vazia e `true` caso não esteja.

Você também pode usar `any?` e `many?` para verificar a existência de um *model* ou relação.

```ruby
# via a model
Article.any?
Article.many?

# via a named scope
Article.recent.any?
Article.recent.many?

# via a relation
Article.where(published: true).any?
Article.where(published: true).many?

# via an association
Article.first.categories.any?
Article.first.categories.many?
```

Cálculos
------------

Essa seção usa *count* como exemplo de método nessa introdução, mas as opções descritas se aplicam para todas as
subseções.

Todos os métodos de cálculo funcionam diretamente em um *model*:

```ruby
Client.count
# SELECT COUNT(*) FROM clients
```

Ou em uma relação:

```ruby
Client.where(first_name: 'Ryan').count
# SELECT COUNT(*) FROM clients WHERE (first_name = 'Ryan')
```

Você também pode utilizar vários métodos de busca em uma relação para fazer cálculos complexos:

```ruby
Client.includes("orders").where(first_name: 'Ryan', orders: { status: 'received' }).count
```

O que vai executar:

```sql
SELECT COUNT(DISTINCT clients.id) FROM clients
  LEFT OUTER JOIN orders ON orders.client_id = clients.id
  WHERE (clients.first_name = 'Ryan' AND orders.status = 'received')
```

### Contar (*count*)

Se você quiser saber quantos registros estão na tabela do seu *model* você pode chamar `Client.count` e isso vai retornar um número.
Se você quiser ser mais específico e encontrar todos os clientes que tem idade presente no banco de dados, você pode utilizar
`Client.count(:age)`

Para mais opções, veja a seção pai, [Cálculos](#calculos).

### Média (*average*)

Se você quiser saber a média de um certo número em uma das suas tabelas, você pode chamar o método `average`
na sua classe que se relaciona com essa tabela. Essa chamada de método vai parecer desse jeito:

```ruby
Client.average("orders_count")
```

Isso vai retornar um número (possivelmente um número de ponto flutuante como 3.14159265) representando o valor médio
desse campo.

Para mais opções, veja a seção pai, [Cálculos](#calculos).

### Mínimo (*minimum*)

Se você quiser encontrar o valor mínimo de um campo na sua tabela, você pode chamar o método `minimum`
na classe que se relaciona com a tabela. Essa chamada de método vai parecer desse jeito:

```ruby
Client.minimum("age")
```

Para mais opções, veja a seção pai, [Cálculos](#calculos).

### Máximo (*maximum*)

Se você quiser encontrar o valor máximo de um campo na sua tabela, você pode chamar o método `maximum`
na classe que se relaciona com a tabela. Essa chamada de método vai parecer desse jeito:

```ruby
Client.maximum("age")
```

Para mais opções, veja a seção pai, [Cálculos](#calculos).

### Soma (*sum*)

Se você quiser encontrar a soma de todos os registros na sua tabela, você pode chamar o método `sum`
na classe que se relaciona com a tabela. Essa chamada de método vai parecer desse jeito:

```ruby
Client.sum("orders_count")
```

Para mais opções, veja a seção pai, [Cálculos](#calculos).

Executando o EXPLAIN
---------------

Você pode executar o *EXPLAIN* nas *queries* disparadas por relações. Por exemplo,

```ruby
User.where(id: 1).joins(:articles).explain
```

pode produzir

```
EXPLAIN for: SELECT `users`.* FROM `users` INNER JOIN `articles` ON `articles`.`user_id` = `users`.`id` WHERE `users`.`id` = 1
+----+-------------+----------+-------+---------------+
| id | select_type | table    | type  | possible_keys |
+----+-------------+----------+-------+---------------+
|  1 | SIMPLE      | users    | const | PRIMARY       |
|  1 | SIMPLE      | articles | ALL   | NULL          |
+----+-------------+----------+-------+---------------+
+---------+---------+-------+------+-------------+
| key     | key_len | ref   | rows | Extra       |
+---------+---------+-------+------+-------------+
| PRIMARY | 4       | const |    1 |             |
| NULL    | NULL    | NULL  |    1 | Using where |
+---------+---------+-------+------+-------------+

2 rows in set (0.00 sec)
```

em MySQL e MariaDB.

O *Active Record* exibe uma impressão que simula a do *shell* do banco de dados correspondente. Então, a mesma *query* sendo executada quando usado o adaptador de PostgreSQL poderá produzir o seguinte:

```
EXPLAIN for: SELECT "users".* FROM "users" INNER JOIN "articles" ON "articles"."user_id" = "users"."id" WHERE "users"."id" = 1
                                  QUERY PLAN
------------------------------------------------------------------------------
 Nested Loop Left Join  (cost=0.00..37.24 rows=8 width=0)
   Join Filter: (articles.user_id = users.id)
   ->  Index Scan using users_pkey on users  (cost=0.00..8.27 rows=1 width=4)
         Index Cond: (id = 1)
   ->  Seq Scan on articles  (cost=0.00..28.88 rows=8 width=4)
         Filter: (articles.user_id = 1)
(6 rows)
```

O *Eager Loading* pode disparar mais que uma *query* por debaixo dos panos,
e algumas *queries* podem necessitar de resultados prévios. Por causa disso,
o `explain` na verdade executa a *query* e somente depois solicita o que a *query* planeja.
Por exemplo,

```ruby
User.where(id: 1).includes(:articles).explain
```

produz

```
EXPLAIN for: SELECT `users`.* FROM `users`  WHERE `users`.`id` = 1
+----+-------------+-------+-------+---------------+
| id | select_type | table | type  | possible_keys |
+----+-------------+-------+-------+---------------+
|  1 | SIMPLE      | users | const | PRIMARY       |
+----+-------------+-------+-------+---------------+
+---------+---------+-------+------+-------+
| key     | key_len | ref   | rows | Extra |
+---------+---------+-------+------+-------+
| PRIMARY | 4       | const |    1 |       |
+---------+---------+-------+------+-------+

1 row in set (0.00 sec)

EXPLAIN for: SELECT `articles`.* FROM `articles`  WHERE `articles`.`user_id` IN (1)
+----+-------------+----------+------+---------------+
| id | select_type | table    | type | possible_keys |
+----+-------------+----------+------+---------------+
|  1 | SIMPLE      | articles | ALL  | NULL          |
+----+-------------+----------+------+---------------+
+------+---------+------+------+-------------+
| key  | key_len | ref  | rows | Extra       |
+------+---------+------+------+-------------+
| NULL | NULL    | NULL |    1 | Using where |
+------+---------+------+------+-------------+


1 row in set (0.00 sec)
```

em MySQL e MariaDB.

### Interpretando o EXPLAIN

A interpretação da saída do *EXPLAIN* está além do escopo deste guia. Os links
a seguir podem servir de ajuda:

* SQLite3: [EXPLAIN QUERY PLAN](https://www.sqlite.org/eqp.html)

* MySQL: [EXPLAIN Output Format](https://dev.mysql.com/doc/refman/5.7/en/explain-output.html)

* MariaDB: [EXPLAIN](https://mariadb.com/kb/en/mariadb/explain/)

* PostgreSQL: [Using EXPLAIN](https://www.postgresql.org/docs/current/static/using-explain.html)
