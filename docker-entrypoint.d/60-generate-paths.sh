#!/bin/sh

# PATH_FORWARDS is resolved by /entrypoint.sh as "path:local_port" entries.
: > /etc/nginx/conf.d/paths.inc
for RULE in ${PATH_FORWARDS}; do
  path="${RULE%:*}"
  port="${RULE##*:}"
  cat >> /etc/nginx/conf.d/paths.inc <<CONF
location = ${path} {
  absolute_redirect off;
  return 301 ${path}/\$is_args\$args;
}

location ${path}/ {
  include conf.d/proxy.inc;
  proxy_set_header X-Forwarded-Prefix ${path};

  proxy_pass http://127.0.0.1:${port}/;
}

CONF
done
