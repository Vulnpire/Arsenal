FROM php:8.2-fpm

# Gerekli paketlerin kurulumu
RUN apt-get update && apt-get install -y \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    curl \
    git \
    build-essential \
    libmagickwand-dev \
    libexif-dev \
    libjpeg62

# GD kurulumu
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo pdo_mysql exif zip

# Imagick kurulumu
RUN pecl install imagick \
    && docker-php-ext-enable imagick

# Composer'ı kopyala
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Çalışma dizini
WORKDIR /var/www/html

# Proje dosyalarını kopyala
COPY . .

# Git güvenlik uyarısını önlemek için
RUN git config --global --add safe.directory /var/www/html

# Composer bağımlılıklarını yükle (update yerine install daha güvenlidir)
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Laravel klasör izinleri
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

