# PHP versions
# https://www.php.net/supported-versions.php

# Build all image variants
docker build -t zouloux/docker-debian-apache-php:PHP7.2 . --build-arg IMAGE_PHP_VERSION=7.2
docker build -t zouloux/docker-debian-apache-php:PHP7.3 . --build-arg IMAGE_PHP_VERSION=7.3
docker build -t zouloux/docker-debian-apache-php:PHP7.4 . --build-arg IMAGE_PHP_VERSION=7.4
docker build -t zouloux/docker-debian-apache-php:PHP8.0 . --build-arg IMAGE_PHP_VERSION=8.0

# Push all images variants
docker push zouloux/docker-debian-apache-php:PHP7.2
docker push zouloux/docker-debian-apache-php:PHP7.3
docker push zouloux/docker-debian-apache-php:PHP7.4
docker push zouloux/docker-debian-apache-php:PHP8.0
