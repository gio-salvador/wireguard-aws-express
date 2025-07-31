# wireguard-br

**wireguard-br** is a fast, automated solution for deploying and managing a WireGuard VPN server on AWS Linux (or any modern Linux).  
It handles server setup, NAT/routing, and makes adding new clients as simple as running a script—no manual editing required.

---

## Features

- **Automated server installation**: Installs WireGuard and configures networking automatically.
- **Zero manual key management**: Secure key generation for each peer, never re-uses keys.
- **Automatic client IP assignment**: Each new client gets the next available IP (10.0.0.2, 10.0.0.3, etc.).
- **One-command client addition**: No editing config files, no restarts forgotten.
- **Immediate client config output**: Paste into any WireGuard app or distribute to your users.
- **Security-first**: All secrets kept in `/etc/wireguard` with strict permissions.
- **AWS/VPS ready**: Suitable for cloud and home servers alike.
- **Full Terraform integration**: One command to launch a new secure VPC, subnet, security group, and fully configured EC2 instance running WireGuard, with scripts provisioned and ready.

---

## Deployment Options

- [Manual (any Linux)](#manual-deployment)
- [Automated via Terraform on AWS](#terraform-automated-aws-deployment)

---

## Terraform Automated AWS Deployment

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) 1.5+
- AWS credentials with permission to create VPC, EC2, Security Group, etc.
- An existing EC2 Key Pair (or create one in AWS Console)
- (Recommended) [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)

### Quick Start

#### 1. Clone the repo and prepare

   ```sh
   git clone https://github.com/YOURUSERNAME/wireguard-br.git
   cd wireguard-br/terraform
   ```

#### 2. Configure your AWS credentials

- Set up your AWS credentials as environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_REGION) or use an AWS profile.
- Optionally, edit variables.tf or use a .tfvars file.

#### 3. Initialize Terraform

`terraform init`

#### 4. Apply Terraform (replace with your EC2 Key Pair name if needed):

`terraform apply -var="key_name=YOUR_EC2_KEYPAIR_NAME"`

By default, this will:

- Create a new isolated VPC, subnet, internet gateway, and route table.
- Allow SSH only from your current public IP.
- Allow WireGuard UDP/51820 from anywhere (you can restrict this further).
- Launch an Amazon Linux 2023 t3.micro EC2 instance in that subnet.
- Copy and run the latest wireguard-br scripts via EC2 user data.
- Output the new server’s public IP for you to SSH and retrieve WireGuard configs.

#### 5. Get your WireGuard configuration

After terraform apply completes, use the provided public IP to SSH:

   ```sh
   ssh -i /path/to/YOUR_KEY.pem ec2-user@<instance_public_ip>
   sudo cat /etc/wireguard/wg0.conf
   sudo /etc/wireguard/wireguard-add-client.sh
   ```

The wireguard-add-client.sh script will output ready-to-use client configs in your SSH session.

---

## Advanced Usage

- Change VPC/subnet CIDR: Edit the relevant values in main.tf.
- Add more peers: SSH to the instance and run sudo /etc/wireguard/wireguard-add-client.sh.
- Remove a peer: Delete its [Peer] block from /etc/wireguard/wg0.conf and restart with sudo systemctl restart wg-quick@wg0.
- Automate config retrieval: Consider uploading generated configs to S3 (not enabled by default for security).

---

## Manual Deployment

You can also run the scripts directly on any modern Linux:

### 1. Clone and Prepare

   ```sh
   git clone https://github.com/YOURUSERNAME/wireguard-br.git
   cd wireguard-br/scripts
   chmod +x *.sh
   ```

### 2. (Optional) Edit Variables

Open `wireguard-vars.sh` to change network range, DNS, or the starting peer IP. Defaults:

- VPN network: 10.0.0.0/24
- First peer: 10.0.0.2/32
- DNS: 1.1.1.1

### 3. Run Initial Server Setup

`sudo ./wireguard-setup.sh`

- Installs WireGuard, enables IP forwarding, generates server keys.
- Writes /etc/wireguard/wg0.conf with NAT and routing.
- Starts the WireGuard service.
- Adds the first client (peer1, 10.0.0.2) and prints a ready-to-use config.

### 4. Add Additional Clients

For every new device or user, just run:

`sudo ./wireguard-add-client.sh`

- The script auto-detects the next available peer IP and name (peer2, 10.0.0.3, etc).
- Updates the server config and restarts the VPN service.
- Prints a full client config ready to be imported into any WireGuard app.

---

## Example Client Config

[Interface]
PrivateKey = <client-private-key>
Address = 10.0.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = <server-public-key>
Endpoint = <YOUR-SERVER-IP>:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25

---

## Security and Best Practices

- All keys/configs stored in /etc/wireguard with strict permissions (chmod 600/700).
- Scripts append new peers and restart the service safely—no manual config editing.
- NAT/routing automatically set up; no need to touch iptables.
- AWS EC2 deployment restricts SSH to your public IP automatically.
- WireGuard port (UDP 51820) is open to the world by default; restrict as needed in main.tf.
- Outbound traffic is unrestricted for VPN clients.
- Never commit real credentials or private keys to git.

---

## Troubleshooting

- WireGuard service won’t start?
- Check /etc/wireguard/wg0.conf for typos or duplicate IPs.
- Restart: sudo systemctl restart wg-quick@wg0
- Client can’t connect or no internet?
- Check AWS security group and server firewall (UDP 51820).
- On the server: sudo iptables -t nat -L
- On the client: Make sure DNS is set (see client config above).

---

## Removing Peers

- To remove a peer, delete its [Peer] block from /etc/wireguard/wg0.conf, then restart the service:

   ```sh
   sudo systemctl restart wg-quick@wg0`
   ```

---

## License

MIT License.
Contributions and pull requests are welcome!

---

## Author

Developed by Gio Salvador.
Tested on AWS EC2 (Amazon Linux 2023), Ubuntu 22.04 LTS

---

## Notes

- For production deployments, consider automating backup, multi-region, or S3 upload of generated configs.
- For high availability, adapt the Terraform to support multiple subnets and AZs.
- For automated config download, integrate with AWS SSM or S3 securely.
