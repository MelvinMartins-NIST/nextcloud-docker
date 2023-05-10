# Dockerfile
FROM php:8.2.5-apache

# Allow Composer to run as superuser
ENV COMPOSER_ALLOW_SUPERUSER 1

# Install dependencies
WORKDIR /var/www/html
COPY nextcloud-api/composer.json nextcloud-api/composer.lock ./

# Update CA certificates and install Composer
RUN apt-get update && apt-get install -y ca-certificates curl unzip git && rm -rf /var/lib/apt/lists/* \
    && curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

# Verify if composer is available
RUN composer --version

# Run Composer
RUN composer install

# Copy Nextcloud API files
COPY nextcloud-api/ ./
RUN chown -R www-data:www-data /var/www/html/
RUN chmod -R 0755 /var/www/html/

# Configure Apache2
COPY 000-default.conf /etc/apache2/sites-available/000-default.conf

# Copy SSL certificates
COPY default-ssl.conf /etc/apache2/sites-available/default-ssl.conf
COPY certs/nextcloud-dev.cer /etc/ssl/certs/nextcloud-dev.cer
COPY certs/nextcloud-dev.key /etc/ssl/private/nextcloud-dev.key

# Enable SSL in Apache
RUN a2enmod ssl && \
    a2ensite default-ssl
