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
- memcached
- sendmail

#### PHP extensions

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

#### Build from docker hub

Common usage is to use an already built image from Docker Hub :


# Default PHP version (7.4)
```yaml
version: "3.7"
services:
  lap :
    image: zouloux/docker-debian-apache-php
    volumes:
      - './:/root'
      - './dist:/root/public'
```

# Specific PHP version (7.2 / 7.3 / 7.4 / 8.0)
```yaml
version: "3.7"
services:
  lap :
    image: zouloux/docker-debian-apache-php:PHP7.2
    volumes:
      - './:/root'
      - './dist:/root/public'
```

#### Local build with git submodule

This is a less common usage but can be handy if you need to tweak this image to
fit specific project needs. Install it as a git submodule and target it directly
from your `docker-compose`. It is advised to clone submodule into a `deploy` or 
`docker` directory, but optional.

```bash
mkdir deploy
cd deploy
git submodule add git@github.com:zouloux/docker-debian-apache-php.git
```

```yaml
version: "3.7"
services:
  lap :
    image: zouloux/docker-debian-apache-php
    volumes:
      - './:/root'
      - './dist:/root/public'
```

#### Specify which PHP version to build / use

Use `args` to specify current php version. Default PHP version is `7.4`.
Available (tested) versions are 7.2 / 7.3 / 7.4 / 8.0. 
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

## Docker compose examples


#### Map volumes

- `/root` is user root directory. Can be used to run processes outside `/public` directory.
- `/root/public` is root published directory by Apache.

```yaml
version: "3.7"
services:
  lap :
    image: zouloux/docker-debian-apache-php
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
    image: zouloux/docker-debian-apache-php
    environment:
      DDAP_LOGIN: admin
      DDAP_PASSWORD: secret
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
      DDAP_DEVTOOLS: true
    volumes:
      - './:/root'
      - './dist:/root/public'
```

#### Enable memcached server

Enable memcached server and optionaly configure it to your needs.
Default config is working out of the box.
To check memcached, enable devtools and go to `/devtools/memcached`

```yaml
version: "3.7"
services:
  lap :
    build: deploy/docker-debian-apache-php
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
      DDAP_LOGIN: ${DDAP_LOGIN:-}
      DDAP_PASSWORD: ${DDAP_PASSWORD:-}
      DDAP_DEVTOOLS: ${DDAP_DEVTOOLS:-}
    volumes:
      - './:/root'
      - './dist:/root/public'
```


`.env` file :
```
PHP_VERSION=7.2
DDAP_LOGIN=admin
DDAP_PASSWORD=secret
DDAP_DEVTOOLS=true
```


## Test this image or work on it 

- `git clone https://github.com/zouloux/docker-debian-apache-php.git`
- `cd docker-debian-apache-php/test`
- `docker-compose build`
- `docker-compose up`
- Then go to localhost:8080
