#!/bin/sh

if [ -f /mnt/context.sh ]; then
  . /mnt/context.sh
fi

# install mysql-server if necessary
dpkg-query -W -f='${Status}\n' mysql-server
if [ $? != 0 ]; then
	export DEBIAN_FRONTEND=noninteractive
	apt-get -q -y install mysql-server
	mysqladmin -u root password $ROOT_PASSWORD
fi

DIR=/home/$DEFUSER
wget -O $DIR/$SQL_SCRIPT http://$CARINA_IP/downloads/$SQL_SCRIPT
chown $DEFUSER:$DEFUSER $DIR/$SQL_SCRIPT
mysql -u root -p$ROOT_PASSWORD < $DIR/$SQL_SCRIPT

wget http://$CARINA_IP/cgi-bin/updateappstatus.sh?service=$SERVICE_NAME\&vmid=$VMID\&envid=$ENVID\&status=MASTER_INIT_DONE 2> /dev/null
