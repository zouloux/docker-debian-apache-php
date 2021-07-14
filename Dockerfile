# Inspired from
# - https://blog.silarhi.fr/image-docker-php-apache-parfaite/
# - https://semaphoreci.com/community/tutorials/dockerizing-a-php-application
# - https://www.pascallandau.com/blog/structuring-the-docker-setup-for-php-projects/
ARG IMAGE_PHP_VERSION=7.4
FROM php:${IMAGE_PHP_VERSION}-apache

# Install utils
RUN apt update -qq
RUN apt install -qy \
    git gnupg \
    zip unzip libzip-dev \
    libpng-dev libjpeg-dev libfreetype6-dev \
    libicu-dev libxml2-dev \
    sendmail sendmail-cf m4

# Install composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# GD configration depends on installed PHP version ...
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ \
    || docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/;

# PHP Extensions
RUN docker-php-ext-configure intl
RUN docker-php-ext-install -j$(nproc) opcache pdo pdo_mysql gd zip intl soap mysqli

# Apcu is only available with pecl. Extension will be loaded in php.ini
RUN pecl install apcu

# Clean
RUN apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy config files
COPY config/app.conf /etc/apache2/conf-available/zzz-app.conf
COPY config/devtools.conf /etc/apache2/conf-available/zzz-devtools.conf
COPY config/password.conf /etc/apache2/conf-available/zzz-password.conf
COPY config/php.ini /usr/local/etc/php/conf.d/app.ini
COPY config/vhost.conf /etc/apache2/sites-available/000-default.conf

# Copy devtools
COPY devtools/ /devtools/

# Install apache mods and configs
RUN a2enmod rewrite remoteip headers
RUN a2enconf zzz-app

# Copy entry point middleware
COPY entry-point.sh /entry-point.sh
RUN chmod +x /entry-point.sh

# Expose server
EXPOSE 80
WORKDIR /root

# Start
CMD ["/entry-point.sh"]
