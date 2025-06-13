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
    supervisor \
    nginx

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip intl

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

# Set proper permissions
RUN chown -R www-data:www-data /var/www/html
RUN chmod -R 755 /var/www/html
RUN chmod -R 775 /var/www/html/storage
RUN chmod -R 775 /var/www/html/bootstrap/cache

# Install dependencies (force environment variables for cache during build)
ENV CACHE_DRIVER=file
ENV SESSION_DRIVER=file
RUN composer install --optimize-autoloader --no-dev

# Generate application key first (needed for caching)
RUN php artisan key:generate --force

# Clear any existing cache and generate new cache
RUN php artisan config:clear
RUN php artisan config:cache
RUN php artisan route:cache
RUN php artisan view:cache

# Create entrypoint script
RUN echo '#!/bin/bash\n\
# Wait for database to be ready\n\
echo "Waiting for database..."\n\
until php artisan migrate:status 2>/dev/null; do\n\
    echo "Database not ready yet, waiting..."\n\
    sleep 2\n\
done\n\
\n\
# Switch back to Redis for production\n\
sed -i "s/CACHE_DRIVER=file/CACHE_DRIVER=redis/" /var/www/html/.env\n\
sed -i "s/SESSION_DRIVER=file/SESSION_DRIVER=redis/" /var/www/html/.env\n\
\n\
# Run migrations\n\
echo "Running migrations..."\n\
php artisan migrate --force\n\
\n\
# Seed database if not already seeded\n\
echo "Seeding database..."\n\
php artisan db:seed --force\n\
\n\
# Create storage link\n\
php artisan storage:link\n\
\n\
# Clear and cache config\n\
php artisan config:clear\n\
php artisan config:cache\n\
\n\
# Start supervisor\n\
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf' > /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose port 80
EXPOSE 80

# Use the entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"] 