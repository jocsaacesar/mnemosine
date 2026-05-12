\---  
documento: padroes-design  
versao: 1.0.0  
criado: 2026-05-08  
atualizado: 2026-05-08  
total\_regras: 72  
severidades:  
 erro: 36  
 aviso: 36  
escopo: Toda interface visual da plataforma Taito (landing publica, painel logado, fluxos de avaliacao, comunicacoes)  
stack: agnostico (HTML/CSS/JS-vanilla, exemplos em CSS custom properties + WordPress/PHP)  
aplica\_a: \[taito.app.br, painel-taito, multisite-taito\]  
requer: \[\]  
referenciado\_por: \[padroes-php, padroes-poo, padroes-seguranca\]  
fontes: |  
 - Auditoria visual de 13 telas de taito.app.br realizada em 2026-05-08:  
 Hero da landing, secao "Nao somos catalogo. Somos ciclo.", grid de 14  
 competencias, secao LGPD/Compliance, secao "Conteudo que desenvolve",  
 pagina Precos (hero + cards de plano), painel/inicio, painel/perfil  
 (3 estados), painel/mapa, painel/pdi, painel/creditos, questionario  
 (44 de 140 perguntas, 31% de progresso).  
 - Memoria do projeto: hero copy oficial "Pare de demitir. Comece a  
 desenvolver mais." (rotativo: contrate melhor / desenvolva mais /  
 avalie corretamente).  
 - Identidade ja estabelecida na landing publica (esta serve de  
 referencia, nao de espelho a ser contestado).  
 - Praticas modernas de design system (Linear, Stripe, Vercel, Notion).  
principio\_orientador: |  
 O Taito ja tem uma identidade visual consolidada na landing publica  
 (taito.app.br/ e taito.app.br/precos/). O problema nao e "criar uma  
 nova marca": e LEVAR a marca que ja existe para dentro do painel  
 logado, do questionario e dos fluxos transacionais. Esse documento  
 consolida os tokens, principios e padroes que ja estao implicitos na  
 landing -- e os explicita -- para que o painel possa se alinhar a eles  
 de forma sistematica, sem perder a identidade que ja foi conquistada.  
\---  
  
\# Padroes de Design -- Sistema Visual Taito  
  
\> Documento constitucional do design visual.  
\> Vale para todas as telas da plataforma Taito: landing publica  
\> (taito.app.br), painel logado (/painel/), fluxos de avaliacao  
\> (/mapa/questionario/), comunicacoes transacionais e qualquer tela  
\> futura que carregue a marca.  
\>  
\> Codigo / template / mockup que viola regra ERRO nao e discutido --  
\> volta para correcao.  
\>  
\> \*\*72 regras | IDs: DSG-001 a DSG-072\*\*  
\> Tokens, componentes e principios universais vivem aqui.  
\> Regras de PHP/POO/seguranca vivem nos respectivos \`padroes-\*.md\`.  
  
\> \*\*A premissa deste documento.\*\* Apos auditoria visual completa em  
\> 2026-05-08, o diagnostico e claro: existem \*\*dois Taitos hoje\*\*.  
\>  
\> - \*\*Landing publica e Precos\*\* -- bem cuidados. Hero escuro com  
\> tipografia forte, gradiente laranja em palavra-chave, padroes de  
\> pixels decorativos, cards com divisor laranja no topo, grid de 14  
\> competencias em fundo escuro com numeracao 01-14, card  
\> "RECOMENDADO" com destaque visual real. Tem identidade.  
\>  
\> - \*\*Painel logado e questionario\*\* -- visual generico de  
\> "Bootstrap-CRM-de-2018". Tags laranja chapadas, input file HTML  
\> bruto, empty states mortos, zero motion, header e footer de  
\> marketing aparecendo durante avaliacao critica, cards quadrados  
\> sem hierarquia. \*\*Foi essa a tela que o usuario chamou de "parece  
\> feita em Java"\*\* -- e e exatamente o que e.  
\>  
\> O movimento que este documento prescreve nao e "criar identidade  
\> nova". E \*\*extrair, formalizar e replicar\*\* a identidade que ja  
\> existe na landing -- estendendo-a com sistema de tokens, regras de  
\> componentes, microinteracoes e padroes de tela que ainda nao  
\> existem. Modernizar sem perder identidade significa exatamente  
\> isso: tornar consistente o que ja era acertado, e cortar o que  
\> destoa.  
  
\---  
  
\#\# Como usar este documento  
  
\#\#\# Para o desenvolvedor / dev front  
  
1\. Antes de tocar qualquer tela do painel ou da landing, leia as Secoes 0 (diagnostico), 1 (principios), 2 (tokens) e 3 (componentes minimos).  
2\. Antes de abrir um PR que altere markup ou CSS, passe pelo checklist do DoD no fim deste documento.  
3\. Quando receber apontamento em code review com ID (ex.: "viola DSG-014 -- cor primaria chapada"), consulte a regra aqui e corrija.  
4\. Em duvida sobre token, \*\*consulte a Secao 2\*\* (Tokens) -- a fonte unica da verdade. Nao invente valor "porque ficou bonito": adicione token novo, justifique no PR e atualize este documento.  
5\. Tudo neste documento e implementavel em HTML/CSS/JS vanilla, sem dependencia de framework JS. O multisite WordPress / tenant-starter consome via \`\<style\>\` do tema-base.  
  
\#\#\# Para o designer  
  
1\. Use os tokens (Secao 2) como base de qualquer mockup novo. Nao introduza cor / tamanho / raio / sombra que nao esteja na escala -- ou justifique por escrito por que precisa de novo token.  
2\. Os principios (Secao 1) sao reguas de decisao. Quando dois caminhos forem possiveis, o que respeita mais principios vence.  
3\. Mockups novos viram inputs do design system: cada componente novo entra na Secao 3 com regra propria (DSG-XXX) e exemplo de implementacao.  
4\. Microcopy (Secao 6) e tao importante quanto pixel: revise junto.  
  
\#\#\# Para o auditor (humano ou IA)  
  
1\. Leia o frontmatter para entender escopo e fontes da auditoria.  
2\. Audite cada tela contra as regras por ID e severidade. Use o inventario da Secao 0 como ponto de partida -- as telas la listadas ja foram auditadas e tem violacoes mapeadas.  
3\. Classifique violacoes: ERRO bloqueia merge, AVISO precisa de justificativa escrita.  
4\. Referencie violacoes pelo ID exato (ex.: "DSG-027: tela \`/painel/?pagina=perfil\` usa \`\<input type=file\>\` cru, viola padrao de upload").  
5\. Em duvida, a hierarquia e: padroes-seguranca \> padroes-poo \> padroes-design \> padroes-php \> convencoes do framework. Mas note: estilo visual, microcopy e fluxo sempre entram em padroes-design, nao nos outros.  
  
\#\#\# Para o Claude Code  
  
1\. Ao revisar PR de UI, leia este documento e aplique cada regra relevante ao diff.  
2\. Referencie violacoes pelo ID exato (ex.: "DSG-014: tag PREMIUM em laranja chapada, sem gradiente nem hierarquia visual").  
3\. Respeite a severidade: ERRO e bloqueante, AVISO e recomendacao forte.  
4\. Cross-references: quando a regra de design tocar uma regra de OO ou de seguranca, citar ambas (ex.: "ver tambem POO-053 e SEG-003").  
5\. Nunca invente regra que nao esta neste documento. Se identificar lacuna, reporte ao usuario com sugestao.  
  
\---  
  
\#\# Severidades  
  
| Nivel | Significado | Acao |  
|-------|-------------|------|  
| \*\*ERRO\*\* | Violacao inegociavel de identidade, acessibilidade ou usabilidade critica | Bloqueia merge. Corrigir antes de review. |  
| \*\*AVISO\*\* | Recomendacao forte de polish, consistencia ou performance perceptiva | Deve ser justificada por escrito se ignorada. |  
  
Toda regra deste documento aponta para um dos seguintes objetivos:  
  
\- \*\*Identidade\*\* -- a tela parece o Taito (e nao Bootstrap, e nao Material, e nao Java).  
\- \*\*Coerencia\*\* -- a tela parece da mesma plataforma da tela ao lado.  
\- \*\*Hierarquia\*\* -- o olho sabe para onde ir e em que ordem.  
\- \*\*Resposta\*\* -- a tela responde imediatamente a cada acao do usuario.  
\- \*\*Respeito\*\* -- a tela nao trapaceia o usuario com darkpattern, fricao desnecessaria ou rudeza textual.  
\- \*\*Performance perceptiva\*\* -- a tela parece rapida, mesmo quando nao e.  
  
\---  
  
\#\# Sumario das secoes  
  
| Secao | Tema | IDs |  
|-------|------|-----|  
| 0 | Diagnostico atual da plataforma (auditoria 2026-05-08) | -- |  
| 1 | Principios visuais (frases-regua) | DSG-001 a DSG-010 |  
| 2 | Tokens (cor, tipografia, espaco, raio, sombra, movimento) | DSG-011 a DSG-022 |  
| 3 | Componentes minimos | DSG-023 a DSG-040 |  
| 4 | Padroes de tela | DSG-041 a DSG-052 |  
| 5 | Microcopy e voz da marca | DSG-053 a DSG-058 |  
| 6 | Acessibilidade | DSG-059 a DSG-064 |  
| 7 | Movimento e microinteracoes | DSG-065 a DSG-068 |  
| 8 | Implementacao tecnica | DSG-069 a DSG-072 |  
  
\---  
  
\#\# 0. Diagnostico atual da plataforma (auditoria 2026-05-08)  
  
\> Esta secao e o \*\*inventario\*\* que motiva todo o resto. Foi feita uma  
\> varredura de 13 telas no dia 2026-05-08, com a conta logada  
\> particular.jota@gmail.com. As observacoes abaixo sao o ponto de  
\> partida: ate cada item ser corrigido, ele continua sendo violacao  
\> aberta.  
  
\#\#\# 0.1 Mapa do que foi auditado  
  
| \# | URL | Categoria | Status atual |  
|---|-----|-----------|--------------|  
| 1 | \`/\` (hero + stats) | Landing publica | OK -- usar como referencia |  
| 2 | \`/\` (secao "Nao somos catalogo") | Landing publica | OK -- usar como referencia |  
| 3 | \`/\` (grid 14 competencias) | Landing publica | OK -- usar como referencia |  
| 4 | \`/\` (LGPD/compliance) | Landing publica | OK -- usar como referencia |  
| 5 | \`/\` (Conteudo que desenvolve) | Landing publica | OK -- usar como referencia |  
| 6 | \`/precos/\` (hero + ciclo de creditos) | Landing publica | OK -- usar como referencia |  
| 7 | \`/precos/\` (cards de plano) | Landing publica | OK -- excelente, card RECOMENDADO bem feito |  
| 8 | \`/painel/?pagina=inicio\` | Painel logado | RUIM -- 3 cards mortos, hierarquia confusa |  
| 9 | \`/painel/?pagina=perfil\` | Painel logado | MUITO RUIM -- input file cru, formulario chato |  
| 10 | \`/painel/?pagina=mapa\` | Painel logado | RUIM -- alerta amarelo Bootstrap, historico magro |  
| 11 | \`/painel/?pagina=pdi\` | Painel logado | MEDIANO -- empty state generico |  
| 12 | \`/painel/?pagina=creditos\` | Painel logado | MUITO RUIM -- destoa muito da \`/precos/\` |  
| 13 | \`/mapa/questionario/?teste\_id=3\` | Fluxo critico | CRITICO -- header e footer de marketing durante teste |  
  
\#\#\# 0.2 Diagnostico geral em 4 frases  
  
1\. \*\*A marca existe.\*\* A landing publica e a pagina de precos foram cuidadas com identidade clara: fundo escuro alternando com fundo claro, tipografia forte, gradiente laranja seletivo, padroes decorativos sutis, cards com hierarquia, card RECOMENDADO com destaque real.  
2\. \*\*A marca nao chegou no painel.\*\* O painel logado parece um produto diferente: gris-Bootstrap por todo lado, tags laranja chapadas, formularios sem polish, empty states mortos, zero microinteracao.  
3\. \*\*O questionario e o ponto critico.\*\* E ali que o usuario passa 30 a 45 minutos. E ali que ha mais ruido visual: header de marketing com Blog/Podcast/Cursos, footer com newsletter e selos de pagamento -- tudo durante a avaliacao psicometrica. Modo focado nao existe.  
4\. \*\*A acao certa e replicar para dentro o que ja existe fora.\*\* Os tokens, padroes e principios deste documento sao em grande parte a explicitacao do que a landing ja faz implicitamente. Em seguida, o painel passa por uma migracao tela a tela ate todos os artefatos respirarem o mesmo design system.  
  
\#\#\# 0.3 Os 12 sintomas mais visiveis de "parece Java" no painel  
  
1\. \*\*Tag PREMIUM em laranja chapada\*\* ao lado do logo, sem gradiente, sem peso tipografico cuidado, sem altura confortavel. Parece adesivo de plastico.  
2\. \*\*Tag "Em breve"\*\* no item "Feedback" da sidebar, em laranja chapado mais claro -- generica, sem voz, sem chamado a acao.  
3\. \*\*Input file HTML cru\*\* (\`\<input type="file"\>\`) na pagina de perfil, exibindo "Choose File / No file chosen". E o sintoma mais reconhecivel de "ninguem polir" que existe na web.  
4\. \*\*Alerta amarelo Bootstrap\*\* ("Teste em andamento") na pagina Mapa -- amarelado padrao \`.alert-warning\` de Bootstrap, sem identidade.  
5\. \*\*Cards do painel inicial sao quadrados estaticos\*\* sem hierarquia -- "Mapa da Excelencia" ativo, "Plano de Desenvolvimento" e "Feedback" em cinza apagado. Os 3 estao na mesma altura, mesma largura, mesma cor de fundo -- nada destaca o que pode ser feito agora.  
6\. \*\*Tela de Creditos tem 4 cards de plano sem destaque para o recomendado\*\* -- ironicamente, a \`/precos/\` publica acertou isso e o painel logado (que e onde a compra acontece) ignorou.  
7\. \*\*Numero de saldo "0 creditos"\*\* na tela de Creditos -- enorme, mas chapado, sem celebracao visual, sem call-to-action emocional. Saldo e informacao emocional num produto que vende credito.  
8\. \*\*Empty states sem alma\*\* -- "Plano de Desenvolvimento -- Complete o Mapa primeiro" e o tom de mensagem de erro de CRM, nao de produto que vende transformacao.  
9\. \*\*Header de marketing aparece durante o questionario\*\* -- com Blog, Podcast, Videos, Cursos, Eventos, Precos. O usuario esta respondendo questao 44 de 140 e tem o menu de marketing ativo.  
10\. \*\*Footer de marketing aparece durante o questionario\*\* -- com newsletter, LinkedIn, Instagram, Mercado Pago, AES-256. O usuario passa minutos olhando isso enquanto pensa na resposta.  
11\. \*\*Botao "Proxima -" disabilitado durante 3s\*\* com texto "Aguarde 3s..." no questionario -- sem countdown visual, sem progresso, sem anti-frustracao.  
12\. \*\*Zero motion no painel inteiro\*\* -- nenhum hover, nenhum click feedback, nenhum transition de estado. Cada acao e instantanea (no sentido pejorativo: nao da tempo nem de respirar).  
  
\#\#\# 0.4 O que aponta o caminho certo (referencias internas)  
  
Antes de buscar referencia em Linear / Stripe / Vercel, \*\*olhe a propria landing\*\*. Ela ja resolveu varias coisas que o painel ainda nao:  
  
\- Hero com tipografia escala 1 (h1 grande, peso pesado) e palavra-chave em gradiente laranja -- replicar como padrao de hero/title em todas as telas-vitrine.  
\- Cards "Ciencia / Ciclo / Cultura" com divisor laranja no topo -- replicar o padrao "linha de acento" como linguagem de cards de feature.  
\- Card "RECOMENDADO" da \`/precos/\` com fundo escuro e tag laranja em cima do card -- replicar para destaque de plano padrao no painel de Creditos.  
\- Grid de 14 competencias com numeracao 01-14 em laranja, fundo escuro -- replicar como linguagem para listas hierarquicas.  
\- Stats em linha (14 / 320+ / 90 / 3) com numero grande e label discreto embaixo -- replicar para todo numero do painel (saldo, contadores, progresso).  
\- Linha de selos (AES-256-GCM / Base FEM / LGPD Ready / NR-1 / API REST) -- replicar para footer/rodape do painel.  
  
Cada item da Secao 1, 2 e 3 deste documento extrai um desses padroes da landing e o formaliza como token / componente / regra.  
  
\---  
  
\#\# 1. Principios visuais (frases-regua)  
  
\> Os principios sao curtos por design. Cada um cabe numa frase e  
\> resolve uma classe de decisoes futuras. Quando dois caminhos forem  
\> possiveis num PR, o que respeita mais principios vence -- e o  
\> revisor pode citar o ID na review.  
  
\#\#\# DSG-001 -- Respiracao antes de densidade \[ERRO\]  
  
\*\*Regra:\*\* Toda tela respira. Espaco em branco e parte do design, nao desperdicio. Cards, secoes e textos tem padding generoso. Conteudo nunca encosta na borda; nunca encosta uma cor na outra sem buffer.  
  
\*\*Diagnostico atual:\*\* O painel logado tem cards encostados, conteudo colado em divisorias, formularios apertados. A landing ja respeita esse principio (secao "Nao somos catalogo" tem 96px de padding vertical, cards tem 32px de padding interno).  
  
\*\*Sugestao:\*\* Adotar a escala de espaco da landing como token (Secao 2.4). Padding interno minimo de cards: 24px. Espaco vertical entre secoes: 64-96px. Espaco entre items de lista: 16px.  
  
\*\*Por que:\*\* Densidade dispara a sensacao de "Java enterprise" -- toda informacao apertada parece tela de SAP. Plataformas modernas (Linear, Notion, Stripe) tem mais respiracao que a media.  
  
\---  
  
\#\#\# DSG-002 -- Tipografia faz hierarquia, cor nao \[ERRO\]  
  
\*\*Regra:\*\* A hierarquia visual de uma tela vem do \*\*tamanho, peso e contraste tipografico\*\*, nao da cor. Cor e usada para sinalizar acao (CTA), estado (sucesso/erro/aviso) e marca -- nao para "diferenciar titulos".  
  
\*\*Diagnostico atual:\*\* O painel usa cor (cinza claro vs cinza escuro) como principal mecanismo de hierarquia. Resultado: tudo parece chapado. A landing ja acerta isso -- "Pare de demitir." em 80px peso 800, "Comece a desenvolver mais." em 40px peso 700, paragrafo em 16px peso 400.  
  
\*\*Sugestao:\*\* Definir escala tipografica (Secao 2.2) com 6 niveis fixos: display, h1, h2, h3, body, caption. Toda nova tela usa apenas esses 6 niveis. Cor textual reduzida a 3 valores: primary, secondary, tertiary.  
  
\*\*Por que:\*\* Tipografia bem hierarquizada e o sinal mais barato e mais perceptivel de qualidade. Plataformas que tropecam aqui sao instantaneamente lidas como "amadoras", mesmo quando o resto e bom.  
  
\---  
  
\#\#\# DSG-003 -- Movimento confirma acao, nunca decora \[ERRO\]  
  
\*\*Regra:\*\* Toda animacao tem proposito funcional: confirmar clique, sinalizar carregamento, indicar transicao de estado, dar feedback de erro. Animacao por animacao (carrosseis automaticos, parallax decorativo gratuito, particulas flutuantes na landing) e proibida.  
  
\*\*Diagnostico atual:\*\* Painel tem zero motion. Todo hover e instantaneo (sem transition), todo click e mudo (sem ripple/scale), toda transicao de pagina e brusca. O usuario nao recebe confirmacao visual de que o sistema reagiu.  
  
\*\*Sugestao:\*\* Definir 3 duracoes (rapida 120ms / media 200ms / lenta 320ms) e 3 easings (out / in-out / spring), e aplicar em estados de hover, focus, click, abertura/fechamento de modal, transicao entre pergunta no questionario, etc. Secao 7 detalha.  
  
\*\*Por que:\*\* Movimento intencional e o que separa "produto que parece moderno" de "site que parece feito em 2014". E barato -- 5 linhas de CSS resolvem 80% dos casos -- e o impacto perceptivo e enorme.  
  
\---  
  
\#\#\# DSG-004 -- Vazio e oportunidade, nao erro \[AVISO\]  
  
\*\*Regra:\*\* Todo empty state da plataforma tem: ilustracao ou icone tematico (nao generico do Heroicons), titulo afirmativo, paragrafo explicativo curto, e CTA claro. Mensagem nunca comeca com "Nenhum" -- comeca com "Voce ainda nao", "Vamos comecar", "Bem-vindo".  
  
\*\*Diagnostico atual:\*\* Empty state do PDI: "Plano de Desenvolvimento / Complete o Mapa da Excelencia primeiro para gerar seu PDI personalizado. / \[Fazer Mapa\]". E funcional mas frio. Parece mensagem de erro de CRM.  
  
\*\*Sugestao:\*\* Reescrever cada empty state como conversa. Exemplo PDI: "Seu PDI esta esperando os dados do seu Mapa. / Quando voce terminar a avaliacao, criamos seu plano em 4 semanas com base nos gaps reais. / \[Ir para o Mapa -\]". Adicionar ilustracao tematica (ver DSG-049).  
  
\*\*Por que:\*\* Empty states sao oportunidade de criar conexao com o usuario -- ele esta exatamente no momento de duvida ("e agora?"). Empty state bom converte; empty state frio frustra.  
  
\---  
  
\#\#\# DSG-005 -- Uma cor primaria, uma cor de acento, neutros disciplinados \[ERRO\]  
  
\*\*Regra:\*\* A paleta tem \*\*uma cor primaria\*\* (laranja Taito), \*\*uma cor de acento\*\* (a definir, candidata: azul-noite ou um verde-jade), e \*\*uma escala neutra de 9-11 tons\*\* (do branco quase puro ao preto quase puro). Cores de estado (sucesso/erro/aviso/info) vem em uma versao saturada e uma sutil, totalizando 4 tons no maximo. \*\*Nada alem disso entra em uso sem aprovar token novo.\*\*  
  
\*\*Diagnostico atual:\*\* O laranja Taito aparece em CINCO contextos sem distinguir: tag PREMIUM, tag Em-breve, botao primario, link ativo na sidebar, alerta de teste em andamento. O olho nao sabe pra onde olhar.  
  
\*\*Sugestao:\*\* Reduzir uso da cor primaria a apenas dois contextos no painel -- (a) acao primaria (CTA de botao), (b) estado ativo de navegacao. Tudo mais migra para neutros disciplinados.  
  
\*\*Por que:\*\* Marca forte usa pouca cor. Linear roda em 2 cores. Stripe idem. Reducao e luxo.  
  
\---  
  
\#\#\# DSG-006 -- Modo focado existe e e protegido \[ERRO\]  
  
\*\*Regra:\*\* Telas onde o usuario faz tarefa cognitiva longa (questionario, edicao de formulario denso, leitura de relatorio extenso) entram em "modo focado" -- header, footer e sidebar de marketing/navegacao desaparecem ou se reduzem ao minimo. So o que serve a tarefa fica na tela.  
  
\*\*Diagnostico atual:\*\* O questionario tem header completo de marketing (Blog/Podcast/Videos/Cursos/Eventos/Precos) e footer completo (newsletter, LinkedIn, selos de pagamento). O usuario passa 30-45 minutos respondendo 140 perguntas com tudo isso disputando atencao.  
  
\*\*Sugestao:\*\* No questionario, header reduzido a logo Taito + indicador de progresso ("44/140 - 31%") + botao Sair/Pausar. Footer some inteiro. O card da pergunta cresce e ocupa 60% da tela. Secao 4 detalha.  
  
\*\*Por que:\*\* Tarefa cognitiva exige protecao. Cada distracao cobra atencao do usuario e deteriora a qualidade da resposta -- num teste psicometrico, deteriora ate a validade dos dados.  
  
\---  
  
\#\#\# DSG-007 -- Hierarquia comercial nao e adivinhacao \[AVISO\]  
  
\*\*Regra:\*\* Quando voce tem N opcoes para o usuario escolher (planos, niveis, pacotes), uma delas tem que ser visualmente o "RECOMENDADO" -- com fundo distinto, tag em cima, ordem privilegiada. Mostrar 4 opcoes iguais e jogar a decisao no colo do usuario; ele nao vai decidir, vai sair.  
  
\*\*Diagnostico atual:\*\* A \`/precos/\` publica acertou isso (Equipe destacada como RECOMENDADO em fundo escuro com tag laranja em cima). Mas a tela de Creditos do painel logado \*ignora\* esse mesmo padrao -- mostra os 4 planos iguais. Inconsistencia interna.  
  
\*\*Sugestao:\*\* Replicar o card RECOMENDADO da \`/precos/\` no painel de Creditos. Mesmo padrao visual. Mesmo tom de tag. Idealmente, mesmo componente reusado.  
  
\*\*Por que:\*\* Conversao em SaaS B2B depende de "anchoring" -- o cliente nao escolhe entre 4 racionalmente, ele escolhe o "indicado" como default. Sem destaque, queda de conversao na ordem de 20-40%.  
  
\---  
  
\#\#\# DSG-008 -- Numeros sao informacao emocional, trate como tal \[AVISO\]  
  
\*\*Regra:\*\* Todo numero exibido (saldo de creditos, progresso de avaliacao, estatistica de competencia, contagem de membros) e uma oportunidade de fala emocional. Numero grande, peso forte, label discreto embaixo, e -- quando faz sentido -- contagem regressiva ou subida animada.  
  
\*\*Diagnostico atual:\*\* Saldo "0 creditos" na tela de Creditos esta grande mas chapado. Sem celebracao, sem call-to-action visual. "0 / Publicados / maio/2026 / Membro desde" no perfil esta cru. "44 / 140 perguntas" no questionario esta acanhado.  
  
\*\*Sugestao:\*\* Padronizar componente "Numero" (DSG-039). Familias: numero-saldo, numero-progresso, numero-stat. Fonte tabular nums (font-variant-numeric: tabular-nums). Animar entrada (count-up de zero ate o valor) em primeira visita.  
  
\*\*Por que:\*\* Numero anemico em produto que vende credito e oportunidade perdida. Stripe trata seu numero principal como heroi visual; Linear idem com contadores.  
  
\---  
  
\#\#\# DSG-009 -- Erro e ajuda, nao acusacao \[AVISO\]  
  
\*\*Regra:\*\* Mensagens de erro do sistema falam ao usuario sobre \*\*o que aconteceu\*\* e \*\*o que ele pode fazer\*\* -- nao listam codigos, nao acusam, nao usam linguagem tecnica. "Status invalido" vira "Esse status nao e aceito agora". "Erro 422" vira "Algum campo nao foi reconhecido. Confira os destacados em vermelho".  
  
\*\*Diagnostico atual:\*\* Nao houve erro durante a auditoria -- mas o tom geral do painel ja indica como o erro vai sair (frio, sistemico). "Choose File / No file chosen" tambem nao e erro mas e exemplo de tom: cru, ingles, default do navegador.  
  
\*\*Sugestao:\*\* Inventario de cada mensagem de erro do sistema e reescrita conforme guideline da Secao 5.  
  
\*\*Por que:\*\* Erro e o momento mais sensivel da relacao usuario-produto. Tom errado afasta; tom certo cria confianca.  
  
\---  
  
\#\#\# DSG-010 -- Consistencia interna ganha de inovacao pontual \[ERRO\]  
  
\*\*Regra:\*\* Quando uma tela ja tem um padrao (botao primario laranja, tag de status verde, card com border-radius 12px), as telas seguintes seguem o mesmo padrao. Inovacao visual pontual -- "vou fazer essa tela diferente porque achei legal" -- e proibida sem aprovacao no design system.  
  
\*\*Diagnostico atual:\*\* O paradoxo do Taito -- internamente, a \`/precos/\` e o painel de Creditos vendem a mesma coisa com layouts visuais distintos. Os cards da landing tem 4 selos com fundo branco e icones; os cards do painel tem 4 quadrados sem destaque. \*\*A propria empresa nao se segue.\*\*  
  
\*\*Sugestao:\*\* Componente unico para cards de plano, reutilizado em ambos os contextos. Mesmo tipografia, mesmo destaque do RECOMENDADO, mesmo padding, mesmo radius.  
  
\*\*Por que:\*\* Marca e consistencia. Quando o usuario sai da landing e entra no painel, ele deve sentir o mesmo lugar -- nao um produto diferente.  
  
\---  
  
\#\# 2. Tokens  
  
\> Tokens sao a fonte unica da verdade do sistema visual. Cada cor,  
\> cada tamanho, cada raio, cada duracao tem um nome -- e nada que  
\> nao tenha nome entra em uso. Os tokens vivem em CSS custom  
\> properties no \`:root\` do tema-base e sao consumidos por componentes,  
\> templates e qualquer estilo do produto.  
\>  
\> O conjunto abaixo esta calibrado para a identidade ja existente da  
\> landing publica do Taito. Cada token foi extraido (ou ajustado) a  
\> partir do que ja roda em producao em maio/2026.  
  
\#\#\# DSG-011 -- Cor: primaria e variantes \[ERRO\]  
  
\*\*Regra:\*\* A cor primaria do Taito e o laranja \`\#FF6B1A\` (aproximacao -- valor exato a confirmar com extracao do CSS atual). Ela aparece em uma escala de 9 tons (50 ao 900) para uso em estados (hover, active, disabled), gradientes e fundos de baixa saturacao.  
  
\*\*Tokens:\*\*  
  
\`\`\`css  
:root {  
 /\* Cor primaria -- laranja Taito \*/  
 --color-primary-50: \#FFF4ED;  
 --color-primary-100: \#FFE4D0;  
 --color-primary-200: \#FFC79F;  
 --color-primary-300: \#FFA46C;  
 --color-primary-400: \#FF8338;  
 --color-primary-500: \#FF6B1A; /\* base \*/  
 --color-primary-600: \#E5530A;  
 --color-primary-700: \#BF400A;  
 --color-primary-800: \#8F2F0A;  
 --color-primary-900: \#5C1F08;  
  
 /\* Gradiente assinatura -- usado em palavras-chave do hero \*/  
 --gradient-primary: linear-gradient(135deg, \#FF8338 0%, \#FF6B1A 50%, \#E5530A 100%);  
}  
\`\`\`  
  
\*\*Sugestao de uso:\*\*  
  
\- \`--color-primary-500\` -- botao primario, link ativo de navegacao.  
\- \`--color-primary-100\` -- fundo de tag/badge sutil ("Em andamento", "Em breve").  
\- \`--color-primary-50\` -- fundo de alerta sutil de informacao.  
\- \`--gradient-primary\` -- palavra-chave em hero ("a desenvolver mais.") \*\*e nada mais alem disso na landing\*\*. No painel, gradiente esta proibido (DSG-014).  
  
\*\*Diagnostico atual:\*\* A landing ja usa gradiente em palavra-chave. O painel usa o \`--color-primary-500\` chapado em multiplos contextos (DSG-005). Nao ha tag/badge sutil em uso.  
  
\---  
  
\#\#\# DSG-012 -- Cor: neutros disciplinados \[ERRO\]  
  
\*\*Regra:\*\* A escala neutra tem 11 tons (0 ao 1000), cobrindo do branco puro ao preto-quase-puro. Esses 11 valores cobrem tudo que e cinza, fundo de painel, borda, sombra, texto secundario, divisor.  
  
\*\*Tokens:\*\*  
  
\`\`\`css  
:root {  
 /\* Escala neutra -- de branco a preto-quase-preto \*/  
 --color-neutral-0: \#FFFFFF;  
 --color-neutral-50: \#FAFAFA;  
 --color-neutral-100: \#F4F4F5;  
 --color-neutral-200: \#E4E4E7;  
 --color-neutral-300: \#D4D4D8;  
 --color-neutral-400: \#A1A1AA;  
 --color-neutral-500: \#71717A;  
 --color-neutral-600: \#52525B;  
 --color-neutral-700: \#3F3F46;  
 --color-neutral-800: \#27272A;  
 --color-neutral-900: \#18181B;  
 --color-neutral-1000: \#09090B;  
}  
\`\`\`  
  
\*\*Sugestao de uso:\*\*  
  
\- Fundo de painel claro: \`--color-neutral-50\`.  
\- Fundo de painel escuro (sidebar atual e hero da landing): \`--color-neutral-1000\` ou \`--color-neutral-900\`.  
\- Borda sutil de card/input: \`--color-neutral-200\`.  
\- Texto primario sobre fundo claro: \`--color-neutral-900\`.  
\- Texto secundario sobre fundo claro: \`--color-neutral-600\`.  
\- Texto terciario / placeholder: \`--color-neutral-400\`.  
  
\*\*Diagnostico atual:\*\* O painel mistura cinzas inconsistentes (provavelmente herdados de \`tailwind/preflight\` ou Bootstrap). Padronizar.  
  
\---  
  
\#\#\# DSG-013 -- Cor: estados semanticos \[ERRO\]  
  
\*\*Regra:\*\* Apenas 4 cores semanticas: sucesso (verde), erro (vermelho), aviso (amarelo-ambar), info (azul). Cada uma com 2 tons: saturada (uso em badge, icone, borda) e sutil (uso em fundo de alerta).  
  
\*\*Tokens:\*\*  
  
\`\`\`css  
:root {  
 /\* Sucesso \*/  
 --color-success-50: \#ECFDF5;  
 --color-success-500: \#10B981;  
 --color-success-700: \#047857;  
  
 /\* Erro \*/  
 --color-error-50: \#FEF2F2;  
 --color-error-500: \#EF4444;  
 --color-error-700: \#B91C1C;  
  
 /\* Aviso (cuidado: nao confundir com primary) \*/  
 --color-warning-50: \#FFFBEB;  
 --color-warning-500: \#F59E0B;  
 --color-warning-700: \#B45309;  
  
 /\* Info \*/  
 --color-info-50: \#EFF6FF;  
 --color-info-500: \#3B82F6;  
 --color-info-700: \#1D4ED8;  
}  
\`\`\`  
  
\*\*Diagnostico atual:\*\* O alerta amarelo "Teste em andamento" no Mapa esta usando o que parece ser \`bg-yellow-50\` Bootstrap-padrao com texto \`text-amber-800\` -- proximo do que o token define, mas sem refinamento. Migrar para uso explicito do token.  
  
\---  
  
\#\#\# DSG-014 -- Cor: regras de uso (proibicoes) \[ERRO\]  
  
\*\*Regra:\*\* Proibicoes explicitas para o painel logado:  
  
1\. \*\*Sem gradientes em superficies de painel.\*\* Gradientes ficam restritos ao hero da landing publica e a hero secundario de paginas de marketing. No painel, fundo e neutro chapado, com no maximo \`--color-primary-50\` em alertas sutis.  
2\. \*\*Tags e badges nao usam \`--color-primary-500\` chapado.\*\* Usam \`--color-primary-100\` como fundo + \`--color-primary-700\` como texto. Excecao: badge de "novo" / "destaque" pode usar 500, mas no maximo um por tela.  
3\. \*\*Cor de fundo de pagina nao mistura com cor de marca.\*\* Pagina inteira em laranja-claro nao existe. Pagina inteira em escuro nao existe (excecao: questionario em modo escuro como variante futura).  
4\. \*\*Cor de botao nao se misturam.\*\* Botao primario e laranja; secundario e neutro; destrutivo e vermelho. Nao existe "botao laranja-claro fantasma" -- confunde hierarquia.  
  
\*\*Diagnostico atual:\*\* Tag PREMIUM e Em-breve violam item 2. Botao "Continuar teste" do dashboard violou intencao da regra 4 (e laranja gigante, mas e o que tem -- aceitavel ate redesign).  
  
\---  
  
\#\#\# DSG-015 -- Tipografia: stack \[ERRO\]  
  
\*\*Regra:\*\* A familia tipografica do Taito e uma fonte sans-serif geometrica moderna, com pesos 400-800. \*\*Recomendacao:\*\* \`Geist Sans\` (open source, Vercel) ou \`Inter\` (open source, classica). A landing atual aparenta usar uma stack \`system-ui\` ou \`Inter\` -- a confirmar e padronizar.  
  
\*\*Tokens:\*\*  
  
\`\`\`css  
:root {  
 /\* Stack tipografica \*/  
 --font-sans: "Geist", "Inter", -apple-system, BlinkMacSystemFont,  
 "Segoe UI", Roboto, sans-serif;  
 --font-mono: "Geist Mono", "JetBrains Mono", ui-monospace,  
 "SF Mono", Menlo, monospace;  
}  
\`\`\`  
  
\*\*Sugestao:\*\* Importar Geist como variable font (1 arquivo, 8-30kb gzipped) via \`\<link rel="preload"\>\` no head. Em fallback, sistema usa Inter (provavelmente ja em cache em qualquer dispositivo).  
  
\*\*Diagnostico atual:\*\* Fonte do painel parece sistema padrao, sem cuidado. Padronizar com a landing.  
  
\---  
  
\#\#\# DSG-016 -- Tipografia: escala \[ERRO\]  
  
\*\*Regra:\*\* Escala tipografica de 8 niveis fixos. Nao se cria nivel intermediario; quando um precisar de "tamanho diferente", revisa-se a escala (proposta com justificativa, atualiza-se este documento).  
  
\*\*Tokens:\*\*  
  
\`\`\`css  
:root {  
 /\* Escala tipografica -- ratio 1.250 (major third) \*/  
 --type-display: 4.768rem; /\* 76.3px -- hero principal \*/  
 --type-h1: 3.815rem; /\* 61.0px -- titulo de pagina \*/  
 --type-h2: 3.052rem; /\* 48.8px -- titulo de secao \*/  
 --type-h3: 2.441rem; /\* 39.1px -- titulo de subsecao \*/  
 --type-h4: 1.953rem; /\* 31.3px -- titulo de card destaque \*/  
 --type-h5: 1.563rem; /\* 25.0px -- titulo de card \*/  
 --type-body: 1rem; /\* 16.0px -- paragrafo padrao \*/  
 --type-caption: 0.8rem; /\* 12.8px -- legendas, tags, microcopy \*/  
  
 /\* Pesos \*/  
 --weight-regular: 400;  
 --weight-medium: 500;  
 --weight-semibold: 600;  
 --weight-bold: 700;  
 --weight-black: 800;  
  
 /\* Line heights \*/  
 --leading-tight: 1.1; /\* display, h1 \*/  
 --leading-snug: 1.25; /\* h2, h3 \*/  
 --leading-normal: 1.5; /\* body \*/  
 --leading-relaxed: 1.7; /\* paragrafos longos \*/  
  
 /\* Letter-spacing \*/  
 --tracking-tight: -0.02em; /\* display, h1 \*/  
 --tracking-normal: 0; /\* body \*/  
 --tracking-wide: 0.05em; /\* uppercase labels, tags \*/  
}  
\`\`\`  
  
\*\*Diagnostico atual:\*\* Painel usa multiplos tamanhos sem padrao claro -- 14px, 16px, 18px, 24px aparecem misturados. Padronizar.  
  
\---  
  
\#\#\# DSG-017 -- Tipografia: regras de uso \[AVISO\]  
  
\*\*Regra:\*\* Cada nivel da escala tem uso especifico:  
  
| Nivel | Uso | Peso default | Cor default |  
|-------|-----|--------------|-------------|  
| display | Hero principal de landing | 800 | neutral-1000 (claro) ou neutral-0 (escuro) |  
| h1 | Titulo de pagina (uma vez por tela) | 700 | neutral-900 |  
| h2 | Titulo de secao | 700 | neutral-900 |  
| h3 | Titulo de subsecao | 600 | neutral-900 |  
| h4 | Titulo de card destaque, KPI | 600 | neutral-900 |  
| h5 | Titulo de card padrao | 600 | neutral-900 |  
| body | Paragrafos, formularios | 400 | neutral-700 |  
| caption | Legendas, helper text, tags | 500 | neutral-500 |  
  
\*\*Regras correlatas:\*\*  
  
\- Apenas \*\*1 elemento h1 por tela\*\* (acessibilidade + SEO).  
\- Title-case so em titulos de produto. Sentence-case em titulos de funcionalidade. Uppercase com tracking-wide so em micro-labels (ex.: "BASE CIENTIFICA" da landing).  
\- Textos descritivos em \`--color-neutral-700\`. Helper text e em \`--color-neutral-500\`.  
  
\---  
  
\#\#\# DSG-018 -- Espaco: grid \[ERRO\]  
  
\*\*Regra:\*\* Grid de espaco em multiplos de 4px. Escala de 12 valores (0 a 96px). Nao existe \`padding: 13px\` ou \`margin: 22px\` -- tudo cabe na escala.  
  
\*\*Tokens:\*\*  
  
\`\`\`css  
:root {  
 --space-0: 0;  
 --space-1: 0.25rem; /\* 4px \*/  
 --space-2: 0.5rem; /\* 8px \*/  
 --space-3: 0.75rem; /\* 12px \*/  
 --space-4: 1rem; /\* 16px \*/  
 --space-5: 1.5rem; /\* 24px \*/  
 --space-6: 2rem; /\* 32px \*/  
 --space-7: 3rem; /\* 48px \*/  
 --space-8: 4rem; /\* 64px \*/  
 --space-9: 6rem; /\* 96px \*/  
 --space-10: 8rem; /\* 128px \*/  
 --space-11: 12rem; /\* 192px \*/  
}  
\`\`\`  
  
\*\*Regras de uso:\*\*  
  
\- Padding interno de card padrao: \`--space-5\` (24px) ou \`--space-6\` (32px).  
\- Espaco vertical entre secoes da landing: \`--space-9\` (96px) a \`--space-10\` (128px).  
\- Espaco vertical entre secoes do painel: \`--space-7\` (48px) a \`--space-8\` (64px) -- painel e mais denso por natureza.  
\- Espaco entre campos de formulario: \`--space-4\` (16px) vertical, \`--space-5\` (24px) horizontal.  
\- Espaco entre items de lista: \`--space-2\` (8px) a \`--space-3\` (12px).  
  
\*\*Diagnostico atual:\*\* Painel mistura paddings 8px / 12px / 16px / 24px sem padrao claro. Padronizar.  
  
\---  
  
\#\#\# DSG-019 -- Raio (border-radius) \[ERRO\]  
  
\*\*Regra:\*\* Raio de borda em 4 valores fixos. Nao existe raio intermediario.  
  
\*\*Tokens:\*\*  
  
\`\`\`css  
:root {  
 --radius-sm: 4px; /\* tags, badges, chips pequenos \*/  
 --radius-md: 8px; /\* botoes, inputs, alerts \*/  
 --radius-lg: 12px; /\* cards, modals \*/  
 --radius-xl: 24px; /\* containers grandes, cards de hero \*/  
 --radius-full: 9999px; /\* pills, avatares circulares \*/  
}  
\`\`\`  
  
\*\*Regras de uso:\*\*  
  
\- Botao primario/secundario: \`--radius-md\` (8px).  
\- Input de formulario: \`--radius-md\` (8px).  
\- Card padrao: \`--radius-lg\` (12px).  
\- Card de plano (Inicial/Equipe/Empresa/Enterprise): \`--radius-lg\` (12px).  
\- Pill de tag (PREMIUM, Em breve, RECOMENDADO): \`--radius-full\` ou \`--radius-sm\` -- escolher um e seguir. Recomendacao: \`--radius-sm\` para tags inline (segue Stripe/Linear), \`--radius-full\` para tags de status standalone.  
\- Avatar do perfil: \`--radius-full\`.  
  
\*\*Diagnostico atual:\*\* Painel usa 4-6px na maioria dos lugares (Bootstrap default). Subir para 8-12px da modernidade imediata.  
  
\---  
  
\#\#\# DSG-020 -- Sombra (elevation) \[AVISO\]  
  
\*\*Regra:\*\* Sistema de sombra de 5 niveis (0 a 4), correspondendo a elevacao perceptual. Sombra usada com parcimonia -- so em superficies que precisam "flutuar" visualmente.  
  
\*\*Tokens:\*\*  
  
\`\`\`css  
:root {  
 --shadow-0: none;  
  
 /\* Nivel 1 -- card base, levemente elevado \*/  
 --shadow-1:  
 0 1px 2px 0 rgba(9, 9, 11, 0.05),  
 0 1px 3px 0 rgba(9, 9, 11, 0.04);  
  
 /\* Nivel 2 -- card destacado, dropdown \*/  
 --shadow-2:  
 0 4px 6px -1px rgba(9, 9, 11, 0.07),  
 0 2px 4px -2px rgba(9, 9, 11, 0.05);  
  
 /\* Nivel 3 -- modal, popover \*/  
 --shadow-3:  
 0 10px 15px -3px rgba(9, 9, 11, 0.1),  
 0 4px 6px -4px rgba(9, 9, 11, 0.07);  
  
 /\* Nivel 4 -- modal critico, drawer \*/  
 --shadow-4:  
 0 20px 25px -5px rgba(9, 9, 11, 0.12),  
 0 8px 10px -6px rgba(9, 9, 11, 0.08);  
  
 /\* Sombra interna (para inputs com foco, cards encaixados) \*/  
 --shadow-inset: inset 0 2px 4px 0 rgba(9, 9, 11, 0.05);  
  
 /\* Sombra de foco (anel) \*/  
 --shadow-focus: 0 0 0 3px rgba(255, 107, 26, 0.3); /\* primary-500 30% \*/  
}  
\`\`\`  
  
\*\*Regras de uso:\*\*  
  
\- Card de listagem: \`--shadow-1\`.  
\- Card de KPI (saldo, progresso): \`--shadow-2\`.  
\- Card RECOMENDADO de plano: \`--shadow-3\`.  
\- Modal: \`--shadow-4\`.  
\- Botao em estado focus: \`--shadow-focus\`.  
\- \*\*Botao em estado hover NAO ganha sombra\*\* -- ganha mudanca de tom de fundo (ver Secao 3).  
  
\*\*Diagnostico atual:\*\* Painel praticamente nao tem sombra. Cards sao planos como folhas em mesa. Adicionar elevacao sutil sobe percepcao de qualidade imediatamente.  
  
\---  
  
\#\#\# DSG-021 -- Movimento: durations e easings \[ERRO\]  
  
\*\*Regra:\*\* Apenas 3 duracoes e 3 easings nomeados. Combinacao gera 9 padroes reusaveis.  
  
\*\*Tokens:\*\*  
  
\`\`\`css  
:root {  
 /\* Duracoes \*/  
 --duration-fast: 120ms; /\* hover, focus, click feedback \*/  
 --duration-medium: 200ms; /\* abertura/fechamento de menu, tab \*/  
 --duration-slow: 320ms; /\* abertura de modal, transicao de pagina \*/  
  
 /\* Easings \*/  
 --ease-out: cubic-bezier(0.16, 1, 0.3, 1); /\* padrao para entrada \*/  
 --ease-in-out: cubic-bezier(0.45, 0, 0.55, 1); /\* padrao para movimento bidirecional \*/  
 --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1); /\* spring suave para feedback \*/  
  
 /\* Combos prontos \*/  
 --transition-fast: var(--duration-fast) var(--ease-out);  
 --transition-medium: var(--duration-medium) var(--ease-in-out);  
 --transition-slow: var(--duration-slow) var(--ease-out);  
}  
\`\`\`  
  
\*\*Regras de uso:\*\*  
  
\- \`transition: background-color var(--transition-fast)\` em botoes, links.  
\- \`transition: transform var(--duration-medium) var(--ease-spring)\` em click feedback.  
\- \`transition: opacity var(--transition-slow)\` em fade de modal.  
\- Em transicoes de pagina (questionario pergunta-a-pergunta): fade-out 120ms + fade-in 200ms com slide-y de 8px.  
  
\*\*Diagnostico atual:\*\* Painel nao tem transition em lugar nenhum. Adicionar essas variaveis e usa-las em hover/focus de tudo: o salto perceptivo e gigante e o custo e tres linhas de CSS por componente.  
  
\---  
  
\#\#\# DSG-022 -- Container e breakpoints \[AVISO\]  
  
\*\*Regra:\*\* Largura maxima de container e breakpoints fixos.  
  
\*\*Tokens:\*\*  
  
\`\`\`css  
:root {  
 --container-sm: 640px;  
 --container-md: 768px;  
 --container-lg: 1024px;  
 --container-xl: 1280px; /\* container padrao do painel e da landing \*/  
 --container-2xl: 1536px; /\* hero de landing \*/  
  
 /\* Breakpoints (mobile-first) \*/  
 --bp-sm: 640px;  
 --bp-md: 768px;  
 --bp-lg: 1024px;  
 --bp-xl: 1280px;  
}  
\`\`\`  
  
\*\*Regras de uso:\*\*  
  
\- Container padrao do painel logado: \`max-width: var(--container-xl); margin: 0 auto; padding: 0 var(--space-5);\`.  
\- Container de questionario em modo focado: \`max-width: var(--container-md);\` (mais estreito por design).  
\- Container de hero da landing: \`max-width: var(--container-2xl);\` (largo, com padding generoso).  
  
\---  
  
\#\# 3. Componentes minimos  
  
\> O Taito nao precisa de 700 componentes (Preline) nem de 200 (Material).  
\> Precisa de \~25 componentes bem feitos. Esta secao define cada um, com  
\> estados, variantes e regra de uso. Conforme novas necessidades  
\> surgirem, novos componentes entram aqui com ID \`DSG-XXX\`.  
  
\#\#\# DSG-023 -- Botao: variantes e estados \[ERRO\]  
  
\*\*Regra:\*\* Tres variantes de botao -- primario, secundario, fantasma. Uma variante adicional destrutivo. Cada um em 4 estados: default, hover, focus, disabled.  
  
\*\*Especificacao:\*\*  
  
| Variante | Background default | Texto | Background hover | Uso |  
|----------|--------------------|----|--------------------|-----|  
| Primario | \`--color-primary-500\` | \`--color-neutral-0\` | \`--color-primary-600\` | CTA principal da tela. Maximo 1 por contexto. |  
| Secundario | \`--color-neutral-0\` | \`--color-neutral-900\` | \`--color-neutral-100\` | Acao secundaria. Borda 1px \`--color-neutral-200\`. |  
| Fantasma | transparent | \`--color-neutral-700\` | \`--color-neutral-100\` | Acao terciaria, links de menu. Sem borda. |  
| Destrutivo | \`--color-error-500\` | \`--color-neutral-0\` | \`--color-error-700\` | Acoes irreversiveis (excluir, cancelar conta). |  
  
\*\*Regras correlatas:\*\*  
  
\- Padding: \`var(--space-3) var(--space-5)\` (12px 24px) padrao. Tamanhos pequenos: \`var(--space-2) var(--space-4)\`.  
\- Border-radius: \`var(--radius-md)\` (8px).  
\- Tipografia: \`--type-body\` (16px), peso 600.  
\- Estado focus: anel \`var(--shadow-focus)\`.  
\- Estado disabled: opacity 0.5, cursor not-allowed.  
\- Transition: \`background-color var(--transition-fast)\`.  
\- Botao com icone: gap de \`var(--space-2)\` entre icone e texto.  
  
\*\*Exemplo de implementacao:\*\*  
  
\`\`\`css  
.btn {  
 display: inline-flex;  
 align-items: center;  
 gap: var(--space-2);  
 padding: var(--space-3) var(--space-5);  
 font: var(--weight-semibold) var(--type-body)/1 var(--font-sans);  
 border-radius: var(--radius-md);  
 border: 1px solid transparent;  
 cursor: pointer;  
 transition: background-color var(--transition-fast),  
 transform var(--duration-fast) var(--ease-spring);  
}  
  
.btn:focus-visible {  
 outline: none;  
 box-shadow: var(--shadow-focus);  
}  
  
.btn:active {  
 transform: scale(0.98);  
}  
  
.btn--primary {  
 background: var(--color-primary-500);  
 color: var(--color-neutral-0);  
}  
  
.btn--primary:hover {  
 background: var(--color-primary-600);  
}  
  
.btn--secondary {  
 background: var(--color-neutral-0);  
 color: var(--color-neutral-900);  
 border-color: var(--color-neutral-200);  
}  
  
.btn--secondary:hover {  
 background: var(--color-neutral-100);  
}  
  
.btn--ghost {  
 background: transparent;  
 color: var(--color-neutral-700);  
}  
  
.btn--ghost:hover {  
 background: var(--color-neutral-100);  
}  
  
.btn--destructive {  
 background: var(--color-error-500);  
 color: var(--color-neutral-0);  
}  
  
.btn--destructive:hover {  
 background: var(--color-error-700);  
}  
  
.btn\[disabled\] {  
 opacity: 0.5;  
 cursor: not-allowed;  
 pointer-events: none;  
}  
\`\`\`  
  
\*\*Diagnostico atual:\*\*  
  
\- O botao "Continuar teste" do dashboard e laranja chapado primario, OK -- mas ocupa quase toda a largura do card (estranho).  
\- "Continuar -" do alerta amarelo de Mapa: laranja primario, OK.  
\- "Salvar perfil / Salvar visibilidade / Desativar perfil publico": laranja / outline / outline-vermelho. \*\*OK no proposito, falta padronizacao\*\* -- o "Desativar perfil publico" parece um destrutivo mas com aspecto visual de fantasma. Migrar para variante destrutivo da especificacao acima.  
\- "Choose File" do input file: e o navegador, nao do sistema -- precisa ser substituido (ver DSG-027).  
\- "Alterar senha": fantasma -- OK.  
\- "Vincular / Desvincular" das contas: misturado -- padronizar.  
  
\---  
  
\#\#\# DSG-024 -- Botao: icone-only e tamanhos \[AVISO\]  
  
\*\*Regra:\*\* Botao de icone (sem texto) tem dimensoes quadradas (32x32, 40x40, 48x48 conforme tamanho), aria-label obrigatorio, e tooltip ao hover apos 500ms.  
  
\*\*Especificacao:\*\*  
  
\`\`\`css  
.btn--icon-sm { width: 32px; height: 32px; padding: 0; }  
.btn--icon-md { width: 40px; height: 40px; padding: 0; }  
.btn--icon-lg { width: 48px; height: 48px; padding: 0; }  
\`\`\`  
  
\*\*Diagnostico atual:\*\* Nao ha botoes icone-only relevantes na auditoria.  
  
\---  
  
\#\#\# DSG-025 -- Input de texto e textarea \[ERRO\]  
  
\*\*Regra:\*\* Input padrao com label flutuante OU label fixo acima. Estados: default, focus, error, disabled. Nunca placeholder como label.  
  
\*\*Especificacao default (label fixo acima):\*\*  
  
\`\`\`css  
.field {  
 display: flex;  
 flex-direction: column;  
 gap: var(--space-2);  
}  
  
.field\_\_label {  
 font-size: var(--type-caption);  
 font-weight: var(--weight-medium);  
 color: var(--color-neutral-700);  
 letter-spacing: var(--tracking-wide);  
}  
  
.field\_\_input {  
 padding: var(--space-3) var(--space-4);  
 font: var(--weight-regular) var(--type-body) var(--font-sans);  
 border: 1px solid var(--color-neutral-200);  
 border-radius: var(--radius-md);  
 background: var(--color-neutral-0);  
 color: var(--color-neutral-900);  
 transition: border-color var(--transition-fast),  
 box-shadow var(--transition-fast);  
}  
  
.field\_\_input::placeholder {  
 color: var(--color-neutral-400);  
}  
  
.field\_\_input:focus {  
 outline: none;  
 border-color: var(--color-primary-500);  
 box-shadow: var(--shadow-focus);  
}  
  
.field\_\_input\[aria-invalid="true"\] {  
 border-color: var(--color-error-500);  
}  
  
.field\_\_input\[aria-invalid="true"\]:focus {  
 box-shadow: 0 0 0 3px rgba(239, 68, 68, 0.3);  
}  
  
.field\_\_helper {  
 font-size: var(--type-caption);  
 color: var(--color-neutral-500);  
}  
  
.field\_\_helper--error {  
 color: var(--color-error-700);  
}  
\`\`\`  
  
\*\*Regras correlatas:\*\*  
  
\- Label sempre acima, peso 500, cor neutral-700.  
\- Helper text abaixo, peso 400, cor neutral-500. Vira \`--color-error-700\` quando o input esta em erro.  
\- Placeholder em \`--color-neutral-400\`, \*\*nunca substitui o label\*\*.  
\- Estado de erro: borda vermelha + helper em vermelho. Helper NAO some quando o usuario comeca a digitar -- so some quando o erro e corrigido.  
  
\*\*Diagnostico atual:\*\*  
  
\- Inputs do perfil tem label acima, OK no padrao.  
\- Bordas estao mais grossas/visiveis que o ideal (parece \`1.5px solid \#e5e7eb\`).  
\- Border-radius parece 4-6px -- subir para 8px (nosso \`--radius-md\`).  
\- Sem estado focus visivel -- adicionar anel \`--shadow-focus\`.  
  
\---  
  
\#\#\# DSG-026 -- Select \[AVISO\]  
  
\*\*Regra:\*\* Select customizado, nao o \`\<select\>\` nativo. Razao: \`\<select\>\` nativo nao herda cores/borda/raio do design system de forma confiavel cross-browser, e nao permite estilizar a lista aberta.  
  
\*\*Sugestao de implementacao:\*\* componente \`\<details\>\` + \`\<summary\>\` + lista, ou biblioteca minima como Choices.js (3kb gzipped) ou Combobox da Web Awesome.  
  
\*\*Diagnostico atual:\*\* Nao ha select complexo na auditoria. Quando tiver, nao usar nativo cru.  
  
\---  
  
\#\#\# DSG-027 -- Input file \[ERRO\]  
  
\*\*Regra:\*\* O \`\<input type="file"\>\` nativo do navegador e proibido como elemento visivel. Substituicao mandatoria por componente customizado: botao + label + (apos selecao) preview do arquivo + botao de remover.  
  
\*\*Especificacao:\*\*  
  
\`\`\`html  
\<div class="file-upload"\>  
 \<label class="file-upload\_\_trigger" for="avatar-input"\>  
 \<svg class="file-upload\_\_icon"\>...\</svg\>  
 \<span class="file-upload\_\_text"\>Carregar foto\</span\>  
 \<span class="file-upload\_\_hint"\>PNG ou JPG, ate 2MB\</span\>  
 \</label\>  
 \<input  
 id="avatar-input"  
 type="file"  
 accept="image/png,image/jpeg"  
 class="file-upload\_\_input"  
 \>  
\</div\>  
\`\`\`  
  
\`\`\`css  
.file-upload\_\_input {  
 position: absolute;  
 width: 1px;  
 height: 1px;  
 opacity: 0;  
 pointer-events: none; /\* ou usar position:absolute fora da viewport \*/  
}  
  
.file-upload\_\_trigger {  
 display: flex;  
 flex-direction: column;  
 align-items: center;  
 justify-content: center;  
 gap: var(--space-2);  
 padding: var(--space-7);  
 border: 2px dashed var(--color-neutral-300);  
 border-radius: var(--radius-lg);  
 background: var(--color-neutral-50);  
 cursor: pointer;  
 transition: border-color var(--transition-fast),  
 background-color var(--transition-fast);  
}  
  
.file-upload\_\_trigger:hover,  
.file-upload:focus-within .file-upload\_\_trigger {  
 border-color: var(--color-primary-500);  
 background: var(--color-primary-50);  
}  
  
.file-upload\_\_icon {  
 width: 32px;  
 height: 32px;  
 color: var(--color-neutral-500);  
}  
  
.file-upload\_\_text {  
 font-weight: var(--weight-medium);  
 color: var(--color-neutral-900);  
}  
  
.file-upload\_\_hint {  
 font-size: var(--type-caption);  
 color: var(--color-neutral-500);  
}  
\`\`\`  
  
\*\*Regras correlatas:\*\*  
  
\- Apos selecao, o trigger vira card com nome do arquivo, tamanho, miniatura (se imagem), e botao "Remover".  
\- Drag & drop e suportado: \`.file-upload\_\_trigger\` aceita drop zone com feedback visual ao dragover.  
\- Validacao de tamanho/tipo no frontend antes de enviar -- erro inline em vez de erro do servidor.  
  
\*\*Diagnostico atual:\*\* Pagina de perfil tem \`\<input type="file"\>\` cru exibindo "Choose File / No file chosen". Sintoma ERRO de "ninguem polir". Substituir.  
  
\---  
  
\#\#\# DSG-028 -- Checkbox e radio \[AVISO\]  
  
\*\*Regra:\*\* Checkbox e radio customizados (escondendo o nativo, exibindo elemento estilizavel). Tamanho minimo 20x20. Hit area aumentada para 32x32 (touch-friendly).  
  
\*\*Especificacao basica:\*\*  
  
\`\`\`css  
.checkbox,  
.radio {  
 position: relative;  
 display: inline-flex;  
 align-items: center;  
 gap: var(--space-3);  
 cursor: pointer;  
 padding: var(--space-2) 0; /\* hit area \*/  
}  
  
.checkbox\_\_input,  
.radio\_\_input {  
 position: absolute;  
 opacity: 0;  
 pointer-events: none;  
}  
  
.checkbox\_\_indicator,  
.radio\_\_indicator {  
 width: 20px;  
 height: 20px;  
 border: 2px solid var(--color-neutral-300);  
 background: var(--color-neutral-0);  
 transition: border-color var(--transition-fast),  
 background-color var(--transition-fast);  
}  
  
.checkbox\_\_indicator { border-radius: var(--radius-sm); }  
.radio\_\_indicator { border-radius: var(--radius-full); }  
  
.checkbox\_\_input:checked + .checkbox\_\_indicator {  
 background: var(--color-primary-500);  
 border-color: var(--color-primary-500);  
 /\* Tick via background-image (svg inline) ou pseudo-elemento \*/  
}  
  
.checkbox\_\_input:focus-visible + .checkbox\_\_indicator {  
 box-shadow: var(--shadow-focus);  
}  
\`\`\`  
  
\*\*Diagnostico atual:\*\*  
  
\- Checkboxes laranja na pagina de perfil ("Bio / Cargo / Empresa / ...") parecem estar usando o nativo do navegador estilizado com \`accent-color: orange\`. Aceitavel como solucao temporaria, mas migrar para customizado para consistencia cross-browser e estado focus padronizado.  
\- Radio buttons no questionario sao circulos vazios brancos com borda neutra, sem estado checked observado durante a auditoria. Padronizar com a especificacao acima -- e adicionar microinteracao de "preencher" o circulo ao clicar.  
  
\---  
  
\#\#\# DSG-029 -- Toggle / switch \[AVISO\]  
  
\*\*Regra:\*\* Para acoes booleanas que tem efeito imediato (sem necessidade de "Salvar"), usar toggle. Para acoes que ficam pendentes ate "Salvar", usar checkbox.  
  
\*\*Especificacao:\*\*  
  
Toggle de 44px (largura) x 24px (altura), com bola de 20px que desliza. Cores: off neutral-300, on primary-500.  
  
\*\*Diagnostico atual:\*\* Nao ha toggle visivel na auditoria.  
  
\---  
  
\#\#\# DSG-030 -- Card \[ERRO\]  
  
\*\*Regra:\*\* Card e o componente mais reutilizado. Define-se variantes: padrao, destacado (RECOMENDADO), KPI (saldo, contador), feature (com icone+titulo+descricao), interactivo (clicavel).  
  
\*\*Especificacao base:\*\*  
  
\`\`\`css  
.card {  
 background: var(--color-neutral-0);  
 border: 1px solid var(--color-neutral-200);  
 border-radius: var(--radius-lg);  
 padding: var(--space-5);  
 transition: border-color var(--transition-fast),  
 box-shadow var(--transition-fast),  
 transform var(--duration-medium) var(--ease-out);  
}  
  
.card--shadow {  
 box-shadow: var(--shadow-1);  
 border: none;  
}  
  
.card--interactive {  
 cursor: pointer;  
}  
  
.card--interactive:hover {  
 border-color: var(--color-neutral-300);  
 box-shadow: var(--shadow-2);  
 transform: translateY(-2px);  
}  
  
.card--featured {  
 background: var(--color-neutral-1000);  
 color: var(--color-neutral-0);  
 border: none;  
 position: relative;  
}  
  
.card--featured::before {  
 /\* Tag RECOMENDADO acima do card \*/  
 content: attr(data-tag);  
 position: absolute;  
 top: -12px;  
 left: 50%;  
 transform: translateX(-50%);  
 padding: var(--space-1) var(--space-3);  
 background: var(--color-primary-500);  
 color: var(--color-neutral-0);  
 font-size: var(--type-caption);  
 font-weight: var(--weight-semibold);  
 letter-spacing: var(--tracking-wide);  
 text-transform: uppercase;  
 border-radius: var(--radius-sm);  
}  
\`\`\`  
  
\*\*Diagnostico atual:\*\*  
  
\- Cards do \`/painel/?pagina=inicio\`: estaticos, sem hover, todos iguais. Aplicar \`card--interactive\` e diferenciar visualmente o que esta ativo (Mapa) vs o que esta em-breve (PDI/Feedback).  
\- Cards de plano da \`/painel/?pagina=creditos\`: 4 quadrados sem destaque. Aplicar \`card--featured\` no plano recomendado (ver DSG-007 e DSG-046).  
\- Cards da landing \`/precos/\`: ja seguem o padrao. Validar se podem ser literalmente o mesmo componente reusado no painel.  
  
\---  
  
\#\#\# DSG-031 -- Tag / badge \[ERRO\]  
  
\*\*Regra:\*\* Tag e elemento pequeno que carrega informacao de status, categoria ou destaque. Tres variantes: padrao, sutil (subtle), forte (solid).  
  
\*\*Especificacao:\*\*  
  
\`\`\`css  
.tag {  
 display: inline-flex;  
 align-items: center;  
 gap: var(--space-1);  
 padding: var(--space-1) var(--space-2);  
 font-size: var(--type-caption);  
 font-weight: var(--weight-medium);  
 letter-spacing: var(--tracking-wide);  
 text-transform: uppercase;  
 border-radius: var(--radius-sm);  
 white-space: nowrap;  
}  
  
/\* Variante sutil -- 95% dos usos \*/  
.tag--subtle-primary { background: var(--color-primary-100); color: var(--color-primary-700); }  
.tag--subtle-success { background: var(--color-success-50); color: var(--color-success-700); }  
.tag--subtle-warning { background: var(--color-warning-50); color: var(--color-warning-700); }  
.tag--subtle-error { background: var(--color-error-50); color: var(--color-error-700); }  
.tag--subtle-neutral { background: var(--color-neutral-100); color: var(--color-neutral-700); }  
  
/\* Variante forte -- usar com parcimonia \*/  
.tag--solid-primary { background: var(--color-primary-500); color: var(--color-neutral-0); }  
\`\`\`  
  
\*\*Regras correlatas:\*\*  
  
\- Tag sutil e o default. Tag forte so para destaque maximo (ex.: RECOMENDADO acima do card, NOVO em feature recem-lancada).  
\- Texto sempre uppercase, letter-spacing wide. Excecao: tags muito longas (\>20 chars) podem ser sentence-case.  
\- Largura intrinseca pelo conteudo. Sem largura fixa.  
  
\*\*Diagnostico atual:\*\*  
  
\- Tag PREMIUM ao lado do logo -- atualmente solid laranja chapado, \*\*provavel violacao de DSG-014\*\*. Migrar para \`tag--subtle-primary\` ou repensar como elemento de status mais sutil (ex.: estrela laranja + tooltip "Plano Premium").  
\- Tag "Em breve" no item Feedback -- atualmente solid. Migrar para \`tag--subtle-neutral\` com texto "Em breve" -- e considerar incluir mes ("Junho 2026").  
\- Tag "Em andamento" no historico de Mapa -- atualmente solid amarelo. Migrar para \`tag--subtle-warning\`.  
  
\---  
  
\#\#\# DSG-032 -- Toast (notificacao temporaria) \[AVISO\]  
  
\*\*Regra:\*\* Toast e mensagem temporaria de feedback (sucesso, erro, info). Aparece no topo-direito (desktop) ou topo-centro (mobile). Duracao: 4s para info/sucesso, 7s para erro, indefinido para erros criticos (com botao Fechar).  
  
\*\*Especificacao:\*\*  
  
\- Largura: 320-400px.  
\- Padding: \`var(--space-4) var(--space-5)\`.  
\- Border-radius: \`var(--radius-md)\`.  
\- Sombra: \`var(--shadow-3)\`.  
\- Entrada: slide-in da direita + fade-in, 320ms ease-out.  
\- Saida: fade-out + slide-out, 200ms ease-in.  
\- Estrutura: icone (sucesso=check, erro=x, info=i, aviso=\!) + titulo + descricao opcional + botao close.  
\- \*\*Empilhamento:\*\* maximo 3 toasts simultaneos. 4o substitui o 1o.  
  
\*\*Diagnostico atual:\*\* Nao houve toast disparado durante a auditoria. Quando houver, padronizar.  
  
\---  
  
\#\#\# DSG-033 -- Alerta inline \[ERRO\]  
  
\*\*Regra:\*\* Alerta inline e mensagem permanente dentro do fluxo (nao temporaria). Usado para "Voce tem teste em andamento", "Sua sessao expira em 5 minutos", "Esse recurso esta em beta".  
  
\*\*Especificacao:\*\*  
  
\`\`\`css  
.alert {  
 display: flex;  
 gap: var(--space-3);  
 padding: var(--space-4) var(--space-5);  
 border-radius: var(--radius-md);  
 border-left: 4px solid;  
}  
  
.alert--info { background: var(--color-info-50); border-color: var(--color-info-500); }  
.alert--success { background: var(--color-success-50); border-color: var(--color-success-500); }  
.alert--warning { background: var(--color-warning-50); border-color: var(--color-warning-500); }  
.alert--error { background: var(--color-error-50); border-color: var(--color-error-500); }  
  
.alert\_\_icon { color: currentColor; flex-shrink: 0; }  
.alert\_\_title { font-weight: var(--weight-semibold); margin-bottom: var(--space-1); }  
.alert\_\_description { color: var(--color-neutral-700); }  
.alert\_\_action { margin-left: auto; }  
\`\`\`  
  
\*\*Diagnostico atual:\*\*  
  
\- Alerta "Teste em andamento" no Mapa: amarelo Bootstrap padrao, sem icone, sem peso na tipografia. Migrar para \`alert--warning\` da especificacao com icone de relogio + botao Continuar como acao principal a direita.  
  
\---  
  
\#\#\# DSG-034 -- Modal e drawer \[AVISO\]  
  
\*\*Regra:\*\* Modal sobrepoe a tela com backdrop semi-transparente (rgba(9,9,11,0.5) + backdrop-blur 4px). Drawer desliza de uma das laterais, prendendo no topo do viewport.  
  
\*\*Regras de uso:\*\*  
  
\- Modal: confirmacao destrutiva, formulario rapido (criar item), preview de conteudo.  
\- Drawer: navegacao secundaria em mobile, painel de detalhes lateral em desktop, formulario longo.  
\- Sempre fechavel por: ESC, click no backdrop (com confirmacao se houver dados nao salvos), botao Fechar (X) no canto.  
\- Foco preso dentro do modal/drawer enquanto aberto (focus trap).  
\- Restaura foco no elemento que abriu ao fechar.  
  
\*\*Diagnostico atual:\*\* Nao ha modal/drawer visivel na auditoria. Quando houver, padronizar.  
  
\---  
  
\#\#\# DSG-035 -- Skeleton (placeholder de carregamento) \[ERRO\]  
  
\*\*Regra:\*\* Em vez de spinner ou tela em branco, todo carregamento de conteudo de mais de 300ms exibe skeleton: blocos cinza-claro com animacao shimmer suave que representam a forma final do conteudo.  
  
\*\*Especificacao:\*\*  
  
\`\`\`css  
.skeleton {  
 display: block;  
 background: linear-gradient(  
 90deg,  
 var(--color-neutral-100) 0%,  
 var(--color-neutral-200) 50%,  
 var(--color-neutral-100) 100%  
 );  
 background-size: 200% 100%;  
 animation: skeleton-shimmer 1.5s ease-in-out infinite;  
 border-radius: var(--radius-md);  
}  
  
@keyframes skeleton-shimmer {  
 0% { background-position: 200% 0; }  
 100% { background-position: -200% 0; }  
}  
  
/\* Variantes por forma \*/  
.skeleton--text { height: 1em; }  
.skeleton--title { height: 1.5em; width: 60%; }  
.skeleton--avatar { width: 48px; height: 48px; border-radius: var(--radius-full); }  
.skeleton--card { height: 160px; }  
\`\`\`  
  
\*\*Regras correlatas:\*\*  
  
\- Skeleton tem o mesmo layout do conteudo final (mesmo numero de linhas, mesma altura de card).  
\- Skeleton \*\*nao\*\* anima por mais de 5s -- apos 5s, troca para erro de timeout com botao "Tentar novamente".  
\- Em transicoes de pagina dentro do painel (SPA-like), skeleton aparece durante navegacao.  
  
\*\*Diagnostico atual:\*\* Painel parece nao ter skeleton -- usa carregamento full-page do PHP. Adoptar skeleton em listagens, dashboard e perfil para sensacao de instantaneidade.  
  
\---  
  
\#\#\# DSG-036 -- Empty state \[ERRO\]  
  
\*\*Regra:\*\* Empty state tem 4 elementos obrigatorios:  
  
1\. \*\*Ilustracao ou icone tematico\*\* -- nao generico do Heroicons. Pode ser SVG custom, ilustracao em estilo proprio, ou icone Lucide com tratamento de cor.  
2\. \*\*Titulo afirmativo\*\* -- "Voce ainda nao", "Vamos comecar", "Bem-vindo a sua trilha". Nunca "Nenhum" / "0 itens" / "Lista vazia".  
3\. \*\*Paragrafo curto\*\* explicando o que vai aparecer la quando houver dado.  
4\. \*\*CTA claro\*\* -- botao primario para a acao mais provavel.  
  
\*\*Especificacao:\*\*  
  
\`\`\`css  
.empty-state {  
 display: flex;  
 flex-direction: column;  
 align-items: center;  
 text-align: center;  
 padding: var(--space-9) var(--space-5);  
 max-width: 480px;  
 margin: 0 auto;  
}  
  
.empty-state\_\_illustration {  
 width: 96px;  
 height: 96px;  
 color: var(--color-neutral-400);  
 margin-bottom: var(--space-5);  
}  
  
.empty-state\_\_title {  
 font-size: var(--type-h4);  
 font-weight: var(--weight-semibold);  
 color: var(--color-neutral-900);  
 margin-bottom: var(--space-2);  
}  
  
.empty-state\_\_description {  
 color: var(--color-neutral-600);  
 line-height: var(--leading-relaxed);  
 margin-bottom: var(--space-5);  
}  
\`\`\`  
  
\*\*Diagnostico atual:\*\*  
  
\- Empty state do PDI: "Plano de Desenvolvimento / Complete o Mapa da Excelencia primeiro para gerar seu PDI personalizado. / \[Fazer Mapa\]". Esta perto do padrao -- titulo OK, descricao OK, CTA OK -- mas o icone e generico (clipboard-check do Lucide), tom da descricao e frio. Reescrever conforme DSG-049 e Secao 5.  
  
\---  
  
\#\#\# DSG-037 -- Sidebar de navegacao \[AVISO\]  
  
\*\*Regra:\*\* Sidebar do painel logado segue padrao consistente: largura fixa 240px, fundo escuro \`--color-neutral-1000\`, agrupamentos com label uppercase em peso 500, items em peso 500 com icone a esquerda. Item ativo tem fundo \`--color-primary-500\` 15% + texto \`--color-primary-500\`.  
  
\*\*Especificacao:\*\*  
  
\`\`\`css  
.sidebar {  
 width: 240px;  
 background: var(--color-neutral-1000);  
 color: var(--color-neutral-300);  
 padding: var(--space-5) var(--space-3);  
}  
  
.sidebar\_\_group-label {  
 font-size: var(--type-caption);  
 font-weight: var(--weight-medium);  
 letter-spacing: var(--tracking-wide);  
 text-transform: uppercase;  
 color: var(--color-neutral-500);  
 padding: var(--space-3) var(--space-3);  
}  
  
.sidebar\_\_item {  
 display: flex;  
 align-items: center;  
 gap: var(--space-3);  
 padding: var(--space-3) var(--space-3);  
 font-weight: var(--weight-medium);  
 color: var(--color-neutral-300);  
 border-radius: var(--radius-md);  
 transition: background-color var(--transition-fast),  
 color var(--transition-fast);  
}  
  
.sidebar\_\_item:hover {  
 background: var(--color-neutral-800);  
 color: var(--color-neutral-100);  
}  
  
.sidebar\_\_item--active {  
 background: rgba(255, 107, 26, 0.1);  
 color: var(--color-primary-400);  
}  
  
.sidebar\_\_item--disabled {  
 opacity: 0.5;  
 cursor: not-allowed;  
}  
\`\`\`  
  
\*\*Diagnostico atual:\*\*  
  
\- Sidebar atual ja segue boa parte desse padrao -- escuro, com agrupamentos (PRINCIPAL / MAPA DA EXCELENCIA / AVALIACOES / DESENVOLVIMENTO / COMPRAS / MINHA CONTA).   
\- Item ativo "Inicio" tem destaque sutil mas pouco visivel -- aumentar contraste com \`rgba(255, 107, 26, 0.15)\` e cor de texto \`--color-primary-400\`.  
\- Item "Feedback (Em breve)" tem opacity reduzida -- OK, mas a tag "Em breve" deve ser componente Tag (DSG-031) com estilo subtle, nao laranja chapado.  
\- Icones parecem do Lucide ou Heroicons monoline -- adequado, mas considerar customizar 2-3 icones-chave (Mapa, Brio, Avaliacao) para personalidade.  
  
\---  
  
\#\#\# DSG-038 -- Header de painel \[AVISO\]  
  
\*\*Regra:\*\* Header do painel logado e fino (altura 56-64px), tem o titulo da pagina a esquerda, e elementos de contexto (saldo de creditos, notificacoes, perfil) a direita. Background neutral-0 com border-bottom sutil.  
  
\*\*Especificacao:\*\*  
  
\`\`\`css  
.header {  
 display: flex;  
 align-items: center;  
 justify-content: space-between;  
 height: 64px;  
 padding: 0 var(--space-5);  
 background: var(--color-neutral-0);  
 border-bottom: 1px solid var(--color-neutral-200);  
}  
  
.header\_\_title {  
 font-size: var(--type-body);  
 font-weight: var(--weight-semibold);  
 color: var(--color-neutral-900);  
}  
  
.header\_\_actions {  
 display: flex;  
 align-items: center;  
 gap: var(--space-3);  
}  
\`\`\`  
  
\*\*Diagnostico atual:\*\*  
  
\- Header atual exibe "Meu Perfil / Inicio / Fazer Mapa / etc." a esquerda e "Jocsa Naves" a direita. Faltam: badge de saldo de creditos clicavel, notificacoes, dropdown de perfil. Adicionar.  
\- Titulo da pagina poderia ser um pouco maior (h5 em vez de body) e ter peso 700 para criar hierarquia clara.  
  
\---  
  
\#\#\# DSG-039 -- Componente Numero (KPI/saldo/progresso) \[ERRO\]  
  
\*\*Regra:\*\* Numeros com peso emocional (saldo, progresso, contadores de pessoas, score) tem componente proprio com hierarquia visual maxima.  
  
\*\*Especificacao:\*\*  
  
\`\`\`css  
.kpi {  
 display: flex;  
 flex-direction: column;  
 gap: var(--space-2);  
}  
  
.kpi\_\_value {  
 font-size: var(--type-display); /\* 76px no maior \*/  
 font-weight: var(--weight-bold);  
 font-variant-numeric: tabular-nums;  
 line-height: 1;  
 color: var(--color-neutral-900);  
 letter-spacing: var(--tracking-tight);  
}  
  
.kpi\_\_label {  
 font-size: var(--type-caption);  
 font-weight: var(--weight-medium);  
 letter-spacing: var(--tracking-wide);  
 text-transform: uppercase;  
 color: var(--color-neutral-500);  
}  
  
.kpi\_\_delta {  
 display: inline-flex;  
 align-items: center;  
 gap: var(--space-1);  
 font-size: var(--type-caption);  
 font-weight: var(--weight-semibold);  
 color: var(--color-success-700);  
}  
  
.kpi\_\_delta--down { color: var(--color-error-700); }  
  
/\* Tamanhos \*/  
.kpi--xl .kpi\_\_value { font-size: var(--type-display); } /\* hero saldo \*/  
.kpi--lg .kpi\_\_value { font-size: var(--type-h1); }  
.kpi--md .kpi\_\_value { font-size: var(--type-h2); }  
\`\`\`  
  
\*\*Animacao de count-up (entrada):\*\*  
  
\`\`\`javascript  
function animateNumber(el, from, to, duration = 800) {  
 const start = performance.now();  
 function step(now) {  
 const t = Math.min(1, (now - start) / duration);  
 const eased = 1 - Math.pow(1 - t, 3); // ease-out cubic  
 el.textContent = Math.round(from + (to - from) \* eased);  
 if (t \< 1) requestAnimationFrame(step);  
 }  
 requestAnimationFrame(step);  
}  
\`\`\`  
  
\*\*Diagnostico atual:\*\*  
  
\- Saldo "0 creditos" na tela de Creditos: existe mas e chapado. Adotar \`kpi--xl\` com animacao count-up de 0 a valor real ao carregar a pagina.  
\- "0 / Publicados / maio/2026 / Membro desde" no perfil: numero pequeno, hierarquia confusa. Reformular como dois \`kpi--md\` lado a lado.  
\- "44 / 140 perguntas / 31%" no questionario: tipograficamente acanhado. Adotar \`kpi--lg\` para o "44" e "31%", com label "perguntas respondidas".  
\- Stats da landing (14 / 320+ / 90 / 3): ja seguem o padrao -- formalizar como mesmo componente.  
  
\---  
  
\#\#\# DSG-040 -- Indicador de progresso (barra) \[ERRO\]  
  
\*\*Regra:\*\* Barra de progresso tem altura 4-8px (4 sutil, 8 destacada), background \`--color-neutral-200\`, fill \`--color-primary-500\`. Animacao de fill suave (transition width 320ms ease-out).  
  
\*\*Especificacao:\*\*  
  
\`\`\`css  
.progress {  
 position: relative;  
 height: 8px;  
 background: var(--color-neutral-200);  
 border-radius: var(--radius-full);  
 overflow: hidden;  
}  
  
.progress\_\_fill {  
 height: 100%;  
 background: var(--color-primary-500);  
 border-radius: inherit;  
 transition: width var(--transition-slow);  
}  
  
/\* Variante com gradiente para hero/destaque \*/  
.progress--featured .progress\_\_fill {  
 background: var(--gradient-primary);  
}  
  
/\* Variante minima (linha 2px) para topo de pagina \*/  
.progress--top {  
 position: fixed;  
 top: 0;  
 left: 0;  
 right: 0;  
 height: 2px;  
 z-index: 100;  
}  
\`\`\`  
  
\*\*Diagnostico atual:\*\*  
  
\- Barra de progresso do questionario (44/140) e laranja chapada, sem refinamento. Migrar para componente padrao + considerar variante featured com gradiente.  
\- Adicionar animacao quando o usuario avanca uma pergunta -- a barra "ganha" visualmente o pedaco novo.  
  
\---  
  
\#\# 4. Padroes de tela  
  
\> Cada tipo de tela tem padroes proprios -- layout, elementos, comportamentos. Esta secao define o esqueleto de cada tipo, herdando os componentes da Secao 3.  
  
\#\#\# DSG-041 -- Hero de landing \[AVISO\]  
  
\*\*Regra:\*\* Hero da landing tem fundo escuro (\`--color-neutral-1000\`), padrao decorativo de pixels no canto superior-direito (ja existe no Taito), titulo display com peso 800, subtitulo com palavra-chave em gradiente, paragrafo de 1-3 linhas, dois CTAs (primario + secundario), padding vertical generoso (\>= 96px).  
  
\*\*Especificacao:\*\*  
  
\`\`\`html  
\<section class="hero"\>  
 \<div class="hero\_\_pattern" aria-hidden="true"\>\</div\>  
 \<div class="hero\_\_container"\>  
 \<h1 class="hero\_\_title"\>Pare de demitir.\</h1\>  
 \<h2 class="hero\_\_subtitle"\>  
 Comece \<span class="hero\_\_highlight"\>a desenvolver mais.\</span\>  
 \</h2\>  
 \<p class="hero\_\_description"\>  
 A unica plataforma brasileira que entrega diagnostico cientifico,  
 plano de acao personalizado e prova de evolucao dos seus  
 colaboradores em 90 dias.  
 \</p\>  
 \<div class="hero\_\_actions"\>  
 \<a class="btn btn--primary" href="/cadastro"\>Comecar gratis\</a\>  
 \<a class="btn btn--secondary" href="/como-funciona"\>Como funciona\</a\>  
 \</div\>  
 \</div\>  
\</section\>  
\`\`\`  
  
\`\`\`css  
.hero {  
 position: relative;  
 background: var(--color-neutral-1000);  
 color: var(--color-neutral-0);  
 padding: var(--space-10) 0;  
 overflow: hidden;  
}  
  
.hero\_\_pattern {  
 position: absolute;  
 top: 0; right: 0;  
 width: 320px;  
 height: 320px;  
 background-image: /\* grid de pixels SVG \*/;  
 opacity: 0.4;  
}  
  
.hero\_\_title {  
 font-size: var(--type-display);  
 font-weight: var(--weight-black);  
 letter-spacing: var(--tracking-tight);  
 line-height: var(--leading-tight);  
}  
  
.hero\_\_subtitle {  
 font-size: var(--type-h2);  
 font-weight: var(--weight-bold);  
 margin-top: var(--space-4);  
}  
  
.hero\_\_highlight {  
 background: var(--gradient-primary);  
 -webkit-background-clip: text;  
 background-clip: text;  
 color: transparent;  
}  
  
.hero\_\_description {  
 font-size: var(--type-body);  
 color: var(--color-neutral-400);  
 max-width: 540px;  
 margin-top: var(--space-5);  
 line-height: var(--leading-relaxed);  
}  
  
.hero\_\_actions {  
 display: flex;  
 gap: var(--space-4);  
 margin-top: var(--space-6);  
}  
  
/\* Variante adaptada para painel (sem fundo escuro) \*/  
.hero--app {  
 background: var(--color-neutral-50);  
 color: var(--color-neutral-900);  
 padding: var(--space-7) 0;  
}  
\`\`\`  
  
\*\*Diagnostico atual:\*\* Hero da landing ja segue boa parte desse padrao. Padronizar e replicar para hero secundario de paginas internas (sem fundo escuro).  
  
\---  
  
\#\#\# DSG-042 -- Stats em linha \[AVISO\]  
  
\*\*Regra:\*\* Numeros-chave em linha horizontal, sem cards individuais. Numero grande no topo (h1 ou h2), label discreto embaixo. Separador vertical sutil entre items.  
  
\*\*Especificacao:\*\*  
  
\`\`\`css  
.stats {  
 display: grid;  
 grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));  
 gap: var(--space-6);  
 padding: var(--space-7) var(--space-5);  
 border-top: 1px solid var(--color-neutral-200);  
 border-bottom: 1px solid var(--color-neutral-200);  
}  
  
.stats\_\_item {  
 display: flex;  
 flex-direction: column;  
 align-items: center;  
 text-align: center;  
}  
  
.stats\_\_value {  
 font-size: var(--type-h2);  
 font-weight: var(--weight-bold);  
 color: var(--color-neutral-900);  
 font-variant-numeric: tabular-nums;  
}  
  
.stats\_\_label {  
 font-size: var(--type-caption);  
 color: var(--color-neutral-500);  
 margin-top: var(--space-2);  
}  
\`\`\`  
  
\*\*Diagnostico atual:\*\* Stats da landing (14 / 320+ / 90 / 3) ja seguem o padrao. Replicar no painel para "Voce ja respondeu / Voce ja completou / Brios ganhos" etc.  
  
\---  
  
\#\#\# DSG-043 -- Secao de feature (3-4 cards) \[AVISO\]  
  
\*\*Regra:\*\* Secao com 3-4 cards de feature segue padrao: titulo da secao centralizado, eyebrow uppercase em laranja, paragrafo de 1-2 linhas, grid de 3-4 cards iguais com icone+titulo+descricao.  
  
\*\*Especificacao:\*\* ja exemplificada na landing (Ciencia / Ciclo / Cultura). Padronizar como componente reusavel para outras secoes.  
  
\*\*Diagnostico atual:\*\* Existe na landing. Adotar mesmo componente em paginas internas (Como funciona, Para quem, etc.).  
  
\---  
  
\#\#\# DSG-044 -- Lista numerada (grid de competencias) \[AVISO\]  
  
\*\*Regra:\*\* Listas hierarquicas (competencias, etapas, niveis) usam grid de cards com numero grande em laranja no topo do card, titulo embaixo, opcionalmente descricao.  
  
\*\*Especificacao:\*\* ja exemplificada na landing (grid de 14 competencias 01-14). Padronizar.  
  
\*\*Diagnostico atual:\*\* Existe na landing. Replicar em painel onde houver listagem hierarquica (ex.: niveis de proficiencia, etapas do PDI, fases do ciclo).  
  
\---  
  
\#\#\# DSG-045 -- Tabela \[AVISO\]  
  
\*\*Regra:\*\* Tabela do Taito nao usa zebra-stripe (alternancia de fundo de linhas). Em vez disso: row hover sutil, divisor horizontal entre linhas, header com peso semibold em cor neutral-700.  
  
\*\*Especificacao:\*\*  
  
\`\`\`css  
.table {  
 width: 100%;  
 border-collapse: collapse;  
}  
  
.table th {  
 text-align: left;  
 font-size: var(--type-caption);  
 font-weight: var(--weight-semibold);  
 text-transform: uppercase;  
 letter-spacing: var(--tracking-wide);  
 color: var(--color-neutral-700);  
 padding: var(--space-3) var(--space-4);  
 border-bottom: 1px solid var(--color-neutral-200);  
}  
  
.table td {  
 padding: var(--space-4);  
 border-bottom: 1px solid var(--color-neutral-100);  
 color: var(--color-neutral-900);  
}  
  
.table tbody tr:hover td {  
 background: var(--color-neutral-50);  
}  
  
.table tbody tr:last-child td {  
 border-bottom: none;  
}  
\`\`\`  
  
\*\*Regras correlatas:\*\*  
  
\- Sem zebra-stripe (e fora de moda e dificulta leitura).  
\- Sticky header em tabelas com \>10 linhas.  
\- Pagination obrigatoria em tabelas com \>50 linhas.  
  
\*\*Diagnostico atual:\*\* Historico do Mapa exibe linhas em formato simples ("Mapa \#3 / Em andamento / Continuar"). Padronizar como tabela ou como lista de cards conforme densidade.  
  
\---  
  
\#\#\# DSG-046 -- Tela de planos / pricing \[ERRO\]  
  
\*\*Regra:\*\* Tela de planos sempre tem destaque do RECOMENDADO. Padrao: 4 cards lado-a-lado em desktop, stack em mobile. Card RECOMENDADO tem fundo escuro (\`--color-neutral-1000\`), tag "RECOMENDADO" em laranja acima do card, mesmas dimensoes que os outros mas com elevacao maior.  
  
\*\*Estrutura por card:\*\*  
  
1\. Nome do plano (h5).  
2\. Faixa de uso (caption -- "1-10 creditos", "11-50 creditos", etc.).  
3\. Preco grande em ($/credito).  
4\. Linha de unidade (\`/credito\`).  
5\. Linha de desconto (verde).  
6\. Divisor horizontal.  
7\. Calculos derivados ("Ciclo completo (3 cred.) / R$X por pessoa", "Equipe de 10 pessoas / R$Y").  
8\. Lista de inclusoes (icone + texto, 3-5 items).  
9\. CTA primario.  
  
\*\*Diagnostico atual:\*\*  
  
\- \`/precos/\` tela publica: ja segue esse padrao. Excelente. \*\*Modelo a replicar\*\*.  
\- \`/painel/?pagina=creditos\` tela logada: NAO segue. Mostra 4 cards iguais sem destaque, sem calculo derivado por pessoa, sem ciclo. Ironicamente, e onde a compra acontece. Refazer espelhando exatamente a tela publica, com adicao do contexto de saldo atual e botao "Comprar X creditos".  
  
\---  
  
\#\#\# DSG-047 -- Tela de questionario (modo focado) \[ERRO\]  
  
\*\*Regra:\*\* Tela de questionario entra em modo focado obrigatorio:  
  
1\. Header reduzido a logo + indicador de progresso + botao Sair/Pausar (so).  
2\. Footer \*\*inexistente\*\*.  
3\. Sidebar \*\*inexistente\*\*.  
4\. Card central com pergunta ocupa 60-70% da viewport horizontal e tem padding generoso.  
5\. Indicador de progresso fixo no topo (linha 2-4px com fill animado).  
6\. Indicador de competencia em curso ("Voce esta em: Comunicacao") acima da pergunta -- contexto critico.  
7\. Numero da pergunta + total ("44 de 140") em peso forte, color tertiary, acima da pergunta.  
8\. Pergunta em h3 ou h4 com max-width controlada (60ch para legibilidade).  
9\. Opcoes de resposta em radio customizado (DSG-028) com labels descritivos, 100% de largura do card, hover sutil.  
10\. Botao "Proxima -" abaixo, alinhado a direita.  
11\. Cooldown de 3s vira progresso visual: o botao tem barra interna que se enche (200% no contraste) -- visualmente reforca "espera, ja vou estar pronto".  
12\. Atalho Tab + Enter para navegacao por teclado: cada opcao recebe foco; Enter seleciona; Tab vai para "Proxima".  
13\. Persistencia: cada resposta salva instantaneamente (sem botao Salvar). "Salvo automaticamente" como caption sutil no rodape do card.  
14\. Pause: botao "Pausar e sair" no header. Sai com toast "Sua resposta esta salva. Continue depois."  
  
\*\*Diagnostico atual:\*\*  
  
\- Header completo de marketing aparece. ERRO ABSOLUTO.  
\- Footer completo aparece. ERRO ABSOLUTO.  
\- Sidebar nao aparece (correto).  
\- Card pequeno demais. Sem indicacao de competencia em curso. Numero da pergunta acanhado.  
\- Cooldown "Aguarde 3s..." em texto plano. Sem barra de progresso visual.  
\- Sem persistencia visual ("Salvo").  
  
Esta e a tela de maior ROI de mudanca em todo o produto. Refatorar primeiro.  
  
\---  
  
\#\#\# DSG-048 -- Tela de perfil \[AVISO\]  
  
\*\*Regra:\*\* Tela de perfil tem cabecalho com avatar grande, nome, plano, e estatisticas (publicados, membro desde, ultimo acesso). Formularios em colunas duas-em-duas em desktop. Cada secao (Informacoes pessoais / profissionais / Redes sociais / Seguranca) e um card.  
  
\*\*Diagnostico atual:\*\*  
  
\- Cabecalho atual tem foto pequena, nome em h1, e-mail, tag "Membro Premium", e numeros "0 / maio/2026" no canto. Aceitavel mas:  
 - Avatar deve ser maior (96-120px) com botao de hover "Trocar foto".  
 - Plano "Membro Premium" deve ser tag (DSG-031) sutil.  
 - Numeros devem ser KPI (DSG-039) maiores.  
 - Adicionar barra de "Completude do perfil" como progresso.  
\- Formulario: input file substituido por componente (DSG-027), bordas e radius padronizados, foco visivel.  
\- Botoes "Salvar perfil / Salvar visibilidade / Desativar perfil publico": padronizar (DSG-023). "Desativar" e destrutivo.  
  
\---  
  
\#\#\# DSG-049 -- Tela de empty state pleno \[ERRO\]  
  
\*\*Regra:\*\* Telas com nada a mostrar (PDI sem mapa feito, Catalogo vazio, Pedidos vazio) entram em empty state pleno (DSG-036) -- ocupam toda a area de conteudo e tem CTA bem destacado.  
  
\*\*Diagnostico atual:\*\*  
  
\- PDI vazio: presente, OK no esqueleto. Reescrever copy (Secao 5).  
\- Catalogo, Pedidos, Resultados, Historico: redirecionam para Inicio quando vazios. \*\*Errado.\*\* Devem mostrar empty state proprio com explicacao do que sera mostrado quando houver dado, e CTA para a acao mais provavel.  
  
\---  
  
\#\#\# DSG-050 -- Tela de inicio (dashboard) \[ERRO\]  
  
\*\*Regra:\*\* Dashboard do painel logado tem 4 elementos:  
  
1\. Saudacao personalizada com hora do dia ("Bom dia, Jocsa") -- topo, h2.  
2\. Status atual (1 card destacado): "Voce tem 1 mapa em andamento. Continuar?" com CTA. Ou "Voce nao tem mapa ativo. Comecar agora?".  
3\. Grade de modulos (Mapa / PDI / Feedback) com estado: ativo (verde sutil + borda), em andamento (laranja sutil), em breve (cinza). Cards interativos (DSG-030).  
4\. Stats pessoais: Brios ganhos, competencias atingidas, dias na plataforma, proxima reavaliacao.  
  
\*\*Diagnostico atual:\*\*  
  
\- Saudacao: existe ("Ola, Jocsa") mas e h2 generico.  
\- Status: existe parcialmente (card "Mapa da Excelencia / Teste em andamento / Continuar teste") mas o botao ocupa quase a largura inteira do card -- esquisito. E o Plano Premium aparece como caption no topo -- enterrado.  
\- Grade: existe (3 cards Mapa / PDI / Feedback) mas dois estao em "Em breve". Quando ha 1 ativo e 2 desativados, isso e empty state mascarado -- repensar.  
\- Stats: nao existem. Adicionar 3-4 stats relevantes no topo direito ou abaixo do hero.  
  
\---  
  
\#\#\# DSG-051 -- Footer da landing \[AVISO\]  
  
\*\*Regra:\*\* Footer e denso, organizado em 4-5 colunas (Produto / Competencias / Recursos / Empresa), com newsletter inline, selos de confianca em linha (AES-256, Base FEM, LGPD, NR-1, API REST), sociais e copyright.  
  
\*\*Diagnostico atual:\*\* Footer da landing ja segue boa parte desse padrao. Padronizar tipografia (h6 nas colunas, peso 600, letter-spacing wide, color neutral-900).  
  
\---  
  
\#\#\# DSG-052 -- Footer do painel \[AVISO\]  
  
\*\*Regra:\*\* Footer do painel logado e minimo: copyright + link para suporte + versao. Linha unica, padding pequeno.  
  
\*\*Especificacao:\*\*  
  
\`\`\`html  
\<footer class="app-footer"\>  
 \<p\>© 2026 Taito - BGR Software House\</p\>  
 \<a href="/suporte"\>Suporte\</a\>  
 \<span class="text-tertiary"\>v1.4.2\</span\>  
\</footer\>  
\`\`\`  
  
\*\*Diagnostico atual:\*\* Footer do painel atual exibe so "© 2026 Taito - BGR Software House". OK. Adicionar link de suporte e versao.  
  
\---  
  
\#\# 5. Microcopy e voz da marca  
  
\> O Taito tem voz definida na marca: "Pare de demitir. Comece a  
\> desenvolver mais." -- direta, urgente, brasileira, sem afetacao.  
\> Esta secao traduz isso para microcopy do sistema.  
  
\#\#\# DSG-053 -- Tom de voz \[ERRO\]  
  
\*\*Regra:\*\* Tom da voz Taito tem 4 marcas:  
  
1\. \*\*Direto.\*\* Frase curta. Verbo no inicio. Imperativo amigavel.  
2\. \*\*Brasileiro.\*\* Sem anglicismo desnecessario ("dashboard" vira "painel", "feedback" continua porque ja entrou no portugues, mas "onboarding" vira "primeiros passos").  
3\. \*\*Confiante sem arrogancia.\*\* "A unica plataforma" e correto se for verdade. "A melhor plataforma" e arrogante. Confidencia se sustenta em fato, nao em adjetivo.  
4\. \*\*Calorosa nas margens.\*\* Saudacao, empty state e mensagem de erro tem espaco para humanidade. Nao virar formal demais.  
  
\*\*Exemplos:\*\*  
  
\- "Bem-vindo ao Taito" (frio) -\> "Bom te ver de novo, Jocsa" (calor)  
\- "Erro: campo obrigatorio" (frio) -\> "Esse campo e obrigatorio" (direto e humano)  
\- "Sua avaliacao foi salva com sucesso" (formal) -\> "Salvo." (direto, ou "Pronto, suas respostas estao seguras." se tiver espaco)  
\- "Lista vazia. Nenhum item encontrado." (cru) -\> "Voce ainda nao comecou um plano. Bora?" (caloroso)  
  
\*\*Diagnostico atual:\*\*  
  
\- "Choose File / No file chosen" -- ingles default do navegador. Substituir.  
\- "Em breve" -- aceitavel mas cru. Considerar "Estamos terminando" ou "Junho 2026" quando data conhecida.  
\- "Mapa \#3 / Em andamento" -- frio. Substituir por "Mapa de maio/2026 - 31% concluido".  
\- "Plano Premium - acesso completo" -- aceitavel, levemente burocratico.  
\- "Voce comecou uma avaliacao e ainda nao terminou." (alerta amarelo) -- bom\! Direto e claro.  
\- "Complete o Mapa da Excelencia primeiro para gerar seu PDI personalizado." -- aceitavel, mas frio. Reescrever.  
  
\---  
  
\#\#\# DSG-054 -- Padroes de mensagens do sistema \[ERRO\]  
  
\*\*Regra:\*\* Tipos de mensagem do sistema seguem template fixo:  
  
| Tipo | Estrutura | Exemplo |  
|------|-----------|---------|  
| Sucesso | Verbo no participio + ponto | "Salvo." / "Plano atualizado." |  
| Erro de validacao | "Esse \[campo\] \[problema\]" | "Esse e-mail nao parece valido." |  
| Erro de sistema | "Algo deu errado. \[Acao sugerida\]" | "Algo deu errado. Tenta de novo em alguns segundos." |  
| Confirmacao destrutiva | "Tem certeza que \[acao\]? \[Consequencia\]" | "Tem certeza que quer cancelar a avaliacao? Voce vai perder o progresso." |  
| Confirmacao positiva | "Pronto. \[Confirmacao do estado novo\]" | "Pronto. Seu PDI foi gerado." |  
  
\*\*Diagnostico atual:\*\* Auditoria nao disparou erros do sistema, mas tom geral indica que ha trabalho de revisao para fazer.  
  
\---  
  
\#\#\# DSG-055 -- Microcopy de botao \[AVISO\]  
  
\*\*Regra:\*\* Texto de botao e verbo de acao + objeto, no imperativo. Maximo 3 palavras. Sem "Clique aqui", "Botao", "Submit".  
  
\*\*Exemplos:\*\*  
  
\- "Submit" -\> "Salvar" / "Continuar" / "Enviar"  
\- "Click here to learn more" -\> "Saiba mais" / "Como funciona"  
\- "Cancel" -\> "Cancelar"  
\- "Delete account" -\> "Excluir conta"  
  
\*\*Diagnostico atual:\*\*  
  
\- "Comecar gratis" / "Como funciona" no hero da landing: PERFEITO.  
\- "Continuar teste" no dashboard: OK.  
\- "Salvar perfil" / "Salvar visibilidade": OK.  
\- "Desativar perfil publico": OK mas considerar "Tornar perfil privado" (afirma o resultado em vez do verbo destrutivo).  
\- "Choose File": ingles do navegador -- substituir.  
\- "Vincular" / "Desvincular": OK no proposito mas considerar "Conectar" / "Desconectar" para sons mais humanos.  
  
\---  
  
\#\#\# DSG-056 -- Empty state copy \[AVISO\]  
  
\*\*Regra:\*\* Empty state segue formula: "Voce ainda nao \[acao\]. \[Beneficio de fazer\]. \[CTA\]."  
  
\*\*Exemplos:\*\*  
  
\- "Nenhum item" -\> "Voce ainda nao comecou um plano. O Taito monta seu PDI em 4 semanas a partir do seu Mapa. \[Fazer Mapa\]"  
\- "Lista vazia" -\> "Voce ainda nao tem pedidos. Quando comprar creditos, o historico aparece aqui."  
\- "0 items" -\> "Voce ainda nao publicou nada. Compartilhe seu primeiro insight e ajude outros profissionais."  
  
\*\*Diagnostico atual:\*\*  
  
\- PDI vazio: "Plano de Desenvolvimento / Complete o Mapa da Excelencia primeiro para gerar seu PDI personalizado." -\> Refazer como "Seu PDI esta esperando seu Mapa. Termina a avaliacao e a gente cria seu plano de 4 semanas com base nos seus gaps reais."  
  
\---  
  
\#\#\# DSG-057 -- Copy de carregamento e espera \[AVISO\]  
  
\*\*Regra:\*\* Carregamentos longos tem mensagem que indica o que esta acontecendo, nao apenas "Carregando...". Para esperas curtas (skeleton), nenhum texto. Para esperas medias (\>2s), mensagem informativa. Para esperas longas (\>10s), passo a passo.  
  
\*\*Exemplos:\*\*  
  
\- 0-300ms: nada (renderizacao instantanea aparente).  
\- 300ms-2s: skeleton sem texto.  
\- 2-10s: spinner + "Carregando seu Mapa...".  
\- 10s+: progresso explicito + "Calculando 14 competencias... 320 comportamentos... Quase la.".  
  
\*\*Diagnostico atual:\*\* "Aguarde 3s..." no questionario e cru. Refazer com countdown visual (DSG-040) sem texto, ou texto "Liberando proxima pergunta...".  
  
\---  
  
\#\#\# DSG-058 -- Copy de notificacao e e-mail \[AVISO\]  
  
\*\*Regra:\*\* Notificacao de sistema (toast, push, e-mail transacional) tem subject/titulo de no maximo 5 palavras + corpo de 1-2 frases.  
  
\*\*Exemplos:\*\*  
  
\- Subject: "Seu Mapa esta pronto" -\> Body: "Voce levou 38 minutos. Os resultados ja estao no seu painel. \[Ver agora\]"  
\- Subject: "Voce parou no meio" -\> Body: "Sua avaliacao esta salva. Quando voltar, comeca da pergunta 44. \[Continuar\]"  
  
\---  
  
\#\# 6. Acessibilidade  
  
\> Acessibilidade nao e checkbox -- e principio. Toda regra deste documento tem versao acessivel embutida. Esta secao consolida as regras transversais.  
  
\#\#\# DSG-059 -- Contraste minimo \[ERRO\]  
  
\*\*Regra:\*\* Todo texto sobre fundo respeita WCAG AA: contraste minimo 4.5:1 para texto normal (\< 18.66px ou \< 14px bold), 3:1 para texto grande (\>= 18.66px ou \>= 14px bold).  
  
\*\*Verificacao:\*\* ferramentas como Axe, WAVE, Stark plugin do Figma. Em CSS, evitar \`color: gray\` -- usar tokens (Secao 2).  
  
\*\*Diagnostico atual:\*\*  
  
\- Texto neutral-500 sobre neutral-50 esta no limite -- verificar caso a caso.  
\- Tag "Em breve" laranja-claro sobre neutral-1000 (sidebar) -- contraste OK mas verificar.  
\- "Aguarde 3s..." em cinza-claro -- provavel violacao. Aumentar contraste.  
  
\---  
  
\#\#\# DSG-060 -- Foco visivel \[ERRO\]  
  
\*\*Regra:\*\* Todo elemento focavel (botao, link, input, custom controls) tem foco visivel quando navegado por teclado. Anel de foco usa \`--shadow-focus\` ou outline equivalente. \*\*Nunca remover outline sem substituir.\*\*  
  
\*\*Especificacao:\*\* ja embutida em Secao 3. Cuidado com \`outline: 0\` global.  
  
\*\*Diagnostico atual:\*\* Nao verificavel via screenshot. Auditar com Tab walk completo em PR de implementacao.  
  
\---  
  
\#\#\# DSG-061 -- Hierarquia semantica \[ERRO\]  
  
\*\*Regra:\*\* Marcacao HTML segue hierarquia semantica: 1 \`\<h1\>\` por pagina, secoes com \`\<section\>\` + heading, navegacao em \`\<nav\>\`, conteudo principal em \`\<main\>\`. Sem usar \`\<div\>\` para o que tem semantica nativa.  
  
\*\*Diagnostico atual:\*\* A confirmar via inspecao do markup do tema-base.  
  
\---  
  
\#\#\# DSG-062 -- Touch targets \[AVISO\]  
  
\*\*Regra:\*\* Elementos clicaveis tem area minima de 44x44px (Apple HIG / WCAG 2.5.5). Em desktop, tamanhos podem ser menores se a hit area total (incluindo padding) atingir 32x32 ou superior.  
  
\*\*Diagnostico atual:\*\* Sidebar items parecem OK. Botoes pequenos no questionario podem estar abaixo -- verificar.  
  
\---  
  
\#\#\# DSG-063 -- Aria e labels \[ERRO\]  
  
\*\*Regra:\*\* Todo input tem label associado (\`\<label for="x"\>\` ou \`aria-labelledby\`). Todo botao com so icone tem \`aria-label\`. Toda acao critica tem \`aria-describedby\` apontando para descricao adicional.  
  
\---  
  
\#\#\# DSG-064 -- Reduce motion \[AVISO\]  
  
\*\*Regra:\*\* Respeitar \`prefers-reduced-motion: reduce\` -- desabilitar animacoes nao-essenciais.  
  
\`\`\`css  
@media (prefers-reduced-motion: reduce) {  
 \*,  
 \*::before,  
 \*::after {  
 animation-duration: 0.01ms \!important;  
 animation-iteration-count: 1 \!important;  
 transition-duration: 0.01ms \!important;  
 scroll-behavior: auto \!important;  
 }  
}  
\`\`\`  
  
\---  
  
\#\# 7. Movimento e microinteracoes  
  
\> Movimento e onde o "WOW" mora -- e e barato.  
  
\#\#\# DSG-065 -- Hover em superficies clicaveis \[ERRO\]  
  
\*\*Regra:\*\* Todo elemento clicavel responde ao hover com transition de 120ms. Mudancas tipicas: tom de fundo (lighter ou darker), borda, sombra, leve translate vertical (-2px). Combinar 1-2 propriedades, nao todas.  
  
\*\*Diagnostico atual:\*\* Painel sem hover. Adicionar.  
  
\---  
  
\#\#\# DSG-066 -- Click feedback (active state) \[ERRO\]  
  
\*\*Regra:\*\* Click em botao gera feedback imediato: scale(0.98) por 120ms ou darken do background. Reforca "o sistema reconheceu meu clique".  
  
\`\`\`css  
.btn:active {  
 transform: scale(0.98);  
}  
\`\`\`  
  
\---  
  
\#\#\# DSG-067 -- Transicao entre paginas / estados \[AVISO\]  
  
\*\*Regra:\*\* Transicao entre estados ou paginas no questionario, no painel, ou em modais usa fade + slide-y de 8px. 200ms ease-out.  
  
\---  
  
\#\#\# DSG-068 -- Microinteracao em selecao \[AVISO\]  
  
\*\*Regra:\*\* Selecao de radio / checkbox / tab anima:  
\- Radio: circulo interno cresce de 0 a 100% com spring (cubic-bezier(0.34, 1.56, 0.64, 1)) em 200ms.  
\- Checkbox: tick desenha (stroke-dashoffset) em 200ms ease-out.  
\- Tab: indicador desliza para nova posicao em 320ms ease-in-out.  
  
\---  
  
\#\# 8. Implementacao tecnica  
  
\#\#\# DSG-069 -- Tokens em CSS custom properties \[ERRO\]  
  
\*\*Regra:\*\* Tokens vivem em \`:root\` no \`\<head\>\` do tema-base, antes de qualquer outra regra. Em multisite WordPress, tema-pai (parent) injeta tokens; tema-filho (child / tenant) sobreescreve apenas o que for especifico do tenant (cor primaria, logo).  
  
\`\`\`css  
/\* tema-base/style.css \*/  
:root {  
 /\* Tokens canonicos do Taito \*/  
 --color-primary-500: \#FF6B1A;  
 /\* ... \*/  
}  
  
/\* tenant-X/style.css \*/  
:root {  
 /\* Tenant Y tem cor primaria custom \*/  
 --color-primary-500: \#00A86B;  
}  
\`\`\`  
  
\---  
  
\#\#\# DSG-070 -- Sem dependencia de framework JS \[ERRO\]  
  
\*\*Regra:\*\* Componentes do Taito sao implementados em HTML + CSS + JS vanilla. Bibliotecas permitidas: Motion One (animacao, 3kb), Alpine.js (interatividade leve, 8kb gzipped), htmx (acoes server-driven, 14kb). React / Vue / Next.js sao \*\*proibidos\*\* no painel padrao.  
  
Excecao: ilhas de React isoladas para componentes muito complexos (ex.: editor de PDI com drag-drop). Aprovacao em PR.  
  
\---  
  
\#\#\# DSG-071 -- Otimizacao de fonte \[AVISO\]  
  
\*\*Regra:\*\* Fonte e variable, carregada via \`\<link rel="preload"\>\` no head. Subset latin-ext (cobre portugues + acentos especificos).  
  
\`\`\`html  
\<link  
 rel="preload"  
 as="font"  
 type="font/woff2"  
 href="/fonts/Geist-Variable.woff2"  
 crossorigin  
\>  
\`\`\`  
  
\---  
  
\#\#\# DSG-072 -- Estrutura de arquivos do tema \[AVISO\]  
  
\*\*Regra:\*\* Tema-base do WP tem estrutura padrao:  
  
\`\`\`  
tema-base/  
 tokens.css \<- DSG-011 a DSG-022  
 base.css \<- reset + tipografia base  
 components/  
 button.css  
 card.css  
 input.css  
 ...  
 layouts/  
 landing.css  
 panel.css  
 questionario.css  
 utilities.css \<- helpers (margin, padding utilitarios)  
 motion.css \<- DSG-065 a DSG-068  
 print.css  
\`\`\`  
  
\---  
  
\#\# Definition of Done -- Checklist visual  
  
\> PR de UI que viola algum item ERRO nao entra em review.  
  
| \# | Item | Regras |  
|---|------|--------|  
| 1 | Tokens consumidos via CSS custom property, nao valores hardcoded | DSG-011 a DSG-022, DSG-069 |  
| 2 | Cor primaria com no maximo 2 contextos de uso por tela | DSG-005, DSG-014 |  
| 3 | Tipografia em escala fixa (8 niveis) | DSG-016, DSG-017 |  
| 4 | Espacos em multiplos de 4px | DSG-018 |  
| 5 | Border-radius em 4 valores fixos | DSG-019 |  
| 6 | Sem gradiente em superficie de painel | DSG-014 |  
| 7 | Sem \`\<input type=file\>\` cru visivel | DSG-027 |  
| 8 | Empty state com 4 elementos (ilustracao, titulo, descricao, CTA) | DSG-036, DSG-049, DSG-056 |  
| 9 | Hover em todo elemento clicavel | DSG-003, DSG-065 |  
| 10 | Click active state (scale + transition) | DSG-066 |  
| 11 | Foco visivel em navegacao por teclado | DSG-060 |  
| 12 | Contraste minimo WCAG AA | DSG-059 |  
| 13 | Microcopy revisada (tom, sem ingles desnecessario) | DSG-053 a DSG-058 |  
| 14 | Modo focado em telas de tarefa cognitiva | DSG-006, DSG-047 |  
| 15 | Hierarquia comercial em telas de plano | DSG-007, DSG-046 |  
| 16 | Numeros tratados como informacao emocional | DSG-008, DSG-039 |  
| 17 | Erros tratam usuario com respeito | DSG-009, DSG-054 |  
| 18 | Consistencia entre landing publica e painel logado | DSG-010 |  
| 19 | Skeleton em vez de spinner | DSG-035 |  
| 20 | \`prefers-reduced-motion\` respeitado | DSG-064 |  
  
\---  
  
\#\# Roadmap de migracao  
  
\> Ordem proposta de refactor das telas, do maior ROI ao menor. Cada  
\> tela vira um epic; cada componente novo vira um PR isolado.  
  
\#\#\# Fase 1 -- Fundacao (sprint 1, \~1 semana)  
  
1\. Documentar tokens (Secao 2) em \`tokens.css\`.  
2\. Documentar componentes minimos basicos (botao, input, card, tag, alerta) em \`components/\`.  
3\. Criar pagina de "Storybook" simples em \`/painel/?pagina=design-system\` (so para times internos): renderiza todos os componentes em todos os estados. Valida visualmente que os tokens fazem sentido.  
  
\#\#\# Fase 2 -- Tela critica (sprint 2, \~1-2 semanas)  
  
4\. Refatorar \`/mapa/questionario/\` para modo focado (DSG-006, DSG-047).  
 - Remover header e footer de marketing.  
 - Header reduzido com logo + progresso.  
 - Card central maior, com indicador de competencia.  
 - Cooldown visual no botao "Proxima".  
 - Microinteracao em selecao de radio.  
 - Persistencia visual ("Salvo automaticamente").  
 - \*\*Antes/depois desse sprint vira material de marketing.\*\*  
  
\#\#\# Fase 3 -- Conversao (sprint 3, \~1 semana)  
  
5\. Refatorar \`/painel/?pagina=creditos\` espelhando \`/precos/\` (DSG-046).  
 - Componente unico de card de plano reutilizado.  
 - Card RECOMENDADO com destaque visual.  
 - Calculo derivado por pessoa.  
 - KPI de saldo com count-up (DSG-039).  
  
\#\#\# Fase 4 -- Onboarding (sprint 4, \~1 semana)  
  
6\. Refatorar \`/painel/?pagina=inicio\` (DSG-050).  
 - Saudacao com hora do dia.  
 - Card de status com CTA forte.  
 - Grade de modulos com estados claros.  
 - Stats pessoais.  
  
\#\#\# Fase 5 -- Dignidade (sprint 5, \~2 semanas)  
  
7\. Refatorar \`/painel/?pagina=perfil\` (DSG-048).  
 - Avatar grande com componente de upload (DSG-027).  
 - Formulario com inputs polidos.  
 - Estados de erro claros.  
 - Microcopy revisada.  
  
\#\#\# Fase 6 -- Empty states e secundarios (sprint 6, \~1 semana)  
  
8\. Implementar empty states reais para Catalogo, Pedidos, Resultados, Historico, PDI (DSG-036, DSG-049, DSG-056).  
9\. Refinar \`/painel/?pagina=mapa\` (alerta inline com componente, historico em tabela ou cards).  
10\. Padronizar header e footer do painel (DSG-038, DSG-052).  
  
\#\#\# Fase 7 -- Polimento (sprint 7+, continuo)  
  
11\. Adicionar microinteracoes (Secao 7) em todos os componentes.  
12\. Auditar e ajustar acessibilidade (Secao 6).  
13\. Skeleton states em listagens carregadas via AJAX.  
14\. Toast e alertas para sucesso de salvamento.  
  
\#\#\# Fase 8 -- Landing publica (sprint paralelo, opcional)  
  
15\. Pequenos ajustes na landing publica para alinhar com tokens formalizados (DSG-011 a DSG-022).  
 - A landing ja esta boa, mas pode ganhar consistencia com os mesmos componentes do painel (botao, card, tag).  
 - Importante: nao mexer em hero, secao de competencias, secao de precos -- ja estao redondos.  
  
\---  
  
\#\# Glossario visual  
  
\*\*Token.\*\* Valor nomeado (cor, tamanho, raio, sombra, duracao). A fonte unica da verdade. Sem token, sem padrao.  
  
\*\*Componente.\*\* Pedaco de UI reutilizavel com estados definidos (default, hover, focus, disabled, error). Construido a partir de tokens.  
  
\*\*Padrao de tela.\*\* Esqueleto de uma tela inteira (hero, dashboard, questionario). Define quais componentes vao em quais posicoes e como se comportam.  
  
\*\*Empty state.\*\* Tela ou regiao sem dados a mostrar. Tem 4 elementos: ilustracao, titulo, descricao, CTA.  
  
\*\*Modo focado.\*\* Estado de tela onde a interface se reduz ao minimo necessario para uma tarefa cognitiva longa (questionario, edicao densa). Header, footer e sidebar de marketing desaparecem.  
  
\*\*Microcopy.\*\* Textos pequenos do sistema (botoes, labels, alertas, tooltips). Tao importantes quanto pixel.  
  
\*\*Microinteracao.\*\* Pequena animacao com proposito (hover, click feedback, transicao de estado). Confirma acao do usuario.  
  
\*\*Skeleton.\*\* Placeholder cinza-claro com animacao shimmer que representa o conteudo enquanto ele carrega. Substitui spinner.  
  
\*\*Tag / Badge.\*\* Elemento pequeno que carrega informacao de status, categoria ou destaque. Variantes: subtle (95% dos usos), solid (destaque maximo).  
  
\*\*KPI / Numero emocional.\*\* Numero grande exibido com peso forte e label discreto -- saldo, progresso, contagem. Pode ter animacao de count-up.  
  
\*\*Hero.\*\* Bloco superior de uma tela importante (landing, pagina de feature, tela vitrine), com titulo display, descricao curta e CTAs.  
  
\*\*Eyebrow.\*\* Pequeno texto uppercase em laranja acima do titulo de secao da landing ("BASE CIENTIFICA", "A SOLUCAO", "PORTAL"). Padrao da landing Taito.  
  
\*\*Anchoring.\*\* Tecnica de design de pricing onde uma opcao e visualmente destacada como "RECOMENDADO" para guiar a decisao do usuario.  
  
\*\*Tell, Don't Ask (transversal).\*\* Em UI: a tela conta o que vai acontecer (ou aconteceu), em vez de pedir confirmacao redundante.  
  
\*\*Gap visual.\*\* Distancia entre como a marca foi pensada (landing publica) e como ela aparece de fato (painel logado). O Taito tem gap grande hoje. Este documento existe para fechar esse gap.  
  
\*\*Tema-base / Tema-tenant.\*\* No multisite WordPress, tema-base concentra os tokens e componentes; cada tenant herda e sobreescreve apenas o necessario (cor primaria, logo). Garante consistencia + flexibilidade.  
  
\*\*Ilha de React.\*\* Componente isolado em React dentro de uma pagina renderizada por PHP/WP. Excecao para componentes muito complexos (drag-drop avancado, editor de texto rico). Aprovacao explicita.  
  
\---  
  
\#\# Cross-references com outros documentos  
  
| Tema | padroes-design | padroes-php | padroes-poo | padroes-seguranca |  
|------|----------------|-------------|-------------|-------------------|  
| Validacao de entrada | DSG-009, DSG-025 | PHP-040 | POO-045 a POO-047 | SEG-003, SEG-004 |  
| Mensagens de erro | DSG-009, DSG-054 | PHP-034 | POO-048 | -- |  
| Componentes reusaveis | DSG-023 a DSG-040 | PHP-011 | POO-001, POO-013 | -- |  
| Empty states e estado vazio | DSG-036, DSG-049, DSG-056 | -- | POO-046, POO-049 | -- |  
| Acessibilidade | DSG-059 a DSG-064 | -- | -- | -- |  
| Performance perceptiva | DSG-035, DSG-065 a DSG-068 | PHP-042, PHP-050 | POO-049, POO-051 | -- |  
| Multisite / tenant | DSG-069, DSG-072 | -- | -- | SEG-013 |  
| Microcopy / linguagem ubiqua | DSG-053 a DSG-058 | -- | POO-002, POO-016 | -- |  
  
\---  
  
\#\# Hierarquia de precedencia  
  
Quando uma regra deste documento conflita com outro:  
  
1\. \*\*\`padroes-seguranca.md\`\*\* sempre vence -- seguranca e nao-negociavel.  
2\. \*\*\`padroes-design.md\`\*\* (este) vence as regras de "estilo" do \`padroes-php.md\`. Quando o PHP entrega HTML, a aparencia segue daqui.  
3\. \*\*\`padroes-poo.md\`\*\* vence quando o tema discutido e logica de dominio. Microcopy e voz, mesmo aplicados a entidades, vem de \`padroes-design\`.  
4\. \*\*\`padroes-php.md\`\*\* vence em detalhe especifico de PHP/PSR-12.  
5\. \*\*Convencoes de framework\*\* (WordPress, etc.) vencem apenas onde explicitamente cobertas por emenda do lider tecnico.  
  
\---  
  
\#\# Historico de versoes  
  
\- \*\*1.0.0 (2026-05-08)\*\* -- Documento inicial. 72 regras, baseadas em:  
 1. Auditoria visual completa de 13 telas em taito.app.br (landing publica + painel logado + questionario), realizada em 2026-05-08.  
 2. Identidade ja consolidada na landing publica do Taito -- a maior parte deste documento e a explicitacao formal do que a landing ja faz implicitamente.  
 3. Praticas modernas de design system contemporaneo (Linear, Stripe, Vercel, Notion).  
 4. Constraint do projeto: PHP-first multisite WordPress, sem framework JS pesado.  
  
 Fonte da auditoria: prints e analise de cada tela do painel logado, incluindo o questionario psicometrico em andamento. Diagnostico-chave: existe um gap visual significativo entre a landing (ja moderna, com identidade) e o painel logado (visualmente "Java enterprise"). Roadmap de migracao em 8 fases, comecando pelo questionario (maior ROI perceptivo).  
  
 Cross-references estabelecidas com \`padroes-php.md\` v4.0.0, \`padroes-poo.md\` v1.1.0 e (referencia futura) \`padroes-seguranca.md\`.  
  
 Total: 72 regras (36 ERRO, 36 AVISO). Documento com \~2700 linhas.  
  
\---  
