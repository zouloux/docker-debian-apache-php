# Docker Image Debian Apache PHP
LAP Docker image based on Debian, with Apache 2.4, and PHP (7.2 to 7.4).


## Installation
This Docker image is not pushed to Docker hub. To use it, intall it as a git submodule and target it directly from your `docker-compose`.
It is adviced to clone submodule into a `deploy` or `docker` directory, but optionnal.

```
mkdir deploy
cd deploy
git submodule add git@github.com:zouloux/docker-debian-apache-php.git
```



## Docker compose examples

Use `args` to specify current php version. Default PHP version is `7.4`.


#### Map volumes

- `/root` is user root directory. Can be used to run processes outside `/public` directory.
- `/public` is root published directory by Apache.


```docker-compose
version: "3.7"
services:
  lap :
    build: deploy/docker-debian-apache-php
    volumes:
      - './:/root'
      - './dist:/public'
```


#### Specify which PHP version to build / use

Default version is PHP `7.4`.


```docker-compose
version: "3.7"
services:
  lap :
    build:
      context: deploy/docker-debian-apache-php
      args:
        IMAGE_PHP_VERSION: 7.3
    volumes:
      - './:/root'
      - './dist:/public'
```


#### Enable apache login / password for public directory

This HTTP password will be required on all `/public` directory.

```docker-compose
version: "3.7"
services:
  lap :
    build:
      context: deploy/docker-debian-apache-php
      args:
        IMAGE_PHP_VERSION: 7.3
    environment:
      APACHE_LOGIN: admin
      APACHE_PASSWORD: secret
    volumes:
      - './:/root'
      - './dist:/public'
```


#### Use envs

A `dotenv` file can also be used for convenience.

```docker-compose
version: "3.7"
services:
  lap :
    build:
      context: deploy/docker-debian-apache-php
      args:
        IMAGE_PHP_VERSION: ${PHP_VERSION:-}
    environment:
      APACHE_LOGIN: ${APACHE_LOGIN:-}
      APACHE_PASSWORD: ${APACHE_PASSWORD:-}
      APACHE_DEVTOOLS: ${APACHE_DEVTOOLS:-}
    volumes:
      - './:/root'
      - './dist:/public'
```


`.env` file :
```
PHP_VERSION=7.2
APACHE_LOGIN=admin
APACHE_PASSWORD=secret
APACHE_DEVTOOLS=true
```