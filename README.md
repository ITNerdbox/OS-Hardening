# Configuration Hardening
General Linux hardening and auditing configuration files that can be pulled after a fresh installation. These configuration files have been tested on Debian 9 (stretch).

## Memory and Network configuration
The memory and network configuration are set in the sysctl.conf file. This memory configuration disables the OOM (Out of Memory) killer to prevent random processes being killed.

The network is configuration is set to only enable IPv4 without any routing options, thus assuming the machine is not a router.
