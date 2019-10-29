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
zero. Ela não assume que você tenha nenhuma experiência anterior com Rails.

Rails é um framework para aplicações web que é executado em cima da linguagem
de programação Ruby. Se você não tem nenhuma experiência com Ruby, você vai
achar a curva de aprendizado bastante íngrime começando direto com Rails.
Existem diversas listas organizadas de materiais online para aprender Ruby:

* [Site Oficial da Linguagem de Programação Ruby](https://www.ruby-lang.org/en/documentation/)
* [Lista de Livros Grátis de Programação](https://github.com/vhf/free-programming-books/blob/master/free-programming-books.md#ruby)

Fique atento que alguns materiais, apesar de excelentes, envolvem versões antigas
do Ruby chegando a 1.6, e frequentemente 1.8, e não incluem parte da sintaxe que você
vai ver no seu dia-a-dia desenvolvendo com Rails.

O que é o Rails?
--------------

Rails é um *framework* de desenvolvimento de aplicações *web* escrito na linguagem de programação Ruby.
Foi projetado para facilitar o desenvolvimento de aplicações *web*, criando premissas sobre tudo que uma pessoa desenvolvedora precisa para começar. Permite que você escreva menos código, enquanto realiza mais do que em muitas outras linguagens ou *frameworks.* Pessoas desenvolvedoras experientes em Rails, também dizem que desenvolver aplicações web ficou mais divertido.

Rails é um software opinativo. Assumindo que há uma "melhor" maneira para fazer as coisas, e foi projetado para encorajar essa maneira - e, em alguns casos para desencorajar alternativas. Se você aprender o "Rails Way", provavelmente terá um grande aumento de produtividade. Se você insistir nos velhos hábitos de outras linguagens, tentando usar os padrões que você aprendeu em outro lugar, você pode ter uma experiência menos feliz.

A filosofia do Rails possui dois princípios fundamentais:

* **Não repita a si mesmo:** DRY(don't repeat yourself) é um conceito de desenvolvimento de software que estabelece que "Todo conhecimento deve possuir uma representação única, de autoridade e livre de ambiguidades em todo o sistema.". Ao não escrever as mesmas informações repetidamente, o código fica mais facil de manter, de expandir, e com menos bugs.
* **Convenção sobre configuração:** Rails possui convenções sobre as melhores maneiras de fazer muitas coisas em uma aplicação web, devido a essas convenções você não precisa especificar minúcias através de arquivos de configuração infinitos.


Criando um Novo Projeto em Rails
---------------------------------
A melhor forma de ler esse guia é seguir o passo à passo. Todos os passos são
essenciais para rodar a aplicação de exemplo e nenhum código ou passos adicionais
serão necessários.

Seguindo este guia, você irá criar um projeto em *Rails* chamado de
`blog`, um *weblog* (muito) simples. Antes de você começar a construir a aplicação,
você precisa ter certeza de ter o *Rails* instalado.

DICA: Os exemplos à seguir usam `$` para representar seu *prompt* de terminal em um
sistema operacional baseado em UNIX, mesmo que ele tenha sido customizado para parecer diferente.
Se você está utilizando Windows, seu *prompt* será parecido com algo como `c:\source_code>`

### Instalando o Rails

Antes de você instalar o Rails, você deve validar para ter certeza que seu sistema
tem os pré requisitos necessários instalados. Esses incluem Ruby e SQLite3.

Abra o *prompt* de linha de comando. No *macOS* abra o *Terminal.app*, no *Windows*
escolha *executar* no menu inicial e digite 'cmd.exe'. Qualquer comando que antecede
o sinal de dólar `$` deverá ser rodado em linha de comando. Verifique se você tem a
versão atual do Ruby instalado:

```bash
$ ruby -v
ruby 2.5.0
```

Rails necessita da versão Ruby 2.5.0 ou mais atual. Se o número da versão retornada
for menor que este número, você precisará instalar uma versão do Ruby mais atual.

DICA: Para instalar o Ruby e o Ruby on Rails mais rápido no seu sistema operacional Windows,
você pode usar o [Rails Installer](http://railsinstaller.org). Para mais informações de instalação
de outros Sistemas Operacionais, dê uma olhada em [ruby-lang.org](https://www.ruby-lang.org/en/documentation/installation/).

Se você está utilizando o Windowns, você deve também instalar o
[Ruby Installer Development Kit](https://rubyinstaller.org/downloads/).

Você também precisará instalar o banco de dados SQLite3.
Muitos sistemas operacionais populares semelhantes ao UNIX são fornecidos com uma versão compatível do SQLite3.
No Windows, se você instalou o Rails pelo instalador do Rails, você
já possui o SQLite instalado. Você também podem achar mais instruções de instalação em [SQLite3 website](https://www.sqlite.org).
Verifique se está corretamente instalado e no seu *PATH*

```bash
$ sqlite3 --version
```

O programa deverá reportar sua versão.

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

Rails vem com vários scripts chamados *generators* que são projetados para tornar
sua vida de desenvolvedor fácil, criando tudo que é necessário para começar a
trabalhar em uma tarefa em particular. Um desses é o *generator* de nova aplicação,
que irá te fornecer a base de uma nova aplicação em Rails para que você não precise
escrever tudo sozinho.

Para utilizar esse *generator*, abra um terminal, navegue para um diretório onde
você tenha permissão para criar arquivos, e digite:

```bash
$ rails new blog
```

Este comando irá criar uma aplicação em Rails chamada Blog em um diretório `blog`
e irá instalar as dependências das *gems* que já foram mencionadas no `Gemfile`
usando `bundle install`.

OBS: Se você está utilizando um subsistema Windows para Linux então existem
algumas limitações nas notificações dos arquivos do sistema que significa que você
deve disabilitar as gems `spring` e `listen` que poderá ser feito rodando o comando
`rails new blog --skip-spring --skip-listen`.

DICA: Você pode ver todas as opções de linha de comando que a aplicação Rails
aceita rodando o comando `rails new -h`.

Depois de criar a aplicação blog, entre em sua pasta:

```bash
$ cd blog
```

A pasta `blog` tem vários arquivos auto-gerados e pastas que compõem a estrutura
de uma aplicação Rails. A maior parte da execução deste tutorial será feito na
pasta `app`, mas à seguir teremos um resumo básico das funções de cada um dos arquivos e pastas
que o Rails gerou por padrão:

| Arquivo/Pasta | Objetivo |
| ----------- | ------- |
|app/|Contém os *controllers*, *models*, *views*, *helpers*, *mailers*, *channels*, *jobs*, e *assets* para sua aplicação. Você irá se concentrar nesse diretório pelo restante desse guia.|
|bin/|Contém o script do Rails que inicializa sua aplicação e contém outros scripts que você utiliza para configurar, atualizar, colocar em produção ou executar sua aplicação.|
|config/|Configure as rotas, banco de dados entre outros de sua aplicação. Este conteúdo é abordado com mais detalhes em [Configuring Rails Applications](configuring.html).|
|config.ru|Configuração *Rack* para servidores baseados em *Rack* usados ​​para iniciar a aplicação. Para mais informações sobre o *Rack*, consulte [Rack website](https://rack.github.io/).|
|db/|Contém o *schema* do seu banco de dados atual, assim como as *migrations* do banco de dados.|
|Gemfile<br>Gemfile.lock|Esses arquivos permitem que você especifique quais dependências de *gem* são necessárias na sua aplicação Rails. Esses arquivos são usados pela *gem* Bundler. Para mais informações sobre o Bundler, acesse [o website do Bundler](https://bundler.io).|
|lib/|Módulos extendidos da sua aplicação.|
|log/|Arquivos de *log* da aplicação.|
|package.json|Este arquivo permite que você especifique quais dependências *npm* são necessárias para sua aplicação Rails. Este arquivo é usado pelo Yarn. Para mais informações do Yarn, acesse [o website do Yarn](https://yarnpkg.com/lang/en/).|
|public/|O único diretório visto pelo mundo. Contém arquivos estáticos e *assets* compilados.|
|Rakefile|Este arquivo localiza e carrega tarefas que podem ser rodadas por linhas de comando. As tarefas são definidas nos componentes do Rails. Ao invés de editar o `Rakefile`, você deve criar suas próprias tarefas adicionando os arquivos no diretório `lib/tasks` da sua aplicação.|
|README.md|Este é um manual de instruções para sua aplicação. Você deve editar este arquivo para informar o que seu aplicativo faz, como configurá-lo e assim por diante.|
|storage/|Arquivos de armazenamento ativo do serviço de disco. Mais informações em [Active Storage Overview](active_storage_overview.html).|
|test/|Testes unitários, *fixtures*, e outros tipos de testes. Mais informações em [Testing Rails Applications](testing.html).|
|tmp/|Arquivos temporários (como cache e arquivos *pid*).|
|vendor/|Diretório com todos os códigos de terceiros. Em uma típica aplicação Rails inclui *vendored gems*.|
|.gitignore|Este arquivo diz ao Git quais arquivos (ou padrões) devem ser ignorados. Acesse [GitHub - Ignoring files](https://help.github.com/articles/ignoring-files) para mais informações sobre arquivos ignorados.
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
$ rails server
```

TIP: Se você está usando Windows, deve executar os scripts do diretório
`bin` para o interpretador do Ruby: `ruby bin\rails server`.

TIP: A compressão de *assets* JavaScript requer que você tenha um executor
disponível em seu sistema operacional. Na ausência de um executor você verá um
erro de `execjs` durante a compilação dos *assets*. Geralmente o macOS e o Windows possuem um executor JavaScript instalado por
padrão. `therubyrhino` é o executor recomendado para usuários de JRuby e vem no
`Gemfile` por padrão em aplicações geradas com JRuby. Você pode avaliar todos
executores em [ExecJS](https://github.com/rails/execjs#readme).

A execução do comando irá iniciar o Puma, um servidor web distribuído com o
Rails por padrão. Para ver sua aplicação em execução, abra um navegador e
navegue para <http://localhost:3000>.  Você deve ver a página padrão com informações do Rails:

![Captura de tela de boas vindas do Rails](images/getting_started/rails_welcome.png)

TIP: Para interromper a execução do servidor Web, pressione Ctrl+C na janela do
terminal em que o servidor está sendo executado. Para verificar se o servidor
realmente foi interrompido, você deve ver o cursor do `prompt` novamente. Para a
maioria dos sistemas baseados em UNIX, incluindo o macOS, o cursor é
representando por um sinal de `$`. Em modo de desenvolvimento, o Rails
geralmente não exige que você reinicie o servidor; mudanças feitas nos arquivos
da aplicaçnao serão automaticamente aplicadas no servidor.

A página de "Boas vindas a bordo" é o _smoke test_ (teste de sanidade) para uma
nova aplicação Rails: garante que o seu software esteja configurado
corretamente, o suficiente para gerar uma página.

### Diga "Olá", Rails

Para que o Rails diga "Olá", você precisa criar no mínimo um _controller_ e uma
_view_.

O objetivo de um _controller_ é receber requisições específicas para a
aplicação. O _Routing_ (roteamento) decide qual _controller_ recebe quais
requisições. Muitas vezes, há mais de uma rota para cada _controller_, e
diferentes rotas podem ser providas por diferentes _actions_. O objetivo de cada
_action_ é coletar informações para fornecer para uma _view_.

O objetivo de uma _view_ é exibir essas informações em um formato legível para
humanos. Uma diferença importante a ser feita é que é no _controller_, não na
_view_, onde as informações são coletadas. A _view_ deve apenas exibir essas
informações. Por padrão, os _templates_ de _view_ são escritos em uma linguagem
chamada eRuby (_Embedded Ruby_) que é processada pelo ciclo da requisição no
Rail antes de ser enviada para o usuário.

Para criar um novo _controller_, você precisará executar o gerador de
_controller_ e informar que você deseja um _controller_ chamado "Welcome"
com uma _action_ chamada "index", exatamente assim:

```bash
$ rails generate controller Welcome index
```

O Rails criará vários arquivos e uma rota para você.

```bash
create  app/controllers/welcome_controller.rb
 route  get 'welcome/index'
invoke  erb
create    app/views/welcome
create    app/views/welcome/index.html.erb
invoke  test_unit
create    test/controllers/welcome_controller_test.rb
invoke  helper
create    app/helpers/welcome_helper.rb
invoke    test_unit
invoke  assets
invoke    scss
create      app/assets/stylesheets/welcome.scss
```

Os mais importantes são, certamente, o _controller_, localizado em
`app/controllers/welcome_controller.rb` e a _view_, localizada em
`app/views/welcome/index.html.erb`.

Abra o arquivo `app/views/welcome/index.html.erb` em seu editor de texto. Exclua
todo o código existente no arquivo e substitua pela linha de código abaixo:

```html
<h1>Olá, Rails!</h1>
```

### Configuração da Página Inicial da Aplicação

Agora que criamos o _controller_ e a _view_, precisamos informar ao Rails quando
queremos que "Olá, Rails" seja exibido. No nosso caso, queremos que seja exibido
quando navegarmos para a URL raiz de nosso site, <http://localhost:3000>. No
momento, "Boas vindas a bordo" é que está preenchendo esse lugar.

Em seguida, você deve informar ao Rails onde está localizada a sua página
inicial.

Abra o arquivo `config/routes.rb` em seu editor de texto.

```ruby
Rails.application.routes.draw do
  get 'welcome/index'

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
```

Este é o arquivo _routing_ (roteamento) da sua aplicação que contém
as entradas em um
[DSL (domain-specific language)](https://en.wikipedia.org/wiki/Domain-specific_language) especial
que informa ao Rails como conectar requisições de entrada com _controllers_ e
_actions_.
Edite este arquivo adicionando a linha de código `root 'welcome#index'`.
Deve ser algo parecido com o seguinte:

```ruby
Rails.application.routes.draw do
  get 'welcome/index'

  root 'welcome#index'
end
```

`root 'welcome#index'` informa ao Rails para mapear as requisições para a raiz
da aplicação para o _controller_ "welcome", _action_ "index" e `get
'welcome/index'` informa ao Rails para mapear as requisições para
<http://localhost:3000/welcome/index> para o _controller_ "welcome", _action_
"index". Isso foi criado anteriormente quando você executou o gerador de
_controller_ (`rails generate controller Welcome index`).

Inicie o servidor *web* novamente se você o interrompeu para gerar o _controller_
(`rails server`) e navegue até <http://localhost:3000> no seu navegador. Você
verá a mensagem "Olá, Rails!", a mesma que você colocou em
`app/views/welcome/index.html.erb`, indicando que essa nova rota de fato vai
para a _action_ `index` de `WelcomeController` e está renderizando a _view_
corretamente.

TIP: Para mais informações sobre roteamento, consulte [Roteamento do Rails de Fora para Dentro](routing.html).

Iniciando e Executando
----------------------

Agora que você já viu como criar um *controller*, uma *action*, e uma *view*, vamos criar algo um pouco mais relevante.

Na aplicação do Blog você irá criar um novo *resource*. *Resource* é um termo utilizado para uma coleção de objetos similares, como artigos, pessoas ou animais.
Você pode criar, visualizar, editar e deletar dados de um *resource* e essas ações são definidas como operações *CRUD*.

O Rails te fornece um método `resources` que pode ser usado para declarar um recurso padrão *REST*. Você precisa adicionar o *article resource* no `config/routes.rb` e o arquivo ficará como a seguir:

```ruby
Rails.application.routes.draw do
  get 'welcome/index'

  resources :articles

  root 'welcome#index'
end
```

Se você executar `rails routes`, você verá que foram definidas rotas para todas as *actions* padrão *RESTful*.
O significado do prefixo da coluna (e de outras colunas) será visto mais adiante, mas por enquanto, observe que o Rails entende `article` de forma singular e faz o uso significativo da distinção.

```bash
$ rails routes
       Prefix Verb   URI Pattern                  Controller#Action
welcome_index GET    /welcome/index(.:format)     welcome#index
     articles GET    /articles(.:format)          articles#index
              POST   /articles(.:format)          articles#create
  new_article GET    /articles/new(.:format)      articles#new
 edit_article GET    /articles/:id/edit(.:format) articles#edit
      article GET    /articles/:id(.:format)      articles#show
              PATCH  /articles/:id(.:format)      articles#update
              PUT    /articles/:id(.:format)      articles#update
              DELETE /articles/:id(.:format)      articles#destroy
         root GET    /                            welcome#index
```

Na próxima seção, você adicionará a funcionalidade para criar e visualizar novos artigos em sua aplicação. Este é o "C" e o "R" do *CRUD*: *create* (criação) e *read* (leitura). O formulário para fazer isso ficará assim:

![The new article form](images/getting_started/new_article.png)

Por enquanto está um pouco simples, mas tudo bem. Nós iremos melhorar o estilo mais adiante.

### Preparando a base

Primeiramente, você precisa de um lugar na aplicação para criar um novo artigo. Um ótimo lugar seria em `/articles/new`. Com a rota já definida, agora é possível fazer requisições para `/articles/new` na aplicação. Acesse <http://localhost:3000/articles/new> e você verá um erro de rota:

![Another routing error, uninitialized constant ArticlesController](images/getting_started/routing_error_no_controller.png)

Este erro ocorre porque a rota precisa ter um *controller* definido para atender à requisição. A solução para esse problema específico é simples: crie um *controller* chamado `ArticlesController`. Você pode fazer isso executando este comando:

```bash
$ rails generate controller Articles
```

Se você abrir o recém-criado `app/controllers/articles_controller.rb`
verá um *controller* vazio:

```ruby
class ArticlesController < ApplicationController
end
```

Um *controller* é uma classe definida para herdar de `ApplicationController`.
É dentro dessa classe que você define os métodos que se tornarão as ações desse *controller*. Essas ações executarão operações *CRUD* nos artigos em nosso sistema.

NOTE: Existem métodos `public`, `private` e `protected` no Ruby, mas apenas métodos `public` podem ser ações nos *controllers*. Para mais detalhes, consulte  [Programação Ruby](http://www.ruby-doc.org/docs/ProgrammingRuby/).

Se você atualizar <http://localhost:3000/articles/new> agora, receberá um novo erro:

![Unknown action new for ArticlesController!](images/getting_started/unknown_action_new_for_articles.png)

Este erro indica que o Rails não consegue encontrar a ação `new` dentro do `ArticlesController` que você acabou de gerar. Isso ocorre porque quando os *controllers* são gerados no Rails, eles estão vazios por padrão, a menos que você diga as ações que deseja durante o processo de geração.

Para definir manualmente uma ação dentro de um *controller*, tudo o que você precisa fazer é definir um novo método dentro do *controller*. Abra `app/controllers/articles_controller.rb` e, dentro da classe `ArticlesController`, defina o método `new` para que agora seu *controller* fique assim:

```ruby
class ArticlesController < ApplicationController
  def new
  end
end
```

Com o método `new` definido em `ArticlesController`, se você atualizar
<http://localhost:3000/articles/new> verá um outro erro:

![Template is missing for articles/new]
(images/getting_started/template_is_missing_articles_new.png)

Você está recebendo esse erro agora porque o Rails espera que *actions* como esta tenham *views* associadas a elas para exibir suas informações. Sem uma *view* disponível, o Rails gerará uma exceção.

Vamos ver a mensagem de erro completa novamente:

>ArticlesController#new  está faltando um *template* para o formato da requisição: *text/html*

>NOTA!
>Como dito, o Rails espera que uma ação renderize um *template* com o mesmo nome, contido em uma pasta com o nome de seu *controller*. Se esse *controller* for uma *API* que responde com 204 (sem conteúdo), e que não requer um *template*, então esse erro ocorrerá ao tentar acessá-lo pelo navegador pois esperamos que um *template* HTML seja renderizado para essas requisições. Se esse for o caso, continue.

A mensagem identifica qual *template* está ausente. Nesse caso, é o *template* `articles/new`. O Rails procurará primeiro esse *template*. Se não for encontrado, ele tentará carregar um *template* chamado `application/new`, porque o `ArticlesController` herda do `ApplicationController`.

Em seguida, a mensagem contém `request.formats` que especifica o formato do *template* a ser exibido em resposta. Ele está definido como `text/html`, conforme solicitamos esta página pelo navegador, portanto o Rails está procurando um *template* HTML.

O *template* mais simples que funcionaria nesse caso seria o localizado em `app/views/articles/new.html.erb`. A extensão desse nome de arquivo é importante: a primeira extensão é o formato do *template* e a segunda extensão é o *handler* (tratadores) que será usado para renderizar o *template*. O Rails está tentando encontrar um *template* chamado `articles/new` em `app/views` para a aplicação. O formato para este *template* pode ser apenas `html` e o *handler* padrão para HTML é `erb`. O Rails usa outros *handlers* para outros formatos. O *handler* de `builder` é usado para criar *templates* XML e o *handler* de `coffee` usa o CoffeeScript para criar *templates* JavaScript. Como você deseja criar um novo formulário HTML, você usará a linguagem `ERB` projetada para incorporar Ruby em HTML.

Portanto, o arquivo deve se chamar `articles/new.html.erb` e precisa estar localizado dentro do diretório `app/views` da aplicação.

Agora vá em frente e crie um novo arquivo em *app/views/articles/new.html.erb* e escreva este conteúdo:

```html
<h1>New Article</h1>
```

Ao atualizar <http://localhost:3000/articles/new> você verá que a página tem um título. A rota, o *controller*, a *action* e a *view* estão funcionando harmoniosamente! É hora de criar o formulário para um novo artigo.

### O primeiro formulário

Para criar um formulário com este template, você vai usar um construtor de formulário (*form builder*). O *form builder* principal do Rails é disponibilizado por um *helper* chamado `form_with`. Para utilizá-lo, adicione o código abaixo no arquivo `app/views/articles/new.html.erb`:

```html+erb
<%= form_with scope: :article, local: true do |form| %>
  <p>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </p>

  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>

  <p>
    <%= form.submit %>
  </p>
<% end %>
```

Se você atualizar a página, você vai ver o mesmo formulário do nosso exemplo acima.
Construir formulários no Rails é tão simples assim!

Quando você chama o `form_with`, você passa para ele a identificação do escopo para esse formulário.
Neste caso, o *symbol* `:article`. Isso mostra ao `form_with` para qual escopo é o formulário em questão. Dentro do bloco deste método, o objeto `FormBuilder` - representado pelo `form` - é usado para construir dois titulos e dois campos textos, para cada titulo e texto de um artigo. Finalmente, uma chamada ao `submit` do objeto `form` irá criar um botão de submissão do formulário.

Porém, existe um problema com este formulário. Se você inspecionar o HTML que foi gerado, visualizando o código-fonte da págia, você vai ver que o atributo *action* do formulário está apontando para `/articles/new`. Isso é um problema porque esta rota vai exatamente para a mesma página que você está no momento, e essa rota deveria ser usada apenas para exibir o formulário para um novo artigo.

O formulário precisa usar uma URL diferente para que consigar ir para outro lugar. Isso pode ser feito de forma simples com a opção `:url` do `form_with`. Normalment no Rails, a *action* que é usada para novas submissões de formários é chamada "create", então o formulário precisa apontar para esta ação.

Altere a linha do `form_with` dentro de `app/views/articles/new.html.erb` para ficar da seguinte forma:

```html+erb
<%= form_with scope: :article, url: articles_path, local: true do |form| %>
```

Neste exemplo, o *helper* `articles_path` é passado para a opção `:url`.

Para saber o que o Rails fará com isso, veja novamente o resultado do `rails routes`:

```bash
$ rails routes
      Prefix Verb   URI Pattern                  Controller#Action
welcome_index GET    /welcome/index(.:format)     welcome#index
     articles GET    /articles(.:format)          articles#index
              POST   /articles(.:format)          articles#create
  new_article GET    /articles/new(.:format)      articles#new
 edit_article GET    /articles/:id/edit(.:format) articles#edit
      article GET    /articles/:id(.:format)      articles#show
              PATCH  /articles/:id(.:format)      articles#update
              PUT    /articles/:id(.:format)      articles#update
              DELETE /articles/:id(.:format)      articles#destroy
         root GET    /                            welcome#index
```

O *helper* `articles_path` diz ao Rails para pontar o formulário para o padrão de URI associado com o prefixo `articles`; e o formulário vai (por padrão) enviar uma requisição `POST` para esta rota. Isto esta associado com a *action* `create` do `controller` atual, no caso o `ArticlesController`.

Com o formulário e sua rota definidos, você será capaz de preencher o formulário e clicar no botão *submit* para iniciar o processo de criação de um novo artigo, então vá em frente e faça isso. Quando você enviar, você verá um erro familiar:

![Unknown action create for ArticlesController]
(images/getting_started/unknown_action_create_for_articles.png)

Agora você precisa adicionar a *action* create dentro do `ArticlesController` para que isso funcione.

NOTE: Por padrão o `form_with` submete formulários usando Ajax, evitando assim o redirecionamento da página inteira. Para tornar este guia mais fácil de entender, por hora, nós desabilitamos isso ao utilizar o `local: true`.

### Creating articles

To make the "Unknown action" go away, you can define a `create` action within
the `ArticlesController` class in `app/controllers/articles_controller.rb`,
underneath the `new` action, as shown:

```ruby
class ArticlesController < ApplicationController
  def new
  end

  def create
  end
end
```

If you re-submit the form now, you may not see any change on the page. Don't worry!
This is because Rails by default returns `204 No Content` response for an action if
we don't specify what the response should be. We just added the `create` action
but didn't specify anything about how the response should be. In this case, the
`create` action should save our new article to the database.

When a form is submitted, the fields of the form are sent to Rails as
_parameters_. These parameters can then be referenced inside the controller
actions, typically to perform a particular task. To see what these parameters
look like, change the `create` action to this:

```ruby
def create
  render plain: params[:article].inspect
end
```

The `render` method here is taking a very simple hash with a key of `:plain` and
value of `params[:article].inspect`. The `params` method is the object which
represents the parameters (or fields) coming in from the form. The `params`
method returns an `ActionController::Parameters` object, which
allows you to access the keys of the hash using either strings or symbols. In
this situation, the only parameters that matter are the ones from the form.

TIP: Ensure you have a firm grasp of the `params` method, as you'll use it fairly regularly. Let's consider an example URL: **http://www.example.com/?username=dhh&email=dhh@email.com**. In this URL, `params[:username]` would equal "dhh" and `params[:email]` would equal "dhh@email.com".

If you re-submit the form one more time, you'll see something that looks like the following:

```ruby
<ActionController::Parameters {"title"=>"First Article!", "text"=>"This is my first article."} permitted: false>
```

This action is now displaying the parameters for the article that are coming in
from the form. However, this isn't really all that helpful. Yes, you can see the
parameters but nothing in particular is being done with them.

### Creating the Article model

Models in Rails use a singular name, and their corresponding database tables
use a plural name. Rails provides a generator for creating models, which most
Rails developers tend to use when creating new models. To create the new model,
run this command in your terminal:

```bash
$ rails generate model Article title:string text:text
```

With that command we told Rails that we want an `Article` model, together
with a _title_ attribute of type string, and a _text_ attribute
of type text. Those attributes are automatically added to the `articles`
table in the database and mapped to the `Article` model.

Rails responded by creating a bunch of files. For now, we're only interested
in `app/models/article.rb` and `db/migrate/20140120191729_create_articles.rb`
(your name could be a bit different). The latter is responsible for creating
the database structure, which is what we'll look at next.

TIP: Active Record is smart enough to automatically map column names to model
attributes, which means you don't have to declare attributes inside Rails
models, as that will be done automatically by Active Record.

### Running a Migration

As we've just seen, `rails generate model` created a _database migration_ file
inside the `db/migrate` directory. Migrations are Ruby classes that are
designed to make it simple to create and modify database tables. Rails uses
rake commands to run migrations, and it's possible to undo a migration after
it's been applied to your database. Migration filenames include a timestamp to
ensure that they're processed in the order that they were created.

If you look in the `db/migrate/YYYYMMDDHHMMSS_create_articles.rb` file
(remember, yours will have a slightly different name), here's what you'll find:

```ruby
class CreateArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :articles do |t|
      t.string :title
      t.text :text

      t.timestamps
    end
  end
end
```

The above migration creates a method named `change` which will be called when
you run this migration. The action defined in this method is also reversible,
which means Rails knows how to reverse the change made by this migration,
in case you want to reverse it later. When you run this migration it will create
an `articles` table with one string column and a text column. It also creates
two timestamp fields to allow Rails to track article creation and update times.

TIP: For more information about migrations, refer to [Active Record Migrations]
(active_record_migrations.html).

At this point, you can use a rails command to run the migration:

```bash
$ rails db:migrate
```

Rails will execute this migration command and tell you it created the Articles
table.

```bash
==  CreateArticles: migrating ==================================================
-- create_table(:articles)
   -> 0.0019s
==  CreateArticles: migrated (0.0020s) =========================================
```

NOTE. Because you're working in the development environment by default, this
command will apply to the database defined in the `development` section of your
`config/database.yml` file. If you would like to execute migrations in another
environment, for instance in production, you must explicitly pass it when
invoking the command: `rails db:migrate RAILS_ENV=production`.

### Saving data in the controller

Back in `ArticlesController`, we need to change the `create` action
to use the new `Article` model to save the data in the database.
Open `app/controllers/articles_controller.rb` and change the `create` action to
look like this:

```ruby
def create
  @article = Article.new(params[:article])

  @article.save
  redirect_to @article
end
```

Here's what's going on: every Rails model can be initialized with its
respective attributes, which are automatically mapped to the respective
database columns. In the first line we do just that (remember that
`params[:article]` contains the attributes we're interested in). Then,
`@article.save` is responsible for saving the model in the database. Finally,
we redirect the user to the `show` action, which we'll define later.

TIP: You might be wondering why the `A` in `Article.new` is capitalized above, whereas most other references to articles in this guide have used lowercase. In this context, we are referring to the class named `Article` that is defined in `app/models/article.rb`. Class names in Ruby must begin with a capital letter.

TIP: As we'll see later, `@article.save` returns a boolean indicating whether
the article was saved or not.

If you now go to <http://localhost:3000/articles/new> you'll *almost* be able
to create an article. Try it! You should get an error that looks like this:

![Forbidden attributes for new article]
(images/getting_started/forbidden_attributes_for_new_article.png)

Rails has several security features that help you write secure applications,
and you're running into one of them now. This one is called [strong parameters](action_controller_overview.html#strong-parameters),
which requires us to tell Rails exactly which parameters are allowed into our
controller actions.

Why do you have to bother? The ability to grab and automatically assign all
controller parameters to your model in one shot makes the programmer's job
easier, but this convenience also allows malicious use. What if a request to
the server was crafted to look like a new article form submit but also included
extra fields with values that violated your application's integrity? They would
be 'mass assigned' into your model and then into the database along with the
good stuff - potentially breaking your application or worse.

We have to define our permitted controller parameters to prevent wrongful mass
assignment. In this case, we want to both allow and require the `title` and
`text` parameters for valid use of `create`. The syntax for this introduces
`require` and `permit`. The change will involve one line in the `create`
action:

```ruby
  @article = Article.new(params.require(:article).permit(:title, :text))
```

This is often factored out into its own method so it can be reused by multiple
actions in the same controller, for example `create` and `update`. Above and
beyond mass assignment issues, the method is often made `private` to make sure
it can't be called outside its intended context. Here is the result:

```ruby
def create
  @article = Article.new(article_params)

  @article.save
  redirect_to @article
end

private
  def article_params
    params.require(:article).permit(:title, :text)
  end
```

TIP: For more information, refer to the reference above and
[this blog article about Strong Parameters]
(https://weblog.rubyonrails.org/2012/3/21/strong-parameters/).

### Showing Articles

If you submit the form again now, Rails will complain about not finding the
`show` action. That's not very useful though, so let's add the `show` action
before proceeding.

As we have seen in the output of `rails routes`, the route for `show` action is
as follows:

```
article GET    /articles/:id(.:format)      articles#show
```

The special syntax `:id` tells rails that this route expects an `:id`
parameter, which in our case will be the id of the article.

As we did before, we need to add the `show` action in
`app/controllers/articles_controller.rb` and its respective view.

NOTE: A frequent practice is to place the standard CRUD actions in each
controller in the following order: `index`, `show`, `new`, `edit`, `create`, `update`
and `destroy`. You may use any order you choose, but keep in mind that these
are public methods; as mentioned earlier in this guide, they must be placed
before declaring `private` visibility in the controller.

Given that, let's add the `show` action, as follows:

```ruby
class ArticlesController < ApplicationController
  def show
    @article = Article.find(params[:id])
  end

  def new
  end

  # snippet for brevity
```

A couple of things to note. We use `Article.find` to find the article we're
interested in, passing in `params[:id]` to get the `:id` parameter from the
request. We also use an instance variable (prefixed with `@`) to hold a
reference to the article object. We do this because Rails will pass all instance
variables to the view.

Now, create a new file `app/views/articles/show.html.erb` with the following
content:

```html+erb
<p>
  <strong>Title:</strong>
  <%= @article.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @article.text %>
</p>
```

With this change, you should finally be able to create new articles.
Visit <http://localhost:3000/articles/new> and give it a try!

![Show action for articles](images/getting_started/show_action_for_articles.png)

### Listing all articles

We still need a way to list all our articles, so let's do that.
The route for this as per output of `rails routes` is:

```
articles GET    /articles(.:format)          articles#index
```

Add the corresponding `index` action for that route inside the
`ArticlesController` in the `app/controllers/articles_controller.rb` file.
When we write an `index` action, the usual practice is to place it as the
first method in the controller. Let's do it:

```ruby
class ArticlesController < ApplicationController
  def index
    @articles = Article.all
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
  end

  # snippet for brevity
```

And then finally, add the view for this action, located at
`app/views/articles/index.html.erb`:

```html+erb
<h1>Listing articles</h1>

<table>
  <tr>
    <th>Title</th>
    <th>Text</th>
    <th></th>
  </tr>

  <% @articles.each do |article| %>
    <tr>
      <td><%= article.title %></td>
      <td><%= article.text %></td>
      <td><%= link_to 'Show', article_path(article) %></td>
    </tr>
  <% end %>
</table>
```

Now if you go to <http://localhost:3000/articles> you will see a list of all the
articles that you have created.

### Adding links

You can now create, show, and list articles. Now let's add some links to
navigate through pages.

Open `app/views/welcome/index.html.erb` and modify it as follows:

```html+erb
<h1>Hello, Rails!</h1>
<%= link_to 'My Blog', controller: 'articles' %>
```

The `link_to` method is one of Rails' built-in view helpers. It creates a
hyperlink based on text to display and where to go - in this case, to the path
for articles.

Let's add links to the other views as well, starting with adding this
"New Article" link to `app/views/articles/index.html.erb`, placing it above the
`<table>` tag:

```erb
<%= link_to 'New article', new_article_path %>
```

This link will allow you to bring up the form that lets you create a new article.

Now, add another link in `app/views/articles/new.html.erb`, underneath the
form, to go back to the `index` action:

```erb
<%= form_with scope: :article, url: articles_path, local: true do |form| %>
  ...
<% end %>

<%= link_to 'Back', articles_path %>
```

Finally, add a link to the `app/views/articles/show.html.erb` template to
go back to the `index` action as well, so that people who are viewing a single
article can go back and view the whole list again:

```html+erb
<p>
  <strong>Title:</strong>
  <%= @article.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @article.text %>
</p>

<%= link_to 'Back', articles_path %>
```

TIP: If you want to link to an action in the same controller, you don't need to
specify the `:controller` option, as Rails will use the current controller by
default.

TIP: In development mode (which is what you're working in by default), Rails
reloads your application with every browser request, so there's no need to stop
and restart the web server when a change is made.

### Adding Some Validation

The model file, `app/models/article.rb` is about as simple as it can get:

```ruby
class Article < ApplicationRecord
end
```

There isn't much to this file - but note that the `Article` class inherits from
`ApplicationRecord`. `ApplicationRecord` inherits from `ActiveRecord::Base`
which supplies a great deal of functionality to your Rails models for free,
including basic database CRUD (Create, Read, Update, Destroy) operations, data
validation, as well as sophisticated search support and the ability to relate
multiple models to one another.

Rails includes methods to help you validate the data that you send to models.
Open the `app/models/article.rb` file and edit it:

```ruby
class Article < ApplicationRecord
  validates :title, presence: true,
                    length: { minimum: 5 }
end
```

These changes will ensure that all articles have a title that is at least five
characters long. Rails can validate a variety of conditions in a model,
including the presence or uniqueness of columns, their format, and the
existence of associated objects. Validations are covered in detail in [Active
Record Validations](active_record_validations.html).

With the validation now in place, when you call `@article.save` on an invalid
article, it will return `false`. If you open
`app/controllers/articles_controller.rb` again, you'll notice that we don't
check the result of calling `@article.save` inside the `create` action.
If `@article.save` fails in this situation, we need to show the form back to the
user. To do this, change the `new` and `create` actions inside
`app/controllers/articles_controller.rb` to these:

```ruby
def new
  @article = Article.new
end

def create
  @article = Article.new(article_params)

  if @article.save
    redirect_to @article
  else
    render 'new'
  end
end

private
  def article_params
    params.require(:article).permit(:title, :text)
  end
```

The `new` action is now creating a new instance variable called `@article`, and
you'll see why that is in just a few moments.

Notice that inside the `create` action we use `render` instead of `redirect_to`
when `save` returns `false`. The `render` method is used so that the `@article`
object is passed back to the `new` template when it is rendered. This rendering
is done within the same request as the form submission, whereas the
`redirect_to` will tell the browser to issue another request.

If you reload
<http://localhost:3000/articles/new> and
try to save an article without a title, Rails will send you back to the
form, but that's not very useful. You need to tell the user that
something went wrong. To do that, you'll modify
`app/views/articles/new.html.erb` to check for error messages:

```html+erb
<%= form_with scope: :article, url: articles_path, local: true do |form| %>

  <% if @article.errors.any? %>
    <div id="error_explanation">
      <h2>
        <%= pluralize(@article.errors.count, "error") %> prohibited
        this article from being saved:
      </h2>
      <ul>
        <% @article.errors.full_messages.each do |msg| %>
          <li><%= msg %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <p>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </p>

  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>

  <p>
    <%= form.submit %>
  </p>

<% end %>

<%= link_to 'Back', articles_path %>
```

A few things are going on. We check if there are any errors with
`@article.errors.any?`, and in that case we show a list of all
errors with `@article.errors.full_messages`.

`pluralize` is a rails helper that takes a number and a string as its
arguments. If the number is greater than one, the string will be automatically
pluralized.

The reason why we added `@article = Article.new` in the `ArticlesController` is
that otherwise `@article` would be `nil` in our view, and calling
`@article.errors.any?` would throw an error.

TIP: Rails automatically wraps fields that contain an error with a div
with class `field_with_errors`. You can define a CSS rule to make them
standout.

Now you'll get a nice error message when saving an article without a title when
you attempt to do just that on the new article form
<http://localhost:3000/articles/new>:

![Form With Errors](images/getting_started/form_with_errors.png)

### Updating Articles

We've covered the "CR" part of CRUD. Now let's focus on the "U" part, updating
articles.

The first step we'll take is adding an `edit` action to the `ArticlesController`,
generally between the `new` and `create` actions, as shown:

```ruby
def new
  @article = Article.new
end

def edit
  @article = Article.find(params[:id])
end

def create
  @article = Article.new(article_params)

  if @article.save
    redirect_to @article
  else
    render 'new'
  end
end
```

The view will contain a form similar to the one we used when creating
new articles. Create a file called `app/views/articles/edit.html.erb` and make
it look as follows:

```html+erb
<h1>Edit article</h1>

<%= form_with(model: @article, local: true) do |form| %>

  <% if @article.errors.any? %>
    <div id="error_explanation">
      <h2>
        <%= pluralize(@article.errors.count, "error") %> prohibited
        this article from being saved:
      </h2>
      <ul>
        <% @article.errors.full_messages.each do |msg| %>
          <li><%= msg %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <p>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </p>

  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>

  <p>
    <%= form.submit %>
  </p>

<% end %>

<%= link_to 'Back', articles_path %>
```

This time we point the form to the `update` action, which is not defined yet
but will be very soon.

Passing the article object to the `form_with` method will automatically set the URL for
submitting the edited article form. This option tells Rails that we want this
form to be submitted via the `PATCH` HTTP method, which is the HTTP method you're
expected to use to **update** resources according to the REST protocol.

Also, passing a model object to `form_with`, like `model: @article` in the edit
view above, will cause form helpers to fill in form fields with the corresponding
values of the object.  Passing in a symbol scope such as `scope: :article`, as
was done in the new view, only creates empty form fields.
More details can be found in [form_with documentation]
(https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with).

Next, we need to create the `update` action in
`app/controllers/articles_controller.rb`.
Add it between the `create` action and the `private` method:

```ruby
def create
  @article = Article.new(article_params)

  if @article.save
    redirect_to @article
  else
    render 'new'
  end
end

def update
  @article = Article.find(params[:id])

  if @article.update(article_params)
    redirect_to @article
  else
    render 'edit'
  end
end

private
  def article_params
    params.require(:article).permit(:title, :text)
  end
```

The new method, `update`, is used when you want to update a record
that already exists, and it accepts a hash containing the attributes
that you want to update. As before, if there was an error updating the
article we want to show the form back to the user.

We reuse the `article_params` method that we defined earlier for the create
action.

TIP: It is not necessary to pass all the attributes to `update`. For example,
if `@article.update(title: 'A new title')` was called, Rails would only update
the `title` attribute, leaving all other attributes untouched.

Finally, we want to show a link to the `edit` action in the list of all the
articles, so let's add that now to `app/views/articles/index.html.erb` to make
it appear next to the "Show" link:

```html+erb
<table>
  <tr>
    <th>Title</th>
    <th>Text</th>
    <th colspan="2"></th>
  </tr>

  <% @articles.each do |article| %>
    <tr>
      <td><%= article.title %></td>
      <td><%= article.text %></td>
      <td><%= link_to 'Show', article_path(article) %></td>
      <td><%= link_to 'Edit', edit_article_path(article) %></td>
    </tr>
  <% end %>
</table>
```

And we'll also add one to the `app/views/articles/show.html.erb` template as
well, so that there's also an "Edit" link on an article's page. Add this at the
bottom of the template:

```html+erb
...

<%= link_to 'Edit', edit_article_path(@article) %> |
<%= link_to 'Back', articles_path %>
```

And here's how our app looks so far:

![Index action with edit link](images/getting_started/index_action_with_edit_link.png)

### Using partials to clean up duplication in views

Our `edit` page looks very similar to the `new` page; in fact, they
both share the same code for displaying the form. Let's remove this
duplication by using a view partial. By convention, partial files are
prefixed with an underscore.

TIP: You can read more about partials in the
[Layouts and Rendering in Rails](layouts_and_rendering.html) guide.

Create a new file `app/views/articles/_form.html.erb` with the following
content:

```html+erb
<%= form_with model: @article, local: true do |form| %>

  <% if @article.errors.any? %>
    <div id="error_explanation">
      <h2>
        <%= pluralize(@article.errors.count, "error") %> prohibited
        this article from being saved:
      </h2>
      <ul>
        <% @article.errors.full_messages.each do |msg| %>
          <li><%= msg %></li>
        <% end %>
      </ul>
    </div>
  <% end %>

  <p>
    <%= form.label :title %><br>
    <%= form.text_field :title %>
  </p>

  <p>
    <%= form.label :text %><br>
    <%= form.text_area :text %>
  </p>

  <p>
    <%= form.submit %>
  </p>

<% end %>
```

Everything except for the `form_with` declaration remained the same.
The reason we can use this shorter, simpler `form_with` declaration
to stand in for either of the other forms is that `@article` is a *resource*
corresponding to a full set of RESTful routes, and Rails is able to infer
which URI and method to use.
For more information about this use of `form_with`, see [Resource-oriented style]
(https://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-form_with-label-Resource-oriented+style).

Now, let's update the `app/views/articles/new.html.erb` view to use this new
partial, rewriting it completely:

```html+erb
<h1>New article</h1>

<%= render 'form' %>

<%= link_to 'Back', articles_path %>
```

Then do the same for the `app/views/articles/edit.html.erb` view:

```html+erb
<h1>Edit article</h1>

<%= render 'form' %>

<%= link_to 'Back', articles_path %>
```

### Deleting Articles

We're now ready to cover the "D" part of CRUD, deleting articles from the
database. Following the REST convention, the route for
deleting articles as per output of `rails routes` is:

```ruby
DELETE /articles/:id(.:format)      articles#destroy
```

The `delete` routing method should be used for routes that destroy
resources. If this was left as a typical `get` route, it could be possible for
people to craft malicious URLs like this:

```html
<a href='http://example.com/articles/1/destroy'>look at this cat!</a>
```

We use the `delete` method for destroying resources, and this route is mapped
to the `destroy` action inside `app/controllers/articles_controller.rb`, which
doesn't exist yet. The `destroy` method is generally the last CRUD action in
the controller, and like the other public CRUD actions, it must be placed
before any `private` or `protected` methods. Let's add it:

```ruby
def destroy
  @article = Article.find(params[:id])
  @article.destroy

  redirect_to articles_path
end
```

The complete `ArticlesController` in the
`app/controllers/articles_controller.rb` file should now look like this:

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

  def edit
    @article = Article.find(params[:id])
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article
    else
      render 'new'
    end
  end

  def update
    @article = Article.find(params[:id])

    if @article.update(article_params)
      redirect_to @article
    else
      render 'edit'
    end
  end

  def destroy
    @article = Article.find(params[:id])
    @article.destroy

    redirect_to articles_path
  end

  private
    def article_params
      params.require(:article).permit(:title, :text)
    end
end
```

You can call `destroy` on Active Record objects when you want to delete
them from the database. Note that we don't need to add a view for this
action since we're redirecting to the `index` action.

Finally, add a 'Destroy' link to your `index` action template
(`app/views/articles/index.html.erb`) to wrap everything together.

```html+erb
<h1>Listing Articles</h1>
<%= link_to 'New article', new_article_path %>
<table>
  <tr>
    <th>Title</th>
    <th>Text</th>
    <th colspan="3"></th>
  </tr>

  <% @articles.each do |article| %>
    <tr>
      <td><%= article.title %></td>
      <td><%= article.text %></td>
      <td><%= link_to 'Show', article_path(article) %></td>
      <td><%= link_to 'Edit', edit_article_path(article) %></td>
      <td><%= link_to 'Destroy', article_path(article),
              method: :delete,
              data: { confirm: 'Are you sure?' } %></td>
    </tr>
  <% end %>
</table>
```

Here we're using `link_to` in a different way. We pass the named route as the
second argument, and then the options as another argument. The `method: :delete`
and `data: { confirm: 'Are you sure?' }` options are used as HTML5 attributes so
that when the link is clicked, Rails will first show a confirm dialog to the
user, and then submit the link with method `delete`.  This is done via the
JavaScript file `rails-ujs` which is automatically included in your
application's layout (`app/views/layouts/application.html.erb`) when you
generated the application. Without this file, the confirmation dialog box won't
appear.

![Confirm Dialog](images/getting_started/confirm_dialog.png)

TIP: Learn more about Unobtrusive JavaScript on
[Working With JavaScript in Rails](working_with_javascript_in_rails.html) guide.

Congratulations, you can now create, show, list, update, and destroy
articles.

TIP: In general, Rails encourages using resources objects instead of
declaring routes manually. For more information about routing, see
[Rails Routing from the Outside In](routing.html).

Adicionando um Segundo Model
----------------------------

É hora de adicionar um segundo *model* à aplicação. O segundo *model* vai lidar com
comentários em artigos.

### Gerando um Model

Nós veremos o mesmo *generator* que usamos antes quando criamos o *model*
`Article` (artigo, inglês). Desta vez vamos criar um *model* `Comment` (comentário)
que contém a referência para um artigo. Rode esse comando no seu terminal:

```bash
$ rails generate model Comment commenter:string body:text article:references
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
$ rails db:migrate
```

O Rails é inteligente o suficiente para executar somente as migrações que ainda
não foram rodadas no banco de dados atual, assim neste caso você verá:

```bash
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
  validates :title, presence: true,
                    length: { minimum: 5 }
end
```

Estas duas declarações habilitam uma boa parte de comportamento automático. Por
exemplo, se você possui uma instância da variável `@article` que contém um
artigo, você pode recuperar todos os comentários pertencentes àquele artigo na
forma de um *array* usando `@article.comments`.

TIP: Para mais informações sobre associações do *Active Record*, veja o guia
[Associações no Active Record](association_basics.html).

### Adicionando a Rota para Comentários

Da mesma forma que o *controller* `welcome`, nós vamos precisar adicionar a
rota para que o Rails saiba para onde queremos navegar para encontrar
`comments`. Abra o arquivo `config/routes.rb` novamente e o edite da seguinte
maneira:

```ruby
resources :articles do
  resources :comments
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
$ rails generate controller Comments
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
<p>
  <strong>Title:</strong>
  <%= @article.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @article.text %>
</p>

<h2>Add a comment:</h2>
<%= form_with(model: [ @article, @article.comments.build ], local: true) do |form| %>
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

<%= link_to 'Edit', edit_article_path(@article) %> |
<%= link_to 'Back', articles_path %>
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
<p>
  <strong>Title:</strong>
  <%= @article.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @article.text %>
</p>

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
<%= form_with(model: [ @article, @article.comments.build ], local: true) do |form| %>
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

<%= link_to 'Edit', edit_article_path(@article) %> |
<%= link_to 'Back', articles_path %>
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
<p>
  <strong>Title:</strong>
  <%= @article.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @article.text %>
</p>

<h2>Comments</h2>
<%= render @article.comments %>

<h2>Add a comment:</h2>
<%= form_with(model: [ @article, @article.comments.build ], local: true) do |form| %>
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

<%= link_to 'Edit', edit_article_path(@article) %> |
<%= link_to 'Back', articles_path %>
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
<%= form_with(model: [ @article, @article.comments.build ], local: true) do |form| %>
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
<p>
  <strong>Title:</strong>
  <%= @article.title %>
</p>

<p>
  <strong>Text:</strong>
  <%= @article.text %>
</p>

<h2>Comments</h2>
<%= render @article.comments %>

<h2>Add a comment:</h2>
<%= render 'comments/form' %>

<%= link_to 'Edit', edit_article_path(@article) %> |
<%= link_to 'Back', articles_path %>
```

O segundo *render* apenas define o template de *partial* que queremos renderizar,
`comments/form`. O Rails é inteligente o suficiente para entender a barra nessa
string e perceber que você quer renderizar o arquivo `_form.html.erb` no
diretório `app/views/comments`.

O objeto `@article` está disponível para todas as *partials* renderizadas na view
porque o definimos como uma variável de instância.

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
               data: { confirm: 'Você tem certeza?' } %>
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
  has_many :comments, dependent: :destroy
  validates :title, presence: true,
                    length: { minimum: 5 }
end
```

Segurança
--------

### Autenticação Básica

Se fosse fosse publicar o seu blog online, qualquer um poderia adicionar, editar
e deletar seus artigos ou comentários.

O Rails disponibiliza um sistema de autenticação HTTP simples que irá funcionar
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
* O [Ruby on Rails Tutorial](https://www.railstutorial.org/book)
* A [lista de discussão do Ruby on Rails](https://groups.google.com/group/rubyonrails-talk)
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
  internamente, e seu usuário insira um caractere russo, hebraico ou japonês,
  os dados serão perdidos para sempre assim que entrarem no banco de dados. Se
  possível, utilize UTF-8 como padrão de armazenamento para o seu banco de dados.
