#!/bin/bash
# Traefik installation

cat files/includes/traefik.docker >> docker-compose.yml

mkdir -p $CONF_PATH/traefik
cat files/includes/traefik.toml >> $CONF_PATH/traefik/traefik.toml
touch $CONF_PATH/traefik/acme.json
chmod 600 $CONF_PATH/traefik/acme.json

sed -i "s/RFC2136_KEY/$RFC2136_KEY/g" docker-compose.yml
sed -i "s/RFC2136_SECRET/$RFC2136_SECRET/g" docker-compose.yml
sed -i "s/RFC2136_ALGO/$RFC2136_ALGO/g" docker-compose.yml
sed -i "s/RFC2136_NS/$RFC2136_NS/g" docker-compose.yml
sed -i "s/EMAIL_CH/$MAIL/g" docker-compose.yml
sed -i "s@domain.tld@$DOMAIN@g" docker-compose.yml
