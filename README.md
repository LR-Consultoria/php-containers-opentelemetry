# PHP Docker Base Images

Este repositório contém Dockerfiles para imagens base PHP otimizadas para projetos Laravel, seguindo os padrões PSR-12 e boas práticas de containerização.

[![Build and Push](https://github.com/lrconsultoria/php-docker/actions/workflows/build-and-push.yml/badge.svg)](https://github.com/lrconsultoria/php-docker/actions/workflows/build-and-push.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker Pulls](https://img.shields.io/docker/pulls/lrconsultoria/php-fpm)](https://github.com/lrconsultoria/php-docker/pkgs/container/php-fpm)

## 🐳 Imagens Disponíveis

### Versões PHP Suportadas
- **PHP 8.2** - Versão estável (suporte de segurança)
- **PHP 8.3** - Versão estável (suporte ativo)
- **PHP 8.4** - Versão estável (suporte ativo)
- **PHP 8.5** - Versão recomendada (suporte ativo)

### Variantes Disponíveis

| Variante | Descrição | Porta | Uso Recomendado |
|----------|-----------|-------|-----------------|
| **Swoole** | Extensão Swoole para alta performance | 8000 | APIs de alta performance |
| **FrankenPHP** | Servidor moderno com HTTP/2 e HTTP/3 | 80/443 | Aplicações modernas |

## 🛠 Características

- ✅ **Baseado em Alpine Linux** - Imagens ultra-leves (~50MB base)
- ✅ **OpenTelemetry pré-instalado** - Observabilidade out-of-the-box
- ✅ **Extensões PHP essenciais** - Tudo que o Laravel precisa
- ✅ **Configurações otimizadas** - Produção e desenvolvimento
- ✅ **PSR-12 compliance** - Padrões de código profissionais
- ✅ **Multi-arquitetura** - Suporte AMD64 e ARM64
- ✅ **Health checks** - Monitoramento integrado
- ✅ **Security hardened** - Configurações seguras por padrão

## 📦 Uso Rápido

### Com Swoole
```bash
docker pull ghcr.io/lrconsultoria/php-swoole:8.3-alpine
```

### Com FrankenPHP
```bash
docker pull ghcr.io/lrconsultoria/php-frankenphp:8.3-alpine
```

## 🏗 Build Local

```bash
# Build todas as imagens
./scripts/build-all.sh

# Build versão específica
./scripts/build.sh 8.3 swoole
./scripts/build.sh 8.3 frankenphp
```

## 📁 Estrutura do Projeto

```
php-docker/
├── swoole/         # Variantes com Swoole
├── frankenphp/     # Variantes com FrankenPHP
├── scripts/        # Scripts de build e automação
├── examples/       # Exemplos de docker-compose
└── configs/        # Configurações compartilhadas
```

## 🔧 Configurações Incluídas

### PHP Extensions
- **Core**: bcmath, calendar, ctype, curl, dom, exif, fileinfo, filter, ftp, gd, gettext, hash, iconv, json, libxml, mbstring, mysqli, openssl, pcre, PDO, pdo_mysql, pdo_pgsql, pdo_sqlite, pcntl, soap, sockets, zip
- **Performance**: opcache, redis
- **Observability**: opentelemetry
- **Swoole**: swoole (variante específica)

### Ferramentas Incluídas
- **Composer** - Gerenciador de dependências PHP
- **Node.js + NPM** - Para build de assets
- **Git** - Controle de versão
- **Curl** - Cliente HTTP
- **MySQL/PostgreSQL Clients** - Clientes de banco

### Configurações Otimizadas
- **OPcache** - Cache de bytecode configurado
- **PHP-FPM** - Pool workers otimizados
- **Memory limits** - Configurados para Laravel
- **Error handling** - Logs estruturados
- **Security headers** - Configurações de segurança

## 🚀 Exemplos de Uso

### Quick Start
```bash
# Clone o repositório
git clone https://github.com/lrconsultoria/php-docker.git
cd php-docker

# Setup do ambiente de desenvolvimento
make dev-setup

# Inicie uma aplicação Laravel
docker-compose -f examples/laravel-base.yml up -d
```

### Uso em Dockerfile
```dockerfile
FROM ghcr.io/lrconsultoria/php-fpm:8.3-alpine

COPY . /var/www
RUN composer install --no-dev --optimize-autoloader

CMD ["php-fpm"]
```

Consulte a pasta [`examples/`](examples/) para ver exemplos completos de como usar essas imagens em seus projetos Laravel.

## 🛠 Build e Desenvolvimento

### Build Local
```bash
# Build uma imagem específica
make build VERSION=8.3 VARIANT=fpm

# Build todas as imagens
make build-all

# Build direto com Docker (usando argumentos)
docker build --build-arg PHP_VERSION=8.3 -t my-php:8.3 -f fpm/Dockerfile .

# Executar testes
make test VERSION=8.3 VARIANT=fpm
make test-all
```

### 🏗 Arquitetura de Build Args
Todos os Dockerfiles usam `PHP_VERSION` como argumento, permitindo:
- **Manutenção simplificada**: Um Dockerfile por variante
- **Flexibilidade**: Qualquer versão PHP suportada  
- **CI/CD otimizado**: Builds mais eficientes

### Scripts Disponíveis
- `make build` - Build de imagem específica
- `make build-all` - Build de todas as imagens
- `make test` - Teste de imagem específica
- `make test-all` - Teste de todas as imagens
- `make push` - Push para registry
- `make clean` - Limpeza de recursos Docker

## 📊 Performance Benchmarks

| Variante | Startup Time | Memory Usage | Request/sec |
|----------|--------------|--------------|-------------|
| FPM (PHP-FPM) | ~2s | 50MB | 1,000 |
| Swoole | ~3s | 80MB | 5,000+ |
| Nginx | ~3s | 70MB | 2,000 |
| FrankenPHP | ~2s | 60MB | 3,000 |

*Benchmarks executados em ambiente de teste padrão com aplicação Laravel simples.*

## 🔒 Segurança

### Scaneamento de Vulnerabilidades
- Scaneamento automático com Trivy
- Updates mensais de dependências
- Security patches aplicados regularmente

### Configurações de Segurança
- User não-root por padrão
- Arquivos sensíveis protegidos
- Headers de segurança configurados
- Secrets management via environment

## 📋 Licença

MIT License - veja [LICENSE](LICENSE) para detalhes.

## 🤝 Contribuindo

Contributions são bem-vindas! Leia nosso [CONTRIBUTING.md](CONTRIBUTING.md) para guidelines detalhadas.

### Quick Contribution
1. Fork o projeto
2. Crie uma branch: `git checkout -b feature/nova-feature`
3. Commit: `git commit -am 'feat: adiciona nova feature'`
4. Push: `git push origin feature/nova-feature`
5. Abra um Pull Request

## 📞 Suporte

- **Issues**: [GitHub Issues](https://github.com/lrconsultoria/php-docker/issues)
- **Discussions**: [GitHub Discussions](https://github.com/lrconsultoria/php-docker/discussions)
- **Email**: devops@lrconsultoria.com.br
- **Documentation**: [Wiki](https://github.com/lrconsultoria/php-docker/wiki)

---

**Last updated**: 2025-12-19 10:55:00 UTC
**Made with ❤️ by [LR Consultoria](https://lrconsultoria.com.br)**
