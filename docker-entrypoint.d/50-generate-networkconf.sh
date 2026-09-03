#!/bin/sh

if [ ! -z "${NETWORK_RESTRICTION}" ]; then
  echo "allow ${NETWORK_RESTRICTION};" > /etc/nginx/conf.d/network.conf
  echo "deny all;" >> /etc/nginx/conf.d/network.conf
else
  echo "allow all;" > /etc/nginx/conf.d/network.conf
fi
