output "db_instance_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.this.id
}

output "db_address" {
  description = "Hostname of the database without the port"
  value       = aws_db_instance.this.address
}

output "db_endpoint" {
  description = "Hostname and port of the database"
  value       = aws_db_instance.this.endpoint
}

output "db_port" {
  description = "Database port"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Initial database name"
  value       = aws_db_instance.this.db_name
}

output "db_subnet_group_name" {
  description = "Name of the database subnet group"
  value       = aws_db_subnet_group.this.name
}

output "master_user_secret_arn" {
  description = "ARN of the RDS-managed secret in Secrets Manager"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
  sensitive   = true
}
