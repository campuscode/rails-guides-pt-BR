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

Webpacker em Diferentes Ambientes
-----------------------------------

O Webpacker possui três ambientes por padrão `development`, `test` e `production`. Você pode adicionar configurações de ambiente adicionais no arquivo `webpacker.yml` e definir padrões diferentes para cada ambiente. O Webpacker também carregará o arquivo `config/webpack/<environment>.js` para configuração adicional do ambiente.

## Executando Webpacker em Desenvolvimento

O Webpacker vem com dois arquivos _binstub_ para rodar em desenvolvimento: `./bin/webpack` e `./bin/webpack-dev-server`. Ambos são _wrappers_ condensados em torno dos executáveis padrão `webpack.js` e `webpack-dev-server.js` e garantem que os arquivos de configuração corretos e variáveis de ambiente sejam carregadas com base em seu ambiente.

Por padrão, o Webpacker compila automaticamente sob demanda em desenvolvimento quando uma página do Rails é carregada. Isso significa que você não precisa executar nenhum processo separado, e os erros de compilação serão registrados no _log_ padrão do Rails. Você pode mudar isso mudando para `compile: false` no arquivo `config/webpacker.yml`. Executar `bin/webpack` forçará a compilação de seus pacotes.

Se você quiser usar o recarregamento de código em tempo real ou tiver JavaScript suficiente para que a compilação sob demanda seja muito lenta, você precisará executar `./bin/webpack-dev-server` ou `ruby ./bin/webpack-dev-server `. Este processo observará as alterações nos arquivos `app/javascript/packs/*.js`, recompilando e recarregando automaticamente o navegador.

Os usuários do Windows precisarão executar esses comandos em um terminal separado do `bundle exec rails server`.

Assim que você iniciar esse servidor de desenvolvimento, o Webpacker iniciará automaticamente o _proxy_ de todas as solicitações de ativos do webpack para este servidor. Quando você parar o servidor, ele reverterá para a compilação sob demanda.

A [Documentação do Webpacker](https://github.com/rails/webpacker) fornece informações sobre variáveis de ambiente que você pode usar para controlar o `webpack-dev-server`. Veja notas adicionais nos [documentos do Rails/webpacker sobre o uso do webpack-dev-server](https://github.com/rails/webpacker#development).

### Fazendo Deploy do Webpacker

O Webpacker adiciona uma tarefa `webpacker:compile` à tarefa de rake `assets:precompile`, portanto, qualquer pipeline de implantação existente que estava usando `assets:precompile` deve funcionar. A tarefa compilará os pacotes e os colocará em `public/packs`.

Documentação Adicional
------------------------

Para obter mais informações sobre tópicos avançados, como o uso do Webpacker com _frameworks_ populares, consulte a [Documentação do Webpacker](https://github.com/rails/webpacker).
