#!/bin/sh

if [ ! -z "${BASIC_AUTH_HTPASSWD}" ]; then
  echo "${BASIC_AUTH_HTPASSWD}" > /etc/nginx/.htpasswd
fi
