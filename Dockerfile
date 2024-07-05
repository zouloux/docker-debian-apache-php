# https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-debian-11
# https://www.itzgeek.com/how-tos/linux/debian/how-to-install-php-7-3-7-2-7-1-on-debian-10-debian-9-debian-8.html
# https://github.com/dockerwest/php/blob/master/8.0/scripts/install.sh

FROM debian:12-slim

# Default PHP version, and expose env to be used in RUN commands
ARG IMAGE_PHP_VERSION=8.3
ENV IMAGE_PHP_VERSION=${IMAGE_PHP_VERSION}

# Set default environment variables for Apache
ENV DDAP_PUBLIC_PATH=/var/www/html \
	DDAP_BASE=/ \
	DDAP_DEVTOOLS=false \
    DDAP_DEVTOOLS_URL=/devtools \
    DDAP_PHP_DISPLAY_ERRORS=true \
	DDAP_PHP_TIMEZONE=UTC \
    DDAP_PHP_MEMORY_LIMIT=256M \
    DDAP_PHP_MAX_EXECUTION_TIME=30 \
    DDAP_PHP_UPLOAD_SIZE=128M

SHELL ["/bin/bash", "-c"]

# Setup sury php source and add it to apt
RUN apt update -qy && apt install -qy gnupg2 curl lsb-release gettext zip unzip \
	&& curl https://packages.sury.org/php/apt.gpg -o apt.gpg && apt-key add apt.gpg \
	&& echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
	&& apt update -qy

# Install PHP-FPM and apache
RUN apt install -qy php${IMAGE_PHP_VERSION}-fpm apache2 libapache2-mod-fcgid

# Enable necessary Apache modules
RUN a2enmod actions fcgid alias proxy_fcgi rewrite expires deflate brotli remoteip headers setenvif

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

# Clean apt after all apt installs
RUN apt clean && rm -rf /var/lib/apt/lists/*

# Install composer
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Enable custom php configuration and opcache config
RUN phpenmod custom && phpenmod opcache_settings

# Configure PHP-FPM
RUN sed -e 's#^\(error_log\).*#\1 = /dev/stderr#' \
    -i /etc/php/${IMAGE_PHP_VERSION}/fpm/php-fpm.conf

RUN sed \
    -e 's#^;\(access.log\).*#\1 = /dev/stderr#' \
    -e 's#^\(listen\).*#\1 = 0.0.0.0:9000#' \
    -e 's#^;\(catch_workers_output\).*#\1 = yes#' \
    -e 's#^;\(clear_env\).*#\1 = no#' \
    -e 's#^;\(ping\)#\1#g' \
    -i /etc/php/${IMAGE_PHP_VERSION}/fpm/pool.d/www.conf

RUN sed \
	-e 's/^user = www-data/;user = www-data/' \
	-e 's/^group = www-data/;group = www-data/' \
	-e 's|listen = /run/php/php${IMAGE_PHP_VERSION}-fpm.sock|listen = 127.0.0.1:9000|' \
	-i /etc/php/${IMAGE_PHP_VERSION}/fpm/pool.d/www.conf

# Setup apache to use PHP-FPM for all php files
RUN echo '<FilesMatch \.php$>' > /etc/apache2/conf-available/php-fpm.conf; \
    echo '    SetHandler "proxy:fcgi://127.0.0.1:9000"' >> /etc/apache2/conf-available/php-fpm.conf; \
    echo '</FilesMatch>' >> /etc/apache2/conf-available/php-fpm.conf; \
    a2enconf php-fpm

# Configure PHP-FPM to log access logs to /dev/null
RUN sed -i 's|^access.log =.*|access.log = /dev/null|' /etc/php/${IMAGE_PHP_VERSION}/fpm/pool.d/www.conf \
    && sed -i 's|^error_log =.*|error_log = /dev/stderr|' /etc/php/${IMAGE_PHP_VERSION}/fpm/php-fpm.conf

# Configure PHP-FPM to streamline error logs
RUN sed -i 's|^;log_level = notice|log_level = error|' /etc/php/${IMAGE_PHP_VERSION}/fpm/php-fpm.conf \
    && sed -i 's|^;catch_workers_output = yes|catch_workers_output = no|' /etc/php/${IMAGE_PHP_VERSION}/fpm/pool.d/www.conf \
    && sed -i 's|^;php_flag[display_errors] = off|php_flag[display_errors] = on|' /etc/php/${IMAGE_PHP_VERSION}/fpm/pool.d/www.conf \
    && sed -i 's|^;php_admin_value[error_log] = /var/log/fpm-php.www.log|php_admin_value[error_log] = /dev/stderr|' /etc/php/${IMAGE_PHP_VERSION}/fpm/pool.d/www.conf \
    && sed -i 's|^;php_admin_flag[log_errors] = on|php_admin_flag[log_errors] = on|' /etc/php/${IMAGE_PHP_VERSION}/fpm/pool.d/www.conf

# Set default server name
RUN echo 'ServerName localhost' >> /etc/apache2/apache2.conf

# Patch user rights for non root users
RUN mkdir -p /var/log /run/php /var/www /var/run/apache2 /auth /var/www/data && \
    chown -R www-data:www-data /var/log /run/php /var/www /var/run/apache2 /usr/local/bin /etc/php /var/lib/php /etc/apache2 /var/lib/apache2 /auth /var/www/data && \
    chmod -R 0777 /run/php

# Copy devtools
COPY devtools/ /devtools/
RUN chown -R www-data:www-data /devtools && chmod -R 775 /devtools

# Copy runtime configs
COPY config /config
RUN chown -R www-data:www-data /config && chmod -R 775 /config

# Copy runtime scripts
COPY scripts/ /scripts/
RUN chown -R www-data:www-data /scripts && chmod -R 755 /scripts

RUN mkdir /var/empty

# Link apache and php configs to mountable config files with their default values
RUN ln -sf /config/app.conf /etc/apache2/conf-available/zzz-app.conf; \
    ln -sf /config/devtools.conf /etc/apache2/conf-available/zzz-devtools.conf; \
    ln -sf /config/password.conf /etc/apache2/conf-available/zzz-password.conf; \
    ln -sf /config/vhost.conf /etc/apache2/sites-available/000-default.conf; \
    ln -sf /config/php.ini /etc/php/${IMAGE_PHP_VERSION}/fpm/php.ini

# Switch to non-root user
USER www-data

WORKDIR /var/www
EXPOSE 80

# Start Apache and PHP-FPM
CMD ["bash", "-c", "/scripts/start.sh"]