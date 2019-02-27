# Boas-vindas ao Guia Rails

## O que é o Guia Rails?

O Guia Rails nasceu da vontade de trazer mais pessoas para a comunidade mas sem a barreira da língua inglesa. Buscamos uma forma de difundir todo tipo de
conhecimento e tentar estimular sempre que possível material em português.

Neste repositório buscamos ajuda para a tradução para pt-BR do material
encontrado no https://guides.rubyonrails.org/ que é uma excelente fonte de
aprendizado de Ruby on Rails.

Você pode ver o conteúdo já traduzido em: http://guiarails.com.br/

## Como ajudar

Se você tem conhecimento em Rails ou está aprendendo e gostaria de aprender mais traduzindo este Guia, seja muito bem-vindo. Abaixo deixamos alguns passos sobre como contribuir:

1. Verifique na pasta pt-BR/ os arquivos `.md` (feitos usando Markdown) se a 
página que você gostaria de traduzir tem textos em inglês, por exemplo a página
 `active_record_basics.md`

1. Verifique no repositório principal se já existe uma issue para aquela página 
ou abra uma issue para o capítulo ou capítulos que deseja traduzir, exemplo:

    - A página Active Record Basics apresenta os capítulos: *What is Active 
    Record* , *Convention over Configuration in Active Record*, *Creating Active 
    Record Models*, etc.

    - Recomendamos abrir uma issue por capítulo e não focar na tradução da página
     toda assim outras pessoas também podem contribuir com a página.
1. Faça um Fork do projeto e clone para a sua máquina

1. Ao iniciar a tradução crie um Branch referente a sua tradução e já abra um Pull
 Request em WIP (Work in Progress), assim podemos saber que você iniciou uma
  tradução e marque no corpo do texto as issues que deseja traduzir. Um exemplo: 
  campuscode/rails-guides-pt-BR#numero_da_issue

1. Faça a tradução normalmente fazendo commits e ao final retire o WIP do Pull
 request para todos saberem que você terminou.
1. Pronto! Agora é só esperar a comunidade avaliar a tradução. 

## Verificando o resultado da sua contribuição

Não é necessário verificar o HTML gerado pela sua contribuição, mas se mesmo 
assim você gostaria de ver como isso é feito temos um Guia abaixo.

### Atualizando as dependências

Subir o Rails só para contribuir com a documentação é desnecessário, por isso para
 contribuir não temos a dependência dele. Mas para você testar a página da 
 sua contribuição sim. Para isso o Rails está no projeto como um git 
 submodule então para iniciá-lo execute o comando:

`git submodule update --init`

Assim que o Rails for clonado para o seu projeto você pode rodar um `bin/setup`
 para instalar as dependências da compilação do Guia (não é necessário 
 baixar todas as gems do Rails, as dependências podem ser verificadas no 
 arquivo `Gemfile`).

**OBS.:** Incluímos arquivos de Docker (Dockerfile e docker-compose.yml) caso queira utilizá-los :)


### Criando os arquivos do site

Com as dependências satisfeitas você pode rodar o comando:

`rake generate:guides:html`

Ele vai compilar os arquivos Markdown em HTML e jogar o resultado na pasta 
`./output/pt-BR`

Por fim para abrir o Guia navegue até essa pasta e abra o arquivo `index.html.erb`:

**Caso tenha qualquer dificuldade você pode abrir uma issue.**

## Obrigado

Obrigado pela sua contribuição, cada uma delas é muito importante para fazer a
 comunidade crescer. Não temos o intuito de ser donos desse projeto e sim que a 
 comunidade possa ser viva e crescer a cada dia. Assim buscamos contribuir com
  material em pt-BR para trazer mais pessoas para o ecossistema Ruby que 
  tanto amamos.
