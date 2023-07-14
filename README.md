# README

Handle HTTPS/TLS/SSL using Nginx, Let's Encrypt and Docker.

## Prerequisite

### Docker

The native package manager of some Linux distributions cannot reach the latest version of docker.

In this case, steps need to be taken following this [Docker Installation Document](https://docs.docker.com/engine/install/).

Make sure `docker compose` command is available (without a hyphen between "docker" and "compose").

### DNS record

Add a DNS record to the public IP address of your server.

### Firewall

Be sure that 80 and 443 port is allowed by firewall/security settings.

## Getting Started

### Config

Clone this repository to some place in your server.

Replace every "example.com" with your domain name in [example.com.conf](conf.d/example.com.conf) file.

```sh
# File compose.yaml should be here.
cd root-path-of-this-repository

# Replace xxx with your domain and run the follow command.
sed -i "s/example.com/xxx/g" conf.d/example.com.conf
```

### Start nginx

```sh
# Start nginx service.
sudo docker compose up -d
```

Check if everything's ok by visiting http://exmaple.com (replace with the real domain name).

The `Welcome to nginx!` printed on the web page indicates we can step forword.

### New certificate

```sh
# Replace with your email after -m param.
# Replace with the real domain name after -d param.

sudo docker compose run --rm \
certbot certonly --webroot \
--webroot-path /var/www/certbot/ \
--agree-tos \
-m someone@xxx.xxx \
-d example.com \
--dry-run
```

You should get a success message like "The dry run was successful".

### Renew

To manually renew, simply run the following command.

```sh
# Append --dry-run if you just want to check if it works.
sudo docker compose run --rm certbot renew
```

In common sense, we want to renew tls certificate automatically.

Let's get there with the help of crontab.

```sh
# Open crontab editor.
sudo crontab -e
```

Add the following line in the crontab config file.

Remember to replace `root-path-of-this-repository` with real path.

```crontab
# Renew every 2 months (on the first day of the month).
0 0 1 */2 * cd root-path-of-this-repository && sudo docker compose run --rm certbot renew
```

## Recommendations

### Nginx Config

The syntax of nginx config files is not widely supported by code editors by default.

For better dev experience, I recommend to use vscode with
[NGINX Configuration Language Support](https://marketplace.visualstudio.com/items?itemName=ahmadalli.vscode-nginx-conf) extention installed.

Alternatively if you prefer vim, the [nginx.vim](https://github.com/chr4/nginx.vim) plugin is quite helpful.

### Cloudflare

If your DNS is provided by cloudflare, be careful of the SSL/TLS encryption mode.

When you provide tls on your origin server,
the default SSL/TLS encryption mode `Flexible` will lead to `too many redirections error`.

In this case, you may either switch SSL/TLS encryption mode to `Full`
or give up tls and only use http on your origin server.

## Reference

[HTTPS using Nginx and Let's encrypt in Docker - Mindsers Blog](https://mindsers.blog/post/https-using-nginx-certbot-docker/)