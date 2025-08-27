# Exemplos de Docker Compose

Esta pasta contém exemplos de configurações Docker Compose para diferentes cenários de uso das imagens PHP.

## 📁 Arquivos Disponíveis

### Configurações Principais
- `laravel-base.yml` - Setup básico com PHP-FPM + Nginx separado
- `laravel-swoole.yml` - Setup com Swoole para alta performance
- `laravel-nginx.yml` - Setup com Nginx integrado para produção
- `laravel-frankenphp.yml` - Setup com FrankenPHP para desenvolvimento moderno

### Arquivos de Suporte
- `env.example` - Variáveis de ambiente de exemplo
- `nginx/` - Configurações Nginx personalizadas
- `configs/` - Configurações PHP personalizadas

## 🚀 Como Usar

### 1. Setup Básico (PHP-FPM + Nginx)
```bash
# Copie e ajuste as variáveis
cp examples/env.example .env

# Inicie os serviços
docker-compose -f examples/laravel-base.yml up -d

# Acesse: http://localhost
```

### 2. Setup com Swoole (Alta Performance)
```bash
# Configure as variáveis
cp examples/env.example .env

# Inicie com Swoole
docker-compose -f examples/laravel-swoole.yml up -d

# Acesse: http://localhost:8000
```

### 3. Setup com Nginx Integrado (Produção)
```bash
# Configure para produção
cp examples/env.example .env
# Edite as variáveis para produção

# Inicie
docker-compose -f examples/laravel-nginx.yml up -d

# Acesse: http://localhost
```

### 4. Setup com FrankenPHP (Moderno)
```bash
# Configure
cp examples/env.example .env

# Inicie com FrankenPHP
docker-compose -f examples/laravel-frankenphp.yml up -d

# Acesse: http://localhost
```

## ⚙️ Configurações Personalizadas

### PHP Configurations
Crie arquivos de configuração PHP personalizados:

```bash
mkdir -p configs
```

**configs/php-local.ini:**
```ini
; Configurações para desenvolvimento
display_errors = On
error_reporting = E_ALL
opcache.validate_timestamps = 1
xdebug.mode = debug
```

**configs/php-production.ini:**
```ini
; Configurações para produção
display_errors = Off
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
opcache.validate_timestamps = 0
```

### Nginx Configurations
**nginx/swoole-proxy.conf:**
```nginx
upstream swoole {
    server app:8000;
}

server {
    listen 80;
    server_name _;
    
    location / {
        proxy_pass http://swoole;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Redis Configuration
**configs/redis.conf:**
```
maxmemory 256mb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
```

## 🛠 Comandos Úteis

### Laravel Commands
```bash
# Migrate e seed
docker-compose exec app php artisan migrate --seed

# Clear cache
docker-compose exec app php artisan cache:clear
docker-compose exec app php artisan config:clear
docker-compose exec app php artisan route:clear

# Generate key
docker-compose exec app php artisan key:generate

# Install dependencies
docker-compose exec app composer install
docker-compose exec app npm install && npm run build
```

### Docker Commands
```bash
# Ver logs
docker-compose logs -f app

# Executar comandos
docker-compose exec app bash

# Rebuild specific service
docker-compose build app

# Scale queue workers
docker-compose up -d --scale queue=3
```

## 🔍 Health Checks

Todos os setups incluem health checks:

- **FPM**: `curl http://localhost/nginx-health`
- **Swoole**: `curl http://localhost:8000/health`
- **Nginx**: `curl http://localhost/nginx-health`
- **FrankenPHP**: `curl http://localhost/health`

## 📊 Monitoramento

### Logs
```bash
# Aplicação
docker-compose logs -f app

# Nginx
docker-compose logs -f nginx

# Database
docker-compose logs -f database

# Queue
docker-compose logs -f queue
```

### Performance
- **Swoole**: Monitor via Laravel Telescope ou custom endpoints
- **Nginx**: Logs em `./logs/nginx/`
- **FrankenPHP**: Built-in metrics via Caddy

## 🛡 Segurança para Produção

1. **Variáveis de Ambiente**:
   - Use `.env` files seguros
   - Não commite credenciais

2. **SSL/TLS**:
   - Configure certificados
   - Use reverse proxy

3. **Firewall**:
   - Exponha apenas portas necessárias
   - Use redes Docker isoladas

4. **Backup**:
   - Volumes persistentes
   - Backup automático do banco

## 🐛 Troubleshooting

### Problemas Comuns

**Permission denied:**
```bash
sudo chown -R $USER:$USER ./src
```

**Port already in use:**
```bash
# Change ports in docker-compose.yml
ports:
  - "8080:80"  # Instead of "80:80"
```

**Container won't start:**
```bash
# Check logs
docker-compose logs app

# Debug mode
docker-compose run --rm app bash
```
