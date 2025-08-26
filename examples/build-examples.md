# Exemplos de Build com Argumentos

Este documento mostra como usar os Dockerfiles com argumentos de build para diferentes cenários.

## 🐳 Build Básico

### Usando Scripts (Recomendado)
```bash
# Build versão específica
./scripts/build.sh 8.3 base alpine

# Build todas as versões
./scripts/build-all.sh alpine
```

### Usando Docker Diretamente
```bash
# PHP 8.3 base
docker build --build-arg PHP_VERSION=8.3 -t my-php-base:8.3 -f base/Dockerfile .

# PHP 8.2 com Swoole
docker build --build-arg PHP_VERSION=8.2 -t my-php-swoole:8.2 -f swoole/Dockerfile .

# PHP 8.4 com Nginx
docker build --build-arg PHP_VERSION=8.4 -t my-php-nginx:8.4 -f nginx/Dockerfile .

# PHP 8.3 com FrankenPHP
docker build --build-arg PHP_VERSION=8.3 -t my-php-franken:8.3 -f franken/Dockerfile .
```

## 🏗 Build com Docker Compose

### docker-compose.yml personalizado
```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: base/Dockerfile
      args:
        PHP_VERSION: 8.3
    container_name: my-laravel-app
    volumes:
      - ./src:/var/www
```

### Build para diferentes ambientes
```yaml
version: '3.8'

services:
  # Desenvolvimento - PHP 8.3
  app-dev:
    build:
      context: .
      dockerfile: base/Dockerfile
      args:
        PHP_VERSION: 8.3
    environment:
      APP_ENV: local
    profiles: [dev]

  # Produção - PHP 8.2 (LTS)
  app-prod:
    build:
      context: .
      dockerfile: nginx/Dockerfile
      args:
        PHP_VERSION: 8.2
    environment:
      APP_ENV: production
    profiles: [prod]

  # Performance - PHP 8.4 com Swoole
  app-perf:
    build:
      context: .
      dockerfile: swoole/Dockerfile
      args:
        PHP_VERSION: 8.4
    environment:
      APP_ENV: production
    profiles: [perf]
```

## 🚀 Build Multi-Stage

### Dockerfile personalizado usando as imagens base
```dockerfile
# Build stage
ARG PHP_VERSION=8.3
FROM ghcr.io/lrconsultoria/php-base:${PHP_VERSION}-alpine as builder

WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-scripts

# Production stage
FROM ghcr.io/lrconsultoria/php-nginx:${PHP_VERSION}-alpine

COPY --from=builder /app/vendor ./vendor
COPY . .

RUN chown -R www-data:www-data /var/www
```

### Build do multi-stage
```bash
# Build para PHP 8.3
docker build --build-arg PHP_VERSION=8.3 -t my-laravel:8.3 .

# Build para PHP 8.2
docker build --build-arg PHP_VERSION=8.2 -t my-laravel:8.2 .
```

## 🔧 Build com Buildx (Multi-Platform)

### Setup do buildx
```bash
# Criar builder
docker buildx create --name multiarch --driver docker-container --use

# Build multi-platform
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg PHP_VERSION=8.3 \
  -t my-php-base:8.3 \
  -f base/Dockerfile \
  --push .
```

### Script automatizado
```bash
#!/bin/bash
PHP_VERSIONS=("8.2" "8.3" "8.4")
VARIANTS=("base" "swoole" "nginx" "franken")

for version in "${PHP_VERSIONS[@]}"; do
  for variant in "${VARIANTS[@]}"; do
    echo "Building $variant:$version for multiple platforms..."
    
    docker buildx build \
      --platform linux/amd64,linux/arm64 \
      --build-arg PHP_VERSION=$version \
      -t my-php-$variant:$version \
      -f $variant/Dockerfile \
      --push .
  done
done
```

## 🧪 Testes com Argumentos

### Teste de versão específica
```bash
# Build imagem de teste
docker build --build-arg PHP_VERSION=8.3 -t test-php:8.3 -f base/Dockerfile .

# Verificar versão PHP
docker run --rm test-php:8.3 php -v

# Verificar extensões
docker run --rm test-php:8.3 php -m | grep opentelemetry
```

### Teste de compatibilidade
```bash
#!/bin/bash
# Script para testar compatibilidade entre versões

for version in "8.2" "8.3" "8.4"; do
  echo "Testing PHP $version..."
  
  # Build
  docker build --build-arg PHP_VERSION=$version -t test:$version -f base/Dockerfile .
  
  # Test basic PHP
  docker run --rm test:$version php -v
  
  # Test extensions
  docker run --rm test:$version php -m | grep -E "(opentelemetry|redis|opcache)"
  
  # Test composer
  docker run --rm test:$version composer --version
  
  echo "✅ PHP $version OK"
done
```

## 📊 Matrix Build com GitHub Actions

### Exemplo de matriz customizada
```yaml
strategy:
  matrix:
    php-version: ['8.2', '8.3', '8.4']
    variant: ['base', 'swoole', 'nginx', 'franken']
    platform: ['linux/amd64', 'linux/arm64']
    include:
      # Combinações especiais
      - php-version: '8.3'
        variant: 'base'
        platform: 'linux/amd64'
        push-latest: true
    exclude:
      # Excluir combinações problemáticas
      - php-version: '8.4'
        variant: 'franken'
        platform: 'linux/arm64'

steps:
- name: Build and push
  uses: docker/build-push-action@v5
  with:
    context: .
    file: ${{ matrix.variant }}/Dockerfile
    platforms: ${{ matrix.platform }}
    build-args: |
      PHP_VERSION=${{ matrix.php-version }}
    tags: |
      my-registry/php-${{ matrix.variant }}:${{ matrix.php-version }}
      ${{ matrix.push-latest && 'my-registry/php-' + matrix.variant + ':latest' || '' }}
```

## 🎯 Casos de Uso Avançados

### Build condicional baseado no ambiente
```bash
#!/bin/bash
# Build script inteligente

ENVIRONMENT=${1:-development}
case $ENVIRONMENT in
  "development")
    PHP_VERSION="8.3"
    VARIANT="base"
    ;;
  "staging")
    PHP_VERSION="8.3"
    VARIANT="nginx"
    ;;
  "production")
    PHP_VERSION="8.2"  # LTS para produção
    VARIANT="nginx"
    ;;
  "performance")
    PHP_VERSION="8.4"  # Latest para performance
    VARIANT="swoole"
    ;;
  *)
    echo "Environment must be: development, staging, production, or performance"
    exit 1
    ;;
esac

echo "Building for $ENVIRONMENT environment..."
echo "PHP Version: $PHP_VERSION, Variant: $VARIANT"

docker build \
  --build-arg PHP_VERSION=$PHP_VERSION \
  -t my-app:$ENVIRONMENT \
  -f $VARIANT/Dockerfile .
```

### Override de configurações por versão
```dockerfile
ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-fpm-alpine

# Configurações específicas por versão
COPY configs/php-production.ini /usr/local/etc/php/conf.d/
RUN if [ "$PHP_VERSION" = "8.4" ]; then \
      echo "opcache.jit=1255" >> /usr/local/etc/php/conf.d/php-production.ini; \
    fi
```

---

**Vantagens dos Build Args:**
- ✅ Manutenção simplificada
- ✅ Flexibilidade total
- ✅ Builds mais rápidos (cache)
- ✅ Menos duplicação de código
- ✅ Easier CI/CD pipelines
