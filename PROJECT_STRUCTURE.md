# Estrutura do Projeto PHP Docker

Este documento descreve a estrutura completa do projeto e como cada componente funciona.

## 📁 Estrutura de Diretórios

```
php-docker/
├── .github/                    # GitHub Actions e automação
│   └── workflows/
│       └── build-and-push.yml  # CI/CD pipeline principal
├── fpm/                       # Imagens FPM PHP-FPM
│   └── Dockerfile              # Dockerfile parametrizado
├── swoole/                     # Variantes com Swoole
│   └── Dockerfile              # Dockerfile parametrizado
├── nginx/                      # Variantes com Nginx
│   └── Dockerfile              # Dockerfile parametrizado
├── frankenphp/                 # Variantes com FrankenPHP
│   └── Dockerfile              # Dockerfile parametrizado
├── configs/                    # Configurações compartilhadas
│   ├── php-production.ini      # Config PHP produção
│   ├── php-swoole.ini         # Config PHP Swoole
│   ├── php-franken.ini        # Config PHP FrankenPHP
│   ├── php-fpm.conf           # Config PHP-FPM
│   ├── nginx.conf             # Config Nginx principal
│   ├── default.conf           # Config Nginx virtual host
│   ├── supervisord.conf       # Config Supervisor
│   ├── Caddyfile              # Config Caddy/FrankenPHP
│   └── entrypoint.sh          # Script de inicialização
├── scripts/                    # Scripts de automação
│   ├── build.sh               # Build imagem específica
│   ├── build-all.sh           # Build todas as imagens
│   ├── push-all.sh            # Push todas as imagens
│   └── test.sh                # Teste de imagens
├── examples/                   # Exemplos docker-compose
│   ├── laravel-base.yml       # Setup base
│   ├── laravel-swoole.yml     # Setup Swoole
│   ├── laravel-nginx.yml      # Setup Nginx
│   ├── laravel-frankenphp.yml # Setup FrankenPHP
│   ├── env.example            # Variáveis exemplo
│   └── README.md              # Documentação exemplos
├── Makefile                    # Comandos de automação
├── docker-compose.dev.yml     # Compose para testes locais
├── README.md                   # Documentação principal
├── CONTRIBUTING.md             # Guidelines contribuição
├── LICENSE                     # Licença MIT
├── .gitignore                  # Arquivos ignorados
└── PROJECT_STRUCTURE.md       # Este arquivo
```

## 🐳 Imagens Construídas

### Convenção de Nomenclatura
- Repositório: `ghcr.io/lrconsultoria/`
- Nome: `php-{variant}`
- Tag: `{version}-alpine`

### Arquitetura de Build Args
Todos os Dockerfiles usam `PHP_VERSION` como argumento de build:
```dockerfile
ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-fpm-alpine
```

Isso permite:
- **Manutenção simplificada**: Um Dockerfile por variante
- **Flexibilidade**: Construir qualquer versão PHP suportada
- **Consistência**: Mesmo comportamento entre versões

### Lista Completa de Imagens

| Imagem | Tag | Descrição |
|--------|-----|-----------|
| `php-fpm` | `8.2-alpine`, `8.3-alpine`, `8.4-alpine` | PHP-FPM base |
| `php-swoole` | `8.2-alpine`, `8.3-alpine`, `8.4-alpine` | PHP + Swoole |
| `php-nginx` | `8.2-alpine`, `8.3-alpine`, `8.4-alpine` | PHP-FPM + Nginx |
| `php-frankenphp` | `8.2-alpine`, `8.3-alpine`, `8.4-alpine` | FrankenPHP |

## ⚙️ Configurações

### PHP Extensions Incluídas
- **Core**: bcmath, calendar, ctype, curl, dom, exif, fileinfo, filter, ftp, gd, gettext, hash, iconv, json, libxml, mbstring, mysqli, openssl, pcre, PDO, pdo_mysql, pdo_pgsql, pdo_sqlite, pcntl, soap, sockets, zip
- **Performance**: opcache, redis
- **Observabilidade**: opentelemetry
- **Swoole**: swoole (apenas nas variantes swoole)

### Ferramentas
- Composer (latest)
- Node.js + NPM
- Git
- Curl
- MySQL/PostgreSQL clients

### Portas Expostas
- **FPM**: 9000 (PHP-FPM)
- **Swoole**: 8000 (HTTP)
- **Nginx**: 80, 443 (HTTP/HTTPS)
- **FrankenPHP**: 80, 443 (HTTP/HTTPS)

## 🛠 Scripts de Automação

### build.sh
Constrói uma imagem específica usando argumentos de build.
```bash
./scripts/build.sh <version> <variant> [tag_suffix]
```

**Exemplo de comando gerado:**
```bash
docker build --build-arg PHP_VERSION=8.3 -t ghcr.io/lrconsultoria/php-fpm:8.3-alpine -f fpm/Dockerfile .
```

### build-all.sh
Constrói todas as imagens.
```bash
./scripts/build-all.sh [tag_suffix]
```

### push-all.sh
Envia todas as imagens para o registry.
```bash
./scripts/push-all.sh [tag_suffix]
```

### test.sh
Testa uma imagem específica.
```bash
./scripts/test.sh <version> <variant> [tag_suffix]
```

## 🚀 Makefile Targets

### Build
- `make build VERSION=8.3 VARIANT=fpm` - Build específico
- `make build-all` - Build todas
- `make build-matrix` - Build multi-platform

### Test
- `make test VERSION=8.3 VARIANT=fpm` - Teste específico
- `make test-all` - Teste todas

### Push
- `make push VERSION=8.3 VARIANT=fpm` - Push específico
- `make push-all` - Push todas

### Desenvolvimento
- `make dev-setup` - Setup ambiente
- `make dev-up` - Inicia ambiente
- `make dev-down` - Para ambiente

### Utilitários
- `make clean` - Limpeza Docker
- `make clean-images` - Remove imagens
- `make list-images` - Lista imagens

## 🔄 CI/CD Pipeline

### GitHub Actions
O pipeline automatizado (`build-and-push.yml`):

1. **Triggers**:
   - Push para `main` e `develop`
   - Tags `v*`
   - Pull requests
   - Schedule mensal

2. **Matrix Build**:
   - 3 versões PHP × 4 variantes = 12 imagens
   - Multi-platform (AMD64/ARM64)
   - Builds paralelos

3. **Steps**:
   - Checkout código
   - Setup Docker Buildx
   - Login no registry
   - Build e push imagens
   - Teste de imagens
   - Security scan (Trivy)

4. **Outputs**:
   - Imagens no GitHub Container Registry
   - Security reports
   - Test results

### Security Scanning
- Trivy vulnerability scanner
- Automated dependency updates
- Security headers validation

## 📋 Variáveis de Ambiente

### Build Time
- `REGISTRY` - Registry Docker (default: ghcr.io/lrconsultoria)
- `NO_CACHE` - Disable build cache
- `PUSH` - Auto push após build
- `BUILDX` - Use buildx para multi-platform

### Runtime
- `APP_ENV` - Ambiente da aplicação
- `APP_DEBUG` - Debug mode
- `DB_HOST`, `DB_DATABASE`, etc. - Configurações banco
- `REDIS_HOST` - Host Redis
- `OTEL_*` - Configurações OpenTelemetry

## 🔍 Health Checks

Todas as imagens incluem health checks:

- **FPM**: Verifica PHP-FPM via ping
- **Swoole**: HTTP GET `/health`
- **Nginx**: HTTP GET `/nginx-health`
- **FrankenPHP**: HTTP GET `/health`

## 📊 Monitoramento

### Logs
- Aplicação: `/proc/self/fd/2` (stderr)
- Nginx: `/var/log/nginx/`
- Supervisor: `/var/log/supervisor/`

### Metrics
- FrankenPHP: Built-in Caddy metrics
- Swoole: Custom metrics endpoints
- OpenTelemetry: Traces e métricas automáticas

## 🛡 Segurança

### Configurações
- User não-root (www-data)
- Minimal attack surface
- Security headers
- No sensitive data in images

### Scanning
- FPM image vulnerabilities
- Dependency scanning
- Regular security updates

## 🔄 Workflow de Desenvolvimento

### 1. Desenvolvimento Local
```bash
# Setup
make dev-setup

# Build e teste
make build VERSION=8.3 VARIANT=fpm
make test VERSION=8.3 VARIANT=fpm
```

### 2. Contribuição
```bash
# Fork e clone
git clone https://github.com/SEU_USER/php-docker.git

# Branch
git checkout -b feature/nova-feature

# Desenvolver e testar
make build-all
make test-all

# Commit e push
git commit -am "feat: nova feature"
git push origin feature/nova-feature
```

### 3. CI/CD
- Pull request triggers build
- Automated testing
- Security scanning
- Manual review
- Merge to main triggers release

## 📈 Roadmap

### Futuro
- [ ] PHP 8.5 support
- [ ] More PHP extensions
- [ ] Performance optimizations
- [ ] Better monitoring
- [ ] Kubernetes manifests
- [ ] Helm charts

### Maintenance
- Monthly dependency updates
- Security patches
- Performance monitoring
- Community feedback integration

---

**Estrutura criada em**: 2024-12-19
**Última atualização**: 2024-12-19
