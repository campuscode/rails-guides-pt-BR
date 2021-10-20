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

Se você tem conhecimento em Rails ou ainda está aprendendo,
nossas boas-vindas!

Temos um Guia sobre como contribuir com o projeto que você pode acessar
[aqui](https://github.com/campuscode/rails-guides-pt-BR/blob/main/CONTRIBUTING.md)

Caso tenha dúvidas estamos [aqui para
ajudar](https://github.com/campuscode/rails-guides-pt-BR/discussions)!

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
