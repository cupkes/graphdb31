#!/bin/bash -e
#
# Script for initializing NEO4J Server Config
# This script must be run as the neo4j user
# and must be run as super user
# Script tested on x/xx/2017 by Christopher Upkes
#################################################

#------------------------------------------------ 
# Script variables
#------------------------------------------------
LOGTAG=NEO4J_SUPPORT
GITREPO="https://github.com/cupkes/LMInstall.git"
GITCLONEMD="git clone $GITREPO"
REPODIR="/home/neo4j/repo"
REPO="LMInstall"
VERSION="3.1.0"
SUPPORT_TGZ_FILE=neo4j_support.tar.gz
NEO4J_SERVER_TGZ=neo4j-enterprise-$VERSION-unix.tar.gz
INITSCRIPT=neo4j_init.sh
#------------------------------------------------ 
# END Script variables
#------------------------------------------------
logger -p local0.notice -t $LOGTAG "neo4j bootstrap_clean script called"

GITTEST=$(yum list installed git |& grep Error | awk '{ print $1 }' | sed s/://) 

# if there is no git package installed, install the git package

if [ -z $GITTEST ]; then
	echo "GIT installed, removing GIT" && logger -p local0.notice -t $LOGTAG "removing GIT"
	yum remove git && logger -p local0.notice -t $LOGTAG "GIT package removed"
else
	if [ $GITTEST = "Error" ]; then
		echo "GIT not installed"
	fi
fi

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


# make sure the neo4j home directory exists
logger -p local0.notice -t $LOGTAG "neo4j bootstrap_clean script completed"

