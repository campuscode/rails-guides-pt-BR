# Guia de Tradução

## Sobre

A tradução da documentação do Rails para português do Brasil ocorre de forma não oficial apesar de estarmos [listados no site](https://guides.rubyonrails.org/contributing_to_ruby_on_rails.html#translating-rails-guides) como um projeto de tradução. É um esforço da comunidade para que novas pessoas possam ter o primeiro contato com esse framework que gostamos tanto, sem que a língua inglesa seja mais uma barreira no aprendizado. O foco é democratizar o conhecimento.

A tradução é coordenada pelo @campuscode/guia-rails-team hoje composto por:

- [akaninja](https://github.com/akaninja)
- [Auralcat](https://github.com/Auralcat)
- [erikacamposdesign](https://github.com/erikacamposdesign)
- [HenriqueMorato](https://github.com/HenriqueMorato)
- [joaorsalmeida](https://github.com/joaorsalmeida)
- [tkusuki](https://github.com/tkusuki)

Toda a infraestrutura do projeto (custos de servidor, domínio, etc.) é patrocinada pela [Campus Code](https://www.campuscode.com.br/), mas o Guia é independente justamente para ser um projeto da comunidade sem viés.

### Participe conosco

Estamos sempre precisando de pessoas para revisar traduções, gerenciar issues e páginas, e realizar outras ações do dia a dia. Quer colaborar? [Fale conosco!](https://github.com/campuscode/rails-guides-pt-BR/discussions)

## Sua primeira contribuição

Se você tem conhecimento em Rails ou ainda está aprendendo, nossas boas-vindas!

Abaixo, deixamos alguns passos sobre como fazer contribuições.

### Criando e configurando sua conta no GitHub

Para começar, crie uma conta no GitHub [aqui](https://github.com/signup), caso ainda não tenha.

Depois disso, você precisa criar uma chave SSH para vincular com a sua conta. Você pode usar [este tutorial](https://docs.github.com/pt/github/authenticating-to-github/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) para criá-la.

Com sua chave SSH configurada, está tudo certo para começar!

> Se você nunca usou `git` não se preocupe, todos os passos são descritos por aqui. Mas caso queira aprender mais recomendamos a leitura [deste guia](https://git-scm.com/book/pt-br/v2).

### Clone do repositório

Depois de configurar sua chave SSH, você precisa fazer uma cópia do projeto (repositório) para a sua conta clicando no botão `Fork` do GitHub, pois, apesar deste projeto ser público, para ter acesso a ele, você modifica a sua cópia e submete essas modificações para o nosso repositório.

Depois disso, você precisa levar essa sua cópia para a sua máquina para ter acesso aos arquivos de tradução. Para isso, usamos o comando `git clone`.

```bash
git clone git@github.com:Seu User Aqui/rails-guides-pt-BR.git
```
Importante: lembre de trocar para o seu nome de usuário do GitHub.

> Se é a sua primeira vez por aqui, pode seguir para “Iniciando a tradução”, agora, se você já tinha o repositório antes de trocarmos o nome da branch principal, será necessário realizar os seguintes passos:

```bash
git branch -m master main
git fetch origin
git branch -u origin/main main
git remote set-head origin -a
```

## Iniciando a tradução

### Escolhendo um capítulo para traduzir

O primeiro passo para iniciar uma tradução é decidir que arquivo você vai traduzir. Na pasta `pt-BR/`, que está na raiz do projeto, verifique nos arquivos `.md` (criados usando Markdown) se a página que você gostaria de traduzir possui textos em inglês. Vamos usar como exemplo a página `active_record_basics.md`.

A página Active Record Basics apresenta os capítulos: What is Active Record, Convention over Configuration in Active Record, Creating Active Record Models, etc.

> Fazemos a tradução capitulo a capitulo para simplificar o processo de revisão.

Depois de escolhido o capitulo em que você vai trabalhar, verifique [nesse endereço](https://github.com/campuscode/rails-guides-pt-BR/issues) se já existe uma `issue` criada para aquele capitulo. Isso nos ajuda a gerenciar quem está traduzindo cada trecho. 

Se a issue não existir, abra uma para o capítulo que deseja traduzir e faça um comentário avisando que irá iniciar a tradução.

Se ela existir, verifique se já não há alguém trabalhando nessa tradução. Normalmente deixamos todas abertas para simplificar, então clique nela e dê uma olhada nos comentários. Se for começar, faça um comentário avisando que irá iniciar a tradução.

### Começando a tradução

O primeiro passo é ler o [Manual de Tradução](https://github.com/campuscode/rails-guides-pt-BR/blob/main/TRANSLATION_MANUAL.md) para conhecer os padrões, dicas de tradução e termos comuns usados no Guia.

Depois, você pode criar no terminal, usando git, um [*branch*](https://git-scm.com/book/pt-br/v2/Branches-no-Git-Branches-em-poucas-palavras) referente à sua tradução e abrir um Pull Request ([link da documentação](https://docs.github.com/pt/github/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request)) em Draft ou com a palavra WIP (Work in Progress) antes do título. Desta forma, todos podem saber que você iniciou uma tradução. Lembre-se de marcar no texto do Pull Request a issue que planeja traduzir (campuscode/rails-guides-pt-BR#numero-da-issue).

Faça a tradução do capítulo fazendo commits durante o processo. Ao final, retire o WIP do Pull Request (ou o Draft) para que todos saibam que você terminou a tradução.

Pronto! Agora é só esperar a comunidade avaliar a tradução.

### Revisão

Alguém da comunidade vai passar pelo seu texto fazendo sugestões de melhoria para que se encaixe melhor com outras partes do guia ou até pequenas revisões de texto ou acentuação. É um costume deixar sugestões para, caso você goste da recomendação, ficar fácil aplicá-la pelo browser no GitHub.

Fique à vontade para sugerir, descartar ou responder a recomendação. Esse projeto não é de uma pessoa, mas, sim, da comunidade.

### Colocando no ar :rocket:

Depois da contribuição aprovada, alguém da equipe do Guia vai colocá-la no ar e avisar no Pull Request quando isso acontecer. Desse modo, você pode conferir em primeira mão o fruto do seu trabalho!

#### Boa contribuição. A comunidade agradece :clap:

#### Ainda tem dúvidas ou não sabe como começar? Não hesite em nos procurar [aqui](https://github.com/campuscode/rails-guides-pt-BR/discussions)

Se sua dúvida for relacionada à sua contribuição, basta comentar no Pull Request marcando o `@campuscode/guia-rails-team`.

Contamos com a participação de todos para que seja possível dar oportunidade a cada vez mais pessoas no mundo da tecnologia, sem que o inglês seja mais uma barreira.
