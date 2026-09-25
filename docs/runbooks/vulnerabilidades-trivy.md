---
tags: [runbook, seguranca, docker, trivy]
criado: 2026-09-25
---

# Runbook — Vulnerabilidades Trivy nas imagens base

Procedimento para tratar achados de vulnerabilidade reportados pelo Trivy nos
containers consumidores, originados na **imagem base PHP** deste repositório.

> Este documento é a **definição** do processo. A execução fica a cargo do time
> de infra na próxima janela de manutenção.

## Escopo

- Imagens publicadas: `ghcr.io/lr-consultoria/php-frankenphp:<php>-alpine-<arch>`
  (ex.: `8.5-alpine-amd64`), geradas por `.github/workflows/build-and-push.yml`
  a partir de `frankenphp/Dockerfile`.
- Não cobre vulnerabilidades de código da aplicação (Composer) — essas aparecem
  no `composer audit` do pipeline de cada app.

## Contexto

Os achados de sistema operacional vêm da camada Alpine herdada do upstream
`dunglas/frankenphp:1-php${PHP_VERSION}-alpine`. Quando o Trivy do app consumidor
roda na imagem publicada no ECR (`Security Check` / job *Image Vulnerability
Check*, com `exit-code 1`), pacotes Alpine desatualizados reprovam o scan — mesmo
sem nenhuma mudança no app.

Exemplo real (scan de `player-tm-prod:latest` em 2026-09-25, base Alpine 3.23):

```
Total: 91 (UNKNOWN: 2, LOW: 16, MEDIUM: 48, HIGH: 25, CRITICAL: 0)

c-ares    CVE-2026-33630   HIGH   1.34.6-r0 -> 1.34.8-r0
libcurl   CVE-2026-8925    HIGH   8.21.x    -> 8.22.0-r0
libcurl   CVE-2026-10536   HIGH   8.21.x    -> 8.22.0-r0
libcurl   CVE-2026-11352   HIGH   8.21.x    -> 8.22.0-r0
libxml2   CVE-2026-6732    HIGH   2.13.9-r0 -> 2.13.9-r1
```

Todos com correção disponível no repositório Alpine — basta reconstruir a imagem
base atualizando os pacotes do SO.

## Sintoma

- O workflow `Security Check` do app consumidor falha no job
  *Image Vulnerability Check* com `Process completed with exit code 1`.
- O relatório do Trivy mostra `HIGH`/`CRITICAL` em pacotes de sistema
  (`c-ares`, `libcurl`, `libxml2`, `openssl`, `zlib`, `busybox`, …).
- Nenhuma alteração recente de aplicação — o achado "aparece sozinho" porque a
  base de vulnerabilidades do Trivy é atualizada diariamente.

## Diagnóstico

1. Confirmar a versão da base usada pelo app:

   ```bash
   grep -n "FROM" Dockerfile   # no repo do app consumidor
   ```

2. Reproduzir o scan na imagem base diretamente:

   ```bash
   trivy image --severity HIGH,CRITICAL \
     ghcr.io/lr-consultoria/php-frankenphp:8.5-alpine-amd64
   ```

3. Confirmar que o pacote apontado tem versão de correção no Alpine
   (coluna *Fixed Version*). Se **não** houver fix upstream, tratar como
   exceção (ver *Prevenção → exceções*).

## Correção

### Opção A — corrigir na imagem base (preferida)

1. No `frankenphp/Dockerfile`, atualizar os pacotes do SO no início do build
   (antes da instalação das extensões PHP), garantindo que o cache do apk seja
   descartado:

   ```dockerfile
   RUN apk upgrade --no-cache \
       && apk add --no-cache curl bash \
       && curl -sSLf -o /usr/local/bin/install-php-extensions \
           https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
       && chmod +x /usr/local/bin/install-php-extensions \
       && install-php-extensions opentelemetry grpc \
       && rm -rf /var/cache/apk/* /tmp/*
   ```

2. Alternativa complementar: fixar/atualizar a tag do upstream
   (`FROM dunglas/frankenphp:1-php${PHP_VERSION}-alpine` para um digest mais
   recente) para herdar os patches do mantenedor.

3. Rodar o build local e validar (ver *Verificação*).

4. Fazer merge no `main` deste repositório — o workflow publica as imagens
   (`build-matrix` → `create-manifests`) e roda o `security-scan`.

### Opção B — corrigir só no app consumidor (paliativo)

Adicionar `apk upgrade --no-cache` no `Dockerfile` do app. Resolve
imediatamente, mas duplica a correção em cada app e diverge da base — usar
apenas como contenção temporária.

### Após publicar a base

A imagem do app no ECR precisa ser **reconstruída** para herdar a base nova:

1. Disparar o pipeline do app (merge na `main` ou `workflow_dispatch` do
   `Deploy`), que faz o build/push em `player-tm-prod`/`player-tm-dev`.
2. Reexecutar o `Security Check` (ou aguardar o cron diário) e confirmar verde.

## Verificação

```bash
# Base publicada, sem HIGH/CRITICAL
trivy image --severity HIGH,CRITICAL \
  ghcr.io/lr-consultoria/php-frankenphp:8.5-alpine-amd64 \
  --exit-code 1

# Imagem do app no ECR
trivy image --severity HIGH,CRITICAL \
  638655891410.dkr.ecr.us-east-2.amazonaws.com/player-tm-prod:latest \
  --exit-code 1
```

- No GitHub, o job `security-scan` deste repositório publica o SARIF na aba
  **Security → Code scanning**.

## Rollback

- Imagens são versionadas por tag `latest` + `<php>-alpine-<arch>` e o ECR usa
  `IMMUTABLE_WITH_EXCLUSION` para o SHA. Para reverter, redeployar o app com o
  digest/tag anterior (update no `values.yaml` do GitOps) e, se necessário,
  reverter o commit do `frankenphp/Dockerfile` e republicar.

## Prevenção

- **Rebuild periódico**: o workflow já tem `schedule` (`cron: '0 2 * * 0'`, hoje
  semanal). Garantir que a cadência seja suficiente para absorver patches do
  Alpine; alinhar o comentário do YAML ("monthly") com o cron real.
- **Base sempre atual**: manter o `dunglas/frankenphp` rastreado (dependabot
  para docker, se aplicável).
- **Diff de base**: ao subir PHP, validar com `trivy` antes de publicar.
- **Alarme cedo**: manter o `Security Check` dos apps rodando diariamente.

### Exceções (sem fix upstream)

Quando não houver versão corrigida, documentar a decisão e o prazo de revisão:

- Configurar `.trivyignore` no repositório do **app** com o CVE e uma data de
  revisão; **não** mascarar em `.trivyignore` da base.
- Registrar a justificativa na issue/PR correspondente.

## Lacunas conhecidas

- O job `security-scan` deste repositório hoje é **informativo** (não falha o
  build) e escaneia apenas **`php-frankenphp:8.4-alpine-amd64`** (versão
  hardcoded). Não há gate por `HIGH`/`CRITICAL` na base, nem cobertura da `8.5`.
  Melhorias sugeridas (PR futuro): parametrizar a versão no scan, rodar
  `--severity HIGH,CRITICAL --exit-code 1` como gate e escanear todas as
  versões do matrix.
