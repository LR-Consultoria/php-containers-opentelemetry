# PHP Docker Base Images

Este repositório contém os Dockerfiles das **imagens base PHP da LR Consultoria**,
otimizadas para projetos Laravel com **FrankenPHP** e **OpenTelemetry**.

[![Build and Push](https://github.com/LR-Consultoria/php-containers-opentelemetry/actions/workflows/build-and-push.yml/badge.svg)](https://github.com/LR-Consultoria/php-containers-opentelemetry/actions/workflows/build-and-push.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🐳 Imagens Disponíveis

| Imagem | Tags | Portas | Uso |
|--------|------|--------|-----|
| `ghcr.io/lr-consultoria/php-frankenphp` | `8.2-alpine`, `8.3-alpine`, `8.4-alpine`, `8.5-alpine` | 80, 443 | Aplicações modernas (FrankenPHP/Octane) |

- Versões PHP suportadas: **8.2, 8.3, 8.4, 8.5** (default no build: 8.3).
- Manifest multi-arch: `amd64` e `arm64`. `latest` acompanha a **8.4**.
- Tags por arquitetura também são publicadas (`<php>-alpine-amd64` / `<php>-alpine-arm64`).

> Consumidores normalmente rodam `php artisan octane:frankenphp` (Laravel Octane),
> então o Caddyfile embutido serve de base para uso direto da imagem.

## 🛠 Características

- ✅ Baseada em Alpine Linux (imagens leves)
- ✅ **OpenTelemetry + gRPC** pré-instalados
- ✅ Extensões PHP essenciais para Laravel
- ✅ Configurações otimizadas (OPcache, php.ini)
- ✅ Multi-arquitetura (AMD64 e ARM64)
- ✅ Health check integrado (`GET /health`)
- ✅ Executa como usuário não-root (`www-data`, UID/GID 1000)

## 📦 Uso Rápido

```bash
docker pull ghcr.io/lr-consultoria/php-frankenphp:8.4-alpine
```

### Uso em Dockerfile

```dockerfile
FROM ghcr.io/lr-consultoria/php-frankenphp:8.4-alpine

COPY . /var/www
RUN composer install --no-dev --optimize-autoloader

# O CMD padrão sobe o FrankenPHP com o Caddyfile embutido.
# Para Octane, sobrescreva com:
# CMD ["php", "artisan", "octane:frankenphp", "--host=0.0.0.0", "--port=80"]
```

Consulte a pasta [`examples/`](examples/) para exemplos de docker-compose.

## 🏗 Build Local

O contexto de build é a **raiz do repositório** (o Dockerfile copia `configs/`).

```bash
# Build de uma imagem
make build VERSION=8.4 VARIANT=frankenphp

# Build + smoke test
make test VERSION=8.4 VARIANT=frankenphp

# Build direto com Docker
docker build --build-arg PHP_VERSION=8.4 -f frankenphp/Dockerfile -t my-php:8.4 .

# Build multi-arch (buildx)
make build-matrix
```

### Build Args

Todos os Dockerfiles usam `PHP_VERSION` como argumento:

```dockerfile
ARG PHP_VERSION=8.3
FROM dunglas/frankenphp:1-php${PHP_VERSION}-alpine
```

## 📁 Estrutura do Projeto

```
php-docker/
├── frankenphp/     # Dockerfile da variante FrankenPHP
├── configs/        # Configurações compartilhadas (php.ini, Caddyfile, entrypoint)
├── scripts/        # Scripts de build/test/push
├── examples/       # Exemplos de docker-compose
├── docs/runbooks/  # Runbooks operacionais
└── .github/        # GitHub Actions
```

## 🔧 Configurações Incluídas

### Extensões PHP
- **Vêm da base** (`dunglas/frankenphp`): ctype, curl, dom, fileinfo, filter, json,
  libxml, mbstring, openssl, PDO, pdo_sqlite, pcre, Phar, posix, session, SimpleXML,
  sodium, sqlite3, tokenizer, xml, xmlreader, xmlwriter, zlib
- **Instaladas por este Dockerfile**: **opentelemetry**, **grpc**
- **Performance**: opcache (habilitado na base)

> Outras extensões usadas pelos apps (`redis`, `pdo_mysql`/`pdo_pgsql`, `zip`, `intl`,
> `bcmath`, `memcached`, …) **não** estão na base. Instale no Dockerfile do app
> (`install-php-extensions`, já disponível na imagem).

### Ferramentas
Node.js + NPM, Git, Curl, clientes MySQL/PostgreSQL **não** estão incluídos por padrão —
apenas o essencial do upstream. Composer e `install-php-extensions` estão disponíveis.

## 🚀 Scripts e Makefile

```bash
make build VERSION=8.4 VARIANT=frankenphp   # build específico
make build-all                              # build de todas as versões
make test VERSION=8.4 VARIANT=frankenphp    # smoke test
make test-all                               # testa todas
make push VERSION=8.4 VARIANT=frankenphp    # push específico
make push-all                               # push de todas
make clean                                  # limpeza Docker
make list-images                            # lista imagens locais
```

Variáveis: `REGISTRY` (default `ghcr.io/lr-consultoria`), `TAG_SUFFIX`,
`NO_CACHE=1`, `PUSH=1`, `BUILDX=1`.

## 🔒 Segurança

- Executa como usuário não-root (`www-data`, UID/GID 1000).
- Scan automático com Trivy no CI (falha em HIGH/CRITICAL não corrigíveis).
- `apk upgrade` no build absorve patches do Alpine.
- Runbook de remediação: [`docs/runbooks/vulnerabilidades-trivy.md`](docs/runbooks/vulnerabilidades-trivy.md).

## 📋 Licença

MIT License — veja [LICENSE](LICENSE).

**Mantido por [LR Consultoria](https://lrconsultoria.com.br).**
