variable "project_name" {
  description = "Project and environment prefix used in names and tags"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the database subnet group"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "RDS requires subnets in at least two availability zones."
  }
}

variable "db_security_group_id" {
  description = "Security group ID that allows MySQL access from the application tier"
  type        = string
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
  description = "Master username. The password is managed by RDS in Secrets Manager."
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

variable "allocated_storage" {
  description = "Initial storage in GiB"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage for autoscaling in GiB"
  type        = number
  default     = 100
}

variable "multi_az" {
  description = "Enable a Multi-AZ standby. Costs roughly double."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Days to retain automated backups"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Block deletion of the database"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Skip the final snapshot on destroy. Set false for production."
  type        = bool
  default     = true
}

variable "final_snapshot_identifier" {
  description = "Name for the final snapshot. Defaults to <identifier>-final when skip_final_snapshot is false."
  type        = string
  default     = null
}

variable "apply_immediately" {
  description = "Apply changes immediately instead of during the maintenance window"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags applied to every resource"
  type        = map(string)
  default     = {}
}
