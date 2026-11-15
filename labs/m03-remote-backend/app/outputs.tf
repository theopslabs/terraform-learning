output "demo_bucket_name" {
  description = "Bucket managed with remote state"
  value       = aws_s3_bucket.demo.bucket
}
