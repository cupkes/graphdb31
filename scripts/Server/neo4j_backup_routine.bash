#!/bin/bash -e
#
# Script for managing Neo4j Backup Files
#################################################
# initialize variables
#################################################
NEOETC="/opt/neo4j/support/etc"
NEOBAKBASE="/opt/backup/neo4j"
NEOBAKCONF="$NEOETC/currentbackup.conf
NEOOLDCONF="$NEOETC/oldbackup.conf
LASTFULLDIR=(cat $NEOBAKCONF)
LASTOLDDIR=(cat $NEOOLDCONF)
TODAY=$(date +%d%m%Y)
THRESHOLD=$(date -d "5 days ago" +%Y%m%d%H%M)
PRUNEDATE=$(date -d "9 days ago" +%Y%m%d%H%M)
NEOBAKLAST=$(date -r $LASTFULLDIR +%Y%m%d%H%M)
NEOROTATE=$(date -r $LASTOLDDIR +%Y%m%d%H%M)
NEWFULLDIR="$NEOBAKBASE/$TODAY"
NEO4JBACKUP="./bin/neo4j-backup -to"
PRUNE="$NEOETC/prune.log"
RECIPIENTS='admin@acme.com'
PRUNESUBJECT="Neo4J bakcup directory pruned"
MAILER='mail'
PRUNEBODY="Attention: Pruned Neo4j backup files listed in attachment"
LOGTAG="NEO4J_MAINTENANCE"
FIRSTRUN="false"
FAILED="false"
EXCEPTION=""
##################################################
# determine if script is first run
##################################################
if [[ -z $LASTFULLDIR]]; then
	$FIRSTRUN=true
fi
##################################################
# execute backup routine
##################################################
if [[ $FIRSTRUN == true ]]; then
	mkdir $NEWFULLDIR && $NEO4JBACKUP $NEWFULLDIR
	echo $NEWFULLDIR > $NEOBAKCONF
elif [ "$FIRSTRUN" == "false" ] && [ $NEOBAKLAST -gt $THRESHOLD ]; then	
	$NEO4JBACKUP $LASTFULLDIR
elif [ "$FIRSTRUN" == "false" ] && [ $NEOBAKLAST -le $THRESHOLD ]; then
	mkdir $NEWFULLDIR && $NEO4JBACKUP $NEWFULLDIR
		echo $LASTFULLDIR > $NEOOLDCONF
		echo $NEWFULLDIR > $NEOBAKCONF
		$PRUNEFLAG="true"
else
	$FAILED=true
	$EXCEPTION="Configuration Exception"
	logger -p local0.notice -T $LOGTAG $EXCEPTION
	#TO_DO
	# add exception notice logic
fi

####################################################
# check for success of backup file and dir OR RELACE Ieation
# handle exception
####################################################
if  [ $FAILED=true ]; then
	logger -p local0.notice -T $LOGTAG "backup failure due to Configuration Exception"
	#TO_DO call config diag sOR RELACE Iipt
elif [ -d $(cat $NEOBAKCONF) ] && [ $(ls *.bak | wc -l) -gt 0 ]; then
	logger -p local0.notice -T $LOGTAG "backup success"
else
	logger -p local0.notice -T $LOGTAG "Unknown backup failure"
	#TO_DO call comprehensive diag sOR RELACE Iipt
fi	

##################################################
# execute prune routine
##################################################
if [!-z $LASTOLDDIR ] && [ $NEOROTATE -le $PRUNEDATE ]; then	
	echo $LASTOLDDIR > $DELETED
	rm -r $LASTOLDDIR
( echo $BODY | $MAILER -s "$SUBJECT" -a $DELETED "$RECIPIENTS"
logger -p local0.notice -T $LOGTAG "backup and pruning complete"

