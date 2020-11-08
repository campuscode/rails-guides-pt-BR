**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Action Cable Overview
=====================

Neste guia, você irá aprender como *Action Cable* funciona e como usar *WebSockets*
para incorporar funcionalidades de tempo real em sua aplicação Rails.

Ao ler este guia você aprenderá:

* O que é um *Action Cable* e sua integração *backend* e *frontend*
* Como configurar um *Action Cable*
* Como configurar canais
* Configuração de *Deployment* e Arquitetura para rodar a *Action Cable*

--------------------------------------------------------------------------------

Introdução
------------

O *Action Cable* integra-se perfeitamente [WebSockets](https://pt.wikipedia.org/wiki/WebSocket) com o resto da sua aplicação Rails. Permite que recursos em tempo real sejam escritos em Ruby no mesmo estilo e forma que o resto de sua aplicação Rails, ao mesmo tempo em que possui desempenho e escabilidade. Isso é uma oferta _full-stack_ que fornece um _framework_ Javascript do lado do cliente (_client-side_) e um _framework_ Ruby do lado do servidor (_server-side_). Você tem acesso ao seu _model_ de domínio completo escrito com o *Active Record* ou o ORM de sua escolha.

Terminology
-----------

A single Action Cable server can handle multiple connection instances. It has one
connection instance per WebSocket connection. A single user may have multiple
WebSockets open to your application if they use multiple browser tabs or devices.
The client of a WebSocket connection is called the consumer.

Each consumer can in turn subscribe to multiple cable channels. Each channel
encapsulates a logical unit of work, similar to what a controller does in
a regular MVC setup. For example, you could have a `ChatChannel` and
an `AppearancesChannel`, and a consumer could be subscribed to either
or to both of these channels. At the very least, a consumer should be subscribed
to one channel.

When the consumer is subscribed to a channel, they act as a subscriber.
The connection between the subscriber and the channel is, surprise-surprise,
called a subscription. A consumer can act as a subscriber to a given channel
any number of times. For example, a consumer could subscribe to multiple chat rooms
at the same time. (And remember that a physical user may have multiple consumers,
one per tab/device open to your connection).

Each channel can then again be streaming zero or more broadcastings.
A broadcasting is a pubsub link where anything transmitted by the broadcaster is
sent directly to the channel subscribers who are streaming that named broadcasting.

As you can see, this is a fairly deep architectural stack. There's a lot of new
terminology to identify the new pieces, and on top of that, you're dealing
with both client and server side reflections of each unit.

O que é _Pub/Sub_
---------------

_[Pub/Sub](https://en.wikipedia.org/wiki/Publish%E2%80%93subscribe_pattern)_, ou
_Publish-Subscribe_, refere-se a um paradigma de fila de mensageria o qual os
remetentes de uma informação (_publishers_) enviam dados à uma classe abstrata de
destinatários (_subscribers_) sem especificar um destinatário individual.
*Action Cable* utiliza essa abordagem para manter a comunicação entre o servidor
e diversos clientes.

## Componentes _Server-Side_

### *Connections*

*Connections* formam a fundação do relacionamento de cliente-servidor. Para cada
_WebSocket_ aceito pelo servidor, um objeto *connection* é instanciado. Esse objeto
se torna o pai de todos os *channel subscriptions* que são criados dali pra frente.
A *connection* em si não lida com nenhuma lógica específica da aplicação além da
autenticação e autorização. O cliente de um _WebSocket *connection*_ é chamado de
*consumer*. Um usuário individual criará um par de *consumer-connection* para cada
aba do navegador, janela ou dispositivo que ele tiver aberto.

*Connections* são instâncias de `ApplicationCable::Connection`. Nessa classe,
você autoriza a *connection* recebida e procede para estabelecê-la, caso o
usuário possa ser identificado.

#### Configuração de uma *Connection*

```ruby
# app/channels/application_cable/connection.rb
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private
      def find_verified_user
        if verified_user = User.find_by(id: cookies.encrypted[:user_id])
          verified_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
```

Aqui, `identified_by` é um identificador de *connection* que pode ser usado para
encontrar uma *connection* específica mais tarde. Note que qualquer coisa marcada
como um identificador criará automaticamente um *delegate* pelo mesmo nome em
qualquer instância de *channel* criada a partir da *connection*.

Esse exemplo se baseia no fato de que você já lidou a autenticação do usuário em
algum outro lugar na sua aplicação e essa autenticação bem sucedida definiu um
*cookie* assinado com o ID do usuário.

O *cookie* é então enviado automaticamente para a instância da *connection* quando há
a tentativa de criar uma nova *connection*, e você o usa para definir o `current_user`.
Ao identificar a *connection* para o mesmo usuário, você também garante que você pode retornar todas as *connections* em aberto para um usuário específico (e potencialmente desconectá-los, caso o usuário seja deletado ou desautorizado).

### *Channels*

O *channel* encapsula uma unidade lógica de trabalho, parecido com o que um
*controller* faz em um *MVC* comum. Por padrão, o *Rails* cria uma classe pai
`ApplicationCable::Channel` para encapsular a lógica compartilhada entre seus
*channels*.

#### Configuração do *Channel* pai

```ruby
# app/channels/application_cable/channel.rb
module ApplicationCable
  class Channel < ActionCable::Channel::Base
  end
end
```

Então, você criaria suas próprias classes de *channel*. Por exemplo, você poderia ter um
`ChatChannel` e um `AppearanceChannel`:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
end

# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
end
```

Um *consumer* poderia então ser inscrito para qualquer ou ambos os *channels*.

#### *Subscriptions*

*Consumers* se inscrevem a *channels*, agindo como *subscribers*. A *connection*
deles é chamada de *subscription*. Mensagens produzidas são então roteadas para esses
*channel subscriptions* baseados em um identificador enviado pelo *cable consumer*.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  # Chamado quando o *consumer* tornou-se um *subscriber*
  # desse *channel* com sucesso.
  def subscribed
  end
end
```

## Componentes _Client-Side_

### Conexões

Consumidores precisam de uma instância da conexão do seu lado. Esta conexão pode
ser estabelecida usando o seguinte JavaScript, que é gerado por padrão pelo
Rails:

#### Conectar o Consumidor

```js
// app/javascript/channels/consumer.js
// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `rails generate channel` command.

import { createConsumer } from "@rails/actioncable"

export default createConsumer()
```

Isto vai preparar um consumidor que conectará em `/cable` em seu servidor por
padrão. A conexão não vai ser estabelecida até que você também tenha
especificado ao menos uma inscrição que você tem interesse em ter.

O consumidor pode optar receber um argumento que especifica a _URL_ para se
conectar. Ela pode ser uma _string_, ou uma função que retorna uma _string_ que
vai ser chamada quando o _WebSocket_ é aberto.

```js
// Especifica uma _URL_ diferente para se conectar
createConsumer('https://ws.example.com/cable')

// Utiliza uma função para gerar a _URL_ dinamicamente
createConsumer(getWebSocketURL)

function getWebSocketURL {
  const token = localStorage.get('auth-token')
  return `https://ws.example.com/cable?token=${token}`
}
```

#### Assinante

Um consumidor se torna um assinante criando uma assinatura para um canal:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" })

// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "AppearanceChannel" })
```

Enquanto isto cria uma assinatura, a funcionalidade necessária para responder
aos dados recebidos será descrita mais tarde.

Um consumidor pode agir como um assinante para um dado canal qualquer número de
vezes. Por exemplo, um consumidor pode assinar várias salas de _chat_ ao mesmo
tempo.

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "1st Room" })
consumer.subscriptions.create({ channel: "ChatChannel", room: "2nd Room" })
```

## Client-Server Interactions

### Streams

*Streams* provide the mechanism by which channels route published content
(broadcasts) to their subscribers.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

If you have a stream that is related to a model, then the broadcasting used
can be generated from the model and channel. The following example would
subscribe to a broadcasting like `comments:Z2lkOi8vVGVzdEFwcC9Qb3N0LzE`

```ruby
class CommentsChannel < ApplicationCable::Channel
  def subscribed
    post = Post.find(params[:id])
    stream_for post
  end
end
```

You can then broadcast to this channel like this:

```ruby
CommentsChannel.broadcast_to(@post, @comment)
```

### Broadcasting

A *broadcasting* is a pub/sub link where anything transmitted by a publisher
is routed directly to the channel subscribers who are streaming that named
broadcasting. Each channel can be streaming zero or more broadcastings.

Broadcastings are purely an online queue and time-dependent. If a consumer is
not streaming (subscribed to a given channel), they'll not get the broadcast
should they connect later.

Broadcasts are called elsewhere in your Rails application:

```ruby
WebNotificationsChannel.broadcast_to(
  current_user,
  title: 'New things!',
  body: 'All the news fit to print'
)
```

The `WebNotificationsChannel.broadcast_to` call places a message in the current
subscription adapter's pubsub queue under a separate broadcasting name for each user.
The default pubsub queue for Action Cable is `redis` in production and `async` in development and
test environments. For a user with an ID of 1, the broadcasting name would be `web_notifications:1`.

The channel has been instructed to stream everything that arrives at
`web_notifications:1` directly to the client by invoking the `received`
callback.

### Subscriptions

When a consumer is subscribed to a channel, they act as a subscriber. This
connection is called a subscription. Incoming messages are then routed to
these channel subscriptions based on an identifier sent by the cable consumer.

```js
// app/javascript/channels/chat_channel.js
// Assumes you've already requested the right to send web notifications
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("[data-chat-room='Best Room']")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article class="chat-line">
        <span class="speaker">${data["sent_by"]}</span>
        <span class="body">${data["body"]}</span>
      </article>
    `
  }
})
```

### Passing Parameters to Channels

You can pass parameters from the client side to the server side when creating a
subscription. For example:

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end
end
```

An object passed as the first argument to `subscriptions.create` becomes the
params hash in the cable channel. The keyword `channel` is required:

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("[data-chat-room='Best Room']")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article class="chat-line">
        <span class="speaker">${data["sent_by"]}</span>
        <span class="body">${data["body"]}</span>
      </article>
    `
  }
})
```

```ruby
# Somewhere in your app this is called, perhaps
# from a NewCommentJob.
ActionCable.server.broadcast(
  "chat_#{room}",
  sent_by: 'Paul',
  body: 'This is a cool chat app.'
)
```

### Rebroadcasting a Message

A common use case is to *rebroadcast* a message sent by one client to any
other connected clients.

```ruby
# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:room]}"
  end

  def receive(data)
    ActionCable.server.broadcast("chat_#{params[:room]}", data)
  end
end
```

```js
// app/javascript/channels/chat_channel.js
import consumer from "./consumer"

const chatChannel = consumer.subscriptions.create({ channel: "ChatChannel", room: "Best Room" }, {
  received(data) {
    // data => { sent_by: "Paul", body: "This is a cool chat app." }
  }
}

chatChannel.send({ sent_by: "Paul", body: "This is a cool chat app." })
```

The rebroadcast will be received by all connected clients, _including_ the
client that sent the message. Note that params are the same as they were when
you subscribed to the channel.

## Full-Stack Examples

The following setup steps are common to both examples:

  1. [Setup your connection](#connection-setup).
  2. [Setup your parent channel](#parent-channel-setup).
  3. [Connect your consumer](#connect-consumer).

### Example 1: User Appearances

Here's a simple example of a channel that tracks whether a user is online or not
and what page they're on. (This is useful for creating presence features like showing
a green dot next to a user name if they're online).

Create the server-side appearance channel:

```ruby
# app/channels/appearance_channel.rb
class AppearanceChannel < ApplicationCable::Channel
  def subscribed
    current_user.appear
  end

  def unsubscribed
    current_user.disappear
  end

  def appear(data)
    current_user.appear(on: data['appearing_on'])
  end

  def away
    current_user.away
  end
end
```

When a subscription is initiated the `subscribed` callback gets fired and we
take that opportunity to say "the current user has indeed appeared". That
appear/disappear API could be backed by Redis, a database, or whatever else.

Create the client-side appearance channel subscription:

```js
// app/javascript/channels/appearance_channel.js
import consumer from "./consumer"

consumer.subscriptions.create("AppearanceChannel", {
  // Called once when the subscription is created.
  initialized() {
    this.update = this.update.bind(this)
  },

  // Called when the subscription is ready for use on the server.
  connected() {
    this.install()
    this.update()
  },

  // Called when the WebSocket connection is closed.
  disconnected() {
    this.uninstall()
  },

  // Called when the subscription is rejected by the server.
  rejected() {
    this.uninstall()
  },

  update() {
    this.documentIsActive ? this.appear() : this.away()
  },

  appear() {
    // Calls `AppearanceChannel#appear(data)` on the server.
    this.perform("appear", { appearing_on: this.appearingOn })
  },

  away() {
    // Calls `AppearanceChannel#away` on the server.
    this.perform("away")
  },

  install() {
    window.addEventListener("focus", this.update)
    window.addEventListener("blur", this.update)
    document.addEventListener("turbolinks:load", this.update)
    document.addEventListener("visibilitychange", this.update)
  },

  uninstall() {
    window.removeEventListener("focus", this.update)
    window.removeEventListener("blur", this.update)
    document.removeEventListener("turbolinks:load", this.update)
    document.removeEventListener("visibilitychange", this.update)
  },

  get documentIsActive() {
    return document.visibilityState == "visible" && document.hasFocus()
  },

  get appearingOn() {
    const element = document.querySelector("[data-appearing-on]")
    return element ? element.getAttribute("data-appearing-on") : null
  }
})
```

##### Client-Server Interaction

1. **Client** connects to the **Server** via `App.cable =
ActionCable.createConsumer("ws://cable.example.com")`. (`cable.js`). The
**Server** identifies this connection by `current_user`.

2. **Client** subscribes to the appearance channel via
`consumer.subscriptions.create({ channel: "AppearanceChannel" })`. (`appearance_channel.js`)

3. **Server** recognizes a new subscription has been initiated for the
appearance channel and runs its `subscribed` callback, calling the `appear`
method on `current_user`. (`appearance_channel.rb`)

4. **Client** recognizes that a subscription has been established and calls
`connected` (`appearance_channel.js`) which in turn calls `install` and `appear`.
`appear` calls `AppearanceChannel#appear(data)` on the server, and supplies a
data hash of `{ appearing_on: this.appearingOn }`. This is
possible because the server-side channel instance automatically exposes all
public methods declared on the class (minus the callbacks), so that these can be
reached as remote procedure calls via a subscription's `perform` method.

5. **Server** receives the request for the `appear` action on the appearance
channel for the connection identified by `current_user`
(`appearance_channel.rb`). **Server** retrieves the data with the
`:appearing_on` key from the data hash and sets it as the value for the `:on`
key being passed to `current_user.appear`.

### Example 2: Receiving New Web Notifications

The appearance example was all about exposing server functionality to
client-side invocation over the WebSocket connection. But the great thing
about WebSockets is that it's a two-way street. So now let's show an example
where the server invokes an action on the client.

This is a web notification channel that allows you to trigger client-side
web notifications when you broadcast to the right streams:

Create the server-side web notifications channel:

```ruby
# app/channels/web_notifications_channel.rb
class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end
end
```

Create the client-side web notifications channel subscription:

```js
// app/javascript/channels/web_notifications_channel.js
// Client-side which assumes you've already requested
// the right to send web notifications.
import consumer from "./consumer"

consumer.subscriptions.create("WebNotificationsChannel", {
  received(data) {
    new Notification(data["title"], body: data["body"])
  }
})
```

Broadcast content to a web notification channel instance from elsewhere in your
application:

```ruby
# Somewhere in your app this is called, perhaps from a NewCommentJob
WebNotificationsChannel.broadcast_to(
  current_user,
  title: 'New things!',
  body: 'All the news fit to print'
)
```

The `WebNotificationsChannel.broadcast_to` call places a message in the current
subscription adapter's pubsub queue under a separate broadcasting name for each
user. For a user with an ID of 1, the broadcasting name would be
`web_notifications:1`.

The channel has been instructed to stream everything that arrives at
`web_notifications:1` directly to the client by invoking the `received`
callback. The data passed as argument is the hash sent as the second parameter
to the server-side broadcast call, JSON encoded for the trip across the wire
and unpacked for the data argument arriving as `received`.

### More Complete Examples

See the [rails/actioncable-examples](https://github.com/rails/actioncable-examples)
repository for a full example of how to setup Action Cable in a Rails app and adding channels.

## Configuration

Action Cable has two required configurations: a subscription adapter and allowed request origins.

### Subscription Adapter

By default, Action Cable looks for a configuration file in `config/cable.yml`.
The file must specify an adapter for each Rails environment. See the
[Dependencies](#dependencies) section for additional information on adapters.

```yaml
development:
  adapter: async

test:
  adapter: async

production:
  adapter: redis
  url: redis://10.10.3.153:6381
  channel_prefix: appname_production
```
#### Adapter Configuration

Below is a list of the subscription adapters available for end users.

##### Async Adapter

The async adapter is intended for development/testing and should not be used in production.

##### Redis Adapter

The Redis adapter requires users to provide a URL pointing to the Redis server.
Additionally, a `channel_prefix` may be provided to avoid channel name collisions
when using the same Redis server for multiple applications. See the [Redis PubSub documentation](https://redis.io/topics/pubsub#database-amp-scoping) for more details.

##### PostgreSQL Adapter

The PostgreSQL adapter uses Active Record's connection pool, and thus the
application's `config/database.yml` database configuration, for its connection.
This may change in the future. [#27214](https://github.com/rails/rails/issues/27214)

### Allowed Request Origins

Action Cable will only accept requests from specified origins, which are
passed to the server config as an array. The origins can be instances of
strings or regular expressions, against which a check for the match will be performed.

```ruby
config.action_cable.allowed_request_origins = ['https://rubyonrails.com', %r{http://ruby.*}]
```

To disable and allow requests from any origin:

```ruby
config.action_cable.disable_request_forgery_protection = true
```

By default, Action Cable allows all requests from localhost:3000 when running
in the development environment.

### Consumer Configuration

To configure the URL, add a call to `action_cable_meta_tag` in your HTML layout
HEAD. This uses a URL or path typically set via `config.action_cable.url` in the
environment configuration files.

### Worker Pool Configuration

The worker pool is used to run connection callbacks and channel actions in
isolation from the server's main thread. Action Cable allows the application
to configure the number of simultaneously processed threads in the worker pool.

```ruby
config.action_cable.worker_pool_size = 4
```

Also, note that your server must provide at least the same number of database
connections as you have workers. The default worker pool size is set to 4, so
that means you have to make at least 4 database connections available.
 You can change that in `config/database.yml` through the `pool` attribute.

### Other Configurations

The other common option to configure is the log tags applied to the
per-connection logger. Here's an example that uses
the user account id if available, else "no-account" while tagging:

```ruby
config.action_cable.log_tags = [
  -> request { request.env['user_account_id'] || "no-account" },
  :action_cable,
  -> request { request.uuid }
]
```

For a full list of all configuration options, see the
`ActionCable::Server::Configuration` class.

## Running Standalone Cable Servers

### In App

Action Cable can run alongside your Rails application. For example, to
listen for WebSocket requests on `/websocket`, specify that path to
`config.action_cable.mount_path`:

```ruby
# config/application.rb
class Application < Rails::Application
  config.action_cable.mount_path = '/websocket'
end
```

You can use `ActionCable.createConsumer()` to connect to the cable
server if `action_cable_meta_tag` is invoked in the layout. Otherwise, A path is
specified as first argument to `createConsumer` (e.g. `ActionCable.createConsumer("/websocket")`).

For every instance of your server you create and for every worker your server
spawns, you will also have a new instance of Action Cable, but the use of Redis
keeps messages synced across connections.

### Standalone

The cable servers can be separated from your normal application server. It's
still a Rack application, but it is its own Rack application. The recommended
basic setup is as follows:

```ruby
# cable/config.ru
require_relative '../config/environment'
Rails.application.eager_load!

run ActionCable.server
```

Then you start the server using a binstub in `bin/cable` ala:

```
#!/bin/bash
bundle exec puma -p 28080 cable/config.ru
```

The above will start a cable server on port 28080.

### Notes

The WebSocket server doesn't have access to the session, but it has
access to the cookies. This can be used when you need to handle
authentication. You can see one way of doing that with Devise in this [article](https://greg.molnar.io/blog/actioncable-devise-authentication/).

## Dependências

O _Action Cable_ fornece uma interface de adaptador de assinatura para processar seus
_pubsub_ internos. Por padrão, adaptadores assíncronos, _inline_, PostgreSQL e Redis
estão incluídos. O adaptador padrão
em novas aplicações Rails é o adaptador assíncrono (`async`).

O lado Ruby das coisas é construído em cima de [websocket-driver](https://github.com/faye/websocket-driver-ruby),
[nio4r](https://github.com/celluloid/nio4r) e [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby).

## Implantação

O _Action Cable_ é alimentado por uma combinação de _WebSockets_ e _threads_. Tanto o
[_plumbing_](https://www.techopedia.com/definition/31509/plumbing) do _framework_ e o trabalho do _channel_ especificado pelo usuário são tratados internamente,
usando suporte de _thread_ nativo do Ruby. Isso significa que você pode usar todos os seus
*models* dos Rails sem problemas, contanto que você não tenha cometido nenhum pecado de _thread-safety_.

O servidor _Action Cable_ implementa o _Rack socket hijacking API_,
permitindo assim o uso de um padrão _multithread_ para o gerenciamento de conexões
internamente, independentemente de o servidor de aplicativos ser multiencadeado ou não.

Assim, _Action Cable_ funciona com servidores populares como _Unicorn_, _Puma_ e
_Passenger_.

## Teste

Você pode encontrar instruções detalhadas de como testar a sua funcionalidade *Action Cable* no
[guia de teste](testing.html#testing-action-cable).
