#!/bin/bash -e
#
# Script for monitoring
##################################################
MAILER='mail'
RECPIPIENTS="admin@acme.com, chris.upkes@neotechnology.com"
NEOBAK="/opt/neo4j/backup"
THRESHOLD=80
LOGTAG=NEO4J_SUPPORT
BODY="Warning, you have used $SPACEUSED of available storage in your Neo4j backup location!"
SUBJECT="Monitor Notice"
if [ -d $NEOBAK ]; then
	SPACEUSED=$(df -k $NEOBAK | awk 'NR!=1{ print $5 }')
	USED=$(cat $SPACEUSED | sed 's/[^0-9]*//g' )
	logger -p local0.notice -t $LOGTAG "$SPACEUSED of available space in backup directory used"
	if (( $USED > $THRESHOLD )) then
		( cat $BODY | $MAILER -s "$SUBJECT" "$RECIPIENTS" );
	fi
else
	echo "cannot locate backup directory : $NEOBAK\n"
fi

#################
#  put your custom monitoring code here
#################