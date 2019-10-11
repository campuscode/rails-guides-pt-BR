**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**

*Debug* de Aplicações Rails
============================

Esse guia introduz técnicas de *debug* para aplicações de Ruby on Rails

Após ler esse guia, você saberá:

* O propósito de das técnicas de *debug*
* Como encontrar problemas nas suas aplicações que testes não estão identificando
* As diferentes maneiras de depurar o seu código
* Como analisar a *stack trace*

--------------------------------------------------------------------------------

*View Helpers* para *Debugging*
--------------------------

Uma tarefa comum é inspecionar o conteúdo de uma variável. O Rails fornece três diferentes formas para fazer isso:

* `debug`
* `to_yaml`
* `inspect`

### `debug`

O *helper* `debug` irá retornar uma tag \<pre> que renderiza um objeto usando o formato YAML. Isso vai gerar um dado legível para humanos a partir de qualquer objeto. Por exemplo, se você tem esse código em uma *view*: 

```html+erb
<%= debug @article %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

Você verá algo parecido com isso:

```yaml
--- !ruby/object Article
attributes:
  updated_at: 2008-09-05 22:55:47
  body: Esse é um guia muito útil para fazer o debugging da sua app Rails.
  title: Guia de debugging do Rails
  published: t
  id: "1"
  created_at: 2008-09-05 22:55:47
attributes_cache: {}


Title: Guia de *debugging* do Rails
```

### `to_yaml`

Como alternativa, chamar `to_yaml` em qualquer objeto o converte para YAML. Você pode passar esse objeto convertido para o método *helper* `simple_format` para formatar o *output*. É assim que o `debug` faz sua mágica. 

```html+erb
<%= simple_format @article.to_yaml %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

O código acima vai renderizar algo como isso:

```yaml
--- !ruby/object Article
attributes:
updated_at: 2008-09-05 22:55:47
body: Esse é um guia muito útil para fazer o debugging de sua app Rails.
title: Guia de debugging do Rails
published: t
id: "1"
created_at: 2008-09-05 22:55:47
attributes_cache: {}

Title: Guia de *debugging* do Rails
```

### `inspect`

Outro método útil para mostrar valores de objeto é o `inspect`, especialmente quando estamos trabalhando com arrays ou hashes. Isso imprimirá o valor do objeto como uma string. Por exemplo:

```html+erb
<%= [1, 2, 3, 4, 5].inspect %>
<p>
  <b>Title:</b>
  <%= @article.title %>
</p>
```

Vai renderizar: 

```
[1, 2, 3, 4, 5]

Title: Guia de *debugging* do Rails
```


O *Logger*
----------

Pode ser útil salvar informações em um arquivo de log em tempo de execução. O Rails mantém um arquivo de log separado para cada ambiente de execução.

### O que é o *Logger*?

O Rails utiliza a classe `ActiveSupport::Logger` para guardar informações de log. Outros tipos de loggers, como o `Log4r`, também podem ser utilizados.

Você pode especificar um *logger* alternativo em `config/application.rb` ou em qualquer outro arquivo de ambiente, por exemplo: 

```ruby
config.logger = Logger.new(STDOUT)
config.logger = Log4r::Logger.new("Application Log")
```

Ou na seção `Initializer`, adicione _qualquer_ um dos seguintes: 

```ruby
Rails.logger = Logger.new(STDOUT)
Rails.logger = Log4r::Logger.new("Application Log")
```

DICA: Por padrão, cada log é criado em `Rails.root/log/` e o arquivo de log é criado com o nome do ambiente no qual a aplicação está sendo executada.

### Log Levels

When something is logged, it's printed into the corresponding log if the log
level of the message is equal to or higher than the configured log level. If you
want to know the current log level, you can call the `Rails.logger.level`
method.

The available log levels are: `:debug`, `:info`, `:warn`, `:error`, `:fatal`,
and `:unknown`, corresponding to the log level numbers from 0 up to 5,
respectively. To change the default log level, use

```ruby
config.log_level = :warn # In any environment initializer, or
Rails.logger.level = 0 # at any time
```

This is useful when you want to log under development or staging without flooding your production log with unnecessary information.

TIP: The default Rails log level is `debug` in all environments.

### Sending Messages

To write in the current log use the `logger.(debug|info|warn|error|fatal|unknown)` method from within a controller, model, or mailer:

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
logger.info "Processing the request..."
logger.fatal "Terminating application, raised unrecoverable error!!!"
```

Here's an example of a method instrumented with extra logging:

```ruby
class ArticlesController < ApplicationController
  # ...

  def create
    @article = Article.new(article_params)
    logger.debug "New article: #{@article.attributes.inspect}"
    logger.debug "Article should be valid: #{@article.valid?}"

    if @article.save
      logger.debug "The article was saved and now the user is going to be redirected..."
      redirect_to @article, notice: 'Article was successfully created.'
    else
      render :new
    end
  end

  # ...

  private
    def article_params
      params.require(:article).permit(:title, :body, :published)
    end
end
```

Here's an example of the log generated when this controller action is executed:

```
Started POST "/articles" for 127.0.0.1 at 2018-10-18 20:09:23 -0400
Processing by ArticlesController#create as HTML
  Parameters: {"utf8"=>"✓", "authenticity_token"=>"XLveDrKzF1SwaiNRPTaMtkrsTzedtebPPkmxEFIU0ordLjICSnXsSNfrdMa4ccyBjuGwnnEiQhEoMN6H1Gtz3A==", "article"=>{"title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs.", "published"=>"0"}, "commit"=>"Create Article"}
New article: {"id"=>nil, "title"=>"Debugging Rails", "body"=>"I'm learning how to print in logs.", "published"=>false, "created_at"=>nil, "updated_at"=>nil}
Article should be valid: true
   (0.0ms)  begin transaction
  ↳ app/controllers/articles_controller.rb:31
  Article Create (0.5ms)  INSERT INTO "articles" ("title", "body", "published", "created_at", "updated_at") VALUES (?, ?, ?, ?, ?)  [["title", "Debugging Rails"], ["body", "I'm learning how to print in logs."], ["published", 0], ["created_at", "2018-10-19 00:09:23.216549"], ["updated_at", "2018-10-19 00:09:23.216549"]]
  ↳ app/controllers/articles_controller.rb:31
   (2.3ms)  commit transaction
  ↳ app/controllers/articles_controller.rb:31
The article was saved and now the user is going to be redirected...
Redirected to http://localhost:3000/articles/1
Completed 302 Found in 4ms (ActiveRecord: 0.8ms)
```

Adding extra logging like this makes it easy to search for unexpected or unusual behavior in your logs. If you add extra logging, be sure to make sensible use of log levels to avoid filling your production logs with useless trivia.

### Verbose Query Logs

When looking at database query output in logs, it may not be immediately clear why multiple database queries are triggered when a single method is called:

```
irb(main):001:0> Article.pamplemousse
  Article Load (0.4ms)  SELECT "articles".* FROM "articles"
  Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```

After running `ActiveRecord::Base.verbose_query_logs = true` in the `rails console` session to enable verbose query logs and running the method again, it becomes obvious what single line of code is generating all these discrete database calls:

```
irb(main):003:0> Article.pamplemousse
  Article Load (0.2ms)  SELECT "articles".* FROM "articles"
  ↳ app/models/article.rb:5
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  ↳ app/models/article.rb:6
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  ↳ app/models/article.rb:6
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
  ↳ app/models/article.rb:6
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```

Below each database statement you can see arrows pointing to the specific source filename (and line number) of the method that resulted in a database call. This can help you identify and address performance problems caused by N+1 queries: single database queries that generates multiple additional queries.

Verbose query logs are enabled by default in the development environment logs after Rails 5.2.

WARNING: We recommend against using this setting in production environments. It relies on Ruby's `Kernel#caller` method which tends to allocate a lot of memory in order to generate stacktraces of method calls.

### Tagged Logging

When running multi-user, multi-account applications, it's often useful
to be able to filter the logs using some custom rules. `TaggedLogging`
in Active Support helps you do exactly that by stamping log lines with subdomains, request ids, and anything else to aid debugging such applications.

```ruby
logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
logger.tagged("BCX") { logger.info "Stuff" }                            # Logs "[BCX] Stuff"
logger.tagged("BCX", "Jason") { logger.info "Stuff" }                   # Logs "[BCX] [Jason] Stuff"
logger.tagged("BCX") { logger.tagged("Jason") { logger.info "Stuff" } } # Logs "[BCX] [Jason] Stuff"
```

### Impact of Logs on Performance
Logging will always have a small impact on the performance of your Rails app,
        particularly when logging to disk. Additionally, there are a few subtleties:

Using the `:debug` level will have a greater performance penalty than `:fatal`,
      as a far greater number of strings are being evaluated and written to the
      log output (e.g. disk).

Another potential pitfall is too many calls to `Logger` in your code:

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
```

In the above example, there will be a performance impact even if the allowed
output level doesn't include debug. The reason is that Ruby has to evaluate
these strings, which includes instantiating the somewhat heavy `String` object
and interpolating the variables.
Therefore, it's recommended to pass blocks to the logger methods, as these are
only evaluated if the output level is the same as — or included in — the allowed level
(i.e. lazy loading). The same code rewritten would be:

```ruby
logger.debug {"Person attributes hash: #{@person.attributes.inspect}"}
```

The contents of the block, and therefore the string interpolation, are only
evaluated if debug is enabled. This performance savings are only really
noticeable with large amounts of logging, but it's a good practice to employ.

Debugging com a gem `byebug`
---------------------------------

Quando seu código está se comportando de maneiras inesperadas, você pode tentar imprimir em *logs* ou
no console para diagnosticar o problema. Infelizmente, há momentos em que esse
tipo de rastreamento de erros não é eficaz para encontrar a raiz de um problema.
Quando você realmente precisa acessar seu código-fonte em execução, o *debugger*
é o seu melhor companheiro.

O *debugger* também pode ajudá-lo se você quiser aprender sobre o código-fonte do Rails,
mas não sabe por onde começar. Basta fazer o *debugging* de qualquer requisição da sua aplicação e
usar este guia para aprender como passar do código que você escreveu para o código Rails subjacente.

### Instalação

Você pode usar a gem `byebug` para definir pontos de interrupção e percorrer o código em execução no
Rails. Para instalá-lo, basta executar:

```bash
$ gem install byebug
```

Dentro de qualquer aplicação Rails, você pode invocar o *debugger* chamando o
método `byebug`.

Aqui está um exemplo:

```ruby
class PeopleController < ApplicationController
  def new
    byebug
    @person = Person.new
  end
end
```

### O Shell

Assim que sua aplicação chamar o método `byebug`, o *debugger* será
iniciado em um *debugger shell* do seu terminal onde você iniciou seu
servidor da aplicação, e você será colocado no prompt do *debugger* `(byebug)`.
Antes do prompt, o código ao redor da linha que está prestes a ser executada será
exibido e a linha atual será marcada por '=>', assim:

```
[1, 10] in /PathTo/project/app/controllers/articles_controller.rb
    3:
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     byebug
=>  8:     @articles = Article.find_recent
    9:
   10:     respond_to do |format|
   11:       format.html # index.html.erb
   12:       format.json { render json: @articles }

(byebug)
```

Se você chegou ali por uma requisição do navegador, a aba do navegador que contém a requisição
ficará suspensa até que o *debugger* termine e que o rastreio tenha terminado
o processamento da requisição inteira.

Por exemplo:

```bash
=> Booting Puma
=> Rails 5.1.0 application starting in development on http://0.0.0.0:3000
=> Run `rails server -h` for more startup options
Puma starting in single mode...
* Version 3.4.0 (ruby 2.3.1-p112), codename: Owl Bowl Brawl
* Min threads: 5, max threads: 5
* Environment: development
* Listening on tcp://localhost:3000
Use Ctrl-C to stop
Started GET "/" for 127.0.0.1 at 2014-04-11 13:11:48 +0200
  ActiveRecord::SchemaMigration Load (0.2ms)  SELECT "schema_migrations".* FROM "schema_migrations"
Processing by ArticlesController#index as HTML

[3, 12] in /PathTo/project/app/controllers/articles_controller.rb
    3:
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     byebug
=>  8:     @articles = Article.find_recent
    9:
   10:     respond_to do |format|
   11:       format.html # index.html.erb
   12:       format.json { render json: @articles }
(byebug)
```

Agora é hora de explorar sua aplicação. Um bom lugar para começar é
pedindo ajuda ao *debugger*. Digite: `help`

```
(byebug) help

  break      -- Sets breakpoints in the source code
  catch      -- Handles exception catchpoints
  condition  -- Sets conditions on breakpoints
  continue   -- Runs until program ends, hits a breakpoint or reaches a line
  debug      -- Spawns a subdebugger
  delete     -- Deletes breakpoints
  disable    -- Disables breakpoints or displays
  display    -- Evaluates expressions every time the debugger stops
  down       -- Moves to a lower frame in the stack trace
  edit       -- Edits source files
  enable     -- Enables breakpoints or displays
  finish     -- Runs the program until frame returns
  frame      -- Moves to a frame in the call stack
  help       -- Helps you using byebug
  history    -- Shows byebug's history of commands
  info       -- Shows several informations about the program being debugged
  interrupt  -- Interrupts the program
  irb        -- Starts an IRB session
  kill       -- Sends a signal to the current process
  list       -- Lists lines of source code
  method     -- Shows methods of an object, class or module
  next       -- Runs one or more lines of code
  pry        -- Starts a Pry session
  quit       -- Exits byebug
  restart    -- Restarts the debugged program
  save       -- Saves current byebug session to a file
  set        -- Modifies byebug settings
  show       -- Shows byebug settings
  source     -- Restores a previously saved byebug session
  step       -- Steps into blocks or methods one or more times
  thread     -- Commands to manipulate threads
  tracevar   -- Enables tracing of a global variable
  undisplay  -- Stops displaying all or some expressions when program stops
  untracevar -- Stops tracing a global variable
  up         -- Moves to a higher frame in the stack trace
  var        -- Shows variables and its values
  where      -- Displays the backtrace

(byebug)
```

Para ver as dez linhas anteriores, você deve digitar `list-` (ou `l-`).

```
(byebug) l-

[1, 10] in /PathTo/project/app/controllers/articles_controller.rb
   1  class ArticlesController < ApplicationController
   2    before_action :set_article, only: [:show, :edit, :update, :destroy]
   3
   4    # GET /articles
   5    # GET /articles.json
   6    def index
   7      byebug
   8      @articles = Article.find_recent
   9
   10     respond_to do |format|
```

Dessa forma, você pode mover-se dentro do arquivo e ver o código acima da linha em que
adicionou a chamada `byebug`. Finalmente, para ver onde você está no código novamente, você pode
digitar `list=`

```
(byebug) list=

[3, 12] in /PathTo/project/app/controllers/articles_controller.rb
    3:
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     byebug
=>  8:     @articles = Article.find_recent
    9:
   10:     respond_to do |format|
   11:       format.html # index.html.erb
   12:       format.json { render json: @articles }
(byebug)
```

### O Contexto

Quando você inicia o *debugging* da sua aplicação, você será colocado em diferentes
contextos conforme você percorre as diferentes partes da *stack*.

O *debugger* cria um contexto quando um ponto de parada ou um evento é alcançado. O
contexto contém informações sobre o programa suspenso, o que habilita o *debugger*
para inspecionar os *frames* da *stack*, avaliar variáveis da perspectiva do
programa depurado e saiba o local em que programa depurado está parado.

A qualquer momento, você pode chamar o comando `backtrace` (ou seu *alias* `where`) para exibir
o *backtrace* da aplicação. Isso pode ser muito muito útil para saber como você
chegou aonde está. Se você já se perguntou como chegou a algum lugar no seu código,
o `backtrace` fornecerá a resposta.

```
(byebug) where
--> #0  ArticlesController.index
      at /PathToProject/app/controllers/articles_controller.rb:8
    #1  ActionController::BasicImplicitRender.send_action(method#String, *args#Array)
      at /PathToGems/actionpack-5.1.0/lib/action_controller/metal/basic_implicit_render.rb:4
    #2  AbstractController::Base.process_action(action#NilClass, *args#Array)
      at /PathToGems/actionpack-5.1.0/lib/abstract_controller/base.rb:181
    #3  ActionController::Rendering.process_action(action, *args)
      at /PathToGems/actionpack-5.1.0/lib/action_controller/metal/rendering.rb:30
...
```

O *frame* atual é marcado com `-->`. Você pode se mover para qualquer lugar que desejar nesse
*trace* (mudando assim o contexto) usando o comando `frame n`, em que _n_ é
o número do *frame* especificado. Se você fizer isso, o `byebug` exibirá seu novo
contexto.

```
(byebug) frame 2

[176, 185] in /PathToGems/actionpack-5.1.0/lib/abstract_controller/base.rb
   176:       # is the intended way to override action dispatching.
   177:       #
   178:       # Notice that the first argument is the method to be dispatched
   179:       # which is *not* necessarily the same as the action name.
   180:       def process_action(method_name, *args)
=> 181:         send_action(method_name, *args)
   182:       end
   183:
   184:       # Actually call the method associated with the action. Override
   185:       # this method if you wish to change how action methods are called,
(byebug)
```

As variáveis disponíveis são as mesmas que se você estivesse executando o código linha por
linha.  Afinal, é isso que é o *debugging*.

Você também pode usar os comandos `up [n]` e `down [n]` para alterar o contexto
_n_ *frames* acima ou abaixo da *stack*, respectivamente. _n_ assume como padrão o número um. Acima nesse
caso, é para *stack frames* com números mais altos, e abaixo é para *stack frames*
com números mais baixos.

### Threads

O *debugger* pode listar, parar, continuar e alternar entre threads em execução usando
o comando `thread` (ou o abreviado `th`). Esse comando possui várias opções:

* `thread`: mostra a thread atual.
* `thread list`: é usado para listar todas as threads e seus status. A thread
atual é marcada com o sinal de mais (+). 
* `thread stop n`: interrompe a thread _n_.
* `thread resume n`: retoma a thread _n_.
* `thread switch n`: alterna o contexto da thread atual para _n_.

Esse comando é muito útil quando você está fazendo o *debugging*
para verificar se não há condições do seu código continuar rodando.

### Inspecionando Variáveis

Qualquer expressão pode ser avaliada no contexto atual. Para avaliar uma
expressão, apenas digite-a!

Este exemplo mostra como você pode imprimir as variáveis de instância definidas no 
contexto atual:

```
[3, 12] in /PathTo/project/app/controllers/articles_controller.rb
    3:
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     byebug
=>  8:     @articles = Article.find_recent
    9:
   10:     respond_to do |format|
   11:       format.html # index.html.erb
   12:       format.json { render json: @articles }

(byebug) instance_variables
[:@_action_has_layout, :@_routes, :@_request, :@_response, :@_lookup_context,
 :@_action_name, :@_response_body, :@marked_for_same_origin_verification,
 :@_config]
```

Como você já deve ter percebido, todas as variáveis que você pode acessar de um
*controller* são exibidas. Esta lista é atualizada dinamicamente à medida que você executa o código.
Por exemplo, execute a próxima linha usando `next` (você aprenderá mais sobre este
comando posteriormente neste guia).

```
(byebug) next

[5, 14] in /PathTo/project/app/controllers/articles_controller.rb
   5     # GET /articles.json
   6     def index
   7       byebug
   8       @articles = Article.find_recent
   9
=> 10      respond_to do |format|
   11        format.html # index.html.erb
   12        format.json { render json: @articles }
   13      end
   14    end
   15
(byebug)
```

E, em seguida, chame novamente o instance_variables:

```
(byebug) instance_variables
[:@_action_has_layout, :@_routes, :@_request, :@_response, :@_lookup_context,
 :@_action_name, :@_response_body, :@marked_for_same_origin_verification,
 :@_config, :@articles]
```

Agora `@articles` está incluído nas variáveis de instância, porque a linha que o definiu
foi executada.

DICA: Você também pode entrar no modo **irb** com o comando `irb` (é claro!).
Isso iniciará uma sessão irb dentro do contexto que você a chamou.

O método `var` é a maneira mais conveniente de mostrar variáveis e seus valores.
Vamos pedir para que o `byebug` nos ajude com isso.

```
(byebug) help var

  [v]ar <subcommand>

  Shows variables and its values


  var all      -- Shows local, global and instance variables of self.
  var args     -- Information about arguments of the current scope
  var const    -- Shows constants of an object.
  var global   -- Shows global variables.
  var instance -- Shows instance variables of self or a specific object.
  var local    -- Shows local variables in current scope.

```

Essa é uma ótima maneira de inspecionar os valores das variáveis do contexto atuais. Por
exemplo, para verificar se não temos variáveis locais definidas atualmente:

```
(byebug) var local
(byebug)
```

Você também pode inspecionar um método de objeto desta maneira:

```
(byebug) var instance Article.new
@_start_transaction_state = {}
@aggregation_cache = {}
@association_cache = {}
@attributes = #<ActiveRecord::AttributeSet:0x007fd0682a9b18 @attributes={"id"=>#<ActiveRecord::Attribute::FromDatabase:0x007fd0682a9a00 @name="id", @value_be...
@destroyed = false
@destroyed_by_association = nil
@marked_for_destruction = false
@new_record = true
@readonly = false
@transaction_state = nil
```

Você também pode usar o `display` para começar a observar as variáveis. Esta é uma boa maneira de
rastrear os valores de uma variável enquanto a execução continua.

```
(byebug) display @articles
1: @articles = nil
```

As variáveis dentro da lista exibida serão impressas com seus valores depois 
que você se mover na *stack*. Para parar de exibir uma variável, use `undisplay n` onde
_n_ é o número da variável (1 no último exemplo).

### Passo-a-passo

Agora você deve saber onde está no *trace* em execução e poder imprimir as
variáveis disponíveis. Mas vamos continuar e seguir em frente com a execução 
da aplicação.

Use `step` (abreviado` s`) para continuar executando o programa até o próximo
ponto de parada lógica e retornar o controle ao *debugger*. `next` é semelhante a
`step`, mas enquanto `step` pára na próxima linha de código executada, executando apenas um
único passo, `next` se move para a próxima linha sem descer nos métodos.

Por exemplo, considere a seguinte situação:

```
Started GET "/" for 127.0.0.1 at 2014-04-11 13:39:23 +0200
Processing by ArticlesController#index as HTML

[1, 6] in /PathToProject/app/models/article.rb
   1: class Article < ApplicationRecord
   2:   def self.find_recent(limit = 10)
   3:     byebug
=> 4:     where('created_at > ?', 1.week.ago).limit(limit)
   5:   end
   6: end

(byebug)
```

Se usarmos o `next`, não entraremos em detalhes nas chamadas de método. Em vez disso, o `byebug` irá
para a próxima linha dentro do mesmo contexto. Nesse caso, é a última linha
do método atual, então o `byebug` retornará à próxima linha do método chamador.

```
(byebug) next
[4, 13] in /PathToProject/app/controllers/articles_controller.rb
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     @articles = Article.find_recent
    8:
=>  9:     respond_to do |format|
   10:       format.html # index.html.erb
   11:       format.json { render json: @articles }
   12:     end
   13:   end

(byebug)
```

Se usarmos `step` na mesma situação, o` byebug` irá literalmente para a próxima
Instrução Ruby a ser executada - neste caso, o método `week` do Active Support.

```
(byebug) step

[49, 58] in /PathToGems/activesupport-5.1.0/lib/active_support/core_ext/numeric/time.rb
   49:
   50:   # Returns a Duration instance matching the number of weeks provided.
   51:   #
   52:   #   2.weeks # => 14 days
   53:   def weeks
=> 54:     ActiveSupport::Duration.weeks(self)
   55:   end
   56:   alias :week :weeks
   57:
   58:   # Returns a Duration instance matching the number of fortnights provided.
(byebug)
```

Essa é uma das melhores maneiras de encontrar erros no seu código.

DICA: Você também pode usar o `step n` ou o `next n` para avançar `n` passos de uma vez.

### Breakpoints

Um breakpoint interrompe sua aplicação sempre que um determinado ponto do programa
é atingido. O *shell* do *debugger* é chamado nessa linha.

Você pode adicionar *breakpoints* dinamicamente com o comando `break` (ou apenas `b`).
Existem três maneiras possíveis de adicionar *breakpoints* manualmente:

* `break n`: define um *breakpoint* na linha de número _n_ no arquivo fonte atual.
* `break file:n [if expression]`: define um breakpoint na linha de número _n_ dentro
do arquivo chamado _file_. Se uma _expression_ for dada, ela deve ser avaliada como _true_ para
iniciar o *debugger*.
* `break class(.|\#)method [if expression]`: define um breakpoint no _method_ (. e
\# para classe e método de instância, respectivamente) definido em _class_. O
_expression_ funciona da mesma maneira que com o `file:n`.

Por exemplo, na situação anterior

```
[4, 13] in /PathToProject/app/controllers/articles_controller.rb
    4:   # GET /articles
    5:   # GET /articles.json
    6:   def index
    7:     @articles = Article.find_recent
    8:
=>  9:     respond_to do |format|
   10:       format.html # index.html.erb
   11:       format.json { render json: @articles }
   12:     end
   13:   end

(byebug) break 11
Successfully created breakpoint with id 1

```

Use `info breakpoints` para listar os breakpoints. Se você fornecer um número, ele listará
esse breakpoint correspondente. Caso contrário, ele listará todos os breakpoints.

```
(byebug) info breakpoints
Num Enb What
1   y   at /PathToProject/app/controllers/articles_controller.rb:11
```

Para deletar os *breakpoints*: use o comando `delete n` para remover o *breakpoint*
de número _n_. Se nenhum número for especificado, ele excluirá todos os breakpoints que estão
ativos no momento.

```
(byebug) delete 1
(byebug) info breakpoints
No breakpoints.
```

Você também pode ativar ou desativar os *breakpoints*:

* `enable breakpoints [n [m [...]]]`: fornece uma lista de *breakpoints* específicos ou todos
os *breakpoints* para interromper seu programa. Este é o estado padrão quando você cria um
*breakpoint*.
* `disable breakpoints [n [m [...]]]`: garante que certos (ou todos) *breakpoints* não
tenham efeito no seu programa.

### Captura de Exceções

O comando `catch exception-name` (ou apenas `cat exception-name`) pode ser usado para
interceptar uma exceção do tipo _exception-name_ quando, de outra forma, não haveria
um manipulador para isso.

Para listar todos os pontos de captura ativos, use `catch`.

### Continuando a execução

Existem duas maneiras de retomar a execução de uma aplicação que está parada no
*debugger*:

* `continue [n]`: retoma a execução do programa no local em que o seu script parou
pela última vez; quaisquer *breakpoints* definidos nesse local são ignorados. O argumento opcional
`n` permite especificar um número de linha para definir um *breakpoint* único que é
excluído quando esse *breakpoint* é atingido.
* `finish [n]`: executa até o *stack frame* selecionado retornar. Se nenhum número
de *frame* for fornecido, a aplicação será executada até o *frame* atualmente selecionado
retornar. O *frame* atualmente selecionado inicia o *frame* mais recente ou 0 se
nenhum posicionamento de *frame* (por exemplo, para cima, para baixo ou *frame*) foi executado. Se um número
de *frame* for fornecido, ele será executado até que o *frame* especificado retorne.

### Edição

Dois comandos permitem abrir o código do *debugger* em um editor:

* `edit [file: n]`: edita o arquivo chamado _file_ usando o editor especificado pelo
Variável de ambiente *EDITOR*. Uma linha específica _n_ também pode ser fornecida.

### Sair

Para sair do debugger, use o comando `quit` (abreviado para `q`). Ou digite `q!`
para ignorar a mensagem `Really quit? (y/n)` e sai incondicionalmente.

Uma saída simples tenta finalizar todos as *threads* em vigor. Portanto, seu servidor
será parado e você precisará iniciá-lo novamente.

### Configurações

O `byebug` possui algumas opções disponíveis para ajustar seu comportamento:

```
(byebug) help set

  set <setting> <value>

  Modifies byebug settings

  Boolean values take "on", "off", "true", "false", "1" or "0". If you
  don't specify a value, the boolean setting will be enabled. Conversely,
  you can use "set no<setting>" to disable them.

  You can see these environment settings with the "show" command.

  List of supported settings:

  autosave       -- Automatically save command history record on exit
  autolist       -- Invoke list command on every stop
  width          -- Number of characters per line in byebug's output
  autoirb        -- Invoke IRB on every stop
  basename       -- <file>:<line> information after every stop uses short paths
  linetrace      -- Enable line execution tracing
  autopry        -- Invoke Pry on every stop
  stack_on_error -- Display stack trace when `eval` raises an exception
  fullpath       -- Display full file names in backtraces
  histfile       -- File where cmd history is saved to. Default: ./.byebug_history
  listsize       -- Set number of source lines to list by default
  post_mortem    -- Enable/disable post-mortem mode
  callstyle      -- Set how you want method call parameters to be displayed
  histsize       -- Maximum number of commands that can be stored in byebug history
  savefile       -- File where settings are saved to. Default: ~/.byebug_save
```

TIP: You can save these settings in an `.byebugrc` file in your home directory.
The debugger reads these global settings when it starts. For example:

```bash
set callstyle short
set listsize 25
```

Debugging with the `web-console` gem
------------------------------------

Web Console is a bit like `byebug`, but it runs in the browser. In any page you
are developing, you can request a console in the context of a view or a
controller. The console would be rendered next to your HTML content.

### Console

Inside any controller action or view, you can invoke the console by
calling the `console` method.

For example, in a controller:

```ruby
class PostsController < ApplicationController
  def new
    console
    @post = Post.new
  end
end
```

Or in a view:

```html+erb
<% console %>

<h2>New Post</h2>
```

This will render a console inside your view. You don't need to care about the
location of the `console` call; it won't be rendered on the spot of its
invocation but next to your HTML content.

The console executes pure Ruby code: You can define and instantiate
custom classes, create new models, and inspect variables.

NOTE: Only one console can be rendered per request. Otherwise `web-console`
will raise an error on the second `console` invocation.

### Inspecting Variables

You can invoke `instance_variables` to list all the instance variables
available in your context. If you want to list all the local variables, you can
do that with `local_variables`.

### Settings

* `config.web_console.whitelisted_ips`: Authorized list of IPv4 or IPv6
addresses and networks (defaults: `127.0.0.1/8, ::1`).
* `config.web_console.whiny_requests`: Log a message when a console rendering
is prevented (defaults: `true`).

Since `web-console` evaluates plain Ruby code remotely on the server, don't try
to use it in production.

Debugging Memory Leaks
----------------------

A Ruby application (on Rails or not), can leak memory — either in the Ruby code
or at the C code level.

In this section, you will learn how to find and fix such leaks by using tool
such as Valgrind.

### Valgrind

[Valgrind](http://valgrind.org/) is an application for detecting C-based memory
leaks and race conditions.

There are Valgrind tools that can automatically detect many memory management
and threading bugs, and profile your programs in detail. For example, if a C
extension in the interpreter calls `malloc()` but doesn't properly call
`free()`, this memory won't be available until the app terminates.

For further information on how to install Valgrind and use with Ruby, refer to
[Valgrind and Ruby](http://blog.evanweaver.com/articles/2008/02/05/valgrind-and-ruby/)
by Evan Weaver.

Plugins for Debugging
---------------------

There are some Rails plugins to help you to find errors and debug your
application. Here is a list of useful plugins for debugging:

* [Query Trace](https://github.com/ruckus/active-record-query-trace/tree/master) Adds query
origin tracing to your logs.
* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master)
Provides a mailer object and a default set of templates for sending email
notifications when errors occur in a Rails application.
* [Better Errors](https://github.com/charliesome/better_errors) Replaces the
standard Rails error page with a new one containing more contextual information,
like source code and variable inspection.
* [RailsPanel](https://github.com/dejan/rails_panel) Chrome extension for Rails
development that will end your tailing of development.log. Have all information
about your Rails app requests in the browser — in the Developer Tools panel.
Provides insight to db/rendering/total times, parameter list, rendered views and
more.
* [Pry](https://github.com/pry/pry) An IRB alternative and runtime developer console.

References
----------

* [byebug Homepage](https://github.com/deivid-rodriguez/byebug)
* [web-console Homepage](https://github.com/rails/web-console)
