# Estrutura do Projeto PHP Docker

Este documento descreve a estrutura do projeto e como cada componente funciona.

## 📁 Estrutura de Diretórios

```
php-docker/
├── .github/
│   └── workflows/
│       └── build-and-push.yml  # Pipeline principal (build, manifest, scan, smoke)
├── frankenphp/
│   └── Dockerfile              # Dockerfile parametrizado por PHP_VERSION
├── configs/                    # Configurações compartilhadas (copiadas na imagem)
│   ├── php-franken.ini         # Config PHP para FrankenPHP
│   ├── Caddyfile               # Config Caddy/FrankenPHP (health, headers, PHP)
│   └── entrypoint.sh           # Entrypoint (permissões + modo local)
├── scripts/                    # Scripts de automação
│   ├── build.sh                # Build de uma imagem
│   ├── build-all.sh            # Build de todas
│   ├── push-all.sh             # Push de todas
│   └── test.sh                 # Smoke test de uma imagem
├── examples/                   # Exemplos de docker-compose
│   ├── laravel-frankenphp.yml  # Setup FrankenPHP
│   ├── env.example             # Variáveis de exemplo
│   └── README.md               # Documentação dos exemplos
├── docs/runbooks/              # Runbooks operacionais
├── Makefile                    # Comandos de automação
├── docker-compose.dev.yml      # Compose para testes locais
├── .dockerignore
├── README.md
├── CONTRIBUTING.md
├── LICENSE
└── PROJECT_STRUCTURE.md        # Este arquivo
```

## 🐳 Imagens Construídas

### Convenção de Nomenclatura
- Repositório: `ghcr.io/lr-consultoria/`
- Nome: `php-{variant}`
- Tag por arquitetura: `{version}-alpine-{arch}` (ex.: `8.4-alpine-amd64`)
- Tag multi-arch (manifest): `{version}-alpine`, `{version}`, `latest` (só 8.4)

### Arquitetura de Build Args
Todos os Dockerfiles usam `PHP_VERSION` como argumento de build:

```dockerfile
ARG PHP_VERSION=8.3
FROM dunglas/frankenphp:1-php${PHP_VERSION}-alpine
```

Isso permite:
- **Manutenção simplificada**: um Dockerfile por variante
- **Flexibilidade**: construir qualquer versão PHP suportada (8.2–8.5)
- **Consistência**: mesmo comportamento entre versões

### Lista de Imagens

| Imagem | Tags | Descrição |
|--------|------|-----------|
| `php-frankenphp` | `8.2-alpine` … `8.5-alpine` | FrankenPHP + OpenTelemetry + gRPC |

> O contexto de build é sempre a raiz do repositório (o Dockerfile copia `configs/`).

## ⚙️ Configurações

### Extensões PHP Incluídas
- **Da base** (`dunglas/frankenphp`): ctype, curl, dom, fileinfo, filter, json, libxml,
  mbstring, openssl, PDO, pdo_sqlite, pcre, Phar, posix, session, SimpleXML, sodium,
  sqlite3, tokenizer, xml, xmlreader, xmlwriter, zlib; opcache habilitado.
- **Instaladas pelo Dockerfile**: opentelemetry, grpc.

Extensões adicionais (`redis`, `pdo_mysql`/`pdo_pgsql`, `zip`, `intl`, `bcmath`,
`memcached`, …) devem ser instaladas no Dockerfile do app consumidor
(via `install-php-extensions`, já presente na imagem), não na base.

### Ferramentas
`install-php-extensions` está disponível na imagem. Composer/Node/Git/clientes de banco
dependem da base upstream e podem não estar presentes.

### Portas Expostas
- **FrankenPHP**: 80, 443 (e 443/udp)

## 🛠 Scripts de Automação

```bash
./scripts/build.sh <version> <variant> [tag_suffix]   # ex.: ./scripts/build.sh 8.4 frankenphp
./scripts/build-all.sh [tag_suffix]
./scripts/push-all.sh [tag_suffix]
./scripts/test.sh <version> <variant> [tag_suffix]    # smoke test
```

## 🚀 Makefile Targets

- `make build VERSION=8.4 VARIANT=frankenphp`
- `make build-all` / `make build-matrix`
- `make test VERSION=8.4 VARIANT=frankenphp` / `make test-all`
- `make push` / `make push-all`
- `make dev-setup` / `make dev-up` / `make dev-down`
- `make clean` / `make clean-images` / `make list-images`

## 🔄 CI/CD Pipeline

O workflow `.github/workflows/build-and-push.yml`:

1. **Triggers**: push em `main`, tags `v*`, PRs para `main`, cron semanal, `workflow_dispatch`.
2. **`build-matrix`**: 4 versões PHP × 2 arquiteturas (runners nativos amd64 e arm64,
   sem emulação QEMU). Em PRs apenas constrói; fora de PRs publica as tags por arch.
3. **`create-manifests`**: combina as tags `-amd64`/`-arm64` em `{version}-alpine`,
   `{version}` e `latest` (8.4, só na `main`). Roda mesmo que uma arquitetura falhe e
   pula apenas a versão afetada.
4. **`security-scan`**: Trivy por versão; publica SARIF e **falha em HIGH/CRITICAL
   não corrigíveis** (`ignore-unfixed`).
5. **`smoke-test`**: roda `scripts/test.sh` na imagem publicada (php -v, opentelemetry,
   grpc, frankenphp, extensões essenciais).

## 📋 Variáveis de Ambiente

### Build Time
- `REGISTRY` — registry Docker (default: `ghcr.io/lr-consultoria`)
- `NO_CACHE` — desabilita cache de build
- `PUSH` — push após o build
- `BUILDX` — usa buildx para multi-plataforma

### Runtime
- `APP_ENV` — ambiente da aplicação (`local` liga display_errors/validate_timestamps)
- `APP_DEBUG`, `DB_*`, `REDIS_HOST`
- `OTEL_*` — configurações OpenTelemetry

## 🔍 Health Check

Todas as imagens incluem health check em `GET /health` (respondido pelo Caddy).

## 🛡 Segurança

- Usuário não-root (`www-data`, UID/GID 1000)
- `apk upgrade` no build para absorver patches do Alpine
- Scan Trivy no CI com gate de HIGH/CRITICAL não corrigíveis
- Runbook: [`docs/runbooks/vulnerabilidades-trivy.md`](docs/runbooks/vulnerabilidades-trivy.md)

## 🔄 Workflow de Desenvolvimento

```bash
# Build e smoke test local
make build VERSION=8.4 VARIANT=frankenphp
make test  VERSION=8.4 VARIANT=frankenphp
```

Contribuições seguem o [CONTRIBUTING.md](CONTRIBUTING.md).

---

**Última atualização**: 2026-09-25
