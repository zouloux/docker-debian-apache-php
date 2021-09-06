#!/bin/bash

# Create password file from envs
if [[ -n "${APACHE_LOGIN}" ]]; then
  mkdir -p /auth/
  touch /auth/.htpasswd
  htpasswd -db /auth/.htpasswd ${APACHE_LOGIN} ${APACHE_PASSWORD}
  echo "Enabling password"
  a2enconf zzz-password
fi

# Add devtools
if [[ -n "${APACHE_DEVTOOLS}" ]]; then
  a2enconf zzz-devtools
fi

# Patch rights on root folder
chmod 0655 /root

# Start apache
apache2-foreground
