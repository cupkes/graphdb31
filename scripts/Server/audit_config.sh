#!/bin/bash -e
#
#
# Script installling Audit
# Script tested on 5/22/2016 by Christopher Upkes
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
# Install and configure auditing
#------------------------------------------------

#
# To ensure we meet the standard security certification guidelines,
# we need to make sure auditing is installed and running rules
# based on the considered requirements (stig, capp, nipsom, etc...).
# 

# check to see if auditing is installed and install if it is missing

AUDITTEST=$(yum list installed audit |& grep Error | awk '{ print $1 }' | sed s/://) 

if [ -z $AUDITTEST ]; then
	echo "AUDIT already installed"
else
	if [ $AUDITTEST = "Error" ]; then
    echo "AUDIT not installed, installing" && logger -p local0.notice -t $LOGTAG "installing AUDIT"
	yum install -y audit
	fi
fi

# set audit rules -- here I use stig because it's thorough



auditctl -R /usr/share/doc/audit-version/stig.rules
if [ $? -eq 0 ]; then
	echo "audit rules loaded"
	logger -p local0.notice -t $LOGTAG "auditing rules loaded and auditing started"
else
	echo "unable to reload audit daemon with new rules"
	echo "please execute auditctl -R and provide valid rules file"
	logger -p local0.notice -t $LOGTAG "erro loading audit rules"
fi


# optionally you can copy the specific rules file to the default:
#
# cp /etc/audit/audit.rules /etc/audit/audit.rules_backup
# cp /usr/share/doc/audit-version/stig.rules /etc/audit/audit.rules
#
# or nipsom.rules
# or capp.rules
# or lspp.rules