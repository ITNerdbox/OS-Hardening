#!/bin/bash

#----------------------------------------------------------------------------------------------#
# Configuration Settings & Variables
#----------------------------------------------------------------------------------------------#
COL_RED="\033[0;31m"
COL_GRN="\e[92m"
COL_WHI="\e[97m"
COL_NON="\033[0m"

GITHUB_REPO="https://raw.githubusercontent.com/ITNerdbox/hardening-configurations/master"
PATH_OS_RELEASE="/etc/os-release"


clear;
echo ""
echo -e "${COL_WHI}"
echo -n '
┌────────────────────────────────────────────────────────────────────────────────────────┐
│   ________    _________ ___ ___                  .___            .__                   │
│   \_____  \  /   _____//   |   \_____ _______  __| _/____   ____ |__| ____    ____     │
│    /   |   \ \_____  \/    ~    \__  \\_  __ \/ __ |/ __ \ /    \|  |/    \  / ___\    │
│   /    |    \/        \    Y    // __ \|  | \/ /_/ \  ___/|   |  \  |   |  \/ /_/  >   │
│   \_______  /_______  /\___|_  /(____  /__|  \____ |\___  >___|  /__|___|  /\___  /    │
│           \/        \/       \/      \/           \/    \/     \/        \//_____/     │
│                                                   v1.2 (c) 2018 - 2020 by J. Diel      │
└────────────────────────────────────────────────────────────────────────────────────────┘'
echo -e "${COL_NON}"


showWarning() {
        echo -e "${COL_RED}"
        echo -e '
   ┌─────────────────────────────────────────────────────────────────────────────────┐
   │      :: W A R N I N G :: W A R N I N G :: W A R N I N G :: W A R N I N G ::     │
   └─────────────────────────────────────────────────────────────────────────────────┘
   
   '
        echo -ne "${COL_WHI}"
}

doHarden() {
	## Checks
	if [ $EUID -ne 0 ]; then
	   echo "  [Error]: The script must be executed as root!"
	   exit 1
	fi

	## Creating backup directory
	mkdir -p ~/configuration-backups
	chmod 640 ~/configuration-backups

	## Introduction
	echo ""
	echo -e " ${COL_GRN} INTRODUCTION: ${COL_NON}"
	echo -e "${COL_WHI}"
	echo "   This is a post installation operating system hardening script for Debian 10 servers. "
	echo ""
	echo "   Before continuing the hardening of the operating system it's required to create a"
	echo "   new user to the the system that will be added to the sudoers group.                                     "
	echo ""
	echo "   It is important to understand that the SSH configuration will disable password based"
	echo "   auth and that a public/private key should be created on your client before proceeding."
	echo -ne "${COL_NON}"
	echo ""

	## Creating a (sudo) user
	read -p "  Enter your username : " user
	read -sp "  Enter your password : " pass
	echo ""
	egrep "^$user" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "  [Error]: The username $username already exists!"
		exit 1
	fi

	useradd -s /bin/bash -m $user
	echo "$user:$pass" | chpasswd
	usermod -aG sudo $user

	showWarning

	echo "   NOTE: If a key is already present, step one can be skipped"
	echo ""
	echo "   Please execute the following commands on your client:"
	echo ""
	echo "    [1] ssh-keygen -t ed25519"
	echo "    [2] ssh-copy-id -i ~/.ssh/id_ed25519.pub $user@`curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'`"
	echo -e "${COL_NON}"
	echo ""
	read -sp "  Enter your password again to continue: " check_pass

	if [ "$pass" = "$check_pass" ]; then
	    echo ""
	    if [ -f /home/$user/.ssh/authorized_keys ]; then
	       check=`cat /home/$user/.ssh/authorized_keys | grep ed25519 | wc -l`
	       if [ $check -gt "0" ]; then
			  echo ""
			  echo -ne " ${COL_GRN} HARDENING SSH DAEMON : ${COL_NON}"
		      mv /etc/ssh/sshd_config ~/configuration-backups
		      wget -q -O /etc/ssh/sshd_config $GITHUB_REPO/sshd_config
		    
		      chmod 640 /etc/ssh/sshd_config
		      chmod 640 /etc/ssh
		      /etc/init.d/ssh restart > /dev/null
			  echo " Done "

			## Make else and warn, restore original sshd_config
		   fi
	    fi
	fi

	## OS Updating
	echo -ne " ${COL_GRN} UPDATING SYSTEM      : ${COL_NON}"
	apt-get update --assume-yes > /dev/null
	apt-get upgrade --assume-yes > /dev/null
	echo " Done"

	## Install required package(s)
	echo -ne " ${COL_GRN} INSTALL REQUIREMENTS : ${COL_NON}"
	apt-get install curl --assume-yes > /dev/null
	apt-get install ca-certificates --assume-yes > /dev/null
	apt-get install libpam-cracklib --assume-yes > /dev/null
	apt-get install acl --assume-yes > /dev/null
	apt-get install unattended-upgrades apt-listchanges --assume-yes > /dev/null
	apt-get install ufw --assume-yes > /dev/null
	apt-get install sudo --assume-yes > /dev/null
	echo " Done"

	## Updating PAM setting for UMASK
	echo -ne " ${COL_GRN} UPDATING GLOBAL UMASK: ${COL_NON}"
	echo "session optional pam_umask.so" >> /etc/pam.d/common-session
	wget -q -O /etc/login.defs $GITHUB_REPO/login.defs
	echo " Done "

	## Disable core dumps
	echo -ne " ${COL_GRN} DISABLE CORE DUMPS   : ${COL_NON}"
	echo "* soft core 0" >> /etc/security/limits.conf
	echo "* hard core 0" >> /etc/security/limits.conf
	echo " Done "

	## Setup Firewall 22/TCP only
	echo -ne " ${COL_GRN} ENABLE FIREWALL     : ${COL_NON}"
	ufw default deny incoming
	ufw allow 22
	ufw enable
	echo " Done "

	## Update sysctl.conf
	mv /etc/sysctl.conf ~/configuration-backups
	wget -q -O /etc/sysctl.conf $GITHUB_REPO/sysctl.conf\
	chmod 644 /etc/sysctl.conf
	sysctl -p > /dev/null 2>1

}


if test -f $PATH_OS_RELEASE; then
   distro=`cat $PATH_OS_RELEASE | grep "ID=" | grep -v "VERSION_ID" | cut -d "=" -f 2`
   release=`cat $PATH_OS_RELEASE | grep "VERSION_CODENAME" | cut -d "=" -f 2`
fi

if [ $distro ]; then
	echo ""
	echo ""
	echo -e " ${COL_GRN} DETECTED DISTRIBUTION: ${COL_NON} ${distro^} (${release^})"
	doHarden
else

	showWarning

	echo "    It appears this is not a Debian like distribution. Continuing might not give the"
        echo -n "    expected results. "
	read -p "Do you want to continue? [y|N]: " cont

        if [ "$cont" != "${cont#[Yy]}" ] ;then
           doHarden
        else
           echo ""
           echo "    Smart choice, unexpected behaviour could possibily result in security risks."
        fi
fi
