#!/bin/sh

if [ ! -z "${CUSTOM_CONFIG}" ]; then
  echo "${CUSTOM_CONFIG}" > /etc/nginx/conf.d/custom.conf
else
  echo '# nope' > /etc/nginx/conf.d/custom.conf
fi
