**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Active Record e PostgreSQL
============================

Esse guia cobre o uso específico de Active Record pelo PostgreSQL

Após ler este guia, você saberá:

* Como usar os *datatypes* do PostgreSQL.
* Como usar chaves primárias UUID.
* Como implementar pesquisa com texto no PostregreSQL.
* Como usar *database views* em seus *models* Active Record.

--------------------------------------------------------------------------------

Para usar o adaptador PostgreSQL, você precisa ter pelo menos a versão 9.3 instalada. Versões anteriores não são suportadas.

Para iniciar o PostgreSQL, veja o [guia de configuração Rails](configuring.html#configuring-a-postgresql-database).
Ele descreve como configurar o Active Record para o PostgreSQL.

Datatypes
---------

O PostgreSQL oferece um número de *datatypes* específicos. Seguindo a lista de tipos que são suportados pelo adaptador PostgreSQL.

### Bytea

* [definição de tipo](https://www.postgresql.org/docs/current/static/datatype-binary.html)
* [funções e operações](https://www.postgresql.org/docs/current/static/functions-binarystring.html)

```ruby
# db/migrate/20140207133952_create_documents.rb
create_table :documents do |t|
  t.binary 'payload'
end
```

```ruby
# app/models/document.rb
class Document < ApplicationRecord
end
```

```ruby
# Usage
data = File.read(Rails.root + "tmp/output.pdf")
Document.create payload: data
```

### Array

* [definição de tipo](https://www.postgresql.org/docs/current/static/arrays.html)
* [funções e operações](https://www.postgresql.org/docs/current/static/functions-array.html)

```ruby
# db/migrate/20140207133952_create_books.rb
create_table :books do |t|
  t.string 'title'
  t.string 'tags', array: true
  t.integer 'ratings', array: true
end
add_index :books, :tags, using: 'gin'
add_index :books, :ratings, using: 'gin'
```

```ruby
# app/models/book.rb
class Book < ApplicationRecord
end
```

```ruby
# Usage
Book.create title: "Brave New World",
            tags: ["fantasy", "fiction"],
            ratings: [4, 5]

## Books for a single tag
Book.where("'fantasy' = ANY (tags)")

## Books for multiple tags
Book.where("tags @> ARRAY[?]::varchar[]", ["fantasy", "fiction"])

## Books with 3 or more ratings
Book.where("array_length(ratings, 1) >= 3")
```

### Hstore

* [definição de tipo](https://www.postgresql.org/docs/current/static/hstore.html)
* [funções e operações](https://www.postgresql.org/docs/current/static/hstore.html#id-1.11.7.26.5)

NOTE: Você precisa habilitar a extensão `hstore` para usar o hstore.

```ruby
# db/migrate/20131009135255_create_profiles.rb
class CreateProfiles < ActiveRecord::Migration[7.0]
  enable_extension 'hstore' unless extension_enabled?('hstore')
  create_table :profiles do |t|
    t.hstore 'settings'
  end
end
```

```ruby
# app/models/profile.rb
class Profile < ApplicationRecord
end
```

```irb
irb> Profile.create(settings: { "color" => "blue", "resolution" => "800x600" })

irb> profile = Profile.first
irb> profile.settings
=> {"color"=>"blue", "resolution"=>"800x600"}

irb> profile.settings = {"color" => "yellow", "resolution" => "1280x1024"}
irb> profile.save!

irb> Profile.where("settings->'color' = ?", "yellow")
=> #<ActiveRecord::Relation [#<Profile id: 1, settings: {"color"=>"yellow", "resolution"=>"1280x1024"}>]>
```

### JSON e JSONB

* [definição de tipo](https://www.postgresql.org/docs/current/static/datatype-json.html)
* [funções e operações](https://www.postgresql.org/docs/current/static/functions-json.html)

```ruby
# db/migrate/20131220144913_create_events.rb
# ... for json datatype:
create_table :events do |t|
  t.json 'payload'
end
# ... or for jsonb datatype:
create_table :events do |t|
  t.jsonb 'payload'
end
```

```ruby
# app/models/event.rb
class Event < ApplicationRecord
end
```

```irb
irb> Event.create(payload: { kind: "user_renamed", change: ["jack", "john"]})

irb> event = Event.first
irb> event.payload
=> {"kind"=>"user_renamed", "change"=>["jack", "john"]}

## Query based on JSON document
# The -> operator returns the original JSON type (which might be an object), whereas ->> returns text
irb> Event.where("payload->>'kind' = ?", "user_renamed")
```

### Tipos de Intervalo

* [definição de tipo](https://www.postgresql.org/docs/current/static/rangetypes.html)
* [funções e operações](https://www.postgresql.org/docs/current/static/functions-range.html)

Esse tipo é mapeado para objetos [`Range`](https://ruby-doc.org/core-2.7.0/Range.html) no Ruby.

```ruby
# db/migrate/20130923065404_create_events.rb
create_table :events do |t|
  t.daterange 'duration'
end
```

```ruby
# app/models/event.rb
class Event < ApplicationRecord
end
```

```irb
irb> Event.create(duration: Date.new(2014, 2, 11)..Date.new(2014, 2, 12))

irb> event = Event.first
irb> event.duration
=> Tue, 11 Feb 2014...Thu, 13 Feb 2014

## All Events on a given date
irb> Event.where("duration @> ?::date", Date.new(2014, 2, 12))

## Working with range bounds
irb> event = Event.select("lower(duration) AS starts_at").select("upper(duration) AS ends_at").first

irb> event.starts_at
=> Tue, 11 Feb 2014
irb> event.ends_at
=> Thu, 13 Feb 2014
```

### Tipos Compostos

* [definição de tipo](https://www.postgresql.org/docs/current/static/rowtypes.html)

Atualmente, não existe suporte específico para tipos compostos. Eles são mapeados para colunas de texto normais:

```sql
CREATE TYPE full_address AS
(
  city VARCHAR(90),
  street VARCHAR(90)
);
```

```ruby
# db/migrate/20140207133952_create_contacts.rb
execute <<-SQL
  CREATE TYPE full_address AS
  (
    city VARCHAR(90),
    street VARCHAR(90)
  );
SQL
create_table :contacts do |t|
  t.column :address, :full_address
end
```

```ruby
# app/models/contact.rb
class Contact < ApplicationRecord
end
```

```irb
irb> Contact.create address: "(Paris,Champs-Élysées)"
irb> contact = Contact.first
irb> contact.address
=> "(Paris,Champs-Élysées)"
irb> contact.address = "(Paris,Rue Basse)"
irb> contact.save!
```

### Tipos Enumerados

* [definição de tipo](https://www.postgresql.org/docs/current/static/datatype-enum.html)

O tipo pode ser mapeado como uma coluna de texto normal ou para um [`ActiveRecord::Enum`](https://api.rubyonrails.org/classes/ActiveRecord/Enum.html).

```ruby
# db/migrate/20131220144913_create_articles.rb
def up
  create_enum :article_status, ["draft", "published"]

  create_table :articles do |t|
    t.enum :status, enum_type: :article_status, default: "draft", null: false
  end
end

# There's no built in support for dropping enums, but you can do it manually.
# You should first drop any table that depends on them.
def down
  drop_table :articles

  execute <<-SQL
    DROP TYPE article_status;
  SQL
end
```

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  enum status: {
    draft: "draft", published: "published"
  }, _prefix: true
end
```

```irb
irb> Article.create status: "draft"
irb> article = Article.first
irb> article.status_draft!
irb> article.status
=> "draft"

irb> article.status_published?
=> false
```

Para adicionar um novo valor antes ou depois de um já existente, é necessário usar o [ALTER TYPE](https://www.postgresql.org/docs/current/static/sql-altertype.html):

```ruby
# db/migrate/20150720144913_add_new_state_to_articles.rb
# NOTE: ALTER TYPE ... ADD VALUE cannot be executed inside of a transaction block so here we are using disable_ddl_transaction!
disable_ddl_transaction!

def up
  execute <<-SQL
    ALTER TYPE article_status ADD VALUE IF NOT EXISTS 'archived' AFTER 'published';
  SQL
end
```

NOTE: Valores ENUM não podem ser removidos atualmente. Você pode ler o motivo [aqui](https://www.postgresql.org/message-id/29F36C7C98AB09499B1A209D48EAA615B7653DBC8A@mail2a.alliedtesting.com).

Dica: para mostrar todos os valores de todos os enums que você tem, deve chamar essa query no console `bin/rails db` ou `psql`:

```sql
SELECT n.nspname AS enum_schema,
       t.typname AS enum_name,
       e.enumlabel AS enum_value
  FROM pg_type t
      JOIN pg_enum e ON t.oid = e.enumtypid
      JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
```

### UUID

* [definição de tipo](https://www.postgresql.org/docs/current/static/datatype-uuid.html)
* [pgcrypto generator function](https://www.postgresql.org/docs/current/static/pgcrypto.html)
* [uuid-ossp generator functions](https://www.postgresql.org/docs/current/static/uuid-ossp.html)

NOTE: Você precisa habilitar a extensão `pgcrypto` (apenas para PostgreSQL >= 9.4) ou a extensão `uuid-ossp` para usar uuid.

```ruby
# db/migrate/20131220144913_create_revisions.rb
create_table :revisions do |t|
  t.uuid :identifier
end
```

```ruby
# app/models/revision.rb
class Revision < ApplicationRecord
end
```

```irb
irb> Revision.create identifier: "A0EEBC99-9C0B-4EF8-BB6D-6BB9BD380A11"

irb> revision = Revision.first
irb> revision.identifier
=> "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11"
```

Você pode usar o tipo `uuid` para definir referências em *migrations*:

```ruby
# db/migrate/20150418012400_create_blog.rb
enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
create_table :posts, id: :uuid

create_table :comments, id: :uuid do |t|
  # t.belongs_to :post, type: :uuid
  t.references :post, type: :uuid
end
```

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  has_many :comments
end
```

```ruby
# app/models/comment.rb
class Comment < ApplicationRecord
  belongs_to :post
end
```

Veja [essa seção](#uuid-primary-keys) para mais detalhes sobre usar UUIDs como chaves primárias.

### Bit String Types

* [definição de tipo](https://www.postgresql.org/docs/current/static/datatype-bit.html)
* [funções e operações](https://www.postgresql.org/docs/current/static/functions-bitstring.html)

```ruby
# db/migrate/20131220144913_create_users.rb
create_table :users, force: true do |t|
  t.column :settings, "bit(8)"
end
```

```ruby
# app/models/user.rb
class User < ApplicationRecord
end
```

```irb
irb> User.create settings: "01010011"
irb> user = User.first
irb> user.settings
=> "01010011"
irb> user.settings = "0xAF"
irb> user.settings
=> "10101111"
irb> user.save!
```

### Tipo Endereço de Internet

* [definição de tipo](https://www.postgresql.org/docs/current/static/datatype-net-types.html)

Os tipos `inet` e `cidr`são transformados em objetos Ruby [`IPAddr`](https://ruby-doc.org/stdlib-2.7.0/libdoc/ipaddr/rdoc/IPAddr.html). O tipo `macaddr` é transformado em texto normal.

```ruby
# db/migrate/20140508144913_create_devices.rb
create_table(:devices, force: true) do |t|
  t.inet 'ip'
  t.cidr 'network'
  t.macaddr 'address'
end
```

```ruby
# app/models/device.rb
class Device < ApplicationRecord
end
```

```irb
irb> macbook = Device.create(ip: "192.168.1.12", network: "192.168.2.0/24", address: "32:01:16:6d:05:ef")

irb> macbook.ip
=> #<IPAddr: IPv4:192.168.1.12/255.255.255.255>

irb> macbook.network
=> #<IPAddr: IPv4:192.168.2.0/255.255.255.0>

irb> macbook.address
=> "32:01:16:6d:05:ef"
```

### Tipos Geométricos

* [definição de tipo](https://www.postgresql.org/docs/current/static/datatype-geometric.html)

Todos os tipos geométricos, com exceção de `points`, são mapeados para texto normal.
Um ponto é transformado em um *array* contendo as coordenadas `x` e `y`.

### Intervalo

* [definição de tipo](https://www.postgresql.org/docs/current/static/datatype-datetime.html#DATATYPE-INTERVAL-INPUT)
* [funções e operações](https://www.postgresql.org/docs/current/static/functions-datetime.html)

Esse tipo é mapeado em um objeto [`ActiveSupport::Duration`](https://api.rubyonrails.org/classes/ActiveSupport/Duration.html).

```ruby
# db/migrate/20200120000000_create_events.rb
create_table :events do |t|
  t.interval 'duration'
end
```

```ruby
# app/models/event.rb
class Event < ApplicationRecord
end
```

```irb
irb> Event.create(duration: 2.days)

irb> event = Event.first
irb> event.duration
=> 2 days
```

UUID Primary Keys
-----------------

NOTE: You need to enable the `pgcrypto` (only PostgreSQL >= 9.4) or `uuid-ossp`
extension to generate random UUIDs.

```ruby
# db/migrate/20131220144913_create_devices.rb
enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
create_table :devices, id: :uuid do |t|
  t.string :kind
end
```

```ruby
# app/models/device.rb
class Device < ApplicationRecord
end
```

```ruby
irb> device = Device.create
irb> device.id
=> "814865cd-5a1d-4771-9306-4268f188fe9e"
```

NOTE: `gen_random_uuid()` (from `pgcrypto`) is assumed if no `:default` option was
passed to `create_table`.

Generated Columns
-----------------

NOTE: Generated columns are supported since version 12.0 of PostgreSQL.

```ruby
# db/migrate/20131220144913_create_users.rb
create_table :users do |t|
  t.string :name
  t.virtual :name_upcased, type: :string, as: 'upper(name)', stored: true
end

# app/models/user.rb
class User < ApplicationRecord
end

# Usage
user = User.create(name: 'John')
User.last.name_upcased # => "JOHN"
```

Pesquisa de Texto Completo
----------------

```ruby
# db/migrate/20131220144913_create_documents.rb
create_table :documents do |t|
  t.string :title
  t.string :body
end

add_index :documents, "to_tsvector('english', title || ' ' || body)", using: :gin, name: 'documents_idx'
```

```ruby
# app/models/document.rb
class Document < ApplicationRecord
end
```

```ruby
# Utilização
Document.create(title: "Cats and Dogs", body: "are nice!")

## todos os documentos que correspondem a 'cat & dog'
Document.where("to_tsvector('english', title || ' ' || body) @@ to_tsquery(?)",
                 "cat & dog")
```

Opcionalmente, você pode armazenar o vetor como coluna gerada automaticamente (do PostgreSQL 12.0):

```ruby
# db/migrate/20131220144913_create_documents.rb
create_table :documents do |t|
  t.string :title
  t.string :body

  t.virtual :textsearchable_index_col,
            type: :tsvector, as: "to_tsvector('english', title || ' ' || body)", stored: true
end

add_index :documents, :textsearchable_index_col, using: :gin, name: 'documents_idx'

# Uso
Document.create(title: "Cats and Dogs", body: "are nice!")

## todos os documentos contendo 'cat & dog'
Document.where("textsearchable_index_col @@ to_tsquery(?)", "cat & dog")
```

Visão de Banco de Dados
--------------

* [criação da visão](https://www.postgresql.org/docs/current/static/sql-createview.html)

Imagine que você precisa trabalhar com um banco de dados legado contendo as seguintes tabelas:

```
rails_pg_guide=# \d "TBL_ART"
                                        Table "public.TBL_ART"
   Column   |            Type             |                         Modifiers
------------+-----------------------------+------------------------------------------------------------
 INT_ID     | integer                     | not null default nextval('"TBL_ART_INT_ID_seq"'::regclass)
 STR_TITLE  | character varying           |
 STR_STAT   | character varying           | default 'draft'::character varying
 DT_PUBL_AT | timestamp without time zone |
 BL_ARCH    | boolean                     | default false
Indexes:
    "TBL_ART_pkey" PRIMARY KEY, btree ("INT_ID")
```

Esta tabela certamente não segue as convenções do Rails.
Como as [visões](https://pt.wikipedia.org/wiki/Vis%C3%A3o_(banco_de_dados)) no PostgreSQL são atualizáveis por padrão,
nós podemos envolver isso da seguinte maneira:

```ruby
# db/migrate/20131220144913_create_articles_view.rb
execute <<-SQL
CREATE VIEW articles AS
  SELECT "INT_ID" AS id,
         "STR_TITLE" AS title,
         "STR_STAT" AS status,
         "DT_PUBL_AT" AS published_at,
         "BL_ARCH" AS archived
  FROM "TBL_ART"
  WHERE "BL_ARCH" = 'f'
  SQL
```

```ruby
# app/models/article.rb
class Article < ApplicationRecord
  self.primary_key = "id"
  def archive!
    update_attribute :archived, true
  end
end
```

```irb
irb> first = Article.create! title: "Winter is coming", status: "published", published_at: 1.year.ago
irb> second = Article.create! title: "Brace yourself", status: "draft", published_at: 1.month.ago

irb> Article.count
=> 2
irb> first.archive!
irb> Article.count
=> 1
```

NOTE: Esta aplicação só se importa com `Articles` não arquivados. Uma visão também
permite condições para que possamos excluir os `Articles` arquivados diretamente.

Structure Dumps
--------------

If your `config.active_record.schema_format` is `:sql`, Rails will call `pg_dump` to generate a
structure dump.

You can use `ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags` to configure `pg_dump`.
For example, to exclude comments from your structure dump, add this to an initializer:

```ruby
ActiveRecord::Tasks::DatabaseTasks.structure_dump_flags = ['--no-comments']
```
