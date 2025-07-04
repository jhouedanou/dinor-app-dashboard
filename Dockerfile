FROM php:8.2-fpm

# Set working directory
WORKDIR /var/www/html

# Install system dependencies
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
    apt-transport-https

# Install Node.js 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql pdo_pgsql mbstring exif pcntl bcmath gd zip intl

# Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy nginx configuration
COPY docker/nginx/default.conf /etc/nginx/sites-available/default

# Copy supervisor configuration
COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy existing application directory contents
COPY . /var/www/html

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www/html

# Create .env file from example if it doesn't exist
RUN if [ ! -f .env ]; then cp .env.example .env; fi

# Set cache driver to file for build process to avoid Redis dependency
RUN sed -i 's/CACHE_DRIVER=redis/CACHE_DRIVER=file/' .env || echo "CACHE_DRIVER=file" >> .env
RUN sed -i 's/SESSION_DRIVER=redis/SESSION_DRIVER=file/' .env || echo "SESSION_DRIVER=file" >> .env

# Add git safe directory configuration
RUN git config --global --add safe.directory /var/www/html || true

# Create necessary cache directories
RUN mkdir -p /var/www/html/storage/framework/cache/data
RUN mkdir -p /var/www/html/storage/framework/sessions
RUN mkdir -p /var/www/html/storage/framework/views
RUN mkdir -p /var/www/html/bootstrap/cache

# Create log directories for supervisor
RUN mkdir -p /var/log/supervisor

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html
RUN chmod -R 775 /var/www/html/storage
RUN chmod -R 775 /var/www/html/bootstrap/cache

# Install dependencies (force environment variables for cache during build)
ENV CACHE_DRIVER=file
ENV SESSION_DRIVER=file
ENV APP_KEY=base64:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
RUN composer install --optimize-autoloader --no-scripts --no-dev

# Install npm dependencies
RUN npm install

# Build assets initially (can be overridden in dev mode)
RUN npm run build

# Create entrypoint script
RUN echo '#!/bin/bash\n\
# Start supervisor with all services (nginx, php-fpm, and vite)\n\
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf' > /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose port 80
EXPOSE 80

# Use the entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"] 