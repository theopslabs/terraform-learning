variable "aws_region" {
  description = "AWS region for the state bucket"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_prefix" {
  description = "Prefix for the globally unique state bucket"
  type        = string
  default     = "tf-course-state"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,30}[a-z0-9]$", var.state_bucket_prefix))
    error_message = "state_bucket_prefix must be 3-32 lowercase letters, numbers, or hyphens."
  }
}
