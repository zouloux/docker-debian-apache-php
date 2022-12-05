#!/bin/bash

# Create password file from envs
if [[ -n "${DDAP_LOGIN}" ]]; then
  mkdir -p /auth/
  touch /auth/.htpasswd
  htpasswd -db /auth/.htpasswd ${DDAP_LOGIN} ${DDAP_PASSWORD}
  echo "Enabling password"
  a2enconf zzz-password
fi

# Add or remove devtools
if [[ -n "${DDAP_DEVTOOLS}" ]]; then
  a2enconf zzz-devtools
else
  rm -rf /devtools
fi

# Start memcached service in background
if [[ -n "${DDAP_MEMCACHED}" ]]; then
  /usr/bin/memcached \
    --user="${DDAP_MEMCACHED_USER:-root}" \
    --listen="${DDAP_MEMCACHED_LISTEN:-0.0.0.0}" \
    --port="${DDAP_MEMCACHED_PORT:-11211}" \
    --memory-limit="${DDAP_MEMCACHED_MEMORY_LIMIT:-64}" \
    --conn-limit="${DDAP_MEMCACHED_CONN_LIMIT:-2048}" \
    --threads="${DDAP_MEMCACHED_THREADS:-4}" \
    --max-reqs-per-event="${DDAP_MEMCACHED_MAX_REQS_PER_EVENT:-20}" \
    --verbose &
fi

# Start apache
apache2-foreground
