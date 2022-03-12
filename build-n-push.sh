# PHP versions
# https://www.php.net/supported-versions.php

# -------- NAMED TAGS

# Latest = 8.0
docker build -t ddap:latest . --build-arg IMAGE_PHP_VERSION=8.0
docker tag ddap:latest zouloux/docker-debian-apache-php:latest
docker push zouloux/docker-debian-apache-php:latest

# Next = 8.1
docker build -t ddap:next . --build-arg IMAGE_PHP_VERSION=8.1
docker tag ddap:next zouloux/docker-debian-apache-php:next
docker push zouloux/docker-debian-apache-php:next

# -------- VERSIONS

# Legacy 7.2
docker build -t ddap:PHP7.2 . --build-arg IMAGE_PHP_VERSION=7.2
docker tag ddap:PHP7.2 zouloux/docker-debian-apache-php:PHP7.2
docker push zouloux/docker-debian-apache-php:PHP7.2

# Legacy 7.3
docker build -t ddap:PHP7.3 . --build-arg IMAGE_PHP_VERSION=7.3
docker tag ddap:PHP7.3 zouloux/docker-debian-apache-php:PHP7.3
docker push zouloux/docker-debian-apache-php:PHP7.3

# Legacy 7.4
docker build -t ddap:PHP7.4 . --build-arg IMAGE_PHP_VERSION=7.4
docker tag ddap:PHP7.4 zouloux/docker-debian-apache-php:PHP7.4
docker push zouloux/docker-debian-apache-php:PHP7.4

# Current 8.0
docker build -t ddap:PHP8.0 . --build-arg IMAGE_PHP_VERSION=8.0
docker tag ddap:PHP8.0 zouloux/docker-debian-apache-php:PHP8.0
docker push zouloux/docker-debian-apache-php:PHP8.0

# Next 8.1
docker build -t ddap:PHP8.1 . --build-arg IMAGE_PHP_VERSION=8.1
docker tag ddap:PHP8.1 zouloux/docker-debian-apache-php:PHP8.1
docker push zouloux/docker-debian-apache-php:PHP8.1

