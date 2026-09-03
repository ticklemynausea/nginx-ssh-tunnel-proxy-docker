#!/bin/sh
set -e

missing=""
[ -z "${SSH_HOST}" ] && missing="${missing} SSH_HOST"
[ -z "${SSH_USER}" ] && missing="${missing} SSH_USER"
[ -z "${REMOTE_PORT}" ] && missing="${missing} REMOTE_PORT"
[ -z "${SSH_KNOWN_HOSTS}" ] && missing="${missing} SSH_KNOWN_HOSTS"

if [ -n "${missing}" ]; then
  echo "error: required env var(s) unset:${missing}" >&2
  exit 1
fi

if [ ! -f "${SSH_KEY_PATH}" ]; then
  echo "error: SSH key not found at ${SSH_KEY_PATH} (mount with -v /host/key:${SSH_KEY_PATH}:ro or set SSH_KEY_PATH)" >&2
  exit 1
fi

mkdir -p /root/.ssh
chmod 700 /root/.ssh

cp "${SSH_KEY_PATH}" /root/.ssh/id_key
chmod 600 /root/.ssh/id_key

printf '%s\n' "${SSH_KNOWN_HOSTS}" > /root/.ssh/known_hosts
chmod 644 /root/.ssh/known_hosts
