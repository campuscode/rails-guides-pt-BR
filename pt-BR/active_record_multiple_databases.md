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
Por padrão, o Rails espera os *roles* de escrita e leitura, para o banco primário e sua réplica, respectivamente. Se você tiver um sistema legado, é possível que existam *roles* que não deseja mudar. Neste caso, é possível definir um novo nome de *role* nas configurações da aplicacão.

```ruby
config.active_record.writing_role = :default
config.active_record.reading_role = :readonly
```

É importante conectar ao seu banco em um único *model* e em seguida, herdar para as tabelas, ao invés de abrir várias conexões individuais.
Os usuários do banco têm um limite de conexões abertas, e ao fazer isso, estaríamos multiplicando o número de conexões, visto que o Rails usa o nome da classe do *model* para o nome da conexão. 

Agora que configuramos o `database.yml` e novo *model*, é hora de criar os bancos de dados.
Rails 6.0 inclui todas as *tasks* necessárias para usar múltiplos bancos.

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

## Generators and Migrations

Migrations for multiple databases should live in their own folders prefixed with the
name of the database key in the configuration.

You also need to set the `migrations_paths` in the database configurations to tell Rails
where to find the migrations.

For example the `animals` database would look for migrations in the `db/animals_migrate` directory and
`primary` would look in `db/migrate`. Rails generators now take a `--database` option
so that the file is generated in the correct directory. The command can be run like so:

```bash
$ bin/rails generate migration CreateDogs name:string --database animals
```

If you are using Rails generators, the scaffold and model generators will create the abstract
class for you. Simply pass the database key to the command line

```bash
$ bin/rails generate scaffold Dog name:string --database animals
```

A class with the database name and `Record` will be created. In this example
the database is `Animals` so we end up with `AnimalsRecord`:

```ruby
class AnimalsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :animals }
end
```

The generated model will automatically inherit from `AnimalsRecord`.

```ruby
class Dog < AnimalsRecord
end
```

Note: Since Rails doesn't know which database is the replica for your writer you will need to
add this to the abstract class after you're done.

Rails will only generate the new class once. It will not be overwritten by new scaffolds
or deleted if the scaffold is deleted.

If you already have an abstract class and its name differs from `AnimalsRecord` you can pass
the `--parent` option to indicate you want a different abstract class:

```bash
$ bin/rails generate scaffold Dog name:string --database animals --parent Animals::Record
```

This will skip generating `AnimalsRecord` since you've indicated to Rails that you want to
use a different parent class.

## Activating automatic connection switching

Finally, in order to use the read-only replica in your application you'll need to activate
the middleware for automatic switching.

Automatic switching allows the application to switch from the writer to replica or replica
to writer based on the HTTP verb and whether there was a recent write.

If the application is receiving a POST, PUT, DELETE, or PATCH request the application will
automatically write to the writer database. For the specified time after the write, the
application will read from the primary. For a GET or HEAD request the application will read
from the replica unless there was a recent write.

To activate the automatic connection switching middleware, add or uncomment the following
lines in your application config.

```ruby
config.active_record.database_selector = { delay: 2.seconds }
config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
```

Rails guarantees "read your own write" and will send your GET or HEAD request to the
writer if it's within the `delay` window. By default the delay is set to 2 seconds. You
should change this based on your database infrastructure. Rails doesn't guarantee "read
a recent write" for other users within the delay window and will send GET and HEAD requests
to the replicas unless they wrote recently.

The automatic connection switching in Rails is relatively primitive and deliberately doesn't
do a whole lot. The goal is a system that demonstrates how to do automatic connection
switching that was flexible enough to be customizable by app developers.

The setup in Rails allows you to easily change how the switching is done and what
parameters it's based on. Let's say you want to use a cookie instead of a session to
decide when to swap connections. You can write your own class:

```ruby
class MyCookieResolver
  # code for your cookie class
end
```

And then pass it to the middleware:

```ruby
config.active_record.database_selector = { delay: 2.seconds }
config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
config.active_record.database_resolver_context = MyCookieResolver
```

## Using manual connection switching

There are some cases where you may want your application to connect to a writer or a replica
and the automatic connection switching isn't adequate. For example, you may know that for a
particular request you always want to send the request to a replica, even when you are in a
POST request path.

To do this Rails provides a `connected_to` method that will switch to the connection you
need.

```ruby
ActiveRecord::Base.connected_to(role: :reading) do
  # all code in this block will be connected to the reading role
end
```

The "role" in the `connected_to` call looks up the connections that are connected on that
connection handler (or role). The `reading` connection handler will hold all the connections
that were connected via `connects_to` with the role name of `reading`.

Note that `connected_to` with a role will look up an existing connection and switch
using the connection specification name. This means that if you pass an unknown role
like `connected_to(role: :nonexistent)` you will get an error that says
`ActiveRecord::ConnectionNotEstablished (No connection pool for 'ActiveRecord::Base' found for the 'nonexistent' role.)`

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

### Automatic swapping for horizontal sharding

While Rails now supports an API for connecting to and swapping connections of shards, it does
not yet support an automatic swapping strategy. Any shard swapping will need to be done manually
in your app via a middleware or `around_action`.

### Load Balancing Replicas

Rails also doesn't support automatic load balancing of replicas. This is very
dependent on your infrastructure. We may implement basic, primitive load balancing
in the future, but for an application at scale this should be something your application
handles outside of Rails.

### Joining Across Databases

Applications cannot join across databases. At the moment applications will need to
manually write two selects and split the joins themselves. In a future version Rails
will split the joins for you.

### Schema Cache

If you use a schema cache and multiple databases you'll need to write an initializer
that loads the schema cache from your app. This wasn't an issue we could resolve in
time for Rails 6.0 but hope to have it in a future version soon.
