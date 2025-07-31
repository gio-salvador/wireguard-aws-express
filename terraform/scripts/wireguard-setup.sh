#!/bin/bash

# USE AWS LINUX

set -e
source "$(dirname "$0")/wireguard-vars.sh"
EXT_IF=$(get_net_interface)

# Install WireGuard
sudo dnf install -y wireguard-tools iproute iptables nmap-ncat

# Enable IP forwarding
sudo sh -c "echo 'net.ipv4.ip_forward=1' > /etc/sysctl.d/99-wireguard-ipforward.conf"
sudo sysctl -p /etc/sysctl.d/99-wireguard-ipforward.conf


# Prepare config dir and permissions
sudo mkdir -p $WG_CONF_DIR
sudo chmod 700 $WG_CONF_DIR
cd $WG_CONF_DIR

# Generate server keys if missing
umask 077
[ -f $SERVER_PRIVKEY_FILE ] || wg genkey | tee $SERVER_PRIVKEY_FILE | wg pubkey > $SERVER_PUBKEY_FILE

SERVER_PRIVKEY=$(cat $SERVER_PRIVKEY_FILE)
SERVER_PUBKEY=$(cat $SERVER_PUBKEY_FILE)

# Write initial server config with one example peer (will be replaced below)
sudo tee $WG_CONF_FILE > /dev/null <<EOF
[Interface]
Address = $WG_SERVER_IP
ListenPort = $WG_PORT
PrivateKey = $SERVER_PRIVKEY
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -s $WG_NET -o $EXT_IF -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -s $WG_NET -o $EXT_IF -j MASQUERADE
EOF

sudo chmod 600 $WG_CONF_FILE

# Start/enable WireGuard service
sudo systemctl enable wg-quick@$WG_INTERFACE
sudo systemctl restart wg-quick@$WG_INTERFACE

# Set up NAT (MASQUERADE) for WireGuard subnet
sudo iptables -C POSTROUTING -t nat -s $WG_NET -o $EXT_IF -j MASQUERADE 2>/dev/null || \
sudo iptables -A POSTROUTING -t nat -s $WG_NET -o $EXT_IF -j MASQUERADE

# Add initial peer (peer0)
"$PWD/wireguard-add-peer.sh" peer0 10.0.0.2

echo
echo "Setup complete. To add more peers, run:"
echo "sudo $PWD/wireguard-add-client.sh"
echo