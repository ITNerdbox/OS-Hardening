# About
This is a post operating system installation hardening script for Debian like distributions. It has been tested on Debian 10 (buster) in a virtual environment.

## Hardened Items

File System and Permission Configuration
- [x] Default umask is changed to 027 (750), which prevents any user created directory to be world readable.
- [x] Set proper permissions in /home
- [x] Set noexec bit on /tmp partition

Memory Configuration
- [x] Enable memory randomization
- [x] Disable creating hardlinks and symbolic links for unauthorized users
- [x] Disable OOM (Out of Memory) killer to prevent random processes being killed.

Network Configuration
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

Authentication
- [x] Disable root login from the console
- [x] Disable root login from SSH
- [x] Disable password based authentication for SSH

Passwords
- [x] Storing passwords using the SHA512 hashing algorithm
- [x] Default number of SHA rounds is set between (min) 5000000 and (max) 9000000
- [x] Install and enable PAM cracklib
- [ ] Configure PAM cracklib with user defined settings
- [ ] Enforce a password policy: Password change frequency for shared systems

SSH Configuration
- [x] Enforce strong Key Exchange Algorithms (KEX)
- [x] Enforce strong ciphers
- [x] Enforce strong Message Authentication Codes (MACs)
- [x] Only allow users that are part of the group sshlogin
- [x] Only allow ed25519 SSH keys (RSA is no longer accepted)

Hardware
- [x] Disable USB
- [x] Disable Firewire
- [x] Enable Spectre like attack protection


## Bug Fixes
DEC-04-2020: If a username was already present on the system during the creation of the SSH keys, the script would stop.
OCT-03-2020: Script hung after enabling the firewall.

## Contact
If you have suggestions, comments, requests or found a bug, feel free to contact me.
