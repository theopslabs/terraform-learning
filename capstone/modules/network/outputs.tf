output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "availability_zones" {
  description = "Availability zones used by the subnets"
  value       = local.azs
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "alb_security_group_id" {
  description = "Security group for the load balancer"
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security group for application instances"
  value       = aws_security_group.app.id
}

output "db_security_group_id" {
  description = "Security group for the database"
  value       = aws_security_group.db.id
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway, if enabled"
  value       = var.enable_nat_gateway ? aws_eip.nat[0].public_ip : null
}
