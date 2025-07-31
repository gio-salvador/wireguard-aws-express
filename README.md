# WireGuard-BR

**WireGuard-BR** is an automated Terraform solution for rapidly deploying a secure, scalable, and easily manageable WireGuard VPN server on AWS. Designed to simplify the complexity of VPN setup, WireGuard-BR is ideal for secure remote connectivity, protecting data privacy, and bypassing geographic restrictions.

---

## VPN Region Selection

The geographic location of your VPN server is directly determined by the AWS region (`AWS_REGION` environment variable) you set during deployment. For example:

- To deploy a VPN server in the **USA**, set `$AWS_REGION` to an AWS region such as `us-east-1` (N. Virginia), `us-west-1` (N. California), or `us-west-2` (Oregon).
- To deploy in **Europe**, select regions such as `eu-west-2` (London), `eu-central-1` (Frankfurt), etc.

Selecting the appropriate AWS region allows you to tailor your VPN's geographic location to your specific needs, ensuring optimal latency, performance, and compliance with regional restrictions.

---

## Why This Project is Important

In today's remote-first, cloud-centric environment, secure and reliable connectivity is essential. WireGuard-BR addresses this need by providing:

- **Fast and automated VPN deployment** using Infrastructure as Code (IaC) principles.
- **Enhanced security** with best-practice defaults, secure key management, and network hardening.
- **Easy scalability and maintainability**, allowing seamless addition of clients and secure remote management.
- **Cost-effective VPN infrastructure** leveraging AWS Free Tier-compatible resources.

---

## Key Features

- **Fully Automated Infrastructure Deployment** via Terraform.
- **Ephemeral and Secure Infrastructure** — easily destroy the entire VPN setup with a single `terraform destroy` command, ensuring resources exist only when needed, reducing costs and enhancing security.
- **Automatic WireGuard Installation and Configuration** on Amazon Linux EC2 (cheapest and free tier elegible).
- **Secure Key Management**, private keys are generated and securely stored with restricted permissions.
- **Simplified Client Management** with one-command script for adding peers/clients, automatically assigning IP addresses.
- **Immediate Peer Configuration Output**, ready for use in WireGuard client apps.
- **NAT and Routing Configuration**, ensuring VPN traffic securely routes through AWS infrastructure.
- **Security Hardened by Default**, with firewall rules limited to essential ports.

---

## Technical Stack

- **Infrastructure as Code (IaC):** Terraform
- **Cloud Provider:** AWS
- **VPN Software:** WireGuard
- **Server OS:** Amazon Linux 2023
- **Networking:** VPC, Subnet, NAT (Masquerade), Security Groups

---

## Prerequisites

- AWS Account with necessary permissions
- AWS CLI configured locally
- Terraform installed locally

---

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/wireguard-br.git
cd wireguard-br/terraform
```

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Review/Adjust Terraform Variables (variables.tf)

Defaults are provided, but you may customize:

- AWS region
- EC2 instance type
- SSH key pair name
- AMI ID (Amazon Linux 2023 default)

### 4. Deploy Infrastructure

```bash
terraform apply
```

Terraform outputs the WireGuard server public IP upon completion.

### 5. Connect to Your VPN Server via SSH

```bash
ssh -i /path/to/your/key.pem ec2-user@<server-public-ip>
```

---

## Managing WireGuard Peers

### Add a New Client/Peer

SSH into your server and run:

`sudo /etc/wireguard/scripts/wireguard-add-client.sh`

Client configuration files will be generated in /home/ec2-user.

---

### Downloading Client Configuration File

After generating a new peer/client, you can easily download the configuration file (peer1.conf) using SCP:

```bash
scp -i /path/to/your/key.pem ec2-user@<server-public-ip>:/home/ec2-user/peer1.conf .
```

Replace /path/to/your/key.pem and <server-public-ip> with your key file path and server IP address respectively.

---

### Remove an Existing Client/Peer

To remove a peer, simply edit the WireGuard server configuration file:

1. Connect to your VPN server via SSH:

2. Edit the WireGuard configuration file `/etc/wireguard/wg0.conf` and locate and remove the peer configuration lines corresponding to the client you wish to remove. The peer block typically looks like this:

   ```txt
   [Peer]
   PublicKey = <peer-public-key>
   AllowedIPs = 10.0.0.x/32
   ```

3. Restart WireGuard service to apply changes:

   ```bash
   sudo systemctl restart wg-quick@wg0
   ```

The peer is now removed from your VPN.

---

## Security Considerations

- Ensure your SSH key is stored securely.
- Regularly apply server security updates (sudo dnf update -y).
- Monitor AWS security groups and restrict access as tightly as possible.
- Rotate WireGuard keys periodically for enhanced security.

---

## Project Structure

wireguard-br/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   └── scripts/
│       ├── wireguard-setup.sh
│       ├── wireguard-add-client.sh
│       └── wireguard-vars.sh
└── README.md

---

## License

This project is licensed under the MIT License. See LICENSE for more information.
