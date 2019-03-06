#!/bin/bash
cat > /etc/hosts <<EOF
127.0.0.1       $1.deposit-solutions.local    $1
127.0.0.1       localhost

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost   ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
127.0.1.1       ubuntu-bionic   ubuntu-bionic

# NFS Servers
10.1.2.25       nfs1.deposit-solutions.local
10.1.2.26       nfs2.deposit-solutions.local

# Web Servers
10.1.2.23       web1.deposit-solutions.local
10.1.2.24       web2.deposit-solutions.local

EOF

