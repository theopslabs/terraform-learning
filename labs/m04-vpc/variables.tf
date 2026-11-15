variable "aws_region" {
  description = "AWS region for the VPC"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in names and tags"
  type        = string
  default     = "terraform-learning"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "az_count" {
  description = "Number of availability zones to use"
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 1 && var.az_count <= 3
    error_message = "az_count must be between 1 and 3."
  }
}

variable "enable_nat_gateway" {
  description = "Create a NAT Gateway so private subnets can reach the internet. This costs money."
  type        = bool
  default     = false
}
