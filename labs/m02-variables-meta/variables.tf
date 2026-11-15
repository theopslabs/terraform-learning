variable "aws_region" {
  description = "AWS region for the lab"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in parameter paths and tags"
  type        = string
  default     = "terraform-learning"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name must contain only lowercase letters, numbers, and hyphens."
  }
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

variable "app_config" {
  description = "Application configuration written to SSM Parameter Store"
  type        = map(string)
  default = {
    log_level    = "info"
    feature_flag = "false"
    page_size    = "25"
  }
}

variable "replica_count" {
  description = "Number of logical replicas to create"
  type        = number
  default     = 2

  validation {
    condition     = var.replica_count >= 1 && var.replica_count <= 3
    error_message = "replica_count must be between 1 and 3."
  }
}
