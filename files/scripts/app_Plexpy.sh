#!/bin/bash
# Plexpy installation

cat files/includes/plexpy.docker >> docker-compose.yml

sed -i "s@FQDN@$Px_SDOM.$DOMAIN@g" docker-compose.yml
sed -i "s@tool-plex_plexpy@$Py_CNAME@g" docker-compose.yml

cat <<EOF >> files/includes/muximux.conf

[PlexPy]
name = "PlexPY"
url = "https://192.168.42.52"
scale = 1
icon = "muximux-plex"
color = "#f9be03"
enabled = "true"
EOF

sed -i "s@192.168.42.52@$Py_SDOM.$DOMAIN@g" files/includes/muximux.conf
INSTALLED+=('Py')
