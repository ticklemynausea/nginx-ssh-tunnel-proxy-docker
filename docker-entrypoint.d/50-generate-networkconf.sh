#!/bin/sh

if [ ! -z "${NETWORK_RESTRICTION}" ]; then
  : > /etc/nginx/conf.d/network.conf
  for RULE in ${NETWORK_RESTRICTION}; do
    echo "allow ${RULE};" >> /etc/nginx/conf.d/network.conf
  done
  echo "deny all;" >> /etc/nginx/conf.d/network.conf
else
  echo "allow all;" > /etc/nginx/conf.d/network.conf
fi
