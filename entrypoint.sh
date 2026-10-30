#!/bin/sh
set -e

export SSH_KEY_PATH="${SSH_KEY_PATH:-/ssh/id_key}"
export SSH_PORT="${SSH_PORT:-22}"
export REMOTE_HOST="${REMOTE_HOST:-127.0.0.1}"
export LOCAL_PORT="${LOCAL_PORT:-8080}"
export PROXY_HOST="${PROXY_HOST:-\$host}"

# PATH_PORTS="/files:8000 /api:9000" -> one extra -L per path, on LOCAL_PORT+1, +2, ...
export SSH_EXTRA_FORWARDS=""
export PATH_FORWARDS=""
local_port="${LOCAL_PORT}"
for RULE in ${PATH_PORTS}; do
  path="/${RULE%:*}"
  path="${path%/}"
  while [ "${path#//}" != "${path}" ]; do path="${path#/}"; done
  remote_port="${RULE##*:}"

  case "${path}" in
    ""|/|*[!A-Za-z0-9._~/-]*)
      echo "error: invalid path in PATH_PORTS rule '${RULE}'" >&2
      exit 1
      ;;
  esac
  case "${remote_port}" in
    ""|*[!0-9]*)
      echo "error: invalid port in PATH_PORTS rule '${RULE}'" >&2
      exit 1
      ;;
  esac

  local_port=$((local_port + 1))
  SSH_EXTRA_FORWARDS="${SSH_EXTRA_FORWARDS} -L ${local_port}:${REMOTE_HOST}:${remote_port}"
  PATH_FORWARDS="${PATH_FORWARDS} ${path}:${local_port}"
done

for f in /docker-entrypoint.d/*.sh; do
  if [ -x "$f" ]; then
    echo "$0: running $f"
    "$f"
  fi
done

exec "$@"
