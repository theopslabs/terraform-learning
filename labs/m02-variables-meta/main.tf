locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }

  parameter_prefix = "/${var.project_name}/${var.environment}"
}

resource "aws_ssm_parameter" "config" {
  for_each = var.app_config

  name  = "${local.parameter_prefix}/${each.key}"
  type  = "String"
  value = each.value
  tags  = local.common_tags
}

resource "terraform_data" "replica" {
  count = var.replica_count

  input = {
    index     = count.index
    parameter = "${local.parameter_prefix}/log_level"
  }

  depends_on = [aws_ssm_parameter.config]
}

resource "terraform_data" "summary" {
  input = {
    environment = var.environment
    parameters  = length(aws_ssm_parameter.config)
    replicas    = var.replica_count
  }
}
