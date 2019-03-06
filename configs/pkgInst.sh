#!/bin/bash

export DEBIAN_FRONTEND="noninteractive"

failed=1
while [ "$failed" -eq 1 ]
do
	add-apt-repository -y ppa:linbit/linbit-drbd9-stack
	if [ $? -ne 0 ]
	then
		continue
	fi

	apt-get update
	debconf-set-selections <<< "postfix postfix/mailname string nfs1.deposit-solutions.local"
	debconf-set-selections <<< "postfix postfix/main_mailer_type string 'No configuration'"

	apt-get install -y postfix
	if [ $? -ne 0 ]
	then
		continue
	fi
	apt-get install -y drbd-utils python-drbdmanage drbd-dkms
	if [ $? -ne 0 ]
	then
		continue
	fi
	apt-get install -y ntp
	if [ $? -ne 0 ]
	then
		continue
	fi
	apt-get install -y nfs-kernel-server
	if [ $? -ne 0 ]
	then
		continue
	fi
	apt-get install -y keepalived
	if [ $? -ne 0 ]
	then
		continue
	fi
	failed=0
done
