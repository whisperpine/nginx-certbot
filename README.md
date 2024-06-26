# README

Handle HTTPS/TLS/SSL using Nginx, Let's Encrypt and Docker.\
Inspired by:
[HTTPS using Nginx and Let's encrypt in Docker - Mindsers Blog](https://mindsers.blog/post/https-using-nginx-certbot-docker/)

## Prerequisite

### Server

Add a DNS record to the public IP address of your server.\
Be sure that 80 and 443 port is allowed by firewall/security settings.

### Docker

The native package manager of some Linux distributions cannot reach the latest version of docker.\
In this case, there are steps need to be taken as listed in the [Docker Installation Document](https://docs.docker.com/engine/install/).

## Getting Started

- Create virtual machine and config DNS record.
- Config environment variables in `.env` file (see [template.env](./template.env)).
- Run `sudo docker compose up -d` to start services.
- Run `sh helper.sh init` to create nginx config.
- Run `sh helper.sh apply` to apply tls certs.
- Run `sh helper.sh renew` to check if renewal works.
- Run `sh helper.sh cron` to setup cron to auto renew tls certs.

## Recommendations

### Nginx Config

The syntax of nginx config files is not widely supported by code editors by default.\
For better develop experience, it's recommended to use vscode with\
[NGINX Configuration Language Support](https://marketplace.visualstudio.com/items?itemName=ahmadalli.vscode-nginx-conf) extention installed.

### Cloudflare

If your DNS is provided by cloudflare, be careful of the SSL/TLS encryption mode.

When you provide tls on your origin server, the default SSL/TLS encryption mode\
`Flexible` will lead to `xxx redirected you too many times` error.

To fix that issue, you may either switch SSL/TLS encryption mode to `Full`\
or turn off the proxy switch (`Proxy status` from `Proxied` to `DNS Only`).

## Add New Domains

- Delete existing domains in `DOMAIN_NAMES` inside `.env`.
- Add new domains in `DOMAIN_NAMES` inside `.env`.
- Run `sh helper.sh init` to create nginx config.
- Run `sh helper.sh apply` to apply tls certs.
- Recover the deleted domains in `DOMAIN_NAMES`.
- Run `sudo docker compose exec nginx nginx -s reload`.
