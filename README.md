# hbRails Releases

> **Core 0.1.0-dev.8.18 — Linux ARM64:** prerelease com correção do rebuild incremental
> de Views, Partials e Layouts. Invalidação seletiva preserva módulos independentes
> e builds sem alterações. Manager **0.1.0-dev.2** preservado.
> [Notas e sete assets da dev.8.18](https://github.com/hbrails/hbrails-releases/releases/tag/v0.1.0-dev.8.18).

Canal público de distribuição do **hbRails**: Core, feature oficial Mail,
Manager, bootstrap e checksums. Não é necessário o checkout privado para usar
os pacotes. O instalador da raiz seleciona **0.1.0-dev.8.18 por padrão**.

## Instalação normal — Linux ARM64

Baixe novamente o bootstrap vigente e execute em sua conta:

```sh
curl -fsSL https://raw.githubusercontent.com/hbrails/hbrails-releases/main/install.sh -o install-hbrails.sh
sh ./install-hbrails.sh
export PATH="$HOME/.local/bin:$PATH"
hash -r
hbrails --version
hbrails versions
```

Para selecionar explicitamente esta versão, use `sh ./install-hbrails.sh 0.1.0-dev.8.18`.
Uma cópia antiga do script não se atualiza sozinha. Para reproduzir os bytes
versionados da dev.8.18:

```sh
curl -fsSL https://github.com/hbrails/hbrails-releases/releases/download/v0.1.0-dev.8.18/install.sh -o install-dev818.sh
sha256sum install-dev818.sh
# Esperado: eed0ff398673b5ced1206051dcffe46809bcb99f11c0be68cb4fdd2cb7c68475
sh ./install-dev818.sh 0.1.0-dev.8.18
```

O bootstrap confere checksum e arquitetura física do Manager antes de executá-lo.
O Manager valida o pacote antes da ativação. Combinações indisponíveis são
rejeitadas sem fallback para outra versão ou arquitetura. Não misture targets
no mesmo prefixo.

## Requisitos e limites

- Esta prerelease oferece exclusivamente `linux-aarch64` (Linux ARM64/AArch64).
- Core e Manager exigem GLIBC **2.38 ou superior**, `libm.so.6`, `libc.so.6` e
  loader `ld-linux-aarch64.so.1`; Mail utiliza `libcurl.so.4` e suas dependências.
- Bootstrap: shell POSIX, uname, curl com HTTPS, sha256sum, od e utilitários comuns.
- Build de aplicações: Harbour/hbmk2 r2607071000 e toolchain compatível com o
  perfil qualificado `linux-aarch64|harbour-r2607071000|gcc-15.2.0|binutils-2.46`.
  A validação utilizou GCC Ubuntu 15.2.0-16ubuntu1 e binutils 2.46.
- Bibliotecas/headers de desenvolvimento devem ser preparados conforme a política
  do seu ambiente; em Debian/Ubuntu, incluem zlib1g-dev e libcurl4-openssl-dev.
  O instalador não instala dependências do sistema.

Validação técnica Linux ARM64 concluída nas condições das notas. **Homologação
em outra VM permanece pendente**. A arquitetura sozinha não garante compatibilidade;
esta publicação não qualifica outras plataformas nem representa versão estável.

## Criar e validar uma aplicação

Em diretório próprio, com nome de aplicação ainda inexistente:

```sh
hbrails new native_review
cd native_review
hbrails version use 0.1.0-dev.8.18
hbrails info
hbrails doctor --details
hbrails build
hbrails routes
HBRAILS_ENV=development HBRAILS_HOST=127.0.0.1 HBRAILS_PORT=3103 hbrails server
```

Na mesma VM, abra `http://127.0.0.1:3103/` e `/status`. Encerre o servidor próprio
com Ctrl-C. Views, Partials e Layouts são compilados no build; mudanças normais
são incorporadas pelo build incremental sem exigir `--force`. Configuração e
logs da aplicação permanecem em `config/application.prg` e `log/`.

## Feature oficial Mail

Na raiz da aplicação:

```sh
hbrails features
hbrails feature add mail
hbrails feature info mail
hbrails build
```

Mail tem pacote separado e vínculo com a identidade pública exata do Core.
Use somente o conjunto correspondente à versão selecionada. A configuração
SMTP pertence à aplicação; adicionar a feature não autoriza envio de mensagens.
Para remover a composição, use `hbrails feature remove mail` e faça novo build.

## Versões preservadas

| Versão | Target | Estado |
| --- | --- | --- |
| [0.1.0-dev.8.18](https://github.com/hbrails/hbrails-releases/releases/tag/v0.1.0-dev.8.18) | linux-aarch64 | Prerelease vigente para homologação externa |
| [0.1.0-dev.8.17](https://github.com/hbrails/hbrails-releases/releases/tag/v0.1.0-dev.8.17) | linux-aarch64 | Anterior preservada |
| [0.1.0-dev.8.16](https://github.com/hbrails/hbrails-releases/releases/tag/v0.1.0-dev.8.16) | linux-aarch64 | Anterior preservada |
| [0.1.0-dev.8.15](https://github.com/hbrails/hbrails-releases/releases/tag/v0.1.0-dev.8.15) | linux-aarch64 | Anterior preservada |
| [0.1.0-dev.8.14](https://github.com/hbrails/hbrails-releases/releases/tag/v0.1.0-dev.8.14) | linux-aarch64 | Anterior preservada |
| [0.1.0-dev.8.13](https://github.com/hbrails/hbrails-releases/releases/tag/v0.1.0-dev.8.13) | linux-aarch64 | Anterior preservada |
| [0.1.0-dev.8.12](https://github.com/hbrails/hbrails-releases/releases/tag/v0.1.0-dev.8.12) | linux-aarch64 | Anterior preservada |
| [0.1.0-dev.8.11](https://github.com/hbrails/hbrails-releases/releases/tag/v0.1.0-dev.8.11) | linux-x86_64 | Histórico preservado; sem nova qualificação nesta publicação |

Para rollback em prefixo compatível, execute o bootstrap com a versão anterior
explicitamente. Para selecionar a versão de um projeto, use `hbrails version use`;
essa seleção não troca o padrão da conta. Os sete arquivos de cada release e
as identidades correspondentes permanecem imutáveis.
