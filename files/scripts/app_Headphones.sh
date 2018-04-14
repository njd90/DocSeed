#!/bin/bash
# Headphones installation

mkdir -p $INC_PATH/music
mkdir -p $MEDIA_PATH/sound/music

cat files/includes/headphones.docker >> docker-compose.yml

sed -i "s@FQDN@$Hp_SDOM.$DOMAIN@g" docker-compose.yml
sed -i "s@INCOMING@$INC_PATH/music@g" docker-compose.yml
sed -i "s@ZIC@$MEDIA_PATH/sound/music@g" docker-compose.yml
sed -i "s@autodl-music_headphones@$Hp_CNAME@g" docker-compose.yml
sed -i "s@TORRENTS@$DEFAULT_PATH/torrents@g" docker-compose.yml

cat <<EOF >> files/includes/muximux.conf

[Headphones]
name = "Headphones"
url = "https://192.168.42.52/home"
scale = 1
icon = "muximux-headphones"
color = "#000000"
enabled = "true"
EOF

sed -i "s@192.168.42.52@$Hp_SDOM.$DOMAIN@g" files/includes/muximux.conf
INSTALLED+=('Hp')
