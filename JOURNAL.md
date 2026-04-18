# Diário

Decisões, aprendizados e insights da construção do framework Mnemósine.

Cada entrada responde três perguntas:
- **O que decidimos**
- **Por quê**
- **O que aprendemos**

---

## Verde visual não é validação real

**O que decidimos:** Tratar sinais visuais de CI (badges verdes, ícones de sucesso) como indicadores frágeis e investir em checks executáveis que bloqueiam automaticamente.

**Por quê:** Em quatro incidentes distintos, bugs estavam ativos e os mecanismos existentes não pegaram: testes SKIPPED apareciam verdes, regras textuais existiam mas sem enforcement automático, CI vermelho em um workflow passava despercebido porque outro workflow aparecia verde, e uma regra de código (documentada no CLAUDE.md) foi violada em uma auditoria massiva porque dependia de atenção humana.

**O que aprendemos:** A diferença entre "regra escrita" e "regra aplicada" é binária. Enquanto o enforcement depender de memória humana ou atenção visual, a regra é um desejo — não um contrato. A solução: **cada sinal frágil vira um check executável** — teste automatizado cobrindo o contrato real, check estático que bloqueia PR, observabilidade com alerta ativamente consumido. Toda vez que a gente identifica uma regra que sobrevive só porque alguém se lembra dela, é porque ainda não foi transformada em check.

---

## Documentar antes de automatizar

**O que decidimos:** Criar um guia escrito explicando como instalar o framework em um projeto existente, em vez de construir imediatamente uma skill automatizada.

**Por quê:** Ao instalar o framework em um projeto existente, `.gitignore`, `CLAUDE.md`, `README.md` e `.github/` conflitariam. Antes de automatizar, precisávamos entender e documentar exatamente o que conflita, o que copiar e o que ignorar.

**O que aprendemos:** Nem todo problema precisa de uma skill. Às vezes a melhor ferramenta é um documento claro. Automatizar um processo que você ainda não documentou é receita para bugs silenciosos.

---

## CLAUDE.md é do usuário, documentação é do framework

**O que decidimos:** Separar a documentação do framework da identidade da IA do usuário. O repositório envia um placeholder no CLAUDE.md que o `/comece-por-aqui` substitui com a identidade personalizada.

**Por quê:** Se o usuário clonar o repositório em um projeto que já tem CLAUDE.md, o arquivo seria sobrescrito. Pior: mesmo em projeto novo, o CLAUDE.md que enviávamos era documentação do framework, não identidade — o Claude Code estaria lendo um manual em vez de uma personalidade.

**O que aprendemos:** O arquivo que o sistema lê automaticamente deve pertencer ao usuário, não ao framework. Documentação é referência, não identidade. Misturar os dois cria um conflito que só aparece quando outra pessoa usa.

---

## Primeiro feedback externo: o README precisa vender, não descrever

**O que decidimos:** Reescrever o README completamente. Substituir a estrutura do projeto como peça central por um fluxo visual de onboarding, uma tabela antes/depois e uma seção prática.

**Por quê:** O primeiro testador externo deu um feedback claro: "Não me importo com a estrutura do projeto. Quero ler o README e saber o que é isso." Também apontou que skills globais vs locais não estavam claras e levantou preocupações legítimas sobre skills modificando o sistema.

**O que aprendemos:** Um README de repositório público tem uma função: fazer um estranho entender o valor em 30 segundos. Estrutura de projeto é pra contribuidores, não visitantes. Disclaimers de segurança não são opcionais quando você pede para alguém rodar comandos na máquina. E o primeiro feedback externo é sempre humilhante — o que é óbvio pra quem construiu é invisível pra quem lê.

---

## Todas as skills são locais por padrão, global é opcional

**O que decidimos:** Documentar explicitamente que todas as skills deste repositório são locais à pasta do projeto. Nada toca o `~/.claude/` globalmente. Se o usuário quiser uma skill global, copia manualmente.

**Por quê:** Feedback externo levantou medo de skills globais ("É tipo colocar algo na BIOS"). Preocupação legítima — um usuário clonando um repositório não deveria se preocupar com o sistema sendo modificado.

**O que aprendemos:** Ao distribuir skills, o padrão deve ser sempre a opção mais segura. Local por padrão, global por escolha é o único design seguro. Usuários avançados vão descobrir como ir pro global. Usuários novos precisam se sentir seguros primeiro.

---

## Problema de bootstrap: skills precisam funcionar antes do /iniciar

**O que decidimos:** Documentar explicitamente que `/comece-por-aqui` é a única skill que roda sem `/iniciar`. O Claude Code auto-descobre skills da pasta `.claude/skills/`, então nenhum passo de bootstrap é necessário.

**Por quê:** Um usuário novo lê que o `/iniciar` carrega skills e assume que precisa dele primeiro. Mas o `/comece-por-aqui` precisa rodar em um ambiente zerado — antes do CLAUDE.md ou memórias existirem. A documentação criava um problema do ovo e da galinha.

**O que aprendemos:** Quando você projeta um sistema com um passo de "carregar tudo", precisa documentar explicitamente o que acontece *antes* desse passo existir. O caso de bootstrap é sempre especial.

---

## /comece-por-aqui: onboarding como conversa, não como manual

**O que decidimos:** Criar uma skill de onboarding que entrevista novos usuários uma pergunta por vez — quem são, o que estão construindo, como trabalham, o que evitar e como chamar a IA — e então constrói uma configuração personalizada completa.

**Por quê:** Um repositório com ótima documentação ainda falha se o usuário não sabe por onde começar. Templates exigem ler instruções e preencher campos. Uma entrevista exige apenas responder perguntas.

**O que aprendemos:** O ponto de entrada de um framework não deveria ensinar o framework — deveria fazer as perguntas certas. Compreensão vem depois, com o uso.

---

## Publicação como fase distinta do encerramento

**O que decidimos:** Criar uma skill dedicada (`/tornar-publico`) que audita o trabalho da sessão, sanitiza dados pessoais e publica conteúdo com valor pedagógico — com confirmação obrigatória do usuário antes de qualquer commit.

**Por quê:** Separar manualmente o pessoal do público a cada sessão é tedioso e propenso a erros. Mas automação completa sem supervisão é perigosa com dados pessoais.

**O que aprendemos:** O ciclo de vida da sessão tem três tempos: `/iniciar` (abrir), `/tornar-publico` (publicar), `/ate-a-proxima` (fechar). Publicação exige revisão consciente — não é algo que se faz no automático enquanto diz tchau.

---

## Diário em vez de log diário

**O que decidimos:** Usar um diário baseado em decisões em vez de um log cronológico diário.

**Por quê:** Logs diários viram ruído rápido — milhares de linhas que ninguém lê. Entradas de decisão continuam úteis porque capturam o *porquê* algo foi escolhido, não apenas *o que* aconteceu.

**O que aprendemos:** A unidade de documentação para um processo de colaboração é a **decisão**, não o **dia**.

---

## Memória vive no projeto, não escondida no sistema

**O que decidimos:** Todos os arquivos de memória vivem na pasta `memoria/` do projeto, visíveis e editáveis pelo humano. Espelhados em `.claude/projects/` para carregamento automático.

**Por quê:** O criador precisa de visibilidade total e controle sobre o que a IA lembra. Estado oculto quebra confiança.

**O que aprendemos:** Transparência é um princípio de design, não uma funcionalidade. Uma interface de colaboração onde um lado tem memória oculta não é uma colaboração — é uma caixa-preta.
