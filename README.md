# hbRails Releases

Canal público de distribuição do **hbRails**: pacotes binários, Manager,
bootstrap e checksums. Os fontes internos do framework não fazem parte deste canal.

## Versões e arquiteturas

| Versão | Target disponível | Estado |
|---|---|---|
| [0.1.0-dev.8.13](https://github.com/hbrails/hbrails-releases/releases/tag/v0.1.0-dev.8.13) | `linux-aarch64` (ARM64/AArch64) | Prerelease para homologação humana; validação técnica concluída nas condições das notas |
| [0.1.0-dev.8.12](https://github.com/hbrails/hbrails-releases/releases/tag/v0.1.0-dev.8.12) | `linux-aarch64` | Prerelease anterior preservada |
| [0.1.0-dev.8.11](https://github.com/hbrails/hbrails-releases/releases/tag/v0.1.0-dev.8.11) | `linux-x86_64` | Prerelease anterior preservada |

A dev.8.13 **não oferece novos assets x86-64**. Não misture arquiteturas no
mesmo prefixo. ARM64 não é declarado suporte oficialmente homologado antes da
revisão e homologação humana deste conjunto. Confira a seção Releases para o
estado da publicação e os sete assets de cada versão.

## Instalação normal — bootstrap vigente

Baixe novamente o script mantido na raiz deste canal:

```sh
curl -fsSL https://raw.githubusercontent.com/hbrails/hbrails-releases/main/install.sh -o install-hbrails.sh
sh ./install-hbrails.sh 0.1.0-dev.8.13
export PATH="$HOME/.local/bin:$PATH"
hash -r
hbrails --version
hbrails versions
```

Esse exemplo é para a candidata **ARM64**. Para Linux x86-64, selecione
explicitamente a versão disponível `0.1.0-dev.8.11` no mesmo script vigente.
Ele detecta Linux `x86_64` ou `aarch64`/`arm64`, escolhe o Manager correspondente,
confere checksum e arquitetura física antes de executar e instala o Core
compatível. Uma combinação ausente gera diagnóstico com versão e target;
não há fallback para outra arquitetura ou versão.

Uma cópia antiga já baixada não se atualiza sozinha: use a URL canônica acima.
Ela pode evoluir; para reproduzir exatamente a dev.8.13 use o asset versionado:

```sh
curl -fsSL https://github.com/hbrails/hbrails-releases/releases/download/v0.1.0-dev.8.13/install.sh -o install-hbrails-dev813.sh
sh ./install-hbrails-dev813.sh 0.1.0-dev.8.13
```

Requer shell POSIX, uname, curl com HTTPS, sha256sum, od e utilitários comuns.
O Manager/Core precisam das bibliotecas runtime compatíveis (glibc, libm e zlib;
Mail também usa libcurl). Não executamos instalação de dependências do sistema.

**Para compilar aplicações:** Harbour/hbmk2 r2607071000 e toolchain compatível,
incluindo bibliotecas/headers de desenvolvimento necessários. A candidata ARM64
foi avaliada em Linux AArch64/Ubuntu 26.04 com GCC Ubuntu 15.2.0-16ubuntu1 e
binutils 2.46. Não se presume funcionamento em qualquer ARM64. Em sistemas
Debian/Ubuntu, os pacotes de desenvolvimento relevantes incluem `zlib1g-dev` e
`libcurl4-openssl-dev`; prepare-os conforme a política do seu ambiente.

## Criar e validar uma aplicação

Em pasta de trabalho própria e sem destino preexistente:

```sh
hbrails new native_review
cd native_review
hbrails version use 0.1.0-dev.8.13
hbrails info
hbrails doctor --details
hbrails build
hbrails routes
HBRAILS_ENV=development HBRAILS_HOST=127.0.0.1 HBRAILS_PORT=3103 hbrails server
```

Abra `http://127.0.0.1:3103/` no navegador da máquina que executa o servidor.
Acompanhe `tail -F log/development.log` em outro terminal. O scaffold entrega
configuração comum explícita em `config/application.prg`; mudanças de PRG
exigem build. Não é necessário configurar store experimental ou localizar CLI
candidata. Em Doctor, Manager dev.2 e Core dev.8.13 têm identidades distintas.

Registre a homologação humana por cenário. SMTP externo, HTTPS público da
aplicação e Docker não foram verificados nesta rodada; validação técnica não
substitui esse aceite. A aplicação serve HTTP; download HTTPS não comprova
HTTPS do servidor da aplicação.

## Integridade, seleção e recuperação

Confira os sidecars SHA-256 antes de uso e preserve os bytes dos assets.
O set tem sete arquivos: Core/checksum, Mail/checksum, Manager/checksum e
`install.sh`; manifestos/proveniência ficam dentro dos archives. Mail é opcional
e vinculado ao Core exato, adquirido por `hbrails feature add mail` quando usado.

`hbrails versions` lista instalações válidas. Dentro de uma aplicação,
`hbrails version use <versão>` seleciona uma versão compatível já instalada;
fora de aplicação, altera o default conforme o contrato do Manager. A seleção
não instala versões ausentes nem troca sua arquitetura. Não existe release
ARM64 anterior homologada para afirmar rollback histórico nesta primeira oferta.
As provas técnicas de A→B→A usam uma fixture real identificada.

A instalação valida antes da ativação e preserva launcher/default em falhas.
Depois de interrupção, repita a instalação explícita da mesma versão/bytes para
recuperar pelo fluxo normal. Versões são imutáveis: não sobrescreva o mesmo
número com arquivos diferentes nem apague o store para contornar validação.

## English summary

This is the public binary release channel. Download the **current** root
`install.sh` using the canonical raw URL above and pass an explicit version.
The bootstrap selects the native Linux Manager, verifies its checksum and ELF
architecture, and rejects unavailable version/target combinations clearly.

Version 0.1.0-dev.8.13 provides Linux AArch64 assets as a **prerelease pending
human homologation**, with Manager 0.1.0-dev.2. Version 0.1.0-dev.8.11 remains
the previous Linux x86_64 offering. No new x86_64 dev.8.13 assets are claimed.
A previously downloaded script does not update itself. System/build prerequisites
and the unverified SMTP, application HTTPS and Docker scenarios are described
above and in the release notes. No internal source checkout or experimental
framework store is required to consume the packages.


## Core dev.8.13: validação e dados por ambiente

`HBR_IsValidEmail( cEmail )` valida localmente endereços ASCII convencionais com
domínio pontuado, sem DNS/SMTP. Endereço até 254 bytes, parte local até 64 e
rótulos do domínio até 63; rejeita @ ausente/duplicado, pontos inválidos,
rótulos vazios e hífen nas extremidades. Não comprova existência ou entrega.

JSONL agora usa `storage/data/<ambiente>/<recurso>.jsonl`. A identidade vem do
ambiente registrado e validado do app; ausência de HBRAILS_ENV seleciona
development. Ambientes personalizados seguem a mesma regra. O arquivo legado
`storage/data/<recurso>.jsonl` permanece intacto e não é fallback do novo adapter.

### Migração manual do legado

Pare os escritores, faça backup e identifique o ambiente real dos dados. Se o
arquivo misturar ambientes, separe/revise registros em cópias. Não presuma que
seja development. Confira UTF-8, um objeto JSON por linha e LF na última linha.
O exemplo abaixo é executado na raiz da aplicação; altere o ambiente conforme
a origem dos dados. Ele preserva o legado e recusa destinos existentes:

```sh
(
    set -eu
    ambiente=development
    legado=storage/data/leads.jsonl
    destino="storage/data/$ambiente/leads.jsonl"
    backup=storage/migration-backup/leads.legacy.jsonl
    test -f "$legado"
    test ! -e "$destino"
    test ! -e "$backup"
    mkdir -p "storage/data/$ambiente" storage/migration-backup
    cp -p --no-clobber -- "$legado" "$backup"
    cmp -- "$legado" "$backup"
    cp -p --no-clobber -- "$legado" "$destino"
    cmp -- "$legado" "$destino"
)
```

Não sobrescreva ou concatene cegamente um destino existente. Selecione a nova
versão no app e recompile antes de usar o novo caminho. Executáveis antigos
continuam no caminho legado; não há sincronização ou rollback automático de
dados. Teste com HBRAILS_ENV=test, que grava somente em storage/data/test;
limpar esse diretório, com os processos parados, preserva os outros ambientes.
