**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Múltiplos bancos de dados com *Active Record*
=====================================

Este guia cobre o uso de múltiplos bancos de dados na sua aplicação Rails.

Após ler este guia, você saberá:

* Como configurar sua aplicação para usar múltiplos bancos de dados.
* Como a troca automática de conexão funciona.
* Como usar fragmentação horizontal (*horizontal sharding*).
* Quais funcionalidades têm suporte e quais ainda estão sendo desenvolvidas.

--------------------------------------------------------------------------------

Conforme uma aplicação cresce em uso e popularidade, você precisará expandir a aplicação para dar suporte aos novos usuários e seus dados. Uma das dimensões na qual sua aplicação precisará expandir é no âmbito do banco de dados. O Rails agora possui suporte para múltiplos bancos de dados, para que você não precise armazenar tudo em um só lugar.

No presente momento, as seguintes funcionalidades são suportadas:

* Múltiplos bancos de dados de escrita, com réplicas
* Troca automática de conexão para o *model* em questão
* Troca automática entre o banco de escrita e sua réplica, dependendo do verbo HTTP e as escritas mais recentes
* *Tasks* do Rails para criar, deletar e interagir com os múltiplos bancos.

As seguintes funcionalidades (ainda) não têm suporte:

* Troca automática para a fragmentação horizontal (*horizontal sharding*)
* Mesclagem entre *clusters*
* *Load balancing* de réplicas
* Exportar cache de esquema para múltiplos bancos.

## Configurando sua aplicação

O Rails tenta fazer a maior parte do trabalho para você, porém, mesmo assim, ainda existem alguns passos que você precisa seguir para preparar sua aplicação para múltiplos bancos de dados.

Digamos que nós temos uma aplicação com um único banco de escrita, e que precisamos adicionar um novo banco para algumas tabelas que estamos criando. O nome deste novo banco será "animals".

O arquivo `database.yml` ficará assim:

```yaml
production:
  database: my_primary_database
  username: root
  password: <%= ENV['ROOT_PASSWORD'] %>
  adapter: mysql
```

Vamos adicionar uma réplica para a primeira configuração e um segundo banco chamado "animals", também possuindo uma réplica. Para fazer isso, precisamos alterar o arquivo `database.yml`, com sua atual configuração de 2 níveis para uma nova configuração, de 3 níveis.

Se uma houver uma configuração primária, esta será usada como padrão. Se não existir uma configuração com o nome "primary", o Rails usará a primeira que encontrar para o ambiente. As configurações padrão usarão os nomes de arquivo padrão do Rails. Por exemplo, configurações primárias usarão o arquivo `schema.rb` para o esquema, enquanto todas as outras configurações usarão `[CONFIGURATION_NAMESPACE]_schema.rb`.

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

Quando usar um banco réplica, é preciso adicionar `replica: true` à configuração em questão, dentro de `database.yml`. Sem isso, o Rails não saberá qual é o de escrita e qual é a réplica.

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

As classes que conectam ao banco primário e/ou sua réplica podem herdar de `ApplicationRecord`, assim como as aplicações padrão Rails.

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
rails db:rollback                        # Reverte o esquema para uma versão anterior, no ambiente atual (especifique o número de versões com STEP=n)
rails db:rollback:animals                # Reverte o esquema do banco animals para uma versão anterior, no ambiente atual (especifique o número de versões com STEP=n)
rails db:rollback:primary                # Reverte o esquema do banco primário para uma versão anterior, no ambiente atual (especifique o número de versões com STEP=n)
rails db:schema:dump                     # Cria um arquivo de esquema (db/schema.rb ou db/structure.sql)
rails db:schema:dump:animals             # Cria um arquivo de esquema para o banco animals (db/schema.rb ou db/structure.sql)
rails db:schema:dump:primary             # Cria o arquivo db/schema.rb que será poderá ser carregado para qualquer banco suportado
rails db:schema:load                     # Importa um arquivo de esquema (db/schema.rb ou db/structure.sql)
rails db:schema:load:animals             # Importa um arquivo de esquema (db/schema.rb ou db/structure.sql)
rails db:schema:load:primary             # Importa um arquivo de esquema (db/schema.rb ou db/structure.sql)
```

Executar um comando como `bin/rails db:create` criará tanto o banco primário quanto o banco *animals*.
Observe que não existe um comando para criar os usuários. Estes precisam ser criados manualmente, para dar suporte aos usuários somente leitura das réplicas. Se deseja criar somente o banco *animals*, basta executar `bin/rails db:create:animals`.

## *Generators* e *Migrations*

Migrações para múltiplos bancos devem ficar nos seus próprios diretórios, prefixados pelo nome da chave do banco especificado nas configurações.

Também é preciso definir `migrations_paths` nas configurações do banco, para que o Rails saiba onde as encontrar.

Por exemplo, o banco *animals* buscaria suas migrações no diretório `db/animals_migrate`, da mesma forma que o banco *primary* buscaria em `db/migrate`. Os *generators* do Rails agora permitem especificar a opção `--database`, de modo que o arquivo seja gerado no diretório correto. O comando pode ser executado da seguinte forma:

```bash
$ bin/rails generate migration CreateDogs name:string --database animals
```

Se estiver usando os *generators* do Rails, os *generators* de *scaffold* e de *model* criarão a classe abstrata para você. Basta especificar a chave do banco no comando:

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

Observação: Visto que o Rails não sabe qual banco de dados é a réplica para o escritor, você precisará adicionar isso à classe abstrata quando tiver terminado.

O Rails criará a nova classe somente uma vez. Esta não será sobrescrita por futuros *scaffolds* e nem mesmo deletada, caso o *scaffold* seja excluído.

Se você já possui uma classe abstrata e seu nome difere da em `AnimalsRecord`, você pode especificar a opção `--parent` se desejar uma classe abstrata diferente:

```bash
$ bin/rails generate scaffold Dog name:string --database animals --parent Animals::Record
```

Isto fará com que a geração de `AnimalsRecord` seja ignorada, visto que você indicou para o Rails que irá usar uma outra classe pai.

## Habilitando a troca automática de conexão

Por último, para conseguir usar a réplica de leitura na sua aplicação, será necessário habilitar o *middleware* de troca automática.

A troca automática permite que a aplicação alterne entre os bancos de escrita e a réplica, baseado no método HTTP e também se houve uma escrita recente.

Se a aplicação receber uma requisição POST, PUT, DELETE, ou PATCH, a conexão será feita automaticamente para o banco de escrita. Por um determinado tempo após a escrita, a leitura será feita no banco primário. Para os métodos GET ou HEAD, a aplicação usará a réplica, a menos que tenha ocorrido uma escrita recente.

Para habilitar o *middleware* responsável pela troca automática, basta adicionar (ou "descomentar") as seguintes linhas no arquivo de configuração:

```ruby
config.active_record.database_selector = { delay: 2.seconds }
config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
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

## Horizontal sharding

Horizontal sharding is when you split up your database to reduce the number of rows on each
database server, but maintain the same schema across "shards". This is commonly called "multi-tenant"
sharding.

The API for supporting horizontal sharding in Rails is similar to the multiple database / vertical
sharding API that's existed since Rails 6.0.

Shards are declared in the three-tier config like this:

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

Models are then connected with the `connects_to` API via the `shards` key:

```ruby
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    shard_one: { writing: :primary_shard_one, reading: :primary_shard_one_replica }
  }
end
```

Then models can swap connections manually via the `connected_to` API. If
using sharding both a `role` and `shard` must be passed:

```ruby
ActiveRecord::Base.connected_to(role: :writing, shard: :default) do
  @id = Person.create! # Creates a record in shard default
end

ActiveRecord::Base.connected_to(role: :writing, shard: :shard_one) do
  Person.find(@id) # Can't find record, doesn't exist because it was created
                   # in the default shard
end
```

The horizontal sharding API also supports read replicas. You can swap the
role and the shard with the `connected_to` API.

```ruby
ActiveRecord::Base.connected_to(role: :reading, shard: :shard_one) do
  Person.first # Lookup record from read replica of shard one
end
```

## Granular Database Connection Switching

In Rails 6.1 it's possible to switch connections for one database instead of
all databases globally. To use this feature you must first set
`config.active_record.legacy_connection_handling` to `false` in your application
configuration. The majority of applications should not need to make any other
changes since the public APIs have the same behavior.

With `legacy_connection_handling` set to false, any abstract connection class
will be able to switch connections without affecting other connections. This
is useful for switching your `AnimalsRecord` queries to read from the replica
while ensuring your `ApplicationRecord` queries go to the primary.

```ruby
AnimalsRecord.connected_to(role: :reading) do
  Dog.first # Reads from animals_replica
  Person.first  # Reads from primary
end
```

It's also possible to swap connections granularly for shards.

```ruby
AnimalsRecord.connected_to(role: :reading, shard: :shard_one) do
  Dog.first # Will read from shard_one_replica. If no connection exists for shard_one_replica,
  # a ConnectionNotEstablished error will be raised
  Person.first # Will read from primary writer
end
```

To switch only the primary database cluster use `ApplicationRecord`:

```ruby
ApplicationRecord.connected_to(role: :reading, shard: :shard_one) do
  Person.first # Reads from primary_shard_one_replica
  Dog.first # Reads from animals_primary
end
```

`ActiveRecord::Base.connected_to` maintains the ability to switch
connections globally.

## Caveats

### Troca automática para fragmentação horizontal

Embora Rails agora suporte uma API para conectar e trocar conexões de shards, ele faz
ainda não suporta uma estratégia de troca automática. Qualquer troca de fragmentos precisará ser feita manualmente em sua aplicação por meio de um middleware ou `around_action`.

### Réplicas de balanceamento de carga

Rails também não suporta balanceamento de carga automático de réplicas. Isto é muito
dependente de sua infraestrutura. Podemos implementar balanceamento de carga básico e primitivo
no futuro, mas para uma aplicação em escala, isso deve ser algo que sua aplicação
lida fora do Rails.

### Join entre Bancos de Dados

As aplicação não podem fazer `join` entre bancos de dados. No momento, as aplicações precisarão
escrever manualmente dois *selects* e dividir as próprias *joins*. Em uma versão futura do Rails
irá dividir as junções para você.

### Cache de Esquema

Se você usar um *cache* de esquema (*scheme*) e vários bancos de dados, você precisará escrever um inicializador
que carrega o *cache* de esquema da sua aplicação. Não era um problema que pudéssemos resolver em
tempo para Rails 6.0, mas espero tê-lo em uma versão futura em breve.
