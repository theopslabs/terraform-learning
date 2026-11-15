variable "aws_region" {
  description = "AWS region for the secrets"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in tags"
  type        = string
  default     = "terraform-learning"
}

variable "secret_name" {
  description = "Name of the Secrets Manager secret"
  type        = string
  default     = "app/db/password"
}

variable "parameter_name" {
  description = "Name of the SSM SecureString parameter"
  type        = string
  default     = "/app/db/password"
}
