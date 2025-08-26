ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-alpine

LABEL maintainer="LR Consultoria <devops@lrconsultoria.com.br>"
LABEL description="PHP ${PHP_VERSION} Alpine with Swoole and OpenTelemetry for high-performance applications"

# Install system dependencies
RUN apk add --no-cache \
    bash \
    curl \
    freetype-dev \
    g++ \
    gcc \
    git \
    icu-dev \
    jpeg-dev \
    libc-dev \
    libpng-dev \
    libxml2-dev \
    libzip-dev \
    make \
    mysql-client \
    nodejs \
    npm \
    oniguruma-dev \
    openssl-dev \
    postgresql-dev \
    sqlite-dev \
    unzip \
    zip \
    && rm -rf /var/cache/apk/*

# Configure and install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-configure intl \
    && docker-php-ext-install -j$(nproc) \
    bcmath \
    calendar \
    exif \
    gd \
    gettext \
    intl \
    mysqli \
    opcache \
    pdo \
    pdo_mysql \
    pdo_pgsql \
    pdo_sqlite \
    pcntl \
    sockets \
    soap \
    zip

# Install Swoole extension
RUN pecl install swoole \
    && docker-php-ext-enable swoole

# Install OpenTelemetry extension
RUN pecl install opentelemetry \
    && docker-php-ext-enable opentelemetry

# Install Redis extension
RUN pecl install redis \
    && docker-php-ext-enable redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy PHP configuration for Swoole
COPY configs/php-swoole.ini /usr/local/etc/php/conf.d/
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
    CMD curl -f http://localhost:8000/health || exit 1

# Expose port
EXPOSE 8000

# Set entrypoint
ENTRYPOINT ["entrypoint.sh"]

# Default command
CMD ["php", "artisan", "octane:start", "--server=swoole", "--host=0.0.0.0", "--port=8000"]
