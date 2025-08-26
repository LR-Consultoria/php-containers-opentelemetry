ARG PHP_VERSION=8.3
FROM dunglas/frankenphp:1-php${PHP_VERSION}-alpine

LABEL maintainer="LR Consultoria <devops@lrconsultoria.com.br>"
LABEL description="PHP ${PHP_VERSION} FrankenPHP Alpine with OpenTelemetry for modern web applications"

# Install system dependencies and PHP extensions in one layer
RUN apk add --no-cache curl bash \
    && curl -sSLf -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    && chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions opentelemetry grpc \
    && rm -rf /var/cache/apk/* /tmp/*    

# Copy PHP configuration
COPY configs/php-franken.ini /usr/local/etc/php/conf.d/
COPY configs/Caddyfile /etc/caddy/Caddyfile
COPY configs/entrypoint.sh /usr/local/bin/

# Set working directory
WORKDIR /var/www

# Modify existing www-data user to use UID/GID 1000
RUN (deluser www-data 2>/dev/null || true) && (delgroup www-data 2>/dev/null || true) \
    && addgroup -g 1000 www-data \
    && adduser -u 1000 -G www-data -s /bin/sh -D www-data

# Set proper permissions
RUN chown -R www-data:www-data /var/www \
    && chmod +x /usr/local/bin/entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Expose ports
EXPOSE 80 443

# Set entrypoint
ENTRYPOINT ["entrypoint.sh"]

