# Principios de codigo — Referencia para a skill-executora

> Principios universais de engenharia de software. Nao sao especificos de nenhuma linguagem.
> A executora aplica esses principios ao ESCREVER codigo. A auditora verifica regras especificas de stack.

## KISS — Simplicidade primeiro

Codigo deve ser o mais simples possivel. Se existe uma forma direta de resolver, usar essa. Abstracoes, patterns e indirecoes so entram quando o problema exige.

## YAGNI — Nao construa o que nao precisa agora

Nao implementar classes, metodos ou parametros pensando em "possibilidades futuras". Implementar estritamente o que o requisito atual exige. Codigo especulativo e divida tecnica desde o nascimento.

## SoC — Separacao de responsabilidades

Cada camada tem um trabalho definido. Handler nunca faz query. Repositorio nunca valida request. Entidade nunca acessa banco.

## Lei de Demeter — Fale so com seus vizinhos

Metodo deve chamar apenas: seus proprios metodos, metodos dos parametros recebidos, metodos de objetos criados internamente. Nunca encadear chamadas cruzando camadas.

## Composicao sobre heranca

Preferir injecao de dependencia e composicao a hierarquias de heranca profundas. Heranca so quando ha relacao "e um" genuina.

## SOLID — Responsabilidade Unica (SRP)

Uma classe tem uma e apenas uma razao para mudar. Se a classe precisa mudar por dois motivos independentes, ela esta fazendo demais.

## SOLID — Aberto/Fechado (OCP)

Classes devem ser abertas para extensao, fechadas para modificacao. Adicionar comportamento sem alterar codigo existente.

## SOLID — Inversao de Dependencia (DIP)

Modulos de alto nivel nao dependem de modulos de baixo nivel. Ambos dependem de abstracoes.
