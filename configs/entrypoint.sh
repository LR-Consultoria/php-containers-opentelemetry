#!/bin/sh
set -e

# Set proper permissions
chown -R www-data:www-data /var/www
chmod -R 755 /var/www

# If running in development mode
if [ "$APP_ENV" = "local" ]; then
    echo "Running in development mode"
    INI_FILE=/usr/local/etc/php/conf.d/php-franken.ini
    if [ -f "$INI_FILE" ]; then
        sed -i 's/^display_errors = Off/display_errors = On/' "$INI_FILE"
        sed -i 's/^opcache.validate_timestamps = 0/opcache.validate_timestamps = 1/' "$INI_FILE"
    fi
fi

# Execute the main command
exec "$@"
