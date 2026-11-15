variable "aws_region" {
  description = "AWS region for the lab"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in names and tags"
  type        = string
  default     = "terraform-learning"
}

variable "bucket_prefix" {
  description = "Prefix for the demo S3 bucket"
  type        = string
  default     = "tf-course-ci"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,30}[a-z0-9]$", var.bucket_prefix))
    error_message = "bucket_prefix must be 3-32 lowercase letters, numbers, or hyphens."
  }
}
