output "db_endpoint" {
  description = "DNS endpoint of the database"
  value       = aws_db_instance.this.endpoint
}

output "db_address" {
  description = "Hostname of the database without the port"
  value       = aws_db_instance.this.address
}

output "db_port" {
  description = "Database port"
  value       = aws_db_instance.this.port
}

output "db_name" {
  description = "Initial database name"
  value       = aws_db_instance.this.db_name
}

output "master_user_secret_arn" {
  description = "ARN of the RDS-managed secret in Secrets Manager"
  value       = aws_db_instance.this.master_user_secret[0].secret_arn
  sensitive   = true
}

output "security_group_id" {
  description = "Security group attached to the database"
  value       = aws_security_group.rds.id
}
