#!/bin/bash
set -e

# Replace variables from config files
configFiles=( "/config/php.ini" "/config/app.conf" "/config/vhost.conf" "/config/password.conf" )
for configFile in "${configFiles[@]}"; do
  if ! mountpoint -q "$configFile"; then
    envsubst < "$configFile" > "${configFile}.tmp" && mv "${configFile}.tmp" "$configFile"
  fi
done

cat /config/vhost.conf
cat /config/php.ini

# Init devtools and htpasswd
/scripts/devtools.sh
/scripts/login.sh

# Start PHP FPM
# We need to do it here, it's not working when built in the image
service "php${IMAGE_PHP_VERSION}-fpm" start

# Next are copied from
# https://github.com/docker-library/php/blob/master/8.0/bullseye/apache/apache2-foreground
# Without this script, apache runs in 1 thread mode, which is super slow.

# Note: we don't just use "apache2ctl" here because it itself is just a shell-script wrapper around apache2 which provides extra functionality like "apache2ctl start" for launching apache2 in the background.
# (also, when run as "apache2ctl <apache args>", it does not use "exec", which leaves an undesirable resident shell process)

: "${APACHE_CONFDIR:=/etc/apache2}"
: "${APACHE_ENVVARS:=$APACHE_CONFDIR/envvars}"
if test -f "$APACHE_ENVVARS"; then
	. "$APACHE_ENVVARS"
fi

# Apache gets grumpy about PID files pre-existing
: "${APACHE_RUN_DIR:=/var/run/apache2}"
: "${APACHE_PID_FILE:=$APACHE_RUN_DIR/apache2.pid}"
rm -f "$APACHE_PID_FILE"

# create missing directories
# (especially APACHE_RUN_DIR, APACHE_LOCK_DIR, and APACHE_LOG_DIR)
for e in "${!APACHE_@}"; do
	if [[ "$e" == *_DIR ]] && [[ "${!e}" == /* ]]; then
		# handle "/var/lock" being a symlink to "/run/lock", but "/run/lock" not existing beforehand, so "/var/lock/something" fails to mkdir
		#   mkdir: cannot create directory '/var/lock': File exists
		dir="${!e}"
		while [ "$dir" != "$(dirname "$dir")" ]; do
			dir="$(dirname "$dir")"
			if [ -d "$dir" ]; then
				break
			fi
			absDir="$(readlink -f "$dir" 2>/dev/null || :)"
			if [ -n "$absDir" ]; then
				mkdir -p "$absDir"
			fi
		done

		mkdir -p "${!e}"
	fi
done

exec apache2 -DFOREGROUND "$@"