**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Orientações para Ruby on Rails Guias 
===============================

Esse guia apresenta orientações para escrever guias Ruby on Rails. Esse guia serve por si só como exemplo.

Após ler esse guia, você saberá:

* Sobre a convenção a ser usada em uma documentacao Rails.
* Como gerar guias localmente.

--------------------------------------------------------------------------------

Markdown
-------

Guias são escritos em [GitHub Markdown](https://help.github.com/articles/github-flavored-markdown). Para uma melhor compreensão existe a [documentação para Markdown](https://daringfireball.net/projects/markdown/syntax), assim como essas [dicas](https://daringfireball.net/projects/markdown/basics).

Prologue
--------

Each guide should start with motivational text at the top (that's the little introduction in the blue area). The prologue should tell the reader what the guide is about, and what they will learn. As an example, see the [Routing Guide](routing.html).

Headings
------

The title of every guide uses an `h1` heading; guide sections use `h2` headings; subsections use `h3` headings; etc. Note that the generated HTML output will use heading tags starting with `<h2>`.

```
Título do Guia
===========

Sessão
-------

### Sub Sessão
```

Quando escrever cabeçalhos, capitalizar todas as palavras exceto para preposições, conjunções, artigos e formulários do verbo "ser":

```
#### Asserções e Testando *Jobs* dentro dos Componentes
#### *Middleware Stack* é um *Array*
#### Quando os Objetos são salvos?
```

Use a mesma formatação em linha como texto regular:

```
##### A `:content_type` Opção
```

Linkando com a API
------------------

*Links* para a API (`api.rubyonrails.org`) são processados por um gerador de guia a seguir:

*Links* que incluem a *tag* de lançamento não são tocadas, Por exemplo

```
https://api.rubyonrails.org/v5.0.1/classes/ActiveRecord/Attributes/ClassMethods.html
```

não é modificada.

Por favor use essas notas de lançamento, porque elas devem apontar para a versão correspondente, não importanto o alvo sendo gerado.

Se o link não incluir a *tag* de lançamento e os *edge* guias estiverem sendo gerados, o dominio é substituido por `edgeapi.rubyonrails.org`. Por exemplo,

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

se torna

```
https://edgeapi.rubyonrails.org/classes/ActionDispatch/Response.html
```

Se o link não inclui a *tag* de lançamento e os guias de lançamento estiverem sendo gerados, a versão do Rails é aplicada, Por exemplo, se nós estamos gerando o guia para v5.1.0 o link

```
https://api.rubyonrails.org/classes/ActionDispatch/Response.html
```

se torna

```
https://api.rubyonrails.org/v5.1.0/classes/ActionDispatch/Response.html
```

Por favor não linkar para `edgeapi.rubyonrails.org` manualmente.


API Documentation Guidelines
----------------------------

The guides and the API should be coherent and consistent where appropriate. In particular, these sections of the [API Documentation Guidelines](api_documentation_guidelines.html) also apply to the guides:

* [Wording](api_documentation_guidelines.html#wording)
* [English](api_documentation_guidelines.html#english)
* [Example Code](api_documentation_guidelines.html#example-code)
* [Filenames](api_documentation_guidelines.html#file-names)
* [Fonts](api_documentation_guidelines.html#fonts)

HTML Guides
-----------

Before generating the guides, make sure that you have the latest version of
Bundler installed on your system. You can find the latest Bundler version
[here](https://rubygems.org/gems/bundler). As of this writing, it's v1.17.1.

To install the latest version of Bundler, run `gem install bundler`.

### Generation

To generate all the guides, just `cd` into the `guides` directory, run `bundle install`, and execute:

```bash
$ bundle exec rake guides:generate
```

or

```bash
$ bundle exec rake guides:generate:html
```

Resulting HTML files can be found in the `./output` directory.

To process `my_guide.md` and nothing else use the `ONLY` environment variable:

```bash
$ touch my_guide.md
$ bundle exec rake guides:generate ONLY=my_guide
```

By default, guides that have not been modified are not processed, so `ONLY` is rarely needed in practice.

To force processing all the guides, pass `ALL=1`.

If you want to generate guides in a language other than English, you can keep them in a separate directory under `source` (e.g. `source/es`) and use the `GUIDES_LANGUAGE` environment variable:

```bash
$ bundle exec rake guides:generate GUIDES_LANGUAGE=es
```

If you want to see all the environment variables you can use to configure the generation script just run:

```bash
$ rake
```

### Validation

Please validate the generated HTML with:

```bash
$ bundle exec rake guides:validate
```

Particularly, titles get an ID generated from their content and this often leads to duplicates.

Kindle Guides
-------------

### Generation

To generate guides for the Kindle, use the following rake task:

```bash
$ bundle exec rake guides:generate:kindle
```
