**NÃO LEIA ESTE ARQUIVO NO GITHUB, OS GUIAS SÃO PUBLICADOS NO https://guiarails.com.br.**
**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**

Política de Manutenção para Ruby on Rails
====================================

O suporte do framework Rails é dividido em quatro grupos: Novas features, correções de bug, problemas de segurança e problemas críticos de segurança. Eles são manuseados como exemplificado a seguir, todas versões, exceto lançamentos de segurança, em formato `X.Y.Z`.

--------------------------------------------------------------------------------

O Rails segue uma versão alterada do [semver](https://semver.org/):

***Patch* `Z`**

Apenas correções de bug, sem mudanças de API e sem features novas.
Exceto quando necessário para correções de segurança.

***Minor* `Y`**

Novas features, podem conter mudanças na API (serve como versões *major* do Semver).
Mudanças significativas são notificadas junto a avisos de depreciação em lançamentos *minor* ou *major* anteriores.

**Major `X`**

Novas features, possivelmente contém mudanças de API.
A diferença entre as lançamentos *minor* e *major* do Rails é a magnitude das mudanças significativas, e geralmente para ocasições especiais.

Novas Features
------------

Novas features são adicionadas apenas na branch principal e não estarão disponíveis em lançamentos pontuais.

Correções de Bugs
---------

Apenas o lançamento mais recente vai receber correções de bugs.
Quando bugs o suficiente forem corrigidos e é considerado que vale a pena lançar uma nova gem, essa é a branch em que isso acontece.


Em ocasiões especiais, em que alguém do *Core Team* concorda em dar suporte a mais versões, elas são todas incluídas na lista de versões suportadas.

**Versões incluídas atualmente:** `7.0.Z`.

Problemas de Segurança
---------------

A versão atual e a anterior mais recente vão receber *patches* e novas versões em casos de um problema de segurança.

Esses lançamentos são criados utilizando a última versão lançada, aplicando as *patches* de segurança e lançando. Esses *patches* são, então, aplicados no fim da branch x-y-stable. Por exemplo, um lançamento de segurança teórico 1.2.2.1 seria construído a partir da 1.2.2 e, depois, adicionado no fim da 1-2-stable. Isso significa que lançamentos de segurança são fáceis de atualizar se você usar a versão mais recente do Rails.

Apenas *patches* de seguranças diretos serão incluídos em lançamentos de segurança. Correções para bugs que não são relacionados à segudança que resultam de um *patch* de segurança podem ser publicados na branch x-y-stable de um lançamento, e será lançado apenas em uma nova gem de acordo com a política de Correção de Bugs.


**Versões incluídas atualmente:** `7.0.Z`, `6.1.Z`.

Problemas Críticos de Segurança
----------------------

Para problemas crítico de segurança, todos os lançamentos que estão na versão *major* atual, e o último release na versão *major* anterior, vão receber patches e novas versões. A classificação do problema de segurança é julgado pelo time *core*.


NOTE: Rails 5.2.Z está incluído na lista de versões suportadas até dia 1 de Junho de 2022.

NOTE: Rails 6.0.Z está incluído na lista de versões suportadas até dia 1 de Junho de 2023.

**Versões atualmente incluídas:** `7.0.Z`, `6.1.Z`, `6.0.Z`, `5.2.Z`.

Versões não suportadas para lançamentos
--------------------------

Quando uma versão não é mais suportada, é sua responsabilidade lidar com bugs e problemas de segurança. Nós podemos prover *backports* das correções e publicar elas no git, porém não haverá lançamento de uma versão nova.
Se você não estiver confortável em manter sua versão, deve atualizar para uma das versões suportadas.
