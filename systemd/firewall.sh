#!/bin/bash

# Allow ssh with ufw
ufw limit proto tcp from any to 172.20.2.76 port 22 comment 'Allow SSH connections with rate limiting'

# Flush the DOCKER-USER table
iptables -t filter -F DOCKER-USER

# Allow internal docker communications
iptables -t filter -A DOCKER-USER -i br-fmr -j ACCEPT 

# Allow established connections
iptables -t filter -A DOCKER-USER -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Create a new chain for rate limiting
iptables -t filter -N DOCKER-USER-LIMIT
iptables -t filter -A DOCKER-USER-LIMIT -m limit --limit 100/minute -j LOG --log-prefix "[LIMIT BLOCK]"
iptables -t filter -A DOCKER-USER-LIMIT -j DROP

# Allow HTTP connections to the reverse proxy with rate limiting.
iptables -t filter -A DOCKER-USER -p tcp -d 172.28.0.4 --dport 80 -m conntrack --ctstate NEW -m recent --set
iptables -t filter -A DOCKER-USER -p tcp -d 172.28.0.4 --dport 80 -m conntrack --ctstate NEW -m recent --update --second 30 --hitcount 100 -j DOCKER-USER-LIMIT
iptables -t filter -A DOCKER-USER -p tcp -d 172.28.0.4 --dport 80 -j ACCEPT

# Allow HTTPS connections to the reverse proxy with rate limiting.
iptables -t filter -A DOCKER-USER -p tcp -d 172.28.0.4 --dport 443 -m conntrack --ctstate NEW -m recent --set
iptables -t filter -A DOCKER-USER -p tcp -d 172.28.0.4 --dport 443 -m conntrack --ctstate NEW -m recent --update --second 30 --hitcount 100 -j DOCKER-USER-LIMIT
iptables -t filter -A DOCKER-USER -p tcp -d 172.28.0.4 --dport 443 -j ACCEPT

# Note that Mariadb only accessible via ssh tunneling only.

# DROP everything else routed through this docker host
iptables -t filter -A DOCKER-USER -j DROP

# The default RETURN all. Never reached.
iptables -t filter -A DOCKER-USER -j RETURN
