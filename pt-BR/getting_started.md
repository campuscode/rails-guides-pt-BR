**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Começando com Rails
===================

Este guia aborda a instalação e a execução do Ruby on Rails.

Depois de ler este guia, você vai saber:

* Como instalar o Rails, criar uma nova aplicação Rails e conectar sua
  aplicação com um banco de dados.
* A estrutura geral de uma aplicação Rails.
* Os princípios básicos do MVC (**Model**, **View**, **Controller**) e design **RESTful**.
* Como gerar rapidamente as peças iniciais de uma aplicação Rails.

--------------------------------------------------------------------------------

Premissas do Guia
-----------------

Este guia é projetado para iniciantes que desejam começar uma aplicação Rails do
zero. Ele não assume que você tenha nenhuma experiência anterior com Rails.

O Rails é um _framework_ para aplicações web que é executado em cima da linguagem
de programação Ruby. Se você não tem nenhuma experiência com Ruby, você vai
achar a curva de aprendizado bastante íngrime começando direto com Rails.
Existem diversas listas organizadas de materiais online para aprender Ruby:

* [Site Oficial da Linguagem de Programação Ruby (Em inglês)](https://www.ruby-lang.org/en/documentation/)
* [Lista de Livros Grátis de Programação (Em inglês)](https://github.com/EbookFoundation/free-programming-books/blob/master/books/free-programming-books.md#ruby)

Fique atento que alguns materiais, apesar de excelentes, envolvem versões antigas
do Ruby e podem não incluir parte da sintaxe que você
vai ver no seu dia-a-dia desenvolvendo com Rails.

O que é o Rails?
--------------

Rails é um *framework* de desenvolvimento de aplicações *web* escrito na linguagem de programação Ruby.
Foi projetado para facilitar o desenvolvimento de aplicações *web*, criando premissas sobre tudo que uma pessoa desenvolvedora precisa para começar. Permite que você escreva menos código, enquanto realiza mais do que em muitas outras linguagens ou *frameworks.* Pessoas desenvolvedoras experientes em Rails, também dizem que desenvolver aplicações web ficou mais divertido.

Rails é um software opinativo. Assumindo que há uma "melhor" maneira para fazer as coisas, e foi projetado para encorajar essa maneira - e, em alguns casos para desencorajar alternativas. Se você aprender o "Rails Way", provavelmente terá um grande aumento de produtividade. Se você insistir nos velhos hábitos de outras linguagens, tentando usar os padrões que você aprendeu em outro lugar, você pode ter uma experiência menos feliz.

A filosofia do Rails possui dois princípios fundamentais:

* **Não repita a si mesmo:** DRY (don't repeat yourself) é um conceito de desenvolvimento de software que estabelece que "Todo conhecimento deve possuir uma representação única, de autoridade e livre de ambiguidades em todo o sistema". Ao não escrever as mesmas informações repetidamente, o código fica mais fácil de manter, de expandir e com menos _bugs_.
* **Convenção sobre configuração:** O Rails possui convenções sobre as melhores maneiras de fazer muitas coisas em uma aplicação web, devido a essas convenções você não precisa especificar detalhes através de arquivos de configuração infinitos.


Criando um Novo Projeto em Rails
---------------------------------

A melhor forma de ler esse guia é seguir o passo à passo. Todos os passos são
essenciais para rodar a aplicação de exemplo e nenhum código ou passos adicionais
serão necessários.

Seguindo este guia, você irá criar um projeto em *Rails* chamado de
`blog`, um *weblog* (muito) simples. Antes de você começar a construir a aplicação,
você precisa ter certeza de ter o *Rails* instalado.

NOTE: Os exemplos à seguir usam `$` para representar seu *prompt* de terminal em um
sistema operacional baseado em UNIX, mesmo que ele tenha sido customizado para parecer diferente.
Se você está utilizando Windows, seu *prompt* será parecido com algo como `C:\source_code>`.

### Instalando o Rails

Antes de você instalar o Rails, você deve validar para ter certeza que seu sistema
tem os pré requisitos necessários instalados. Esses incluem:

* Ruby 
* SQLite3
* Node.js
* Yarn

#### Instalando o Ruby

Abra o *prompt* de linha de comando. No *macOS* abra o *Terminal.app*; no *Windows*
escolha "Executar" no menu inicial e digite `cmd.exe`. Qualquer comando que antecede
o sinal de dólar `$` deverá ser rodado em linha de comando. Verifique se você tem a
versão atual do Ruby instalado:

```bash
$ ruby --version
ruby 2.5.0
```

O Rails necessita da versão Ruby 2.5.0 ou mais atual. Se o número da versão retornada
for menor que este número (como 2.3.7, e 1.8.7), você precisará instalar uma versão do Ruby mais atual.

Para instalar o Rails no Windows, você primeiro tem que instalar o [Ruby Installer](https://rubyinstaller.org). 

Para mais informações de instalação
de outros Sistemas Operacionais, dê uma olhada em [ruby-lang.org](https://www.ruby-lang.org/en/documentation/installation/).

#### Instalando o SQLite3

Você também precisará instalar o banco de dados SQLite3.
Muitos sistemas operacionais populares semelhantes ao UNIX são fornecidos com uma versão compatível do SQLite3.
Em outros sistemas você pode achar mais instruções de instalação em [SQLite3 website](https://www.sqlite.org).
Verifique se está corretamente instalado e carregado no seu `PATH`:

```bash
$ sqlite3 --version
```

O programa deverá reportar sua versão.

#### Instalando o Node.js e Yarn

Por fim, você precisará do Node.js e o Yarn instalados para gerenciar o JavaScript da sua aplicação.

Encontre as instruções de instalação no [site do Node.js](https://nodejs.org/en/download/) e
verifique se está instalado corretamente com o seguinte comando:

```bash 
$ node --version
```

A versão do Node.js deve ser impressa. Certifique-se de que é maior
que 8.16.0.

Para instalar o Yarn, siga as instruções de instalação
instruções no [site do Yarn](https://classic.yarnpkg.com/en/docs/install).

A execução deste comando deve imprimir a versão do Yarn:

```bash
$ yarn --version
```

Se aparecer algo como "1.22.0", o Yarn foi instalado corretamente.

#### Instalando o Rails

Para instalar o Rails, use o comando `gem install` fornecido pelo RubyGems:

```bash
$ gem install rails
```

Para verificar se você tem tudo instalado corretamente, você deve rodar o comando à seguir:

```bash
$ rails --version
```

Se esse comando retornar algo como "Rails 6.0.0", você está pronto para continuar.

### Criando a Aplicação Blog

O Rails vem com vários scripts chamados *generators* que são projetados para tornar
sua vida de desenvolvedor fácil, criando tudo que é necessário para começar a
trabalhar em uma tarefa em particular. Um desses é o *generator* de nova aplicação,
que irá te fornecer a base de uma nova aplicação em Rails para que você não precise
escrever tudo sozinho.

Para utilizar esse *generator*, abra um terminal, navegue para um diretório onde
você tenha permissão para criar arquivos, e rode:

```bash
$ rails new blog
```

Este comando irá criar uma aplicação em Rails chamada Blog em um diretório `blog`
e irá instalar as dependências das *gems* que já foram mencionadas no `Gemfile`
usando `bundle install`.

NOTE: Se você está utilizando um subsistema Windows para Linux então existem
algumas limitações nas notificações dos arquivos do sistema que significa que você
deve desabilitar as gems `spring` e `listen`, o que poderá ser feito rodando o comando
`rails new blog --skip-spring --skip-listen`.

TIP: Você pode ver todas as opções de linha de comando gerador que a aplicação Rails
aceita rodando o comando `rails new --help`.

Depois de criar a aplicação blog, entre em sua pasta:

```bash
$ cd blog
```

A pasta `blog` vai ter vários arquivos gerados e pastas que compõem a estrutura
de uma aplicação Rails. A maior parte da execução deste tutorial será feito na
pasta `app`, mas à seguir teremos um resumo básico das funções de cada um dos arquivos e pastas
que o Rails gerou por padrão:

| Arquivo/Pasta | Objetivo |
| ----------- | ------- |
|app/|Contém os *controllers*, *models*, *views*, *helpers*, *mailers*, *channels*, *jobs*, e *assets* para sua aplicação. Você irá se concentrar nesse diretório pelo restante desse guia.|
|bin/|Contém o script `rails` que inicializa sua aplicação e contém outros scripts que você utiliza para configurar, atualizar, colocar em produção ou executar sua aplicação.|
|config/|Contém configurações de rotas, banco de dados entre outros de sua aplicação. Este conteúdo é abordado com mais detalhes em [Configuring Rails Applications](configuring.html).|
|config.ru|Configuração *Rack* para servidores baseados em *Rack* usados para iniciar a aplicação. Para mais informações sobre o *Rack*, consulte [Rack website](https://rack.github.io/).|
|db/|Contém o *schema* do seu banco de dados atual, assim como as *migrations* do banco de dados.|
|Gemfile<br>Gemfile.lock|Esses arquivos permitem que você especifique quais dependências de *gem* são necessárias na sua aplicação Rails. Esses arquivos são usados pela *gem* Bundler. Para mais informações sobre o Bundler, acesse [o website do Bundler](https://bundler.io).|
|lib/|Módulos extendidos da sua aplicação.|
|log/|Arquivos de *log* da aplicação.|
|package.json|Este arquivo permite que você especifique quais dependências *npm* são necessárias para sua aplicação Rails. Este arquivo é usado pelo Yarn. Para mais informações do Yarn, acesse [o website do Yarn](https://yarnpkg.com/lang/en/).|
|public/|Contém arquivos estáticos e *assets* compilados. Quando sua aplicação está rodando esse diretório é exposto como ele está.|
|Rakefile|Este arquivo localiza e carrega tarefas que podem ser rodadas por linhas de comando. As tarefas são definidas nos componentes do Rails. Ao invés de editar o `Rakefile`, você deve criar suas próprias tarefas adicionando os arquivos no diretório `lib/tasks` da sua aplicação.|
|README.md|Este é um manual de instruções para sua aplicação. Você deve editar este arquivo para informar o que seu aplicativo faz, como configurá-lo e assim por diante.|
|storage/|Arquivos de armazenamento ativo do serviço de disco. Mais informações em [Active Storage Overview](active_storage_overview.html).|
|test/|Testes unitários, *fixtures*, e outros tipos de testes. Mais informações em [Testing Rails Applications](testing.html).|
|tmp/|Arquivos temporários (como cache e arquivos *pid*).|
|vendor/|Diretório com todos os códigos de terceiros. Em uma típica aplicação Rails inclui *vendored gems*.|
|.gitignore|Este arquivo diz ao Git quais arquivos (ou padrões) devem ser ignorados. Acesse [GitHub - Ignoring files](https://help.github.com/articles/ignoring-files) para mais informações sobre arquivos ignorados.|
|.ruby-version|Este arquivo contém a versão padrão do Ruby.|

Olá, Rails!
-----------

Para começar vamos colocar um texto na tela rapidamente. Para fazer isso, você
precisa que seu servidor de aplicação Rails esteja em execução.

### Inicializando o Servidor Web

Você já tem uma aplicação Rails funcional. Para vê-la você deve iniciar um
servidor web em sua máquina de desenvolvimento. Você pode fazer isso executando
o seguinte comando no diretório `blog`:

```bash
$ bin/rails server
```

TIP: Se você está usando Windows, deve executar os scripts do diretório
`bin` para o interpretador do Ruby: `ruby bin\rails server`.

TIP: A compressão de *assets* JavaScript requer que você tenha um executor
disponível em seu sistema operacional. Na ausência de um executor você verá um
erro de `execjs` durante a compressão dos *assets*. Geralmente o macOS e o Windows possuem um executor JavaScript instalado por
padrão. `therubyrhino` é o executor recomendado para usuários de JRuby e vem no
`Gemfile` por padrão em aplicações geradas com JRuby. Você pode avaliar todos
executores em [ExecJS](https://github.com/rails/execjs#readme).

A execução do comando irá iniciar o Puma, um servidor web distribuído com o
Rails por padrão. Para ver sua aplicação em execução, abra um navegador e
navegue para <http://localhost:3000>.  Você deve ver a página padrão com informações do Rails:

![Captura de tela escrito Yay! Você está no Rails(em inglês)](images/getting_started/rails_welcome.png)

Quando você deseja interromper a execução do servidor Web, pressione Ctrl+C na janela do
terminal em que o servidor está sendo executado. No ambiente de desenvolvimento, o Rails geralmente não requer que você reinicie o servidor; mudanças em arquivos são automaticamente interpretadas pelo servidor.

A página de "Yay! Você está no Rails! (Yay! You're on Rails!)" é o _smoke test_ (teste de sanidade) para uma
nova aplicação Rails: garante que o seu software esteja configurado
corretamente, o suficiente para gerar uma página.

### Diga "Olá", Rails

Para que o Rails diga "Olá", você precisa criar no mínimo uma rota (_route_), um _controller_ com uma _action_ e uma _view_. A _route_ mapeia uma requisição para uma _action_ de um _controller_. A _action_ do _controller_ faz todo o trabalho necessário para lidar com a requisição, e prepara qualquer dado para a _view_. A _view_  mostra o dado no formato que você quiser.

Em termos de implementação: Rotas são regras escritas em um [DSL (domain-specific language)](https://pt.wikipedia.org/wiki/Linguagem_de_dom%C3%ADnio_espec%C3%ADfico) em Ruby. _Controllers_ são classes Ruby, e seus métodos públicos são as _actions_. E as _views_ são _templates_, geralmente escritos numa mistura de Ruby e HTML.

Vamos começar adicionando uma rota ao nosso arquivo de rotas, `config/routes.rb`, no
topo do bloco `Rails.application.routes.draw`:

```ruby
Rails.application.routes.draw do
  get "/articles", to: "articles#index"

  # Para mais detalhes da DSL disponível para esse arquivo, veja https://guides.rubyonrails.org/routing.html
end
```

A rota acima declara que as requisições de `GET / articles` são mapeadas para o _action_ `index` do `ArticlesController`.

Para criar o `ArticlesController` e sua _action_ `index`, vamos executar o controlador
gerador (com a opção `--skip-routes` porque já temos um
rota apropriada):

```bash
$ bin/rails generate controller Articles index --skip-routes
```

O Rails vai gerar vários arquivos para você:

```
create  app/controllers/articles_controller.rb
invoke  erb
create    app/views/articles
create    app/views/articles/index.html.erb
invoke  test_unit
create    test/controllers/articles_controller_test.rb
invoke  helper
create    app/helpers/articles_helper.rb
invoke    test_unit
invoke  assets
invoke    scss
create      app/assets/stylesheets/articles.scss
```

O mais importante desses é o arquivo _controller_, `app/controllers/articles_controller.rb`. Vamos dar uma olhada nele:

```ruby
class ArticlesController < ApplicationController
  def index
  end
end
```

A _action_ `index` está vazia. Quando uma _action_ não renderiza explicitamente uma _view_
(ou de outra forma acionar uma resposta HTTP), o Rails irá renderizar automaticamente uma _view_
que corresponde ao nome do _controller_ e _action_. Convenção sobre
Configuração! As _views_ estão localizadas no diretório `app/views`. Portanto, a _action_ `index` renderizará `app/views/articles/index.html.erb` por padrão.

Vamos abrir o arquivo `app/views/articles/index.html.erb`, e substituir todo código existente por:

```html
<h1>Olá, Rails!</h1>
```

Se você parou anteriormente o servidor web para executar o gerador do _controller_,
reinicie-o com `bin/rails server`. Agora visite <http://localhost:3000/articles>
e veja nosso texto exibido!

### Configuração da Página Inicial da Aplicação

No momento, <http://localhost:3000> ainda exibe "Yay! Você está no Rails!".
Vamos mostrar nosso "Olá, Rails!" texto em <http://localhost:3000> também.
Para fazer isso, vamos adicionar uma rota que mapeia o caminho raiz (*root path*) da nossa aplicação para o _controller_ e _action_ apropriados.

Vamos abrir o arquivo `config/routes.rb`, e adicionar o a rota `root` no começo do bloco `Rails.application.routes.draw`:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
end
```

Agora podemos ver a mensagem "Olá, Rails!", quando visitamos <http://localhost:3000> confirmando que a _route_ `root` também mapeia para a _action_ `index` de `ArticlesController`.

TIP: Para mais informações sobre roteamento, consulte [Roteamento do Rails de Fora para Dentro](routing.html).


MVC e Você
-----------

Até agora, discutimos rotas, _controllers_, _actions_ e _views_. Todas essas
são peças típicas de uma aplicação web que segue o padrão [MVC (Model-View-Controller)](
https://pt.wikipedia.org/wiki/MVC).

MVC é um padrão de projeto que divide as responsabilidades de uma aplicação para
facilitar nosso entendimento. O Rails segue esse padrão de projeto por
convenção.

Já que temos um _controller_ e uma _view_ para trabalhar, agora vamos gerar a próxima
peça: o _model_.

### Gerando um _Model_

Um _Model_ é uma classe Ruby utilizada para representar dados. Além disso, os
_models_ podem interagir com o banco de dados da aplicação através de um recurso
do Rails chamado _Active Record_.

Para definir um _model_, utilizaremos um gerador de _models_:

```bash
$ bin/rails generate model Article title:string body:text
```

NOTE: Os nomes dos _models_ são no **singular**, pois um _model_ instanciado
representa um único registro de dados. Para ajudar a lembrar esta convenção,
pense em como você chamaria o construtor do _model_: queremos escrever
`Article.new(...)`, **não** `Articles.new(...)`.

O comando utilizando o gerador criará vários arquivos:

```
invoke  active_record
create    db/migrate/<timestamp>_create_articles.rb
create    app/models/article.rb
invoke    test_unit
create      test/models/article_test.rb
create      test/fixtures/articles.yml
```

Os dois arquivos em que vamos nos concentrar são o arquivo da _migration_
(`db/migrate/<timestamp>_create_articles.rb`) e o arquivo do _model_
(`app/models/article.rb`).

### Migrações de Banco de Dados

As *Migrations* são utilizadas para alterar a estrutura do banco de dados de uma
aplicação. Em aplicações Rails, as _migrations_ são escritas em Ruby para que
possam ser independentes do banco de dados.

Vamos dar uma olhada no conteúdo do nosso novo arquivo de _migration_:

```ruby
class CreateArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
```

A chamada para `create_table` especifica como a tabela `articles` deve ser
construída. Por padrão, o método `create_table` adiciona uma coluna `id` como
chave primária de auto incremento. Portanto, o primeiro registro na tabela terá
um `id` de valor 1, o próximo registro terá um `id` de valor 2 e assim por
diante.

Dentro do bloco de `create_table`, duas colunas são definidas: `title` e `body`.
Elas foram adicionadas pelo gerador, pois incluímos a instrução no nosso comando
(`bin/rails generate model Article title:string body:text`).

Na última linha do bloco há uma chamada para `t.timestamps`. Este método define
duas colunas adicionais chamadas `created_at` e `updated_at`. Como veremos
mais pra frente, o Rails gerenciará isso para nós, definindo os valores quando
criamos ou atualizamos um objeto _model_.

Vamos executar a nossa _migration_ com o seguinte comando:

```bash
$ bin/rails db:migrate
```

O comando exibirá o resultado do processamento indicando que a tabela foi criada:

```
==  CreateArticles: migrating ===================================
-- create_table(:articles)
   -> 0.0018s
==  CreateArticles: migrated (0.0018s) ==========================
```

TIP: Para saber mais sobre _migrations_, consulte [Active Record Migrations](
active_record_migrations.html).

Agora podemos interagir com a tabela utilizando o nosso _model_.

### Utilizando um _Model_ para Interagir com o Banco de Dados

Para brincar um pouco com o nosso _model_, vamos utilizar um recurso do Rails
chamado *console*. O *console* é um ambiente de codificação interativo como o
`irb`, mas que também carrega automaticamente o Rails e o código da nossa
aplicação.

Vamos iniciar o console com o comando:

```bash
$ bin/rails console
```

Você deve visualizar um *prompt* `irb`:

```irb
Loading development environment (Rails 6.0.2.1)
irb(main):001:0>
```

Neste *prompt*, podemos inicializar um novo objeto `Article`:

```irb
irb> article = Article.new(title: "Hello Rails", body: "I am on Rails!")
```

É importante notar que apenas *inicializamos* este objeto. O objeto não é salvo
no banco de dados e no momento está disponível apenas no *console*. Para salvar o
objeto no banco de dados, devemos chamar
[`save`](https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-save):

```irb
irb> article.save
(0.1ms)  begin transaction
Article Create (0.4ms)  INSERT INTO "articles" ("title", "body", "created_at", "updated_at") VALUES (?, ?, ?, ?)  [["title", "Hello Rails"], ["body", "I am on Rails!"], ["created_at", "2020-01-18 23:47:30.734416"], ["updated_at", "2020-01-18 23:47:30.734416"]]
(0.9ms)  commit transaction
=> true
```

A saída acima mostra uma *query* `INSERT INTO "articles" ...` de banco de dados.
Isso indica que o artigo foi inserido em nossa tabela. Se dermos uma olhada no
objeto `article` novamente, vemos que algo interessante aconteceu:

```irb
irb> article
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```

Os atributos `id`, `created_at` e `updated_at` agora estão definidos.
O Rails fez isso por nós quando salvamos o objeto.

Quando quisermos buscar este artigo no banco de dados, podemos chamar
[`find`](https://api.rubyonrails.org/classes/ActiveRecord/FinderMethods.html#method-i-find)
no _model_ e passar o `id` como argumento:

```irb
irb> Article.find(1)
=> #<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">
```

E quando quisermos obter todos os artigos do banco de dados, podemos chamar [`all`](
https://api.rubyonrails.org/classes/ActiveRecord/Scoping/Named/ClassMethods.html#method-i-all)
no _model_:

```irb
irb> Article.all
=> #<ActiveRecord::Relation [#<Article id: 1, title: "Hello Rails", body: "I am on Rails!", created_at: "2020-01-18 23:47:30", updated_at: "2020-01-18 23:47:30">]>
```

Esté método retorna um objeto [`ActiveRecord::Relation`](
https://api.rubyonrails.org/classes/ActiveRecord/Relation.html), que você pode
considerar como um _array_ superpotente.

TIP: Para saber mais sobre _models_, consulte o [Básico do Active Record](
active_record_basics.html) e [Interface de Consulta do Active Record](
active_record_querying.html).

Os _models_ são a peça final do quebra-cabeça MVC. A seguir, conectaremos todas
as peças.

### Exibindo uma Lista de Artigos

Vamos voltar ao nosso _controller_ em `app/controllers/articles_controller.rb` e
alterar a _action_ `index` para buscar todos os artigos do banco de dados:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end
end
```

As variáveis de instância do _controller_ podem ser acessadas pela _view_. Isso
significa que podemos referenciar `@articles` em
`app/views/articles/index.html.erb`. Vamos abrir esse arquivo e substituir seu
conteúdo por:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= article.title %>
    </li>
  <% end %>
</ul>
```

O código acima é uma mistura de HTML e *ERB*. ERB é um sistema de _template_ que
avalia código Ruby embarcado em um documento. Aqui, podemos ver dois tipos de
_tags_ ERB: `<% %>` e `<%= %>`. A _tag_ `<% %>` significa "avaliar o código Ruby
incluso". A _tag_ `<%= %>` significa "avaliar o código Ruby incluso e retornar o
valor de saída". Qualquer coisa que possa ser escrita em um programa normal em
Ruby pode ir dentro dessas _tags_ ERB, embora geralmente seja melhor manter o
conteúdo das _tags_ ERB de forma curta para facilitar a leitura.

Já que não queremos gerar o valor retornado por `@articles.each`, vamos colocar
esse código em `<% %>`. Porém, uma vez que **queremos** exibir o valor retornado
em `article.title` (para cada artigo), incluímos esse códido em `<%= %>`.

Nós podemos visualizar o resultado final visitando <http://localhost:3000>
(lembre-se de que `bin/rails server` deve estar em execução!). Aqui estão as
etapas do que acontece quando fazemos isso:

1. O navegador faz uma requisição (_request_): `GET http://localhost:3000`.
2. Nossa aplicação Rails recebe essa requisição.
3. O roteador do Rails mapeia a rota raiz para a _action_ `index` de
   `ArticlesController`.
4. A _action_ `index`utiliza o _model_ `Article` para buscar todos os artigos no
   banco de dados.
5. O Rails renderiza automaticamente a _view_
   `app/views/articles/index.html.erb`.
6. O código ERB na _view_ é avaliado para gerar código HTML.
7. O servidor envia uma resposta (_response_) de volta ao navegador contendo o
   HTML.

Conectamos todas as peças do MVC e temos nossa primeira _action_ no
_controller_! A seguir, passaremos para a segunda _action_.

Operações CRUD
--------------------------

Quase todas as aplicações web abrangem operações [CRUD (Create, Read, Update e
Delete)](https://pt.wikipedia.org/wiki/CRUD), traduzidos como criação, consulta,
atualização e destruição de dados. Você pode até descobrir que a maior parte do
trabalho que a sua aplicação faz é o CRUD. O Rails reconhece isso e fornece
muitos recursos para ajudar a simplificar o código na hora de fazer o CRUD.

Vamos começar a explorar esses recursos adicionando mais funcionalidades à nossa
aplicação.

### Exibindo um Único Artigo

Atualmente, temos uma _view_ que lista todos os artigos em nosso banco de dados.
Vamos adicionar uma nova _view_ que exibe o título (_title_) e o corpo (_body_)
de um único artigo.

Começamos adicionando uma nova rota que mapeia para uma nova _action_ do
_controller_ (que adicionaremos a seguir). Abra o arquivo `config/routes.rb` e
insira a última rota exibida aqui:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  get "/articles", to: "articles#index"
  get "/articles/:id", to: "articles#show"
end
```

A nova rota é outra rota do tipo `get`, mas tem algo extra no seu caminho
(_path_): `:id`. Isso denomina um **parâmetro** de rota. Um parâmetro de rota
captura um pedaço do caminho da requisição e coloca esse valor no _Hash_
`params`, que pode ser acessado pela _action_ do _controller_. Por exemplo, ao
lidar com uma requisição como `GET http://localhost:3000/articles/1`, `1` seria
capturado como o valor para `id`, que seria então acessível em `params[:id]` na
_action_ `show` de `ArticlesController`.

Vamos adicionar a _action_ `show` agora, abaixo da _action_ `index` em
`app/controllers/articles_controller.rb`:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end
end
```

A _action_ `show` chama `Article.find` ([mencionado
anteriormente](#utilizando-um-model-para-interagir-com-o-banco-de-dados)) com o
ID capturado pelo parâmetro de rota. O artigo retornado é armazenado na variável
de instância `@article`, portanto, pode ser acessado pela _view_. Por padrão, a
_action_ `show` vai renderizar `app/views/articles/show.html.erb`.

Vamos criar `app/views/articles/show.html.erb`, com o seguinte conteúdo:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>
```

Agora podemos ver o artigo quando visitarmos <http://localhost:3000/articles/1>!

Para finalizar, vamos adicionar uma maneira mais prática para chegar à página
de um artigo. Iremos vincular o título de cada artigo em
`app/views/articles/index.html.erb` para sua página:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="/articles/<%= article.id %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

### Roteamento de _Resources_ (recursos)

Até agora, nós vimos o "R" (_Read_, consulta) do CRUD. Iremos eventualmente
cobrir o "C" (_Create_, criação), "U" (_Update_, atualização) e o "D" (_Delete_,
destruição). Como você deve ter imaginado, faremos isso adicionando novas rotas,
_actions_ no _controller_ e _views_ que funcionam em conjunto para realizar as
operações CRUD em uma entidade. Chamamos essa entidade de _resource_ (recurso).
Por exemplo, em nossa aplicação, diríamos que um artigo é um recurso.

O Rails fornece um método de rotas chamado [`resources`](
https://api.rubyonrails.org/classes/ActionDispatch/Routing/Mapper/Resources.html#method-i-resources)
que mapeia todas as rotas convencionais para uma coleção de recursos, como
artigos. Portanto, antes de prosseguir para as seções "C", "U" e "D", vamos
substituir as duas rotas `get` em `config/routes.rb` por `resources`:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles
end
```

Nós podemos inspecionar quais rotas estão mapeadas executando o comando
`bin/rails routes`:

```bash
$ bin/rails routes
      Prefix Verb   URI Pattern                  Controller#Action
        root GET    /                            articles#index
    articles GET    /articles(.:format)          articles#index
 new_article GET    /articles/new(.:format)      articles#new
     article GET    /articles/:id(.:format)      articles#show
             POST   /articles(.:format)          articles#create
edit_article GET    /articles/:id/edit(.:format) articles#edit
             PATCH  /articles/:id(.:format)      articles#update
             DELETE /articles/:id(.:format)      articles#destroy
```

O método `resources` também configura URL e métodos auxiliares (_helper_) de
caminhos que podemos utilizar para evitar que nosso código dependa de uma
configuração de rota específica. Os valores na coluna "Prefix" acima, mais um
sufixo `_url` ou `_path` formam os nomes desses _helpers_. Por exemplo, o
_helper_ `article_path` retorna `"/articles/#{article.id}"` quando recebe um
artigo. Podemos utilizá-lo para organizar nossos links em
`app/views/articles/index.html.erb`:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <a href="<%= article_path(article) %>">
        <%= article.title %>
      </a>
    </li>
  <% end %>
</ul>
```

No entanto, daremos um passo adiante utilizando o _helper_ [`link_to`](
https://api.rubyonrails.org/classes/ActionView/Helpers/UrlHelper.html#method-i-link_to).
O _helper_ `link_to` renderiza um link com seu primeiro argumento como o texto
do link e seu segundo argumento como o destino do link. Se passarmos um objeto
_model_ como segundo argumento, o `link_to` chamará o _helper_ de caminho
apropriado para converter o objeto em um caminho. Por exemplo, se passarmos um
artigo, o `link_to` chamará o `article_path`. Portanto,
`app/views/articles/index.html.erb` se torna:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>
```

Muito bom!

TIP: Para aprender mais sobre roteamento, consulte [Rotas do Rails de Fora pra Dentro](
routing.html).

### Criando um Novo Artigo

Agora, seguimos para o "C" (_Create_, criação) do CRUD. Normalmente, em
aplicações web, a criação de um novo recurso é um processo de várias etapas.
Primeiro, o usuário solicita um formulário para preencher. Em seguida, o usuário
envia o formulário. Se não houver erros, o recurso será criado e algum tipo de
confirmação será exibido. Caso contrário, o formulário é exibido novamente com
mensagens de erros e o processo é repetido.

Em uma aplicação Rails, esses passos não convencionalmente tratados pelas
_actions_ `new` e `create` do _controller_. Vamos implementar essas _actions_ em
`app/controllers/articles_controller.rb`, abaixo da _action_ `show`:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(title: "...", body: "...")

    if @article.save
      redirect_to @article
    else
      render :new
    end
  end
end
```

A _action_ `new` instancia um novo artigo, mas não o salva no banco de dados.
Este artigo será utilizado na _view_ ao construirmos o formulário. Por padrão, a
_action_ `new` renderizará `app/views/articles/new.html.erb`, que criaremos a
seguir.

A _action_ `create` instancia um novo artigo com os valores para o título e
corpo e tenta salvá-lo no banco de dados. Se o artigo for salvo com sucesso, a
_action_ redireciona o navegador para a página do artigo em
`"http://localhost:3000/articles/#{@article.id}"`. Caso contrário, a _action_
exibe novamente o formulário renderizando a _view_
`app/views/articles/new.html.erb`. O título e o corpo aqui são valores
fictícios. Depois de criarmos o formulário, vamos voltar no _controller_ e
alterá-los.

NOTE: [`redirect_to`](https://api.rubyonrails.org/classes/ActionController/Redirecting.html#method-i-redirect_to)
fará com que o navegador faça uma nova requisição, enquanto
[`render`](https://api.rubyonrails.org/classes/AbstractController/Rendering.html#method-i-render)
renderiza a _view_ especificada para a requisição atual.  É importante utilizar
o `redirect_to` após alterar o banco de dados ou o estado da aplicação. Caso
contrário, se o usuário atualizar a página, o navegador fará a mesma requisição
e a mutação será repetida.

#### Utilizando um Construtor de Formulário (*Form Builder*)

Utilizaremos uma funcionalidade do Rails chamada *form builder* (construtor de
formulário) para criar nosso formulário. Utilizando um construtor de formulário,
podemos escrever uma quantidade mínima de código para gerar um formulário que
está totalmente configurado e segue as convenções do Rails.

Vamor criar a _view_ `app/views/articles/new.html.erb` com o seguinte conteúdo:

```html+erb
<h1>New Article</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

O método auxiliar [`form_with`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with)
instancia um construtor de formulário. No bloco `form_with` chamamos métodos como
[`label`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-label)
e [`text_field`](https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-text_field)
no construtor para gerar os elementos apropriados de um formulário.

O resultado de saída da nossa chamada `form_with` será parecido com:

```html
<form action="/articles" accept-charset="UTF-8" method="post">
  <input type="hidden" name="authenticity_token" value="...">

  <div>
    <label for="article_title">Title</label><br>
    <input type="text" name="article[title]" id="article_title">
  </div>

  <div>
    <label for="article_body">Body</label><br>
    <textarea name="article[body]" id="article_body"></textarea>
  </div>

  <div>
    <input type="submit" name="commit" value="Create Article" data-disable-with="Create Article">
  </div>
</form>
```

TIP: Para saber mais sobre os construtores de formulários, consulte [Action View Form Helpers](
form_helpers.html).

#### Utilizando *Strong Parameters* (Parâmetros Fortes)

Os dados do formulário enviados são colocados no *Hash* `params`, junto com os
parâmetros de rota capturados. Assim, a _action_ `create` pode acessar o título
enviado via `params[:article][:title]` e o corpo enviado via
`params[:article][:body]`. Poderíamos passar esses valores individualmente para
`Article.new`, mas isso seria longo demais e possivelmente sujeito a erros. E
ficaria pior a medida que adicionamos mais campos.

Em vez disso, passaremos um único *Hash* que contém os valores. No entanto,
ainda devemos especificar quais valores são permitidos nesse *Hash*, caso
contrário, um usuário mal intencionado pode enviar campos extras no formulário e
sobrescrever dados privados. Na verdade, se passarmos o *Hash*
`params[:article]` não filtrado diretamente para `Article.new`, o Rails lançará
um `ForbiddenAttributesError` para nos alertar sobre o problema. Portanto,
utilizaremos um recurso do Rails chamado *Strong Parameters* (Parâmetros Fortes)
para filtrar `params`. Pense nisso como [tipagem
forte](https://pt.wikipedia.org/wiki/Linguagem_tipada) para `params`.

Vamos adicionar um método privado na parte inferior de
`app/controllers/articles_controller.rb` chamado `article_params` que filtra o
`params`. E vamos alterar o método `create` para utilizá-lo:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

TIP: Para saber mais sobre *Strong Parameters*, consulte [Action Controller
Overview § Parâmetros Fortes](action_controller_overview.html#parametros-fortes).

#### Validações e Exibição de Mensagens de Erros

Como vimos, a criação de um recurso é um processo de várias etapas. Lidar com a
entrada inválida do usuário é outra etapa desse processo. O Rails fornece um
recurso chamado **validações** para nos ajudar a lidar com entradas inválidas do
usuário. As validações são regras que são verificadas antes de um objeto *model*
ser salvo. Se alguma das validações falhar, o objeto não será salvo e as
mensagens de erros apropriadas serão adicionadas ao atributo `errors` do objeto
*model*.

Vamos adicionar algumas validações ao nosso *model* em `app/models/article.rb`:

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

A primeira validação declara que um valor `title` deve estar presente. Como
`title` é uma *string*, isso significa que o valor `title` deve conter pelo
menos um caractere diferente de espaço em branco.

A segunda validação declara que um valor `body` também deve estar presente. Além
disso, declara que o valor `body` deve ter pelo menos 10 caracteres.

NOTE: Você pode estar se perguntando onde os atributos `title` e `body` são
definidos. O *Active Record* define automaticamente os atributos do *model* para
cada coluna da tabela, então você não precisa declarar esses atributos em seu
arquivo *model*.

Com nossas validações no lugar, vamos modificar
`app/views/articles/new.html.erb` para exibir quaisquer mensagens de erro para
`title` e `body`:

```html+erb
<h1>New Article</h1>

<%= form_with model: @article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% @article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% @article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

O método [`full_messages_for`](https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_messages_for)
retorna um *array* de mensagens de erro amigáveis para um atributo especificado.
Se não houver erros para esse atributo, o *array* ficará vazio.


Para entender como tudo isso funciona junto, vamos dar uma olhada nas *actions*
de `new` e `create` do *controller*:

```ruby
  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new
    end
  end
```

Quando visitamos <http://localhost:3000/articles/new>, a solicitação `GET
/articles/new` é mapeada para a *action* `new`. A *action* `new` não tenta
salvar o `@article`. Portanto, as validações não são verificadas e não haverá
mensagens de erro.

Quando enviamos o formulário, a solicitação `POST /articles` é mapeada para a
*action* `create`. A *action* `create` **tenta** salvar o `@article`.
Portanto, as validações **são** verificadas. Se alguma validação falhar,
o `@article` não será salvo e a *view* `app/views/articles/new.html.erb` será
renderizada com as mensagens de erro.

TIP: Para saber mais sobre validações, consulte [Validações do Active Record](
active_record_validations.html). Para saber mais sobre as mensagens de erro de
validação, consulte [Validações do Active Record § Trabalhando com Erros de
Validação]( active_record_validations.html#trabalhando-com-erros-de-validacao).

#### Finalizando

Agora podemos criar um artigo visitando <http://localhost:3000/articles/new>.
Para finalizar, vamos criar um *link* para essa página na parte inferior da
*view* `app/views/articles/index.html.erb`:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

### Updating an Article

We've covered the "CR" of CRUD. Now let's move on to the "U" (Update). Updating
a resource is very similar to creating a resource. They are both multi-step
processes. First, the user requests a form to edit the data. Then, the user
submits the form. If there are no errors, then the resource is updated. Else,
the form is redisplayed with error messages, and the process is repeated.

These steps are conventionally handled by a controller's `edit` and `update`
actions. Let's add a typical implementation of these actions to
`app/controllers/articles_controller.rb`, below the `create` action:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit
    end
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

Notice how the `edit` and `update` actions resemble the `new` and `create`
actions.

The `edit` action fetches the article from the database, and stores it in
`@article` so that it can be used when building the form. By default, the `edit`
action will render `app/views/articles/edit.html.erb`.

The `update` action (re-)fetches the article from the database, and attempts
to update it with the submitted form data filtered by `article_params`. If no
validations fail and the update is successful, the action redirects the browser
to the article's page. Else, the action redisplays the form, with error
messages, by rendering `app/views/articles/edit.html.erb`.

#### Using Partials to Share View Code

Our `edit` form will look the same as our `new` form. Even the code will be the
same, thanks to the Rails form builder and resourceful routing. The form builder
automatically configures the form to make the appropriate kind of request, based
on whether the model object has been previously saved.

Because the code will be the same, we're going to factor it out into a shared
view called a *partial*. Let's create `app/views/articles/_form.html.erb` with
the following contents:

```html+erb
<%= form_with model: article do |form| %>
  <div>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
    <% article.errors.full_messages_for(:title).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.label :body %><br>
    <%= form.text_area :body %><br>
    <% article.errors.full_messages_for(:body).each do |message| %>
      <div><%= message %></div>
    <% end %>
  </div>

  <div>
    <%= form.submit %>
  </div>
<% end %>
```

The above code is the same as our form in `app/views/articles/new.html.erb`,
except that all occurrences of `@article` have been replaced with `article`.
Because partials are shared code, it is best practice that they do not depend on
specific instance variables set by a controller action. Instead, we will pass
the article to the partial as a local variable.

Let's update `app/views/articles/new.html.erb` to use the partial via [`render`](
https://api.rubyonrails.org/classes/ActionView/Helpers/RenderingHelper.html#method-i-render):

```html+erb
<h1>New Article</h1>

<%= render "form", article: @article %>
```

NOTE: A partial's filename must be prefixed **with** an underscore, e.g.
`_form.html.erb`. But when rendering, it is referenced **without** the
underscore, e.g. `render "form"`.

And now, let's create a very similar `app/views/articles/edit.html.erb`:

```html+erb
<h1>Edit Article</h1>

<%= render "form", article: @article %>
```

TIP: To learn more about partials, see [Layouts and Rendering in Rails § Using
Partials](layouts_and_rendering.html#using-partials).

#### Finishing Up

We can now update an article by visiting its edit page, e.g.
<http://localhost:3000/articles/1/edit>. To finish up, let's link to the edit
page from the bottom of `app/views/articles/show.html.erb`:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
</ul>
```

### Deleting an Article

Finally, we arrive at the "D" (Delete) of CRUD. Deleting a resource is a simpler
process than creating or updating. It only requires a route and a controller
action. And our resourceful routing (`resources :articles`) already provides the
route, which maps `DELETE /articles/:id` requests to the `destroy` action of
`ArticlesController`.

So, let's add a typical `destroy` action to `app/controllers/articles_controller.rb`,
below the `update` action:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render :new
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render :edit
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to root_path
  end

  private
    def article_params
      params.require(:article).permit(:title, :body)
    end
end
```

The `destroy` action fetches the article from the database, and calls [`destroy`](
https://api.rubyonrails.org/classes/ActiveRecord/Persistence.html#method-i-destroy)
on it. Then, it redirects the browser to the root path.

We have chosen to redirect to the root path because that is our main access
point for articles. But, in other circumstances, you might choose to redirect to
e.g. `articles_path`.

Now let's add a link at the bottom of `app/views/articles/show.html.erb` so that
we can delete an article from its own page:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article),
                  method: :delete,
                  data: { confirm: "Are you sure?" } %></li>
</ul>
```

In the above code, we're passing a few additional options to `link_to`. The
`method: :delete` option causes the link to make a `DELETE` request instead of a
`GET` request. The `data: { confirm: "Are you sure?" }` option causes a
confirmation dialog to appear when the link is clicked. If the user cancels the
dialog, the request is aborted. Both of these options are powered by a feature
of Rails called *Unobtrusive JavaScript* (UJS). The JavaScript file that
implements these behaviors is included by default in fresh Rails applications.

TIP: To learn more about Unobtrusive JavaScript, see [Working With JavaScript in
Rails](working_with_javascript_in_rails.html).

And that's it! We can now list, show, create, update, and delete articles!
InCRUDable!

Adicionando um Segundo Model
----------------------------

É hora de adicionar um segundo *model* à aplicação. O segundo *model* vai lidar com
comentários em artigos.

### Gerando um Model

Nós veremos o mesmo *generator* que usamos antes quando criamos o *model*
`Article` (artigo, inglês). Desta vez vamos criar um *model* `Comment` (comentário)
que contém a referência para um artigo. Rode esse comando no seu terminal:

```bash
$ bin/rails generate model Comment commenter:string body:text article:references
```

Este comando vai gerar quatro arquivos:


| Arquivo                                      | Propósito                                                                                                       |
| -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------|
| db/migrate/20140120201010_create_comments.rb | *Migration* para criar a tabela de comentários no seu banco de dados (o nome incluirá um *timestamp* diferente) |
| app/models/comment.rb                        | O *model* Comment                                                                                               |
| test/models/comment_test.rb                  | Aparelhagem de testes para o *model* de comentário                                                              |
| test/fixtures/comments.yml                   | Exemplo de comentários para uso em testes                                                                       |

Primeiro, veja o arquivo `app/models/comment.rb`:

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```

Isso é muito semelhante ao *model* `Article` que vimos antes. A diferença está na
linha `belongs_to : article`, o que configura uma associação no *Active Record*.
Você vai aprender um pouco sobre associações na próxima seção deste guia.

A palavra-chave (`:references`) usada no comando `bash` é um tipo especial de
dado para *models*. Ela cria uma nova coluna na tabela do banco de dados com o
nome fornecido ao *model* anexada a um `_id` que contém um valor do tipo
*integer*. Para compreender melhor, analise o arquivo `db/schema.rb` depois de
rodar a *migration*.

Além do *model*, o Rails também gerou a *migration* para criar a tabela
correspondente no banco de dados:

```ruby
class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.string :commenter
      t.text :body
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```
A linha `t.references` cria uma coluna com valores do tipo *integer* chamada
`article_id`, um índice para ela e uma restrição de chave estrangeira (*foreign key*)
que aponta para a coluna `id` da tabela `articles`. Vá em frente e rode a
*migration*:

```bash
$ bin/rails db:migrate
```

O Rails é inteligente o suficiente para executar somente as migrações que ainda
não foram rodadas no banco de dados atual, assim neste caso você verá:

```
==  CreateComments: migrating =================================================
-- create_table(:comments)
   -> 0.0115s
==  CreateComments: migrated (0.0119s) ========================================
```
### Associando Models

Associações do *Active Record* permitem declarar facilmente a relação entre dois
*models*. No caso de comentários e artigos, você poderia descrever a relação
da seguinte maneira:

* Cada comentário pertece a um artigo.
* Um artigo pode possuir muitos comentários.

De fato, essa sintaxe é muito similar à utilizada pelo Rails para declarar essa
associação. Você já viu a linha de código dentro do *model* `Comment`
(`app/models/comment.rb`) que faz com que cada comentário pertença a um Artigo:

```ruby
class Comment < ApplicationRecord
  belongs_to :article
end
```
Você vai precisar editar o arquivo `app/models/article.rb` para adicionar o outro lado da
associação:

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

Estas duas declarações habilitam uma boa parte de comportamento automático. Por
exemplo, se você possui uma instância da variável `@article` que contém um
artigo, você pode recuperar todos os comentários pertencentes àquele artigo na
forma de um *array* usando `@article.comments`.

TIP: Para mais informações sobre associações do *Active Record*, veja o guia
[Associações no Active Record](association_basics.html).

### Adicionando a Rota para Comentários

Da mesma forma que o *controller* `articles`, nós vamos precisar adicionar a
rota para que o Rails saiba para onde queremos navegar para encontrar
`comments`. Abra o arquivo `config/routes.rb` novamente e o edite da seguinte
maneira:

```ruby
Rails.application.routes.draw do
  root "articles#index"

  resources :articles do
    resources :comments
  end
end
```

Isso cria `comments` como um recurso aninhado (_nested resource_) dentro de `article`. Essa é
outra parte do processo para recuperar as relações hierárquicas que existem  entre
artigos e comentários.

TIP: Para mais informações sobre rotas, veja o guia [Roteamento no Rails](routing.html)

### Gerando um Controller

Com o *model* em mãos, você pode voltar sua atenção para a criação do
*controller* correspondente. Mais uma vez, você vai usar o *generator* usado
anteriormente:

```bash
$ bin/rails generate controller Comments
```
Isso cria quatro arquivos e um diretório vazio:

| Arquivo/Diretório                            | Propósito                                            |
| -------------------------------------------- | ---------------------------------------------------- |
| app/controllers/comments_controller.rb       | O *controller* de comentários                        |
| app/views/comments/                          | *Views* do *controller* são armazenadas aqui         |
| test/controllers/comments_controller_test.rb | O teste para o *controller*                          |
| app/helpers/comments_helper.rb               | Arquivo de *helpers* da *view*                       |
| app/assets/stylesheets/comments.scss         | *Cascading style sheet* (CSS) para o *controller*    |

Como em qualquer blog, nossos leitores vão criar seus comentários diretamente
depois de lerem o artigo e, uma vez que adicionarem o comentário, serão enviados
de volta para a página *show* do artigo para verem o comentário agora listado.
Por essa razão, nosso `CommentsController` está aqui para fornecer um método que
cria comentários e deleta comentários *spam* quando chegarem.

Então, primeiro nós vamos ligar o *show template* para Artigos (`app/views/articles/show.html.erb`)
para que possamos criar um novo comentários:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article),
                  method: :delete,
                  data: { confirm: "Are you sure?" } %></li>
</ul>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Isso adiciona na página *show* do `Article` um formulário que cria um novo
comentário chamando a *action* `create` no `CommentsController`. O `form_with`
aqui usa um *array* que vai construir uma rota aninhada, como `/articles/1/comments`.

Vamos ligar a *action* `create` em `app/controllers/comments_controller.rb`:

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```
Você verá um pouco mais de complexidade aqui do que no *controller* para
artigos. Esse é o efeito colateral do aninhamento que você configurou. Cada
requisição para um comentário deve lembrar o artigo ao qual o comentário está
anexado, para que a chamada inicial do método `find` do *model* `Article`
encontre o artigo em questão.

Além disso, o código aproveita-se de alguns métodos disponíveis para uma
associação. Nós usamos o método `create` em `@article.comments` para criar e
salvar um comentário. Isso vai automaticamente conectar o comentário para que
ele pertença àquele artigo em particular.

Uma vez que temos um novo comentário, nós enviamos o usuário de volta ao artigo
original usando o helper `article_path(@article)`. Como já vimos
anteriormente, isso chama a *action* `show` do `ArticlesController` que por sua
vez renderiza o *template* `show.html.erb`. É aqui que queremos que o comentário
apareça, então vamos adicionar isso ao arquivo `app/views/articles/show.html.erb`.

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article),
                  method: :delete,
                  data: { confirm: "Are you sure?" } %></li>
</ul>

<h2>Comments</h2>
<% @article.comments.each do |comment| %>
  <p>
    <strong>Commenter:</strong>
    <%= comment.commenter %>
  </p>

  <p>
    <strong>Comment:</strong>
    <%= comment.body %>
  </p>
<% end %>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Agora podemos adicionar artigos e comentários ao seu blog e mostrá-los nos
lugares certos.

![Article with Comments](images/getting_started/article_with_comments.png)

Refatorando
-----------

Agora que nossos artigos e comentários funcionam, dê uma olhada no template
`app/views/articles/show.html.erb`. Ele está ficando longo e esquisito. Nós
podemos usar *partials* (*views* parciais) para melhorá-lo.

### Renderizando Coleções de *Partials*

Primeiramente, nós vamos criar uma *partial* para extrair a exibição de todos os
comentários para o artigo. Crie o arquivo `app/views/comments/_comment.html.erb`
e insira o código a seguir:

```html+erb
<p>
  <strong>Commenter:</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>Comment:</strong>
  <%= comment.body %>
</p>
```

Então você pode mudar `app/views/articles/show.html.erb` para o seguinte código:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article),
                  method: :delete,
                  data: { confirm: "Are you sure?" } %></li>
</ul>

<h2>Comments</h2>
<%= render @article.comments %>

<h2>Add a comment:</h2>
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Isso fará com que a *partial* seja renderizada em `app/views/comments/_comment.html.erb`
uma vez para cada comentário na coleção `@article.comments`. Como o método
`render` itera sobre a coleção `@article.comments`, ele designa cada comentário
para uma variável local nomeada como a *partial*, nesse caso `comment`, que então
fica disponível para ser exibida na *partial*.

### Renderizando um Formulário com *Partial*

Agora vamos mover aquela nova seção de comentários para sua própria *partial*.
Novamente, crie o arquivo `app/viewscomments/_form.html.erb` contendo:

```html+erb
<%= form_with model: [ @article, @article.comments.build ] do |form| %>
  <p>
    <%= form.label :commenter %><br>
    <%= form.text_field :commenter %>
  </p>
  <p>
    <%= form.label :body %><br>
    <%= form.text_area :body %>
  </p>
  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Então deixe o arquivo `app/views/articles/show.html.erb` assim:

```html+erb
<h1><%= @article.title %></h1>

<p><%= @article.body %></p>

<ul>
  <li><%= link_to "Edit", edit_article_path(@article) %></li>
  <li><%= link_to "Destroy", article_path(@article),
                  method: :delete,
                  data: { confirm: "Are you sure?" } %></li>
</ul>

<h2>Comments</h2>
<%= render @article.comments %>

<h2>Add a comment:</h2>
<%= render 'comments/form' %>
```

O segundo *render* apenas define o template de *partial* que queremos renderizar,
`comments/form`. O Rails é inteligente o suficiente para entender a barra nessa
string e perceber que você quer renderizar o arquivo `_form.html.erb` no
diretório `app/views/comments`.

O objeto `@article` está disponível para todas as *partials* renderizadas na view
porque o definimos como uma variável de instância.

### Usando *Concerns*

*Concerns* são uma forma de tornar grandes _controllers_ ou _models_ mais fáceis de entender e gerenciar. Isso também tem a vantagem de ser reutilizável quando vários _models_ (ou _controllers_) compartilham as mesmas preocupações. As *concerns* são implementadas usando módulos (`module`) que contêm métodos que representam uma fatia bem definida da funcionalidade pela qual um _model_ ou _controller_ é responsável. Em outras linguagens, os módulos costumam ser conhecidos como *mixins*.

Você pode usar as *concerns* em seu _controller_ ou _model_ da mesma forma que usaria qualquer módulo. Quando você criou sua aplicação pela primeira vez com `rails new blog`, duas pastas foram criadas dentro de `app/` junto com o resto:

```
app/controllers/concerns
app/models/concerns
```

 Um determinado artigo do blog pode ter vários status - por exemplo, pode ser visível para todos (ou seja, `public`), ou visível apenas para o autor (ou seja, `private`). Também pode estar oculto para todos, mas ainda pode ser recuperado (ou seja, `archived`). Os comentários também podem estar ocultos ou visíveis. Isso pode ser representado usando uma coluna `status` em cada um dos _models_.

Dentro do _model_ `article`, após executar uma _migration_ para adicionar uma coluna `status`, você pode adicionar:

```ruby
class Article < ApplicationRecord
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

e no _model_ `Comment`:

```ruby
class Comment < ApplicationRecord
  belongs_to :article

  VALID_STATUSES = ['public', 'private', 'archived']

  validates :status, inclusion: { in: VALID_STATUSES }

  def archived?
    status == 'archived'
  end
end
```

Então, em nossa _action_ `index` (`app/views/articles/index.html.erb`), usaríamos o método `archived?` Para evitar a exibição de qualquer artigo que está arquivado:

```html+erb
<h1>Articles</h1>

<ul>
  <% @articles.each do |article| %>
    <% unless article.archived? %>
      <li>
        <%= link_to article.title, article %>
      </li>
    <% end %>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

No entanto, se você olhar novamente para nossos _models_ agora, pode ver que a lógica está duplicada. Se, no futuro, aumentarmos a funcionalidade do nosso blog - para incluir mensagens privadas, por exemplo - podemos ver a duplicação de lógica mais uma vez. É aqui que as *concerns* são úteis.

Uma *concerns* é responsável apenas por um subconjunto específico da responsabilidade do _model_; os métodos na nossa *concern* estarão todos relacionados à visibilidade de um _model_. Vamos chamar nossa nova *concern* (módulo) de `Visible`. Podemos criar um novo arquivo dentro de `app/models/concerns` chamado` visible.rb`, e armazenar todos os métodos de status que foram duplicados nos _models_.

`app/models/concerns/visible.rb`

```ruby
module Visible
  def archived?
    status == 'archived'
  end
end
```

Podemos adicionar nossa validação de status à *concern*, mas isso é um pouco mais complexo, pois as validações são métodos chamados no nível da classe. O `ActiveSupport::Concern` ([API Guide] (https://api.rubyonrails.org/classes/ActiveSupport/Concern.html)) nos dá uma maneira mais simples de incluí-los:

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  def archived?
    status == 'archived'
  end
end
```

Agora, podemos remover a lógica duplicada de cada _model_ e, em vez disso, incluir nosso novo módulo `Visible`:

Em `app/models/article.rb`:

```ruby
class Article < ApplicationRecord
  include Visible
  has_many :comments

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

e em `app/models/comment.rb`:

```ruby
class Comment < ApplicationRecord
  include Visible
  belongs_to :article
end
```

Os métodos de classe também podem ser adicionados às *concerns*. Se quisermos que uma contagem de artigos públicos ou comentários sejam exibidos em nossa página principal, podemos adicionar um método de classe a `Visible` da seguinte maneira:

```ruby
module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  class_methods do
    def public_count
      where(status: 'public').count
    end
  end

  def archived?
    status == 'archived'
  end
end
```

Então, na _view_, você pode chamá-lo como qualquer método de classe:

```html+erb
<h1>Articles</h1>

Our blog has <%= Article.public_count %> articles and counting!

<ul>
  <% @articles.each do |article| %>
    <li>
      <%= link_to article.title, article %>
    </li>
  <% end %>
</ul>

<%= link_to "New Article", new_article_path %>
```

Existem mais algumas etapas a serem realizadas antes que nossa aplicaçãi funcione com a adição da coluna `status`. Primeiro, vamos executar as seguintes *migrations* para adicionar `status` aos `Articles` e `Comments`:

```bash
$ bin/rails generate migration AddStatusToArticles status:string
$ bin/rails generate migration AddStatusToComments status:string
```

TIP: Para aprender mais sobre *migrations*, veja em [Active Record Migrations](
active_record_migrations.html).

Também temos que permitir a chave `:status` como parte do parâmetro (usando *strong parameters*), em `app/controllers/articles_controller.rb`:

```ruby
private
    def article_params
      params.require(:article).permit(:title, :body, :status)
    end
```

e em `app/controllers/comments_controller.rb`:

```ruby
private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
```

Para finalizar, adicionaremos uma caixa de seleção aos formulários e permitiremos que o usuário selecione o status ao criar um novo artigo ou postar um novo comentário. Também podemos especificar o status padrão como `public`. Em `app/views/articles/_form.html.erb`, podemos adicionar:

```html+erb
<div>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</div>
```

e em `app/views/comments/_form.html.erb`:

```html+erb
<p>
  <%= form.label :status %><br>
  <%= form.select :status, ['public', 'private', 'archived'], selected: 'public' %>
</p>
```

Deletando Comentários
-----------------

Outra importante *feature* de um blog é excluir comentários de spam. Para fazer
isto, nós precisamos implementar um link de alguma *view* e uma *action*
`destroy` no `CommentsController`.

Primeiro, vamos adicionar o link *delete* na *partial*
`app/views/comments/_comment.html.erb`:

```html+erb
<p>
  <strong>Autor do comentário:</strong>
  <%= comment.commenter %>
</p>

<p>
  <strong>Comentário:</strong>
  <%= comment.body %>
</p>

<p>
  <%= link_to 'Destruir comentário', [comment.article, comment],
              method: :delete,
              data: { confirm: "Are you sure?" } %>
</p>
```

Clicar neste novo link "Destruir comentário" será disparado um `DELETE
/articles/:article_id/comments/:id` ao nosso `CommentsController`, que
pode ser usar isso para encontrar o comentário que queremos excluir, então vamos adicionar
uma ação `destroy` ao nosso *controller* (`app/controllers/comments_controller.rb`):

```ruby
class CommentsController < ApplicationController
  def create
    @article = Article.find(params[:article_id])
    @comment = @article.comments.create(comment_params)
    redirect_to article_path(@article)
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body)
    end
end
```

A *action* `destroy` vai encontrar o artigo que estamos vendo, localizar o
comentário na *collection* `@article.comments`, removê-lo do seu banco de
dados e nos enviar de volta para a *action* `show` do artigo.

### Excluindo objetos associados

Se você excluir um artigo, os comentários (comments) associados também precisarão ser
excluídos, caso contrário, eles simplesmente ocupariam espaço no banco de dados.
O Rails permite que você use a opção `dependent` de uma associação para conseguir isso.
Modifique o Modelo de artigo (article), `app/models/article.rb`, da seguinte forma:

```ruby
class Article < ApplicationRecord
  include Visible

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }
end
```

Segurança
--------

### Autenticação Básica

Se fosse fosse publicar o seu blog online, qualquer um poderia adicionar, editar
e deletar seus artigos ou comentários.

O Rails disponibiliza um sistema de autenticação HTTP que funcionará
tranquilamente nesta situação.

No `ArticlesController` nós precisamos que tenha um meio de bloquear o acesso à
várias ações se uma pessoa não estiver autenticada. Aqui podemos usar o método
`http_basic_authenticate_with`, que permite o acesso para a ação requisitada se
o método deixar.

Para usar o sistema de autenticação, nós especificamos no topo do nosso
`ArticlesController` em `app/controllers/articles_controller.rb`. No nosso caso,
nós queremos que o usuário esteja autenticado em todas as ações, exceto `index`
e `show`, então nós colocamos isso:

```ruby
class ArticlesController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", except: [:index, :show]

  def index
    @articles = Article.all
  end

  # snippet for brevity
```
Nós também queremos autorizar somente usuários autenticados a deletar
comentários, então em `CommentsController`
(`app/controllers/comments_controller.rb`) nós colocamos:

```ruby
class CommentsController < ApplicationController

  http_basic_authenticate_with name: "dhh", password: "secret", only: :destroy

  def create
    @article = Article.find(params[:article_id])
    # ...
  end

  # snippet for brevity
```

Agora se você tentar criar um novo artigo, você deverá preencher um formulário de autenticação:

![Formulário de Autenticação](images/getting_started/challenge.png)

Outros métodos de autenticação estão disponíveis para aplicações Rails. Dois
*add-ons* de autenticação populares para Rails são o
[Devise](https://github.com/plataformatec/devise) e o
[Authlogic](https://github.com/binarylogic/authlogic) entre outros.

### Outras Considerações de Segurança

Segurança, especialmente em aplicações web, é uma area ampla e detalhada. O
tópico de segurança aplicações Rails é coberto com mais detalhes em
[Guia de Segurança Ruby on Rails](security.html).

O que vem depois?
-----------------

Agora que você criou sua primeira aplicação Rails, sinta-se à vontade para
atualizar e experimentar por conta própria.

Lembre-se, você não precisa fazer tudo sem ajuda. Se você precisa de
assistência para começar a desenvolver com Rails, sinta-se à vontade para
consultar estes recursos:

* O [Guia Rails](index.html)
* O [Ruby on Rails Guides](https://guides.rubyonrails.org)
* A [lista de discussão do Ruby on Rails](https://discuss.rubyonrails.org/c/rubyonrails-talk)
* O canal [#rubyonrails](irc://irc.freenode.net/#rubyonrails) no irc.freenode.net


Dicas de Configuração
---------------------

O caminho mais fácil para se trabalhar com o Rails é armazenar todos os dados
externos como UTF-8. Se não fizer assim, as bibliotecas Ruby e o Rails vão, na
maioria das vezes, conseguir converter seus dados nativos em UTF-8, porém não
é sempre que isso funciona corretamente, então é melhor que você assegure que
todos seus dados externos estão em UTF-8.

Caso tenha cometido um erro nessa parte, o sintoma mais comum é o aparecimento
de um diamante preto com um ponto de interrogação dentro no seu navegador. Outro
sintoma comum é o aparecimento de caracteres como "Ã¼" ao invés de "ü". O Rails
executa um número de passos internos para mitigar causas comuns desses problemas
que possam ser detectadas e corrigidas automaticamente. Porém, caso você possua
dados externos que não estão armazenados como UTF-8, eles poderão ocasionalmente
resultar em problemas que não podem ser detectados e nem resolvidos de forma
automática pelo Rails.

Duas fontes muito comuns de dados que não estão em UTF-8 são:

* Seu editor de texto: A maioria dos editores de texto (como o TextMate), salvam
  os arquivos em UTF-8 de forma padrão. Caso o seu editor de texto não salve,
  isso pode resultar em caracteres especiais inseridos por você nos seus
  _templates_ (como por exemplo: é) aparecerem no navegador como um diamante
  com um ponto de interrogação dentro. Isso também se aplica aos seus arquivos
  de tradução i18n. Muitos editores que não salvam em UTF-8 por padrão (como
  algumas versões do Dreamweaver) oferecem uma forma de alterar o padrão para
  UTF-8. Faça isso.
* Seu banco de dados: o Rails converte seus dados do banco de dados em UTF-8
  de forma padrão. Porém, se seu banco de dados não está utilizando UTF-8
  internamente, pode ser que não consiga armazenar todos os caracteres que seus
  usuários insiram. Por exemplo, se seu banco de dados está utilizando Latin-1
  internamente, e seu usuário inserir um caractere russo, hebraico ou japonês,
  os dados serão perdidos para sempre assim que entrarem no banco de dados. Se
  possível, utilize UTF-8 como padrão de armazenamento para o seu banco de dados.
