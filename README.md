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
In this case, steps need to be taken following this [Docker Installation Document](https://docs.docker.com/engine/install/).\
Make sure command `docker compose` (not `docker-compose`)  is available.

## Getting Started

### Config nginx

Clone this repository to some place in your server.\
Use [helper.sh](helper.sh) to simplify this step (recommended):

```sh
cd [this-repository]

#!!! Replace "example.com" with your domain.
sh ./helper.sh -a create -d example.com
```

Alternatively you can choose to run the following commands:

```sh
cd [this-repository]

cp template/example-com-apply.conf conf.d/example-com-apply.conf

#!!! Replace "xxx" with your domain and run the follow command.
sed -i "s/example.com/xxx/g" conf.d/example-com-apply.conf

# Start nginx service.
sudo docker compose up -d

# Check if nginx logs any error.
sudo docker logs nginx
```

Check if everything's ok by visiting <http://exmaple.com> (replace with the real domain name).\
The `Welcome to nginx!` printed on the web page indicates we can step forword.

### New certificate

```sh
#!!! Replace with the real domain name after -d arg.
#!!! Replace with your email after -m arg.
# Add another -m line to include another email address.
# --agree-tos: agree to the terms of service of the ACME server.
# --no-eff-email: don't share your e-mail address with EFF.

sudo docker compose run --rm \
certbot certonly --webroot \
--webroot-path /var/www/certbot/ \
--agree-tos \
--no-eff-email \
-m someone@xxx.xxx \
-d example.com \
--dry-run
```

You should get a success message like "The dry run was successful".\
Just run the command above without `--dry-run` to received the certificates issued by Let's Encrypt.

### Enable https

Use [helper.sh](helper.sh) to simplify this step (recommended):

```sh
#!!! Replace "example.com" with your domain.
sh ./helper.sh -a https -d example.com
```

Alternatively you can choose to run the following commands:

```sh
# Take care: example-com-renew.conf is not the previous file.
cp template/example-com-renew.conf conf.d/example-com-renew.conf

#!!! Replace xxx with your domain.
sed -i "s/example.com/xxx/g" conf.d/example-com-renew.conf

# Delete the previous file used to apply tls certificate.
rm conf.d/example-com-apply.conf

# Restart nginx to take effect.
sudo compose restart
```

Now you can visit <https://exmaple.com> (replace with the real domain name) and see the https is enabled.

### Renew

To manually renew, simply run the following command:

```sh
# Append --dry-run if you only want to check if it works.
sudo docker compose run --rm certbot renew
```

In common sense, we want to renew tls certificate automatically.\
Let's get there with the help of crontab:

```sh
# Open crontab editor.
sudo crontab -e
```

Add the following line in the crontab config file.\
Remember to replace `root-path-of-this-repository` with real path.

```crontab
# Renew every 2 months (on the first day of the month).
0 0 1 */2 * cd [this-repository] && sudo docker compose run --rm certbot renew
```

## Recommendations

### Nginx Config

The syntax of nginx config files is not widely supported by code editors by default.

For better dev experience, it's recommended to use vscode with
[NGINX Configuration Language Support](https://marketplace.visualstudio.com/items?itemName=ahmadalli.vscode-nginx-conf) extention installed.

### Cloudflare

If your DNS is provided by cloudflare, be careful of the SSL/TLS encryption mode.

When you provide tls on your origin server,
the default SSL/TLS encryption mode `Flexible` will lead to `xxx redirected you too many times` error.
To fix that issue, you may either switch SSL/TLS encryption mode to `Full`
or give up tls and only use http on your origin server.

## FAQ

### Can I manage more than one domain?

Yes, just do every thing the same as the first domain but skip the `Renew` step.\
Cause certbot will renew all the registered domain in a sequence in a run.
