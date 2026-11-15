variable "aws_region" {
  description = "AWS region for the state bucket"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in the state bucket name and tags"
  type        = string
  default     = "terraform-capstone"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,30}[a-z0-9]$", var.project_name))
    error_message = "project_name must be 3-32 lowercase letters, numbers, or hyphens."
  }
}

variable "state_key_prefix" {
  description = "Prefix for state object keys"
  type        = string
  default     = "capstone"
}
