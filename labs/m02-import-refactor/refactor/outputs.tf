output "current_id" {
  description = "ID of the moved resource"
  value       = terraform_data.current.id
}

output "kept_output" {
  description = "Value stored by the untouched resource"
  value       = terraform_data.kept.output
}
