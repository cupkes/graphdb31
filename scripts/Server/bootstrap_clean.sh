#!/bin/bash -e
#
# Script for initializing NEO4J Server Config
# This script must be run as the neo4j user
# and must be run as super user
# Script tested on 1/25/2017 by Christopher Upkes
#################################################

#------------------------------------------------ 
# Script variables
#------------------------------------------------
LOGTAG=NEO4J_SUPPORT
NEOUSERHOME="/home/neo4j"
GITREPO="https://github.com/cupkes/LMInstall.git"
GITCLONEMD="git clone $GITREPO"
REPODIR="$NEOUSERHOME/repo"
REPO="LMInstall"
VERSION="3.1.0"
SUPPORT_TGZ_FILE=neo4j_support.tar.gz
NEO4J_SERVER_TGZ=neo4j-enterprise-$VERSION-unix.tar.gz
INITSCRIPT=neo4j_init.sh
CLUSTERCONF_FILE=cluster.conf
SAMBACONF_FILE=neo4j_smb.conf
NEO4J_SERVER_CONFIG_FILE=neo4j.conf
#------------------------------------------------ 
# END Script variables
#------------------------------------------------
logger -p local0.notice -t $LOGTAG "neo4j bootstrap_clean script called"

GITTEST=$(yum list installed git |& grep Error | awk '{ print $1 }' | sed s/://) 

# if there is no git package installed, install the git package
echo "removing git package"
if [ -z $GITTEST ]; then
	echo "GIT installed, removing GIT" && logger -p local0.notice -t $LOGTAG "removing GIT"
	yum remove -y git && logger -p local0.notice -t $LOGTAG "GIT package removed"
else
	if [ $GITTEST = "Error" ]; then
		echo "GIT not installed"
	fi
fi
echo "removing install repository"
# remove install repository
if [ -d $REPODIR ]; then
	echo "located neo4j repository"
	cd /home/neo4j
	rm -r repo
	echo "cleaning up neo4j home"
	logger -p local0.notice -t $LOGTAG "neo4j repsitory removed"
else
	echo "could not locate neo4j repository"
fi

# clean up neo4j user's home directory
echo "removing install files from neo4j users' home directory"
rm $NEOUSERHOME/$NEO4J_SERVER_TGZ
rm $NEOUSERHOME/$SUPPORT_TGZ_FILE
rm $NEOUSERHOME/$INITSCRIPT
rm $NEOUSERHOME/$CLUSTERCONF_FILE
rm $NEOUSERHOME/$SAMBACONF_FILE
rm $NEOUSERHOME/$NEO4J_SERVER_CONFIG_FILE

logger -p local0.notice -t $LOGTAG "neo4j home directory cleansed"

# make sure the neo4j home directory exists
logger -p local0.notice -t $LOGTAG "neo4j bootstrap_clean script completed"

