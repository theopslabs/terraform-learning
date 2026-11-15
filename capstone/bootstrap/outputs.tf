output "state_bucket_name" {
  description = "Name of the S3 bucket that stores Terraform state"
  value       = aws_s3_bucket.state.bucket
}

output "state_bucket_region" {
  description = "Region of the state bucket"
  value       = var.aws_region
}

output "state_key_prefix" {
  description = "Prefix for state object keys"
  value       = var.state_key_prefix
}

output "backend_config" {
  description = "Values to place in environments/dev/backend.hcl"
  value = {
    bucket       = aws_s3_bucket.state.bucket
    key          = "${var.state_key_prefix}/dev/terraform.tfstate"
    region       = var.aws_region
    use_lockfile = true
    encrypt      = true
  }
}
