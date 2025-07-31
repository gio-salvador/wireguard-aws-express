variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
  default     = "wireguard-br-instance"
}

variable "key_name" {
  description = "Name of the existing EC2 key pair for SSH access"
  type        = string
}

variable "instance_ami" {
  description = "AMI ID to use (Amazon Linux 2023, Ubuntu, etc)"
  type        = string
}