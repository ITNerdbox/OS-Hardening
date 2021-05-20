#!/bin/bash


#----------------------------------------------------------------------------------------------#
# User Configuration Settings & Variables
#----------------------------------------------------------------------------------------------#
PASSWORD_LENGTH=12		# The minimum password length
PASSWORD_LCASE=3		# The minimum number of required lowercase characters 
PASSWORD_UCASE=3		# The minimum number of required uppercase characters
PASSWORD_SCHAR=2		# The minimum number of required special characters
PASSWORD_DIGIT=1		# The minimum number of required digits


#----------------------------------------------------------------------------------------------#
# System Configuration Settings & Variables
#----------------------------------------------------------------------------------------------#
COL_RED="\033[0;31m"
COL_GRN="\e[92m"
COL_WHI="\e[97m"
COL_NON="\033[0m"

GITHUB_REPO="https://raw.githubusercontent.com/ITNerdbox/OS-Hardening/master"
PATH_OS_RELEASE="/etc/os-release"
PATH_BACKUP="/root/os-hardening-backups"


#----------------------------------------------------------------------------------------------#
# Script Functions
#----------------------------------------------------------------------------------------------#
function init() {
	if [ $EUID -ne 0 ]; then
   		echo "  [Error]: The script must be executed as root!"
		exit 1
	fi

	## Create a backup directory and set permissions
	mkdir -p $PATH_BACKUP
	chmod 640 $PATH_BACKUP

	## Update the system
	echo -ne " ${COL_GRN} UPDATING SYSTEM                  : ${COL_WHI}"
	apt-get autoremove --assume-yes > /dev/null
	apt-get update --assume-yes > /dev/null
	apt-get upgrade --assume-yes > /dev/null
	echo " Done"


	## Install required package(s)
	echo -ne " ${COL_GRN} INSTALL REQUIREMENTS             : ${COL_WHI}"
	apt-get install apt-transport-https --assume-yes > /dev/null
	apt-get install debsums --assume-yes > /dev/null
	apt-get install ca-certificates --assume-yes > /dev/null
	apt-get install libpam-cracklib --assume-yes > /dev/null
	apt-get install acl --assume-yes > /dev/null
	apt-get install unattended-upgrades apt-listchanges --assume-yes > /dev/null
	apt-get install ufw --assume-yes > /dev/null
	apt-get install sudo --assume-yes > /dev/null
	echo " Done"


	## Install temporary package(s)
	echo -ne " ${COL_GRN} INSTALLING TEMPORARY PACKAGES    : ${COL_WHI}"
	apt-get install curl --assume-yes > /dev/null
	echo " Done "
}


function banner() {
	echo -e "${COL_WHI}"
	echo -n '
┌────────────────────────────────────────────────────────────────────────────────────────┐
│      _____  _____     __ __  _____  _____  _____  _____  _____  ___  _____  _____      │
│     /  _  \/  ___>   /  |  \/  _  \/  _  \|  _  \/   __\/  _  \/___\/  _  \/   __\     │
│     |  |  ||___  |   |  _  ||  _  ||  _  <|  |  ||   __||  |  ||   ||  |  ||  |_ |     │
│     \_____/<_____/   \__|__/\__|__/\__|\_/|_____/\_____/\__|__/\___/\__|__/\_____/     │
│                                                                                        │
├────────────────────────────────────────────────────────────────────────────────────────┤
│     Debian 10                                      v1.3 (c) 2018 - 2020 by J. Diel     │
└────────────────────────────────────────────────────────────────────────────────────────┘'
	echo -e "${COL_NON}"
}


function warning() {

        echo -e "${COL_RED}   ┌──────────────────────────────────────────────────────────────────────────────────┐
   │      :: W A R N I N G :: W A R N I N G :: W A R N I N G :: W A R N I N G ::      │
   └──────────────────────────────────────────────────────────────────────────────────┘${COL_WHI}"
}


function create_user() {
	echo -e " ${COL_GRN} CREATING NEW USER: ${COL_NON}"
        echo -e "${COL_WHI}"
        read -p "   Enter your username : " user
        read -sp "   Enter your password : " pass
        echo ""
        /usr/sbin/groupadd sshlogin > /dev/null
        
        egrep "^$user" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo ""
		/usr/sbin/usermod -aG sudo $user
		/usr/sbin/usermod -aG sshlogin $user
		echo -e "   [${COL_RED}SKIPPED${COL_NON}${COL_WHI}]: The username $user already exists!"
        else
                /usr/sbin/useradd -s /bin/bash -m $user
                echo "$user:$pass" | /usr/sbin/chpasswd
                /usr/sbin/usermod -aG sudo $user
                /usr/sbin/usermod -aG sshlogin $user
        fi
}


function distro() {
	if test -f $PATH_OS_RELEASE; then
		distro=`cat $PATH_OS_RELEASE | grep "PRETTY_NAME" | cut -d "\"" -f 2 | cut -d " " -f 1`
   		version=`cat $PATH_OS_RELEASE | grep "VERSION_ID" | cut -d "\"" -f 2`
	fi

	if [ $distro ]; then
		echo ""
		echo -e " ${COL_GRN} DISTRIBUTION: ${COL_NON} ${COL_WHI} "
		echo ""
		echo -e "   Name     : ${distro^}"
		echo -e "   Version  : ${version^}"
		echo ""
	else
		warning
		echo "    It appears this is not a Debian like distribution. Continuing might not give the"
		echo -n "    expected and wanted result. "
		read -p "Do you want to continue? [y|N]: " cont

		if [ "$cont" != "${cont#[Yy]}" ] ;then
			continue
		else
			echo ""
			echo "    Smart choice, unexpected behaviour could possibily result in security risks."
			exit
		fi
	fi
}

function create_user_ssh_key() {
	echo ""
    	echo -e " ${COL_GRN} CREATING SSH Keys: ${COL_WHI}"
	echo ""
	warning
	echo "   NOTE: If an SSH key is already present, step one can be skipped"
	echo "   Please execute the following commands on your client:"
	echo ""
	echo "    [1] ssh-keygen -t ed25519"
	echo "    [2] ssh-copy-id -i ~/.ssh/id_ed25519.pub $user@`curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'`"
	echo ""
	read -sp "   Enter your password again to continue: " check_pass
	echo -e "${COL_NON}"

	if [ "$pass" = "$check_pass" ]; then
		echo ""
		if [ -f /home/$user/.ssh/authorized_keys ]; then
	   		check=`cat /home/$user/.ssh/authorized_keys | grep ed25519 | wc -l`
		   	if [ $check -gt "0" ]; then
				echo ""
				echo -ne " ${COL_GRN} HARDENING SSH DAEMON             : ${COL_WHI}"
				mv /etc/ssh/sshd_config $PATH_BACKUP
				wget -q -O /etc/ssh/sshd_config $GITHUB_REPO/sshd_config
				chmod 640 /etc/ssh/sshd_config
				chmod 640 /etc/ssh
				/etc/init.d/ssh restart > /dev/null
				echo " Done "
		   	fi
		else
			echo ""
			echo -ne " ${COL_GRN} HARDENING SSH DAEMON : "
			cp -R $PATH_BACKUP/sshd_config /etc/ssh
			chmod 640 /etc/ssh/sshd_config
			chmod 640 /etc/ssh
			/etc/init.d/ssh restart > /dev/null
			echo " Failed and rolled back to original configuration"
		fi
	else
		echo ""
		echo -e "   ${COL_RED}[Error] ${COL_WHI} Passwords do not match!"
		create_user_ssh_key
	fi
}

function harden() {
	## Updating PAM setting for UMASK
	echo -ne " ${COL_GRN} UPDATING GLOBAL UMASK            : ${COL_WHI}"
	echo "session optional pam_umask.so" >> /etc/pam.d/common-session
	wget -q -O /etc/login.defs $GITHUB_REPO/login.defs
	echo " Done "


	## Disable core dumps
	echo -ne " ${COL_GRN} DISABLE CORE DUMPS               : ${COL_WHI}"
	echo "* soft core 0" >> /etc/security/limits.conf
	echo "* hard core 0" >> /etc/security/limits.conf
	echo " Done "


	## Disable root login through console
	echo -ne " ${COL_GRN} DISABLE ROOT CONSOLE LOGIN       : ${COL_WHI}"
	cat /dev/null > /etc/securetty
	echo " Done "


	## Update sysctl.conf
	echo -ne " ${COL_GRN} UPDATING SYSCTL                  : ${COL_WHI}"
	mv /etc/sysctl.conf ~/configuration-backups
	wget -q -O /etc/sysctl.conf $GITHUB_REPO/sysctl.conf
	chmod 644 /etc/sysctl.conf
	/usr/sbin/sysctl -p > /dev/null
	echo " Done "


	## Update home directory permissions
	echo -ne " ${COL_GRN} UPDATING PERMISSIONS             : ${COL_WHI}"
	chmod 750 /home/$user
	echo " Done "

	## Configure CrackLib
	#echo -ne " ${COL_GRN} CONFIGURING CRACKLIB             : ${COL_WHI}"
	#cp /etc/pam.d/common-password $PATH_BACKUP
	#
	# To be implemented 
	#
	#echo " Done "


	## Harden the /tmp partition
	echo -ne " ${COL_GRN} HARDENING /tmp                   : ${COL_WHI}"
	current_partition=`mount | grep "/tmp" | cut -d " " -f 1`
	
	if [ -z "$current_partition" ]; then
		echo " Failed "
	else
		chmod 1777 /tmp
		sed -i '/tmp/d' /etc/fstab
		echo "$current_partition 	/tmp 	ext4 	loop,nosuid,noexec,rw 	0 	0" >> /etc/fstab
		mount -a
		echo " Done "
	fi

	## Disable specific hardware and protocols
	echo install firewire /bin/true >> /etc/modprobe.conf
	echo install usb_storage /bin/true >> /etc/modprobe.conf
	echo install dccp /bin/true >> /etc/modprobe.conf
	echo install sctp /bin/true >> /etc/modprobe.conf
	echo install rds /bin/true >> /etc/modprobe.conf
	echo install tipc /bin/true >> /etc/modprobe.conf

	## Do a cleanup of the system and uninstall specific packages
	cleanup

	## Setup Firewall 22/TCP only
	echo -ne " ${COL_GRN} ENABLE FIREWALL                  : ${COL_WHI}"
	sed -i '/^IPV6/s//#&/' /etc/default/ufw
	/usr/sbin/ufw default deny incoming > /dev/null
	/usr/sbin/ufw allow 22 > /dev/null
	/usr/sbin/ufw enable
	echo " Done "
}


function cleanup() {
	echo -ne " ${COL_GRN} CLEANING UP PACKAGES             : ${COL_WHI}"
	apt-get purge curl --assume-yes > /dev/null
	apt-get purge netcat-traditional --assume-yes > /dev/null
	echo " Done "
}


#----------------------------------------------------------------------------------------------#
# Start of Script
#----------------------------------------------------------------------------------------------#
clear;
banner

echo ""
echo -e " ${COL_GRN} AGREEMENT: ${COL_NON}"
echo ""
echo "   The software is provided 'as is', without warranty of any kind. In no event shall the" 
echo "   author be liable for any claims, damages or other liabilities."
echo ""
warning
read -p "   Do you accept this agreement? [y|N]: " agreement
echo -ne "${COL_NON}"

if [ "$agreement" != "${agreement#[Yy]}" ]; then
	echo ""
	echo -e " ${COL_GRN} INTRODUCTION: ${COL_NON}"
	echo -e "${COL_WHI}"
	echo "   This is a post installation operating system hardening script for Debian 10 servers. "
	echo ""
	echo "   Before continuing the hardening of the operating system it's required to create a"
	echo "   new user to the the system that will be added to the sudoers group.                                     "
	echo ""
	echo "   It is important to understand that the SSH configuration will disable password based"
	echo "   authentication and that a public/private key should be created on your client before"
	echo "   proceeding."
	echo ""

	init
	distro
	create_user
	create_user_ssh_key
	harden
else
   	echo ""
	echo "   Bye!"
fi
