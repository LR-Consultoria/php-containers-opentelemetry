ARG PHP_VERSION=8.3
FROM dunglas/frankenphp:1-php${PHP_VERSION}-alpine

LABEL maintainer="LR Consultoria <devops@lrconsultoria.com.br>"
LABEL description="PHP ${PHP_VERSION} FrankenPHP Alpine with OpenTelemetry for modern web applications"

## Install PHP extensions
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN install-php-extensions opentelemetry grpc    


# Copy PHP configuration
COPY configs/php-franken.ini /usr/local/etc/php/conf.d/
COPY configs/Caddyfile /etc/caddy/Caddyfile
COPY configs/entrypoint.sh /usr/local/bin/

# Set working directory
WORKDIR /var/www

# Create www-data user with proper permissions
RUN addgroup -g 1000 www-data \
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

