**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Contribuindo para o Ruby on Rails
=============================

Esse guia aborda como _você_ pode se tornar uma parte do desenvolvimento contínuo do Ruby on Rails.

Depois de ler este guia, você saberá:

* Como usar o GitHub para relatar problemas.
* Como clonar a *branch* main e executar uma série de testes.
* Como ajudar a resolver problemas já existentes.
* Como contribuir na documentação do Ruby on Rails.
* Como contribuir no código fonte do Ruby on Rails.

Ruby on Rails não é um "framework de qualquer um." Ao longo dos anos, milhares de pessoas contribuíram para o Ruby on Rails, desde as mais simples implementações até as maiores mudanças na arquitetura ou documentação - tudo para fazer um Ruby on Rails melhor para todos. Mesmo que você ainda não se sinta pronto para escrever um código ou documentação, existem várias outras maneiras pelas quais você pode contribuir, desde relatar problemas até testar *patches*.

Como mencionado em [Rails'README](https://github.com/rails/rails/blob/main/README.md), espera-se que todos que interajam no Rails e nas bases de código de seus sub-projetos, *issue trackers*, *chat rooms* e listas de discussão sigam o [código de conduta](https://rubyonrails.org/conduct/) do Rails.

--------------------------------------------------------------------------------

Relatando uma *Issue*
------------------

O Ruby on Rails utiliza o [GitHub Issue Tracking](https://github.com/rails/rails/issues) para rastrear problemas (principalmente *bugs* e contribuições de novo código). Se você encontrou um *bug* no Ruby on Rails, este é o lugar por onde começar. Você precisará criar uma conta (gratuita) no GitHub para enviar uma *issue*, fazer comentários em *issues*, ou criar *pull requests*.

NOTE: Os *bugs* na versão mais recente do Ruby on Rails vão receberão mais atenção. Além disso, a equipe principal do Rails está sempre interessada no *feedback* daqueles que podem tirar um tempo para testar o _edge Rails_ (o código para a versão do Rails que está atualmente em desenvolvimento). Posteriormente neste guia, você irá descobrirá como obter o _edge Rails_ para testes. Veja nossa [política de manutenção](https://guides.rubyonrails.org/maintenance_policy.html) para mais informações sobre quais versões são suportadas. Nunca reporte uma falha de segurança nas GitHub issues.

### Criando um aviso de *Bug*

Se você encontrou um problema no Ruby on Rails que não é um risco de segurança, faça um pesquisa no GitHub em [*Issues*](https://github.com/rails/rails/issues), caso já tenha sido relatado. Se você não conseguir encontrar nenhuma *issue* aberta no GitHub que resolva o problema que encontrou, seu próximo passo será [abrir uma nova *issue*](https://github.com/rails/rails/issues/new). (Consulte a próxima seção para relatar problemas de segurança.)

We've provided an issue template for you so that when creating an issue you include all the information needed to determine whether there is a bug in the framework. Each issue needs to include a title and clear description of the problem. Make sure to include as much relevant information as possible including a code sample or failing test that demonstrates the expected behavior, as well as your system configuration. Your goal should be to make it easy for yourself - and others - to reproduce the bug and figure out a fix.

Once you open an issue it may or may not see activity right away unless it is a "Code Red, Mission Critical, the World is Coming to an End" kind of bug. That doesn't mean we don't care about your bug, just that there are a lot of issues and pull requests to get through. Other people with the same problem can find your issue and confirm the bug and may collaborate with you on fixing it. If you know how to fix the bug, go ahead and open a pull request.

### Crie um Caso de Teste Executável

Ter uma maneira de reproduzir seu problema será útil para que outras pessoas ajudem a confirmar, investigar e, por fim, corrigir seu problema. Você pode fazer isso fornecendo um caso de teste executável. Para facilitar esse processo, preparamos vários modelos de relatório de *bug* para você utilizar como ponto de partida:

* Template para problemas de Active Record (models, database): [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_main.rb)
* Template para testar problemas de Active Record (migration): [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_record_migrations_main.rb)
* Template para problemas de Action Pack (controllers, routing): [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_controller_main.rb)
* Template para problemas de Active Job: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_job_main.rb)
* Template para problemas de Active Storage: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/active_storage_main.rb)
* Template para problemas de Action Mailbox: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/action_mailbox_main.rb)
* Template genérico para outros problemas: [gem](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_gem.rb) / [main](https://github.com/rails/rails/blob/main/guides/bug_report_templates/generic_main.rb)

Esses *templates* incluem um código padrão (*boilerplate*) para configurar um caso de teste tanto para uma versão estável do Rails (`*_gem.rb`) quanto para o *edge Rails* (`*_main.rb`).

Copie o conteúdo do *template* apropriado para um arquivo `.rb` e faça as alterações necessárias para demonstrar o problema. Você pode executá-lo rodando `ruby nome_do_arquivo.rb` no seu terminal. Se tudo correr bem, você verá que seu caso de teste falhou.

Você pode então compartilhar seu caso de teste executável como um [*gist*](https://gist.github.com), ou colar o conteúdo na descrição da *issue*.

### Tratamento Especial para Questões de Segurança

WARNING: Não relate vulnerabilidades de segurança com relatórios públicos de *issue* do GitHub. A [página de política de segurança do Rails](https://rubyonrails.org/security) detalha o procedimento a seguir para questões de segurança.

### E quanto às Solicitações de Funcionalidade (Feature Requests)?

Por favor, não coloque itens de *feature request* nas *issues* do GitHub. Se houver uma nova *feature* que você deseja ver adicionada ao Ruby on Rails, você precisará escrever o código por conta própria - ou convencer alguém a fazer uma parceria com você para escrever o código.
Posteriormente neste guia, você encontrará instruções detalhadas para propor um *patch* para o Ruby on Rails. Se você inserir um item que você deseja nas *Issues* do GitHub sem código, pode esperar que ele será marcado como "inválido" assim que for revisado.

Às vezes, é difícil de traçar a linha entre '*bug*' e '*feature*'. Normalmente, a *feature* é qualquer coisa que adiciona um novo comportamento, enquanto um *bug* é qualquer coisa que causa um comportamento incorreto. Às vezes, a equipe principal terá que fazer um julgamento. Dito isso, a distinção geralmente determina em qual versão seu *patch* entrará; nós amamos submissões de *features*! Elas simplesmente não serão transportadas para as *branches* de manutenção.

Se você deseja obter *feedback* sobre uma ideia de *feature* antes de começá-la e fazer um *patch*, envie um email para a [lista de discussão do rails-core](https://groups.google.com/forum/?fromgroups#!forum/rubyonrails-core). Você pode não receber resposta, o que significa que todos são indiferentes. Você pode encontrar alguém que também esteja interessado em criar essa *feature*. Você pode receber um "Isso não será aceito". Mas é o lugar certo para discutir novas ideias. As *issues* do GitHub não são um local particularmente bom para as discussões às vezes longas e complicadas que as novas *features* exigem.


Ajudando a Resolver *Issues* Existentes
----------------------------------

Uma próxima etapa além de relatar *issues*, você pode ajudar a equipe principal a resolver as existentes fornecendo *feedback* sobre elas. Se você é novo no desenvolvimento do núcleo do Rails, essa pode ser uma ótima maneira de dar os primeiros passos, você irá se familiarizar com a base de código e os processos.

Se você verificar a [lista de *issues*](https://github.com/rails/rails/issues) em *Issues* do GitHub, você encontrará muitas *issues* que já requerem atenção. O que você pode fazer para ajudar? Bastante coisa, na verdade:

### Verificar *Bug Reports*

Para começar, ajuda apenas verificar os relatórios de *bugs*. Você pode reproduzir a *issue* relatada em seu computador? Nesse caso, você pode adicionar um comentário à *issue* dizendo que está vendo a mesma coisa.

Se uma *issue* for muito vaga, você pode ajudar a restringí-la a algo mais específico? Talvez você possa fornecer informações adicionais para reproduzir um *bug* ou eliminando etapas desnecessárias para demonstrar o problema.

Se você encontrar um relatório de *bug* sem um teste, é muito útil contribuir com um teste de falha. Essa também é uma ótima forma de explorar o código-fonte: examinar os arquivos de testes irá te ensinar a escrever mais testes. Novos testes são melhor contribuídos na forma de um *patch*, como explicado mais tarde na seção [Contribuindo com o Código Rails](#contributing-to-the-rails-code).

Qualquer coisa que você possa fazer para tornar os relatórios de *bugs* mais sucintos ou mais fáceis de reproduzir ajuda as pessoas a tentarem escrever código para corrigir esses *bugs* - independentemente de você mesmo acabar escrevendo o código ou não.

### Testar *Patches*

Você também pode ajudar examinando *pull requests* que foram enviados ao Ruby on Rails via GitHub. Para aplicar as alterações de alguém, primeiro criar uma *branch* dedicada:

```bash
$ git checkout -b testing_branch
```

Então, você pode usar a *branch* remota da pessoa que fez o *pull request* para atualizar sua base código. Por exemplo, digamos que o usuário JohnSmith tenha feito um *fork* e enviado para a branch "*orange*" localizada em https://github.com/JohnSmith/rails.

```bash
$ git remote add JohnSmith https://github.com/JohnSmith/rails.git
$ git pull JohnSmith orange
```

An alternative to adding their remote to your checkout is to use the [GitHub CLI tool](https://cli.github.com/) to checkout their pull request.

Depois de aplicar a *branch*, teste-a! Aqui estão algumas coisa a se atentar:

* A alteração realmente funciona?
* Você está satisfeito com os testes? Você pode acompanhar o que estão testando? Há algum teste faltando?
* Possui a cobertura de documentação adequada? A documentação deve ser atualizada em algum outro lugar?
* Você está satisfeito com a implementação? Você pode pensar em uma maneira mais agradável ou rápida de implementar parte da alteração?

Uma vez que você estiver satisfeito com o fato de que o *pull request* possui uma boa alteração, comente na *issue* do GitHub indicando suas descobertas. Seu comentário deve indicar que você gostou da mudança e o que você gostou nela. Algo como:

>Eu gostei da forma como você reestruturou o código em `generate_finder_sql` - muito melhor. Os testes também parecem bons.

Se o seu comentário for apenas "+1", é provável que outros revisores não o levem muito a sério. Mostre que você dedicou um tempo para revisar o *pull request*.

Contribuindo com a documentação do Rails
---------------------------------------

O Ruby on Rails possui dois conjuntos principais de documentação: os guias, que te ajudam a aprender sobre Ruby on Rails, e a API, que serve como referência.

Você pode ajudar a melhorar os guias do Rails ou a referência da API tornando-os mais coerentes, consistentes ou legíveis, adicionando informações ausentes, corrigindo erros factuais, corrigindo erros de digitação ou atualizando-os com os Rails mais recentes.

Para isso, faça alterações aos arquivos-fonte dos guias do Rails (localizados [aqui](https://github.com/rails/rails/tree/main/guides/source) no GitHub) ou comentários RDoc no código fonte. Então abra um *Pull Request* para aplicar suas mudanças na *branch* principal (*main*).

Ao trabalhar com a documentação, leve em consideração as [Diretrizes de Documentação da API](api_documentation_guidelines.html) e as [Diretrizes dos guias Ruby on Rails](ruby_on_rails_guides_guidelines.html).

Translating Rails Guides
------------------------

We are happy to have people volunteer to translate the Rails guides. Just follow these steps:

* Fork https://github.com/rails/rails.
* Add a source folder for your language, for example: *guides/source/it-IT* for Italian.
* Copy the contents of *guides/source* into your language directory and translate them.
* Do NOT translate the HTML files, as they are automatically generated.

Note that translations are not submitted to the Rails repository; your work lives in your fork, as described above. This is because, in practice, documentation maintenance via patches is only sustainable in English.

To generate the guides in HTML format, you will need to install the guides dependencies, `cd` into the *guides* directory, and then run (e.g., for it-IT):

```bash
# only install gems necessary for the guides. To undo run: bundle config --delete without
$ bundle install --without job cable storage ujs test db
$ cd guides/
$ bundle exec rake guides:generate:html GUIDES_LANGUAGE=it-IT
```

This will generate the guides in an *output* directory.

NOTE: The Redcarpet Gem doesn't work with JRuby.

Translation efforts we know about (various versions):

* **Italian**: [https://github.com/rixlabs/docrails](https://github.com/rixlabs/docrails)
* **Spanish**: [https://github.com/latinadeveloper/railsguides.es](https://github.com/latinadeveloper/railsguides.es)
* **Polish**: [https://github.com/apohllo/docrails](https://github.com/apohllo/docrails)
* **French** : [https://github.com/railsfrance/docrails](https://github.com/railsfrance/docrails)
* **Czech** : [https://github.com/rubyonrails-cz/docrails/tree/czech](https://github.com/rubyonrails-cz/docrails/tree/czech)
* **Turkish** : [https://github.com/ujk/docrails](https://github.com/ujk/docrails)
* **Korean** : [https://github.com/rorlakr/rails-guides](https://github.com/rorlakr/rails-guides)
* **Simplified Chinese** : [https://github.com/ruby-china/guides](https://github.com/ruby-china/guides)
* **Traditional Chinese** : [https://github.com/docrails-tw/guides](https://github.com/docrails-tw/guides)
* **Russian** : [https://github.com/morsbox/rusrails](https://github.com/morsbox/rusrails)
* **Japanese** : [https://github.com/yasslab/railsguides.jp](https://github.com/yasslab/railsguides.jp)
* **Brazilian Portuguese** : [https://github.com/campuscode/rails-guides-pt-BR](https://github.com/campuscode/rails-guides-pt-BR)

Contributing to the Rails Code
------------------------------

### Setting Up a Development Environment

To move on from submitting bugs to helping resolve existing issues or contributing your own code to Ruby on Rails, you _must_ be able to run its test suite. In this section of the guide, you'll learn how to set up the tests on your computer.

#### Using GitHub Codespaces

If you're a member of an organization that has codespaces enabled, you can fork Rails into that organization and use codespaces on GitHub. The Codespace will be initialized with all required dependencies and allows you to run all tests.

If you're not a member of an organization that has codespaces enabled you can use the [VS Code remote containers plugin](https://code.visualstudio.com/docs/remote/containers-tutorial). The plugin will read the `.devcontainer` configuration in the repository and build the Docker container locally.

#### Using rails-dev-box

It's also possible to use the [rails-dev-box](https://github.com/rails/rails-dev-box) to get a development environment ready. However, the rails-dev-box uses Vagrant and Virtual Box which will not work with the M1 processors.

#### Local Development

When you can't use GitHub Codespaces, see [this other guide](development_dependencies_install.html) for how to set up local development. This is considered the hard way because installing dependencies may be OS specific.

### Clone the Rails Repository

To be able to contribute code, you need to clone the Rails repository:

```bash
$ git clone https://github.com/rails/rails.git
```

and create a dedicated branch:

```bash
$ cd rails
$ git checkout -b my_new_branch
```

It doesn't matter much what name you use because this branch will only exist on your local computer and your personal repository on GitHub. It won't be part of the Rails Git repository.

### Bundle install

Install the required gems.

```bash
$ bundle install
```

### Running an Application Against Your Local Branch

In case you need a dummy Rails app to test changes, the `--dev` flag of `rails new` generates an application that uses your local branch:

```bash
$ cd rails
$ bundle exec rails new ~/my-test-app --dev
```

The application generated in `~/my-test-app` runs against your local branch
and, in particular, sees any modifications upon server reboot.

For JavaScript packages, you can use [`yarn link`](https://yarnpkg.com/cli/link) to source your local branch in a generated application:

```bash
$ cd rails/activestorage
$ yarn link
$ cd ~/my-test-app
$ yarn link "@rails/activestorage"
```

### Write Your Code

Now it's time to write some code! When making changes for Rails here are some things to keep in mind:

* Follow Rails style and conventions.
* Use Rails idioms and helpers.
* Include tests that fail without your code, and pass with it.
* Update the (surrounding) documentation, examples elsewhere, and the guides: whatever is affected by your contribution.
* If the change adds, removes, or changes a feature, be sure to include a CHANGELOG entry. If your change is a bug fix, a CHANGELOG entry is not necessary.

TIP: Changes that are cosmetic and do not add anything substantial to the stability, functionality, or testability of Rails will generally not be accepted (read more about [our rationales behind this decision](https://github.com/rails/rails/pull/13771#issuecomment-32746700)).

#### Follow the Coding Conventions

Rails follows a simple set of coding style conventions:

* Two spaces, no tabs (for indentation).
* No trailing whitespace. Blank lines should not have any spaces.
* Indent and no blank line after private/protected.
* Use Ruby >= 1.9 syntax for hashes. Prefer `{ a: :b }` over `{ :a => :b }`.
* Prefer `&&`/`||` over `and`/`or`.
* Prefer `class << self` over `self.method` for class methods.
* Use `my_method(my_arg)` not `my_method( my_arg )` or `my_method my_arg`.
* Use `a = b` and not `a=b`.
* Use `assert_not` methods instead of `refute`.
* Prefer `method { do_stuff }` instead of `method{do_stuff}` for single-line blocks.
* Follow the conventions in the source you see used already.

The above are guidelines - please use your best judgment in using them.

Additionally, we have [RuboCop](https://www.rubocop.org/) rules defined to codify some of our coding conventions. You can run RuboCop locally against the file that you have modified before submitting a pull request:

```bash
$ bundle exec rubocop actionpack/lib/action_controller/metal/strong_parameters.rb
Inspecting 1 file
.

1 file inspected, no offenses detected
```

For `rails-ujs` CoffeeScript and JavaScript files, you can run `npm run lint` in `actionview` folder.

#### Spell Checking

We are running [misspell](https://github.com/client9/misspell) which is mainly written in
[Golang](https://golang.org/) to check spelling with [GitHub Actions](https://github.com/rails/rails/blob/main/.github/workflows/lint.yml). Correct
commonly misspelled English words quickly with `misspell`. `misspell` is different from most other spell checkers
because it doesn't use a custom dictionary. You can run `misspell` locally against all files with:

```bash
find . -type f | xargs ./misspell -i 'aircrafts,devels,invertions' -error
```

Notable `misspell` help options or flags are:

- `-i` string: ignore the following corrections, comma separated
- `-w`: Overwrite file with corrections (default is just to display)

We also run [codespell](https://github.com/codespell-project/codespell) with GitHub Actions to check spelling and
[codespell](https://pypi.org/project/codespell/) runs against a [small custom dictionary](https://github.com/rails/rails/blob/main/codespell.txt).
`codespell` is written in [Python](https://www.python.org/) and you can run it with:

```bash
codespell --ignore-words=codespell.txt
```

### Benchmark Your Code

For changes that might have an impact on performance, please benchmark your
code and measure the impact. Please share the benchmark script you used as well
as the results. You should consider including this information in your commit
message, to allow future contributors to easily verify your findings and
determine if they are still relevant. (For example, future optimizations in the
Ruby VM might render certain optimizations unnecessary.)

When optimizing for a specific scenario that you care about, it is easy to
regress performance for other common cases.
Therefore, you should test your change against a list of representative
scenarios, ideally extracted from real-world production applications.

You can use the [benchmark template](https://github.com/rails/rails/blob/main/guides/bug_report_templates/benchmark.rb)
as a starting point. It includes the boilerplate code to set up a benchmark
using the [benchmark-ips](https://github.com/evanphx/benchmark-ips) gem. The
template is designed for testing relatively self-contained changes that can be
inlined into the script.

### Running Tests

It is not customary in Rails to run the full test suite before pushing
changes. The railties test suite, in particular, takes a long time, and will take an
especially long time if the source code is mounted in `/vagrant` as happens in
the recommended workflow with the [rails-dev-box](https://github.com/rails/rails-dev-box).

As a compromise, test what your code obviously affects, and if the change is
not in railties, run the whole test suite of the affected component. If all
tests are passing, that's enough to propose your contribution. We have
[Buildkite](https://buildkite.com/rails/rails) as a safety net for catching
unexpected breakages elsewhere.

#### Entire Rails:

To run all the tests, do:

```bash
$ cd rails
$ bundle exec rake test
```

#### For a Particular Component

You can run tests only for a particular component (e.g., Action Pack). For example,
to run Action Mailer tests:

```bash
$ cd actionmailer
$ bin/test
```

#### For a Specific Directory

You can run tests only for a specific directory of a particular component
(e.g., models in Active Storage). For example, to run tests in `/activestorage/test/models`:

```bash
$ cd activestorage
$ bin/test models
```

#### For a Specific File

You can run the tests for a particular file:

```bash
$ cd actionview
$ bin/test test/template/form_helper_test.rb
```

#### Running a Single Test

You can run a single test by name using the `-n` option:

```bash
$ cd actionmailer
$ bin/test test/mail_layout_test.rb -n test_explicit_class_layout
```

#### Running Tests with a Specific Seed

Test execution is randomized with a randomization seed. If you are experiencing random
test failures, you can more accurately reproduce a failing test scenario by specifically
setting the randomization seed.

Running all tests for a component:

```bash
$ cd actionmailer
$ SEED=15002 bin/test
```

Running a single test file:

```bash
$ cd actionmailer
$ SEED=15002 bin/test test/mail_layout_test.rb
```

#### Running Tests in Serial

Action Pack and Action View unit tests run in parallel by default. If you are experiencing random
test failures, you can set the randomization seed and let these unit tests run in serial by setting `PARALLEL_WORKERS=1`

```bash
$ cd actionview
$ PARALLEL_WORKERS=1 SEED=53708 bin/test test/template/test_case_test.rb
```

#### Testing Active Record

First, create the databases you'll need. You can find a list of the required
table names, usernames, and passwords in `activerecord/test/config.example.yml`.

For MySQL and PostgreSQL, it is sufficient to run:

```bash
$ cd activerecord
$ bundle exec rake db:mysql:build
```
Or:

```bash
$ cd activerecord
$ bundle exec rake db:postgresql:build
```

This is not necessary for SQLite3.

This is how you run the Active Record test suite only for SQLite3:

```bash
$ cd activerecord
$ bundle exec rake test:sqlite3
```

You can now run the tests as you did for `sqlite3`. The tasks are respectively:

```bash
$ bundle exec rake test:mysql2
$ bundle exec rake test:postgresql
```

Finally,

```bash
$ bundle exec rake test
```

will now run the three of them in turn.

You can also run any single test separately:

```bash
$ ARCONN=mysql2 bundle exec ruby -Itest test/cases/associations/has_many_associations_test.rb
```

To run a single test against all adapters, use:

```bash
$ bundle exec rake TEST=test/cases/associations/has_many_associations_test.rb
```

You can invoke `test_jdbcmysql`, `test_jdbcsqlite3` or `test_jdbcpostgresql` also. See the file `activerecord/RUNNING_UNIT_TESTS.rdoc` for information on running more targeted database tests.

### Warnings

The test suite runs with warnings enabled. Ideally, Ruby on Rails should issue no warnings, but there may be a few, as well as some from third-party libraries. Please ignore (or fix!) them, if any, and submit patches that do not issue new warnings.

### Updating the Documentation

The Ruby on Rails [guides](https://guides.rubyonrails.org/) provide a high-level overview of Rails' features, while the [API documentation](https://api.rubyonrails.org/) delves into specifics.

If your PR adds a new feature, or changes how an existing feature behaves, check the relevant documentation, and update it or add to it as necessary.

For example, if you modify Active Storage's image analyzer to add a new metadata field, you should update the [Analyzing Files](active_storage_overview.html#analyzing-files) section of the Active Storage guide to reflect that.

### Updating the CHANGELOG

The CHANGELOG is an important part of every release. It keeps the list of changes for every Rails version.

You should add an entry **to the top** of the CHANGELOG of the framework you modified if you're adding or removing a feature, committing a bug fix, or adding deprecation notices. Refactorings and documentation changes generally should not go to the CHANGELOG.

A CHANGELOG entry should summarize what was changed and should end with the author's name. You can use multiple lines if you need more space, and you can attach code examples indented with 4 spaces. If a change is related to a specific issue, you should attach the issue's number. Here is an example CHANGELOG entry:

```
*   Summary of a change that briefly describes what was changed. You can use multiple
    lines and wrap them at around 80 characters. Code examples are ok, too, if needed:

        class Foo
          def bar
            puts 'baz'
          end
        end

    You can continue after the code example, and you can attach the issue number.

    Fixes #1234.

    *Your Name*
```

Your name can be added directly after the last word if there are no code
examples or multiple paragraphs. Otherwise, it's best to make a new paragraph.

### Ignoring Files Created by Your Editor / IDE

Some editors and IDEs will create hidden files or folders inside the `rails` folder. Instead of manually excluding those from each commit or adding them to Rails' `.gitignore`, you should add them to your own [global gitignore file](https://docs.github.com/en/get-started/getting-started-with-git/ignoring-files#configuring-ignored-files-for-all-repositories-on-your-computer).

### Updating the Gemfile.lock

Some changes require dependency upgrades. In these cases, make sure you run `bundle update` to get the correct version of the dependency and commit the `Gemfile.lock` file within your changes.

### Commit Your Changes

When you're happy with the code on your computer, you need to commit the changes to Git:

```bash
$ git commit -a
```

This should fire up your editor to write a commit message. When you have
finished, save, and close to continue.

A well-formatted and descriptive commit message is very helpful to others for
understanding why the change was made, so please take the time to write it.

A good commit message looks like this:

```
Short summary (ideally 50 characters or less)

More detailed description, if necessary. Each line should wrap at
72 characters. Try to be as descriptive as you can. Even if you
think that the commit content is obvious, it may not be obvious
to others. Add any description that is already present in the
relevant issues; it should not be necessary to visit a webpage
to check the history.

The description section can have multiple paragraphs.

Code examples can be embedded by indenting them with 4 spaces:

    class ArticlesController
      def index
        render json: Article.limit(10)
      end
    end

You can also add bullet points:

- make a bullet point by starting a line with either a dash (-)
  or an asterisk (*)

- wrap lines at 72 characters, and indent any additional lines
  with 2 spaces for readability
```

TIP. Please squash your commits into a single commit when appropriate. This
simplifies future cherry picks and keeps the git log clean.

### Update Your Branch

It's pretty likely that other changes to main have happened while you were working. To get new changes in main:

```bash
$ git checkout main
$ git pull --rebase
```

Now reapply your patch on top of the latest changes:

```bash
$ git checkout my_new_branch
$ git rebase main
```

No conflicts? Tests still pass? Change still seems reasonable to you? Then push the rebased changes to GitHub:

```bash
$ git push --force-with-lease
```

We disallow force pushing on the rails/rails repository base, but you are able to force push to your fork. When rebasing this is a requirement since the history has changed.

### Fork

Navigate to the Rails [GitHub repository](https://github.com/rails/rails) and press "Fork" in the upper right-hand corner.

Add the new remote to your local repository on your local machine:

```bash
$ git remote add fork https://github.com/<your username>/rails.git
```

You may have cloned your local repository from rails/rails, or you may have cloned from your forked repository. The following git commands assume that you have made a "rails" remote that points to rails/rails.

```bash
$ git remote add rails https://github.com/rails/rails.git
```

Download new commits and branches from the official repository:

```bash
$ git fetch rails
```

Merge the new content:

```bash
$ git checkout main
$ git rebase rails/main
$ git checkout my_new_branch
$ git rebase rails/main
```

Update your fork:

```bash
$ git push fork main
$ git push fork my_new_branch
```

### Open a Pull Request

Navigate to the Rails repository you just pushed to (e.g.
https://github.com/your-user-name/rails) and click on "Pull Requests" in the top bar (just above the code).
On the next page, click "New pull request" in the upper right-hand corner.

The pull request should target the base repository `rails/rails` and the branch `main`.
The head repository will be your work (`your-user-name/rails`), and the branch will be
whatever name you gave your branch. Click "create pull request" when you're ready.

Ensure the changesets you introduced are included. Fill in some details about
your potential patch, using the pull request template provided. When finished, click "Create
pull request".

### Get Some Feedback

Most pull requests will go through a few iterations before they get merged.
Different contributors will sometimes have different opinions, and often
patches will need to be revised before they can get merged.

Some contributors to Rails have email notifications from GitHub turned on, but
others do not. Furthermore, (almost) everyone who works on Rails is a
volunteer, and so it may take a few days for you to get your first feedback on
a pull request. Don't despair! Sometimes it's quick; sometimes it's slow. Such
is the open source life.

If it's been over a week, and you haven't heard anything, you might want to try
and nudge things along. You can use the [rubyonrails-core mailing
list](https://discuss.rubyonrails.org/c/rubyonrails-core) for this. You can also
leave another comment on the pull request.

While you're waiting for feedback on your pull request, open up a few other
pull requests and give someone else some! They'll appreciate it in
the same way that you appreciate feedback on your patches.

Note that only the Core and Committers teams are permitted to merge code changes.
If someone gives feedback and "approves" your changes they may not have the ability
or final say to merge your change.

### Iterate as Necessary

It's entirely possible that the feedback you get will suggest changes. Don't get discouraged: the whole point of contributing to an active open source project is to tap into the community's knowledge. If people encourage you to tweak your code, then it's worth making the tweaks and resubmitting. If the feedback is that your code won't be merged, you might still think about releasing it as a gem.

#### Squashing Commits

One of the things that we may ask you to do is to "squash your commits", which
will combine all of your commits into a single commit. We prefer pull requests
that are a single commit. This makes it easier to backport changes to stable
branches, squashing makes it easier to revert bad commits, and the git history
can be a bit easier to follow. Rails is a large project, and a bunch of
extraneous commits can add a lot of noise.

```bash
$ git fetch rails
$ git checkout my_new_branch
$ git rebase -i rails/main

< Choose 'squash' for all of your commits except the first one. >
< Edit the commit message to make sense, and describe all your changes. >

$ git push fork my_new_branch --force-with-lease
```

You should be able to refresh the pull request on GitHub and see that it has
been updated.

#### Updating a Pull Request

Sometimes you will be asked to make some changes to the code you have
already committed. This can include amending existing commits. In this
case Git will not allow you to push the changes as the pushed branch
and local branch do not match. Instead of opening a new pull request,
you can force push to your branch on GitHub as described earlier in
squashing commits section:

```bash
$ git commit --amend
$ git push fork my_new_branch --force-with-lease
```

This will update the branch and pull request on GitHub with your new code.
By force pushing with `--force-with-lease`, git will more safely update
the remote than with a typical `-f`, which can delete work from the remote
that you don't already have.

### Older Versions of Ruby on Rails

If you want to add a fix to versions of Ruby on Rails older than the next release, you'll need to set up and switch to your own local tracking branch. Here is an example to switch to the 7-0-stable branch:

```bash
$ git branch --track 7-0-stable rails/7-0-stable
$ git checkout 7-0-stable
```

NOTE: Before working on older versions, please check the [maintenance policy](maintenance_policy.html). Changes will not be accepted to versions that have reached end of life.

#### Backporting

Changes that are merged into main are intended for the next major release of Rails. Sometimes, it might be beneficial to propagate your changes back to stable branches for inclusion in maintenance releases. Generally, security fixes and bug fixes are good candidates for a backport, while new features and patches that change expected behavior will not be accepted. When in doubt, it is best to consult a Rails team member before backporting your changes to avoid wasted effort.

First, make sure your main branch is up to date.

```bash
$ git checkout main
$ git pull --rebase
```

Check out the branch you're backporting to, for example, `7-0-stable` and make sure it's up to date:

```bash
$ git checkout 7-0-stable
$ git reset --hard origin/7-0-stable
$ git checkout -b my-backport-branch
```

If you're backporting a merged pull request, find the commit for the merge and cherry-pick it:

```bash
$ git cherry-pick -m1 MERGE_SHA
```

Fix any conflicts that occurred in the cherry-pick, push your changes, then open a PR pointing at the stable branch you're backporting to. If you have a more complex set of changes, the [cherry-pick](https://git-scm.com/docs/git-cherry-pick) documentation can help.

Contribuintes do Rails
------------------

Todas as contribuições recebem crédito em [Contribuintes do Rails](https://contributors.rubyonrails.org).
