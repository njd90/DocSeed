#!/bin/bash
# Mylar installation

mkdir -p $INC_PATH/library
mkdir -p $MEDIA_PATH/library

cat files/includes/mylar.docker >> docker-compose.yml

sed -i "s@FQDN@$My_SDOM.$DOMAIN@g" docker-compose.yml
sed -i "s@INCOMING@$INC_PATH/library@g" docker-compose.yml
sed -i "s@BDS@$MEDIA_PATH/library@g" docker-compose.yml
sed -i "s@autodl-comics_mylar@$My_CNAME@g" docker-compose.yml

# Set Muximum configuration
cat <<EOF >> files/includes/muximux.conf

[Mylar]
name = "Mylar"
url = "https://192.168.42.52/home"
scale = 1
icon = "muximux-book"
color = ""
enabled = "true"
EOF

sed -i "s@192.168.42.52@$My_SDOM.$DOMAIN@g" files/includes/muximux.conf
INSTALLED+=('My')
