# Multi-stage build pour optimiser le cache BuildKit
FROM php:8.2-fpm as base

# Set working directory
WORKDIR /var/www/html

# Install system dependencies (layer stable - rarement modifié)
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    libpq-dev \
    supervisor \
    nginx \
    gnupg \
    apt-transport-https \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# Install PHP extensions (layer stable - rarement modifié)
RUN docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd zip intl \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && rm -rf /tmp/pear

# Install Composer (layer stable)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy configuration files (layer stable - rarement modifié)
COPY docker/nginx/default.conf /etc/nginx/sites-available/default
COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Dependencies stage - optimisé pour le cache
FROM base as dependencies

# Copy package files first for better caching (invalidé seulement si dependencies changent)
COPY composer.json composer.lock ./
COPY package.json package-lock.json ./

# Install dependencies with cache mounts pour BuildKit
RUN --mount=type=cache,target=/root/.composer/cache \
    --mount=type=cache,target=/root/.npm \
    composer install --optimize-autoloader --no-scripts --no-dev --no-interaction \
    && npm ci

# Production stage
FROM dependencies as production

# Copy source code (layer invalidé seulement quand le code change)
COPY --chown=www-data:www-data . /var/www/html

# Create .env file from example if it doesn't exist
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Set cache driver to file for build process to avoid Redis dependency
RUN sed -i 's/CACHE_DRIVER=redis/CACHE_DRIVER=file/' .env || echo "CACHE_DRIVER=file" >> .env && \
    sed -i 's/SESSION_DRIVER=redis/SESSION_DRIVER=file/' .env || echo "SESSION_DRIVER=file" >> .env

# Add git safe directory configuration
RUN git config --global --add safe.directory /var/www/html || true

# Create necessary directories and set permissions
RUN mkdir -p /var/www/html/storage/framework/{cache/data,sessions,views} \
    && mkdir -p /var/www/html/bootstrap/cache \
    && mkdir -p /var/log/supervisor \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/storage \
    && chmod -R 775 /var/www/html/bootstrap/cache

# Set environment variables for build
ENV CACHE_DRIVER=file \
    SESSION_DRIVER=file \
    APP_KEY=base64:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=

# Build assets with cache mount pour optimiser les builds
RUN --mount=type=cache,target=/root/.npm \
    npm ci && npm run build && npm run pwa:build && npm prune --production

# Create entrypoint script
RUN echo '#!/bin/bash\n\
# Start supervisor with all services (nginx, php-fpm, and vite)\n\
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf' > /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

# Expose port 80
EXPOSE 80

# Use the entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]