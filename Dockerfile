# Inspired from
# - https://blog.silarhi.fr/image-docker-php-apache-parfaite/
# - https://semaphoreci.com/community/tutorials/dockerizing-a-php-application
# - https://www.pascallandau.com/blog/structuring-the-docker-setup-for-php-projects/

# Build X
# - https://www.docker.com/blog/faster-multi-platform-builds-dockerfile-cross-compilation-guide/
# Here $BUILDPLATFORM is m1 so we do not want that.
#FROM --platform=$BUILDPLATFORM php:${IMAGE_PHP_VERSION}-apache

ARG IMAGE_PHP_VERSION=8.0
FROM php:${IMAGE_PHP_VERSION}-apache
SHELL ["/bin/bash", "-c"]

# We need to reassign ARG here after FROM
ARG IMAGE_PHP_VERSION=8.0
RUN echo "Building image with php${IMAGE_PHP_VERSION}"

# Install dependencies
RUN apt update -q && apt install -qy git sendmail sendmail-cf

# We use this script and docker-php-ext which seems to work better with buildx
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Install php extensions
RUN install-php-extensions opcache pdo_mysql gd zip intl soap mysqli mcrypt apcu bz2 memcached

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
