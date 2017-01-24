#!/bin/bash
# Script to add a user to Linux system
# Script tested by Christopher Upkes, 5-19-2016
#######################################################
LOGTAG="NEO4J_SUPPORT"
if [ $(id -u) -eq 0 ]; then
	read -p "Enter username : " username
	read -s -p "Enter password : " password
	egrep "^$username" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "$username exists!"
		exit 1
	else
		pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
		useradd -m -p $pass $username
		if [ $? -eq 0 ]; then
			echo "User has been added to system!"
			logger -p local0.notice -t $LOGTAG "user $username added to server"
			usermod -G10 $username
			if [ $? -eq 0 ]; then
				echo "User added to wheel group for sudo"
				logger -p local0.notice -t $LOGTAG "user $username added to wheel group"
			else
				echo "Unable to add user to wheel group"
				logger -p local0.notice -t $LOGTAG "unablel to add user $username to wheel group"
				exit 2
			fi			
		else
			echo "Failed to add a user!"
			logger -p local0.notice -t $LOGTAG "error adding user $username"
		fi
	fi
else
	echo "Only root may add a user to the system"
	exit 3
fi