ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-fpm-alpine

LABEL maintainer="LR Consultoria <devops@lrconsultoria.com.br>"
LABEL description="PHP ${PHP_VERSION} FPM Alpine base image with OpenTelemetry and Laravel optimizations"


# Install system dependencies
RUN apk add --no-cache \
    curl \
    bash \
    && rm -rf /var/cache/apk/*

## Install PHP extensions
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN install-php-extensions opentelemetry grpc    

# Copy PHP configuration
COPY configs/php-production.ini /usr/local/etc/php/conf.d/
COPY configs/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
COPY configs/entrypoint.sh /usr/local/bin/

# Set working directory
WORKDIR /var/www

# Modify existing www-data user to use UID/GID 1000
RUN deluser www-data && delgroup www-data \
    && addgroup -g 1000 www-data \
    && adduser -u 1000 -G www-data -s /bin/sh -D www-data

# Set proper permissions
RUN chown -R www-data:www-data /var/www \
    && chmod +x /usr/local/bin/entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:9000/ping || exit 1

# Expose port
EXPOSE 9000

# Set entrypoint
ENTRYPOINT ["entrypoint.sh"]

# Default command
CMD ["php-fpm"]
