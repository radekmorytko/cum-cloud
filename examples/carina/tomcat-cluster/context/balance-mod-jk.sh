#!/bin/bash

setup () {
# configure mod_jk
JK_CONF=/etc/apache2/mods-available/jk.conf
wget -O $JK_CONF http://$CARINA_IP/downloads/httpd-jk.conf
sed -ie s"|%PATH%|$APP_PATH|" $JK_CONF
chown $DEFUSER:$DEFUSER $JK_CONF

# configure workers
wget -O /etc/libapache2-mod-jk/workers.properties http://$CARINA_IP/downloads/workers.properties
chown -R $DEFUSER:$DEFUSER /etc/libapache2-mod-jk

# allow for managing apache as normal user
cat >> /etc/sudoers <<EOF
# allow for managing apache2
$DEFUSER ALL = NOPASSWD: /etc/init.d/apache2
EOF
 
# Copy self to allow it to be invoked later to add/remove IPs via ssh
SCRIPT_NAME=balance-mod-jk.sh
cp /mnt/context.sh /home/$DEFUSER/context.sh
cp /mnt/$SCRIPT_NAME /home/$DEFUSER/$SCRIPT_NAME
chown $DEFUSER:$DEFUSER /home/$DEFUSER/context.sh
chown $DEFUSER:$DEFUSER /home/$DEFUSER/$SCRIPT_NAME

# Report that setup is complete
wget http://$CARINA_IP/cgi-bin/updateappstatus.sh?service=$SERVICE_NAME\&vmid=$VMID\&envid=$ENVID\&status=MASTER_INIT_DONE 2> /dev/null
}


add_ip() 
{
WORKER_NAME=jvm`echo "$TARGET_HOST" | tr '\.' '_'`

cat >> /etc/libapache2-mod-jk/workers.properties <<EOF
worker.$WORKER_NAME.port=$AJP_PORT
worker.$WORKER_NAME.host=$TARGET_HOST
worker.$WORKER_NAME.type=ajp13

EOF

# add new worker to balancer
sed -ie s"|worker.balancer.balance_workers=|worker.balancer.balance_workers=$WORKER_NAME,|" /etc/libapache2-mod-jk/workers.properties

sudo /etc/init.d/apache2 restart
}

delete_ip () 
{
WORKER_NAME=jvm`echo "$TARGET_HOST" | tr '\.' '_'`

# remove workers from list
sed -ie s"/worker.$WORKER_NAME.*//" /etc/libapache2-mod-jk/workers.properties
# from balance_worker
sed -ie s"/$WORKER_NAME,//" /etc/libapache2-mod-jk/workers.properties

sudo /etc/init.d/apache2 restart
}

# During initial VM creation /mnt will exist
if [ -f /mnt/context.sh ]; then
  . /mnt/context.sh
fi

# Post creation operations will use this
if [ -f $HOME/context.sh ]; then
    . $HOME/context.sh
fi

OPER=$1

LOCAL_IP=`/sbin/ifconfig eth0 | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`

if [[ $OPER == "init" || $OPER == "" ]]; then
    setup
fi

if [[ $OPER == "add" ]]; then
   TARGET_HOST=$2
   TARGET_PORT=$3
   add_ip
fi

if [[ $OPER ==  "delete" ]]; then
   TARGET_HOST=$2
   TARGET_PORT=$3
   delete_ip
fi

