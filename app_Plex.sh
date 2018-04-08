#!/bin/bash
# Plex installation

mkdir -p $MEDIA_PATH/movies

cat files/includes/plex.docker >> docker-compose.yml

sed -i "s@MOVIES@$MEDIA_PATH/movies@g" docker-compose.yml
sed -i "s@FQDN@$Px_SDOM.$DOMAIN@g" docker-compose.yml
sed -i "s@stream-video_plex@$Px_CNAME@g" docker-compose.yml

cat <<EOF >> files/includes/muximux.conf

[Plex]
name = "Plex"
url = "https://192.168.42.52"
scale = 1
icon = "muximux-plex"
color = "#f9be03"
enabled = "true"
EOF

sed -i "s@192.168.42.52@$Px_SDOM.$DOMAIN@g" files/includes/muximux.conf
INSTALLED+=('Px')
