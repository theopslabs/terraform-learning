variable "aws_region" {
  description = "AWS region for the lab"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in tags"
  type        = string
  default     = "terraform-learning"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "bucket_prefix" {
  description = "Prefix for the globally unique S3 bucket name"
  type        = string
  default     = "tf-course-first-resource"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,30}[a-z0-9]$", var.bucket_prefix))
    error_message = "bucket_prefix must be 3-32 lowercase letters, numbers, or hyphens, and cannot start or end with a hyphen."
  }
}
