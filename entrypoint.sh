#!/bin/sh
set -e

export SSH_KEY_PATH="${SSH_KEY_PATH:-/ssh/id_key}"
export SSH_PORT="${SSH_PORT:-22}"
export REMOTE_HOST="${REMOTE_HOST:-127.0.0.1}"
export LOCAL_PORT="${LOCAL_PORT:-8080}"

for f in /docker-entrypoint.d/*.sh; do
  if [ -x "$f" ]; then
    echo "$0: running $f"
    "$f"
  fi
done

exec "$@"
