output "dev_bucket_name" {
  description = "Bucket created for the dev environment"
  value       = module.dev_bucket.bucket_name
}

output "staging_bucket_name" {
  description = "Bucket created for the staging environment"
  value       = module.staging_bucket.bucket_name
}

output "bucket_arns" {
  description = "ARNs of all module-created buckets"
  value = {
    dev     = module.dev_bucket.bucket_arn
    staging = module.staging_bucket.bucket_arn
  }
}
