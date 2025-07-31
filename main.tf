data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # Amazon official

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  my_public_ip = trim(data.http.my_ip.response_body, "\n")
  ssh_cidr     = "${local.my_public_ip}/32"
}

data "local_file" "wireguard_setup" {
  filename = "${path.module}/scripts/wireguard-setup.sh"
}

data "local_file" "wireguard_add_client" {
  filename = "${path.module}/scripts/wireguard-add-client.sh"
}

data "local_file" "wireguard_vars" {
  filename = "${path.module}/scripts/wireguard-vars.sh"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name = "${var.instance_name}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.instance_name}-igw"
  }
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.20.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.instance_name}-subnet"
  }
}

resource "aws_route_table" "main" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.instance_name}-rt"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "instance" {
  name        = "${var.instance_name}-sg"
  description = "Allow SSH and WireGuard inbound"
  vpc_id = aws_vpc.main.id
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [local.ssh_cidr]
  }

  ingress {
    description      = "WireGuard UDP"
    from_port        = 51820
    to_port          = 51820
    protocol         = "udp"
    cidr_blocks      = ["0.0.0.0/0"] # You can restrict this further as needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.instance_name}-sg"
  }
}

resource "aws_instance" "main" {
  ami                    = var.instance_ami != "" ? var.instance_ami : data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name               = var.key_name

  tags = {
    Name = var.instance_name
  }

  root_block_device {
    encrypted = true
  }

  user_data = <<-EOF
    #!/bin/bash
    set -e

    mkdir -p /etc/wireguard/scripts

    cat > /etc/wireguard/scripts/wireguard-setup.sh <<'SETUP_SCRIPT'
    ${data.local_file.wireguard_setup.content}
    SETUP_SCRIPT

    cat > /etc/wireguard/scripts/wireguard-add-client.sh <<'ADDCLIENT_SCRIPT'
    ${data.local_file.wireguard_add_client.content}
    ADDCLIENT_SCRIPT

    cat > /etc/wireguard/scripts/wireguard-vars.sh <<'VARS_SCRIPT'
    ${data.local_file.wireguard_vars.content}
    VARS_SCRIPT

    chmod +x /etc/wireguard/scripts/*.sh

    # Run setup as root (will install and configure WireGuard)
    /etc/wireguard/scripts/wireguard-setup.sh

    # You can add more logic here if you want to auto-add clients, send configs, etc.
  EOF
}