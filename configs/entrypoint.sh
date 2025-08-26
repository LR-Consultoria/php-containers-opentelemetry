#!/bin/sh
set -e

# Set proper permissions
chown -R www-data:www-data /var/www
chmod -R 755 /var/www

# If running in development mode
if [ "$APP_ENV" = "local" ]; then
    echo "Running in development mode"
    # Enable more verbose error reporting
    sed -i 's/display_errors = Off/display_errors = On/g' /usr/local/etc/php/conf.d/php-production.ini
    sed -i 's/opcache.validate_timestamps = 0/opcache.validate_timestamps = 1/g' /usr/local/etc/php/conf.d/php-production.ini
fi

# Execute the main command
exec "$@"
