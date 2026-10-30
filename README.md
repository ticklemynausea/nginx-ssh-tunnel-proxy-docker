# nginx-ssh-tunnel-proxy-docker

Quick setup container that opens an SSH tunnel to a remote host and fronts the
tunneled service with nginx. Sibling to
[`nginx-reverse-proxy-docker`](../nginx-reverse-proxy-docker), meant to be used
with [`nginx-proxy`](https://github.com/nginx-proxy/nginx-proxy) for
`VIRTUAL_HOST` routing and Let's Encrypt.

Where the reverse-proxy variant does `proxy_pass http://backend:port`, this one
does the equivalent of:

```
ssh -N -L LOCAL_PORT:REMOTE_HOST:REMOTE_PORT SSH_USER@SSH_HOST
```

inside the container, then has nginx proxy to `127.0.0.1:LOCAL_PORT`. Use it to
expose a service that's bound to loopback on some remote box (e.g. a Netdata
instance on `127.0.0.1:19999`) through your regular nginx-proxy stack.

`supervisord` runs both nginx and the ssh tunnel, restarting the tunnel
automatically if the connection drops.

## Usage

```bash
docker build . -t ticklemynausea/nginx-ssh-tunnel-proxy

docker run \
  --name netdata-tunnel-proxy \
  --detach \
  --restart unless-stopped \
  --network nginx-proxy \
  --volume /path/to/private_key:/ssh/id_key:ro \
  --env VIRTUAL_HOST="netdata.example.org" \
  --env LETSENCRYPT_HOST="netdata.example.org" \
  --env LETSENCRYPT_EMAIL="admin@example.org" \
  --env SSH_HOST="203.0.113.10" \
  --env SSH_USER="tunneluser" \
  --env REMOTE_PORT="19999" \
  --env SSH_KNOWN_HOSTS="$(ssh-keyscan 203.0.113.10 2>/dev/null)" \
  ticklemynausea/nginx-ssh-tunnel-proxy
```

## Environment variables

### Tunnel (required)

| Var                | Description                                                    |
| ------------------ | -------------------------------------------------------------- |
| `SSH_HOST`         | SSH target host or IP.                                         |
| `SSH_USER`         | SSH username.                                                  |
| `REMOTE_PORT`      | Port on the SSH target to forward (usually a loopback port).   |
| `SSH_KNOWN_HOSTS`  | Contents of a `known_hosts` file for `SSH_HOST` (see below).   |

The private key must be **bind-mounted** into the container. Default path is
`/ssh/id_key`; override with `SSH_KEY_PATH`. The entrypoint copies it to
`/root/.ssh/id_key` and fixes the permissions to `600`, so the host-side file
can safely be `:ro`.

### Tunnel (optional)

| Var            | Default        | Description                                               |
| -------------- | -------------- | --------------------------------------------------------- |
| `SSH_PORT`     | `22`           | SSH port on the target.                                   |
| `REMOTE_HOST`  | `127.0.0.1`    | Host the target should forward to (from its perspective). |
| `LOCAL_PORT`   | `8080`         | Local port inside the container. Not exposed externally.  |
| `PROXY_HOST`   | `$host`        | `Host` header sent upstream. Set to `localhost` for services that reject other hosts. |
| `SSH_KEY_PATH` | `/ssh/id_key`  | Where inside the container to read the private key from.  |
| `PATH_PORTS`   |                | Extra remote ports served under a path, e.g. `/files:8000 /api:9000` (see below). |

### Serving extra ports under paths

`PATH_PORTS` is a space-separated list of `/path:remote_port` rules. Each one
adds another `-L` forward on the same SSH connection (on local ports
`LOCAL_PORT+1`, `LOCAL_PORT+2`, …) and an nginx location that strips the
prefix:

```
PATH_PORTS="/files:8000"

https://example.org/files/sample.jpg  ->  http://REMOTE_HOST:8000/sample.jpg
https://example.org/files             ->  301 to /files/
```

Everything else still goes to `REMOTE_PORT`. Network restriction, basic auth
and `PROXY_HOST` apply to every path. The prefix is sent upstream as
`X-Forwarded-Prefix`. Apps that emit absolute links (`/style.css`) will need to
be configured with their base path to work under a prefix.

### nginx / nginx-proxy (inherited from sibling project)

| Var                    | Description                                              |
| ---------------------- | -------------------------------------------------------- |
| `VIRTUAL_HOST`         | Domain for nginx-proxy routing.                          |
| `LETSENCRYPT_HOST`     | Domain for acme-companion TLS.                           |
| `LETSENCRYPT_EMAIL`    | Contact address for Let's Encrypt.                       |
| `BASIC_AUTH_ENABLED`   | Set to `1` to enable HTTP basic auth.                    |
| `BASIC_AUTH_HTPASSWD`  | `user:hash` line (see below).                            |
| `CUSTOM_CONFIG`        | Raw nginx directives spliced into the server block.      |
| `NETWORK_RESTRICTION`  | Space-separated IPs/CIDRs to allow (`deny all` for the rest). |

## Getting `SSH_KNOWN_HOSTS`

Strict host-key verification is on. Populate the env var with output from
`ssh-keyscan`:

```bash
ssh-keyscan -p 22 203.0.113.10 2>/dev/null
```

Paste the resulting lines into the `SSH_KNOWN_HOSTS` env var (multi-line is
fine).

## Getting `BASIC_AUTH_HTPASSWD`

```bash
% openssl passwd -apr1
Password:
Verifying - Password:
$apr1$tL0Ji/AY$dL0IbjHJud6fB3nxc2Brg1
```

Then:

```bash
--env BASIC_AUTH_ENABLED="1"
--env BASIC_AUTH_HTPASSWD='username:$apr1$tL0Ji/AY$dL0IbjHJud6fB3nxc2Brg1'
```
