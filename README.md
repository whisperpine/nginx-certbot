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

```sh
cd root-path-of-this-repository

cp template/example-com-apply.conf conf.d/example-com-apply.conf

#!!! Replace xxx with your domain and run the follow command.
sed -i "s/example.com/xxx/g" conf.d/example-com-apply.conf
```

### Start nginx

```sh
# Start nginx service.
sudo docker compose up -d

# Check if nginx logs any error.
sudo docker logs nginx
```

Check if everything's ok by visiting http://exmaple.com (replace with the real domain name).

The `Welcome to nginx!` printed on the web page indicates we can step forword.

### New certificate

```sh
#!!! Replace with the real domain name after -d param.
# Replace with your email after -m param.
# Add another -m line to include another email address.

sudo docker compose run --rm \
certbot certonly --webroot \
--webroot-path /var/www/certbot/ \
--agree-tos \
-m someone@xxx.xxx \
-d example.com \
--dry-run
```

You should get a success message like "The dry run was successful".

### Enable https

```sh
# Take care: example-com-renew.conf is not the previous example-com-apply.conf
cp template/example-com-renew.conf conf.d/example-com-renew.conf

#!!! Replace xxx with your domain and run the follow command.
sed -i "s/example.com/xxx/g" conf.d/example-com-renew.conf

# Delete the previous file used to apply tls certificate.
rm conf.d/example-com-apply.conf

# Restart nginx to take effect.
sudo compose restart
```

Now you can visit https://exmaple.com (replace with the real domain name) and see the https is enabled.

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