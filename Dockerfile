# https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-debian-11
# https://www.itzgeek.com/how-tos/linux/debian/how-to-install-php-7-3-7-2-7-1-on-debian-10-debian-9-debian-8.html

FROM debian:11-slim
ARG IMAGE_PHP_VERSION=8.0
SHELL ["/bin/bash", "-c"]
WORKDIR /root

# Install all dependencies
RUN apt update -qy && apt install -qy gnupg2 curl git sendmail zip unzip lsb-release gettext-base

# Setup sury php source and add it to apt
# ca-certificates apt-transport-https
RUN curl https://packages.sury.org/php/apt.gpg -o apt.gpg && apt-key add apt.gpg
RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
RUN apt update -qy

# Install Apache 2.4 and PHP FPM
RUN apt install -qy apache2 php${IMAGE_PHP_VERSION}-fpm

# We use mpm_event instead of mpm_prefor here for less RAM usage with threads
RUN a2dismod mpm_prefork && a2enmod mpm_event proxy_fcgi

# Forward request and error logs to docker log collector
RUN ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log";
RUN ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log";

# Install PHP extensions
RUN apt install -qy \
    php${IMAGE_PHP_VERSION}-common \
    php${IMAGE_PHP_VERSION}-opcache php${IMAGE_PHP_VERSION}-apcu php${IMAGE_PHP_VERSION}-memcached \
    php${IMAGE_PHP_VERSION}-mysqli php${IMAGE_PHP_VERSION}-mysql php${IMAGE_PHP_VERSION}-pdo php${IMAGE_PHP_VERSION}-pdo-mysql php${IMAGE_PHP_VERSION}-pdo-sqlite \
    php${IMAGE_PHP_VERSION}-zip php${IMAGE_PHP_VERSION}-bz2 \
    php${IMAGE_PHP_VERSION}-gd php${IMAGE_PHP_VERSION}-intl php${IMAGE_PHP_VERSION}-tokenizer php${IMAGE_PHP_VERSION}-mbstring \
    php${IMAGE_PHP_VERSION}-dom php${IMAGE_PHP_VERSION}-simplexml php${IMAGE_PHP_VERSION}-xml \
    php${IMAGE_PHP_VERSION}-curl

# Install mcrypt only prior to php 8.2 ( deprecated and not available after this version )
RUN if [ "$IMAGE_PHP_VERSION" = "7.2" ] || [ "$IMAGE_PHP_VERSION" = "7.3" ] || [ "$IMAGE_PHP_VERSION" = "7.4" ] || [ "$IMAGE_PHP_VERSION" = "8.0" ] || [ "$IMAGE_PHP_VERSION" = "8.1" ]; \
    then apt-get install -qy php${IMAGE_PHP_VERSION}-mcrypt; fi

# Enable apache modules
RUN a2enmod rewrite expires deflate brotli remoteip headers setenvif

# Clean
RUN apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy config directory and link each files
COPY config /config
RUN ln -sf /config/app.conf /etc/apache2/conf-available/zzz-app.conf; \
    ln -sf /config/devtools.conf /etc/apache2/conf-available/zzz-devtools.conf; \
    ln -sf /config/password.conf /etc/apache2/conf-available/zzz-password.conf; \
#    ln -sf /config/php.ini /etc/php/${IMAGE_PHP_VERSION}/apache2/conf.d/app.ini; \
    ln -sf /config/php.ini /etc/php/${IMAGE_PHP_VERSION}/fpm/php.ini; \
    ln -sf /config/vhost.conf /etc/apache2/sites-available/000-default.conf;

# Forward request and error logs to docker log collector
RUN ln -sfT /dev/stderr "/var/log/apache2/error.log";
RUN ln -sfT /dev/stdout "/var/log/apache2/access.log";

# Enable main app conf. Prefixed with "zzz" so it's included in last.
RUN a2enconf zzz-app

# Enable PHP FPM
RUN a2enconf php${IMAGE_PHP_VERSION}-fpm

# Copy devtools
COPY devtools/ /devtools/

# Copy startup scripts
# Those script will be executed in runtime, not at buildtime, because of $envs
COPY scripts/ /scripts/

# Patch root rights before volumes are mapped
RUN chmod -R +x /scripts/
RUN chmod 655 /root

# For https://stackoverflow.com/questions/22215173/session-error-permisison-denied-13
RUN chmod 777 /var/lib/php/sessions

# Expose main server port
EXPOSE 80

# Start apache in foreground mode.
# If apache crashes, the container will also fall.
ENV IMAGE_PHP_VERSION="${IMAGE_PHP_VERSION}"
CMD "/scripts/start.sh"
