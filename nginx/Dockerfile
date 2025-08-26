ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-fpm-alpine

LABEL maintainer="LR Consultoria <devops@lrconsultoria.com.br>"
LABEL description="PHP ${PHP_VERSION} FPM + Nginx Alpine with OpenTelemetry for web applications"

## Install PHP extensions
ADD --chmod=0755 https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN install-php-extensions opentelemetry grpc    

# Copy configurations
COPY configs/php-production.ini /usr/local/etc/php/conf.d/
COPY configs/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
COPY configs/nginx.conf /etc/nginx/nginx.conf
COPY configs/default.conf /etc/nginx/conf.d/default.conf
COPY configs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY configs/entrypoint.sh /usr/local/bin/

# Create necessary directories
RUN mkdir -p /var/log/supervisor \
    && mkdir -p /var/log/nginx \
    && mkdir -p /run/nginx

# Set working directory
WORKDIR /var/www

# Create www-data user with proper permissions
RUN addgroup -g 1000 www-data \
    && adduser -u 1000 -G www-data -s /bin/sh -D www-data

# Set proper permissions
RUN chown -R www-data:www-data /var/www \
    && chown -R www-data:www-data /var/log/nginx \
    && chmod +x /usr/local/bin/entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/nginx-health || exit 1

# Expose port
EXPOSE 80

# Set entrypoint
ENTRYPOINT ["entrypoint.sh"]

# Default command
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
