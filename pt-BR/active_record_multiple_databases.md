**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Múltiplos bancos de dados com *Active Record*
=====================================

Este guia cobre o uso de múltiplos bancos de dados na sua aplicação Rails.

Após ler este guia, você saberá:

* Como configurar sua aplicação para usar múltiplos bancos de dados.
* Como a troca automática de conexão funciona.
* Como usar fragmentação horizontal (*horizontal sharding*).
* Como migrar do `legacy_connection_handling` para o novo tratamento de conexão.
* Quais funcionalidades têm suporte e quais ainda estão sendo desenvolvidas.

--------------------------------------------------------------------------------

Conforme uma aplicação cresce em uso e popularidade, você precisará expandir a aplicação para dar suporte aos novos usuários e seus dados. Uma das dimensões na qual sua aplicação precisará expandir é no âmbito do banco de dados. O Rails agora possui suporte para múltiplos bancos de dados, para que você não precise armazenar tudo em um só lugar.

No presente momento, as seguintes funcionalidades são suportadas:

* Múltiplos bancos de dados de escrita, com réplicas
* Troca automática de conexão para o *model* em questão
* Troca automática entre o banco de escrita e sua réplica, dependendo do verbo HTTP e as escritas mais recentes
* *Tasks* do Rails para criar, deletar e interagir com os múltiplos bancos.

As seguintes funcionalidades (ainda) não têm suporte:

* *Load balancing* de réplicas

## Configurando sua aplicação

O Rails tenta fazer a maior parte do trabalho para você, porém, mesmo assim, ainda existem alguns passos que você precisa seguir para preparar sua aplicação para múltiplos bancos de dados.

Digamos que nós temos uma aplicação com um único banco de escrita, e que precisamos adicionar um novo banco para algumas tabelas que estamos criando. O nome deste novo banco será "animals".

O arquivo `database.yml` ficará assim:

```yaml
production:
  database: my_primary_database
  adapter: mysql
  username: root
  password: <%= ENV['ROOT_PASSWORD'] %>
```

Vamos adicionar uma réplica para a primeira configuração e um segundo banco chamado "animals", também possuindo uma réplica. Para fazer isso, precisamos alterar o arquivo `database.yml`, com sua atual configuração de 2 níveis para uma nova configuração, de 3 níveis.

Se uma houver uma configuração primária, esta será usada como padrão. Se não existir uma configuração com o nome "primary", o Rails usará a primeira configuração que encontrar como padrão para cada ambiente. As configurações padrão usarão os nomes de arquivo padrão do Rails. Por exemplo, configurações primárias usarão o arquivo `schema.rb` para o esquema, enquanto todas as outras configurações usarão `[CONFIGURATION_NAMESPACE]_schema.rb`.

```yaml
production:
  primary:
    database: my_primary_database
    username: root
    password: <%= ENV['ROOT_PASSWORD'] %>
    adapter: mysql2
  primary_replica:
    database: my_primary_database
    username: root_readonly
    password: <%= ENV['ROOT_READONLY_PASSWORD'] %>
    adapter: mysql2
    replica: true
  animals:
    database: my_animals_database
    username: animals_root
    password: <%= ENV['ANIMALS_ROOT_PASSWORD'] %>
    adapter: mysql2
    migrations_paths: db/animals_migrate
  animals_replica:
    database: my_animals_database
    username: animals_readonly
    password: <%= ENV['ANIMALS_READONLY_PASSWORD'] %>
    adapter: mysql2
    replica: true
```

Quando usar múltiplos bancos, existem algumas configurações importantes.

Em primeiro lugar, o nome do banco para a configuração `primary` e `primary_replica` precisam ser os mesmos, pois estes contém os mesmos dados. Isso também se aplica para os bancos `animals` e `animals_replica`.

Segundo, o nome de usuário para os bancos de escrita e suas réplicas devem ser diferentes, e as permissões do usuário da réplica devem ser somente leitura.

Quando usar um banco réplica, é preciso adicionar `replica: true` à configuração em questão, dentro de `database.yml`. Sem isso, o Rails não saberá qual é o de escrita e qual é a réplica. O Rails também não executará determinadas tarefas, como migrações, em réplicas.

Por último, para os novos bancos de escrita, é preciso adicionar o `migrations_paths` ao diretório onde ficarão as migrações. Veremos `migration_paths` em mais detalhes ao decorrer deste guia.

Agora que temos um novo banco, vamos definir o *model* de conexão. Para usar este novo banco, é necessário criar uma classe abstrata e conectar ao banco *animals*.

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals, reading: :animals_replica }
end
```

Em seguida, atualizaremos `ApplicationRecord` para ela saiba da nossa nova réplica.

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary_replica }
end
```

Se você usar uma classe com nome diferente para o registro da aplicação, precisará
definir `primary_abstract_class`, para que o Rails saiba qual classe `ActiveRecord::Base`
deve compartilhar uma conexão com.

```ruby
class PrimaryApplicationRecord < ActiveRecord::Base
  self.primary_abstract_class
end
```

As classes que se conectam a primary/primary_replica podem herdar de da classe primária
como aplicações Rails padrão:

```ruby
class Person < ApplicationRecord
end
```
Por padrão, o Rails espera os *roles* de escrita e leitura, para o banco primário e sua réplica, respectivamente. Se você tiver um sistema legado, é possível que existam *roles* que não deseja mudar. Neste caso, é possível definir um novo nome de *role* nas configurações da aplicação.

```ruby
config.active_record.writing_role = :default
config.active_record.reading_role = :readonly
```

É importante conectar ao seu banco em um único *model* e em seguida, herdar para as tabelas, ao invés de abrir várias conexões individuais.
Os usuários do banco têm um limite de conexões abertas, e ao fazer isso, estaríamos multiplicando o número de conexões, visto que o Rails usa o nome da classe do *model* para o nome da conexão. 

Agora que configuramos o `database.yml` e novo *model*, é hora de criar os bancos de dados.
O Rails 6.0 inclui todas as *tasks* necessárias para usar múltiplos bancos.

É possível ver todos os comandos disponíveis usando `bin/rails -T`:

```bash
$ bin/rails -T
rails db:create                          # Cria o banco a partir da DATABASE_URL ou config/database.yml para o ambiente atual
rails db:create:animals                  # Cria o banco animals para o ambiente atual
rails db:create:primary                  # Cria o banco primário para o ambiente atual
rails db:drop                            # Destrói o banco a partir da DATABASE_URL ou config/database.yml para o ambiente atual
rails db:drop:animals                    # Destrói o banco animals para o ambiente atual
rails db:drop:primary                    # Destrói o banco primário para o ambiente atual
rails db:migrate                         # Migra o banco (as opções são: VERSION=x, VERBOSE=false, SCOPE=blog)
rails db:migrate:animals                 # Migra o banco animals para o ambiente atual
rails db:migrate:primary                 # Migra o banco primário para o ambiente atual
rails db:migrate:status                  # Exibe o status das migrações
rails db:migrate:status:animals          # Exibe o status das migrações para o banco animals
rails db:migrate:status:primary          # Exibe o status das migrações para o banco primário
rails db:reset                           # Elimina e recria todos os bancos de dados com seu esquema para o ambiente atual e carrega as seeds
rails db:reset:animals                   # Descarta e recria o banco de dados de animais com seu esquema para o ambiente atual e carrega as seeds
rails db:reset:primary                   # Descarta e recria o banco de dados primário com seu esquema para o ambiente atual e carrega as seeds
rails db:rollback                        # Reverte o esquema para uma versão anterior, no ambiente atual (especifique o número de versões com STEP=n)
rails db:rollback:animals                # Reverte o esquema do banco animals para uma versão anterior, no ambiente atual (especifique o número de versões com STEP=n)
rails db:rollback:primary                # Reverte o esquema do banco primário para uma versão anterior, no ambiente atual (especifique o número de versões com STEP=n)
rails db:schema:dump                     # Cria um arquivo de esquema (db/schema.rb ou db/structure.sql)
rails db:schema:dump:animals             # Cria um arquivo de esquema para o banco animals (db/schema.rb ou db/structure.sql)
rails db:schema:dump:primary             # Cria o arquivo db/schema.rb que será poderá ser carregado para qualquer banco suportado
rails db:schema:load                     # Importa um arquivo de esquema (db/schema.rb ou db/structure.sql)
rails db:schema:load:animals             # Importa um arquivo de esquema (db/schema.rb ou db/structure.sql)
rails db:schema:load:primary             # Importa um arquivo de esquema (db/schema.rb ou db/structure.sql)
rails db:setup                           # Cria todos os bancos de dados, carrega todos com os esquemas e inicializa com os dados de seeds (use db:reset para também descartar todos os bancos de dados primeiro)
rails db:setup:animals                   # Cria o banco de dados de animais, carrega o esquema e inicializa com os dados de seeds (use db:reset:animals para também descartar o banco de dados primeiro)
rails db:setup:primary                   # Cria o banco de dados primário, carrega o esquema e inicializa com os dados de seeds (use db:reset:primary para também descartar o banco de dados primeiro)
```

Executar um comando como `bin/rails db:create` criará tanto o banco primário quanto o banco *animals*.
Observe que não existe um comando para criar os usuários do banco de dados. Estes precisam ser criados manualmente, para dar suporte aos usuários somente leitura das réplicas. Se deseja criar somente o banco *animals*, basta executar `bin/rails db:create:animals`.

## Conectando-se a Bancos de Dados sem gerenciar *Schema* e *Migrations*

Se você gostaria de se conectar a um banco de dados externo sem nenhum gerenciamento de banco de dados
usando os comandos, como gerenciamento de *schema*, *migrations*, *seeds*, etc., você pode definir
a opção de configuração do banco de dados `database_tasks: false`. Por padrão ela é
definida como verdadeira.

```yaml
production:
  primary:
    database: my_database
    adapter: mysql2
  animals:
    database: my_animals_database
    adapter: mysql2
    database_tasks: false
```

## *Generators* e *Migrations*

Migrações para múltiplos bancos devem ficar nos seus próprios diretórios, prefixados pelo nome da chave do banco especificado nas configurações.

Também é preciso definir `migrations_paths` nas configurações do banco, para que o Rails saiba onde as encontrar.

Por exemplo, o banco *animals* buscaria suas migrações no diretório `db/animals_migrate`, da mesma forma que o banco *primary* buscaria em `db/migrate`. Os *generators* do Rails agora permitem especificar a opção `--database`, de modo que o arquivo seja gerado no diretório correto. O comando pode ser executado da seguinte forma:

```bash
$ bin/rails generate migration CreateDogs name:string --database animals
```

Se estiver usando os *generators* do Rails, os *generators* de *scaffold* e de *model* criarão a classe abstrata para você. Basta especificar a chave do banco no comando.

```bash
$ bin/rails generate scaffold Dog name:string --database animals
```

Uma classe com mesmo nome do banco e a palavra `Record` será criada. Neste exemplo, o banco é `Animals`, então teremos `AnimalsRecord`:

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals }
end
```

O *model* gerado herdará automaticamente de `AnimalsRecord`.

```ruby
class Dog < AnimalsRecord
end
```

Note: Visto que o Rails não sabe qual banco de dados é a réplica para o escritor, você precisará adicionar isso à classe abstrata quando tiver terminado.

O Rails criará a nova classe somente uma vez. Esta não será sobrescrita por futuros *scaffolds* e nem mesmo deletada, caso o *scaffold* seja excluído.

Se você já possui uma classe abstrata e seu nome difere da em `AnimalsRecord`, você pode especificar a opção `--parent` se desejar uma classe abstrata diferente:

```bash
$ bin/rails generate scaffold Dog name:string --database animals --parent Animals::Record
```

Isto fará com que a geração de `AnimalsRecord` seja ignorada, visto que você indicou para o Rails que irá usar uma outra classe pai.

## Habilitando a troca automática de papel

Por último, para conseguir usar a réplica de leitura na sua aplicação, será necessário habilitar o *middleware* de troca automática.

A troca automática permite que a aplicação alterne entre os bancos de escrita e a réplica, baseado no método HTTP e também se houve uma escrita recente pela requisição do usuário.

Se a aplicação receber uma requisição POST, PUT, DELETE, ou PATCH, a conexão será feita automaticamente para o banco de escrita. Por um determinado tempo após a escrita, a leitura será feita no banco primário. Para os métodos GET ou HEAD, a aplicação usará a réplica, a menos que tenha ocorrido uma escrita recente.

Para ativar o *middleware* de troca automática de conexão, você pode executar o gerados de troca automática:

```
$ bin/rails g active_record:multi_db
```

E então descomentar as seguintes linhas:

```ruby
Rails.application.configure do
  config.active_record.database_selector = { delay: 2.seconds }
  config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
end
```

O Rails garante o chamado "leia sua própria escrita" e encaminhará as requisições de método GET ou HEAD para o banco de escrita, se estes ocorrerem dentro do intervalo especificado pelo `delay`. Você deve alterar esta configuração para melhor atender a infraestrutura do seu banco de dados. O Rails não garante "leia sua escrita recente" para outros usuários dentro do intervalo de *delay*, e encaminhará as requisições GET e HEAD para a réplica, a menos que eles tenham escrito algo recentemente.

A troca automática de conexão do Rails é relativamente simples e deliberadamente não faz muita coisa. O objetivo é ter um sistema que demonstre como fazer a troca automática de conexão, e que seja suficientemente flexível para que as pessoas desenvolvedoras possam customizar.

O *setup* do Rails permite que você altere com facilidade como é feita a troca automática, e em quais parâmetros ela se baseia. Digamos que você queira usar *cookies* ao invés da *session* para decidir quando trocar as conexões. Você poderia escrever sua própria classe:

```ruby
class MyCookieResolver
  # código da sua classe
end
```

Em seguida, especifique sua nova classe no *middleware*:

```ruby
config.active_record.database_selector = { delay: 2.seconds }
config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
config.active_record.database_resolver_context = MyCookieResolver
```

## Usando a troca de conexão manual

Existem casos nos quais você pode querer que sua aplicação se conecte ao banco de escrita ou à réplica, e onde a troca automática de conexão não será adequada. Por exemplo, suponhamos que exista uma requisição em particular que sempre deverá ser encaminhada para a réplica, mesmo que tenha método POST.

Para isso, o Rails possui um método chamado `connected_to`, que trocará para a conexão desejada.

```ruby
ActiveRecord::Base.connected_to(role: :reading) do
  # o código deste bloco estará conectado ao role 'reading'
end
```

O *role* definido em `connected_to` buscará as conexões ligadas naquele determinado *handler* (ou *role*). O *handler* da conexão `reading` receberá todas as conexões feitas através do `connects_to`, que tenham o *role* `reading`.

Observe que o `connected_to` com um *role* definido buscará e trocará para uma conexão existente, usando o nome da conexão. Isso quer dizer que ao passar um *role* desconhecido ou inválido, como por exemplo, `connected_to(role: :nonexistent)`, causará um erro com a seguinte mensagem: `ActiveRecord::ConnectionNotEstablished (No connection pool for 'ActiveRecord::Base' found for the 'nonexistent' role.)`

Se você quiser que o Rails garanta que todas as consultas executadas sejam somente leitura, passe `prevent_writes: true`.
Isso apenas impede que consultas que pareçam gravações sejam enviadas ao banco de dados.
Você também deve configurar seu banco de dados de réplica para ser executado no modo somente leitura.

```ruby
ActiveRecord::Base.connected_to(role: :reading, prevent_writes: true) do
  # O Rails irá checar cada query para garantir que é uma query de leitura
end
```

## Horizontal sharding

Fragmentação horizontal é quando você divide seu banco de dados para reduzir o número de linhas em cada
servidor de banco de dados, mas mantém o mesmo esquema em "fragmentos". Isso é comumente chamado de fragmentação "multilocatário" (*multi-tenant*).

A API para suportar fragmentação horizontal no Rails é semelhante ao banco de dados múltiplo / 
API de vertical fragmentação que existe desde o Rails 6.0.

Os fragmentos são declarados na configuração de três camadas como este:

```yaml
production:
  primary:
    database: my_primary_database
    adapter: mysql2
  primary_replica:
    database: my_primary_database
    adapter: mysql2
    replica: true
  primary_shard_one:
    database: my_primary_shard_one
    adapter: mysql2
  primary_shard_one_replica:
    database: my_primary_shard_one
    adapter: mysql2
    replica: true
```

Os *models* são então conectados à API `connects_to` por meio da chave` shards`:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    shard_one: { writing: :primary_shard_one, reading: :primary_shard_one_replica }
  }
end
```

Então, os *models* podem trocar conexões manualmente por meio da API `connected_to`. Se
usando o *sharding*, um `role` e um` shard` devem ser passados:

```ruby
ActiveRecord::Base.connected_to(role: :writing, shard: :default) do
  @id = Person.create! # Cria um registro no fragmento padrão
end

ActiveRecord::Base.connected_to(role: :writing, shard: :shard_one) do
  Person.find(@id) # Não é possível encontrar o registro, não existe porque foi criado
                   # no fragmento padrão
end
```

A API de fragmentação horizontal também oferece suporte a réplicas de leitura. Você pode trocar o
papel (*role*) e o fragmento (*shard*) com a API `connected_to`.

```ruby
ActiveRecord::Base.connected_to(role: :reading, shard: :shard_one) do
  Person.first # Procura um registro de uma réplica de leitura do shard_one
end
```

## Activating automatic shard switching

Applications are able to automatically switch shards per request using the provided
middleware.

The ShardSelector Middleware provides a framework for automatically
swapping shards. Rails provides a basic framework to determine which
shard to switch to and allows for applications to write custom strategies
for swapping if needed.

The ShardSelector takes a set of options (currently only `lock` is supported)
that can be used by the middleware to alter behavior. `lock` is
true by default and will prohibit the request from switching shards once
inside the block. If `lock` is false, then shard swapping will be allowed.
For tenant based sharding, `lock` should always be true to prevent application
code from mistakenly switching between tenants.

The same generator as the database selector can be used to generate the file for
automatic shard swapping:

```
$ bin/rails g active_record:multi_db
```

Then in the file uncomment the following:

```ruby
Rails.application.configure do
  config.active_record.shard_selector = { lock: true }
  config.active_record.shard_resolver = ->(request) { Tenant.find_by!(host: request.host).shard }
end
```

Applications must provide the code for the resolver as it depends on application
specific models. An example resolver would look like this:

```ruby
config.active_record.shard_resolver = ->(request) {
  subdomain = request.subdomain
  tenant = Tenant.find_by_subdomain!(subdomain)
  tenant.shard
}
```

## Migrate to the new connection handling

In Rails 6.1+, Active Record provides a new internal API for connection management.
In most cases applications will not need to make any changes except to opt-in to the
new behavior (if upgrading from 6.0 and below) by setting
`config.active_record.legacy_connection_handling = false`. If you have a single database
application, no other changes will be required. If you have a multiple database application
the following changes are required if your application is using these methods:

* `connection_handlers` and `connection_handlers=` no longer works in the new connection
handling. If you were calling a method on one of the connection handlers, for example,
`connection_handlers[:reading].retrieve_connection_pool("ActiveRecord::Base")`
you will now need to update that call to be
`connection_handlers.retrieve_connection_pool("ActiveRecord::Base", role: :reading)`.
* Calls to `ActiveRecord::Base.connection_handler.prevent_writes` will need to be updated
to `ActiveRecord::Base.connection.preventing_writes?`.
* If you need all the pools, including writing and reading, a new method has been provided on
the handler. Call `connection_handler.all_connection_pools` to use this. In most cases though
you'll want writing or reading pools with `connection_handler.connection_pool_list(:writing)` or
`connection_handler.connection_pool_list(:reading)`.
* If you turn off `legacy_connection_handling` in your application, any method that's unsupported
will raise an error (i.e. `connection_handlers=`).

## Alternando Conexão de Banco de Dados Granular

No Rails 6.1 é possível alternar conexões para um banco de dados ao invés de
todos os bancos de dados globalmente. Para usar este recurso, você deve primeiro definir
`config.active_record.legacy_connection_handling` para` false` nas configurações da sua
aplicação. A maioria das aplicações não precisam fazer nenhuma outra
alteração, uma vez que as APIs públicas têm o mesmo comportamento. Consulte a seção acima para
como habilitar e migrar do `legacy_connection_handling`.

Com `legacy_connection_handling` definido como `false`, qualquer classe de conexão abstrata
será capaz de alternar as conexões sem afetar outras conexões. Esse
é útil para mudar suas consultas `AnimalsRecord` para ler a partir da réplica
enquanto garante que suas consultas `ApplicationRecord` vão para o primário.

```ruby
AnimalsRecord.connected_to(role: :reading) do
  Dog.first # Reads from animals_replica
  Person.first  # Reads from primary
end
```

Também é possível trocar conexões granularmente por fragmentos.

```ruby
AnimalsRecord.connected_to(role: :reading, shard: :shard_one) do
  Dog.first # Will read from shard_one_replica. If no connection exists for shard_one_replica,
  # a ConnectionNotEstablished error will be raised
  Person.first # Will read from primary writer
end
```

Para mudar apenas o [_cluster_](https://pt.wikipedia.org/wiki/Cluster) de banco de dados primário, use `ApplicationRecord`:

```ruby
ApplicationRecord.connected_to(role: :reading, shard: :shard_one) do
  Person.first # Reads from primary_shard_one_replica
  Dog.first # Reads from animals_primary
end
```

`ActiveRecord::Base.connected_to` mantém a capacidade de alternar
conexões globalmente.

### Manipulando associações com *join* entre bancos de dados

A partir do Rails 7.0+, o Active Record tem uma opção para manipular associações que realizariam
um *join* em vários bancos de dados. Se você tem um *has many through* ou uma associação *has one through*
que você deseja desabilitar o *join* e realizar 2 ou mais consultas, passe a opção `disable_joins: true`.

Por exemplo:

```ruby
class Dog < AnimalsRecord
  has_many :treats, through: :humans, disable_joins: true
  has_many :humans

  has_one :home
  has_one :yard, through: :home, disable_joins: true
end

class Home
  belongs_to :dog
  has_one :yard
end

class Yard
  belongs_to :home
end
```

Anteriormente chamando `@dog.treats` sem `disable_joins` ou `@dog.yard` sem `disable_joins`
geraria um erro porque os bancos de dados não conseguem lidar com *joins* entre *clusters*. Com o
opção `disable_joins`, Rails irá gerar múltiplas consultas de seleção
para evitar a tentativa de *join* entre *clusters*. Para a associação acima, `@dog.treats` geraria o
seguinte SQL:

```sql
SELECT "humans"."id" FROM "humans" WHERE "humans"."dog_id" = ?  [["dog_id", 1]]
SELECT "treats".* FROM "treats" WHERE "treats"."human_id" IN (?, ?, ?)  [["human_id", 1], ["human_id", 2], ["human_id", 3]]
```

Enquanto `@dog.yard` geraria o seguinte SQL:

```sql
SELECT "home"."id" FROM "homes" WHERE "homes"."dog_id" = ? [["dog_id", 1]]
SELECT "yards".* FROM "yards" WHERE "yards"."home_id" = ? [["home_id", 1]]
```

Há algumas coisas importantes a serem observadas com esta opção:

1) Pode haver implicações de desempenho, pois agora duas ou mais consultas serão executadas (dependendo
na associação) em vez de um *join*. Se a seleção de `humans` retornou um grande número de IDs
o select for `treats` pode enviar muitos IDs.
2) Como não estamos mais realizando *join*, uma consulta com uma ordem ou limite agora é classificada na memória, pois
ordem de uma tabela não pode ser aplicada a outra tabela.
3) Essa configuração deve ser adicionada a todas as associações nas quais você deseja que a participação seja desabilitada.
O Rails não pode adivinhar isso para você porque o carregamento de associação é *lazy*, para carregar `treats` em `@dog.treats`
o Rails já precisa saber qual SQL deve ser gerado.

### *Cache* de *Schema*

Se você quiser carregar um *cache* de *schema* para cada banco de dados, você deve definir um `schema_cache_path` em cada configuração de banco de dados e definir `config.active_record.lazily_load_schema_cache = true` na configuração de sua aplicação. Observe que isso carregará o *cache* lentamente quando as conexões do banco de dados forem estabelecidas.

## Caveats

### Load Balancing Replicas

Rails also doesn't support automatic load balancing of replicas. This is very
dependent on your infrastructure. We may implement basic, primitive load balancing
in the future, but for an application at scale this should be something your application
handles outside of Rails.