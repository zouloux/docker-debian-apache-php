# Docker Debian Apache PHP

DDAP is based on Debian, with Apache 2.4, and PHP (from 7.2 to 8.0).
This image is missing MySQL or any Database on purpose.
[Compose with a Mysql or Maria image to add this feature.](https://github.com/zouloux/docker-debian-apache-php#compose-mysql-image)
Feel free to extend this image and adapt it to your needs.

## Installed extensions

### APT Modules

- git
- zip / unzip
- libpng / libjpeg / libfreetype (for GD)
- libicu / libxml2
- memcached
- sendmail

### PHP extensions

- opcache
- pdo / pdo_mysql
- gd
- zip
- soap
- intl
- apcu
- memcached
- mysqli

## Usage

### Install from docker hub

Common usage is to use an already built image from Docker Hub :

# Default PHP version (7.4)
```yaml
version: "3.7"
services:
  ddap :
    image: zouloux/docker-debian-apache-php
    volumes:
      - './:/root'
```

# Specific PHP version (7.2 / 7.3 / 7.4 / 8.0)
```yaml
version: "3.7"
services:
  ddap :
    image: zouloux/docker-debian-apache-php:PHP7.2
    volumes:
      - './:/root'
```

### Local build with git submodule

This is a less common usage but can be handy if you need to tweak this image to
fit specific project needs. Install it as a git submodule and target it directly
from your `docker-compose`. It is advised to clone submodule into a `deploy` or 
`docker` directory, but optional.

```bash
git submodule add git@github.com:zouloux/docker-debian-apache-php.git deploy/docker-debian-apache-php
```

Using default PHP 7.4 version :

```yaml
version: "3.7"
services:
  ddap :
    build: deploy/docker-debian-apache-php
    volumes:
      - './:/root'
```

Use `args` to specify current php version. Available (tested) versions are 7.2 / 7.3 / 7.4 / 8.0.
Next versions like 8.1 may work.
Docker image needs to be rebuilt if `args` are changed, with `docker-compose build`.

```yaml
version: "3.7"
services:
  ddap :
    build:
      context: deploy/docker-debian-apache-php
      args:
        IMAGE_PHP_VERSION: 7.3
    volumes:
      - './:/root'
```

## Docker compose examples

### Map volumes

- `/root` is user root directory. Can be used to run processes outside `/public` directory.
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

### Enable apache login / password for public directory

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

### Dev tools

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
      DDAP_DEVTOOLS: true
    volumes:
      - './:/root'
```

### Enable memcached server

Enable memcached server and optionaly configure it to your needs.
Default config is working out of the box.
To check memcached, enable devtools and go to `/devtools/memcached`

```yaml
version: "3.7"
services:
  ddap :
    image: zouloux/docker-debian-apache-php
    environment:
      # Enabled memcached server
      DDAP_MEMCACHED: 'true'
      # Specific memcached conf (here are default options)
      #DDAP_MEMCACHED_USER: "root"
      #DDAP_MEMCACHED_LISTEN: "0.0.0.0"
      #DDAP_MEMCACHED_PORT: "11211"
      #DDAP_MEMCACHED_MEMORY_LIMIT: "64"
      #DDAP_MEMCACHED_CONN_LIMIT: "2048"
      #DDAP_MEMCACHED_THREADS: "4"
      #DDAP_MEMCACHED_MAX_REQS_PER_EVENT: "20"
    volumes:
      - './:/root'
```


### Use envs

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
```
PHP_VERSION=7.2
DDAP_LOGIN=admin
DDAP_PASSWORD=secret
DDAP_DEVTOOLS=true
```

### Custom config

To use custom config files for apache or php,
Simply create your `config/php.ini` for ex, and map specific config file with `volumes`.
Default configs are [available here](https://github.com/zouloux/docker-debian-apache-php/tree/main/config). 

```yaml
    version: "3.7"
    services:
      ddap :
        image: zouloux/docker-debian-apache-php
        environment:
          DDAP_LOGIN: ${DDAP_LOGIN:-}
          DDAP_PASSWORD: ${DDAP_PASSWORD:-}
          DDAP_DEVTOOLS: ${DDAP_DEVTOOLS:-}
        volumes:
          - './:/root'
          - './config/php.ini:/config/php.ini'
```

### Compose MySQL image

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

