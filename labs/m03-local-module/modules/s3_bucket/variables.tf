variable "bucket_prefix" {
  description = "Prefix for the globally unique bucket name"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,30}[a-z0-9]$", var.bucket_prefix))
    error_message = "bucket_prefix must be 3-32 lowercase letters, numbers, or hyphens."
  }
}

variable "environment" {
  description = "Environment name used in tags"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  description = "Project name used in tags"
  type        = string
}

variable "extra_tags" {
  description = "Additional tags merged into the bucket tags"
  type        = map(string)
  default     = {}
}
