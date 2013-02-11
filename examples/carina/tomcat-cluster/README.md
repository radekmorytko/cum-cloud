Introduction
============

Directory contains configuration files that can be used to setup clustered application server environment. 

Tomcat is used as an example application container running on Ubuntu 12.04. Apache with installed mod\_jk is used as a load balancing mechanism. Finally,
mysql is used as a database.

Prerequisites
=============

It is assumed that OpenNebula and Carina are setup and running.

It is necessary that some precreated Ubuntu 12.04 image exists and is imported to OpenNebula. This image has to contain installed apache2 (+ mod\_jk) and tomcat6 server. Abovementioned packages can be installed by:
<pre>
sudo apt-get update
sudo apt-get install apache2 libapache2-mod-jk tomcat6
</pre>

Directory structure
===================

Directory contains sud-directories that are relating to carina's configuration, load-balancer or tomcat. 

Files aim only to give some overview how to setup own environment. Hence, configuration (like setting own ports, image id, upload files, etc) is required.

Carina configuration
--------------------
 * config.rb - service provider configuration 
   * adjust image\_id and network\_id, endpoints, etc - reflecting your carina configuration
   * it should be placed in /home/$SERVICE\_HOME/ directory
 * global.rb - global configuration
   * adjust enpoints, zones
   * it should be placed in $CARINA\_LOCATION/etc/
 * ubuntu1204.vm
   * adjust $DEFUSER, network configuration

Please remember to upload config.rb and ubuntu1204.vm template using oneenv --upload command

Contextualization scripts
------------------------

 * tomcat-cluster.sh, balance-mod-jk.sh, mysql.sh
   * should be place in service's providers contextualization directory

Load balancer (master)
----------------------
 * httpd-jk.conf - apache mod condiguration
   * among other things, it contains mounting point for workers
   * place it in carina's download directory
 * workers.properties
   * specifies workers that are used by balancing mechanism
   * place it in carina's download directory

Tomcat (slave)
--------------
 * server.xml - server.xml file used by tomcat
  * sets up AJP\_PORT during contextualization
  * sets up JVM\_ROUTE during contextualization
  * currently SimpleTcpCluster is used
  * place it in carina's download directory
 * demoapp - maven project
  * application contains simple jsp page to show session information
  * note that web.xml contains <distributable/> directive
  * build with mvn package
  * war should be placed in carina's download directory

MySQL (master only)
--------------
 * demoapp.sql
  * creates sample database, table and inserts some data
  * should be placed in carina's download directory
