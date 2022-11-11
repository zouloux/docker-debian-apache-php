# PHP versions
# https://www.php.net/supported-versions.php

# Create and use CrossBuilder to be able to build for amd64 and arm64
docker buildx use CrossBuilder || (docker buildx create CrossBuilder && docker buildx use CrossBuilder)

# PHP 8.0 - latest
docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile -t zouloux/docker-debian-apache-php:8.0 -t zouloux/docker-debian-apache-php:latest --build-arg IMAGE_PHP_VERSION=8.0 --push .

# PHP 8.1 - next
docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile -t zouloux/docker-debian-apache-php:8.1 -t zouloux/docker-debian-apache-php:next --build-arg IMAGE_PHP_VERSION=8.1 --push .

# PHP 7.2 ( legacy )
docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile -t zouloux/docker-debian-apache-php:7.2 --build-arg IMAGE_PHP_VERSION=7.2 --push .

# PHP 7.3 ( legacy )
docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile -t zouloux/docker-debian-apache-php:7.3 --build-arg IMAGE_PHP_VERSION=7.3 --push .

# PHP 7.4 ( legacy )
docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile -t zouloux/docker-debian-apache-php:7.4 --build-arg IMAGE_PHP_VERSION=7.4 --push .
