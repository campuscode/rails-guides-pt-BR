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

Instalando Webpacker
--------------------

Para usar o Webpacker, você precisa instalar o gerenciador de pacotes Yarn, versão 1.x ou acima, e você precisa ter Node.js instalado, versão 10.13.0 ou acima.

NOTA: O Webpacker depende do NPM e do Yarn. O NPM, o registro do gerenciador de pacotes do Node, é o repositório principal para publicação e download de projetos JavaScript de código aberto, tanto para Node.js quanto para _runtimes_ do navegador. É análogo ao rubygems.org para as gems Ruby. Yarn é uma utilidade em linha de comando que habilita a instalação e gerenciamento de dependências JavaScript, muito parecido com o que o Bundler faz para Ruby.

Para incluir Webpacker em um novo projeto, adicione `--webpack` no comando `rails new`. Para adicionar o Webpacker em um projeto já criado, adicione a gem `webpacker` no `Gemfile`, rode `bundle install`, e então execute `bin/rails webpacker:install`.

Instalar o Webpacker cria os seguintes arquivos locais:

|Arquivo                    |Localização                |Explicação                                                                                         |
|------------------------|------------------------|----------------------------------------------------------------------------------------------------|
|Pasta JavaScript       | `app/javascript`       |Um lugar para suas fontes de front-end                                                                   |
|Configuração Webpacker | `config/webpacker.yml` |Configura a gem Webpacker                                                                         |
|Configuração Babel     | `babel.config.js`      |Configuração para o Compilador JavaScript [Babel](https://babeljs.io)                               |
|Configuração PostCSS   | `postcss.config.js`    |Configuração para o Pré-Processador CSS[PostCSS](https://postcss.org)                             |
|Browserlist             | `.browserslistrc`      |[Browserlist](https://github.com/browserslist/browserslist) gerencia configuração de navegadores   |


A instalação também chama o gerenciador de pacotes `yarn`, cria um arquivo `package.json` com uma lista básica de pacotes, e usa Yarn para instalar essas dependências.

Usage
-----

### Using Webpacker for JavaScript

With Webpacker installed, any JavaScript file in the `app/javascript/packs` directory will get compiled to its own pack file by default.

So if you have a file called `app/javascript/packs/application.js`, Webpacker will create a pack called `application`, and you can add it to your Rails application with the code `<%= javascript_pack_tag "application" %>`. With that in place, in development, Rails will recompile the `application.js` file every time it changes, and you load a page that uses that pack. Typically, the file in the actual `packs` directory will be a manifest that mostly loads other files, but it can also have arbitrary JavaScript code.

The default pack created for you by Webpacker will link to Rails' default JavaScript packages if they have been included in the project:

```
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

Rails.start()
Turbolinks.start()
ActiveStorage.start()
```

You'll need to include a pack that requires these packages to use them in your Rails application.

It is important to note that only webpack entry files should be placed in the `app/javascript/packs` directory; Webpack will create a separate dependency graph for each entry point, so a large number of packs will increase compilation overhead. The rest of your asset source code should live outside this directory though Webpacker does not place any restrictions or make any suggestions on how to structure your source code. Here is an example:

```sh
app/javascript:
  ├── packs:
  │   # only webpack entry files here
  │   └── application.js
  │   └── application.css
  └── src:
  │   └── my_component.js
  └── stylesheets:
  │   └── my_styles.css
  └── images:
      └── logo.svg
```

Typically, the pack file itself is largely a manifest that uses `import` or `require` to load the necessary files and may also do some initialization.

If you want to change these directories, you can adjust the `source_path` (default `app/javascript`) and `source_entry_path` (default `packs`) in the `config/webpacker.yml` file.

Within source files, `import` statements are resolved relative to the file doing the import, so `import Bar from "./foo"` finds a `foo.js` file in the same directory as the current file, while `import Bar from "../src/foo"` finds a file in a sibling directory named `src`.

### Using Webpacker for CSS

Out of the box, Webpacker supports CSS and SCSS using the PostCSS processor.

To include CSS code in your packs, first include your CSS files in your top-level pack file as though it was a JavaScript file. So if your CSS top-level manifest is in `app/javascript/styles/styles.scss`, you can import it with `import styles/styles`. This tells webpack to include your CSS file in the download. To actually load it in the page, include `<%= stylesheet_pack_tag "application" %>` in the view, where the `application` is the same pack name that you were using.

If you are using a CSS framework, you can add it to Webpacker by following the instructions to load the framework as an NPM module using `yarn`, typically `yarn add <framework>`. The framework should have instructions on importing it into a CSS or SCSS file.


### Using Webpacker for Static Assets

The default Webpacker [configuration](https://github.com/rails/webpacker/blob/master/lib/install/config/webpacker.yml#L21) should work out of the box for static assets.
The configuration includes several image and font file format extensions, allowing webpack to include them in the generated `manifest.json` file.

With webpack, static assets can be imported directly in JavaScript files. The imported value represents the URL to the asset. For example:

```javascript
import myImageUrl from '../images/my-image.jpg'

// ...
let myImage = new Image();
myImage.src = myImageUrl;
myImage.alt = "I'm a Webpacker-bundled image";
document.body.appendChild(myImage);
```

If you need to reference Webpacker static assets from a Rails view, the assets need to be explicitly required from Webpacker-bundled JavaScript files. Unlike Sprockets, Webpacker does not import your static assets by default. The default `app/javascript/packs/application.js` file has a template for importing files from a given directory, which you can uncomment for every directory you want to have static files in. The directories are relative to `app/javascript`. The template uses the directory `images`, but you can use anything in `app/javascript`:

```
const images = require.context("../images", true)
const imagePath = name => images(name, true)
```

Static assets will be output into a directory under `public/packs/media`. For example, an image located and imported at `app/javascript/images/my-image.jpg` will be output at `public/packs/media/images/my-image-abcd1234.jpg`. To render an image tag for this image in a Rails view, use `image_pack_tag 'media/images/my-image.jpg`.

The Webpacker ActionView helpers for static assets correspond to asset pipeline helpers according to the following table:

|ActionView helper | Webpacker helper |
|------------------|------------------|
|favicon_link_tag  |favicon_pack_tag  |
|image_tag         |image_pack_tag    |

Also, the generic helper `asset_pack_path` takes the local location of a file and returns its Webpacker location for use in Rails views.

You can also access the image by directly referencing the file from a CSS file in `app/javascript`.

### Webpacker in Rails Engines

As of Webpacker version 6, Webpacker is not "engine-aware," which means Webpacker does not have feature-parity with Sprockets when it comes to using within Rails engines.

Gem authors of Rails engines who wish to support consumers using Webpacker are encouraged to distribute frontend assets as an NPM package in addition to the gem itself and provide instructions (or an installer) to demonstrate how host apps should integrate. A good example of this approach is [Alchemy CMS](https://github.com/AlchemyCMS/alchemy_cms).

### Hot Module Replacement (HMR)

Webpacker out-of-the-box supports HMR with webpack-dev-server, and you can toggle it by setting dev_server/hmr option inside `webpacker.yml`.

Check out [webpack's documentation on DevServer](https://webpack.js.org/configuration/dev-server/#devserver-hot) for more information.

To support HMR with React, you would need to add react-hot-loader. Check out [React Hot Loader's _Getting Started_ guide](https://gaearon.github.io/react-hot-loader/getstarted/).

Don't forget to disable HMR if you are not running webpack-dev-server; otherwise, you will get a "not found error" for stylesheets.

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
