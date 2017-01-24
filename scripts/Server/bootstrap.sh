#!/bin/bash -e
#
# Script for initializing NEO4J Server Config
# This script must be run as the neo4j user
# and must be run as super user
# Script tested on 1/24/2017 by Christopher Upkes
#################################################

#------------------------------------------------ 
# Script variables
#------------------------------------------------
LOGTAG=NEO4J_SUPPORT
GITREPO="https://github.com/cupkes/LMInstall.git"
GITCLONECMD="git clone $GITREPO"
REPODIR="/home/neo4j/repo"
REPO="LMInstall"
VERSION="3.1.0"
SUPPORT_TGZ_FILE=neo4j_support.tar.gz
NEO4J_SERVER_TGZ=neo4j-enterprise-$VERSION-unix.tar.gz
INITSCRIPT=neo4j_init.sh

# make sure the neo4j home directory exists
logger -p local0.notice -t $LOGTAG "neo4j bootstrap script called"

if [ -d /home/neo4j ]; then
	echo "located neo4j home directory"
	mkdir $REPODIR
		if [ $? -ne 0 ]; then
			echo "unable to create directory $REPODIR"
			echo "ERROR: unable to create $REPODIR." >> $NEOLOG
			logger -p local0.notice -t $LOGTAG "neo4j bootstrap ERROR"
			exit 2
		else
			chown neo4j:neo4j $REPODIR
			cd $REPODIR
		fi
		
else
	echo "could not locate neo4j home directory, aborting script"
	exit 1
fi

GITTEST=$(yum list installed git |& grep Error | awk '{ print $1 }' | sed s/://) 

# if there is no git package installed, install the git package

if [ -z $GITTEST ]; then
	echo "GIT already installed"
else
	if [ $GITTEST = "Error" ]; then
		echo "GIT not installed, installing" && logger -p local0.notice -t $LOGTAG "installing GIT"
		yum install -y git
	fi
fi
# setting http proxy
source <(curl -sk https://sscgit.ast.lmco.com/projects/CP/repos/openstack-instance-utils/browse/lm-proxy/lm-proxy.sh?raw) 

$GITCLONECMD
if [ $? -ne 0 ]; then
		echo "unable to call git clone"
		echo "ERROR: unable to call $GITCLONE." >> $NEOLOG
		logger -p local0.notice -t $LOGTAG "neo4j bootstrap ERROR"
		exit 3
else
	cd $REPO
	if [[ -f $SUPPORT_TGZ_FILE && -f $NEO4J_SERVER_TGZ  && -f $INITSCRIPT  ]]; then
		echo "required files found"
	else
		echo "unable to locate all required files"
		echo "ERROR: Missing required files." >> $NEOLOG
		logger -p local0.notice -t $LOGTAG "neo4j bootstrap script ERROR"
		exit 4
	fi
fi
echo "Bootstrap complete.  Ready to initialize host"
logger -p local0.notice -t $LOGTAG "neo4j bootstrap script completed"
# call the initialization script
# chmod +x $INITSCRIPT
# ./$INITSCRIPT


	

	