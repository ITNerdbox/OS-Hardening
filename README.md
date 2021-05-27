![](./internal/osh.png)
# Operating System Hardening
![](https://img.shields.io/badge/OS%20Hardening-v1.4-blue) ![](https://img.shields.io/badge/Debian-v10.9-green)


OS-Hardening is a post Debian like operating system hardening script written in Bash and should be executed after a clean installation.
## Installation & Usage

```bash
wget https://raw.githubusercontent.com/ITNerdbox/OS-Hardening/master/debian_hardening.sh
chmod +x debian_hardening.sh
./debian_hardening.sh
```
A terminal based wizzard is used to guide users through the installation and configuration process. 

## New in v1.4
|Item          |Action |Description                                                    |
|--------------|-------|---------------------------------------------------------------|
|PAM Cracklib  |Added  |PAM Cracklib is now properly configured based on in script user settings.|
|Firehol       |Added  |Firewall: Replaced ufw with Firehol as it is easier to configure multiple network zones.|
|              |Added  |Firehol configuration is automatically generated and set to only allow SSH on the main interface.|
|Backup        |Fixed  |Backup of configuration files was not handeled properly.| 

## Features

**File System and Permission Configuration**
- [x] Default umask is changed to 027 (750), which prevents any user created directories to be world readable.
- [x] Set proper permissions in /home
- [x] Set noexec bit on /tmp partition
- [x] Disable creating hardlinks and symbolic links for unauthorized users

**Memory Configuration**
- [x] Enable memory randomization
- [x] Disable OOM (Out of Memory) killer to prevent random processes being killed.

**Network Configuration**
- [x] Disable IPv6
- [x] Disable IPv4 forwarding
- [x] Disable ICMP redirects
- [x] Disable IP source route packets
- [x] Disable source routing
- [x] Disable BOOTP relay
- [x] Disable Proxy ARP
- [x] Disable specific network protocols (dccp, sctp, rds and tipc)
- [x] Ignore ICMP ECHO and TIMESTAMP requests via broadcast/multicast
- [x] Enable source address verification to prevent spoofing attacks
- [x] Enable source validation by reversed path
- [x] Enable firewall to deny any incoming traffic
- [x] Enable firewall to accept incomming connection to TCP/22 (SSH)

**Authentication**
- [x] Disable root login from the console
- [x] Disable root login from SSH
- [x] Disable password based authentication for SSH

**Passwords**
- [x] Storing passwords using the SHA512 hashing algorithm
- [x] Default number of SHA rounds is set between (min) 5000000 and (max) 9000000
- [x] Install and enable PAM cracklib
- [x] Configure PAM cracklib with user defined settings
- [ ] Enforce a password policy: Password change frequency for shared systems

**SSH Configuration**
- [x] Enforce strong Key Exchange Algorithms (KEX)
- [x] Enforce strong ciphers
- [x] Enforce strong Message Authentication Codes (MACs)
- [x] Only allow users that are part of the group sshlogin
- [x] Only allow ed25519 SSH keys (RSA is no longer accepted)

**Hardware**
- [x] Disable USB
- [x] Disable Firewire
- [x] Enable Spectre like attack protection


## Releases & Bug Fixes

|Date       |Type  |Description                                                     |
|-----------|-------|---------------------------------------------------------------|
|MAY-22-2021|Release|Released version 1.4                                           |
|DEC-04-2020|Bugfix |Script would stop when entering a username that already existed|
|OCT-03-2020|Bugfix |After enabling the firewall, the script hung                   | 

## Contact
If you have suggestions, comments, requests or found a bug, feel free to contact me.
