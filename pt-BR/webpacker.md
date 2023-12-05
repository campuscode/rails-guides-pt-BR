**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Webpacker
=========

Esse guia irá mostrar como instalar e usar o Webpacker para empacotar JavaScript, CSS e outros *assets* para a lado cliente da sua aplicação Rails mas por favor note que o [Webpacker foi aposentado](https://github.com/rails/webpacker#webpacker-has-been-retired-).

Depois de ler esse guia, você saberá:

* O que o Webpacker faz e o como ele é diferente do Sprockets.
* Como instalar o Webpacker e integrar com seu _framework_ de escolha.
* Como usar o Webpacker para *assets* JavaScript.
* Como usar o Webpacker para *assets* CSS.
* Como usar o Webpacker para *assets* estáticos.
* Como fazer deploy de uma aplicação que usa Webpacker.
* Como usar o Webpacker em contextos Rails alternativos, como *engines* ou *containers* Docker.

--------------------------------------------------------------

O que é Webpacker?
------------------

Webpacker é um *wrapper* Rails feito com o sistema de *build* [webpack](https://webpack.js.org) que provê uma configuração padrão webpack e bons padrões.

### O que é webpack?

O intuito do webpack, ou qualquer sistema de *build* front-end, é permitir que você escreva código front-end de maneira conveniente para pessoas desenvolvedoras e depois empacotar o código de maneira conveniente para navegadores. Com o webpack, você pode gerenciar Javascript, CSS e *assets* estáticos, como imagens e fontes. O webpack permite que você escreva seu código, referencie outro código na aplicação, transforme seu código e combine ele em pacotes que podem ser facilmente baixados.

Veja a [documentação do webpack](https://webpack.js.org) para mais informações.

### Como o Webpacker é diferente do Sprockets?

O Rails também funciona com o Sprockets, uma ferramenta de empacotamento de *assets* que tem algumas funcionalidade em comum com o Webpacker. Ambas vão compilar seu Javascript em arquivos "amigáveis" para o navegador, além de minificar e adicionar *fingerprints* neles em produção. Em ambiente de desenvolvimento, o Sprockets e o Webpacker permitem que você altere arquivos de maneira incremental.

O Sprockets, que foi feito para ser usado com Rails, é mais simples de integrar. Particularmente, o código pode ser adicionado ao Sprockets por meio de uma *gem* Ruby. Todavia, o webpack integra melhor com mais ferramentas atuais de javascript e pacotes NPM e disponibiliza mais variedade de integrações. Aplicações novas Rails são configuradas para usar o webpack para Javascript e Sprockets para CSS, apesar de que você também pode utilizar o webpack para o CSS.

Você deve escolher o Webpacker em vez de Sprockets em um projeto novo se quiser utilizar pacotes NPM e/ou quiser acessar funcionalidades e ferramentas mais atuais de Javascript. Você deve escolher Sprockets em vez do Webpacker para aplicações legadas onde migrações podem ser custosas, se você quiser integrar usando Gems ou se tiver uma quantidade pequena de código a ser empacotado.

Se você estiver familiarizado com o Sprockets, o guia a seguir pode trazer ideias de correspondência entre as duas ferramentas. Por favor, note que cada ferramenta tem uma estrutura diferente, e os conceitos não são exatamentes iguais um ao outro.

|Tarefa               | Sprockets            | Webpacker         |
|---------------------|----------------------|-------------------|
|Vincular JavaScript  |javascript_include_tag|javascript_pack_tag|
|Vincular CSS         |stylesheet_link_tag   |stylesheet_pack_tag|
|Link de uma imagem   |image_url             |image_pack_tag     |
|Link de um *asset*   |asset_url             |asset_pack_tag     |
|Requerer um *script* |//= require           |import or require  |

Installing Webpacker
--------------------

To use Webpacker, you must install the Yarn package manager, version 1.x or up, and you must have Node.js installed, version 10.13.0 and up.

NOTE: Webpacker depends on NPM and Yarn. NPM, the Node package manager registry, is the primary repository for publishing and downloading open-source JavaScript projects, both for Node.js and browser runtimes. It is analogous to rubygems.org for Ruby gems. Yarn is a command-line utility that enables the installation and management of JavaScript dependencies, much like Bundler does for Ruby.

To include Webpacker in a new project, add `--webpack` to the `rails new` command. To add Webpacker to an existing project, add the `webpacker` gem to the project's `Gemfile`, run `bundle install`, and then run `bin/rails webpacker:install`.

Installing Webpacker creates the following local files:

|File                    |Location                |Explanation                                                                                         |
|------------------------|------------------------|----------------------------------------------------------------------------------------------------|
|JavaScript Folder       | `app/javascript`       |A place for your front-end source                                                                   |
|Webpacker Configuration | `config/webpacker.yml` |Configure the Webpacker gem                                                                         |
|Babel Configuration     | `babel.config.js`      |Configuration for the [Babel](https://babeljs.io) JavaScript Compiler                               |
|PostCSS Configuration   | `postcss.config.js`    |Configuration for the [PostCSS](https://postcss.org) CSS Post-Processor                             |
|Browserlist             | `.browserslistrc`      |[Browserlist](https://github.com/browserslist/browserslist) manages target browsers configuration   |


The installation also calls the `yarn` package manager, creates a `package.json` file with a basic set of packages listed, and uses Yarn to install these dependencies.

Uso
-----

### Usando Webpacker para JavaScript

Com Webpacker instalado, qualquer arquivo JavaScript no diretório `app/javascript/packs` será compilado para seu próprio arquivo de pacote padrão.

Então, se você tem um arquivo chamado `app/javascript/packs/application.js`, Webpacker irá criar um pacote chamado `application`, e você pode adicionar isto para sua aplicação Rails com o código `<%= javascript_pack_tag "application" %>`. Com isso no lugar, em desenvolvimento, Rails irá recompilar o arquivo `application.js` a cada vez que é alterado, e você carrega uma página que usa esse pacote. Normalmente, o arquivo no diretório `packs` real será um manifesto que carrega na sua maior parte outros arquivos, mas também pode ter código JavaScript arbitrário.

O pacote padrão criado para você pelo Webpacker será vinculado aos pacotes JavaScript padrão do Rails se eles tiverem sido incluídos no projeto:

```
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()
```

Você precisará incluir um pacote que requeira esses pacotes para usá-los em seu aplicativo Rails.

É importante notar que apenas os arquivos de entrada do Webpack devem ser colocados no diretório `app/javascript/packs`; O Webpack criará um gráfico de dependência separado para cada ponto de entrada, portanto, um grande número de pacotes aumentará a sobrecarga de compilação. O restante do código-fonte do seu ativo deve ficar fora desse diretório, embora o Webpacker não coloque nenhuma restrição ou faça sugestões sobre como estruturar seu código-fonte. Aqui está um exemplo:

```sh
app/javascript:
  ├── packs:
  │   # apenas arquivos de entrada do webpack aqui
  │   └── application.js
  │   └── application.css
  └── src:
  │   └── my_component.js
  └── stylesheets:
  │   └── my_styles.css
  └── images:
      └── logo.svg
```

Normalmente, o próprio arquivo de pacote é em grande parte um manifesto que usa `import` ou `require` para carregar os arquivos necessários e também pode fazer alguma inicialização.

Se você quiser mudar esses diretórios, você pode ajustar o `source_path` (padrão `app/javascript`) e `source_entry_path` (padrão `packs`) no arquivo `config/webpacker.yml`.

Dentro dos arquivos de código fonte, as declarações `import` são resolvidas em relação ao arquivo fazendo a importação, então `import Bar from "./foo"` encontra um arquivo `foo.js` no mesmo diretório que o arquivo atual, enquanto `import Bar from "../src/foo"` encontra um arquivo em um diretório irmão chamado `src`.

### Usando Webpacker para CSS

Pronto para uso, o Webpacker suporta CSS e SCSS usando o processador PostCSS.

Para incluir código CSS em seus pacotes, primeiro inclua seus arquivos CSS em seu arquivo de pacote de nível superior como se fosse um arquivo JavaScript. Portanto, se seu manifesto CSS de nível superior estiver em `app/javascript/styles/styles.scss`, você poderá importá-lo com `import styles/styles`. Isso diz ao webpack para incluir seu arquivo CSS no download. Para realmente carregá-lo na página, inclua `<%= stylesheet_pack_tag "application" %>` na visualização, onde o `application` é o mesmo nome do pacote que você estava usando.

Se você estiver usando um framework CSS, você pode adicioná-lo ao Webpacker seguindo as instruções para carregar o framework como um módulo NPM usando `yarn`, normalmente `yarn add <framework>`. A estrutura deve ter instruções sobre como importá-la para um arquivo CSS ou SCSS.

### Usando Webpacker para Assets Estáticos

A [configuração](https://github.com/rails/webpacker/blob/master/lib/install/config/webpacker.yml#L21) do Webpack padrão deve funcionar imediatamente para _assets_ estáticos.
A configuração inclui várias extensões de formato de arquivo de imagem e fonte, permitindo que o webpack as inclua no arquivo `manifest.json` gerado.

Com o webpack, os _assets_ estáticos podem ser importados diretamente em arquivos JavaScript. O valor importado representa a URL para o ativo. Por exemplo:

```javascript
import myImageUrl from '../images/my-image.jpg'

// ...
let myImage = new Image();
myImage.src = myImageUrl;
myImage.alt = "Eu sou uma imagem do pacote Webpacker";
document.body.appendChild(myImage);
```

Se você precisar referenciar ativos estáticos do Webpacker a partir de uma visualização do Rails, os ativos precisam ser explicitamente exigidos dos arquivos JavaScript do pacote do Webpacker. Ao contrário do Sprockets, o Webpacker não importa seus ativos estáticos por padrão. O arquivo padrão `app/javascript/packs/application.js` tem um modelo para importar arquivos de um determinado diretório, que você pode descomentar para cada diretório em que deseja ter arquivos estáticos. Os diretórios são relativos a `app/javascript` . O template usa o diretório `images`, mas você pode usar qualquer coisa em `app/javascript`:

```
const images = require.context("../images", true)
const imagePath = name => images(name, true)
```

_Assets_ estáticos serão enviados para um diretório em `public/packs/media`. Por exemplo, uma imagem localizada e importada em `app/javascript/images/my-image.jpg` será gerada em `public/packs/media/images/my-image-abcd1234.jpg`. Para renderizar uma tag de imagem para esta imagem em uma visualização do Rails, use `image_pack_tag 'media/images/my-image.jpg`.

Os _helpers_ do Webpacker ActionView para _assets_ estáticos correspondem aos _helpers_ de pipeline de _assets_ de acordo com a tabela a seguir:

|Helper ActionView | Helper Webpacker |
|------------------|------------------|
|favicon_link_tag  |favicon_pack_tag  |
|image_tag         |image_pack_tag    |

Além disso, o _helper_ genérico `asset_pack_path` seleciona a localização local de um arquivo e retorna sua localização do Webpacker para uso em _views_ do Rails.

Você também pode acessar a imagem referenciando diretamente o arquivo de um arquivo CSS em `app/javascript`.

### Webpacker em Engines Rails

A partir da versão 6 do Webpacker, o Webpacker não é "consciente da _engine_", o que significa que o Webpacker não possui paridade de recursos com o Sprockets quando se trata de usar nas _engines_ do Rails.

Os autores de gems de _engines_ Rails que desejam oferecer suporte aos consumidores usando o Webpacker são incentivados a distribuir ativos de _front-end_ como um pacote NPM além da própria gem e fornecer instruções (ou um instalador) para demonstrar como os aplicativos hospedeiros devem se integrar. Um bom exemplo dessa abordagem é o [Alchemy CMS](https://github.com/AlchemyCMS/alchemy_cms).

### Substituição de Hot Module (HMR - Hot Module Replacement)

O Webpacker pronto para uso suporta HMR com webpack-dev-server, e você pode alterná-lo configurando a opção dev_server/hmr dentro de `webpacker.yml`.

Confira a [documentação do webpack no DevServer](https://webpack.js.org/configuration/dev-server/#devserver-hot) para mais informações.

Para suportar HMR com React, você precisará adicionar react-hot-loader. Confira [Guia de primeiros passos no React Hot Loader](https://gaearon.github.io/react-hot-loader/getstarted/).

Não se esqueça de desabilitar o HMR se você não estiver executando o webpack-dev-server; caso contrário, você receberá um "erro não encontrado" para arquivos css.

Webpacker in Different Environments
-----------------------------------

Webpacker has three environments by default `development`, `test`, and `production`. You can add additional environment configurations in the `webpacker.yml` file and set different defaults for each environment. Webpacker will also load the file `config/webpack/<environment>.js` for additional environment setup.

## Running Webpacker in Development

Webpacker ships with two binstub files to run in development: `./bin/webpack` and `./bin/webpack-dev-server`. Both are thin wrappers around the standard `webpack.js` and `webpack-dev-server.js` executables and ensure that the right configuration files and environmental variables are loaded based on your environment.

By default, Webpacker compiles automatically on demand in development when a Rails page loads. This means that you don't have to run any separate processes, and compilation errors will be logged to the standard Rails log. You can change this by changing to `compile: false` in the `config/webpacker.yml` file. Running `bin/webpack` will force the compilation of your packs.

If you want to use live code reloading or have enough JavaScript that on-demand compilation is too slow, you'll need to run `./bin/webpack-dev-server` or `ruby ./bin/webpack-dev-server`. This process will watch for changes in the `app/javascript/packs/*.js` files and automatically recompile and reload the browser to match.

Windows users will need to run these commands in a terminal separate from `bundle exec rails server`.

Once you start this development server, Webpacker will automatically start proxying all webpack asset requests to this server. When you stop the server, it'll revert to on-demand compilation.

The [Webpacker Documentation](https://github.com/rails/webpacker) gives information on environment variables you can use to control `webpack-dev-server`. See additional notes in the [rails/webpacker docs on the webpack-dev-server usage](https://github.com/rails/webpacker#development).

### Deploying Webpacker

Webpacker adds a `webpacker:compile` task to the `assets:precompile` rake task, so any existing deploy pipeline that was using `assets:precompile` should work. The compile task will compile the packs and place them in `public/packs`.

Additional Documentation
------------------------

For more information on advanced topics, such as using Webpacker with popular frameworks, consult the [Webpacker Documentation](https://github.com/rails/webpacker).
