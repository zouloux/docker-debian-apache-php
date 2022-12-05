#!/bin/bash

# Add or remove devtools
if [[ -n "${DDAP_DEVTOOLS}" ]]; then
  a2enconf zzz-devtools > /dev/null
  echo "Enabling devtools"
else
  rm -rf /devtools
fi
