output "bucket_name" {
  description = "Imported bucket name"
  value       = aws_s3_bucket.existing.bucket
}

output "bucket_arn" {
  description = "Imported bucket ARN"
  value       = aws_s3_bucket.existing.arn
}
