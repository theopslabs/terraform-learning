output "parameter_names" {
  description = "Fully qualified SSM parameter names"
  value       = [for parameter in aws_ssm_parameter.config : parameter.name]
}

output "replica_ids" {
  description = "Terraform-managed replica identifiers"
  value       = terraform_data.replica[*].id
}

output "summary" {
  description = "Values collected by the summary resource"
  value       = terraform_data.summary.output
}
