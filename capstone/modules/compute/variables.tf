variable "project_name" {
  description = "Project and environment prefix used in names and tags"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for the ALB"
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "The ALB requires at least two public subnets in different AZs."
  }
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the Auto Scaling Group"
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "The Auto Scaling Group requires at least two private subnets."
  }
}

variable "alb_security_group_id" {
  description = "Security group ID for the ALB"
  type        = string
}

variable "app_security_group_id" {
  description = "Security group ID for application instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "min_size" {
  description = "Minimum ASG size"
  type        = number
  default     = 1
}

variable "max_size" {
  description = "Maximum ASG size"
  type        = number
  default     = 3
}

variable "desired_capacity" {
  description = "Desired ASG capacity"
  type        = number
  default     = 2
}

variable "app_port" {
  description = "Port the application listens on"
  type        = number
  default     = 80
}

variable "health_check_path" {
  description = "HTTP path used by the target group health check"
  type        = string
  default     = "/"
}

variable "tags" {
  description = "Additional tags applied to every resource"
  type        = map(string)
  default     = {}
}
