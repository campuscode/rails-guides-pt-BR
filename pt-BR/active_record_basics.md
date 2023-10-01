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

O que é *Active Record*?
------------------------

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

Convenção sobre configuração no Active Record
----------------------------------------------

Quando escrevemos aplicações usando outras linguagens de programação ou frameworks, pode
ser necessário escrever muito código de configuração. Isto é particularmente verdadeiro para
frameworks ORM em geral. Entretanto, se você seguir as convenções adotadas pelo Rails, será
necessário escrever pouco código de configuração (em alguns casos, nenhum) quando criar *models*
do *Active Record*. A idéia por trás disso é que se você configura a sua aplicação da mesma
forma na maior parte da vezes, ela deveria ser a forma padrão. Então, configuração explícita faz-se
necessária somente em casos que você não pode seguir a convenção padrão.

### Convenções para nomeação

Por padrão, o *Active Record* usa algumas definições de nomeação para descobrir como
o mapeamento entre *models* e tabelas do banco de dados será criado. O Rails irá pluralizar
o nome da sua classe para encontrar a sua respectiva tabela no banco de dados. Sendo assim,
para a classe `Book` (livro), você deverá ter uma tabela no banco de dados chamada **books** (livros).
Os mecanismos de pluralização do Rails são muito poderosos, sendo capazes de pluralizar (e
singularizar) palavras regulares e irregulares. Quando usamos nomes de classes compostas por
duas ou mais palavras, o nome do seu *model* deve seguir a convenção do *Ruby*,
utilizando *CamelCase*, enquanto a tabela deve utilizar a forma *snake_case*, separando as palavras utilizando o caracter sublinhado.
Exemplos:

* *Model* - Escrito no singular capitalizando a primeira letra de cada palavra
(p. ex., `BookClub`)
* Tabela no banco de dados - Escrito no plural separando cada palavra com sublinhado
(p. ex. `book_clubs`)

| *Model* / Classe | Tabela / Schema |
| ---------------- | --------------- |
| `Article`        | `articles`      |
| `LineItem`       | `line_items`    |
| `Deer`           | `deers`         |
| `Mouse`          | `mice`          |
| `Person`         | `people`        |

### Convenções de *schema* (esquema)

O *Active Record* utiliza convenções de nomeação para as colunas em tabelas
de banco de dados, dependendo do seu propósito.

* **Chaves estrangeiras** - Esses campos devem seguir o padrão de nomeação
  `nome_da_tabela_no_singular_id` (p. ex., `item_id`, `pedido_id`). O
  *Active Record* irá buscar por esses campos quando você criar associações
  entre os seus *models*.
* **Chaves primárias** - Por padrão, o *Active Record* utiliza uma coluna
  do tipo inteiro chamada `id` como a chave primária da tabela (`bigint`
  para PostgreSQL e MySQL, `integer` para SQLite). Quando você usa as
  [*Migrations* do *Active Record*](active_record_migrations.html) para
  criar suas tabelas, essa coluna será criada automaticamente.

Existem outros nomes de colunas opcionais que vão adicionar alguns
comportamentos adicionais para instâncias do *Active Record*.

* `created_at` - Automaticamente informado com a data e hora atual
  de quando o registro foi criado.
* `updated_at` - Automaticamente informado com a data e hora atual
  de quando o registor foi criado ou atualizado.
* `lock_version` - Adiciona [bloqueio otimista](
  https://api.rubyonrails.org/classes/ActiveRecord/Locking.html) para
  um *model*.
* `type` - Especifica que um *model* utiliza [Herança de tabela única](
  https://api.rubyonrails.org/classes/ActiveRecord/Base.html#class-ActiveRecord::Base-label-Single+table+inheritance).
* `(nome_da_associacao)_type` - Armazena o tipo
  [associação polimórfica](association_basics.html#polymorphic-associations).
* `(nome_da_tabela)_count` - Usado para cachear o número de objetos vinculados
  em uma associação. Por exemplo, uma coluna `comentarios_count` em uma classe
  `Artigo` que possui várias instâncias de `Comentario` vai cachear o número de
  comentários existentes para cada artigo.

NOTE: Apesar de essas colunas serem opcionais, elas estão em fato reservadas pelo *Active Record*. Evite utilizar
palavras-chave reservadas a não ser que você deseje a funcionalidade adicional. Por exemplo, `type` é uma
palavra-chave reservada para designar que uma tabela está usando Herança de tabela única (STI). Se você não está
utilizando STI, tente utilizar análogos como `context`, que ainda descrevem de forma correta o tipo de dado
que você está modelando.

Criando Models do Active Record
-----------------------------

Para criar *models* do *Active Record*, use a subclasse `ApplicationRecord` e você está pronto para começar:

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
  # ...
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

CRUD é um acrônimo para os quatro verbos que utilizamos na operação dos dados: _**C**reate_ (criar),
_**R**ead_ (ler, consultar), _**U**pdate_ (atualizar) e _**D**elete_ (deletar, destruir). O *Active Record*
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

Isso é o mesmo que se você escrevesse:

```ruby
User.update(:all, max_login_attempts: 3, must_change_password: true)
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
```

```irb
irb> user = User.new
irb> user.save
=> false
irb> user.save!
ActiveRecord::RecordInvalid: Validation failed: Name can't be blank
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
class CreatePublications < ActiveRecord::Migration[7.0]
  def change
    create_table :publications do |t|
      t.string :title
      t.text :description
      t.references :publication_type
      t.references :publisher, polymorphic: true
      t.boolean :single_issue

      t.timestamps
    end
  end
end
```

O Rails mantém o controle de quais arquivos foram enviados ao banco de dados e fornece
ferramentas de reversão. Para realmente criar uma tabela, você deverá executar
`bin/rails db:migrate` e para reverter, `bin/rails db:rollback`

Observe que o código acima é agnóstico em relação ao banco de dados: irá rodar em MySQL,
PostgreSQL, Oracle, entre outros. Você pode aprender mais sobre *migrations*
no [Guia de *Migrations* do *Active Record*](active_record_migrations.html).
