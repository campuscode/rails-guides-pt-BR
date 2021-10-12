**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Testando Applicações Rails
==========================

Este guia cobre mecanismos nativos do Rails para testar suas aplicações.

Após ler este guia, você saberá:

* A terminologia de testes.
* Como escrever testes unitários, funcionais, de integração e de sistema para a sua aplicação.
* Outras abordagens e plugins populares de testes.

--------------------------------------------------------------------------------

Por que escrever testes para a sua aplicação Rails?
---------------------------------------------------

O Rails torna super fácil escrever seus testes. Ele começa produzindo um esqueleto de código de teste enquanto você cria seus *models* e *controllers*.

Ao rodar seus testes no Rails você pode garantir que seu código continua com a funcionalidade desejada mesmo após algumas grandes refatorações no código.

Os testes no Rails podem simular requisições no browser e com isso, você pode testar a resposta da sua aplicação sem ter que testar utilizando de fato seu o browser.

Introdução a testes
-----------------------

O suporte a testes foi implantado no Rails desde os primórdios. Não foi uma epifania do tipo: "Vamos adicionar suporte para testes porque eles são novos e legais!"

### Configurações para testes em aplicações Rails

O Rails cria um diretório `test` para você logo que você cria um projeto Rails usando o comando `rails new` _nome_da_aplicacao_. Se você listar o conteúdo deste diretório, você verá:

```bash
$ ls -F test
application_system_test_case.rb  controllers/                     helpers/                         mailers/                         system/
channels/                        fixtures/                        integration/                     models/                          test_helper.rb
```

Os diretórios `helpers`, `mailers` e `models` são destinados a realizar os testes para *view helpers*, *mailers* e *models*, respectivamente. O diretório `channel` é destinado a realizar os testes para a conexão e canais do *ActionCable*. O diretório `controllers` se destina a realizar testes para os *controllers*, rotas e *views*. O diretório `integration` se destina a realizar testes de interação entre *controllers*.

O diretório `system` é destinado a realizar os testes do sistema, que são usados para testes completos da aplicação no browser. Os Testes de Sistema permitem você testar a aplicação do jeito que seu usuário experiência e ajuda você a testar seu JavaScript também.
Os Testes de sistemas herdam de Capybara e são executados em testes de *browser* para a sua aplicação

*Fixtures* são um jeito de organizar dados de testes; ficam no diretório `fixtures`

Um diretório `jobs` também será criado quando um teste associado é gerado.

O arquivo `test_helper.rb` é responsável por realizar as configurações padrão para seus testes.

O arquivo `application_system_test_case.rb` é responsável por realizar as configurações padrão para seus testes de sistema.

### O Ambiente de Teste

Por padrão, toda aplicação Rails tem três ambientes: desenvolvimento, teste e produção.

A configuração de cada ambiente pode ser modificada de forma semelhante. Neste caso, podemos modificar nosso ambiente de teste alterando as opções encontradas em `config/environments/test.rb`.

NOTE: Seus testes são executados sob o comando `RAILS_ENV=test`.

### Rails conhece Minitest

Se você se lembra, nós usamos o comando `bin/rails generate model` no guia [Começando com Rails](getting_started.html). Nós criamos nosso primeiro model e, entre outras coisas, foi criado [_stub_](https://pt.wikipedia.org/wiki/Stub) de testes no diretório `test`:

```bash
$ bin/rails generate model article title:string body:text
...
create  app/models/article.rb
create  test/models/article_test.rb
create  test/fixtures/articles.yml
...
```

O _stub_ teste padrão em `test/models/article_test.rb` parece assim:

```ruby
require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
```

Uma inspeção linha a linha desse arquivo ajudará você a se orientar a terminologia e código de testes no Rails.

```ruby
require "test_helper"
```

Por fazer *require* desse arquivo, `test_helper.rb` as configurações padrões para executar nossos testes são carregadas. Nós vamos incluir isso em todos os testes que escrevermos, então qualquer método adicionado a este arquivo vai estar disponível em todos os nossos testes.

```ruby
class ArticleTest < ActiveSupport::TestCase
```

A classe `ArticleTest` define um _test case_ porque ela herda de `ActiveSupport::TestCase`. `ArticleTest` portanto tem todos os métodos disponíveis de `ActiveSupport::TestCase`. Mais pra frente nesse guia, nós vamos adicionar alguns dos métodos dados.

Qualquer método definido com uma classe herdada de `Minitest::Test` (que é uma superclasse de `ActiveSupport::TestCase`) que começa com `test_` é simplesmente chamada em um teste. Então, métodos definidos como `test_password` e `test_valid_password` são nomes de testes legais e serão executados automaticamente quando o caso de teste (_test_case_) é executado.

O Rails também adiciona um método `test` que leva um nome _test_ e um bloco. Isso gera um teste normal `Minitest::Unit` com nomes de métodos prefixados com `test_`. Então você não precisa se preocupar com nomear os métodos, e você pode escrever algo assim:

```ruby
test "the truth" do
  assert true
end
```

Que é aproximadamente o mesmo que escrever isto:

```ruby
def test_the_truth
  assert true
end
```

Apesar de você ainda poder usar definições comuns de métodos, usando o prefixo `test` permite você ter um teste mais legível.

NOTE: O nome do método é gerado por alterar espaços com undescores(*_*). O resultado não precisa ser um identificador Ruby válido, embora o nome possa conter caracteres de pontuação, etc. Isso é porque em Ruby tecnicamente qualquer string pode ser o nome de um método. Isso pode requerer a chamada dos métodos `define_method` e `send` para funcionar corretamente, mas formalmente há uma pequena restrição no nome.

A seguir, vamos olhar para nossa primeira asserção:

```ruby
assert true
```

Uma asserção é uma linha de código que pode se tornar um objeto (ou expressão) para resultados esperados. Por exemplo, uma asserção pode checar se:

* Esse valor é igual a aquele valor?
* Esse objeto é nulo?
* Essa linha de código dispara uma exceção?
* A senha do usuário é maior que 5 caracteres?

Todo teste pode conter uma ou mais asserções, sem restrições em quantas asserções são permitidas. Apenas quando todas as asserções serem bem-sucedidas o teste vai passar.

#### Seu primeiro teste que falha

Para ver como uma falha no teste é reportada, você pode adicionar um teste que falha no caso de teste do arquivo `article_test.rb`.

```ruby
test "should not save article without title" do
  article = Article.new
  assert_not article.save
end
```

Vamos executar o teste com esse caso de teste adicionado (onde 6 é o número da linha onde o teste é definido).

```bash
$ bin/rails test test/models/article_test.rb:6
Run options: --seed 44656

# Running:

F

Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
Expected true to be nil or false


rails test test/models/article_test.rb:6



Finished in 0.023918s, 41.8090 runs/s, 41.8090 assertions/s.

1 runs, 1 assertions, 1 failures, 0 errors, 0 skips
```

Na saída do teste, `F` significa uma falha. Você pode ver o _trace_ correspondente mostrado abaixo de `Failure` junto com o nome do teste que está falhando. As próximas linhas contém as origens do erro seguido por uma mensagem que menciona o valor atual e o valor esperado pela asserção. A mensagem de asserção padrão provê informação o suficiente para ajudar a localizar o erro. Para fazer a asserção mais legível, toda asserção tem um parâmetro de mensagem opcional, como foi mostrado aqui:

```ruby
test "should not save article without title" do
  article = Article.new
  assert_not article.save, "Saved the article without a title"
end
```

A execução desse teste exibe uma mensagem de asserção mais amigável:

```
Failure:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
Saved the article without a title
```

Agora para fazer esse teste passar nós podemos adicionar uma validação no nível do model para o campo _title_.

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
end
```

Agora o teste deveria passar. Vamos verificar executando o teste novamente:

```bash
$ bin/rails test test/models/article_test.rb:6
Run options: --seed 31252

# Running:

.

Finished in 0.027476s, 36.3952 runs/s, 36.3952 assertions/s.

1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

Agora, se você notou, nós escrevemos um teste que falha para uma funcionalidade desejada, então nós escrevemos um código básico que adiciona a funcionalidade e finalmente nós tivemos certeza que nosso testes passam. Essa abordagem em desenvolvimento de software é referida como
[_Test-Driven Development_ (TDD)](http://c2.com/cgi/wiki?TestDrivenDevelopment).

#### Como um erro se parece

Para ver como um erro é reportado, aqui está um teste contendo um erro:

```ruby
test "should report error" do
  # some_undefined_variable não está definida no caso de teste
  some_undefined_variable
  assert true
end
```

Agora você pode ver mais saída no console ao rodar os testes:

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1808

# Running:

.E

Error:
ArticleTest#test_should_report_error:
NameError: undefined local variable or method 'some_undefined_variable' for #<ArticleTest:0x007fee3aa71798>
    test/models/article_test.rb:11:in 'block in <class:ArticleTest>'


rails test test/models/article_test.rb:9



Finished in 0.040609s, 49.2500 runs/s, 24.6250 assertions/s.

2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

Observe o 'E' na saída. Isso significa um teste com erro.

NOTE: A execução de cada método de teste para assim que qualquer erro ou uma falha de teste é encontrada, e a suíte de teste continua com o próximo método. Todos os métodos de testes são executados numa ordem aleatória. A [opção `config.active_support.test_order`](configuring.html#configuring-active-support) pode ser usada para configurar a ordem do teste.

Quando um teste falha você é apresentado ao _backtrace_ correspondente. Por padrão
Rails filtra o _backtrace_ e mostrará apenas linhas relevantes para sua
aplicação. Isso elimina qualquer reclamação do _framework_ e isso  ajuda a focar no seu
código. No entanto existem situações que você quer ver o _backtrace_
completo. Coloque o argumento `-b` (ou `--backtrace`) para habilitar esse comportamento:

```bash
$ bin/rails test -b test/models/article_test.rb
```

Se nós queremos que este teste passe nós devemos modificar isto para usar `assert_raises` assim:

```ruby
test "should report error" do
  # some_undefined_variable não está definida no caso de teste
  assert_raises(NameError) do
    some_undefined_variable
  end
end
```

Este teste agora deveria passar.

### Asserções disponíveis

Por agora você viu pouco de algumas asserções que estão disponíveis. Asserções são as obreiras dos testes. Elas são as únicas que na verdade performam para checar se as coisas estão indo conforme o planejado.

Aqui está um resumo das asserções que você pode usar com
[`Minitest`](https://github.com/seattlerb/minitest), a biblioteca padrão
usada pelo Rails. O parâmetro `[msg]` é uma mensagem opcional do tipo string que você pode
especificar para fazer as falhas do teste mais claras.

| Asserção                                                         | Propósito |
| ---------------------------------------------------------------- | ------- |
| `assert( test, [msg] )`                                          | Checa se `test` é verdadeiro.|
| `assert_not( test, [msg] )`                                      | Checa se `test` é falso.|
| `assert_equal( expected, actual, [msg] )`                        | Checa se `expected == actual` é verdadeiro.|
| `assert_not_equal( expected, actual, [msg] )`                    | Checa se `expected != actual` é verdadeiro.|
| `assert_same( expected, actual, [msg] )`                         | Checa se `expected.equal?(actual)` é verdadeiro.|
| `assert_not_same( expected, actual, [msg] )`                     | Checa se `expected.equal?(actual)` é falso.|
| `assert_nil( obj, [msg] )`                                       | Checa se `obj.nil?` é verdadeiro.|
| `assert_not_nil( obj, [msg] )`                                   | Checa se `obj.nil?` é falso.|
| `assert_empty( obj, [msg] )`                                     | Checa se `obj` is `empty?` (`obj` é vazio).|
| `assert_not_empty( obj, [msg] )`                                 | Checa se `obj` is not `empty?` (`obj` não é vazio).|
| `assert_match( regexp, string, [msg] )`                          | Checa se uma string bate com a expressão regular dada.|
| `assert_no_match( regexp, string, [msg] )`                       | Checa se uma string não bate com a expressão regular dada.|
| `assert_includes( collection, obj, [msg] )`                      | Checa se `obj` está incluído na `collection`.|
| `assert_not_includes( collection, obj, [msg] )`                  | Checa se `obj` não está incluído na `collection`.|
| `assert_in_delta( expected, actual, [delta], [msg] )`            | Checa se os números `expected` e atual estão aproximados com o `delta` de cada.|
| `assert_not_in_delta( expected, actual, [delta], [msg] )`        | Checa se os números `expected` e atual não estão aproximados com o `delta` de cada.|
| `assert_in_epsilon ( expected, actual, [epsilon], [msg] )`       | Checa se os números `expected` e `actual` tem um erro relativo menor que `epsilon`.|
| `assert_not_in_epsilon ( expected, actual, [epsilon], [msg] )`   | Checa se os números `expected` e `actual` não tem um erro relativo menor que `epsilon`.|
| `assert_throws( symbol, [msg] ) { block }`                       | Checa se um dado _bloco_ dispara um erro com o `symbol`|
| `assert_raises( exception1, exception2, ... ) { block }`         | Checa se um dado bloco dispara uma das exceções dadas.|
| `assert_instance_of( class, obj, [msg] )`                        | Checa se `obj` é uma instância de `class`.|
| `assert_not_instance_of( class, obj, [msg] )`                    | Checa se `obj` não é uma instância de `class`.|
| `assert_kind_of( class, obj, [msg] )`                            | Checa se `obj` é uma instância de `class` or uma descendente dela.|
| `assert_not_kind_of( class, obj, [msg] )`                        | Checa se `obj` não é uma instância de `class` e não é uma descendente dela.|
| `assert_respond_to( obj, symbol, [msg] )`                        | Checa se `obj` responde a `symbol`.|
| `assert_not_respond_to( obj, symbol, [msg] )`                    | Checa se `obj` não responde a `symbol`.|
| `assert_operator( obj1, operator, [obj2], [msg] )`               | Checa se `obj1.operator(obj2)` é verdadeiro.|
| `assert_not_operator( obj1, operator, [obj2], [msg] )`           | Checa se `obj1.operator(obj2)` é falso.|
| `assert_predicate ( obj, predicate, [msg] )`                     | Checa se `obj.predicate` é verdadeiro, ex: `assert_predicate str, :empty?`|
| `assert_not_predicate ( obj, predicate, [msg] )`                 | Checa se `obj.predicate` é falso, ex: `assert_not_predicate str, :empty?`|
| `flunk( [msg] )`                                                 | Checa que o teste falha. Isso é útil para marcar explicitamente que o teste não está finalizado ainda.|

As asserções acima são um subconjunto de asserções que `minitest` suporta. Para uma lista mais atualizada, por favor cheque
[Minitest API documentation](http://docs.seattlerb.org/minitest/), especificamente
[`Minitest::Assertions`](http://docs.seattlerb.org/minitest/Minitest/Assertions.html).

Por conta da natureza modular do `framework` de testes, é possível criar suas próprias asserções. De fato, isso é exatamente o que Rails faz. Isso inclui algumas asserções especializadas para deixar sua vida mais fácil.

NOTE: Criar suas próprias asserções é um tópico avançado que não cobriremos nesse tutorial.

### Asserções Específicas do Rails

Rails adiciona algumas asserções customizadas o framework `minitest`:

| Asserção                                                                          | Propósito |
| --------------------------------------------------------------------------------- | ------- |
| [`assert_difference(expressions, difference = 1, message = nil) {...}`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_difference) | Testa a diferença numérica entre o valor retornada da expressão como um resultado que contabilizado no bloco _yielded_.|
| [`assert_no_difference(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_difference) | Checa se i resultado numérico da expressão calculada não é mudado antes e depois de invocar o bloco passado.|
| [`assert_changes(expressions, message = nil, from:, to:, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_changes) | Testa o resultado de uma expressão calculado é alterado depois de passar pelo _bloco_.|
| [`assert_no_changes(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_changes) | Testa o resultado de uma expressão não é alterada depois de passar pelo _bloco_.|
| [`assert_nothing_raised { block }`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_nothing_raised) | Checa se o bloco dado não dispara nenhuma exceção.|
| [`assert_recognizes(expected_options, path, extras={}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes) | Checa se o Rails reconhece a rota fornecida pelas `expected_options`.|
| [`assert_generates(expected_path, options, defaults={}, extras = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates) | O inverso de `assert_recognizes`. Checa se o Rails não reconhece a rota fornecida pelas `expected_options`.|
| [`assert_response(type, message = nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_response) | Checa se a resposta de uma requisição vem com um código de status específico. Você pode especificar `:success` para indicar 200-299, `:redirect` para indicar 300-399, `:missing` para indicar 404, ou `:error` para indicar o intervalo de 500-599. Você pode também passar o número explícito do status ou símbolo equivalente. Para mais informação, veja [lista completa de códigos de status](http://rubydoc.info/github/rack/rack/master/Rack/Utils#HTTP_STATUS_CODES-constant) e como seus [mapeamentos](https://rubydoc.info/github/rack/rack/master/Rack/Utils#SYMBOL_TO_STATUS_CODE-constant) funcionam.|
| [`assert_redirected_to(options = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_redirected_to) | Checa se a resposta de uma requisição é redirecionada para uma URL que "bate" com as opções dadas. Você pode passar rotas nomeadas tais como `asset_redirected_to root_path` e objetos do Active Record como `assert_redirected_to @article`.|

Agora você verá alguns usos de algumas dessas asserções no próximo capítulo.

### Uma breve nota sobre os Casos de Testes

Todas as asserções tais como `assert_equal` são definidas em `Minitest::Assertions` são também disponíveis nas classes que nós usamos em nossos próprios casos de teste. De fato, Rails provê as seguintes classes que você pode herdar de:

* [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)
* [`ActionMailer::TestCase`](https://api.rubyonrails.org/classes/ActionMailer/TestCase.html)
* [`ActionView::TestCase`](https://api.rubyonrails.org/classes/ActionView/TestCase.html)
* [`ActiveJob::TestCase`](https://api.rubyonrails.org/classes/ActiveJob/TestCase.html)
* [`ActionDispatch::IntegrationTest`](https://api.rubyonrails.org/classes/ActionDispatch/IntegrationTest.html)
* [`ActionDispatch::SystemTestCase`](https://api.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html)
* [`Rails::Generators::TestCase`](https://api.rubyonrails.org/classes/Rails/Generators/TestCase.html)

Cada uma dessas asserções inclui `Minitest::Assertions`, nos permitindo usar todas as asserções básicas de nossos testes.

NOTE: Para mais informações em `Minitest`, procure na sua [própria documentação](http://docs.seattlerb.org/minitest).

### O `Teste Runner` do Rails

Nós podemos executar todos os nossos testes de uma vez usando o comando `bin/rails test`.

Ou podemos executar um único arquivo de teste passando no comando `bin/rails test` o arquivo contendo os casos de testes.

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1559

# Running:

..

Finished in 0.027034s, 73.9810 runs/s, 110.9715 assertions/s.

2 runs, 3 assertions, 0 failures, 0 errors, 0 skips
```

Isso vai executar todos os métodos do caso de teste.

Você também pode executar um método particular do caso de teste provendo a opção `-n` ou `--name` e o nome do método de teste.

```bash
$ bin/rails test test/models/article_test.rb -n test_the_truth
Run options: -n test_the_truth --seed 43583

# Running:

.

Finished tests in 0.009064s, 110.3266 tests/s, 110.3266 assertions/s.

1 tests, 1 assertions, 0 failures, 0 errors, 0 skips
```

Você pode também executar uma linha específica de um teste colocando o número da linha.

```bash
$ bin/rails test test/models/article_test.rb:6 # run specific test and line
```

Você também pode executar um diretório inteiro de testes colocando o caminho do diretório.

```bash
$ bin/rails test test/controllers # run all tests from specific directory
```

O Teste Runner provê muitas feature como _failing fast_, adiando a saída do teste
no fim da execução do teste e assim por diante. Cheque a documentação do Test Runner da seguinte forma:

```bash
$ bin/rails test -h
Usage: rails test [options] [files or directories]

Você pode executar um único teste adicionando o número da linha para o arquivo:

    bin/rails test test/models/user_test.rb:27

Você pode executar múltiplos arquivos e pastas ao mesmo tempo:

    bin/rails test test/controllers test/integration/login_test.rb

Por padrão falhas de testes e erros são reportados numa única linha durante uma execução.

opções do minitest:
    -h, --help                       Mostra esse menu de ajuda.
        --no-plugins                 Pula o plugin de auto-loading do minitest (ou coloque $MT_NO_PLUGINS).
    -s, --seed SEED                  Coloca _seed_ aleatório. Pode também ser colocado por variável de ambiente. Ex: SEED=n rake
    -v, --verbose                    Verboso. Mostra o progresso de arquivos enquanto estão processando.
    -n, --name PATTERN               Filtra a execução em  /regexp/ (Expressão regular) ou string.
        --exclude PATTERN            Exclui /regexp/ ou string da execução.

Extensões conhecidas: rails, pride
    -w, --warnings                   Executa com Warnings habilitados
    -e, --environment ENV            Executa os testes em um ambiente específico
    -b, --backtrace                  Mostra o _backtrace_ completo
    -d, --defer-output               Saída das falhas no teste e erros depois da execução de todos os testes
    -f, --fail-fast                  Aborta a execução dos testes na primeira falha ou no primeiro erro
    -c, --[no-]color                 Habilita cor ou não na saída
    -p, --pride                      Orgulho. Mostre o orgulho do seu teste!
```

Testes em Paralelo
------------------

Testes em paralelo permitem a paralelização da sua suíte de testes.
Ao passo que fazer *fork* de processos é o método padrão, também é suportado o uso de *threads*.
Rodar testes em paralelo reduz o tempo que leva para rodar sua suíte de testes inteira.

### Testes em Paralelo com Processos

O método padrão de paralelização é fazer *fork* de processos utilizando o sistema DRb do Ruby.
Os número de processos utilizados depende do número de *workers* fornecidos.
O número padrão é a quantidade de núcleos de seu computador, mas pode ser mudado para a quantidade
passada para o método `parallelize`.

Para habilitar a paralelização adicione o seguinte em seu arquivo `test_helper.rb`:

```ruby
class ActiveSupport::TestCase
  parallelize(workers: 2)
end
```

O número de *workers* informado é o número de vezes que o processo sofrerá *fork*.
Voce pode querer paralelizar sua suíte de testes local de maneira diferente de seu *CI*,
por isso uma variável de ambiente está disponível para que seja possível mudar facilmente
o número de *workers* que uma execução dos testes deve usar:

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

Quando testes são paralelizados, o *Active Record* automaticamente lida com a criação dos bancos de dados e do carregamento do esquema (*schema*) no banco de dados de cada processo.
Os bancos de dados criados serão sufixados de acordo com a numeração do *worker*.
Por exemplo, se há 2 *workers*, os testes criarão os bancos `test-database-0` e `test-database-1` respectivamente.

Se o número de *workers* passado for 1 ou menos, os processos não sofrerão *fork* e os testes não serão paralelizados.
Além disso, o banco de original `test-database` será usado.

Dois *hooks* são disponibilizados, um que roda quando o processo sofre *fork* e outro quando o *fork* é encerrado.
Isso pode ser útil se sua aplicação usa múltiplos bancos de dados ou executa outras atividades que dependem da quantidade de *workers*.

O método `parallelize_setup` é chamado logo após o *fork* do processo.
O método `parallelize_teardown` é chamado no momento antes do processo ser finalizado.

```ruby
class ActiveSupport::TestCase
  parallelize_setup do |worker|
    # configuração dos bancos de dados
  end

  parallelize_teardown do |worker|
    # limpeza dos bancos de dados
  end

  parallelize(workers: :number_of_processors)
end
```

Esses métodos não são necessários ou estão indisponíveis quando testes paralelos com *threads* são utilizados.

### Testes em Paralelo com *Threads*

Se você preferir utilizar *threads* ou está utilizando JRuby, a opção de paralelizar com *threads* está disponível.
O paralelizador com *threads* utiliza por baixo dos panos a classe `Parallel::Executor` do *Minitest*.

Para mudar o método de paralelização para utilizar *threads* ao invés de *forks*, escreva o seguinte em seu `test_helper.rb`:

```ruby
class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors, with: :threads)
end
```

Aplicações Rails geradas com JRuby ou TruffleRuby irão incluir automaticamente a opção `with: :threads`.

o número de *workers* passado para `parallelize` determina o número de *threads* que os testes irão utilizar.
Voce pode querer paralelizar sua suíte de testes de maneira diferente de seu *CI*,
por isso uma variável de ambiente está disponível para que seja possível mudar facilmente
o número de *workers* que uma execução dos testes deve usar:

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

### Testando Transações em Paralelo

O Rails automaticamente envolve todo caso de teste em uma transação do banco de dados, que é desfeita depois que o teste é concluído.
Isso faz com que os casos de teste sejam independentes uns dos outros e faz com que as mudanças no banco de dados sejam visíveis somente dentro daquele teste.


Quando você testa código que roda transações paralelas em *threads*,
as transações podem bloquear umas às outras, pois eles já estão aninhadas com a transação do caso de teste.

Você pode desabilitar transações na classe de um caso de teste, através da configuração `self.use_transactional_tests = false`:

```ruby
class WorkerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test "parallel transactions" do
    # inicia threads que criam transações
  end
end
```

NOTE: Com os testes transacionais desligados, você terá que que limpar os dados de teste criados,
já que a as mudanças não são automaticamente desfeitas depois que o teste termina.

O Banco de Dados de Teste
--------------------------

Quase tudo em uma aplicação Rails interage fortemente com um banco de dados e, como resultado, seus testes também precisarão interagir com um banco de dados.
Para escrever testes eficientes, você precisará entender como configurar e como popular esse banco de dados com dados de exemplo.

Por padrão, toda aplicação Rails tem 3 ambientes (*environments*): `development`, `test` e `production`.
O banco de dados de cada ambiente é configurado em `config/database.yml`.

Um banco de dados dedicado aos testes permite a configuração e a interação com os dados de teste separadamente.
Dessa forma, seus testes podem manipular dados de teste com confiança, sem se preocupar com os bancos de desenvolvimento ou produção.

### Mantendo o esquema do banco de dados de teste

Para rodar os testes, seu banco de dados precisará ter a estrutura atual.
A classe *test helper* checa se seu banco de teste tem alguma migração pendente.
Ela vai tentar carregar seu `db/schema.rb` ou `db/structure.sql` dentro do banco de teste.
Se alguma migração ainda estiver faltando, um erro vai ser levantado.
Isso indica que seu esquema (*schema*) ainda não foi totalmente migrado.
Rodar as migrações do banco de desenvolvimento (`bin/rails db:migrate`) irá atualizar o esquema para a última versão.

NOTE: Se migrações que já existiam forem modificadas, o banco de dados de teste precisará ser refeito.
Isso pode ser feito executando `bin/rails db:test:prepare`.

### O Essencial sobre *Fixtures*

Para fazer bons testes, você precisará pensar bastante em como irá preparar seus dados de teste.
No Rails, você pode lidar com isso definindo e customizando *fixtures*.
Você pode encontrar a documentação completa em [documentação da API de Fixtures](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html).

#### O que são *Fixtures*?

*Fixtures* é uma apenas uma palavra bonita pra dados de teste.
*Fixtures* permitem você popular seu banco de teste com dados predefinidos antes dos testes rodarem.
*Fixtures* funcionam independentemente do banco de dados e são escritas em YAML.
Há um arquivo por *model*.

NOTE: *Fixtures* não foram feitas para criar todos os objetos que seus testes precisam e são melhor gerenciadas quando usadas somente para dados padrão que podem ser usados em casos comuns.

Você encontrará *fixtures* dentro da pasta `test/fixtures`.
Quando se roda `bin/rails generate model` para criar um *model*, o Rails automaticamente cria um esqueleto de *fixture* nessa pasta.

#### YAML

*Fixtures* escritas em YAML são um jeito amigável para humanos de escrever seus dados de teste.
Esse tipo de *fixture* vai ter a extensão **.yml** (como em `users.yml`).

Segue um exemplo de *fixture* em arquivo YAML:

```yaml
# Vejam e contemplem! Eu sou um comentário em YAML!
david:
  name: David Heinemeier Hansson
  birthday: 1979-10-15
  profession: Systems development

steve:
  name: Steve Ross Kellock
  birthday: 1974-09-27
  profession: guy with keyboard
```

Cada *fixture* recebe um nome, seguido de uma lista indentada de chaves/valores separados por dois pontos.
Registros são separados uns dos outros por uma linha em branco.
Você pode colocar comentários em uma arquivo *fixture* usando o caractere # na primeira coluna do texto.

Se você está trabalhando com [associações](/association_basics.html), você pode definir referências entre duas *fixtures* diferentes.
Aqui está um exemplo com uma associação `belongs_to`/`has_many`:

```yaml
# fixtures/categories.yml
about:
  name: About
```

```yaml
# fixtures/articles.yml
first:
  title: Welcome to Rails!
  body: Hello world!
  category: about
```

Veja que a chave de `category` do artigo `first` encontrado em `fixtures/articles.yml` tem o valor `about`.
Isso diz ao Rails para carregar a categoria `about` encontrada em `fixtures/categories.yml`.

NOTE: Para que associações façam referência umas as outras pelo nome, você pode usar o nome da *fixture* ao invés de especificar a chave `id:` nas *fixtures* associadas.
O Rails vai dar automaticamente uma chave para que haja consistência entre execuções dos testes.
Para mais informações sobre esse comportamento das associações, leia a página [documentação da API de Fixtures](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html).

#### ERBzando as Fixtures

A linguagem ERB permite que você coloque código Ruby dentro de templates.
As *fixtures* em formato YAML são pré-processadas com ERB antes do Rails carregar as *fixtures*.
Isso faz com que você possa usar Ruby para ajudar a gerar dados de teste.
Por exemplo, o código a seguir vai gerar mil usuários:

```erb
<% 1000.times do |n| %>
user_<%= n %>:
  username: <%= "user#{n}" %>
  email: <%= "user#{n}@example.com" %>
<% end %>
```

#### Fixtures em Ação

O Rails automaticamente carrega todas as *fixtures* dentro do diretório `test/fixtures` por padrão.
O carregamento envolve três passos:

1. Remover qualquer dado existente da tabela que corresponde a *fixture*
2. Carregar os dados da *fixture* na tabela
3. Copiar os dados da *fixture* para dentro de um método caso você queira acessá-los diretamente

TIP: Para remover todos os dados existentes, o Rails tenta desabilitar os *triggers* de integridade referencial (como chaves estrangeiras e *constraints*).
Se você estiver recebendo erros irritantes de permissão na hora de rodar os testes, garanta que o usuário do banco de dados tenha permissão para desabilitar esses *triggers* no ambiente de teste.
(No PostgreSQL, somente superusuários podem desativar todos os *triggers*.
Leia mais sobre as permissões do PostgreSQL [aqui](http://blog.endpoint.com/2012/10/postgres-system-triggers-error.html)).

#### Fixtures são objetos do Active Record

*Fixtures* são instâncias de Active Record.
Como mencionado no ponto #3 acima, você pode acessar o objeto diretamente, já que ele está automaticamente acessível como um método cujo escopo é local para cada teste.
Por exemplo:

```ruby
# isso retornará um objeto User para a fixture chamada david
users(:david)

# isso retornará a propriedade id de david
users(:david).id

# também é possível acessar os métodos disponíveis dentro de User
david = users(:david)
david.call(david.partner)
```

Para acessar várias *fixtures* de uma vez, você pode passar uma lista de nomes de *fixtures*.
Por exemplo:

```ruby
# isso retornará uma array contendo as fixtures david e steve
users(:david, :steve)
```

Testando *Models*
-----------------

Testes de *model* são usados para testar os vários *models* de sua aplicação.

Os testes de *model* do Rails estão localizados em `test/models`.
O Rails disponibiliza um gerador (*generator*) para criar esqueletos de testes de *model*.

```bash
$ bin/rails generate test_unit:model article title:string body:text
create  test/models/article_test.rb
create  test/fixtures/articles.yml
```

Testes de *model* não possuem uma superclasse como `ActionMailer::TestCase`.
Ao invés disso, eles herdam de [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html).

Fazendo Testes de Sistema
-------------------------

Testes de sistema permitem testar interações do usuário com sua aplicação, rodando os testes em um navegador web real ou *headless*.
Testes de sistema usam *Capybara* por debaixo dos panos.

Para criar testes de sistema do Rails, utilize o caminho `test/system` da sua aplicação.
O Rails também disponibiliza um *generator* para criar esqueletos de testes de sistema para você.

```bash
$ bin/rails generate system_test users
      invoke test_unit
      create test/system/users_test.rb
```

Aqui está como um teste de sistema recém gerado se parece:

```ruby
require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit users_url
  #
  #   assert_selector "h1", text: "Users"
  # end
end
```

Por padrão, testes de sistema utilizam o *driver* Selenium, executando o navegador Chrome, em uma tela de tamanho 1400x1400.
A próxima seção explica como mudar as configurações padrão.

### Mudando as Configurações Padrão

O Rails faz com que mudar as configurações padrão de testes de sistema seja muito simples.
Toda a preparação (*setup*) é abstraída, logo você pode focar mais em escrever testes.

Quando uma nova aplicação ou *scaffold* são gerados, o arquivo `application_system_test_case.rb` é criado na pasta de testes.
É nele em que todas as configurações de seus testes de sistema devem estão.

Se você quiser mudar as configurações padrão, você pode mudar quem "dirige" (*driver*) os testes de sistema.
Digamos que você quer mudar de Selenium para Poltergeist.
Primeiro adicione a gem `poltergeist` em seu `Gemfile`.
Depois, em seu `application_system_test_case.rb`, faça o seguinte:

```ruby
require "test_helper"
require "capybara/poltergeist"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :poltergeist
end
```

O nome do *driver* é um argumento obrigatório de `driven_by`.
Os argumentos opcionais que podem ser passados para `driven_by` são `:using` para o navegador web (opção usada somente pelo *driver* Selenium), `:screen_size` para mudar o tamanho da tela e das capturas de tela e `:options` que serve para configurações específicas de cada *driver*.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :firefox
end
```

Se você quiser usar um navegador *headless*, você pode usar o Chrome *headless* ou Firefox *headless* passando `headless_chrome` ou `headless_firefox` para o argumento `:using`.

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
```

Se a sua configuração do Capybara requer mais customização do que as fornecidas pelo Rails, opções adicionais podem ser adicionadas no arquivo `application_system_test_case.rb`.

Consulte a [documentação do Capybara](https://github.com/teamcapybara/capybara#setup) para configurações adicionais.

### *Helper* de capturas de tela

O módulo `ScreenshotHelper` é um *helper* feito para fazer capturas de tela ("prints") dos seus testes.
Isso pode ser útil para ver o navegador web no momento em que um teste falha ou para debug.

Dois métodos são disponibilizados: `take_screenshot` e `take_failed_screenshot`.
No Rails, o método `take_failed_screenshot` é automaticamente incluído em `before_teardown`.

O *helper* `take_screenshot` pode ser chamado em qualquer lugar nos seus testes para fazer uma captura de tela do navegador.

### Implementando um Teste de Sistema

Agora vamos adicionar um teste de sistema em nossa aplicação de blog.
Vamos demonstrar como escrever testes de sistema, através da visita a página inicial da aplicação e da escrita de um novo artigo de blog.

Se você tive usado o *generator* de *scaffold*, então o esqueleto de um teste de sistema foi automaticamente criado para você.
Se você não utilizou o *generator* de *scaffold*, comece criando o esqueleto de um teste de sistema.

```bash
$ bin/rails generate system_test articles
```

Isso deveria criar um arquivo de teste.
Se você utilizou o comando anterior, você deveria ver a seguinte saída:

```
      invoke  test_unit
      create    test/system/articles_test.rb
```

Agora vamos abrir o arquivo e escrever nossa primeira asserção:

```ruby
require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  test "viewing the index" do
    visit articles_path
    assert_selector "h1", text: "Articles"
  end
end
```

O teste deveria localizar que há um elemento `h1` na página inicial (*index*) de *articles* e passar.

Rode os testes de sistema.

```bash
$ bin/rails test:system
```

NOTE: Por padrão, rodar `bin/rails test` não irá rodar seus testes de sistema.
Certifique-se de rodar `bin/rails test:system` para que eles sejam executados.
Você também pode executar `bin/rails test:all` para rodar todos os testes, incluindo os de sistema.

#### Criando um Teste de Sistema de Artigos

Agora vamos testar o fluxo de criação de um novo artigo para o nosso blog.

```ruby
test "creating an article" do
  visit articles_path

  click_on "New Article"

  fill_in "Title", with: "Creating an Article"
  fill_in "Body", with: "Created this article successfully!"

  click_on "Create Article"

  assert_text "Creating an Article"
end
```

O primeiro passo é chamar `visit articles_path`.
Isso faz com que o teste acesse a página inicial (*index*) de *articles*.

Depois a instrução `click_on "New Article"` vai achar o botão "New Article" na página inicial (*index*).
Isso vai redirecionar o navegador para `/articles/new`.

Após isso, o teste vai preencher o título (*title*) e o corpo (*body*) do artigo com o texto especificado.
Uma vez que os campos estão preenchidos, clica-se em "Create Article", que irá mandar uma requisição POST para criar o artigo no banco de dados.

Finalmente, nós vamos ser redirecionados de volta para a página inicial (*index*) e lá vamos assertar que o texto do título de nosso novo artigo está presente na página inicial.

#### Testando em diferentes tamanhos de tela

Se você quiser testar em telas de tamanho mobile além do tamanho desktop, você pode criar outra classe que herda de `SystemTestCase` para usar em sua suite de testes.
Nesse exemplo, um arquivo chamado `mobile_system_test_case.rb` foi criado no caminho `/test` com a seguinte configuração:

```ruby
require "test_helper"

class MobileSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [375, 667]
end
```

Para usar essa configuração, crie um teste dentro de `test/system` que herda de `MobileSystemTestCase`.
Agora você pode testar seu app com diferentes configurações de tela.

```ruby
require "mobile_system_test_case"

class PostsTest < MobileSystemTestCase

  test "visiting the index" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end
end
```

#### Indo Além

A beleza dos testes de sistema é que, parecido com os testes de integração, eles também testam a interação do usuário com o *controller*, *model* e a *view*.
Porém, o teste de sistema é muito mais robusto e testa a aplicação como se uma pessoa de verdade estivesse usando.
Indo além, você pode testar qualquer coisa que os próprios usuários fariam em sua aplicação, como comentar, deletar artigos, publicar rascunhos e etc.

Integration Testing
-------------------

Integration tests are used to test how various parts of our application interact. They are generally used to test important workflows within our application.

For creating Rails integration tests, we use the `test/integration` directory for our application. Rails provides a generator to create an integration test skeleton for us.

```bash
$ bin/rails generate integration_test user_flows
      exists  test/integration/
      create  test/integration/user_flows_test.rb
```

Here's what a freshly generated integration test looks like:

```ruby
require "test_helper"

class UserFlowsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
end
```

Here the test is inheriting from `ActionDispatch::IntegrationTest`. This makes some additional helpers available for us to use in our integration tests.

### Helpers Available for Integration Tests

In addition to the standard testing helpers, inheriting from `ActionDispatch::IntegrationTest` comes with some additional helpers available when writing integration tests. Let's get briefly introduced to the three categories of helpers we get to choose from.

For dealing with the integration test runner, see [`ActionDispatch::Integration::Runner`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Runner.html).

When performing requests, we will have [`ActionDispatch::Integration::RequestHelpers`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/RequestHelpers.html) available for our use.

If we need to modify the session, or state of our integration test, take a look at [`ActionDispatch::Integration::Session`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Session.html) to help.

### Implementing an integration test

Let's add an integration test to our blog application. We'll start with a basic workflow of creating a new blog article, to verify that everything is working properly.

We'll start by generating our integration test skeleton:

```bash
$ bin/rails generate integration_test blog_flow
```

It should have created a test file placeholder for us. With the output of the
previous command we should see:

```
      invoke  test_unit
      create    test/integration/blog_flow_test.rb
```

Now let's open that file and write our first assertion:

```ruby
require "test_helper"

class BlogFlowTest < ActionDispatch::IntegrationTest
  test "can see the welcome page" do
    get "/"
    assert_select "h1", "Welcome#index"
  end
end
```

We will take a look at `assert_select` to query the resulting HTML of a request in the "Testing Views" section below. It is used for testing the response of our request by asserting the presence of key HTML elements and their content.

When we visit our root path, we should see `welcome/index.html.erb` rendered for the view. So this assertion should pass.

#### Creating articles integration

How about testing our ability to create a new article in our blog and see the resulting article.

```ruby
test "can create an article" do
  get "/articles/new"
  assert_response :success

  post "/articles",
    params: { article: { title: "can create", body: "article successfully." } }
  assert_response :redirect
  follow_redirect!
  assert_response :success
  assert_select "p", "Title:\n  can create"
end
```

Let's break this test down so we can understand it.

We start by calling the `:new` action on our Articles controller. This response should be successful.

After this we make a post request to the `:create` action of our Articles controller:

```ruby
post "/articles",
  params: { article: { title: "can create", body: "article successfully." } }
assert_response :redirect
follow_redirect!
```

The two lines following the request are to handle the redirect we setup when creating a new article.

NOTE: Don't forget to call `follow_redirect!` if you plan to make subsequent requests after a redirect is made.

Finally we can assert that our response was successful and our new article is readable on the page.

#### Taking it further

We were able to successfully test a very small workflow for visiting our blog and creating a new article. If we wanted to take this further we could add tests for commenting, removing articles, or editing comments. Integration tests are a great place to experiment with all kinds of use cases for our applications.


Functional Tests for Your Controllers
-------------------------------------

In Rails, testing the various actions of a controller is a form of writing functional tests. Remember your controllers handle the incoming web requests to your application and eventually respond with a rendered view. When writing functional tests, you are testing how your actions handle the requests and the expected result or response, in some cases an HTML view.

### What to include in your Functional Tests

You should test for things such as:

* was the web request successful?
* was the user redirected to the right page?
* was the user successfully authenticated?
* was the appropriate message displayed to the user in the view?
* was the correct information displayed in the response?

The easiest way to see functional tests in action is to generate a controller using the scaffold generator:

```bash
$ bin/rails generate scaffold_controller article title:string body:text
...
create  app/controllers/articles_controller.rb
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

This will generate the controller code and tests for an `Article` resource.
You can take a look at the file `articles_controller_test.rb` in the `test/controllers` directory.

If you already have a controller and just want to generate the test scaffold code for
each of the seven default actions, you can use the following command:

```bash
$ bin/rails generate test_unit:scaffold article
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

Let's take a look at one such test, `test_should_get_index` from the file `articles_controller_test.rb`.

```ruby
# articles_controller_test.rb
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url
    assert_response :success
  end
end
```

In the `test_should_get_index` test, Rails simulates a request on the action called `index`, making sure the request was successful
and also ensuring that the right response body has been generated.

The `get` method kicks off the web request and populates the results into the `@response`. It can accept up to 6 arguments:

* The URI of the controller action you are requesting.
  This can be in the form of a string or a route helper (e.g. `articles_url`).
* `params`: option with a hash of request parameters to pass into the action
  (e.g. query string parameters or article variables).
* `headers`: for setting the headers that will be passed with the request.
* `env`: for customizing the request environment as needed.
* `xhr`: whether the request is Ajax request or not. Can be set to true for marking the request as Ajax.
* `as`: for encoding the request with different content type.

All of these keyword arguments are optional.

Example: Calling the `:show` action for the first `Article`, passing in an `HTTP_REFERER` header:

```ruby
get article_url(Article.first), headers: { "HTTP_REFERER" => "http://example.com/home" }
```

Another example: Calling the `:update` action for the last `Article`, passing in new text for the `title` in `params`, as an Ajax request:

```ruby
patch article_url(Article.last), params: { article: { title: "updated" } }, xhr: true
```

One more example: Calling the `:create` action to create a new article, passing in
text for the `title` in `params`, as JSON request:

```ruby
post articles_path, params: { article: { title: "Ahoy!" } }, as: :json
```

NOTE: If you try running `test_should_create_article` test from `articles_controller_test.rb` it will fail on account of the newly added model level validation and rightly so.

Let us modify `test_should_create_article` test in `articles_controller_test.rb` so that all our test pass:

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { body: "Rails is awesome!", title: "Hello Rails" } }
  end

  assert_redirected_to article_path(Article.last)
end
```

Now you can try running all the tests and they should pass.

NOTE: If you followed the steps in the [Basic Authentication](getting_started.html#basic-authentication) section, you'll need to add authorization to every request header to get all the tests passing:

```ruby
post articles_url, params: { article: { body: "Rails is awesome!", title: "Hello Rails" } }, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("dhh", "secret") }
```

### Available Request Types for Functional Tests

If you're familiar with the HTTP protocol, you'll know that `get` is a type of request. There are 6 request types supported in Rails functional tests:

* `get`
* `post`
* `patch`
* `put`
* `head`
* `delete`

All of request types have equivalent methods that you can use. In a typical C.R.U.D. application you'll be using `get`, `post`, `put`, and `delete` more often.

NOTE: Functional tests do not verify whether the specified request type is accepted by the action, we're more concerned with the result. Request tests exist for this use case to make your tests more purposeful.

### Testing XHR (AJAX) requests

To test AJAX requests, you can specify the `xhr: true` option to `get`, `post`,
`patch`, `put`, and `delete` methods. For example:

```ruby
test "ajax request" do
  article = articles(:one)
  get article_url(article), xhr: true

  assert_equal "hello world", @response.body
  assert_equal "text/javascript", @response.media_type
end
```

### The Three Hashes of the Apocalypse

After a request has been made and processed, you will have 3 Hash objects ready for use:

* `cookies` - Any cookies that are set
* `flash` - Any objects living in the flash
* `session` - Any object living in session variables

As is the case with normal Hash objects, you can access the values by referencing the keys by string. You can also reference them by symbol name. For example:

```ruby
flash["gordon"]               flash[:gordon]
session["shmession"]          session[:shmession]
cookies["are_good_for_u"]     cookies[:are_good_for_u]
```

### Instance Variables Available

You also have access to three instance variables in your functional tests, after a request is made:

* `@controller` - The controller processing the request
* `@request` - The request object
* `@response` - The response object


```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url

    assert_equal "index", @controller.action_name
    assert_equal "application/x-www-form-urlencoded", @request.media_type
    assert_match "Articles", @response.body
  end
end
```

### Setting Headers and CGI variables

[HTTP headers](https://tools.ietf.org/search/rfc2616#section-5.3)
and
[CGI variables](https://tools.ietf.org/search/rfc3875#section-4.1)
can be passed as headers:

```ruby
# setting an HTTP Header
get articles_url, headers: { "Content-Type": "text/plain" } # simulate the request with custom header

# setting a CGI variable
get articles_url, headers: { "HTTP_REFERER": "http://example.com/home" } # simulate the request with custom env variable
```

### Testing `flash` notices

If you remember from earlier, one of the Three Hashes of the Apocalypse was `flash`.

We want to add a `flash` message to our blog application whenever someone
successfully creates a new Article.

Let's start by adding this assertion to our `test_should_create_article` test:

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { title: "Some title" } }
  end

  assert_redirected_to article_path(Article.last)
  assert_equal "Article was successfully created.", flash[:notice]
end
```

If we run our test now, we should see a failure:

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 32266

# Running:

F

Finished in 0.114870s, 8.7055 runs/s, 34.8220 assertions/s.

  1) Failure:
ArticlesControllerTest#test_should_create_article [/test/controllers/articles_controller_test.rb:16]:
--- expected
+++ actual
@@ -1 +1 @@
-"Article was successfully created."
+nil

1 runs, 4 assertions, 1 failures, 0 errors, 0 skips
```

Let's implement the flash message now in our controller. Our `:create` action should now look like this:

```ruby
def create
  @article = Article.new(article_params)

  if @article.save
    flash[:notice] = "Article was successfully created."
    redirect_to @article
  else
    render "new"
  end
end
```

Now if we run our tests, we should see it pass:

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 18981

# Running:

.

Finished in 0.081972s, 12.1993 runs/s, 48.7972 assertions/s.

1 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### Putting it together

At this point our Articles controller tests the `:index` as well as `:new` and `:create` actions. What about dealing with existing data?

Let's write a test for the `:show` action:

```ruby
test "should show article" do
  article = articles(:one)
  get article_url(article)
  assert_response :success
end
```

Remember from our discussion earlier on fixtures, the `articles()` method will give us access to our Articles fixtures.

How about deleting an existing Article?

```ruby
test "should destroy article" do
  article = articles(:one)
  assert_difference("Article.count", -1) do
    delete article_url(article)
  end

  assert_redirected_to articles_path
end
```

We can also add a test for updating an existing Article.

```ruby
test "should update article" do
  article = articles(:one)

  patch article_url(article), params: { article: { title: "updated" } }

  assert_redirected_to article_path(article)
  # Reload association to fetch updated data and assert that title is updated.
  article.reload
  assert_equal "updated", article.title
end
```

Notice we're starting to see some duplication in these three tests, they both access the same Article fixture data. We can D.R.Y. this up by using the `setup` and `teardown` methods provided by `ActiveSupport::Callbacks`.

Our test should now look something as what follows. Disregard the other tests for now, we're leaving them out for brevity.

```ruby
require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  # called before every single test
  setup do
    @article = articles(:one)
  end

  # called after every single test
  teardown do
    # when controller is using cache it may be a good idea to reset it afterwards
    Rails.cache.clear
  end

  test "should show article" do
    # Reuse the @article instance variable from setup
    get article_url(@article)
    assert_response :success
  end

  test "should destroy article" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_path
  end

  test "should update article" do
    patch article_url(@article), params: { article: { title: "updated" } }

    assert_redirected_to article_path(@article)
    # Reload association to fetch updated data and assert that title is updated.
    @article.reload
    assert_equal "updated", @article.title
  end
end
```

Similar to other callbacks in Rails, the `setup` and `teardown` methods can also be used by passing a block, lambda, or method name as a symbol to call.

### Test helpers

To avoid code duplication, you can add your own test helpers.
Sign in helper can be a good example:

```ruby
# test/test_helper.rb

module SignInHelper
  def sign_in_as(user)
    post sign_in_url(email: user.email, password: user.password)
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

```ruby
require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest

  test "should show profile" do
    # helper is now reusable from any controller test case
    sign_in_as users(:david)

    get profile_url
    assert_response :success
  end
end
```

#### Using Separate Files

If you find your helpers are cluttering `test_helper.rb`, you can extract them into separate files.
One good place to store them is `test/lib` or `test/test_helpers`.

```ruby
# test/test_helpers/multiple_assertions.rb
module MultipleAssertions
  def assert_multiple_of_forty_two(number)
    assert (number % 42 == 0), 'expected #{number} to be a multiple of 42'
  end
end
```

These helpers can then be explicitly required as needed and included as needed

```ruby
require "test_helper"
require "test_helpers/multiple_assertions"

class NumberTest < ActiveSupport::TestCase
  include MultipleAssertions

  test "420 is a multiple of forty two" do
    assert_multiple_of_forty_two 420
  end
end
```

or they can continue to be included directly into the relevant parent classes

```ruby
# test/test_helper.rb
require "test_helpers/sign_in_helper"

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

#### Eagerly Requiring Helpers

You may find it convenient to eagerly require helpers in `test_helper.rb` so your test files have implicit access to them. This can be accomplished using globbing, as follows

```ruby
# test/test_helper.rb
Dir[Rails.root.join("test", "test_helpers", "**", "*.rb")].each { |file| require file }
```

This has the downside of increasing the boot-up time, as opposed to manually requiring only the necessary files in your individual tests.

Testando Rotas
--------------

Assim como tudo na sua aplicação Rails, você também pode testar suas rotas.
Testes de rotas são encontrados na pasta `test/controllers/` ou podem fazer parte de seus testes de *controller*.

NOTE: Se sua aplicação tem rotas muito complexas, o Rails fornece vários *helpers* úteis para testá-las.

Para mais informações sobre as asserções de rotas disponíveis no Rails, veja a documentação da API de [`ActionDispatch::Assertions::RoutingAssertions`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html).

Testando *Views*
----------------

Testar a resposta de sua requisição através da presença de elementos HTML chave e o seu conteúdo é uma forma comum de testar as *views* de sua aplicação. Assim como os testes de rota, testes de *view* ficam em `test/controllers/` ou são parte dos seus testes de *controller*.

O método `assert_select` permite que você faça consultas a elementos HTML da resposta, através de uma sintaxe simples, mas poderosa.

Há duas formas de `assert_select`:

A assinatura `assert_select(selector, [equality], [message])` garante que a condição de igualdade (`equality`) é atendida nos elementos selecionados através do seletor (*selector*).
O argumento *selector* pode ser um seletor CSS (String) ou uma expressão com valores de substituição (como [nesses testes](https://github.com/rails/rails-dom-testing/blob/8f5acdfcb83a888c06592bad05475b7463998d1b/test/selector_assertions_test.rb#L124-L146)).

Já `assert_select(element, selector, [equality], [message])` garante que a condição de igualdade (`equality`) é atendida nos elementos selecionados através do seletor, começando no elemento `element` (instância de `Nokogiri::XML::Node` ou `Nokogiri::XML::NodeSet`) e seus descendentes.

Por exemplo, você poderia verificar o conteúdo do elemento `title` na sua resposta com:

```ruby
assert_select "title", "Welcome to Rails Testing Guide"
```

Você também pode usar blocos aninhados de `assert_select` para uma investigação mais profunda.

No exemplo a seguir, o `assert_select` mais interno de `li.menu_item` executa com a coleção de elementos selecionados pelo bloco mais externo:

```ruby
assert_select "ul.navigation" do
  assert_select "li.menu_item"
end
```

Uma coleção de elementos pode ser iterada para que `assert_select` possa ser chamado individualmente para cada elemento.

Por exemplo, se a resposta contiver duas listas ordenadas, cada uma com quatro elementos, então os testes a seguir irão passar.

```ruby
assert_select "ol" do |elements|
  elements.each do |element|
    assert_select element, "li", 4
  end
end

assert_select "ol" do
  assert_select "li", 8
end
```

Essa asserção é bastante poderosa. Para usos mais avançados, veja a sua [documentação](https://github.com/rails/rails-dom-testing/blob/master/lib/rails/dom/testing/assertions/selector_assertions.rb).

#### Asserções Adicionais para *Views*

Existem mais asserções que são usadas primariamente em testes de *views*:

| Asserção                                                  | Propósito |
| --------------------------------------------------------- | --------- |
| `assert_select_email`                                     | Permite fazer asserções no corpo de um email. |
| `assert_select_encoded`                                   | Permite fazer asserções em HTML codificado. Isso é feito decodificando os conteúdos de cada elemento e então chamando o bloco com todos os elementos decodificados. |
| `css_select(selector)` ou `css_select(element, selector)` | Retorna uma *array* de todos os elementos selecionados por *selector*. Na segunda variante, o método primeiro seleciona o elemento base `element` e depois tenta selecionar os descendentes de `element` através de `selector`. Se não houver nenhum match, ambas variantes retornam *array* vazia. |

Aqui está um exemplo do uso de `assert_selected_email`:

```ruby
assert_select_email do
  assert_select "small", "Please click the 'Unsubscribe' link if you want to opt-out."
end
```

Testando os *Helpers*
---------------

Um *helper* é apenas um simples módulo onde você pode definir métodos
que estarão disponíveis nas suas *views*.

Para testar os *helpers*, tudo que você precisa fazer é verificar se a saída do
método *helper* é de fato a saída esperada. Testes relacionados aos *helpers* estão
localizados dentro da pasta `test/helpers`.

Dado o seguinte *helper*:

```ruby
module UsersHelper
  def link_to_user(user)
    link_to "#{user.first_name} #{user.last_name}", user
  end
end
```

Nós podemos testar a saída desse método da seguinte maneira:

```ruby
class UsersHelperTest < ActionView::TestCase
  test "should return the user's full name" do
    user = users(:david)

    assert_dom_equal %{<a href="/user/#{user.id}">David Heinemeier Hansson</a>}, link_to_user(user)
  end
end
```

Além disso, uma vez que a classe de teste se estende de `ActionView::TestCase`, você tem
acesso aos métodos auxiliares do Rails como `link_to` ou` pluralize`.

Testing Your Mailers
--------------------

Testing mailer classes requires some specific tools to do a thorough job.

### Keeping the Postman in Check

Your mailer classes - like every other part of your Rails application - should be tested to ensure that they are working as expected.

The goals of testing your mailer classes are to ensure that:

* emails are being processed (created and sent)
* the email content is correct (subject, sender, body, etc)
* the right emails are being sent at the right times

#### From All Sides

There are two aspects of testing your mailer, the unit tests and the functional tests. In the unit tests, you run the mailer in isolation with tightly controlled inputs and compare the output to a known value (a fixture). In the functional tests you don't so much test the minute details produced by the mailer; instead, we test that our controllers and models are using the mailer in the right way. You test to prove that the right email was sent at the right time.

### Unit Testing

In order to test that your mailer is working as expected, you can use unit tests to compare the actual results of the mailer with pre-written examples of what should be produced.

#### Revenge of the Fixtures

For the purposes of unit testing a mailer, fixtures are used to provide an example of how the output _should_ look. Because these are example emails, and not Active Record data like the other fixtures, they are kept in their own subdirectory apart from the other fixtures. The name of the directory within `test/fixtures` directly corresponds to the name of the mailer. So, for a mailer named `UserMailer`, the fixtures should reside in `test/fixtures/user_mailer` directory.

If you generated your mailer, the generator does not create stub fixtures for the mailers actions. You'll have to create those files yourself as described above.

#### The Basic Test Case

Here's a unit test to test a mailer named `UserMailer` whose action `invite` is used to send an invitation to a friend. It is an adapted version of the base test created by the generator for an `invite` action.

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # Create the email and store it for further assertions
    email = UserMailer.create_invite("me@example.com",
                                     "friend@example.com", Time.now)

    # Send the email, then test that it got queued
    assert_emails 1 do
      email.deliver_now
    end

    # Test the body of the sent email contains what we expect it to
    assert_equal ["me@example.com"], email.from
    assert_equal ["friend@example.com"], email.to
    assert_equal "You have been invited by me@example.com", email.subject
    assert_equal read_fixture("invite").join, email.body.to_s
  end
end
```

In the test we create the email and store the returned object in the `email`
variable. We then ensure that it was sent (the first assert), then, in the
second batch of assertions, we ensure that the email does indeed contain what we
expect. The helper `read_fixture` is used to read in the content from this file.

NOTE: `email.body.to_s` is present when there's only one (HTML or text) part present.
If the mailer provides both, you can test your fixture against specific parts
with `email.text_part.body.to_s` or `email.html_part.body.to_s`.

Here's the content of the `invite` fixture:

```
Hi friend@example.com,

You have been invited.

Cheers!
```

This is the right time to understand a little more about writing tests for your
mailers. The line `ActionMailer::Base.delivery_method = :test` in
`config/environments/test.rb` sets the delivery method to test mode so that
email will not actually be delivered (useful to avoid spamming your users while
testing) but instead it will be appended to an array
(`ActionMailer::Base.deliveries`).

NOTE: The `ActionMailer::Base.deliveries` array is only reset automatically in
`ActionMailer::TestCase` and `ActionDispatch::IntegrationTest` tests.
If you want to have a clean slate outside these test cases, you can reset it
manually with: `ActionMailer::Base.deliveries.clear`

### Functional and System Testing

Unit testing allows us to test the attributes of the email while functional and system testing allows us to test whether user interactions appropriately trigger the email to be delivered. For example, you can check that the invite friend operation is sending an email appropriately:

```ruby
# Integration Test
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "invite friend" do
    # Asserts the difference in the ActionMailer::Base.deliveries
    assert_emails 1 do
      post invite_friend_url, params: { email: "friend@example.com" }
    end
  end
end
```

```ruby
# System Test
require "test_helper"

class UsersTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome

  test "inviting a friend" do
    visit invite_users_url
    fill_in "Email", with: "friend@example.com"
    assert_emails 1 do
      click_on "Invite"
    end
  end
end
```

NOTE: The `assert_emails` method is not tied to a particular deliver method and will work with emails delivered with either the `deliver_now` or `deliver_later` method. If we explicitly want to assert that the email has been enqueued we can use the `assert_enqueued_emails` method. More information can be found in the  [documentation here](https://api.rubyonrails.org/classes/ActionMailer/TestHelper.html).

Testing Jobs
------------

Since your custom jobs can be queued at different levels inside your application,
you'll need to test both the jobs themselves (their behavior when they get enqueued)
and that other entities correctly enqueue them.

### A Basic Test Case

By default, when you generate a job, an associated test will be generated as well
under the `test/jobs` directory. Here's an example test with a billing job:

```ruby
require "test_helper"

class BillingJobTest < ActiveJob::TestCase
  test "that account is charged" do
    BillingJob.perform_now(account, product)
    assert account.reload.charged_for?(product)
  end
end
```

This test is pretty simple and only asserts that the job got the work done
as expected.

By default, `ActiveJob::TestCase` will set the queue adapter to `:test` so that
your jobs are performed inline. It will also ensure that all previously performed
and enqueued jobs are cleared before any test run so you can safely assume that
no jobs have already been executed in the scope of each test.

### Custom Assertions and Testing Jobs inside Other Components

Active Job ships with a bunch of custom assertions that can be used to lessen the verbosity of tests. For a full list of available assertions, see the API documentation for [`ActiveJob::TestHelper`](https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html).

It's a good practice to ensure that your jobs correctly get enqueued or performed
wherever you invoke them (e.g. inside your controllers). This is precisely where
the custom assertions provided by Active Job are pretty useful. For instance,
within a model:

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "billing job scheduling" do
    assert_enqueued_with(job: BillingJob) do
      product.charge(account)
    end
  end
end
```

Testing Action Cable
--------------------

Since Action Cable is used at different levels inside your application,
you'll need to test both the channels, connection classes themselves, and that other
entities broadcast correct messages.

### Connection Test Case

By default, when you generate new Rails application with Action Cable, a test for the base connection class (`ApplicationCable::Connection`) is generated as well under `test/channels/application_cable` directory.

Connection tests aim to check whether a connection's identifiers get assigned properly
or that any improper connection requests are rejected. Here is an example:

```ruby
class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "connects with params" do
    # Simulate a connection opening by calling the `connect` method
    connect params: { user_id: 42 }

    # You can access the Connection object via `connection` in tests
    assert_equal connection.user_id, "42"
  end

  test "rejects connection without params" do
    # Use `assert_reject_connection` matcher to verify that
    # connection is rejected
    assert_reject_connection { connect }
  end
end
```

You can also specify request cookies the same way you do in integration tests:

```ruby
test "connects with cookies" do
  cookies.signed[:user_id] = "42"

  connect

  assert_equal connection.user_id, "42"
end
```

See the API documentation for [`ActionCable::Connection::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Connection/TestCase.html) for more information.

### Channel Test Case

By default, when you generate a channel, an associated test will be generated as well
under the `test/channels` directory. Here's an example test with a chat channel:

```ruby
require "test_helper"

class ChatChannelTest < ActionCable::Channel::TestCase
  test "subscribes and stream for room" do
    # Simulate a subscription creation by calling `subscribe`
    subscribe room: "15"

    # You can access the Channel object via `subscription` in tests
    assert subscription.confirmed?
    assert_has_stream "chat_15"
  end
end
```

This test is pretty simple and only asserts that the channel subscribes the connection to a particular stream.

You can also specify the underlying connection identifiers. Here's an example test with a web notifications channel:

```ruby
require "test_helper"

class WebNotificationsChannelTest < ActionCable::Channel::TestCase
  test "subscribes and stream for user" do
    stub_connection current_user: users(:john)

    subscribe

    assert_has_stream_for users(:john)
  end
end
```

See the API documentation for [`ActionCable::Channel::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Channel/TestCase.html) for more information.

### Custom Assertions And Testing Broadcasts Inside Other Components

Action Cable ships with a bunch of custom assertions that can be used to lessen the verbosity of tests. For a full list of available assertions, see the API documentation for [`ActionCable::TestHelper`](https://api.rubyonrails.org/classes/ActionCable/TestHelper.html).

It's a good practice to ensure that the correct message has been broadcasted inside other components (e.g. inside your controllers). This is precisely where
the custom assertions provided by Action Cable are pretty useful. For instance,
within a model:

```ruby
require "test_helper"

class ProductTest < ActionCable::TestCase
  test "broadcast status after charge" do
    assert_broadcast_on("products:#{product.id}", type: "charged") do
      product.charge(account)
    end
  end
end
```

If you want to test the broadcasting made with `Channel.broadcast_to`, you should use
`Channel.broadcasting_for` to generate an underlying stream name:

```ruby
# app/jobs/chat_relay_job.rb
class ChatRelayJob < ApplicationJob
  def perform_later(room, message)
    ChatChannel.broadcast_to room, text: message
  end
end
```

```ruby
# test/jobs/chat_relay_job_test.rb
require "test_helper"

class ChatRelayJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test "broadcast message to room" do
    room = rooms(:all)

    assert_broadcast_on(ChatChannel.broadcasting_for(room), text: "Hi!") do
      ChatRelayJob.perform_now(room, "Hi!")
    end
  end
end
```

Recursos Adicionais para Testes
----------------------------

### Testando Código Dependente de Data/Horário

O Rails fornece métodos *helpers* integrados que permitem que você verifique que seu código dependente de data ou hora funcione conforme o esperado.

Aqui está um exemplo utilizando o *helper* [`travel_to`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel_to):

```ruby
# Digamos que um usuário só poderá enviar presentes após um mês do seu registro.
user = User.create(name: "Gaurish", activation_date: Date.new(2004, 10, 24))
assert_not user.applicable_for_gifting?
travel_to Date.new(2004, 11, 24) do
  assert_equal Date.new(2004, 10, 24), user.activation_date # dentro do bloco `travel_to` é feito o mock de `Date.current` 
  assert user.applicable_for_gifting?
end
assert_equal Date.new(2004, 10, 24), user.activation_date # A mudança é visível somente dentro do bloco `travel_to`.
```

Por favor consulte a [Documentação da API `ActiveSupport::Testing::TimeHelpers`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html) para obter informações detalhadas sobre os *helpers* de tempo disponíveis.
