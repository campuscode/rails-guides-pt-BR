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

Condições
----------

O método `where`  permite que você especifique condições para limitar os registros retornados, representando a parte `where` da instrução SQL. Condições podem ser especificadas como uma *string*, *array*, ou *hash*.

### Condições de Strings Puras

Se você gostaria de adicionar condições para sua busca, poderia apenas especificá-las, como, por exemplo `Client.where("orders_count = '2'")`. Isso encontrará todos os clientes em que o campo `ordes_count` tenha o valor igual a 2.

WARNING: Construindo sua própria condições como *strings* pura pode te deixar vulnerável a ataques de injeção SQL. Por exemplo, `Client.where("first_name LIKE '%#{params[:first_name]}%'")` não é seguro. Veja a próxima seção para saber a maneira preferida de lidar com  condições usando array.

### Condições de Array

Agora, se esse número pudesse variar, digamos como um argumento de algum lugar? O comando da busca então levaria a forma:

```ruby
Client.where("orders_count = ?", params[:orders])
```

*Active Record* tomará o primeiro argumento como a string de condições e quaisquer argumentos adicionais vão substituir os pontos de interrogação `(?)` nele.

Se você quer especificar múltiplas condições:

```ruby
Client.where("orders_count = ? AND locked = ?", params[:orders], false)
```

Neste exemplo, o primeiro ponto de interrogação será substituído com o valor em `params[:orders]` e o segundo será substituído com a representação SQL para `false`, que depende do adaptador.

Este código é altamente preferível:

```ruby
Client.where("orders_count = ?", params[:orders])
```

Para este código:

```ruby
Client.where("orders_count = #{params[:orders]}")
```

Devido à segurança do argumento. Colocando a variável dentro da condição de *string*, passará a variável para o banco de dados **como se encontra**. Isto significa que será uma variável sem escape diretamente de um usuário que pode ter intenções maliciosas. Se você fizer isso, coloca todo seu banco de dados em risco, porque uma vez que um usuário descobre que pode explorar seu banco de dados, ele pode fazer qualquer coisa com ele. Nunca, jamais, coloque seus argumentos diretamente dentro da condição de *string*.

TIP: Para mais informações sobre os perigos da injeção de SQL, veja em [Ruby on Rails Security Guide](https://guides.rubyonrails.org/security.html#sql-injection) / [Ruby on Rails Security Guide PT-Br](security.html#sql-injection)

#### Condições com *Placeholder*

Similar ao estilo de substituição `(?)` dos parâmetros, você também pode especificar chaves em sua condição de *string* junto com uma *hash* de chaves/valores (*keys/values*) correspondentes:

```ruby
Client.where("created_at >= :start_date AND created_at <= :end_date",
  {start_date: params[:start_date], end_date: params[:end_date]})
```

Isso torna a legibilidade mais clara se você tem um grande número de condições variáveis.

### Condições de Hash

*Active Record* também permite que você passe em condições de *hash* o que pode aumentar a legibilidade de suas sintaxes de condições. Com condições de *hash*, você passa em uma *hash* com chaves (*keys*) dos campos que deseja qualificados e os valores (*values*) de como deseja qualificá-los:

NOTE: Apenas igualdade, intervalo, e subconjunto são possíveis com as condições de *hash*.

#### Condições de igualdade

```ruby
Client.where(locked: true)
```

Isso irá gerar um SQL como este:

```sql
SELECT * FROM clients WHERE (clients.locked = 1)
```

O nome do campo também pode ser uma *string*:

```ruby
Client.where('locked' => true)
```

No caso de um relacionamento `belongs_to`, uma chave de associação pode ser usada para especificar o model se um objeto *Active Record* for usado como o valor. Este método também funciona com relacionamentos polimórficos.

```ruby
Article.where(author: author)
Author.joins(:articles).where(articles: { author: author })
```

#### Condições de intervalos

```ruby
Client.where(created_at: (Time.now.midnight - 1.day)..Time.now.midnight)
```

Isso irá encontrar todos clientes criados ontem usando uma instrução SQL `BETWEEN`:

```sql
SELECT * FROM clients WHERE (clients.created_at BETWEEN '2008-12-21 00:00:00' AND '2008-12-22 00:00:00')
```

Isso demonstra uma sintaxe mais curta para exemplos em [Condições de Array](#condicoes-de-array)

#### Subconjunto de Condições

Se você deseja procurar registros usando a expressão `IN` pode passar um *array* para a *hash* de condições:

```ruby
Client.where(orders_count: [1,3,5])
```

Esse código irá gerar um SQL como este:

```sql
SELECT * FROM clients WHERE (clients.orders_count IN (1,3,5))
```

### Condições NOT

Consultas SQL `NOT` podem ser construídas por `where.not`:

```ruby
Client.where.not(locked: true)
```

Em outras palavras, essa consulta pode ser gerada chamando `where` sem nenhum argumento, então imediatamente encadeie com condições `not` passando `where`. Isso irá gerar SQL como este:

```sql
SELECT * FROM clients WHERE (clients.locked != 1)
```

### Condições OR

Condições `OR` entre duas relações podem ser construídas chamando `or` na primeira relação, e passando o segundo como um argumento.

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

Selecionando Campos Específicos
-------------------------

Por padrão, `Model.find` seleciona todos os campos do conjunto de resultado usando `select *`.

Para selecionar somente um subconjunto de campos do conjunto de resultado, você pode especificar o
subconjunto via método `select`.

Por exemplo, para selecionar somente as colunas `viewable_by` e `locked`:

```ruby
Client.select(:viewable_by, :locked)
# OU
Client.select("viewable_by, locked")
```

A *query* SQL usada por esta chamada de busca vai ser algo como:

```sql
SELECT viewable_by, locked FROM clients
```

Tome cuidado pois isso também significa que você está inicializando um objeto *model* com somente os campos que você selecionou. Se você tentar acessar um campo que não está no registro inicializado,
você vai receber:

```bash
ActiveModel::MissingAttributeError: missing attribute: <attribute>
```

Onde `<attribute>` é o atributo que você pediu. O método `id` não vai lançar o `ActiveRecord::MissingAttributeError`, então fique atento quando estiver trabalhando com associações, pois elas precisam do método `id` para funcionar corretamente.

Se você quiser pegar somente um registro por valor único em um certo campo, você pode usar `distinct`:

```ruby
Client.select(:name).distinct
```

Isso vai gerar uma *query* SQL como:

```sql
SELECT DISTINCT name FROM clients
```

Você pode também remover a restrição de unicidade:

```ruby
query = Client.select(:name).distinct
# => Retorna nomes únicos

query.distinct(false)
# => Retorna todos os nomes, mesmo se houverem valores duplicados.
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

Agrupando
-----

Para aplicar uma cláusula `GROUP BY` para o SQL disparado pelo localizador, você pode utilizar o método `group`.

Por exemplo, se você quer encontrar uma coleção das datas em que os pedidos foram criados:

```ruby
Order.select("date(created_at) as ordered_date, sum(price) as total_price").group("date(created_at)")
```

E isso te dará um único objeto `Order` para cada data em que há pedidos no banco de dados.

O SQL que será executado parecerá com algo como isso:

```sql
SELECT date(created_at) as ordered_date, sum(price) as total_price
FROM orders
GROUP BY date(created_at)
```

### Total de itens agrupados

Para pegar o total de itens agrupados em uma única _query_, chame `count` depois do `group`.

```ruby
Order.group(:status).count
# => { 'awaiting_approval' => 7, 'paid' => 12 }
```

O SQL que será executado parecerá com algo como isso:

```sql
SELECT COUNT (*) AS count_all, status AS status
FROM "orders"
GROUP BY status
```

_Having_
------

O SQL usa a cláusula `HAVING` para especificar condições nos campos `GROUP BY`. Você pode adicionar a cláusula `HAVING` ao SQL disparado pelo `Model.find` ao adicionar o método `having` à busca.

Por exemplo:

```ruby
Order.select("date(created_at) as ordered_date, sum(price) as total_price").
  group("date(created_at)").having("sum(price) > ?", 100)
```

O SQL que será executado será parecido com isso:

```sql
SELECT date(created_at) as ordered_date, sum(price) as total_price
FROM orders
GROUP BY date(created_at)
HAVING sum(price) > 100
```

Isso retorna a data e o preço total para cada objeto de pedido, agrupado pelo dia em que foram criados e se o preço é maior que $100.

Condições de Substituição
---------------------

### `unscope`

Você pode especificar certas condições a serem removidas usando o método `unscope`. Por exemplo:

```ruby
Article.where('id > 10').limit(20).order('id asc').unscope(:order)
```

O SQL que será executado:

```sql
SELECT * FROM articles WHERE id > 10 LIMIT 20

# Original query without `unscope`
SELECT * FROM articles WHERE id > 10 ORDER BY id asc LIMIT 20

```

Você também pode remover o escopo de cláusulas `where` específicas. Por exemplo:

```ruby
Article.where(id: 10, trashed: false).unscope(where: :id)
# SELECT "articles".* FROM "articles" WHERE trashed = 0
```

A relação que usou `unscope` afetará quaisquer relações nas quais foi unida:

```ruby
Article.order('id asc').merge(Article.unscope(:order))
# SELECT "articles".* FROM "articles"
```

### `only`

Você também pode substituir condições com o método `only`. Por exemplo:

```ruby
Article.where('id > 10').limit(20).order('id desc').only(:order, :where)
```

O SQL que será executado:

```sql
SELECT * FROM articles WHERE id > 10 ORDER BY id DESC

# Query original sem `only`
SELECT * FROM articles WHERE id > 10 ORDER BY id DESC LIMIT 20

```

### `reselect`

O método `reselect` substitui uma declaração de _select_ existente. Por exemplo:

```ruby
Post.select(:title, :body).reselect(:created_at)
```

O SQL que será executado:

```sql
SELECT `posts`.`created_at` FROM `posts`
```

No caso em que a cláusula `reselect` não é utilizada,

```ruby
Post.select(:title, :body).select(:created_at)
```

o SQL executado será:

```sql
SELECT `posts`.`title`, `posts`.`body`, `posts`.`created_at` FROM `posts`
```

### `reorder`

O método `reorder` substitui a ordem de escopo padrão. Por exemplo:

```ruby
class Article < ApplicationRecord
  has_many :comments, -> { order('posted_at DESC') }
end

Article.find(10).comments.reorder('name')
```

O SQL que será executado:

```sql
SELECT * FROM articles WHERE id = 10 LIMIT 1
SELECT * FROM comments WHERE article_id = 10 ORDER BY name
```

No caso em que `reorder` não é utilizado, o SQL executado será:

```sql
SELECT * FROM articles WHERE id = 10 LIMIT 1
SELECT * FROM comments WHERE article_id = 10 ORDER BY posted_at DESC
```

### `reverse_order`

O método `reverse_order` reverte a ordem da cláusula, se especificado.

```ruby
Client.where("orders_count > 10").order(:name).reverse_order
```

O SQL que será executado:

```sql
SELECT * FROM clients WHERE orders_count > 10 ORDER BY name DESC
```

Se nenhuma cláusula de ordenação é especificada na _query_, o `reverse_order` ordena pela chave primária em ordem reversa.

```ruby
Client.where("orders_count > 10").reverse_order
```

O SQL que será executado:

```sql
SELECT * FROM clients WHERE orders_count > 10 ORDER BY clients.id DESC
```

Esse método **não aceita** argumentos.

### `rewhere`

O método `rewhere` substitui uma existente, nomeada condição de _where_. Por exemplo:

```ruby
Article.where(trashed: true).rewhere(trashed: false)
```

O SQL que será executado:

```sql
SELECT * FROM articles WHERE `trashed` = 0
```

No caso em que a cláusula `rewhere` não é usada,

```ruby
Article.where(trashed: true).where(trashed: false)
```

o SQL será:

```sql
SELECT * FROM articles WHERE `trashed` = 1 AND `trashed` = 0
```

Relações Nulas
-------------

O método `none` retorna uma relação encadeada sem registros. Quaisquer condições subsequentes encadeadas à relação retornada continuarão gerando relações vazias. Isso é útil em cenários onde você precisa de uma resposta encadeada para um método ou um escopo que pode retornar zero resultados.

```ruby
Article.none # retorna uma Relation vazia e não dispara nenhuma query.
```

```ruby
# O método visible_articles abaixo deve retornar uma Relation.
@articles = current_user.visible_articles.where(name: params[:name])

def visible_articles
  case role
  when 'Country Manager'
    Article.where(country: country)
  when 'Reviewer'
    Article.published
  when 'Bad User'
    Article.none # => neste caso, retornar [] ou nil quebrará o código que invocou
  end
end
```

Objetos _Readonly_ (Somente leitura)
----------------

O _Active Record_ provê o método `readonly` em uma relação para desabilitar modificações explicitamente em qualquer um dos objetos retornados. Qualquer tentativa de alterar um registro _readonly_ não ocorrerá, levantando uma exceção `ActiveRecord::ReadOnlyRecord`.

```ruby
client = Client.readonly.first
client.visits += 1
client.save
```

Como `client` é explicitamente configurado para ser um objeto _readonly_, o código acima levantará uma exceção `ActiveRecord::ReadOnlyRecord` ao chamar `client.save` com o valor atualizado de _visits_.

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

Associando Tabelas
--------------

O *Active Record* fornece dois métodos de busca para especificar cláusulas `JOIN` no SQL resultante: `joins` e `left_outer_joins`.
Enquanto `joins` deve ser utilizado para `INNER JOIN` em consultas personalizadas,
`left_outer_joins` é usado para consultas usando `LEFT OUTER JOIN`.

### `joins`

Há múltiplas maneiras de usar o método `joins`.

#### Usando um Fragmento de String SQL

Você pode apenas fornecer o SQL literal especificando a cláusula `JOIN` para `joins`:

```ruby
Author.joins("INNER JOIN posts ON posts.author_id = authors.id AND posts.published = 't'")
```

Isso resultará no seguinte SQL:

```sql
SELECT authors.* FROM authors INNER JOIN posts ON posts.author_id = authors.id AND posts.published = 't'
```

#### Usando Array/Hash de Associações Nomeadas

O *Active Record* permite que você use os nomes de [associações](association_basics.html) definidos no _model_ como um atalho para especificar cláusulas `JOIN` para essas associações quando estiver usando o método  `joins`.

Por exemplo, considere os seguintes _models_ `Category`, `Article`, `Comment`, `Guest` e `Tag`:

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

Agora, todos os itens a seguir irão produzir as consultas de junção (*join*) esperadas usando `INNER JOIN`:

##### Unindo uma Associação Única

```ruby
Category.joins(:articles)
```

Isso produz:

```sql
SELECT categories.* FROM categories
  INNER JOIN articles ON articles.category_id = categories.id
```

Ou, em Português: "retorne um objeto `Category` para todas as categorias com artigos". Observe que você verá categorias duplicadas se mais de um artigo tiver a mesma categoria. Se você quiser categorias exclusivas, pode usar `Category.joins(:articles).distinct`.

#### Unindo Múltiplas Associações

```ruby
Article.joins(:category, :comments)
```

Isso produz:

```sql
SELECT articles.* FROM articles
  INNER JOIN categories ON categories.id = articles.category_id
  INNER JOIN comments ON comments.article_id = articles.id
```

Ou, em Português: "retorne todos os artigos que tem uma categoria e ao menos um comentário". Observe novamente que artigos com múltiplos comentários aparecerão múltiplas vezes.

##### Unindo Associações Aninhadas (Nível Único)

```ruby
Article.joins(comments: :guest)
```

Isso produz:

```sql
SELECT articles.* FROM articles
  INNER JOIN comments ON comments.article_id = articles.id
  INNER JOIN guests ON guests.comment_id = comments.id
```

Ou, em Português: "retorne todos os artigos que tem um comentário feito por um convidado."

##### Unindo Associações Aninhadas (Níveis Múltiplos)

```ruby
Category.joins(articles: [{ comments: :guest }, :tags])
```

Isso produz:

```sql
SELECT categories.* FROM categories
  INNER JOIN articles ON articles.category_id = categories.id
  INNER JOIN comments ON comments.article_id = articles.id
  INNER JOIN guests ON guests.comment_id = comments.id
  INNER JOIN tags ON tags.article_id = articles.id
```

Ou, em Português: "retorne todas as categorias que têm artigos, sendo que estes artigos têm um comentário feito por um convidado, e que estes artigos também tenham uma _tag_."

#### Especificando Condições em Tabelas Associadas

Você pode especificar condições nas tabelas associadas com condições [Array](#array-conditions) e [String](#pure-string-conditions). [Hash conditions](#hash-conditions) fornecem uma sintaxe especial para especificar condições para as tabelas associadas:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Client.joins(:orders).where('orders.created_at' => time_range)
```

Uma sintaxe alternativa e mais limpa é aninhar as condições de _hash_:

```ruby
time_range = (Time.now.midnight - 1.day)..Time.now.midnight
Client.joins(:orders).where(orders: { created_at: time_range })
```

Isso encontrará todos os clientes que têm pedidos criados ontem, novamente usando uma expressão SQL `BETWEEN`.

### `left_outer_joins`

Se você deseja selecionar um conjunto de registros tendo ou não registros associados, você pode usar o método `left_outer_joins`.

```ruby
Author.left_outer_joins(:posts).distinct.select('authors.*, COUNT(posts.*) AS posts_count').group('authors.id')
```

Que resulta em:

```sql
SELECT DISTINCT authors.*, COUNT(posts.*) AS posts_count FROM "authors"
LEFT OUTER JOIN posts ON posts.author_id = authors.id GROUP BY authors.id
```

Que significa: "retorne todos os autores com suas contagens de posts, tenham eles postagens ou não"


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

_Scopes_
------

A definição do escopo permite que você especifique consultas comumente usadas, que podem ser referenciadas como chamadas de método nos objetos ou *modelos* associados. Com esses escopos, você pode usar todos os métodos cobertos anteriormente, como `where`, `joins` e `includes`. Todos os corpos de escopo devem retornar um `ActiveRecord::Relation` ou `nil` para permitir que métodos adicionais (como outros escopos) sejam chamados nele.

Para definir um escopo simples, usamos o método `scope` dentro da classe, passando a consulta que gostaríamos de executar quando este escopo for chamado:

```ruby
class Article < ApplicationRecord
  scope :published, -> { where(published: true) }
end
```

Os escopos também podem ser encadeados dentro dos escopos:

```ruby
class Article < ApplicationRecord
  scope :published,               -> { where(published: true) }
  scope :published_and_commented, -> { published.where("comments_count > 0") }
end
```

Para chamar este escopo `published`, podemos chamá-lo tanto na classe:

```ruby
Article.published # => [published articles]
```

Ou em uma associação que consiste em objetos `Article`:

```ruby
category = Category.first
category.articles.published # => [published articles belonging to this category]
```

### Transmitindo argumentos

Seu escopo pode receber argumentos:

```ruby
class Article < ApplicationRecord
  scope :created_before, ->(time) { where("created_at < ?", time) }
end
```

Chame o escopo como se fosse um método de classe:

```ruby
Article.created_before(Time.zone.now)
```

No entanto, isso é apenas a duplicação da funcionalidade que seria fornecida a você por um método de classe.

```ruby
class Article < ApplicationRecord
  def self.created_before(time)
    where("created_at < ?", time)
  end
end
```

Usar um método de classe é a maneira preferida de aceitar argumentos para escopos. Esses métodos ainda estarão acessíveis nos objetos de associação:

```ruby
category.articles.created_before(time)
```

### Usando condicionais

Seu escopo pode utilizar condicionais:

```ruby
class Article < ApplicationRecord
  scope :created_before, ->(time) { where("created_at < ?", time) if time.present? }
end
```

Como os outros exemplos, isso se comportará de maneira semelhante a um método de classe.

```ruby
class Article < ApplicationRecord
  def self.created_before(time)
    where("created_at < ?", time) if time.present?
  end
end
```

No entanto, há uma advertência importante: um escopo sempre retornará um objeto `ActiveRecord::Relation`, mesmo se a condicional for avaliada como `false`, enquanto um método de classe retornará `nil`. Isso pode causar `NoMethodError` ao encadear métodos de classe com condicionais, se qualquer uma das condicionais retornar `false`.

### Aplicando um escopo padrão

Se desejarmos que um escopo seja aplicado em todas as consultas do *model*, podemos usar o
método `default_scope` dentro do próprio *model*.

```ruby
class Client < ApplicationRecord
  default_scope { where("removed_at IS NULL") }
end
```

Quando as consultas são executadas neste *model*, a consulta SQL agora será semelhante a
isto:

```sql
SELECT * FROM clients WHERE removed_at IS NULL
```

Se você precisa fazer coisas mais complexas com um escopo padrão, você pode alternativamente
defini-lo como um método de classe:

```ruby
class Client < ApplicationRecord
  def self.default_scope
    # Should return an ActiveRecord::Relation.
  end
end
```

NOTE: O `default_scope` também é aplicado ao criar/construir um registro
quando os argumentos do escopo são fornecidos como `Hash`. Não é aplicado enquanto
atualizando um registro. E.g.:

```ruby
class Client < ApplicationRecord
  default_scope { where(active: true) }
end

Client.new          # => #<Client id: nil, active: true>
Client.unscoped.new # => #<Client id: nil, active: nil>
```

Esteja ciente de que, quando fornecido no formato `Array`, os argumentos de consulta `default_scope`
não pode ser convertido em `Hash` para atribuição de atributo padrão. E.g.:

```ruby
class Client < ApplicationRecord
  default_scope { where("active = ?", true) }
end

Client.new # => #<Client id: nil, active: nil>
```

### Mesclagem de escopos

Assim como os escopos das cláusulas `where` são mesclados usando as condições `AND`.

```ruby
class User < ApplicationRecord
  scope :active, -> { where state: 'active' }
  scope :inactive, -> { where state: 'inactive' }
end

User.active.inactive
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active' AND "users"."state" = 'inactive'
```

Podemos misturar e combinar as condições `scope` e `where` e o sql final
terá todas as condições unidas com `AND`.

```ruby
User.active.where(state: 'finished')
# SELECT "users".* FROM "users" WHERE "users"."state" = 'active' AND "users"."state" = 'finished'
```

Se quisermos que a última cláusula `where` vença, então `Relation#merge` pode
ser usado.

```ruby
User.active.merge(User.inactive)
# SELECT "users".* FROM "users" WHERE "users"."state" = 'inactive'
```

Uma advertência importante é que `default_scope` será anexado em
condições `scope` e `where`.

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

Como você pode ver acima, o `default_scope` está sendo mesclado em ambos
condições `scope` e `where`.

### Removendo todo o escopo

Se desejarmos remover o escopo por qualquer motivo, podemos usar o método `unscoped`. Isto é
especialmente útil se um `default_scope` é especificado no *model* e não deve ser
aplicado para esta consulta particular.

```ruby
Client.unscoped.load
```

Este método remove todo o escopo e fará uma consulta normal na tabela.

```ruby
Client.unscoped.all
# SELECT "clients".* FROM "clients"

Client.where(published: false).unscoped.all
# SELECT "clients".* FROM "clients"
```

`unscoped` também pode aceitar um bloqueio.

```ruby
Client.unscoped {
  Client.created_before(Time.zone.now)
}
```

Localizadores Dinâmicos
---------------

Para cada campo (também conhecido como atributo) que você define na sua tabela, o *Active Record* fornece um método localizador. Se você tiver um campo chamado `first_name` no seu *model* `Client` por exemplo, você terá de graça o método `find_by_first_name` fornecido pelo *Active Record*. Se você tiver o campo `locked` no seu *model* `Client`, você também receberá o método `find_by_locked`.

Você pode especificar o ponto de exclamação (`!`) no final de um localizador dinâmico para que ele levante um erro `ActiveRecord::RecordNotFound` caso não seja retornado nenhum registro, por exemplo `Client.find_by_name!("Ryan")`

Se você deseja localizar por *name* e *locked*, você pode encadear esses localizadores juntos simplesmente digitando "`and`" entre os campos. Por exemplo, `Client.find_by_first_name_and_locked("Ryan", true)`.

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

Suponha que queremos definir o atributo 'bloqueado (*locked*)' para `false` se estamos
criando um novo registro, mas não queremos incluí-lo na consulta. Então
queremos encontrar o cliente chamado "Andy", ou se esse cliente não
existir, crie um cliente chamado "Andy" que não esteja bloqueado.

Podemos conseguir isso de duas maneiras. A primeira é usar `create_with`:

```ruby
Client.create_with(locked: false).find_or_create_by(first_name: 'Andy')
```

A segunda maneira é usar um bloco:

```ruby
Client.find_or_create_by(first_name: 'Andy') do |c|
  c.locked = false
end
```

O bloco só será executado se o cliente estiver sendo criado. A segunda vez que rodarmos este código, o todo o bloco será ignorado.

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
`find_or_create_by` mas chamará `new` ao invés de `create`. Isso significa que uma nova instância do *model* será criada na memória, mas não será salva no banco de dados. Continuando com o exemplo `find_or_create_by`, agora queremos o cliente chamado 'Nick':


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
