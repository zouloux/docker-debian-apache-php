#!/bin/bash
set -e

if ! mountpoint -q "/config/vhost.conf"; then
  echo ">> Base is $DDAP_BASE"
  if [[ "${DDAP_BASE}" != "/" ]]; then
    cp /config/vhost-base.conf /config/vhost.conf
  else
    cp /config/vhost-direct.conf /config/vhost.conf
  fi
fi

# Replace variables from config files, only if not mounted from docker compose
configFiles=( "/config/php.ini" "/config/app.conf" "/config/vhost.conf" "/config/password.conf" )
for configFile in "${configFiles[@]}"; do
  if ! mountpoint -q "$configFile"; then
    envsubst < "$configFile" > "${configFile}.tmp" && mv "${configFile}.tmp" "$configFile"
  fi
done

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
echo ">> Apache listening on port 80"
php-fpm${IMAGE_PHP_VERSION} & apache2ctl -D FOREGROUND