#!/bin/bash
# vars.sh - WireGuard common variables

WG_INTERFACE="wg0"
WG_PORT=51820
WG_NET="10.0.0.0/24"
WG_1ST_PEER_IP="10.0.0.2/32"
WG_SERVER_IP="10.0.0.1/24"
WG_CONF_DIR="/etc/wireguard"
WG_CONF_FILE="$WG_CONF_DIR/$WG_INTERFACE.conf"
WG_DNS="1.1.1.1"
SERVER_PUBKEY_FILE="$WG_CONF_DIR/server_public.key"
SERVER_PRIVKEY_FILE="$WG_CONF_DIR/server_private.key"

# Detect primary network interface for NAT
function get_net_interface() {
    ip route get $WG_DNS | \
        awk '{for(i=1;i<=NF;i++){if($i=="dev"){print $(i+1);exit}}}')
}

function get_pub_ip(){
    curl -s ifconfig.me -4
}