output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.db.arn
}

output "secret_name" {
  description = "Name of the Secrets Manager secret"
  value       = aws_secretsmanager_secret.db.name
}

output "parameter_name" {
  description = "Name of the SSM SecureString parameter"
  value       = aws_ssm_parameter.db.name
}

output "parameter_arn" {
  description = "ARN of the SSM SecureString parameter"
  value       = aws_ssm_parameter.db.arn
}
