output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main.id
}

output "vpc_id" {
  description = "ID of the new VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID of the new subnet"
  value       = aws_subnet.main.id
}