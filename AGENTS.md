# AGENTS.md

Guia específico deste repositório. Leia também `.cursor/rules/cursorrule.mdc` — aplica-se sempre.

## O que é este repositório

Dockerfiles das imagens base PHP compartilhadas da LR Consultoria (FrankenPHP + OpenTelemetry),
consumidas por outros repositórios (player-tm, agent-tm, sqlpad-tm, reverb-tm, uptime, …).

- Remote canônico: `github.com/LR-Consultoria/php-containers-opentelemetry`
  (o diretório se chama `php-docker`).
- Imagem publicada que os consumidores puxam: `ghcr.io/lr-consultoria/php-frankenphp:<php>-alpine-<arch>`.
- Owner do registry = `github.repository_owner` em minúsculas → **`lr-consultoria`** (com hífen).
  Já corrigido no Makefile/scripts/docs; use sempre o hífen.
- Versões PHP suportadas: 8.2, 8.3, 8.4, 8.5 (default do Dockerfile: `PHP_VERSION=8.3`).

## Só existe uma variante: frankenphp

Swoole/FPM/Nginx foram removidas e os arquivos órfãos já foram limpos
(`configs/supervisord.conf`, `configs/php-swoole.ini`, `configs/php-production.ini`,
exemplos swoole/base, `demo.sh`, `build-examples.md`).

- `VARIANTS := frankenphp` no Makefile e nos scripts. Para adicionar uma variante,
  crie `<variante>/Dockerfile` e inclua o nome nas listas (`Makefile`, `scripts/*.sh`,
  matriz do workflow).
- Build direcionado: `make build VERSION=8.4 VARIANT=frankenphp`
  (ou `./scripts/build.sh 8.4 frankenphp`).
- O contexto de build é sempre a raiz do repositório (o Dockerfile faz `COPY configs/...`):
  `docker build --build-arg PHP_VERSION=8.4 -f frankenphp/Dockerfile .`

## Arquivos-chave

- `frankenphp/Dockerfile` — parametrizado por `ARG PHP_VERSION`;
  `FROM dunglas/frankenphp:1-php${PHP_VERSION}-alpine`. Faz `apk upgrade`, instala
  `opentelemetry grpc` via `mlocati/docker-php-extension-installer` (versão pinada) e
  define um `CMD` completo (`frankenphp run …`), pois o `ENTRYPOINT` só faz `exec "$@"`.
- `configs/` — compartilhado, copiado para dentro da imagem. O Caddyfile vai para
  **`/etc/frankenphp/Caddyfile`** (path default da imagem upstream) e usa `php_server`
  (não PHP-FPM). `entrypoint.sh` ajusta `php-franken.ini` quando `APP_ENV=local`.
  **A base NÃO traz `zip`, `redis`, `pdo_mysql`/`pdo_pgsql`, `intl`, `bcmath`, `memcached`** —
  só opentelemetry/grpc são adicionados aqui; o resto é responsabilidade do app.
- `scripts/*.sh` — build/test/push; `test.sh` é smoke test **com falha em erro**
  (php -v, opentelemetry, grpc, frankenphp, extensões essenciais).
- `docs/runbooks/vulnerabilidades-trivy.md` — runbook para CVEs do Alpine na base.
- `.github/workflows/build-and-push.yml` (build/publicação) e `lint.yml`
  (shellcheck, hadolint, actionlint).

## Comandos

```sh
make build VERSION=8.4 VARIANT=frankenphp   # build de uma imagem
make test  VERSION=8.4 VARIANT=frankenphp   # smoke test de uma imagem já construída
make build-matrix                            # build multi-arch com buildx
make list-images                             # imagens locais
make help
```

Env/build args: `REGISTRY` (default `ghcr.io/lr-consultoria`), `TAG_SUFFIX`,
`NO_CACHE=1`, `PUSH=1`, `BUILDX=1`.

## Fatos do container

- Roda como `www-data` remapeado para **UID/GID 1000**; workdir `/var/www`.
- Health: `curl -f http://localhost/health` (Caddy responde `healthy`).
- Consumidores normalmente sobrescrevem o comando (ex.: `php artisan octane:frankenphp`);
  a config default fica em `/etc/frankenphp/Caddyfile`.

## CI/CD

- Matriz: PHP 8.2–8.5 × frankenphp × **runners nativos amd64/arm64** (sem QEMU).
  Gatilhos: push em `main`, tags `v*`, PRs para `main`, cron semanal (`0 2 * * 0`)
  e `workflow_dispatch`.
- `create-manifests` publica `<php>-alpine`, `<php>` e `latest` (só 8.4, só na `main`).
  Roda com `if: !cancelled()` e **pula apenas a versão** cujo arch falhou.
- `security-scan` roda Trivy por versão: SARIF no GitHub + **gate que falha em
  HIGH/CRITICAL não corrigíveis** (`ignore-unfixed`).
- `smoke-test` roda `scripts/test.sh` na imagem publicada.
- Histórico: o workflow já esteve `disabled_inactivity` e os runs falhavam por
  emulação arm64; reabilitado em 2026-09-25 (`gh workflow enable build-and-push.yml`).

## Convenções (de `.cursor/rules/cursorrule.mdc`)

- Nunca fazer commit ou push em nome do usuário.
- Mensagens de commit em inglês, no formato conventional commits.
- Código e comentários em inglês; chat em português.
- Manter os Dockerfiles dirigidos por args/env para evitar duplicação entre arquivos.
- Únicas extensões não-default permitidas: `opentelemetry` e `grpc`.
- Preferir rodar o pipeline de testes em PRs, não na `main`.
- O `.gitattributes` força LF para `*.sh`, Dockerfiles, `*.ini`, `*.conf`, `Caddyfile`,
  `*.yml/yaml` e `*.md` — mantenha assim.
