#!/bin/sh

if [ -f /mnt/context.sh ]; then
  . /mnt/context.sh
fi

# download packages
CATALINA_HOME=/var/lib/tomcat6
SERVER_XML=/etc/tomcat6/server.xml

wget -O $CATALINA_HOME/webapps/$APP_PACKAGE http://$CARINA_IP/downloads/$APP_PACKAGE
wget -O $SERVER_XML http://$CARINA_IP/downloads/server.xml

# set load balancing configuration - jvm route, ajp port
JVM_ROUTE=`echo "$ETH0_IP" | tr '\.' '_'`
sed -ie s"/%JVM_ROUTE%/jvm$JVM_ROUTE/" $SERVER_XML
sed -ie s"/%AJP_PORT%/$AJP_PORT/" $SERVER_XML

/etc/init.d/tomcat6 start

if [ ! -z "$MYSQL_URL" ]; then
	echo "Configuring connection to: $MYSQL_URL" >> /home/$DEFUSER/mysql.log
fi

wget http://$CARINA_IP/cgi-bin/updateappstatus.sh?service=$SERVICE_NAME\&vmid=$VMID\&envid=$ENVID\&status=SLAVE_"$SLAVE_ID"_INIT_DONE 2> /dev/null

