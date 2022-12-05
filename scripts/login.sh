#!/bin/bash

# Create password file from envs
if [[ -n "${DDAP_LOGIN}" ]]; then
  mkdir -p /auth/
  touch /auth/.htpasswd
  htpasswd -db /auth/.htpasswd ${DDAP_LOGIN} ${DDAP_PASSWORD}
  a2enconf zzz-password > /dev/null
fi
