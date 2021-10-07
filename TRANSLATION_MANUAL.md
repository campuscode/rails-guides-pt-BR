# Manual de tradução do Rails Guides - PT-Br

Este manual apresenta os padrões adotados para a tradução do Rails Guides,
visando auxiliar o trabalho de todas as pessoas que colaboram com este projeto.
Vamos procurar atualizar o manual continuamente e frequentemente. Consulte este
material sempre que abrir uma nova *issue* de tradução.  Este é um trabalho
coletivo, desenvolvido por todas as pessoas envolvidas no projeto.

Sugestões e comentários são bem-vindos.

## Questões de gênero

Prefira o uso de linguagem neutra de gênero. Ao se referir a pessoas, procure
traduzir de forma neutra, como "Boas vindas à tradução do Rails", no lugar de
"Bem vindos à tradução do Rails".

## Questões de estilo
Para que o texto flua como é costume na língua portuguesa, é preciso incluir
artigos. No entanto, é necessária atenção na concordância, como por exemplo:

> Rails is a web application framework running on the Ruby programming language.

Sugerimos que seja traduzido para algo como:

> O Rails é um *framework* de aplicações web rodando na linguagem de programação
Ruby.

Em inglês é muito comum o uso da palavra *will*, como em *You will see*.
Sugerimos uma tradução mais próxima da língua falada em português como "Você vai
ver" ou "Você verá". Evite "Você irá ver".


## Glossário
Termos técnicos de origem do idioma inglês, referentes a elementos fundamentais
de aplicações Rails, não devem ser traduzidos. Não traduza, coloque apenas
*itálico*:

* o *model*.
* a *view*.
* o *controller*.
* o *template*.
* o *helper*.
* o *layout*.
* o *logger*.
* a *stack trace*.
* os *assets*.
* o *Shell*.
* o *debugger*.
* o *backtrace*.
* os *cookies*.
* os *initializers*.
* os *generators*.
* o *middleware*.
* a *partial*.
* a *string*.
* o *symbol*.
* a *fixture*.
* o *driver*.

### Algumas sugestões de tradução para termos específicos

Termo         | Sugestão de tradução    |
--------------|------------------------ |
fallback      | plano de contingência   |
Edge Guides   | Guias Não Estáveis      |
staging       | homologação             |
logged        | adicionado ao log       |
breakpoints   | pontos de interrupção   |
debugging     | debug                   |

### Casos especiais
*Deploy*: analisar caso a caso. Sugestão: utilizar implantar ou implantação seguido
por deploy em itálico e entre parênteses. Também pode ser aceito somente deploy em
itálico se o contexto permitir. Exemplo:

> "... scripts utilizados para configurar, atualizar, implantar (deploy) ou rodar sua aplicação."

*Log*: pode ser usado o termo do inglês *em itálico*, mas também pode ser
traduzido como registro. Avaliar cada caso para que o sentido permaneça correto
e a leitura flua melhor. Exemplo:

> When something is logged, it's printed into the corresponding log if the log
level of the message is equal to or higher than the configured log level.

> Quando algo é adicionado ao *log*, ele é impresso no registro correspondente
caso o nível de *log* da mensagem seja igual ou maior ao nível configurado.

## TIP, NOTE e WARNING
Existem algumas marcações que aparecem como TIP: , NOTE: ou WARNING:. Tais
marcações não devem ser traduzidas, pois elas são interpretadas para renderizar
uma caixa de texto de estilo especial na página da aplicação. Exemplos:

```
NOTE: If you're using Windows Subsystem for Linux then there are currently some
limitations on file system notifications that mean you should disable the `spring`
and `listen` gems which you can do by running `rails new blog --skip-spring --skip-listen`.

TIP: You can see all of the command line options that the Rails application builder
accepts by running `rails new -h`.

WARNING: There are many ways to change the state of an object in the database.
Some methods will trigger validations, but some will not. This means that it's
possible to save an object in the database in an invalid state if you aren't careful.
```

O texto acima será renderizado como:

![alt text](https://campuscode-site.s3-sa-east-1.amazonaws.com/artigos/railsguides_manual.png "TIP, NOTE e WARNING")
