**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Validações do *Active Record*
=========================

Este guia te ensina a validar os estados dos objetos antes deles serem incluídos no
banco de dados usando as validações do *Active Record*.

Depois de ler este guia, você saberá:

* Como usar as validações já inclusas no *Active Record*.
* Como criar seus próprios métodos de validação.
* Como trabalhar com mensagens de erro geradas pelo processo de validação.

--------------------------------------------------------------------------------

Resumo das Validações
----------------------

Este é um exemplo de uma validação simples:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.create(name: "John Doe").valid?
=> true
irb> Person.create(name: nil).valid?
=> false
```

Como você pode ver, nossa validação nos deixa saber que nossa *`Person`* não é
válida sem o atributo *`name`*. A segunda *`Person`* não existirá no banco de dados.

Antes de entrarmos em maiores detalhes, vamos falar sobre como as validações
funcionam na nossa aplicação.

### Por que usar validações?

Validações são usadas para garantir que só dados válidos sejam salvos no seu
banco de dados. Por exemplo, pode ser importante para sua aplicação garantir
que todo usuário forneça um endereço de e-mail e endereço de correspondência
válidos. Validações de *model* são a melhor maneira de garantir que só
dados válidos sejam salvos em seu banco de dados. Eles são bancos de dados
agnósticos, não podem ser contornados por usuários, e são fáceis de manter e
de testar. O Rails fornece ajudantes
*build-in* para necessidades comuns, e também permite que você crie seus
próprios métodos de validação.

Exitem outros modos de validar dados antes deles serem salvos no seu banco de
dados, incluindo restrições nativas do banco de dados, validações no lado do
cliente e validações no nível do *controller*. Este é um sumário dos prós
e contras:

* Restrições no banco de dados e/ou procedimentos armazenados tornam as validações
  dependentes do banco de dados e podem tornar o processo de testar e a manutenção
  mais difíceis. No entanto, se seu banco de dados é usado por outras aplicações, pode
  ser uma boa ideia usar algumas restrições diretamente no banco de dados. Adicionalmente,
  validações no nível de banco de dados são seguras para lidar com algumas coisas
  (como singularidade em tabelas muito utilizadas) que seriam difíceis de
  implementar de outra forma.
* Validações no lado do cliente são úteis, mas no geral não são seguras quando
  utilizadas sozinhas. Se elas forem implementadas usando JavaScript, elas podem
  ser contornadas se o JavaScript estiver desligado no navegador do usuário. No
  entanto se forem combinadas com outras técnicas, essas validações podem ser um
  método mais conveniente de fornecer ao usuário um retorno imediato enquanto
  eles navegam no seu site.
* Utilizar validações no nível do *controller* pode ser tentador,
  mas frequentemente se tornam pesadas e de manutenção e testagem difíceis. Sempre
  que possível, é uma boa prática manter seus *controllers* leves, o que irá
  tornar a sua aplicação prazerosa de se trabalhar com o passar do tempo.

Escolha essa opção de validação em alguns casos específicos. É da opinião da equipe do Rails que as
validações de *model* são mais apropriadas na maior parte das circunstâncias.

### Quando as validações ocorrem?

Existem dois tipos de objetos de *Active Record*: aqueles que correspondem
a uma linha no seu banco de dados e aqueles que não correspondem. Quando você cria
um objeto novo, por exemplo, usando o método `new`, esse objeto ainda não existe no
banco de dados. Uma vez que você chame o `save` sob esse objeto ele será salvo na
tabela apropriada no seu banco de dados. O *Active Record* usa o método de
instância `new_record?` para determinar se o objeto já existe no banco de dados ou
não.
Considere a seguinte classe do *Active Record*:

```ruby
class Person < ApplicationRecord
end
```

Podemos ver como ela funciona olhando para o resultado no `bin/rails console`:

```irb
irb> p = Person.new(name: "John Doe")
=> #<Person id: nil, name: "John Doe", created_at: nil, updated_at: nil>

irb> p.new_record?
=> true

irb> p.save
=> true

irb> p.new_record?
=> false
```

Ao criar e salvar um novo *record* será enviada uma operação SQL de
`INSERT` para o seu banco de dados. Atualizando um registro
existente irá mandar uma operação SQL de `UPDATE` no lugar.
Validações são tipicamente realizadas antes que esses comandos sejam
enviados para seu banco de dados. Se alguma validação falhar, o objeto será
marcados como inválido e o *Active Record* não irá executar as
operações de `INSERT` ou `UPDATE`. Isso evita que um dado
inválido seja armazenado no banco de dados. Você pode escolher validações
específicas que atuem quando um objeto for criado, salvo, ou editado.

CAUTION: Existem muitos modos de alterar o estado de um objeto no banco
de dados. Alguns métodos irão acionar validações, mas alguns não vão. Isso
significa que é possível salvar um objeto inválido no banco de dados se você
não tomar cuidado.

Os métodos a seguir acionam validações e só vão salvar objetos que
forem válidos no banco de dados:

* `create`
* `create!`
* `save`
* `save!`
* `update`
* `update!`

As versões *bang* (ex: `save!`) levantam uma exceção se o objeto for
inválido. As versões normais não fazem isso: `save` e `update` retornam `false`,
e `create` retorna o objeto.

### Pulando Validações

Os seguintes métodos pulam validações, e irão salvar o objeto no banco
de dados independente da sua validade. Eles devem ser usados com cuidado.

* `decrement!`
* `decrement_counter`
* `increment!`
* `increment_counter`
* `insert`
* `insert!`
* `insert_all`
* `insert_all!`
* `toggle!`
* `touch`
* `touch_all`
* `update_all`
* `update_attribute`
* `update_column`
* `update_columns`
* `update_counters`
* `upsert`
* `upsert_all`

Note que `save` também tem a habilidade de pular validações se for
estabelecido `validate: false` como argumento. Essa técnica deve ser
usada com cuidado.

* `save(validate: false)`

### `valid?` e `invalid?`

Antes de salvar um objeto do *Active Record*, Rails executa suas
validações. Se essas validações produzirem um erro, o Rails não salva
o objeto.

Você também pode executar essas validações por si só. [`valid?`][] ativa suas validações,
retornando `true`, se nenhum erro for encontrado no objeto, ou `false`,
caso contrário.
Como dito acima:

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.create(name: "John Doe").valid?
=> true
irb> Person.create(name: nil).valid?
=> false
```

Depois do *Active Record* executar as validações, qualquer erro encontrado
pode ser acessado através do método de instância [`errors`][], que
retorna uma coleção de erros. Por definição, um objeto é válido se essa coleção
estiver vazia após serem executadas as validações.

Note que um objeto instanciado com `new` não informará nenhum erro mesmo que
ele seja tecnicamente inválido, porque as validações são executadas automaticamente
apenas quando o objeto é salvo, como acontece com os métodos `create`
ou `save`.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> p = Person.new
=> #<Person id: nil, name: nil>
irb> p.errors.size
=> 0

irb> p.valid?
=> false
irb> p.errors.objects.first.full_message
=> "Name can't be blank"

irb> p = Person.create
=> #<Person id: nil, name: nil>
irb> p.errors.objects.first.full_message
=> "Name can't be blank"

irb> p.save
=> false

irb> p.save!
ActiveRecord::RecordInvalid: Validation failed: Name can't be blank

irb> Person.create!
ActiveRecord::RecordInvalid: Validation failed: Name can't be blank
```

[`invalid?`][] é simplesmente o inverso de `valid?`. Desencadeia suas validações e
retorna `true` se algum erro for encontrado no objeto, e `false`
caso contrário.

[`errors`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-errors
[`invalid?`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-invalid-3F
[`valid?`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations.html#method-i-valid-3F

### `errors[]`

Para verificar se um determinado atributo de um objeto é válido, você pode
usar [`errors[:attribute]`][Errors#squarebrackets]. Isso retorna um *array* com todos os
erros para o `:attribute`. Se não houver nenhum erro para o atributo
especificado, um *array* vazio é exibido.

Esse método só é útil **após** as validações terem sido executadas, porque ele só
inspeciona as coleções de erros e não aciona nenhuma validação em si. É
diferente do método `ActiveRecord::Base#invalid?` explicado acima porque
não verifica ao todo se um objeto é válido. Apenas verifica se existem
erros em um determinado atributo do objeto.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.new.errors[:name].any?
=> false
irb> Person.create.errors[:name].any?
=> true
```

Nós vamos cobrir os erros das validações em maior detalhe na seção [Trabalhando com
Erros de Validações](#working-with-validation-errors).

O uso de `details` juntamente com validadores é tratado na seção
[Trabalhando com Erros de Validações](#working-with-validation-errors).

[Errors#squarebrackets]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-5B-5D

Helpers de Validação
------------------

O Active Record oferece vários *helpers* de validação pré-definidos que você
pode utilizar dentro das suas definições de classes. Esses *helpers*
providenciam regras de validações comuns. Toda vez que uma validação falha, um
erro é adicionado a coleção `errors` do objeto, e sua mensagem é
associada com o atributo que está sendo validado.

Cada *helper* aceita um número arbitrário de nomes de atributos, então com uma
única linha de código você consegue adicionar o mesmo tipo de validação para
vários atributos.

Todas as validações aceitam as opções `:on` e `:message`, que definem quando
as validações devem ser utilizadas e qual a mensagem que será adicionada a
coleção `errors` caso ela falhe, respectivamente. A opção `:on` utiliza-se de
um dos valores `:create` ou `:update`. Existe uma mensagem padrão de erro para
cada um dos *helpers* de validação. Essas mensagens são utilizadas quando a
opção `:message` não é especificada. Vamos dar uma olhada em cada um dos
*helpers* disponíveis.

### `acceptance`

Esse método valida se um *checkbox* foi marcado quando um formulário foi
submetido. Tipicamente isso é utilizado quando o usuário necessita de concordar
com os termos de serviço de sua aplicação, confirmar que algum texto foi lido,
ou qualquer conceito similar.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end
```

Essa verificação só é feita se `terms_of_service` não é `nil`.
A mensagem padrão de erro para esse *helper* é _"must be accepted"_.
Você também pode passar uma mensagem customizada com a opção de `message`.

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { message: 'must be abided' }
end
```

O método também pode receber uma opção de `:accept`, que determina os valores
que serão considerados como aceito. Ele tem como padrão os valores `['1', true]`
e pode ser facilmente mudado.


```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { accept: 'yes' }
  validates :eula, acceptance: { accept: ['TRUE', 'accepted'] }
end
```

Essa validação é bem específica para aplicações web e a "aceitação" não precisa
ser gravada em lugar nenhum do seu banco de dados. Se você não tem um campo para
isso o *helper* criará um atributo virtual. Se o campo existe no seu banco de
dados a opção `accept` deve ser definida como `true` ou a validação não irá
acontecer.

### `validates_associated`

Você deve usar esse *helper* quando seu modelo tiver associações com outros
modelos que também precisam ser validados. Quando você tentar salvar seu objeto,
`valid?` será chamado para cada um dos seus objetos associados.

```ruby
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

Essa validação funcionará com todos os tipos de associação.

CAUTION: Não utilize `validates_associated` nos dois lados de suas associações.
Eles vão chamar umas as outras em um loop infinito.

A mensagem padrão de erro para [`validates_associated`][] é _"is invalid"_. Repare
que cada objeto associado terá sua própria coleção de `errors`; erros não irão
se juntar no modelo onde a validação foi chamada.

[`validates_associated`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_associated

### `confirmation`

Você deve utilizar esse *helper* quando você tem dois campos de texto que devem
receber exatamente o mesmo conteúdo. Por exemplo, você pode querer confirmar um
endereço de email ou uma senha. Essa validação cria um atributo virtual onde o
nome é o nome do atributo que deve ser confirmado com "\_confirmation" anexado.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
end
```

No seu *template* de *view* você pode utilizar algo como

```erb
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>
```

This check is performed only if `email_confirmation` is not `nil`. To require
confirmation, make sure to add a presence check for the confirmation attribute
(we'll take a look at `presence` later on in this guide):

Essa checagem só é feita se o `email_confirmation` não é `nil`. Para requisitar
uma confirmação tenha certeza que adicionou uma checagem de presença para o
atributo de confirmação (nós iremos ver `presence` em breve nesse guia):

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end
```

Também existe a opção `:case_sensitive` caso você queira definir se a restrição
de confirmação deve ser sensível a letras maiúsculas e minúsculas. Essa opção
por padrão é verdadeira.

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: { case_sensitive: false }
end
```

A mensagem padrão de erro para esse *helper* é _"doesn't match confirmation"_.

### `exclusion`

Esse *helper* valida os atributos que não estão incluídos em uma coleção. Na
verdade, essa coleção pode ser qualquer objeto enumerável.

```ruby
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} is reserved." }
end
```

O *helper* de `exclusion` tem a opção `:in` que recebe uma coleção de valores
que não serão aceitas para os atributos validados. A opção `:in` tem um atalho
chamado `:within` que pode ser utilizado para o mesmo propósito, caso queira.
Esse exemplo usa a opção `:message` para mostrar como você pode incluir o valor
do atributo na mensagem de erro. Para uma lista completa das opções do argumento
de mensagem por favor veja a [documentação sobre mensagens](#message).

A mensagem de erro padrão é _"is reserved"_.

### `format`

Esse *helper* valida os valores dos atributos testando se eles correspondem uma
expressão regular dada, que é especificada com a opção `:with`.

```ruby
class Product < ApplicationRecord
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "only allows letters" }
end
```

Alternativamente, você pode requerer que um atributo específico _não_
corresponde com a expressão regular usando a opção `:without`.

A mensagem de erro padrão é _"is invalid"_.

### `inclusion`

Esse *helper* valida os atributos que estão incluídos em uma coleção. Na
verdade, essa coleção pode ser qualquer objeto enumerável.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }
end
```

O *helper* de `inclusion` tem a opção `:in` que recebe uma coleção de valores
que serão aceitas para os atributos validados. A opção `:in` tem um atalho
chamado `:within` que pode ser utilizado para o mesmo propósito, caso queira.
Esse exemplo usa a opção `:message` para mostrar como você pode incluir o valor
do atributo na mensagem de erro. Para uma lista completa das opções do argumento
de mensagem por favor veja a [documentação da mensagem](#message).

A mensagem de erro padrão para esse *helper* é _"is not included in the list"_.

### `length`

Esse *helper* valida o tamanho dos valores dos atributos. Ele disponibiliza uma
variedade de opções, então você pode especificar o tamanho das restrições de
maneiras diferentes.

```ruby
class Person < ApplicationRecord
  validates :name, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
end
```

The possible length constraint options are:

As possíveis opções de restrições de tamanho são:

* `:minimum` - O atributo não pode ser menor que o tamanho especificado.
* `:maximum` - O atributo não pode ser maior que o tamanho especificado.
* `:in` (or `:within`) - O tamanho do atributo deve estar dentro do alcance de
  um intervalo dado. O valor dessa opção deve ser um intervalo.
* `:is` - O tamanho do atributo deve ser igual ao valor passado.

O valor padrão da mensagem de erro depende do tipo de validação sendo usado.
Você pode customizar essas mensagens usando as opções `:wrong_length`,
`:too_long` e `:muito curto` e `%{count}` como um espaço reservado para o número
correspondente ao do tamanho da restrição sendo utilizada. Você ainda pode
utilizar a opção `:message` para especificar uma mensagem de erro.

```ruby
class Person < ApplicationRecord
  validates :bio, length: { maximum: 1000,
    too_long: "%{count} characters is the maximum allowed" }
end
```

Note que as mensagens de erro padrão estão em plural (por exemplo: "is too short
(minimum is %{count} characters)"). Por essa razão, quando `:minimum` é 1 você
deve disponibilizar uma mensagem customizada ou utilizar `presence: true` no
lugar. Quando `:in` ou `:within` tem um limite menor que 1, você deve
disponibilizar ou uma mensagem customizada ou usar `presence` antes do
`length`.

### `numericality`

Esse *helper* válida se seus atributos contém somente valores numéricos. Por
padrão, ele vai corresponder um número inteiro ou real precedido de um sinal
opcional de negativo ou positivo (+ ou -).

Para especificar que somente números inteiros são permitidos mude `:only_integer` para verdadeiro.
Então ele vai usar

```ruby
/\A[+-]?\d+\z/
```

como expressão regular para validar o valor do atributo. Se não, ele vai tentar
converter o valor para um número usando a classe `Float`. `Float`s são
transformados em `BigDecimal` usando a precisão da coluna ou 15.

```ruby
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: { only_integer: true }
end
```

A mensagem de erro padrão para `:only_integer` é _"must be an integer"_.

Além de `:only_integer`, esse *helper* também aceita as seguintes opções para
adicionar restrições aos valores aceitáveis:

* `:greater_than` - Especifica que o valor deve ser maior que o valor informado.
  A mensagem padrão para esse erro é _"must be greater than %{count}"_.
* `:greater_than_or_equal_to` - Especifica que o valor deve ser maior ou igual
  que o valor informado. A mensagem padrão para esse erro é _"must be greater
  than or equal to %{count}"_.
* `:equal_to` - Especifica que o valor deve ser igual que o valor informado.
  A mensagem padrão para esse erro é _"must be equal to %{count}"_.
* `:less_than` - Especifica que o valor deve ser menor que o valor informado.
  A mensagem padrão para esse erro é _"must be less than %{count}"_.
* `:less_than_or_equal_to` - Especifica que o valor deve ser menor ou igual que
  o valor informado. A mensagem padrão para esse erro é _"must be less than or
  equal to %{count}"_.
* `:other_than` - Especifica que o valor deve ser diferente que o valor
  informado. A mensagem padrão para esse erro é _"must be other than %{count}"_.
* `:odd` - Especifica que o valor deve ser ímpar se definido como verdadeiro.
  A mensagem padrão para esse erro é _"must be odd"_.
* `:even` - Especifica que o valor deve ser par se definido como verdadeiro. A
  mensagem padrão para esse erro é _"must be even"_.

NOTE: Por padrão, `numericality` não permite valores `nil`. Você pode utilizar
`allow_nil: true` para permitir isso.

A mensagem de erro padrão para quando nenhuma opção é especificada é _"is not a number"_.

### `presence`

Esse *helper* que os atributos especificados não estão vazios. Ele utiliza o
método `blank?` para verificar se o valor é `nil` ou uma *string* em branco,
isso é, uma *string* que está vazia ou só contém espaços.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, presence: true
end
```

Se você quer ter certeza que uma associação está presente, você precisará testar
se o objeto associado por ele mesmo está presente, e não a chave estrangeira
utilizada para mapear a associação. Dessa maneira, não só é checado que a chave
estrangeira existe como também se o objeto referenciado existe.

```ruby
class Supplier < ApplicationRecord
  has_one :account
  validates :account, presence: true
end
```

Para validar registros associados cuja presença é necessária, você deve
especificar a opção `:inverse_of` para a associação:

NOTE: Se você quiser garantir que a associação está presente e é válida, você também precisa usar `validates_associated`.

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

Se você validar a presença de um objeto associado através de um relacionamento
`has_one` ou` has_many`, ele verificará se o objeto não está `blank?` nem
`marked_for_destruction?`.

Como `false.blank?` é verdadeiro, se você deseja validar a presença de um valor
booleano no campo, você deve usar uma das seguintes validações:

```ruby
validates :boolean_field_name, inclusion: [true, false]
validates :boolean_field_name, exclusion: [nil]
```

Ao usar uma dessas validações, você garantirá que o valor NÃO será `nil`
o que resultaria em um valor `NULL` na maioria dos casos.

### `absence`

Este *helper* valida que os atributos especificados estão ausentes. Ele usa o
método `present?` para verificar se o valor não é `nil` ou uma *string* em
branco, isso é, uma *string* que está vazia ou só contém caracteres em branco.

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, absence: true
end
```

Se você quer ter certeza que uma associação está ausente, você precisará testar
se o objeto associado por ele mesmo está ausente, e não a chave estrangeira
utilizada para mapear a associação.

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, absence: true
end
```

Para validar registros associados cuja ausência é necessária, você deve
especificar a opção `:inverse_of` para a associação:

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

Se você validar a ausência de um objeto associado através de um relacionamento
`has_one` ou` has_many`, ele verificará se o objeto não está `present?` nem
`marked_for_destruction?`.

Como `false.present?` é _false_, se você quer validar a ausência de um campo
booleano você deve usar `validates :field_name,
exclusion: { in: [true, false] }`.

A mensagem padrão de erro é _"must be blank"_.

### `uniqueness`

Este *helper* valida que o valor do atributo é único antes de o objeto ser
salvo. Ele não cria uma restrição de exclusividade no banco de dados, portanto
pode acontecer de duas conexões diferentes ao banco de dados criarem dois
registros com o mesmo valor para uma coluna que você pretende tornar exclusiva.
Para evitar isso, você deve criar um índice exclusivo nessa coluna no seu banco
de dados.

```ruby
class Account < ApplicationRecord
  validates :email, uniqueness: true
end
```

A validação ocorre executando uma consulta SQL na tabela do modelo, procurando
um registro existente com o mesmo valor nesse atributo.

Existe uma opção `:scope` que você pode usar para especificar um ou mais
atributos usados para limitar a verificação de exclusividade:

```ruby
class Holiday < ApplicationRecord
  validates :name, uniqueness: { scope: :year,
    message: "should happen once per year" }
end
```

Se você deseja criar uma restrição no banco de dados para previnir possiveis
violações em uma validação de exclusividade usando a opção de `:scope`, você
deve criar uma indexação única em ambas as colunas em seu banco de dados. Veja
[o manual do MySQL](https://dev.mysql.com/doc/refman/en/multiple-column-indexes.html)
para mais detalhes sobre indexação de múltiplas colunas ou
[o manual do Postgres](https://www.postgresql.org/docs/current/static/ddl-constraints.html)
para exemplos de restrições únicas que referenciam esse grupo de colunas

Há também uma opção `:case_sensitive` que você pode usar para definir se a
restrição de exclusividade fará distinção entre maiúsculas e minúsculas.
O padrão desta opção é _true_.

```ruby
class Person < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
end
```

WARNING: Observe que alguns bancos de dados estão configurados para executar
pesquisas que não diferenciam maiúsculas de minúsculas.

A mensagem de erro padrão é _"has already been taken"_.

### `validates_with`

Esse *helper* passa o registro para uma classe separada para ser feita a validação.

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors.add :base, "This person is evil"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator
end
```

NOTE: Os erros adicionados ao `record.errors[:base]` estão relacionados ao
estado do registro como um todo, e não a um atributo específico.

O *helper* [`validates_with`][] pega uma classe ou uma lista de classes para usar
na validação. Não há mensagem de erro padrão para `validates_with`. Você deve
adicionar manualmente erros à coleção de erros do registro na classe validadora.

Para implementar o método validador, você deve ter um parâmetro `record`
definido, que é o registro a ser validado.

Like all other validations, `validates_with` takes the `:if`, `:unless` and
`:on` options. If you pass any other options, it will send those options to the
validator class as `options`:

Como todas as outras validações, `validates_with` utiliza as opções`:if`,
`:unless` e `:on`. Se você passar outras opções, essas opções serão enviadas
para a classe validadora como `options`:

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any? { |field| record.send(field) == "Evil" }
      record.errors.add :base, "This person is evil"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator, fields: [:first_name, :last_name]
end
```

Observe que o validador será inicializado *apenas uma vez* durante todo o ciclo
de vida do aplicativo, e não em cada execução de validação, portanto, tenha
cuidado ao usar variáveis de instância nele.

Se o seu validador for suficientemente complexo para que você deseje variáveis
de instância, você poderá facilmente usar um objeto Ruby puro no lugar:

```ruby
class Person < ApplicationRecord
  validate do |person|
    GoodnessValidator.new(person).validate
  end
end

class GoodnessValidator
  def initialize(person)
    @person = person
  end

  def validate
    if some_complex_condition_involving_ivars_and_private_methods?
      @person.errors.add :base, "This person is evil"
    end
  end

  # ...
end
```

[`validates_with`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_with

### `validates_each`

Este *helper* valida atributos em relação a um bloco. Não possui uma função de
validação predefinida. Você deve criar um usando um bloco, e todos os atributos
passados para [`validates_each`][] serão testados contra ele. No exemplo a seguir,
não queremos que nomes e sobrenomes comecem com letras minúsculas.

```ruby
class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, 'must start with upper case') if value =~ /\A[[:lower:]]/
  end
end
```

O bloco recebe o registro, o nome do atributo e o valor do atributo. Você pode
fazer o que quiser para verificar dados válidos dentro do bloco. Se sua
validação falhar, você deverá adicionar um erro ao modelo,
tornando-o inválido.

[`validates_each`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_each

Opções de Validação Comuns
-------------------------

Essas são opções de validação comuns:

### `:allow_nil`

A opção `:allow_nil` pula a validação quando o valor que está sendo validado é
`nil`.

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} is not a valid size" }, allow_nil: true
end
```

Para opções completas para argumento de mensagem, consulte
[documentação de mensagem](#mensagem).

### `:allow_blank`

A opção `:allow_blank` é semelhante à opção `:allow_nil`. Esta opção
deixará a validação passar se o valor do atributo for `blank?`,
*string* vazia por exemplo.

```ruby
class Topic < ApplicationRecord
  validates :title, length: { is: 5 }, allow_blank: true
end
```

```irb
irb> Topic.create(title: "").valid?
=> true
irb> Topic.create(title: nil).valid?
=> true
```

### `:message`

Como você já viu, a opção `:message` permite que você especifique a mensagem que
será adicionada à coleção `errors` quando a validação falhar. Quando esta
opção não é usada, o `Active Record` usará a respectiva mensagem de erro padrão
para cada *helper* de validação. A opção `:message` aceita uma `String` ou `Proc`.

Um valor `String` de `:message` pode conter opcionalmente qualquer/tudo de `%{value}`,
`%{attribute}`, e `%{model}` que será substituído dinamicamente quando
a validação falhar. Esta substituição é feita usando a gem I18n, e as
posições devem ser exatamente correspondentes, não são permitidos espaços.

Um valor `Proc` de `:message` recebe dois argumentos: o objeto à ser validado, e
uma *hash* com os pares de chave-valor `:model`, `:attributes` e `:value`.

```ruby
class Person < ApplicationRecord
  # Hard-coded message
  validates :name, presence: { message: "must be given please" }

  # Mensagem com valor de atributo dinâmico. %{value} será substituído
  # com o valor real do atributo. %{attribute} e %{model}
  # também estão disponíveis.
  validates :age, numericality: { message: "%{value} seems wrong" }

  # Proc
  validates :username,
    uniqueness: {
      # object = person object being validated
      # data = { model: "Person", attribute: "Username", value: <username> }
      message: ->(object, data) do
        "Hey #{object.name}, #{data[:value]} is already taken."
      end
    }
end
```

### `:on`

A opção `:on` permite que você especifique quando a validação deve acontecer. O
comportamento padrão para todos os *helpers* de validação integrados é ser executado
ao salvar (tanto ao criar um novo registro quanto ao atualizá-lo). Se você
quiser mudar, você pode usar `on: :create` para rodar a validação apenas quando um
novo registro é criado ou `on: :update` para rodar a validação apenas quando um registro
é atualizado.

```ruby
class Person < ApplicationRecord
  # it will be possible to update email with a duplicated value
  validates :email, uniqueness: true, on: :create

  # it will be possible to create the record with a non-numerical age
  validates :age, numericality: true, on: :update

  # the default (validates on both create and update)
  validates :name, presence: true
end
```

Você também pode usar `on:` para definir contextos customizados. O contexto
customizado precisa ser acionado explicitamente passando o nome do contexto para
`valid?`, `invalid?`, ou `save`.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
end
```

```irb
irb> person = Person.new(age: 'thirty-three')
irb> person.valid?
=> true
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["has already been taken"], :age=>["is not a number"]}
```

`person.valid?(:account_setup)` executa ambas as validações sem salvar
o *model*. `person.save(context: :account_setup)` valida `person` no
contexto de `account_setup` antes de salvar.

Quando acionado por um contexto explícito, as validações são executadas para
esse contexto, assim como quaisquer validações _sem_ um contexto.

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
  validates :name, presence: true
end
```

```irb
irb> person = Person.new
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["has already been taken"], :age=>["is not a number"], :name=>["can't be blank"]}
```

Validações Estritas
------------------

Você também pode especificar validações como estritas e lançar um
`ActiveModel::StrictValidationFailed` quando o objeto é inválido.

```ruby
class Person < ApplicationRecord
  validates :name, presence: { strict: true }
end
```

```irb
irb> Person.new.valid?
ActiveModel::StrictValidationFailed: Name can't be blank
```

Também é possível passar uma exceção personalizada para a opção `:strict`.

```ruby
class Person < ApplicationRecord
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end
```

```irb
irb> Person.new.valid?
TokenGenerationException: Token can't be blank
```

Validação com Condicional
----------------------

Às vezes fará sentido validar um objeto apenas quando uma determinada condição for satisfeita.
Você pode fazer isso usando `:if` e `:unless`, que podem ser usados como um *symbol*,
uma `Proc` ou um `Array`. Você pode usar o `:if` quando quiser especificar quando uma
validação **deve** ocorrer.
Se você quiser especificar quando uma validação **não deve** ocorrer, você pode usar o `:unless`.


### Usando um *Symbol* com `:if` e `:unless`

Você pode associar o `:if` e `:unless` com um *symbol* correspondente ao nome do método
que será chamado logo antes da validação acontecer.
Essa é a opção mais usada.

```ruby
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == "card"
  end
end
```

### Usando uma *Proc* com `:if` e `:unless`

É possível associar `:if` e `:unless` com um objeto `Proc` que será chamado.
O uso de um objeto `Proc` permite escrever uma condição em apenas uma linha
ao invés de em um método separado.

```ruby
class Account < ApplicationRecord
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end
```

Como as `Lambdas` são tipos de `Proc`, elas também podem ser usadas para escrever condições em apenas uma linha de forma mais curta.

```ruby
validates :password, confirmation: true, unless: -> { password.blank? }
```

### Agrupando Validações com Condicionais

Às vezes, é útil ter várias validações usando a mesma condição.
Isso pode ser feito facilmente usando  [`with_options`][].

```ruby
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end
```

Todas as validações dentro do bloco `with_options` terão automaticamente passado a condição `if: :is_admin?`

[`with_options`]: https://api.rubyonrails.org/classes/Object.html#method-i-with_options

### Combinando Validações com Condicionais

Por outro lado, quando várias condições definem se uma validação deve ou não acontecer,
podemos usar um `Array`. Além disso, você pode usar ambos `:if` e `:unless` para a mesma validação.

```ruby
class Computer < ApplicationRecord
  validates :mouse, presence: true,
                    if: [Proc.new { |c| c.market.retail? }, :desktop?],
                    unless: Proc.new { |c| c.trackpad.present? }
end
```

A validação é executada apenas quando todas as condições `:if`
e nenhuma das condições `:unless` resultarem em `true`.

Realizando Validações Customizadas
----------------------------------

Quando os *helpers* de validação embutidos não são o bastante para suas necessidades, você pode
implementar seus próprios validadores ou métodos de validação como preferir.

### Validadores Customizados

Validadores Customizados são classes que herdam de [`ActiveModel::Validator`][]. Essas
classes devem implementar o método `validate`, que recebe um *record* como argumento
e realiza as validações nele. O validador customizado é chamado usando o
método `validates_with`.

```ruby
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.start_with? 'X'
      record.errors.add :name, "Need a name starting with X please!"
    end
  end
end

class Person
  include ActiveModel::Validations
  validates_with MyValidator
end
```

A maneira mais fácil de adicionar validadores customizados para atributos individuais
é com a conveniente classe `ActiveModel::EachValidator`. Nesse caso, a classe validadora
customizada deve implementar um método `validate_each`, que recebe três argumentos:
*record*, *attribute* e *value*. Esses correspondem respectivamente à instância, ao atributo
a ser validado e ao valor do atributo na instância recebida.

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
      record.errors.add attribute, (options[:message] || "is not an email")
    end
  end
end

class Person < ApplicationRecord
  validates :email, presence: true, email: true
end
```

Como mostrado no exemplo acima, você também pode combinar validações padrão com
seus próprios validadores customizados.

[`ActiveModel::Validator`]: https://api.rubyonrails.org/classes/ActiveModel/Validator.html

### Métodos Customizados

Você também pode criar métodos que verificam o estado de seus *models* e
adicionam erros à coleção `errors` quando eles são inválidos. Você
deve então registrar esses métodos usando o método de classe [`validate`][]
passando os *symbols* dos nomes dos métodos de validação.

Você pode passar mais do que um *symbol* para cada método da classe e as
respectivas validações serão executadas na mesma ordem que elas foram registradas.

O método `valid?` verificará se a coleção de erros está vazia,
sendo assim seus métodos de validação customizados devem adicionar erros
à ela quando você desejar que as validações falhem:

```ruby
class Invoice < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "can't be in the past")
    end
  end

  def discount_cannot_be_greater_than_total_value
    if discount > total_value
      errors.add(:discount, "can't be greater than total value")
    end
  end
end
```

Por padrão, tais validações executarão a cada chamada ao método `valid?`
ou ao salvar o objeto. Mas também é possível controlar quando executar essas
validações customizadas informando uma opção `:on` para o método `validate`,
com `:create` ou `:update`.

```ruby
class Invoice < ApplicationRecord
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "is not active") unless customer.active?
  end
end
```

[`validate`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validate

Trabalhando com Erros de Validação
----------------------------------

Em adição aos métodos [`valid?`][] e [`invalid?`][] cobertos anteriormente, o Rails provê outros métodos para trabalhar com a coleção [`errors`][] e verificar a validade dos objetos.

A seguir é exibida uma lista dos métodos mais comumente utilizados. Por favor, verifique a documentação do [`ActiveModel::Errors`][] para uma lista de todos os métodos disponíveis.

[`ActiveModel::Errors`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html

### `errors`

O portão através do qual você pode ver vários detalhes de cada erro.

Retorna uma instância da classe `ActiveModel::Errors` contendo todos os erros,
cada erro é representado por um objeto [`ActiveModel::Error`][].

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.full_messages
=> ["Name can't be blank", "Name is too short (minimum is 3 characters)"]

irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors.full_messages
=> []
```

[`ActiveModel::Error`]: https://api.rubyonrails.org/classes/ActiveModel/Error.html

### `errors[]`

[`errors[]`][Errors#squarebrackets] é utilizado quando você quiser verificar as mensagens de erro de um atributo em específico. O método retorna um *array* de *strings* com todas as mensagens de erro para o atributo informado, cada *string* contendo uma mensagem de erro. Se não houver erros relacionados com o atributo, o método retorna um *array* vazio.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors[:name]
=> []

irb> person = Person.new(name: "JD")
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["is too short (minimum is 3 characters)"]

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["can't be blank", "is too short (minimum is 3 characters)"]
```

### `errors.where` e objetos de erro

Às vezes, podemos precisar de mais informações sobre cada erro e sua mensagem. Cada erro é encapsulado como um objeto `ActiveModel::Error` e o método [`where`][] é a forma mais comum de acesso.

`where` retorna um *array* de objetos de erro, filtrados por vários graus de condições.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name)
=> [ ... ] # todos os erros para o atributo :name

irb> person.errors.where(:name, :too_short)
=> [ ... ] # erros :too_short para o atributo :name
```

Você pode ler várias informações desses objetos de erro:

```irb
irb> error = person.errors.where(:name).last

irb> error.attribute
=> :name
irb> error.type
=> :too_short
irb> error.options[:count]
=> 3
```

Você também pode gerar a mensagem de erro:

```irb
irb> error.message
=> "is too short (minimum is 3 characters)"
irb> error.full_message
=> "Name is too short (minimum is 3 characters)"
```

O método [`full_message`][] gera uma mensagem mais legível, que começa com o atributo com a primeira letra maiúscula.

[`full_message`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_message
[`where`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-where

### `errors.add`

O método [`add`][] permite que você crie um objeto de erro usando o atributo em particular, o tipo do erro e um *hash* de opções adicional. Isso pode ser útil quando tiver escrevendo seus validadores (*validators*).

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :name, :too_plain, message: "is not cool enough"
  end
end
```

```irb
irb> person = Person.create
irb> person.errors.where(:name).first.type
=> :too_plain
irb> person.errors.where(:name).first.full_message
=> "Name is not cool enough"
```

[`add`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-add

### `errors[:base]`

Voce pode adicionar erros relacionadas ao estado do objeto como um todo, ao invés de estarem relacionadas a um atributo em específico. Você pode adicionar erros ao `:base` quando quiser dizer que o objeto é inválido, não importando os valores de seus atributos.

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :base, :invalid, message: "This person is invalid because ..."
  end
end
```

```irb
irb> person = Person.create
irb> person.errors.where(:base).first.full_message
=> "This person is invalid because ..."
```

### `errors.clear`

O método `clear` é usado quando você intencionalmente quiser limpar toda a coleção `errors`. É claro que, ao chamar o método `errors.clear` sobre um objeto inválido não irá torná-lo válido: a coleção `errors` estará agora vazia, mas a próxima vez que você chamar `valid?` ou qualquer método que tente salvar esse objeto na base de dados, as validações serão executadas novamente. Se qualquer uma das validações falhar, a coleção `errors` será preenchida de novo.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.empty?
=> false

irb> person.errors.clear
irb> person.errors.empty?
=> true

irb> person.save
=> false

irb> person.errors.empty?
=> false
```

### `errors.size`

O método `size` retorna o número total de erros para o objeto.

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.size
=> 2

irb> person = Person.new(name: "Andrea", email: "andrea@example.com")
irb> person.valid?
=> true
irb> person.errors.size
=> 0
```

Exibindo Erros de Validação nas *Views*
-------------------------------------

Uma vez criado o *model* e adicionada as validações, se o *model* é criado via
formulário web, você provavelmente quer mostrar uma mensagem de erro quando uma
das validações falhar.

Devido a cada aplicação lidar com esse tipo de cenário de forma diferente, o Rails
não inclui nenhum *helper* na *view* para ajudar a gerar essas mensagens
diretamente.
Contudo, devido ao rico número de métodos que o Rails nos da para interagirmos
com validações em geral, podemos criar as nossas próprias validações.
Além disso, quando geramos o *scaffold*, o Rails colocará algum *ERB* dentro
de `_form.html.erb` que ele gera, exibindo a lista completa de erros naquele
*model*.

Supondo que temos um modelo que foi salvo em uma variável de instância chamada
`@article`, terá a seguinte aparência:

```html+erb
<% if @article.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@article.errors.count, "error") %> prohibited this article from being saved:</h2>

    <ul>
      <% @article.errors.each do |error| %>
        <li><%= error.full_message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

Portanto, se você usar os *helpers* de formulário do Rails para gerar seus
formulários, quando um erro de validação ocorrer em um campo, isso vai gerar
uma `<div>` extra ao redor da entrada.

```html
<div class="field_with_errors">
  <input id="article_title" name="article[title]" size="30" type="text" value="">
</div>
```

Você pode definir o estilo desta *div* como preferir. O *scaffold*
padrão que o Rails gera, por exemplo, adiciona essa regra *CSS*:

```css
.field_with_errors {
  padding: 2px;
  background-color: red;
  display: table;
}
```

Isso significa que qualquer campo com erro termina com 2 *pixels* de borda vermelha.
