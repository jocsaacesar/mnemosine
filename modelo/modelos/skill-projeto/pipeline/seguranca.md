---
name: seguranca-{projeto}
description: Varre código novo buscando vulnerabilidades e corrige. SQL injection, XSS, IDOR, CSRF, auth bypass, data exposure. Corrige proativamente — não só reporta.
---

> **Engrama — BGR Software House**
> Art. 4° — Dados dos usuários são a coisa mais importante.
> Art. 14 — Proibido comprometer dados de usuários.
> Anexo I — Padrões de segurança (25 regras).
> Anexo V — Padrões de criptografia (21 regras).

# Segurança — {PROJETO}

Varre todo código novo (diff da branch) buscando vulnerabilidades. Diferente das auditoras que listam findings, esta skill **corrige** cada vulnerabilidade encontrada e documenta a correção.

## Escopo

```
LÊ:
  .specs/{spec-ativa}.md § Tarefas Segurança  ← superfície de ataque esperada
  projetos/{projeto}/**                        ← código (prod + testes)
  constitutional/padroes-minimos/padroes-seguranca.md
  constitutional/padroes-minimos/padroes-criptografia.md
  aprendizado/erros/*                          ← incidentes de segurança anteriores

ESCREVE (corrige):
  projetos/{projeto}/**                        ← aplica fixes no código

NÃO PODE:
  Alterar lógica de negócio. Mudar assinaturas de método. Remover funcionalidades.
```

## Processo

### 1. Identificar superfície de ataque

Ler a spec § Tarefas Segurança. Depois, varrer o diff da branch:

```bash
git diff staging --name-only
```

Classificar cada arquivo alterado por risco:

| Risco | Tipo de arquivo |
|-------|----------------|
| Alto | Handlers AJAX, REST endpoints, login/auth, migrations com PII |
| Médio | Templates com formulários, queries SQL, uploads |
| Baixo | CSS, config, docs |

### 2. Varredura por categoria

Verificar cada categoria em cada arquivo de risco alto/médio:

#### SQL Injection
- [ ] Todo `$wpdb->query()` usa `$wpdb->prepare()` com placeholders `%s`, `%d`, `%f`
- [ ] Nenhuma concatenação de variável em SQL (`"SELECT * FROM x WHERE id = $id"` = FATAL)
- [ ] `LIKE` usa `$wpdb->esc_like()` + `$wpdb->prepare()`
- [ ] `IN (...)` construído com array de placeholders, não `implode`
- (Referência: Anexo I, SEG-001 a SEG-005)

#### XSS (Cross-Site Scripting)
- [ ] Todo output no HTML usa escape: `esc_html()`, `esc_attr()`, `esc_url()`, `wp_kses_post()`
- [ ] Nenhum `echo $_POST/GET/REQUEST` direto
- [ ] `json_encode` com `JSON_HEX_TAG | JSON_HEX_AMP` quando inline no HTML
- [ ] URLs usam `esc_url()` — nunca `echo $url` direto em `href`
- (Referência: Anexo I, SEG-006 a SEG-010)

#### CSRF (Cross-Site Request Forgery)
- [ ] Todo form POST tem `wp_nonce_field('acao_especifica')`
- [ ] Todo handler AJAX verifica `check_ajax_referer('acao_especifica')`
- [ ] Nonce é específico por ação — não genérico (`wp_nonce_field('taito_nonce')` é ERRADO)
- [ ] Nonce inclui contexto quando relevante (`"taito_excluir_{$id}"`)
- (Referência: Anexo VI, WP-008)

#### IDOR (Insecure Direct Object Reference)
- [ ] Todo acesso a recurso verifica ownership: "este user pode ver/editar este objeto?"
- [ ] IDs em URL/POST não são confiáveis — validar contra sessão
- [ ] Cross-tenant: dados de `blog_id` X nunca acessíveis em `blog_id` Y
- [ ] Cross-empresa: dados de `empresa_id` X nunca acessíveis em `empresa_id` Y
- (Lição: incidente 0044, IDOR cross-tenant)

#### Auth Bypass
- [ ] Toda rota protegida verifica `is_user_logged_in()` ou `current_user_can()`
- [ ] Capabilities são granulares — não `manage_options` pra tudo
- [ ] REST endpoints usam `permission_callback` — nunca `__return_true`
- [ ] AJAX handlers verificam capability antes de processar
- (Lição: incidentes 0027, 0045)

#### Data Exposure
- [ ] PII criptografada quando especificado (XChaCha20-Poly1305 ou AES-256-GCM)
- [ ] Nenhum dado sensível em logs (email, senha, token, CPF)
- [ ] Nenhum dado sensível no HTML source (IDs internos, tokens, emails de outros)
- [ ] `.env` no `.gitignore` E no `.dockerignore`
- [ ] `composer.json`, `package.json` inacessíveis via web
- (Lição: incidentes 0031, 0034, 0035)

#### Upload Security
- [ ] Validação MIME real (não só extensão)
- [ ] Tamanho máximo definido
- [ ] Diretório de upload fora do webroot ou com `.htaccess` deny
- [ ] Nome do arquivo sanitizado (`sanitize_file_name()`)

#### Headers e Configuração
- [ ] CSP definido e inclui recursos externos necessários (Lição: incidente 0032)
- [ ] `expose_php = Off`
- [ ] Sessões: `cookie_httponly`, `cookie_secure`, `cookie_samesite`
- [ ] `X-Content-Type-Options: nosniff`
- [ ] `X-Frame-Options: DENY` (ou SAMEORIGIN se necessário)

### 3. Corrigir

Para cada vulnerabilidade encontrada:

1. **Corrigir no código** — aplicar o fix mínimo que resolve sem mudar lógica
2. **Commitar** — prefixo `security:` com descrição da vulnerabilidade
3. **Documentar** — anotar no relatório: arquivo, linha, categoria, fix aplicado

### 4. Relatório

Entregar pro gerente:

```
## Relatório de Segurança — {spec}

Arquivos varridos: {N}
Vulnerabilidades encontradas: {M}
Vulnerabilidades corrigidas: {M}

| # | Arquivo | Linha | Categoria | Severidade | Fix |
|---|---------|-------|-----------|------------|-----|
| 1 | handler.php | 45 | SQL Injection | CRÍTICO | $wpdb->prepare() adicionado |
```

## Regras

- **Corrigir, não reportar.** A diferença entre esta skill e as auditoras: esta aplica o fix. Se o fix mudar lógica de negócio, aí sim reportar pro gerente.
- **Severidade CRÍTICO = fix imediato.** SQL injection, auth bypass, data exposure não esperam.
- **Nunca adicionar dependência.** O fix usa as ferramentas do framework (WP, PHP nativo). Não instalar pacotes de segurança.
- **Nunca alterar assinatura de método.** O fix é interno. Se a assinatura precisa mudar pra ser segura, reportar pro gerente.
- **Security by default.** Na dúvida, o código é restritivo. Melhor negar acesso legítimo (fix fácil) que permitir acesso indevido (incidente).
