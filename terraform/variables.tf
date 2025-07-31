variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "eu-west-2"
}

variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
  default     = "wireguard-br-instance"
}

variable "key_name" {
  description = "Name of the existing EC2 key pair for SSH access"
  type        = string
  default     = "M4-WG-BR"
}

variable "instance_ami" {
  description = "AMI ID to use (Amazon Linux 2023, Ubuntu, etc)"
  type        = string
  default     = "ami-0fc69bc38c74bcded"
}