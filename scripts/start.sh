#!/bin/bash
set -e

#ls -la /config
#ls -la /config/templates

# Replace variables from config files, only if not mounted from docker compose
configFiles=( "app.conf" "devtools.conf" "password.conf" "php.ini" "ports.conf"  "vhost-base.conf" "vhost-direct.conf"  )
for configFile in "${configFiles[@]}"; do
  if ! mountpoint -q "/config/$configFile"; then
    envsubst < "/config/templates/$configFile" > "/tmp/$configFile"
    mv "/tmp/$configFile" "/config/${filename}"
  fi
done

# Enable app config now that the config file exists
a2enconf zzz-app > /dev/null 2>&1

# Move vhost config from base env
if ! mountpoint -q "/config/vhost.conf"; then
  echo ">> Base is $DDAP_BASE"
  rm /config/vhost.conf > /dev/null 2>&1 || true
  if [[ "${DDAP_BASE}" != "/" ]]; then
    cp /config/vhost-base.conf /config/vhost.conf
  else
    cp /config/vhost-direct.conf /config/vhost.conf
  fi
fi

# Add or remove devtools
if [[ "${DDAP_DEVTOOLS}" == "true" ]]; then
  echo ">> Devtools are available at ${DDAP_DEVTOOLS_URL}"
  a2enconf zzz-devtools > /dev/null
else
  echo "" > /config/devtools.conf
fi

# Create password file from envs
if [[ -n "${DDAP_LOGIN}" ]]; then
  stars=$(printf '%*s' "${#DDAP_PASSWORD}" '' | tr ' ' '*')
  echo ">> HTTP credentials are ${DDAP_LOGIN}:${stars}"
  touch /auth/.htpasswd
  htpasswd -db /auth/.htpasswd ${DDAP_LOGIN} ${DDAP_PASSWORD} > /dev/null 2>&1
  a2enconf zzz-password > /dev/null 2>&1
fi

# Start PHP-FPM and apache
echo ">> PHP ${IMAGE_PHP_VERSION} FPM started"
echo ">> Apache listening on port ${DDAP_PORT}"
php-fpm${IMAGE_PHP_VERSION} & apache2ctl -D FOREGROUND