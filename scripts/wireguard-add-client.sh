#!/bin/bash
# wireguard-add-client.sh - Auto-add new peer/client with incremented IP and server config update

set -e
source "$(dirname "$0")/wireguard-vars.sh"

cd $WG_CONF_DIR

# Find last peer's IP or use WG_1ST_PEER_IP
last_ip=$(awk '/^\[Peer\]/ {peer=1} peer && /AllowedIPs/ {gsub(/.*= */, "", $0); split($0,ip,"/"); last=ip[1]; peer=0} END {if(last) print last}' "$WG_CONF_FILE")
if [[ -z "$last_ip" ]]; then
  new_ip=${WG_1ST_PEER_IP%/*}
  peer_idx=1
else
  IFS=. read -r a b c d <<< "$last_ip"
  d=$((d + 1))
  new_ip="$a.$b.$c.$d"
  peer_idx=$((d - 1))
fi

PEER_NAME="peer${peer_idx}"
PEER_IP="${new_ip}"

umask 077
wg genkey | tee ${PEER_NAME}_private.key | wg pubkey > ${PEER_NAME}_public.key
PEER_PRIVKEY=$(cat ${PEER_NAME}_private.key)
PEER_PUBKEY=$(cat ${PEER_NAME}_public.key)
SERVER_PUBKEY=$(cat $SERVER_PUBKEY_FILE)
SERVER_ENDPOINT=$(curl -s ifconfig.me -4)

# Append new peer to server config
echo
echo "Adding peer to $WG_CONF_FILE..."
sudo tee -a "$WG_CONF_FILE" > /dev/null <<EOP

# $PEER_NAME auto-generated on $(date)
[Peer]
PublicKey = $PEER_PUBKEY
AllowedIPs = ${PEER_IP}/32
EOP

# Restart WireGuard service
echo "Restarting WireGuard service..."
sudo systemctl restart wg-quick@$WG_INTERFACE

echo "Peer $PEER_NAME ($PEER_IP) added and service restarted!"
echo

# Output client config
echo """[Interface]
PrivateKey = $PEER_PRIVKEY
Address = ${PEER_IP}/32
DNS = $WG_DNS

[Peer]
PublicKey = $SERVER_PUBKEY
Endpoint = $SERVER_ENDPOINT:$WG_PORT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
""" > ${WG_PEER_CONFIG_PATH}/${PEER_NAME}.conf

sudo chown ec2-user:ec2-user ${WG_PEER_CONFIG_PATH}/${PEER_NAME}.conf
sudo chmod 640 ${WG_PEER_CONFIG_PATH}/${PEER_NAME}.conf

echo
echo "=================  WireGuard PEER CONFIG  ================="
cat ${WG_PEER_CONFIG_PATH}/${PEER_NAME}.conf
echo "==========================================================="
echo "This config file is available at: ${WG_PEER_CONFIG_PATH}/${PEER_NAME}.conf"

# Output alternative AllowedIPs
echo
echo "Alternatively use the following AllowedIPs value to exclude private IPs from being routed via the tunnel:"
echo "AllowedIPs = 1.0.0.0/8, 2.0.0.0/8, 3.0.0.0/8, 4.0.0.0/6, 8.0.0.0/7, 11.0.0.0/8, 12.0.0.0/6, 16.0.0.0/4, 32.0.0.0/3, 64.0.0.0/2, 128.0.0.0/3, 160.0.0.0/5, 168.0.0.0/6, 172.0.0.0/12, 172.32.0.0/11, 172.64.0.0/10, 172.128.0.0/9, 173.0.0.0/8, 174.0.0.0/7, 176.0.0.0/4, 192.0.0.0/9, 192.128.0.0/11, 192.160.0.0/13, 192.169.0.0/16, 192.170.0.0/15, 192.172.0.0/14, 192.176.0.0/12, 192.192.0.0/10, 193.0.0.0/8, 194.0.0.0/7, 196.0.0.0/6, 200.0.0.0/5, 208.0.0.0/4, $WG_DNS/32"
echo
echo "Script finished successfully."