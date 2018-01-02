#!/bin/bash
# Seedbox manager
#
# author       : zerpex ( zerpex@gmail.com )
# Last updated : 2017 04 03
# Version 1.5
#
# Github : https://github.com/zerpex/seedbox_docker

# Define path
PWD=$(pwd)
SCRPATH=$PWD/files/scripts

# Variables includes 
source $SCRPATH/vars.sh

# Check if a package is installed
# $1 = Package to check
# 0 = No
# 1 = Yes
is_package_installed() {
    if [[ ! -z $1  ]]; then
        echo $(dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c ' installed')
    fi
}

# Check if system is debian based
if [ ! -f /etc/debian_version ];
then
    echo -e "${CRED}This script has been writen for Debian-based distros."
    exit 0
fi

# Check user and if sudo is installed
if [ -f /usr/bin/sudo ]
then
    ROOT=`whoami`
    if [ $ROOT == "root" ]
    then
        SUDO=
    else
        echo -e "${CRED}sudo is not installed on this system and you are not root.$CEND"
        echo -e "${CRED}Please either install sudo or execute this script as root.$CEND"
        exit 1
    fi
else
        SUDO=sudo
fi

# Installation pre-requiresites

echo " "
echo -e "${CGREEN}Installing pre-requiresites$CEND"
echo " "
$SUDO apt-get update
$SUDO apt-get -y upgrade
$SUDO apt-get -y install dialog sudo apt-transport-https ca-certificates curl

# Installation menu begin
if [ -z $DISPLAY ]
   then
      DIALOG=dialog
   else
      DIALOG=Xdialog
fi

# OK to check and install docker ?
$DIALOG --title " IMPORTANT " --clear \
        --yesno "This script require docker and docker-compose, it will install it automatically if not found on the system.\n
  Do you agree ?" 15 75

case $? in
  0)
    # If docker is not installed
	if ! is_package_installed docker; then
	  # Install docker
	  source $SCRPATH/ins_docker.sh
	fi

	# If docker-compose is not installed
	if [ ! -s /usr/local/bin/docker-compose ]
	then
	  # Install docker-compose
	  source $SCRPATH/ins_docker-compose.sh
	fi
    ;;
  1)
    # Can't do anything without docker
    echo "KTHXBYE."
    exit 0
    ;;
esac

# Define the root path 
D_PATH=($DIALOG --title " Root path " --clear \
             --inputbox "Please set the root path of your installation
( default to /home/seebox ) :" 16 75 "/home/seebox")
DEFAULT_PATH=$("${D_PATH[@]}" 2>&1 >/dev/tty)

# Define the incoming path 
I_PATH=($DIALOG --title " Incoming path " --clear \
        --inputbox "Please set the path of your incoming folder
( default to $DEFAULT_PATH/incoming ) :" 16 75 "$DEFAULT_PATH/incoming")
INC_PATH=$("${I_PATH[@]}" 2>&1 >/dev/tty)

# Define the media path 
M_PATH=($DIALOG --title " Media path " --clear \
        --inputbox "Please set the path of your media folder
( default to $DEFAULT_PATH/media ) :" 16 75 "$DEFAULT_PATH/media")
MEDIA_PATH=$("${M_PATH[@]}" 2>&1 >/dev/tty)

# Define the containers' configuration path 
C_PATH=($DIALOG --title " Configuration path " --clear \
        --inputbox "Please set the path where you want to store apps configuration files
( default to $PWD/files/apps ) :" 16 75 "$PWD/files/apps")
CONF_PATH=$("${C_PATH[@]}" 2>&1 >/dev/tty)

# Create all this directories
$SUDO mkdir -p $DEFAULT_PATH $INC_PATH $MEDIA_PATH $CONF_PATH

IFACE=$WAN

# Begin generating docker receipe
cat files/includes/head.docker > docker-compose.yml

# Select apps to install
cmd=(dialog --separate-output --checklist "Select options:" 22 85 16)
options=("Muximux" "Application management console (Heavily recommanded)" on
         "rTorrent" "Download : Torrents" off
         "SABnzdb" "Download : Newsgroups" off
         "Emby" "Streaming : Video" off
         "Libresonic" "Streaming : Music" off
         "Ubooquity" "Streaming : Comics" off
         "Radarr" "Automation : Movies" off
         "Medusa" "Automation : TV shows" off
         "Headphones" "Automation : Music" off
         "Mylar" "Automation : Comics" off
         "Watchtower" "Tool : Auto-update apps (Heavily recommanded)" on
         "Portainer" "Tool : Containers management through browser (recomanded)" on
         "Syncthing" "Tool : Devices synchronisation" on)
choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
clear

# Install selected apps
for choice in $choices
do
	source $SCRPATH/app_$choice.sh
done

cat files/includes/foot.docker >> docker-compose.yml

# Set global variables
$SUDO sed -i "s@1069@$SUID@g" docker-compose.yml
$SUDO sed -i "s@1069@$SGID@g" docker-compose.yml
$SUDO sed -i "s@CONF@$CONF_PATH@g" docker-compose.yml

# Set permissions
$SUDO chown -R $SUID:$SGID $DEFAULT_PATH
$SUDO chown -R $SUID:$SGID $INC_PATH
$SUDO chown -R $SUID:$SGID $MEDIA_PATH

# Generate and start all needeed containers
docker network create traefik_proxy
docker-compose up -d
sleep 5

# Update Muximux conf
docker stop $Mx_CNAME
$SUDO rm $CONF_PATH/muximux/conf/www/muximux/settings.ini.php
$SUDO cp files/includes/muximux.conf $CONF_PATH/muximux/conf/www/muximux/settings.ini.php
$SUDO chown -R $SUID:$SGID $CONF_PATH/muximux/conf/www/muximux/settings.ini.php
sleep 5
docker start $Mx_CNAME

# Writing a beautifull resume
for APP in "${INSTALLED[@]}"
do
	CNAME=_CNAME
	SDOM=_SDOM
	CONTNAME=$(eval "echo \$$APP$CNAME")
	FDOM=$(eval "echo \$$APP$SDOM")
	FNAME=`echo $CONTNAME | awk -F_ '{print $2}'`
	STATE=`docker inspect -f {{.State.Running}} $CONTNAME`

	if [ "$STATE" == "true" ]
	then
		echo -e "=> [ ${CGREEN}OK$CEND ] $FNAME is now installed and running at ${CYELLOW}http://$FDOM$CEND"
	else
		echo -e "!! [ ${CRED}KO$CEND ] $FNAME is not installed, but not running. Please check logs with "docker logs $CONTNAME" !"
	fi
done

echo " "
echo -e "If you installed Muximux, you can access all your apps directly through : ${CYELLOW}http://$Mx_SDOM.$DOMAIN$CEND"
echo " "

