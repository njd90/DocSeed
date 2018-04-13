#!/bin/bash
# rTorrent with rutorrent interface installation

cat files/includes/rtorrent-r.docker >> docker-compose.yml
mkdir -p $CONF/rtorrent/usr/local/bin
touch $CONF/rtorrent/usr/local/bin/postdl
touch $CONF/rtorrent/usr/local/bin/postrm
cat files/includes/postdl > $CONF/rtorrent/usr/local/bin/postdl
cat files/includes/postrm > $CONF/rtorrent/usr/local/bin/postrm

sed -i "s@FQDN@$Rt_SDOM.$DOMAIN@g" docker-compose.yml
sed -i "s@INCOMING@$INC_PATH@g" docker-compose.yml
sed -i "s@dl-torrent_rtorrent@$Rt_CNAME@g" docker-compose.yml
sed -i "s@HOME@$DEFAULT_PATH@g" docker-compose.yml

# Set Muximux configuration
cat <<EOF >> files/includes/muximux.conf
[rTorrent]
name = "rTorrent"
url = "https://192.168.42.52"
scale = 1
icon = "muximux-rutorrent"
color = "#1a1bfe"
enabled = "true"
EOF

sed -i "s@192.168.42.52@$Rt_SDOM.$DOMAIN@g" files/includes/muximux.conf
INSTALLED+=('Rt')
