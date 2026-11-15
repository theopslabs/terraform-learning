# Generated at apply time. The value is never persisted to state.
ephemeral "random_password" "db" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db" {
  name                    = var.secret_name
  description             = "Database password managed by Terraform"
  recovery_window_in_days = 0

  tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id                = aws_secretsmanager_secret.db.id
  secret_string_wo         = ephemeral.random_password.db.result
  secret_string_wo_version = 1
}

resource "aws_ssm_parameter" "db" {
  name             = var.parameter_name
  description      = "Database password managed by Terraform"
  type             = "SecureString"
  value_wo         = ephemeral.random_password.db.result
  value_wo_version = 1

  tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}
