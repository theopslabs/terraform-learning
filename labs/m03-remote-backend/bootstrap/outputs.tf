output "state_bucket_name" {
  description = "Name of the S3 bucket that stores Terraform state"
  value       = aws_s3_bucket.state.bucket
}

output "state_bucket_region" {
  description = "Region of the state bucket"
  value       = var.aws_region
}

output "backend_config_example" {
  description = "Values to use in app/backend.hcl"
  value = {
    bucket       = aws_s3_bucket.state.bucket
    region       = var.aws_region
    use_lockfile = true
    encrypt      = true
  }
}
