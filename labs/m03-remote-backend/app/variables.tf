variable "aws_region" {
  description = "AWS region for the demo bucket"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in tags"
  type        = string
  default     = "terraform-learning"
}
