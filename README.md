# Preset nginx config with docker

### How to use
1. In dir `config/conf.d` copy `default.conf.template`  to `domain_name.conf`
2. Update upstream config
3. Update domain name and proxy config if deploy with static file can config path without `proxy_pass`

### Config HTTPS
#### self-sign certificate
1. `cd ssl`
2. run `./gen_ssl.sh domain_name` for generate self -sign ceritificate
3. run `openssl dhparam -out dhparam.pem 2048`

#### CA certificate
1. `cd ssl`
2. copy exist certificate to `ssl/domain_name`
3. run `openssl dhparam -out dhparam.pem 2048`



ref. [digital ocean nginx tools]([https://](https://www.digitalocean.com/community/tools/nginx))