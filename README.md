# Boas-vindas ao Guia Rails

## O que é o Guia Rails?

O Guia Rails nasceu da vontade de trazer mais pessoas para a comunidade, mas sem
a barreira da língua inglesa. É uma forma de difundir o conhecimento e estimular
a criação de materiais em português.

Neste repositório buscamos ajuda na tradução do [guides.rubyonrails.org](https://guides.rubyonrails.org/)
para pt-BR, já que lá temos uma excelente fonte de estudo e documentação de
Ruby on Rails.

Você pode ver o conteúdo já traduzido em [guiarails.com.br](https://guiarails.com.br/)

## Como ajudar

Seja você é alguém que tem conhecimento em Rails ou ainda está aprendendo,
nossas boas-vindas!

Abaixo deixamos alguns passos sobre como fazer contribuições:

1. Na pasta pt-BR/, que está na raiz do projeto, verifique nos arquivos `.md`
(criados usando Markdown) se a página que você gostaria de traduzir tem textos
em inglês. Vamos usar de exemplo a página `active_record_basics.md`.

1. Verifique no repositório principal se já existe uma issue para aquela página.
1. Se a issue não existir abra uma para o capítulo ou capítulos que deseja traduzir, por exemplo:

    - A página Active Record Basics apresenta os capítulos: *What is Active
      Record*, *Convention over Configuration in Active Record*,
      *Creating Active Record Models*, etc.

    - Recomendamos abrir uma issue por capítulo e não focar na tradução da
      página toda.
    - Temos um template de issue que pode ser utilizado, para criar a issue.

1. Faça um Fork do projeto e clone para a sua máquina.

1. Ao iniciar a tradução, crie um Branch referente à sua tradução e abra um Pull
Request ([link da documentação](https://help.github.com/en/articles/creating-a-pull-request))
com a palavra WIP (Work in Progress) antes do título ou em Draft. Assim todos
podem saber que você iniciou uma tradução. Lembre-se de marcar no texto do
Pull Request as issues que planeja traduzir
(campuscode/rails-guides-pt-BR#numero-da-issue).

1. Faça a tradução do capítulo fazendo commits durante o processo. Ao final,
retire o WIP do Pull Request (ou o Draft) para que todos saibam que você
terminou a tradução.

1. Pronto! Agora é só esperar a comunidade avaliar a tradução.

## Visualizando o conteúdo traduzido

Não é necessário verificar o HTML gerado pela sua contribuição, mas temos
um Guia abaixo mostrando como isso é feito.

### Pré-requisitos

**Ruby 2.5+**

### Atualizando as dependências

Não é preciso instalar as dependências do Rails para gerar a documentação,
mas temos que executar o comando abaixo para disponibilizar a `rake` que
gera os arquivos HTML a partir dos arquivos Markdown.

`git submodule update --init`

Assim que o Rails for clonado para o seu projeto você pode rodar um `bin/setup`
para instalar as dependências do Guia (não é necessário baixar todas as gems do
Rails, as dependências podem ser verificadas no arquivo `Gemfile`).

**OBS.:** temos arquivos de Docker (Dockerfile e docker-compose.yml)
:slightly_smiling_face:


### Criando os arquivos do site

Com as dependências instaladas você pode rodar o comando:

`rake guides:generate:html`

Ele vai gerar os arquivos HTML e enviar o resultado para a pasta
`./output/pt-BR`

Por fim, para abrir o Guia navegue até essa pasta e abra o arquivo
`index.html.erb`:

**Caso tenha qualquer dificuldade, abra uma issue.**

## Agradecimentos

Agradecemos sua contribuição. Cada uma é importante para fazer a comunidade
crescer. Contribuindo com material em pt-BR trazemos mais pessoas
para o ecossistema Ruby que tanto amamos.
