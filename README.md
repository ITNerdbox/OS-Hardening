# Configuration Hardening
General Linux hardening and auditing configuration files that can be pulled after a fresh installation. These configuration files have been tested on Debian 9 (stretch) and Debian 10 (buster).

## Memory and Network configuration
The memory and network configuration are set in the sysctl.conf file. This memory configuration disables the OOM (Out of Memory) killer to prevent random processes being killed.

The network is configuration is set to only enable IPv4 without any routing options, thus assuming the machine is not a router.

## SSH Configuration
The SSH configuration file uses only strong key exchange algorithms, cipers and MACs and has direct root access disabled. Additionally, for strong security only key based access and/or two factor authentication should be configured.
