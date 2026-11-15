output "bucket_name" {
  description = "Globally unique bucket name"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_region" {
  description = "Region where the bucket lives"
  value       = aws_s3_bucket.this.bucket_region
}

output "environment" {
  description = "Environment tag applied to the bucket"
  value       = var.environment
}
