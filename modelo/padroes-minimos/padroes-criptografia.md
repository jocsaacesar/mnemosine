---
documento: padroes-criptografia
versao: 2.1.0
criado: 2025-01-01
atualizado: 2026-04-16
total_regras: 21
severidades:
  erro: 14
  aviso: 7
escopo: Criptografia de dados em repouso e em trânsito em todos os projetos BGR
aplica_a: ["todos"]
requer: ["padroes-seguranca"]
substitui: ["padroes-criptografia v1.0.0"]
---

# Padroes de Criptografia — BGR Software House

> Documento constitucional. Contrato de entrega entre a BGR e todo
> desenvolvedor que toca criptografia nos nossos projetos.
> Codigo que viola regras ERRO nao e discutido — e devolvido.

---

## Como usar este documento

### Para o desenvolvedor

1. Leia as regras antes de implementar qualquer operacao criptografica.
2. Use os IDs (CRIPTO-001 a CRIPTO-021) para referenciar em PRs e code reviews.
3. Consulte o DoD no final antes de abrir qualquer Pull Request que envolva criptografia.

### Para o auditor (humano ou IA)

1. Leia o frontmatter para entender escopo e dependencias.
2. Audite o codigo contra cada regra por ID.
3. Classifique violacoes pela severidade definida neste documento.
4. Referencie violacoes pelo ID da regra (ex.: "viola CRIPTO-005").

### Para o Claude Code

1. Leia o frontmatter para identificar escopo e documentos relacionados.
2. Ao revisar codigo, verifique cada regra ERRO obrigatoriamente.
3. Ao gerar codigo, aplique todas as regras automaticamente.
4. Referencie violacoes sempre pelo ID (ex.: "viola CRIPTO-014").

---

## Severidades

| Nivel | Significado | Acao |
|-------|-------------|------|
| **ERRO** | Violacao inegociavel | Bloqueia merge. Corrigir antes de review. |
| **AVISO** | Recomendacao forte | Deve ser justificada por escrito se ignorada. |

---

## 1. Algoritmo e biblioteca

### CRIPTO-001 — Usar criptografia autenticada moderna via biblioteca padrao [ERRO]

**Regra:** A criptografia de dados deve usar bibliotecas criptograficas nativas e auditadas da linguagem/plataforma. Em PHP, usar a extensao Sodium nativa (disponivel desde PHP 7.2). O algoritmo padrao e **XChaCha20-Poly1305** via `sodium_crypto_aead_xchacha20poly1305_ietf_encrypt`. Em outras linguagens, usar a biblioteca equivalente recomendada (libsodium bindings, Web Crypto API, NaCl). Proibido usar APIs criptograficas de baixo nivel que exigem montagem manual (ex.: `openssl_encrypt` / `openssl_decrypt` em PHP).

**Verifica:** Buscar `openssl_encrypt`, `openssl_decrypt`, `mcrypt_*` no codigo. Toda chamada de criptografia deve usar `sodium_crypto_*`.

**Por que na BGR:** A BGR manipula dados sensiveis (financeiros, de saude, educacionais). O time e pequeno e o desenvolvimento e assistido por IA — nao ha margem para montar primitivos criptograficos manualmente. Libsodium oferece uma API de alto nivel que torna dificil errar: nonce gerado automaticamente com tamanho correto, autenticacao embutida, sem escolha de modo de operacao. Menos decisoes manuais = menos falhas criptograficas.

**Exemplo correto:**
```php
// PHP — Libsodium AEAD nativo
$nonce = random_bytes(SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_NPUBBYTES); // 24 bytes
$cifrado = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
    $texto,
    '',           // additional data (contexto, ex: tabela + campo)
    $nonce,
    $chaveDerivada
);
```

**Exemplo incorreto:**
```php
// OpenSSL manual — exige escolha de modo, IV manual, sem autenticacao embutida
$cifrado = openssl_encrypt($texto, 'aes-256-cbc', $chave, OPENSSL_RAW_DATA, $iv);
```

**Excecoes:** Leitura de dados legados criptografados com outra biblioteca e permitida durante periodo de migracao, desde que novas gravacoes usem a biblioteca padrao.

**Referencias:** CRIPTO-003

### CRIPTO-002 — Proibido algoritmos obsoletos ou caseiros [ERRO]

**Regra:** Proibido usar DES, 3DES, RC4, Blowfish, MD5 para criptografia, SHA1 para integridade, `mcrypt_*`, modos ECB, CBC sem autenticacao. Proibido implementar algoritmos caseiros — sempre usar primitivos de biblioteca auditada.

**Verifica:** Buscar `des`, `3des`, `rc4`, `blowfish`, `md5(`, `sha1(`, `mcrypt_`, `ecb`, `cbc` no codigo. Buscar funcoes de XOR manual sobre strings.

**Por que na BGR:** Um time pequeno nao tem capacidade de revisar implementacoes criptograficas customizadas. Algoritmos obsoletos tem vulnerabilidades documentadas e exploits publicos. Com desenvolvimento assistido por IA, o risco de uma sugestao automatica usar um algoritmo obsoleto e real — esta regra funciona como barreira explicita.

**Exemplo correto:**
```php
// Algoritmo moderno via biblioteca auditada
$cifrado = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
    $texto, '', $nonce, $chaveDerivada
);
```

**Exemplo incorreto:**
```php
// DES — obsoleto desde 1999
$cifrado = openssl_encrypt($texto, 'des-ecb', $chave);

// Algoritmo caseiro — nunca
function minhaCriptografia(string $texto, string $chave): string {
    $resultado = '';
    for ($i = 0; $i < strlen($texto); $i++) {
        $resultado .= chr(ord($texto[$i]) ^ ord($chave[$i % strlen($chave)]));
    }
    return $resultado;
}
```

---

## 2. Criptografia autenticada (AEAD)

### CRIPTO-003 — Todo ciphertext deve ser autenticado [ERRO]

**Regra:** Criptografia sem autenticacao (AES-CBC puro, XOR, etc.) e proibida. O modo de operacao deve ser **AEAD** (Authenticated Encryption with Associated Data), que garante confidencialidade e integridade em uma unica operacao atomica. Com Libsodium, `sodium_crypto_aead_xchacha20poly1305_ietf_encrypt` ja e AEAD nativo — a tag de autenticacao (Poly1305, 16 bytes) e gerada e verificada automaticamente.

**Verifica:** Confirmar que toda chamada de criptografia usa funcoes `_aead_` do Sodium. Nenhum `openssl_encrypt` com modo CBC/CTR sem HMAC separado.

**Por que na BGR:** Dados financeiros e de saude adulterados silenciosamente sao piores que dados perdidos. Criptografia sem autenticacao permite que um atacante modifique o ciphertext sem deteccao (padding oracle, bit flipping). Na BGR, onde os dados criptografados alimentam calculos financeiros e decisoes de negocio, integridade e tao critica quanto confidencialidade.

**Exemplo correto:**
```php
// AEAD nativo — verificacao automatica na descriptografia
$texto = sodium_crypto_aead_xchacha20poly1305_ietf_decrypt(
    $cifrado,
    '',
    $nonce,
    $chaveDerivada
);

if ($texto === false) {
    throw new CriptografiaException('Dado adulterado ou chave incorreta.');
}
```

**Exemplo incorreto:**
```php
// CBC sem HMAC — nao detecta adulteracao
$texto = openssl_decrypt($cifrado, 'aes-256-cbc', $chave, OPENSSL_RAW_DATA, $iv);
// openssl_decrypt pode retornar lixo silenciosamente se o ciphertext foi manipulado
```

### CRIPTO-004 — Descriptografia que falha deve lancar excecao tipada [ERRO]

**Regra:** Se a funcao de descriptografia retornar falha (ex.: `false` em Libsodium), o codigo deve lancar uma excecao tipada imediatamente. Nunca retornar string vazia, null ou dado parcial.

**Verifica:** Buscar `_decrypt(` e confirmar que o retorno `false` lanca excecao tipada. Nenhum `?: ''` ou `?? null` apos descriptografia.

**Por que na BGR:** Dados financeiros descriptografados incorretamente que passam silenciosamente podem gerar calculos errados, relatorios incorretos e decisoes de negocio baseadas em lixo. Uma excecao tipada permite tratamento especifico (retry com chave anterior, log de auditoria, alerta) em vez de falha silenciosa.

**Exemplo correto:**
```php
$texto = sodium_crypto_aead_xchacha20poly1305_ietf_decrypt(
    $cifrado, '', $nonce, $chaveDerivada
);

if ($texto === false) {
    throw new CriptografiaException('Falha na descriptografia: dado adulterado ou chave incorreta.');
}

return $texto;
```

**Exemplo incorreto:**
```php
$texto = sodium_crypto_aead_xchacha20poly1305_ietf_decrypt(
    $cifrado, '', $nonce, $chaveDerivada
);

return $texto ?: ''; // retorna string vazia em vez de reportar falha
```

---

## 3. Derivacao de chave (KDF)

### CRIPTO-005 — Nunca usar a chave mestra diretamente nos dados [ERRO]

**Regra:** A chave mestra (KEK) armazenada em variavel de ambiente nunca deve ser passada diretamente para funcoes de criptografia. Derivar sub-chaves especificas via **HKDF** (ex.: `sodium_crypto_kdf_derive_from_key` em PHP). Cada sub-chave e vinculada a um contexto (aplicacao + finalidade).

**Verifica:** Buscar a variavel de chave mestra (`$chaveMestra`, `APP_ENCRYPTION_KEY`) como argumento direto de funcoes `_encrypt`/`_decrypt`. Deve passar apenas por `_kdf_derive_from_key`.

**Por que na BGR:** Se a chave mestra vazar por uso direto em multiplos contextos, todos os dados de todos os projetos ficam comprometidos simultaneamente. Derivacao de sub-chaves isola o impacto: comprometer uma sub-chave nao compromete as demais. Com time pequeno e multiplos projetos, este isolamento e critico.

**Exemplo correto:**
```php
// Derivacao de sub-chave com contexto
$subchave = sodium_crypto_kdf_derive_from_key(
    SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_KEYBYTES, // 32 bytes
    $subchaveId,    // inteiro — identifica a finalidade (ex: 1 = financeiro, 2 = TOTP)
    'MeuApp__',     // contexto de 8 bytes, identifica a aplicacao
    $chaveMestra    // chave mestra do ambiente (exatamente 32 bytes)
);

$cifrado = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt($texto, '', $nonce, $subchave);
```

**Exemplo incorreto:**
```php
// Chave mestra usada diretamente — comprometimento total se vazar
$cifrado = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt($texto, '', $nonce, $chaveMestra);
```

### CRIPTO-006 — Contextos de derivacao distintos para cada finalidade [AVISO]

**Regra:** Cada uso criptografico (dados financeiros, TOTP secrets, tokens de sessao, dados de saude) deve usar um `subkey_id` diferente na derivacao, garantindo que a mesma chave mestra gere sub-chaves distintas e independentes.

**Verifica:** Listar todas as chamadas `_kdf_derive_from_key` e confirmar que cada finalidade usa `subkey_id` distinto. Nenhum ID repetido entre contextos diferentes.

**Por que na BGR:** A BGR trabalha com dados de naturezas diferentes (financeiros, educacionais, de saude) em projetos distintos. Reutilizar a mesma sub-chave para finalidades diferentes significa que um vazamento em um contexto compromete todos os outros. Contextos separados garantem isolamento criptografico entre dominios de negocio.

**Exemplo correto:**
```php
// Sub-chaves distintas por finalidade
$subchaveFinanceiro = sodium_crypto_kdf_derive_from_key(
    32, 1, 'MeuApp__', $chaveMestra  // subkey_id = 1 para dados financeiros
);
$subchaveSaude = sodium_crypto_kdf_derive_from_key(
    32, 2, 'MeuApp__', $chaveMestra  // subkey_id = 2 para dados de saude
);
```

**Exemplo incorreto:**
```php
// Mesma sub-chave para tudo — sem isolamento
$subchave = sodium_crypto_kdf_derive_from_key(32, 1, 'MeuApp__', $chaveMestra);
// usa $subchave para dados financeiros E dados de saude
```

---

## 4. Validacao de chave

### CRIPTO-007 — Chave mestra deve ter o tamanho exato exigido pelo algoritmo [ERRO]

**Regra:** O construtor da classe de criptografia deve validar que a chave mestra tem exatamente o tamanho exigido pelo algoritmo (32 bytes para Libsodium KDF). Caso contrario, lancar excecao fatal imediatamente. Nunca tentar corrigir (padding, hash, truncamento).

**Verifica:** Inspecionar construtor da classe de criptografia. Deve conter `mb_strlen($chave, '8bit') !== SODIUM_CRYPTO_KDF_KEYBYTES` com throw. Nenhum `str_pad` ou `hash()` corretivo.

**Por que na BGR:** Chave com tamanho errado indica erro de configuracao no deploy. Corrigir automaticamente (padding, hash) mascara o problema e enfraquece a criptografia. Na BGR, onde deploys sao feitos por time pequeno e frequentemente assistidos por IA, falhar ruidosamente no bootstrap e melhor que criptografar com chave malformada silenciosamente.

**Exemplo correto:**
```php
$chave = getenv('APP_ENCRYPTION_KEY');

if ($chave === false || $chave === '') {
    throw new ChaveCriptografiaAusenteException('APP_ENCRYPTION_KEY nao definida.');
}

if (mb_strlen($chave, '8bit') !== SODIUM_CRYPTO_KDF_KEYBYTES) {
    throw new ChaveCriptografiaAusenteException(
        'APP_ENCRYPTION_KEY deve ter exatamente ' . SODIUM_CRYPTO_KDF_KEYBYTES . ' bytes.'
    );
}
```

**Exemplo incorreto:**
```php
$this->chave = getenv('APP_ENCRYPTION_KEY');
// sem validacao de tamanho — aceita qualquer coisa

// ou pior — "corrige" silenciosamente
$this->chave = str_pad($chave, 32, "\0"); // padding com null bytes
$this->chave = hash('sha256', $chave, true); // hash para forcar 32 bytes
```

### CRIPTO-008 — Chave ausente interrompe o bootstrap [ERRO]

**Regra:** Se a chave de criptografia nao estiver definida ou for vazia, o sistema nao deve inicializar. A excecao deve ser capturada o mais cedo possivel (construtor da classe de criptografia ou bootstrap da aplicacao).

**Verifica:** Confirmar que o bootstrap ou construtor testa `getenv('APP_ENCRYPTION_KEY') === false || === ''` e lanca excecao. Nenhum fallback silencioso.

**Por que na BGR:** Um sistema que inicializa sem chave de criptografia pode gravar dados em texto plano no banco, criar uma janela de exposicao silenciosa. Na BGR, dados sensiveis (financeiros, saude) sao criptografados na camada de repositorio — se o repositorio funcionar sem criptografia, os dados ficam expostos sem que ninguem perceba ate a proxima auditoria.

**Exemplo correto:**
```php
// No bootstrap da aplicacao
$chave = getenv('APP_ENCRYPTION_KEY');
if ($chave === false || $chave === '') {
    throw new ChaveCriptografiaAusenteException(
        'APP_ENCRYPTION_KEY nao definida. Sistema nao pode inicializar sem chave de criptografia.'
    );
}
```

**Exemplo incorreto:**
```php
// Sistema inicializa normalmente sem chave — dados gravados em texto plano
$chave = getenv('APP_ENCRYPTION_KEY');
if (empty($chave)) {
    error_log('Aviso: chave de criptografia nao configurada');
    // continua executando sem criptografia...
}
```

---

## 5. Versionamento de ciphertext

### CRIPTO-009 — Todo ciphertext deve ter prefixo de versao [ERRO]

**Regra:** Para permitir rotacao de chave e migracao de algoritmo sem quebrar dados existentes, todo dado criptografado deve comecar com um prefixo de versao seguido de separador. O formato do prefixo e livre (ex.: `v1|`, `v2|`), mas deve ser consistente dentro do projeto.

**Verifica:** Inspecionar saida da funcao `criptografar()`. Deve iniciar com prefixo de versao (ex.: `v1|`). Buscar `str_starts_with` ou equivalente na funcao `descriptografar()`.

**Por que na BGR:** A BGR tem projetos de longa duracao onde algoritmos e chaves vao mudar ao longo do tempo. Sem prefixo de versao, e impossivel saber qual chave ou algoritmo usar para descriptografar um dado antigo. Isso travaria migracoes e tornaria a rotacao de chave um pesadelo operacional para um time pequeno.

**Exemplo correto:**
```php
// Gravar com versao
$encoded = 'v1|' . base64_encode($nonce) . '|' . base64_encode($cifrado);

// Ler com deteccao de versao
if (str_starts_with($textoCifrado, 'v1|')) {
    // descriptografar com algoritmo v1
} elseif (str_starts_with($textoCifrado, 'v2|')) {
    // descriptografar com algoritmo v2
} else {
    throw new CriptografiaException('Versao de ciphertext desconhecida.');
}
```

**Exemplo incorreto:**
```php
// Sem prefixo — impossivel saber qual algoritmo/chave usar
$encoded = base64_encode($nonce) . base64_encode($cifrado);
```

### CRIPTO-010 — Migracao gradual de dados legados [AVISO]

**Regra:** Dados criptografados com algoritmo ou chave anterior devem ser re-criptografados com o algoritmo/chave atual quando lidos e regravados. Isso permite migracao organica sem script de migracao em massa. A leitura com algoritmo legado deve emitir log de aviso em ambiente de desenvolvimento.

**Verifica:** Confirmar que o repositorio, ao ler dados com versao anterior, re-criptografa e regrava com a versao atual. Metodo `eraLegado()` ou equivalente deve existir.

**Por que na BGR:** Scripts de migracao em massa em projetos com dados sensiveis sao arriscados — exigem janela de manutencao, rollback complexo e teste extensivo. Na BGR, com time pequeno, migracao organica (re-criptografar ao ler/regravar) distribui o risco ao longo do tempo e nao exige coordenacao operacional especial.

**Exemplo correto:**
```php
public function buscarPorId(int $id): ?Entidade
{
    $row = $this->db->get($id);
    $dados = $this->cripto->descriptografar($row->dados_cifrados);

    // Se era legado, regravar com algoritmo atual
    if ($this->cripto->eraLegado()) {
        $row->dados_cifrados = $this->cripto->criptografar($dados);
        $this->db->update($id, $row);
    }

    return Entidade::fromRow($row, $dados);
}
```

**Exemplo incorreto:**
```php
// Script de migracao em massa — arriscado, requer downtime
foreach ($this->db->todos() as $row) {
    $dados = $this->criptoAntiga->descriptografar($row->dados_cifrados);
    $row->dados_cifrados = $this->criptoNova->criptografar($dados);
    $this->db->update($row->id, $row);
}
```

---

## 6. Rotacao de chave

### CRIPTO-011 — Suporte a multiplas versoes de chave simultaneas [AVISO]

**Regra:** O sistema deve suportar pelo menos duas versoes de chave ativas ao mesmo tempo (atual + anterior), permitindo rotacao sem downtime. O prefixo de versao (CRIPTO-009) identifica qual chave usar na descriptografia.

**Verifica:** Confirmar que a classe de criptografia aceita pelo menos 2 chaves (atual + anterior). Metodo de descriptografia deve selecionar chave pelo prefixo de versao.

**Por que na BGR:** A BGR nao tem equipe de operacoes dedicada. Rotacao de chave que exige downtime ou migracao coordenada e inviavel para um time pequeno. Suportar duas chaves simultaneas permite rotacao transparente: dados novos usam a chave nova, dados antigos continuam legiveis pela chave anterior.

**Exemplo correto:**
```php
class GerenciadorChaves
{
    public function chaveParaDescriptografar(string $versao): string
    {
        return match ($versao) {
            'v2' => $this->chaveAtual,
            'v1' => $this->chaveAnterior,
            default => throw new CriptografiaException("Versao de chave desconhecida: {$versao}"),
        };
    }

    public function chaveParaCriptografar(): string
    {
        return $this->chaveAtual; // sempre criptografa com a mais recente
    }
}
```

**Exemplo incorreto:**
```php
// Apenas uma chave — rotacao quebra todos os dados antigos
class Cripto
{
    public function __construct(private string $chave) {}
    // quando a chave muda, dados antigos ficam ilegiveis
}
```

### CRIPTO-012 — Rotacao nao requer re-encrypt em massa [AVISO]

**Regra:** Ao rotacionar a chave mestra, apenas novos dados e dados regravados usam a nova chave. Dados antigos permanecem legiveis pela chave anterior ate serem organicamente regravados (ver CRIPTO-010).

**Verifica:** Confirmar que nao existe script de re-encrypt em massa. Criptografia sempre usa chave atual; descriptografia aceita chave anterior via prefixo.

**Por que na BGR:** Re-encrypt em massa de dados sensiveis exige janela de manutencao, plano de rollback e testes extensivos — recursos que um time pequeno nao tem para mobilizar com frequencia. Rotacao organica distribui o custo ao longo do tempo e elimina o risco de corrompimento em massa.

**Exemplo correto:**
```php
// Rotacao: adicionar nova chave, manter a anterior
// .env
// APP_ENCRYPTION_KEY=nova_chave_32_bytes_aqui_______
// APP_ENCRYPTION_KEY_PREVIOUS=chave_anterior_32_bytes_aqui___

// Dados novos: criptografados com APP_ENCRYPTION_KEY (v2)
// Dados antigos: descriptografados com APP_ENCRYPTION_KEY_PREVIOUS (v1)
// Dados regravados: re-criptografados com APP_ENCRYPTION_KEY (v2)
```

**Exemplo incorreto:**
```php
// Rotacao com migracao forcada — risco operacional
// 1. Parar o sistema
// 2. Rodar script de re-encrypt em todos os registros
// 3. Trocar a chave
// 4. Reiniciar e torcer para funcionar
```

---

## 7. Gestao de memoria

### CRIPTO-013 — Limpar chaves da memoria apos uso [AVISO]

**Regra:** Chaves e sub-chaves devem ser zeradas da memoria apos cada operacao de criptografia/descriptografia. Em PHP, usar `sodium_memzero()`. Em outras linguagens, usar o equivalente da biblioteca criptografica.

**Verifica:** Buscar `sodium_memzero` apos cada uso de sub-chave. Toda variavel `$subchave`/`$dek` deve ser zerada antes do return.

**Por que na BGR:** Em ambientes compartilhados (hospedagem, containers), um dump de memoria pode expor chaves que permaneceram apos o uso. Na BGR, onde projetos rodam em infraestrutura variada (servidores proprios, cloud, containers), limpar chaves da memoria reduz a janela de exposicao independentemente do ambiente.

**Exemplo correto:**
```php
$subchave = sodium_crypto_kdf_derive_from_key(
    SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_KEYBYTES,
    $subchaveId, 'MeuApp__', $chaveMestra
);
$cifrado = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt($texto, '', $nonce, $subchave);
sodium_memzero($subchave); // sub-chave zerada imediatamente apos uso
```

**Exemplo incorreto:**
```php
$subchave = sodium_crypto_kdf_derive_from_key(/* ... */);
$cifrado = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt($texto, '', $nonce, $subchave);
// $subchave permanece na memoria ate o garbage collector — janela de exposicao
```

### CRIPTO-014 — Nunca logar chaves, sub-chaves ou nonces [ERRO]

**Regra:** Proibido incluir material criptografico (chaves, sub-chaves, nonces, ciphertexts parciais) em logs, error_log, var_dump, debug_backtrace, print_r, saida de console ou qualquer mecanismo de diagnostico.

**Verifica:** Buscar `error_log`, `var_dump`, `print_r`, `console.log`, `debug_backtrace` proximo a variaveis `$chave`, `$subchave`, `$nonce`, `$dek`, `$kek`, `$cifrado`.

**Por que na BGR:** Logs sao frequentemente armazenados em texto plano, replicados para servicos de monitoramento e retidos por longos periodos. Com desenvolvimento assistido por IA, e comum que sugestoes de debug incluam `var_dump($chave)` ou `console.log(key)` — esta regra funciona como barreira explicita contra esse tipo de vazamento acidental.

**Exemplo correto:**
```php
// Log sem material criptografico
error_log('Criptografia: falha na descriptografia do registro ID=' . $id);
error_log('Criptografia: tamanho da chave invalido');
```

**Exemplo incorreto:**
```php
// VAZAMENTO — chave em log
error_log('Chave usada: ' . bin2hex($chave));
var_dump($subchave);
error_log('Nonce: ' . base64_encode($nonce) . ' | Cifrado: ' . base64_encode($cifrado));
```

---

## 8. Envelope encryption (evolucao futura)

### CRIPTO-015 — Dados criptografados com DEK, DEK protegida por KEK [AVISO]

**Regra:** Para escala futura, cada registro (ou grupo de registros) deve ser criptografado com uma **Data Encryption Key (DEK)** unica, e a DEK deve ser criptografada pela **Key Encryption Key (KEK)** mestra. Isso permite rotacao de KEK sem re-encrypt de todos os dados.

**Verifica:** Se envelope encryption implementado: confirmar que cada registro tem DEK propria criptografada pela KEK. Coluna `dek_cifrada` deve existir junto a `dados_cifrados`.

**Por que na BGR:** A medida que os projetos da BGR crescem e acumulam mais dados sensiveis, rotacionar a chave mestra se torna progressivamente mais caro se cada registro usa a mesma chave. Envelope encryption isola o custo de rotacao: trocar a KEK so exige re-criptografar as DEKs (pequenas), nao os dados (grandes).

**Exemplo correto:**
```php
// Criptografar com envelope encryption
$dek = random_bytes(32); // DEK unica para este registro
$dadosCifrados = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
    $dados, '', $nonceDados, $dek
);
$dekCifrada = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
    $dek, '', $nonceDek, $kek
);
sodium_memzero($dek);

// Armazenar: dek_cifrada + dados_cifrados
```

**Exemplo incorreto:**
```php
// Todos os registros criptografados com a mesma chave diretamente
// Rotacao de chave exige re-criptografar TODOS os registros
$cifrado = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
    $dados, '', $nonce, $chaveMestra
);
```

**Excecoes:** A implementacao atual com chave mestra + KDF (CRIPTO-005) e aceitavel para volumes moderados de dados. Envelope encryption deve ser implementada quando o volume justificar.

### CRIPTO-016 — DEK deve ser unica por registro ou por lote [AVISO]

**Regra:** Se envelope encryption for implementada, cada DEK deve ser gerada com o CSPRNG da linguagem (ex.: `random_bytes(32)` em PHP) e nunca reutilizada entre registros ou tabelas diferentes.

**Verifica:** Confirmar que `random_bytes(32)` e chamado dentro do loop de gravacao (nova DEK por registro). Nenhuma variavel `$dek` definida fora do loop.

**Por que na BGR:** Reutilizar DEKs entre registros anula o beneficio do envelope encryption: comprometer uma DEK expoe multiplos registros. Na BGR, dados de naturezas diferentes (financeiro, saude, educacional) devem ter isolamento criptografico total — uma DEK por registro garante que o comprometimento de um registro nao afeta os demais.

**Exemplo correto:**
```php
// DEK unica para cada registro
foreach ($registros as $registro) {
    $dek = random_bytes(32); // nova DEK para cada registro
    $cifrado = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
        $registro->dados(), '', random_bytes(24), $dek
    );
    $dekCifrada = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
        $dek, '', random_bytes(24), $kek
    );
    sodium_memzero($dek);
    $this->salvar($registro->id(), $dekCifrada, $cifrado);
}
```

**Exemplo incorreto:**
```php
// Mesma DEK para todos os registros — sem isolamento
$dek = random_bytes(32);
foreach ($registros as $registro) {
    $cifrado = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
        $registro->dados(), '', random_bytes(24), $dek
    );
    // mesma $dek reutilizada — comprometer uma expoe todas
}
```

---

## 9. Camada de criptografia e interface

### CRIPTO-017 — Todo campo sensivel deve ser criptografado em repouso [ERRO]

**Regra:** Campos que contem dados sensiveis (financeiros, de saude, educacionais, pessoais identificaveis) devem ser armazenados criptografados no banco de dados. O tipo da coluna deve acomodar ciphertext de tamanho variavel (ex.: `TEXT` em SQL, nunca `VARCHAR` com limite fixo).

**Verifica:** Listar colunas sensiveis no schema. Tipo deve ser `TEXT` (nao `VARCHAR`). Dados gravados devem ter prefixo de versao (indicando ciphertext).

**Por que na BGR:** A BGR trabalha com dados financeiros pessoais, dados de saude e dados educacionais — todos sujeitos a regulamentacoes de protecao de dados (LGPD). Em caso de vazamento do banco (SQL injection, backup exposto, acesso indevido), dados criptografados em repouso sao ilegiveis sem a chave. Esta e a ultima linha de defesa.

**Exemplo correto:**
```php
// Repositorio criptografa antes de gravar
private function criptografarDados(Entidade $entidade): array
{
    return [
        'descricao' => $this->cripto->criptografar($entidade->descricao()),
        'valor'     => $this->cripto->criptografar((string) $entidade->valor()),
    ];
}

// Coluna no banco: TEXT (acomoda ciphertext de qualquer tamanho)
```

**Exemplo incorreto:**
```php
// Dado sensivel gravado em texto plano
$this->db->insert('registros', [
    'descricao' => $entidade->descricao(),  // texto plano no banco
    'valor'     => $entidade->valor(),       // texto plano no banco
]);

// Ou coluna VARCHAR(255) — pode truncar ciphertext
```

### CRIPTO-018 — Criptografia/descriptografia apenas na camada de persistencia [ERRO]

**Regra:** A criptografia e descriptografia de campos acontece exclusivamente na camada de persistencia (repositorio, DAO), nos metodos de gravacao e hidratacao. Camadas superiores (entidades, servicos, controllers, handlers) nunca manipulam dados criptografados diretamente.

**Verifica:** Buscar `->criptografar(` e `->descriptografar(` fora de arquivos `*Repository*`/`*Repo*`/`*DAO*`. Nenhum handler, servico ou entidade deve chamar essas funcoes.

**Por que na BGR:** Concentrar criptografia no repositorio cria um unico ponto de auditoria. Se criptografia estiver espalhada em handlers, servicos e entidades, e impossivel garantir que todos os caminhos estao corretos — especialmente com desenvolvimento assistido por IA, onde cada sugestao de codigo pode introduzir um caminho sem criptografia. Um ponto unico = uma auditoria.

**Exemplo correto:**
```php
// Repositorio criptografa ao gravar
public function salvar(Entidade $entidade): void
{
    $this->db->insert('tabela', [
        'descricao' => $this->cripto->criptografar($entidade->descricao()),
        'valor'     => $this->cripto->criptografar((string) $entidade->valor()),
    ]);
}

// Repositorio descriptografa ao ler
public function buscarPorId(int $id): ?Entidade
{
    $row = $this->db->get($id);
    return Entidade::fromRow(
        $this->cripto->descriptografar($row->descricao),
        $this->cripto->descriptografar($row->valor),
    );
}
```

**Exemplo incorreto:**
```php
// Handler manipula criptografia — errado, camada incorreta
public function handleCriar(): void
{
    $valor = $this->cripto->criptografar($_POST['valor']); // ERRADO
    $this->servico->criar($valor);
}
```

### CRIPTO-019 — Interface segregada para testabilidade [ERRO]

**Regra:** A classe de criptografia deve implementar uma interface. Todas as dependencias apontam para a interface, nunca para a implementacao concreta. Testes usam mock ou implementacao fake da interface.

**Verifica:** Confirmar que existe `CriptografiaInterface` (ou equivalente). Type hints em construtores devem apontar pra interface, nao pra classe concreta.

**Por que na BGR:** Repositorios que dependem de uma classe concreta de criptografia nao podem ser testados unitariamente sem chave real e extensao Sodium instalada. Na BGR, testes devem rodar rapido e sem dependencias de infraestrutura. Interface segregada permite mock que retorna o dado sem criptografia, isolando o comportamento do repositorio.

**Exemplo correto:**
```php
// Interface
interface CriptografiaInterface
{
    public function criptografar(string $texto): string;
    public function descriptografar(string $cifrado): string;
}

// Repositorio depende da interface
public function __construct(
    private readonly PDO $db,
    private readonly CriptografiaInterface $cripto,
) {}
```

**Exemplo incorreto:**
```php
// Dependencia concreta — impossivel mockar sem a extensao real
public function __construct(
    private readonly PDO $db,
    private readonly Criptografia $cripto, // classe concreta
) {}
```

---

## 10. Nonce e aleatoriedade

### CRIPTO-020 — Nonce gerado com CSPRNG [ERRO]

**Regra:** O nonce (numero usado uma vez) deve ser gerado exclusivamente com o CSPRNG (Cryptographically Secure Pseudo-Random Number Generator) da linguagem. Em PHP, usar `random_bytes()`. Proibido: `rand()`, `mt_rand()`, `uniqid()`, timestamp, contador previsivel, ou qualquer fonte nao criptograficamente segura.

**Verifica:** Buscar atribuicao de `$nonce`. Deve ser `random_bytes(SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_NPUBBYTES)`. Nenhum `rand()`, `mt_rand()`, `uniqid()`, `time()`.

**Por que na BGR:** Nonce previsivel combinado com chave fixa permite ataques de recuperacao de plaintext. Com desenvolvimento assistido por IA, e comum que sugestoes usem `uniqid()` ou `mt_rand()` para gerar "algo aleatorio" — estas funcoes nao sao criptograficamente seguras. Esta regra e uma barreira explicita contra sugestoes automaticas perigosas.

**Exemplo correto:**
```php
// CSPRNG — 24 bytes para XChaCha20
$nonce = random_bytes(SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_NPUBBYTES);
```

**Exemplo incorreto:**
```php
// Previsivel — NAO e CSPRNG
$nonce = md5(uniqid());           // previsivel, apenas 16 bytes
$nonce = random_bytes(16);         // tamanho errado para XChaCha20 (precisa 24)
$nonce = pack('P', time());        // timestamp — completamente previsivel
$nonce = str_pad((string)$id, 24); // derivado de dado previsivel
```

### CRIPTO-021 — Nonce nunca reutilizado com a mesma chave [ERRO]

**Regra:** O nonce deve ser gerado aleatoriamente a cada operacao de criptografia. Nunca armazenar e reutilizar um nonce, nunca derivar de dados previsiveis. Com XChaCha20 e nonce de 24 bytes, a probabilidade de colisao e negligivel para volumes normais se gerado via CSPRNG.

**Verifica:** Confirmar que `random_bytes()` e chamado dentro do metodo `criptografar()`, nao no construtor ou como propriedade de classe. Nenhum `$this->nonce` reutilizado.

**Por que na BGR:** Reutilizacao de nonce com a mesma chave em XChaCha20-Poly1305 permite recuperacao do keystream por XOR dos ciphertexts. Na BGR, onde dados financeiros e de saude sao criptografados, esta vulnerabilidade permitiria a um atacante com acesso ao banco recuperar dados sensiveis sem a chave.

**Exemplo correto:**
```php
// Nonce novo a cada operacao
public function criptografar(string $texto): string
{
    $nonce = random_bytes(SODIUM_CRYPTO_AEAD_XCHACHA20POLY1305_IETF_NPUBBYTES);
    $cifrado = sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
        $texto, '', $nonce, $this->subchave
    );
    return 'v1|' . base64_encode($nonce) . '|' . base64_encode($cifrado);
}
```

**Exemplo incorreto:**
```php
// Nonce fixo reutilizado — vulnerabilidade critica
private string $nonce;

public function __construct()
{
    $this->nonce = random_bytes(24); // gerado uma vez, reutilizado sempre
}

public function criptografar(string $texto): string
{
    // mesmo nonce + mesma chave para todos os textos = keystream recovery
    return sodium_crypto_aead_xchacha20poly1305_ietf_encrypt(
        $texto, '', $this->nonce, $this->subchave
    );
}
```

---

## 11. Documentacao e versionamento

> **Nota:** Os principios expressos nos exemplos PHP deste documento aplicam-se universalmente. Em outras linguagens, usar a biblioteca criptografica equivalente (libsodium bindings, NaCl, Web Crypto API) seguindo os mesmos principios: algoritmos modernos, AEAD, KDF, nonce via CSPRNG, interface segregada.

---

## Definition of Done — Checklist de entrega

> PR que nao cumpre o DoD nao entra em review. E devolvido.

| # | Item | Regras | Verificacao |
|---|------|--------|-------------|
| 1 | Nenhum algoritmo obsoleto ou caseiro no codigo | CRIPTO-001, CRIPTO-002 | Buscar por `openssl_encrypt`, `mcrypt_*`, `des`, `rc4`, `md5` no codigo |
| 2 | Toda criptografia usa AEAD | CRIPTO-003 | Verificar que toda chamada de criptografia usa funcoes AEAD |
| 3 | Falha de descriptografia lanca excecao tipada | CRIPTO-004 | Verificar que retorno `false` nunca e ignorado |
| 4 | Chave mestra nunca usada diretamente | CRIPTO-005 | Buscar usos diretos da variavel de chave mestra em funcoes de criptografia |
| 5 | Chave validada no bootstrap | CRIPTO-007, CRIPTO-008 | Verificar validacao de tamanho e presenca no construtor |
| 6 | Ciphertext tem prefixo de versao | CRIPTO-009 | Inspecionar formato de saida da funcao de criptografia |
| 7 | Material criptografico ausente de logs | CRIPTO-014 | Buscar por `error_log`, `var_dump`, `print_r`, `console.log` proximo a variaveis de chave |
| 8 | Campos sensiveis criptografados no banco | CRIPTO-017 | Verificar que colunas sensiveis sao tipo TEXT e dados sao criptografados |
| 9 | Criptografia apenas no repositorio | CRIPTO-018 | Verificar que handlers, servicos e entidades nao chamam funcoes de criptografia |
| 10 | Dependencia via interface, nao classe concreta | CRIPTO-019 | Verificar type hints nos construtores |
| 11 | Nonce gerado com CSPRNG e tamanho correto | CRIPTO-020 | Verificar uso de `random_bytes()` com constante de tamanho |
| 12 | Nonce nunca reutilizado | CRIPTO-021 | Verificar que nonce e gerado dentro do metodo de criptografia, nao armazenado |
| 13 | Sub-chaves limpas da memoria | CRIPTO-013 | Verificar chamadas a `sodium_memzero()` apos uso |
| 14 | Contextos de derivacao distintos por finalidade | CRIPTO-006 | Verificar que cada uso tem subkey_id diferente |
| 15 | Testes usam mock da interface de criptografia | CRIPTO-019 | Verificar que testes nao dependem de chave real ou extensao Sodium |
