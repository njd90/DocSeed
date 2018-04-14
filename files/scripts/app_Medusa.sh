#!/bin/bash
# SickGear installation

mkdir -p $INC_PATH/tv
mkdir -p $MEDIA_PATH/tv

cat files/includes/medusa.docker >> docker-compose.yml

sed -i "s@FQDN@$Sg_SDOM.$DOMAIN@g" docker-compose.yml
sed -i "s@INCOMING@$INC_PATH/tv@g" docker-compose.yml
sed -i "s@TVSHOWS@$MEDIA_PATH/tv@g" docker-compose.yml
sed -i "s@TORRENTS@$DEFAULT_PATH/torrents@g" docker-compose.yml
sed -i "s@autodl-tv_medusa@$Sg_CNAME@g" docker-compose.yml

# Set Muximux configuration
cat <<EOF >> files/includes/muximux.conf

[Medusa]
name = "Medusa"
url = "https://192.168.42.52"
scale = 1
icon = "muximux-sickbeard"
color = "#b6f000"
enabled = "true"
EOF

sed -i "s@192.168.42.52@$Sg_SDOM.$DOMAIN@g" files/includes/muximux.conf
INSTALLED+=('Sg')
