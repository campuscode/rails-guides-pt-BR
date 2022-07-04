**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

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


TIP: Por padrão, cada *log* é criado em `Rails.root/log/` e o arquivo de registro é criado com o nome do ambiente no qual a aplicação está sendo executada.


### Níveis de Log

Quando algo é registrado, a informação é armazenada no local de registro correspondente se o nível de *log* for igual ou maior que o configurado. Se você quiser saber o nível atual do registro, você pode o método `Rails.logger.level`.

Os níveis de log disponiveis são: `:debug`, `:info`, `:warn`, `:error`, `:fatal`,
e `:unknown`, correspondendo aos níveis de log de 0 até 5, respectivamente. Para mudar o nível de log padrão, utilize:

```ruby
config.log_level = :warn # Em qualquer inicializador de ambiente, ou
Rails.logger.level = 0 # a qualquer momento
```

Isso é útil quando você quer criar *logs* em ambientes diferentes de desenvolvimento ou homologação sem sobrecarregar os registros do seu aplicativo com informação desnecessária.

TIP: O nível de *log* padrão do Rails é `debug` em todos os ambientes de desenvolvimento.

### Enviando Mensagens

Para enviar uma mensagem para o *log* ativo, use o método `logger.(debug|info|warn|error|fatal|unknown)` de dentro de um *controller*, *model* ou *mailer*:

```ruby
logger.debug "Hash com atributos de 'Person': #{@person.attributes.inspect}"
logger.info "Processando informações..."
logger.fatal "Encerrando aplicação, erro irrecuperavel!!!"
```

Segue um exemplo de um método instrumentado com um log extra:

```ruby
class ArticlesController < ApplicationController
  # ...

  def create
    @article = Article.new(article_params)
    logger.debug "Novo Artigo: #{@article.attributes.inspect}"
    logger.debug "Artigo deve ser valido: #{@article.valid?}"

    if @article.save
      logger.debug "O Artigo foi salvo e agora o usuario será redirecionado..."
      redirect_to @article, notice: 'Artigo criado com sucesso'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # ...

  private
    def article_params
      params.require(:article).permit(:title, :body, :published)
    end
end
```

Segue um exemplo de um log gerado quando a ação deste *controller* é executada:

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

A adição deste tipo de log facilita a busca por comportamentos não esperados ou não usuais. Se você adicionar logs extras, tenha certeza de utilizar os níveis de log de maneira adequada, para evitar encher seus logs do ambiente de produção com trivialidades inúteis.

### Verbose Query Logs

Ao observar a saída de consulta de banco de dados em logs, pode não ser imediatamente claro por que várias consultas de banco de dados são acionadas quando um único método é chamado:

```
irb(main):001:0> Article.pamplemousse
  Article Load (0.4ms)  SELECT "articles".* FROM "articles"
  Comment Load (0.2ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 1]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 2]]
  Comment Load (0.1ms)  SELECT "comments".* FROM "comments" WHERE "comments"."article_id" = ?  [["article_id", 3]]
=> #<Comment id: 2, author: "1", body: "Well, actually...", article_id: 1, created_at: "2018-10-19 00:56:10", updated_at: "2018-10-19 00:56:10">
```

Depois de executar `ActiveRecord::Base.verbose_query_logs = true` na sessão `bin/rails console` para habilitar logs de consulta detalhados e executar o método novamente, torna-se óbvio qual linha única de código está gerando todas essas chamadas discretas de banco de dados:

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

Abaixo de cada instrução do banco de dados, você pode ver setas apontando para o nome do arquivo de origem específico (e o número da linha) do método que resultou em uma chamada de banco de dados. Isso pode ajudá-lo a identificar e resolver problemas de desempenho causados por consultas N + 1: consultas únicas de banco de dados que geram várias consultas adicionais.

Logs de consulta detalhada são habilitados por padrão nos logs do ambiente de desenvolvimento após o Rails 5.2.

WARNING: Não recomendamos o uso dessa configuração em ambientes de produção. Ele se baseia no método`Kernel#caller` que tende a alocar muita memória para gerar o _backtrace_ (rastreamento) de chamadas de método.

### Tagged Log

Ao executar aplicativos multiusuário e multi-contas, muitas vezes é útil
ser capaz de filtrar os registros usando algumas regras personalizadas. `TaggedLogging`
no Active Support ajuda você a fazer exatamente isso, marcando linhas de registro com subdomínios, IDs de requisição e qualquer outra coisa para auxiliar no _debug_ de tais aplicativos.

```ruby
logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
logger.tagged("BCX") { logger.info "Stuff" }                            # Logs "[BCX] Stuff"
logger.tagged("BCX", "Jason") { logger.info "Stuff" }                   # Logs "[BCX] [Jason] Stuff"
logger.tagged("BCX") { logger.tagged("Jason") { logger.info "Stuff" } } # Logs "[BCX] [Jason] Stuff"
```

### Impacto dos logs no desempenho

O log sempre terá um pequeno impacto no desempenho do seu aplicativo Rails,
particularmente ao fazer o registro no disco. Além disso, existem algumas sutilezas:

Ao utilizar o nível `:debug` terá uma penalidade de desempenho maior do que `:fatal`,
já que um número muito maior de _strings_ está sendo avaliado e gravado na saída do log (e.g. disco).

Outra armadilha potencial são muitas chamadas para `Logger` em seu código:

```ruby
logger.debug "Person attributes hash: #{@person.attributes.inspect}"
```

No exemplo acima, haverá um impacto no desempenho, mesmo se o nível de saída
permitido não incluir _debug_. A razão é que o Ruby tem que avaliar
essas _strings_, que inclui instanciar o objeto `String` um tanto pesado
e interpolar as variáveis.

Portanto, é recomendado passar blocos para os métodos logger, pois estes são
apenas avaliado se o nível de saída for o mesmo - ou incluído - o nível permitido
(i.e. carregamento lento). O mesmo código reescrito seria:

```ruby
logger.debug {"Person attributes hash: #{@person.attributes.inspect}"}
```

O conteúdo do bloco e, portanto, a interpolação de _string_, são apenas
avaliada se o _debug_ está habilitado. Essa economia de desempenho é apenas realmente
perceptível com grandes quantidades de registro, mas é uma boa prática empregar.

INFO: Esta seção foi escrita por [Jon Cairns em uma resposta no StackOverflow](https://stackoverflow.com/questions/16546730/logging-in-rails-is-there-any-performance-hit/16546935#16546935)
e está licenciada sob [cc by-sa 4.0](https://creativecommons.org/licenses/by-sa/4.0/).

Debugging with the `debug` gem
------------------------------

When your code is behaving in unexpected ways, you can try printing to logs or
the console to diagnose the problem. Unfortunately, there are times when this
sort of error tracking is not effective in finding the root cause of a problem.
When you actually need to journey into your running source code, the debugger
is your best companion.

The debugger can also help you if you want to learn about the Rails source code
but don't know where to start. Just debug any request to your application and
use this guide to learn how to move from the code you have written into the
underlying Rails code.

Rails 7 includes the `debug` gem in the `Gemfile` of new applications generated
by CRuby. By default, it is ready in the `development` and `test` environments.
Please check its [documentation](https://github.com/ruby/debug) for usage.

### Entering a Debugging Session

By default, a debugging session will start after the `debug` library is required, which happens when your app boots. But don't worry, the session won't interfere your program.

 To enter the debugging session, you can use `binding.break` and its aliases: `binding.b` and `debugger`. The following examples will use `debugger`:

```rb
class PostsController < ApplicationController
  before_action :set_post, only: %i[ show edit update destroy ]

  # GET /posts or /posts.json
  def index
    @posts = Post.all
    debugger
  end
  # ...
end
```

Once your app evaluates the debugging statement, it'll enter the debugging session:

```rb
Processing by PostsController#index as HTML
[2, 11] in ~/projects/rails-guide-example/app/controllers/posts_controller.rb
     2|   before_action :set_post, only: %i[ show edit update destroy ]
     3|
     4|   # GET /posts or /posts.json
     5|   def index
     6|     @posts = Post.all
=>   7|     debugger
     8|   end
     9|
    10|   # GET /posts/1 or /posts/1.json
    11|   def show
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  # and 72 frames (use `bt' command for all frames)
(rdbg)
```

### The Context

After entering the debugging session, you can type in Ruby code as you're in a Rails console or IRB.

```rb
(rdbg) @posts    # ruby
[]
(rdbg) self
#<PostsController:0x0000000000aeb0>
(rdbg)
```

You can also use `p` or `pp` command to evaluate Ruby expressions (e.g. when a variable name conflicts with a debugger command).

```rb
(rdbg) p headers    # command
=> {"X-Frame-Options"=>"SAMEORIGIN", "X-XSS-Protection"=>"1; mode=block", "X-Content-Type-Options"=>"nosniff", "X-Download-Options"=>"noopen", "X-Permitted-Cross-Domain-Policies"=>"none", "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg) pp headers    # command
{"X-Frame-Options"=>"SAMEORIGIN",
 "X-XSS-Protection"=>"1; mode=block",
 "X-Content-Type-Options"=>"nosniff",
 "X-Download-Options"=>"noopen",
 "X-Permitted-Cross-Domain-Policies"=>"none",
 "Referrer-Policy"=>"strict-origin-when-cross-origin"}
(rdbg)
```

Besides direct evaluation, debugger also helps you collect rich amount of information through different commands. Just to name a few here:

- `info` (or `i`) - Information about current frame.
- `backtrace` (or `bt`) - Backtrace (with additional information).
- `outline` (or `o`, `ls`) - Available methods, constants, local variables, and instance variables in the current scope.

#### The info command

It'll give you an overview of the values of local and instance variables that are visible from the current frame.

```rb
(rdbg) info    # command
%self = #<PostsController:0x0000000000af78>
@_action_has_layout = true
@_action_name = "index"
@_config = {}
@_lookup_context = #<ActionView::LookupContext:0x00007fd91a037e38 @details_key=nil, @digest_cache=...
@_request = #<ActionDispatch::Request GET "http://localhost:3000/posts" for 127.0.0.1>
@_response = #<ActionDispatch::Response:0x00007fd91a03ea08 @mon_data=#<Monitor:0x00007fd91a03e8c8>...
@_response_body = nil
@_routes = nil
@marked_for_same_origin_verification = true
@posts = []
@rendered_format = nil
```

#### The backtrace command

When used without any options, it lists all the frames on the stack:

```rb
=>#0    PostsController#index at ~/projects/rails-guide-example/app/controllers/posts_controller.rb:7
  #1    ActionController::BasicImplicitRender#send_action(method="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/basic_implicit_render.rb:6
  #2    AbstractController::Base#process_action(method_name="index", args=[]) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/abstract_controller/base.rb:214
  #3    ActionController::Rendering#process_action(#arg_rest=nil) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/action_controller/metal/rendering.rb:53
  #4    block in process_action at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actionpack-7.0.0.alpha2/lib/abstract_controller/callbacks.rb:221
  #5    block in run_callbacks at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.0.0.alpha2/lib/active_support/callbacks.rb:118
  #6    ActionText::Rendering::ClassMethods#with_renderer(renderer=#<PostsController:0x0000000000af78>) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.0.0.alpha2/lib/action_text/rendering.rb:20
  #7    block {|controller=#<PostsController:0x0000000000af78>, action=#<Proc:0x00007fd91985f1c0 /Users/st0012/...|} in <class:Engine> (4 levels) at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/actiontext-7.0.0.alpha2/lib/action_text/engine.rb:69
  #8    [C] BasicObject#instance_exec at ~/.rbenv/versions/3.0.1/lib/ruby/gems/3.0.0/gems/activesupport-7.0.0.alpha2/lib/active_support/callbacks.rb:127
  ..... and more
```

Every frame comes with:

- Frame identifier
- Call location
- Additional information (e.g. block or method arguments)

This will give you a great sense about what's happening in your app. However, you probably will notice that:

- There are too many frames (usually 50+ in a Rails app).
- Most of the frames are from Rails or other libraries you use.

Don't worry, the `backtrace` command provides 2 options to help you filter frames:

- `backtrace [num]` - only show `num` numbers of frames, e.g. `backtrace 10` .
- `backtrace /pattern/` - only show frames with identifier or location that matches the pattern, e.g. `backtrace /MyModel/`.

It's also possible to use these options together: `backtrace [num] /pattern/`.

#### The outline command

This command is similar to `pry` and `irb`'s `ls` command. It will show you what's accessible from you current scope, including:

- Local variables
- Instance variables
- Class variables
- Methods & their sources
- ...etc.

```rb
ActiveSupport::Configurable#methods: config
AbstractController::Base#methods:
  action_methods  action_name  action_name=  available_action?  controller_path  inspect
  response_body
ActionController::Metal#methods:
  content_type       content_type=  controller_name  dispatch          headers
  location           location=      media_type       middleware_stack  middleware_stack=
  middleware_stack?  performed?     request          request=          reset_session
  response           response=      response_body=   response_code     session
  set_request!       set_response!  status           status=           to_a
ActionView::ViewPaths#methods:
  _prefixes  any_templates?  append_view_path   details_for_lookup  formats     formats=  locale
  locale=    lookup_context  prepend_view_path  template_exists?    view_paths
AbstractController::Rendering#methods: view_assigns

# .....

PostsController#methods: create  destroy  edit  index  new  show  update
instance variables:
  @_action_has_layout  @_action_name    @_config  @_lookup_context                      @_request
  @_response           @_response_body  @_routes  @marked_for_same_origin_verification  @posts
  @rendered_format
class variables: @@raise_on_missing_translations  @@raise_on_open_redirects
```

You can find more commands and configuration options from its [documentation](https://github.com/ruby/debug).

#### Autoloading Caveat

Debugging with `debug` works fine most of the time, but there's an edge case: If you evaluate an expression in the console that autoloads a namespace defined in a file, constants in that namespace won't be found.

For example, if the application has these two files:

```ruby
# hotel.rb
class Hotel
end

# hotel/pricing.rb
module Hotel::Pricing
end
```

and `Hotel` is not yet loaded, then

```
(rdbg) p Hotel::Pricing
```

will raise a `NameError`. In some cases, Ruby will be able to resolve an unintended constant in a different scope.

If you hit this, please restart your debugging session with eager loading enabled (`config.eager_load = true`).

Stepping commands line `next`, `continue`, etc., do not present this issue. Namespaces defined implicitly only by
subdirectories are not subject to this issue either.

See [ruby/debug#408](https://github.com/ruby/debug/issues/408) for details.

Debug com a gem `web-console`
------------------------------------

A *gem* Web Console é um pouco semelhante à *gem* `debug`, porém é executada no navegador. Em qualquer página que você esteja desenvolvendo, você pode solicitar um `console` no contexto da *view* ou do *controller*. O *console* deve ser renderizado próximo ao conteúdo HTML.

### Console

Dentro de qualquer *controller action* ou *view*, você pode utilizar o console através da chamada do método `console`.

Por exemplo, em um *controller*:

```ruby
class PostsController < ApplicationController
  def new
    console
    @post = Post.new
  end
end
```

Ou em uma *view*:

```html+erb
<% console %>

<h2>New Post</h2>
```

Isso vai renderizar um *console* dentro da view. Você não precisa se preocupar com a localização da chamada do método `console`; não será renderizado próximo ao elemento em que foi invocado, mas sim próximo ao seu conteúdo HTML.

O *console* executa código Ruby nativo: Você pode definir e instanciar classes personalizadas, criar novos *models*, e inspecionar variáveis.

NOTE: Somente um *console* pode ser renderizado por *request*. De outra maneira `web-console` lança um erro na segunda invocação do método `console`.

### Inspecionando Variáveis

Você pode chamar `instance_variables` para listar todas as variáveis de instância disponíveis em seu contexto. Se você deseja listar todas as variáveis locais, você pode fazer isso usando `local_variables`.

### Configurações

* `config.web_console.allowed_ips`: Lista autorizada de endereços e redes IPv4 ou IPv6 (padrões: `127.0.0.1/8, ::1`).
* `config.web_console.whiny_requests`: Registra uma mensagem quando a renderização do *console* é impedida (padrões: `true`).

Uma vez que `web-console` avalia código Ruby simples remotamente no servidor, não tente usar em produção.

Debug de Vazamentos de Memórias
----------------------

Um aplicativo Ruby (on Rails ou não) pode vazar memória (*memory leak*) - tanto no código Ruby
quanto no nível de código C.

Nesta seção, você aprenderá como encontrar e corrigir esses vazamentos usando ferramentas
tais como o Valgrind.

### Valgrind

[Valgrind](http://valgrind.org/) é um aplicativo para detectar vazamentos de memória baseados em C
e condições de corrida.

Existem ferramentas Valgrind que podem detectar automaticamente muitos bugs de threading 
e gerenciamento de memória, e criar perfis de seus programas em detalhes. Por exemplo, se uma extensão 
C no intérprete chama `malloc()` mas não chama corretamente 
`free()`, essa memória não estará disponível até que o aplicativo seja encerrado.

Para obter mais informações sobre como instalar o Valgrind e usar com Ruby, consulte
[Valgrind and Ruby](https://blog.evanweaver.com/2008/02/05/valgrind-and-ruby/)
por Evan Weaver.

### Encontrando um vazamento de memória

Há um excelente artigo (em inglês) sobre detecção e correção de vazamentos de memória no Derailed, [que você pode ler aqui](https://github.com/schneems/derailed_benchmarks#is-my-app-leaking-memory).

Plugins para *Debug*
---------------------

Existem alguns plugins Rails para te ajudar a procurar erros e *debugar* a aplicação. Aqui está uma lista de plugins úteis para *debug*:

* [Query Trace](https://github.com/ruckus/active-record-query-trace/tree/master) Adiciona rastreamento de origem de consulta aos seus logs.
* [Exception Notifier](https://github.com/smartinez87/exception_notification/tree/master)
Fornece um objeto *mailer* e um conjunto padrão de *templates* para enviar notificações por email quando ocorrerem erros em um aplicativo Rails.
* [Better Errors](https://github.com/charliesome/better_errors) Substitui a página de erro padrão do Rails por uma nova contendo mais informações contextuais, como código-fonte e inspeção de variáveis.
* [RailsPanel](https://github.com/dejan/rails_panel) extensão do Chrome para desenvolvimento Rails que encerrerá seu acompanhamento de development.log. Tenha todas as informações sobre as solicitações do seu aplicativo Rails no navegador - no painel Ferramentas do desenvolvedor. Fornece informações sobre db / renderização / tempos totais, lista de parâmetros, visualizações renderizadas e muito mais.
* [Pry](https://github.com/pry/pry) Uma alternativa IRB e console de desenvolvedor em tempo de execução.

Referencias
----------

* [web-console Homepage](https://github.com/rails/web-console)
* [debug homepage](https://github.com/ruby/debug)

