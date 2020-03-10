# Configuration Hardening
General Linux hardening and auditing configuration files that can be pulled after a fresh installation. These configuration files have been tested on Debian 9 (stretch) and Debian 10 (buster).

## Linux umask
The default umask will be changed to 027 (750), which prevents any user created directory to be world readable.

## Memory and Network configuration
The memory and network configuration are set in the sysctl.conf file. This memory configuration disables the OOM (Out of Memory) killer to prevent random processes being killed.

The network is configuration is set to only enable IPv4 without any routing options, thus assuming the machine is not a router.

## SSH Configuration
The SSH configuration file uses only strong key exchange algorithms, cipers and MACs and has direct root access disabled. Additionally, for strong security only key based access and/or two factor authentication should be configured.

## Firewall
Uncomplicated firewall is configured default to block incoming traffic by default with the exception of SSH (TCP/22) and allowing outgoing connections.

## Passwords
Passwords are stored using the SHA512 hashing algorithm. The default number of SHA rounds used by the encryption algorithm is set between 5000000 (min) and 9000000 (max).

The PAM cracklib module is installed by default but for now requires manual editing of the /etc/pam.d/common-password file.


# Future Releases
## 03/10/2020
In the upcoming weeks / months updates will be released. Future improvements are:

- Automatically configure the PAM cracklib module in /etc/pam.d/common-password
- Uninstall specific software that can be used in common attacks such as Netcat (which for some reason is installed by default)


For suggestions, comments or requests feel free to contact me.
