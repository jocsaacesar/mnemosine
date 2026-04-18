---
name: auditar-cripto
description: Audita implementacao de criptografia do PR aberto contra as regras definidas em docs/padroes-criptografia.md. Cobre algoritmo, AEAD, KDF, validacao de chave, versionamento, rotacao, memoria, envelope encryption e uso nos repositorios. Trigger manual apenas.
---

# /auditar-cripto — Auditora de criptografia

Le as regras de `docs/padroes-criptografia.md`, identifica os arquivos PHP relevantes no PR aberto (nao mergeado) e compara cada arquivo contra cada regra de criptografia aplicavel. Foco em: algoritmo e biblioteca, criptografia autenticada (AEAD), derivacao de chave (KDF), validacao de chave, versionamento de ciphertext, rotacao, gestao de memoria, envelope encryption e uso correto nos repositorios.

Complementa `/auditar-seguranca` (seguranca geral) e `/auditar-php` (sintaxe).

## Quando usar

- **APENAS** quando o usuario digitar `/auditar-cripto` explicitamente.
- Rodar antes de mergear um PR que altere classes de criptografia, repositorios ou configuracao de chaves.
- **Nunca** disparar automaticamente, nem como parte de outra skill.

## Padroes minimos exigidos

> Esta secao contem os padroes completos usados pela auditoria. Edite para personalizar ao seu projeto.

# Padrao de criptografia

## Descricao

Documento de referencia para auditoria de criptografia no projeto. Define regras obrigatorias para proteger dados sensiveis em repouso usando criptografia autenticada moderna. A skill `/auditar-cripto` le este documento e compara contra o codigo-alvo.

## Escopo

- Classe de criptografia do projeto
- Todo repositorio que injeta a interface de criptografia
- Configuracao de chaves (`.env`, `.env.example`)
- Contexto: dados sensiveis em repouso no banco de dados

## Referencias

- [Libsodium — XChaCha20-Poly1305](https://doc.libsodium.org/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction)
- [Latacora — Cryptographic Right Answers](https://latacora.micro.blog/2018/04/03/cryptographic-right-answers.html)
- [OWASP Cryptographic Storage Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html)
- [PHP Sodium Extension](https://www.php.net/manual/en/book.sodium.php)

## Severidade

- **ERRO** — Violacao bloqueia aprovacao. Deve ser corrigida antes de merge.
- **AVISO** — Recomendacao forte. Deve ser justificada se ignorada.

---

## 1. Algoritmo e biblioteca

### CRIPTO-001 — Usar Libsodium nativo do PHP [ERRO]

A criptografia de dados em repouso deve usar a extensao Sodium nativa do PHP (disponivel desde PHP 7.2). Proibido usar `openssl_encrypt` / `openssl_decrypt` para novos dados. O algoritmo alvo e **XChaCha20-Poly1305** via `sodium_crypto_aead_xchacha20poly1305_ietf_encrypt`.

```php
// correto — Libsodium AEAD
$nonce = random_bytes(SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_NPUBBYTES); // 24 bytes
$cifrado = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
    $texto,
    '',           // additional data (contexto, ex: tabela + campo)
    $nonce,
    $chaveDerivada
);

// incorreto — OpenSSL manual
$cifrado = openssl_encrypt($texto, 'aes-256-cbc', $chave, OPENSSL_RAW_DATA, $iv);
```

**Excecao:** Leitura de dados legados criptografados com OpenSSL e permitida durante o periodo de migracao.

### CRIPTO-002 — Proibido algoritmos obsoletos ou caseiros [ERRO]

Proibido: DES, 3DES, RC4, Blowfish, MD5 para criptografia, SHA1 para integridade, `mcrypt_*`, modos ECB, CBC sem autenticacao. Proibido implementar algoritmos caseiros.

---

## 2. Criptografia autenticada (AEAD)

### CRIPTO-003 — Todo ciphertext deve ser autenticado [ERRO]

Criptografia sem autenticacao e vulneravel a ataques de manipulacao. O modo de operacao deve ser **AEAD** (Authenticated Encryption with Associated Data).

Com Libsodium, `sodium_crypto_aead_xchacha20poly1305_ietf_encrypt` ja e AEAD nativo.

### CRIPTO-004 — Descriptografia que falha deve lancar excecao tipada [ERRO]

Se `sodium_crypto_aead_*_decrypt` retornar `false`, a classe deve lancar excecao tipada imediatamente. Nunca retornar string vazia, null ou dado parcial.

---

## 3. Derivacao de chave (KDF)

### CRIPTO-005 — Nunca usar a chave mestra diretamente nos dados [ERRO]

A string `APP_ENCRYPTION_KEY` do `.env` e a chave mestra (KEK). Ela nunca deve ser passada diretamente para funcoes de criptografia. Deve-se derivar sub-chaves especificas via **HKDF** usando `sodium_crypto_kdf_derive_from_key`.

```php
// correto — derivacao de sub-chave
$subchave = sodium_crypto_kdf_derive_from_key(
    SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_KEYBYTES,
    $subchaveId,    // inteiro — identifica o contexto
    'MeuApp__',     // contexto de 8 bytes, identifica a aplicacao
    $chaveMestra
);

// incorreto — chave mestra direto nos dados
$cifrado = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt($texto, '', $nonce, $chaveMestra);
```

### CRIPTO-006 — Contextos de derivacao distintos para cada finalidade [AVISO]

Cada uso criptografico (dados sensiveis, TOTP secrets, tokens) deve usar um `subkey_id` diferente na derivacao.

---

## 4. Validacao de chave

### CRIPTO-007 — Chave mestra deve ter exatamente 32 bytes [ERRO]

O construtor da classe de criptografia deve validar que `APP_ENCRYPTION_KEY` tem exatamente 32 bytes. Caso contrario, lancar excecao fatal imediatamente. Nao tentar corrigir (padding, hash).

```php
// correto
$chave = getenv('APP_ENCRYPTION_KEY');

if ($chave === false || $chave === '') {
    throw new ChaveCriptografiaAusenteException('APP_ENCRYPTION_KEY nao definida.');
}

if (mb_strlen($chave, '8bit') !== SODIUM_CRYPTO_KDF_KEYBYTES) {
    throw new ChaveCriptografiaAusenteException(
        'APP_ENCRYPTION_KEY deve ter exatamente 32 bytes.'
    );
}
```

### CRIPTO-008 — Chave ausente interrompe o bootstrap [ERRO]

Se `APP_ENCRYPTION_KEY` nao estiver definida ou for vazia, o sistema nao deve inicializar.

---

## 5. Versionamento de ciphertext

### CRIPTO-009 — Todo ciphertext deve ter prefixo de versao [ERRO]

Para permitir rotacao de chave e migracao de algoritmo sem quebrar dados existentes, todo dado criptografado deve comecar com um prefixo de versao.

```
v1|nonce(24 bytes base64)|ciphertext(base64)   -> Libsodium XChaCha20-Poly1305
```

### CRIPTO-010 — Migracao gradual de dados legados [AVISO]

Dados criptografados com algoritmo legado devem ser re-criptografados com o algoritmo atual quando lidos e regravados.

---

## 6. Rotacao de chave

### CRIPTO-011 — Suporte a multiplas versoes de chave simultaneas [AVISO]

O sistema deve suportar pelo menos duas versoes de chave ativas ao mesmo tempo.

### CRIPTO-012 — Rotacao nao requer re-encrypt em massa [AVISO]

Ao rotacionar a chave mestra, apenas novos dados e dados regravados usam a nova chave.

---

## 7. Gestao de memoria

### CRIPTO-013 — Limpar chaves da memoria apos uso [AVISO]

Chaves e sub-chaves devem ser zeradas da memoria RAM com `sodium_memzero()` apos cada operacao.

```php
// correto
$subchave = sodium_crypto_kdf_derive_from_key(/* ... */);
$cifrado = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt($texto, '', $nonce, $subchave);
sodium_memzero($subchave);
```

### CRIPTO-014 — Nunca logar chaves, sub-chaves ou nonces [ERRO]

Proibido incluir material criptografico em logs, error_log, var_dump, debug_backtrace ou qualquer saida de diagnostico.

---

## 8. Envelope encryption (futuro)

### CRIPTO-015 — Dados criptografados com DEK, DEK protegida por KEK [AVISO]

Para escala futura, cada registro deve ser criptografado com uma **Data Encryption Key (DEK)** unica, e a DEK deve ser criptografada pela **Key Encryption Key (KEK)** mestra.

### CRIPTO-016 — DEK deve ser unica por registro ou por lote [AVISO]

---

## 9. Repositorios e uso da interface

### CRIPTO-017 — Todo campo sensivel deve ser criptografado [ERRO]

Campos que contem dados sensiveis devem ser armazenados criptografados no banco. O tipo da coluna no banco deve ser `TEXT` (ciphertext tem tamanho variavel).

### CRIPTO-018 — Criptografia/descriptografia apenas no repositorio [ERRO]

A criptografia e descriptografia de campos acontece exclusivamente na camada de repositorio. Entidades, gerenciadores e handlers nunca manipulam dados criptografados diretamente.

### CRIPTO-019 — Interface segregada para testabilidade [ERRO]

A classe de criptografia deve implementar uma interface. Repositorios dependem da interface, nunca da implementacao concreta. Testes usam mock da interface.

```php
// correto
public function __construct(
    private readonly Database $db,
    private readonly CriptografiaInterface $cripto,
) {}

// incorreto — dependencia concreta
public function __construct(
    private readonly Database $db,
    private readonly Criptografia $cripto,
) {}
```

---

## 10. Nonce e aleatoriedade

### CRIPTO-020 — Nonce gerado com CSPRNG [ERRO]

O nonce deve ser gerado exclusivamente com `random_bytes()` do PHP. Proibido: `rand()`, `mt_rand()`, `uniqid()`, timestamp, contador previsivel.

### CRIPTO-021 — Nonce nunca reutilizado com a mesma chave [ERRO]

O nonce deve ser gerado aleatoriamente a cada operacao — nunca armazenado e reutilizado.

---

## Resumo de regras

| ID | Regra | Severidade |
|----|-------|-----------|
| CRIPTO-001 | Usar Libsodium nativo do PHP | ERRO |
| CRIPTO-002 | Proibido algoritmos obsoletos ou caseiros | ERRO |
| CRIPTO-003 | Todo ciphertext deve ser autenticado (AEAD) | ERRO |
| CRIPTO-004 | Descriptografia falha -> excecao tipada | ERRO |
| CRIPTO-005 | Nunca usar chave mestra diretamente nos dados (KDF) | ERRO |
| CRIPTO-006 | Contextos de derivacao distintos por finalidade | AVISO |
| CRIPTO-007 | Chave mestra deve ter exatamente 32 bytes | ERRO |
| CRIPTO-008 | Chave ausente interrompe o bootstrap | ERRO |
| CRIPTO-009 | Todo ciphertext com prefixo de versao | ERRO |
| CRIPTO-010 | Migracao gradual de dados legados | AVISO |
| CRIPTO-011 | Suporte a multiplas versoes de chave | AVISO |
| CRIPTO-012 | Rotacao sem re-encrypt em massa | AVISO |
| CRIPTO-013 | Limpar chaves da memoria apos uso | AVISO |
| CRIPTO-014 | Nunca logar material criptografico | ERRO |
| CRIPTO-015 | Envelope encryption: DEK/KEK | AVISO |
| CRIPTO-016 | DEK unica por registro ou lote | AVISO |
| CRIPTO-017 | Todo campo sensivel criptografado | ERRO |
| CRIPTO-018 | Criptografia apenas no repositorio | ERRO |
| CRIPTO-019 | Interface segregada para testabilidade | ERRO |
| CRIPTO-020 | Nonce gerado com CSPRNG | ERRO |
| CRIPTO-021 | Nonce nunca reutilizado com mesma chave | ERRO |

**Total: 21 regras (13 ERROs, 8 AVISOs)**

## Processo

### Fase 1 — Carregar a regua

1. Ler a secao **Padroes minimos exigidos** deste documento.
2. Internalizar todas as 21 regras com seus IDs (CRIPTO-001 a CRIPTO-021), descricoes, exemplos e severidades (ERRO/AVISO).
3. Nao resumir nem recitar o documento de volta.

### Fase 2 — Identificar o PR aberto

1. Executar `gh pr list --state open --base main --json number,title,headBranch --limit 1` para encontrar o PR aberto mais recente.
2. Se nao encontrar contra `main`, tentar `--base develop`.
3. Se houver mais de um PR aberto, listar todos e perguntar ao usuario qual auditar.
4. Se nao houver PR aberto, informar o usuario e encerrar.
5. Executar `gh pr diff <numero>` para obter o diff completo do PR.

### Fase 3 — Identificar arquivos alvo

Filtrar os arquivos do diff e adicionar os arquivos core de criptografia (sempre auditados):

**Sempre auditados:**
- Classe de criptografia
- Interface de criptografia
- Excecoes de criptografia

**Auditados se alterados no PR:**
- Todo repositorio que injeta a interface de criptografia
- `.env.example` (configuracao de chave)
- Arquivo de bootstrap/instanciacao

### Fase 4 — Auditar arquivo por arquivo

Para cada arquivo identificado:

1. Ler o arquivo completo (nao apenas o diff — contexto importa).
2. Comparar contra **cada regra** de `docs/padroes-criptografia.md`, uma por uma, na ordem do documento.
3. Para cada violacao encontrada, registrar:
   - **Arquivo** e **linha(s)** onde ocorre
   - **ID da regra** violada (ex.: padroes-criptografia.md, CRIPTO-003)
   - **Severidade** (ERRO ou AVISO)
   - **Categoria** (Algoritmo, AEAD, KDF, Validacao, Versionamento, Rotacao, Memoria, Envelope, Repositorio, Nonce)
   - **O que esta errado** — descricao concisa
   - **Como corrigir** — correcao especifica com codigo de exemplo usando Libsodium
4. Se o arquivo nao viola nenhuma regra, registrar como aprovado.

### Fase 5 — Relatorio

Apresentar o relatorio ao usuario com tabela de estado atual vs. target e tabela de violacoes.

### Fase 6 — Plano de migracao

Se houver violacoes do tipo ERRO:

1. Classificar as correcoes em **fases de migracao**:
   - **Fase 1 (imediata):** Validacao de chave (CRIPTO-007, CRIPTO-008).
   - **Fase 2 (nova classe):** Criar nova implementacao com Libsodium + KDF + versionamento.
   - **Fase 3 (migracao):** Atualizar interface para suportar fallback legado.
   - **Fase 4 (limpeza):** Remover codigo legado. Memory zeroing.
   - **Fase 5 (futuro):** Envelope encryption.

2. Para cada fase, indicar exatamente quais arquivos mudam e o que muda.
3. Perguntar ao usuario: "Quer que eu execute a Fase 1 agora?"

## Regras

- **Nunca alterar codigo durante a auditoria.** A skill e read-only ate o usuario pedir correcao explicitamente.
- **Sempre auditar os arquivos core de criptografia**, mesmo que nao alterados no PR.
- **Sempre referenciar o ID da regra violada.** O relatorio deve ser rastreavel ao documento de padroes.
- **Nunca inventar regras.** A regua e exclusivamente o `docs/padroes-criptografia.md`.
- **Ser metodica e processual.** Cada arquivo e comparado contra cada regra, na ordem do documento, sem pular.
- **Fidelidade ao documento.** Se o codigo viola uma regra do documento, reportar. Se o documento nao cobre o caso, nao reportar.
- **Priorizar por risco de dados.** AEAD e KDF vem antes de memory zeroing e envelope encryption.
- **Mostrar o relatorio completo antes de qualquer acao.** Nunca executar correcoes sem aprovacao explicita.
- **O plano de migracao e obrigatorio.** Criptografia exige migracao gradual para nao quebrar dados existentes.
