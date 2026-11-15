output "bucket_name" {
  description = "Bucket managed by the pipeline"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  description = "ARN of the pipeline-managed bucket"
  value       = aws_s3_bucket.this.arn
}
