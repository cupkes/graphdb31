#!/bin/bash -e
#
#
# Script installling OpenJDK
# Script tested on  5/22/2016 by Christopher UPkes
##################################################
LOGTAG="NEO4J_SUPPORT"
NEOLOG=neo4j_install.log

if [ -e $NEOLOG ]; then
	echo "located log file"
else
	echo "unable to locate log file, creating new log file"
	echo "$(date) : begin Neo4J installation logging -- " > $NEOLOG
fi

#------------------------------------------------
# Install a jdk
#------------------------------------------------

# 
# The neo4j cluser requires at minimum a java 6 jdk to be installed
#

# determine if the java 8 openjdk is installed.
# We should improve this script by checking for multiple releases (6,7,8)
# and multiple vendors (openjdk, Oracle).

JDKTEST=$(yum list installed java-1.8.0-openjdk |& grep Error | awk '{ print $1 }' | sed s/://) 

# if there is no jdk installed, install the openjdk 1.8.0 package

if [ -z $JDKTEST ]; then
	echo "JDK already installed"
else
	if [ $JDKTEST = "Error" ]; then
		echo "JDK not installed, installing" && logger -p local0.notice -t $LOGTAG "installing JDK"
		yum install -y java-1.8.0-openjdk
	fi
fi
