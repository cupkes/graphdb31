#!/bin/bash -e
#
#
# Script configuring intrusion detection
# Script tested on 5/22/2016 by Christopher Upkes
#################################################
LOGTAG="NEO4J_SUPPORT"
# provide the crontab entry for the intrusion detection module
AIDE_ENTRY="0 1 * * * /usr/sbin/aide --check"
ADMIN_EMAIL=admin@acme.com

NEOLOG=neo4j_install.log

if [ -e $NEOLOG ]; then
	echo "located log file"
else
	echo "unable to locate log file, creating new log file"
	echo "$(date) : begin Neo4J installation logging -- " > $NEOLOG
fi

#------------------------------------------------
# Install intrusion detection package
#------------------------------------------------

# check to see if the aide package is already installed

AIDETEST=$(yum list installed aide |& grep Error | awk '{ print $1 }' | sed s/://) 

# install the aide package if it is missing
if [ !-z $AIDETEST ]; then
	echo "AIDE already installed"
else
	if [ $AIDETEST = "Error" ]; then
		echo "AIDE not installed, installing" && logger -p local0.notice -t $LOGTAG "installing AIDE"
		yum install -y aide
	fi
fi

# update the crontab mailto configuration with the admin email

sed -i 's/root/$ADMIN_EMAIL/' /etc/crontab

# initialize the aide package and get the service started

aide --init

logger -p local0.notice -t $LOGTAG "AIDE initialized"

# navigate to the aide library directory
# the aide service creates a new database
# so we rename the new database to the default

cd /var/lib/aide
mv aide.db.new.gz aide.db.gz

# according to the manual, we need to invoke the check & update routines
# and then switch to the newly created database

aide --check
aide --update

rm aide.db.gz

mv aide.db.new.gz aide.db.gz

# now we update the crontab with an entry for the aide package

crontab -e

echo "$AIDE_ENTRY " >> /etc/crontab


logger -p local0.notice -t $LOGTAG "crontab updated with AIDE entry"
