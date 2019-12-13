#!/bin/bash

clear

if [[ $EUID -ne 0 ]]; then
   echo "  [Error]: The script must be executed as root!"
   exit 1
fi

## Upgrade the OS installation if applicable and install curl
echo -n 'Preparing, please wait.'
apt-get update --assume-yes > /dev/null
apt-get upgrade --assume-yes > /dev/null
apt-get dist-upgrade --assume-yes > /dev/null
apt-get install curl --assume-yes > /dev/null

## Create configuration-backps directory
mkdir -p ~/configuration-backups

## Variables
IP=`curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'`
COL_RED='\033[0;31m'
COL_NON='\033[0m'

clear
echo -n '
┌────────────────────────────────────────────────────────────────────────────────────────┐
│   ________    _________ ___ ___                  .___            .__                   │
│   \_____  \  /   _____//   |   \_____ _______  __| _/____   ____ |__| ____    ____     │
│    /   |   \ \_____  \/    ~    \__  \\_  __ \/ __ |/ __ \ /    \|  |/    \  / ___\    │
│   /    |    \/        \    Y    // __ \|  | \/ /_/ \  ___/|   |  \  |   |  \/ /_/  >   │
│   \_______  /_______  /\___|_  /(____  /__|  \____ |\___  >___|  /__|___|  /\___  /    │
│           \/        \/       \/      \/           \/    \/     \/        \//_____/     │
│                                                   v1.1 (c) 2018 - 2019 by J. Diel      │
└────────────────────────────────────────────────────────────────────────────────────────┘
'
echo ""
echo "INTRODUCTION:"
echo ""
echo "This is a post operating system installation hardening script for Debian 9 and 10 servers."
echo "Before continuing the hardening of the operating system it's required to create a new user"
echo "to the the system that will be added to the sudoers group.                                     "
echo ""
echo "It is important to understand that the SSH configuration will disable password based auth"
echo "and that a public/private key should be created on your client before proceeding."


echo ""
read -p "Enter your username : " user
read -sp "Enter your password : " pass
echo ""
echo ""
egrep "^$user" /etc/passwd >/dev/null
	if [ $? -eq 0 ]; then
		echo "[Error]: The username $username already exists!"
		exit 1
	fi

useradd -s /bin/bash -m $user 
echo "$user:$pass" | chpasswd
usermod -aG sudo $user

echo -e "${COL_RED}"
echo -e '
   ┌─────────────────────────────────────────────────────────────────────────────────┐
   │      :: W A R N I N G :: W A R N I N G :: W A R N I N G :: W A R N I N G ::     │
   └─────────────────────────────────────────────────────────────────────────────────┘'
echo -ne "${COL_NON}"
echo "   Please execute the following commands on your client:"
echo ""
echo "   => ssh-keygen -t ed25519"
echo "   => ssh-copy-id -i ~/.ssh/id_ed25519.pub $user@$IP"
echo ""
read -sp "  Enter your password again to continue: " check_pass

if [ "$pass" = "$check_pass" ]; then
    echo ""
    if [ -f /home/$user/.ssh/authorized_keys ]; then
		check=`cat /home/$user/.ssh/authorized_keys | grep ed25519 | wc -l`

		if [ $check -gt "0" ]; then
			echo ""
			echo -ne "  [ Busy ] Hardening the SSH daemon and setting file permissions \r"
			mv /etc/ssh/sshd_config ~/configuration-backups
			wget -q -O /etc/ssh/sshd_config https://raw.githubusercontent.com/ITNerdbox/hardening-configurations/master/sshd_config
			chmod 640 /etc/ssh/sshd_config
			chmod 640 /etc/ssh
			/etc/init.d/ssh restart
			echo "  [ Done ]"
		fi
	fi
fi

## Dependencies and packages to harden the system
apt install ca-certificates --assume-yes > /dev/null
apt install libpam-cracklib --assume-yes > /dev/null
apt install acl --assume-yes > /dev/null
apt install unattended-upgrades apt-listchanges --assume-yes > /dev/null
apt install ufw --assume-yes > /dev/null
apt install sudo --assume-yes > /dev/null

## Additional packages
apt install whois --assume-yes > /dev/null
apt install net-tools --assume-yes > /dev/null
apt install dnsutils --assume-yes > /dev/null

## Disable Core Dumps, they might contain sensitive information from memory
echo "* soft core 0" >> /etc/security/limits.conf
echo "* hard core 0" >> /etc/security/limits.conf

## Update sysctl.conf
mv /etc/sysctl.conf ~/configuration-backups
wget -q -O /etc/sysctl.conf https://raw.githubusercontent.com/ITNerdbox/hardening-configurations/master/sysctl.conf
sysctl -p > /dev/null 2>1

## Configure Firewall to only allow TCP/22
ufw default deny
ufw allow 22
ufw enable

## Clear the history file
history -c


