# Inspired from
# - https://blog.silarhi.fr/image-docker-php-apache-parfaite/
# - https://semaphoreci.com/community/tutorials/dockerizing-a-php-application
# - https://www.pascallandau.com/blog/structuring-the-docker-setup-for-php-projects/
ARG IMAGE_PHP_VERSION=7.4
FROM php:${IMAGE_PHP_VERSION}-apache
SHELL ["/bin/bash", "-c"]

# Install utils
RUN apt update -qq && apt install -qy \
    git gnupg \
    zip unzip libzip-dev \
    libpng-dev libjpeg-dev libfreetype6-dev libwebp-dev \
    libicu-dev libxml2-dev \
    memcached libmemcached-dev libmemcached-tools libzip-dev \
    sendmail sendmail-cf m4

# Go to bash and get back php version here
ARG IMAGE_PHP_VERSION=7.4
RUN MAJOR_PHP_VERSION=`echo $IMAGE_PHP_VERSION | cut -c1-1`
RUN echo "Using major version ${MAJOR_PHP_VERSION} and full version ${IMAGE_PHP_VERSION}"

# GD configration depends on installed PHP version ...
RUN if test "${IMAGE_PHP_VERSION}" = "7.2" || test "${IMAGE_PHP_VERSION}" = "7.3" ; then \
      docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-webp-dir=/usr; \
    else \
      docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ --with-webp=/usr; \
    fi;

# Configure PHP Extensions
RUN docker-php-ext-configure intl \
    && docker-php-ext-configure zip

# Install PHP extensions
RUN docker-php-ext-install -j$(nproc) opcache pdo pdo_mysql gd zip intl soap mysqli

# Apcu and memcached are only available with pecl. APCU extension will be loaded in php.ini
RUN pecl install apcu; pecl install memcached
RUN docker-php-ext-enable memcached

# Install composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Clean
RUN apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy config directory and link each files
COPY config /config
RUN ln -sf /config/app.conf /etc/apache2/conf-available/zzz-app.conf; \
    ln -sf /config/devtools.conf /etc/apache2/conf-available/zzz-devtools.conf; \
    ln -sf /config/password.conf /etc/apache2/conf-available/zzz-password.conf; \
    ln -sf /config/php.ini /usr/local/etc/php/conf.d/app.ini; \
    ln -sf /config/vhost.conf /etc/apache2/sites-available/000-default.conf;

# Copy devtools
COPY devtools/ /devtools/

# Install memcache admin in dev tools
RUN git clone https://github.com/hatamiarash7/Memcached-Admin.git /tmp/memcached-admin
RUN mv /tmp/memcached-admin/app /devtools/memcached
RUN rm -rf /tmp/memcached-admin

# Install apache mods and configs
RUN a2enmod rewrite remoteip headers
RUN a2enconf zzz-app

# Copy entry point middleware
COPY entry-point.sh /entry-point.sh
RUN chmod +x /entry-point.sh

# Expose server
EXPOSE 80
WORKDIR /root

# Patch root rights before volumes are mapped
RUN chmod 655 /root

# Start
CMD ["/entry-point.sh"]
