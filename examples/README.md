# Exemplos de Docker Compose

Exemplos de uso das imagens base em projetos Laravel.

## 📁 Arquivos Disponíveis

- `laravel-frankenphp.yml` — setup completo (app FrankenPHP + MySQL + Redis +
  queue + Soketi + MailHog + Adminer).
- `env.example` — variáveis de ambiente de exemplo.

## 🚀 Como Usar

```bash
# Copie e ajuste as variáveis
cp examples/env.example .env

# Coloque o código Laravel em ./src e suba os serviços
docker compose -f examples/laravel-frankenphp.yml up -d

# Acesse: http://localhost
```

A imagem já traz o `Caddyfile` e o `php-franken.ini`. Para sobrescrever, monte seus
arquivos, por exemplo:

```yaml
volumes:
  - ./src:/var/www
  - ./configs/php-franken-local.ini:/usr/local/etc/php/conf.d/php-franken-local.ini
  - ./configs/Caddyfile:/etc/frankenphp/Caddyfile
```

## 🛠 Comandos Úteis

```bash
# Laravel
docker compose exec app php artisan migrate --seed
docker compose exec app php artisan key:generate
docker compose exec app php artisan config:clear

# Docker
docker compose logs -f app
docker compose exec app sh
```

## 🔍 Health Check

- **FrankenPHP**: `curl http://localhost/health`

## 🐛 Troubleshooting

**Permission denied:**
```bash
sudo chown -R $USER:$USER ./src
```

**Porta em uso:** altere `ports:` no compose (ex.: `"8080:80"`).

**Container não sobe:** verifique os logs com `docker compose logs app`.
