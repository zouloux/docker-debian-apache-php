# Docker Image Debian Apache PHP
LAP Docker image based on Debian, with Apache 2.4, and PHP (7.2 to 7.4).
This image is missing MySQL or any Database with purpose. Compose with a Mysql or Maria image to add this feature.
Feel free to extend this image and adapt it to your needs.

## Installed extensions

#### APT Modules

- git
- zip / unzip
- libpng / libjpeg / libfreetype (for GD)
- libicu / libxml2
- sendmail

#### PHP extensions

- opcache
- pdo / pdo_mysql
- gd
- zip
- soap
- intl
- apcu cache
- mysqli

## Installation
This Docker image is not pushed to Docker hub. To use it, intall it as a git submodule and target it directly from your `docker-compose`.
It is adviced to clone submodule into a `deploy` or `docker` directory, but optionnal.

```bash
mkdir deploy
cd deploy
git submodule add git@github.com:zouloux/docker-debian-apache-php.git
```


## Docker compose examples


#### Map volumes

- `/root` is user root directory. Can be used to run processes outside `/public` directory.
- `/root/public` is root published directory by Apache.


```yaml
version: "3.7"
services:
  lap :
    build: deploy/docker-debian-apache-php
    volumes:
      - './:/root'
      - './dist:/root/public'
```


#### Specify which PHP version to build / use

Use `args` to specify current php version. Default PHP version is `7.4`.
Default version is PHP `7.4`.
PHP versions can go from `7.0` to tested `7.4`. Other version may works.
Docker image needs to be rebuilt if changed, with `docker-compose build`.

```yaml
version: "3.7"
services:
  lap :
    build:
      context: deploy/docker-debian-apache-php
      args:
        IMAGE_PHP_VERSION: 7.3
    volumes:
      - './:/root'
      - './dist:/root/public'
```


#### Enable apache login / password for public directory

This HTTP password will be required on all `/root/public` directory.

```yaml
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
      - './dist:/root/public'
```


#### Dev tools

Some devtools can be installed. `http://docker-host/devtools` folder will be available if enabled.
See [/devtools](https://github.com/zouloux/docker-debian-apache-php/tree/main/devtools) directory.

Available devtools :
- apcu cache monitor
- phpinfo

```yaml
version: "3.7"
services:
  lap :
    build: deploy/docker-debian-apache-php
    environment:
      APACHE_DEVTOOLS: true
    volumes:
      - './:/root'
      - './dist:/root/public'
```


#### Use envs

A `dotenv` file can also be used for convenience.

```yaml
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
      - './dist:/root/public'
```


`.env` file :
```
PHP_VERSION=7.2
APACHE_LOGIN=admin
APACHE_PASSWORD=secret
APACHE_DEVTOOLS=true
```