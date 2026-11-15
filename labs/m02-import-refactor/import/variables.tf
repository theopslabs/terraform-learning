variable "aws_region" {
  description = "AWS region for the bucket"
  type        = string
  default     = "us-east-1"
}

variable "existing_bucket_name" {
  description = "Name of the S3 bucket created outside Terraform"
  type        = string
}
