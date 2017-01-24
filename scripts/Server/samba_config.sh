#!/bin/bash -e
#
#
# Script building Samba shares
# Script tested on 5/22/2016 by Christopher Upkes
##################################################
LOGTAG="NEO4J_SUPPORT"
NEOBASE="/opt/neo4j"
SAMBA_FILE=neo4j_smb.conf
CLUSTCONF=cluster.conf
PWDSCRIPT=mksmbpasswd.sh

NEOLOG=neo4j_install.log

if [ -z $SAMBAWINCLIENT ]; then
	echo "loading cluster.conf file"
	source $CLUSTCONF
fi


if [ -e $NEOLOG ]; then
	echo "located log file"
else
	echo "unable to locate log file, creating new log file"
	touch $NEOLOG
fi

if [ -d $NEOBASE/stage ]; then
	echo "located $NEOBASE/stage"
else
	mkdir $NEOBASE/stage && chmod 755 $NEOBASE/stage
fi

firewall-cmd --list-ports | grep 137
if [ $? -ne 0 ]; then
	echo "Samba port 137 not open, aborting script"
	logger -p local0.notice -t $LOGTAG "error configuring Samba.  UDP port not open"
	echo "$(date) ERROR: Firewall not configured for Samba"
	exit 1
else
	# continue configuration
	SAMBATEST=$(sudo yum list installed samba |& grep Error | awk '{ print $1 }' | sed s/://) 

	if [ -z $SAMBATEST ]; then
		echo "samba already installed"
	else
		if [ $SAMBATEST = "Error" ]; then
			echo "installing Samba"
		
			logger -p local0.notice -t $LOGTAG "installing Samba"
		
			yum install -y samba # samba-client
		
			echo "Samba installed"
		fi
	fi
	
		
	logger -p local0.notice -t $LOGTAG "updated neo4j Samba configuration"
		
	systemctl enable smb.service
	if [ $? -ne 0 ]; then
		echo "error enabling Samba service"
		logger -p local0.notice -t $LOGTAG "error enabling Samba service"
		exit 3
	else
		echo "samba service enabled"
		logger -p local0.notice -t $LOGTAG "enabled Samba service"
		systemctl start smb.service
		if [ $? -ne 0 ]; then
			echo "error starting Samba service"
			logger -p local0.notice -t $LOGTAG "error starting Samba service"
			exit 4
		else
			echo "started Samba service"
			logger -p local0.notice -t $LOGTAG "enabled Samba service"
			
		fi
	fi
	if [ -e $PWDSCRIPT ]; then
		chmod +x $PWDSCRIPT
		cat /etc/passwd | source /home/neo4j/$PWDSCRIPT > /etc/samba/smbpasswd
		#source $PWDSCRIPT < cat /etc/passwd > /etc/samba/smbpasswd
		chmod 600 /etc/samba/smbpasswd	
	else
		echo "unable to lcoate $PWDSCRIPT"
		echo "$(date) ERROR: unable to locate $PWDSCRIPT, /etc/samba/smbpassword not created" >> $NEOLOG
	fi
	
	if [ -e $SAMBA_FILE ]; then
		echo "creating neo4j samba server config"
		cp /etc/samba/smb.conf /etc/samba/smb.conf.bak && cp $SAMBA_FILE /etc/samba/smb.conf
		sed -i s/node_name/$SAMBAWINCLIENT/g /etc/samba/smb.conf
		echo "reloading samba service"
		systemctl reload smb.service
		if [ $? -ne 0 ]; then
			echo "error reloading Samba service"
			logger -p local0.notice -t $LOGTAG "error reloading Samba service"
			exit 4
		else
			echo "reloaded Samba service"
			logger -p local0.notice -t $LOGTAG "reloaded Samba service"
			
		fi
	else
		echo "could not locate $SAMBA_FILE, samba not configured for Neo4j"
		echo "$(daate) ERROR:  Samba started but not configured for Neo4j"
	fi
fi
