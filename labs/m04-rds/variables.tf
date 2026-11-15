variable "aws_region" {
  description = "AWS region for the database"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in names and tags"
  type        = string
  default     = "terraform-learning"
}

variable "db_name" {
  description = "Initial database name"
  type        = string
  default     = "appdb"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9]{0,62}$", var.db_name))
    error_message = "db_name must start with a letter and contain only letters and numbers."
  }
}

variable "username" {
  description = "Master username"
  type        = string
  default     = "appadmin"

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_]{0,15}$", var.username))
    error_message = "username must start with a letter and be at most 16 characters."
  }
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "engine_version" {
  description = "MySQL engine version"
  type        = string
  default     = "8.0"
}
