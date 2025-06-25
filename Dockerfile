FROM php:8.3.20-fpm-alpine AS production

ARG UID=1000
ARG GID=1000

USER root

# Install system dependencies
RUN apk update && apk add curl libpng-dev oniguruma-dev libxml2-dev zip unzip shadow linux-headers npm

# Set www-data user and group to match host UID/GID
RUN groupmod -g ${GID} www-data && \
    usermod -u ${UID} -g ${GID} www-data

# Clear cache
RUN apk cache clean

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd sockets

# Get latest Composer and copy the application source code
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY . /var/www/html

WORKDIR /var/www/html

# Install composer dependencies
RUN composer install --prefer-dist --no-cache

# Run migrations
RUN php artisan migrate

# Generate application key
RUN php artisan key:generate

# Install node dependencies
RUN npm install

USER www-data
