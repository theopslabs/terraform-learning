variable "aws_region" {
  description = "AWS region for the lab"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in bucket names and tags"
  type        = string
  default     = "terraform-learning"
}
