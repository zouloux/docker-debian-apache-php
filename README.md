# Docker Debian Apache PHP

DDAP is a docker image based on Debian, with Apache 2.4, and PHP 8.0 by default (from 7.2 to 8.1).
This image is missing MySQL or any Database on purpose.
[Compose with a Mysql or Maria image to add this feature.](#compose-mysql-image)

> Available on [Docker Hub](https://hub.docker.com/repository/docker/zouloux/docker-debian-apache-php)

Feel free to extend this image and adapt it to your needs or use it directly for your web projects.

> This image is built for `linux/amd64` (x86_64) and `linux/arm64` (aarch64)

> **New** : this image is now from debian-slim, and not from PHP:X-apache anymore.
> It's way slimmer and faster to build. See [./v1](v1) for previous source code.

## Installed extensions

### APT Modules

- all modules installed by default with Debian 11 slim
- gnupg2
- curl
- git
- sendmail
- zip / unzip

### Other utilities

- `composer` ( v2 )

### PHP extensions

- opcache / apcu / memcached
- mysqli / mysql / pdo / pdo-mysql / pdo-sqlite
- zip / bz2
- gd / intl / tokenizer / mcrypt / mbstring
- dom / zimplexml / xml
- curl

> mcrypt is only installed prior to `8.2`, this package being deprecated now.

### Apache multi threding

`prefork` is installed and configured to allow multi threading of Apache requests.
This is better than the regular `worker` with PHP.

> `sleep.php` is available in example to check that blocking scripts now works with other requests.

## Usage

### A) Use it from docker hub

Common usage is to use an already built image from Docker Hub :

#### Default PHP version (8.0)

```yaml
version: "3.7"
services:
  ddap :
    image: zouloux/docker-debian-apache-php
    volumes:
      - './:/root'
```

> Web root is in `/root/public`

#### Specify PHP version

```yaml
version: "3.7"
services:
  ddap :
    # Example, we need the legacy PHP 7.2 for a rusty project
    image: zouloux/docker-debian-apache-php:7.2
    volumes:
      - './:/root'
```

> Available versions are `7.2` / `7.3` / `7.4` / `8.0` / `8.1` / `8.2`

### B) Build it locally

If you need to customize this image locally, you still can specify the PHP version.
Use `args` to specify current php version. Non tested PHP version may work.
Docker image needs to be rebuilt if `args` are changed, with `docker-compose build`.

```yaml
version: "3.7"
services:
  ddap :
    build:
      context: path/to/docker-debian-apache-php/trunk
      args:
        IMAGE_PHP_VERSION: 7.3
    volumes:
      - './:/root'
```


## Map volumes

- `/root` is user's root and current directory. Can be used to run processes outside `/public` directory ( ex `composer install` )
- `/root/public` is root published directory by Apache.

```yaml
version: "3.7"
services:
  ddap :
    image: zouloux/docker-debian-apache-php
    volumes:
      - './:/root'
      - './dist:/root/public'
```

## Enable apache login / password for public directory

This HTTP password will be required on all `/root/public` directory.

```yaml
version: "3.7"
services:
  ddap :
    image: zouloux/docker-debian-apache-php
    environment:
      DDAP_LOGIN: admin
      DDAP_PASSWORD: secret
    volumes:
      - './:/root'
```

## Dev tools

Some devtools can be installed. `http://docker-host/devtools` folder will be available if enabled.
See [/devtools](https://github.com/zouloux/docker-debian-apache-php/tree/main/devtools) directory.

Available devtools :
- apcu cache monitor
- phpinfo

```yaml
version: "3.7"
services:
  ddap :
    image: zouloux/docker-debian-apache-php
    environment:
      DDAP_DEVTOOLS: 'true'
    volumes:
      - './:/root'
```

## Use dot env file

A `dotenv` file can also be used for convenience.

```yaml
version: "3.7"
services:
  ddap :
    build:
      context: deploy/docker-debian-apache-php
      args:
        IMAGE_PHP_VERSION: ${PHP_VERSION:-}
    environment:
      DDAP_LOGIN: ${DDAP_LOGIN:-}
      DDAP_PASSWORD: ${DDAP_PASSWORD:-}
      DDAP_DEVTOOLS: ${DDAP_DEVTOOLS:-}
    volumes:
      - './:/root'
```

`.env` file :
```dotenv
PHP_VERSION=7.2
DDAP_LOGIN=admin
DDAP_PASSWORD=secret
DDAP_DEVTOOLS=true
```

## Custom config

To use custom config files for apache or php,
Simply create your `config/php.ini` for ex, and map specific config file with `volumes`.
Default configs are [available here](https://github.com/zouloux/docker-debian-apache-php/tree/main/config). 

```yaml
version: "3.7"
services:
  ddap:
    image: zouloux/docker-debian-apache-php
    environment:
      DDAP_LOGIN: ${DDAP_LOGIN:-}
      DDAP_PASSWORD: ${DDAP_PASSWORD:-}
      DDAP_DEVTOOLS: ${DDAP_DEVTOOLS:-}
    volumes:
      - './:/root'
      - './config/php.ini:/config/php.ini'
```

## Compose with MySQL

This image is missing MySQL image on purpose. To add a MySQL server to your stack :

```yaml
version: "3.7"
services:

  ddap :
    image: zouloux/docker-debian-apache-php
    volumes:
      - './:/root'

  maria:
    image: mariadb
    restart: unless-stopped
    container_name: maria
    hostname: maria
    ports:
      - '3306:3306'
    environment:
      MYSQL_ROOT_PASSWORD: "${MYSQL_ROOT_PASSWORD:-}"
    volumes :
      - './data/mysql:/var/lib/mysql:delegated'

  phpmyadmin:
    image: phpmyadmin
    restart: unless-stopped
    container_name: phpmyadmin
    environment:
      PMA_HOST: "maria"
```

## Test this image or work on it 

- `git clone https://github.com/zouloux/docker-debian-apache-php.git`
- `cd docker-debian-apache-php/test`
- `docker-compose build`
- `docker-compose up`
- Then go to localhost:8080
