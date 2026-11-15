locals {
  common_tags = merge(
    {
      Project   = var.project_name
      ManagedBy = "terraform"
      Component = "data"
    },
    var.tags,
  )

  identifier = substr(lower(replace("${var.project_name}-db", "_", "-")), 0, 63)
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnets"
  subnet_ids = var.private_subnet_ids

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-db-subnets"
  })
}

resource "aws_db_instance" "this" {
  identifier = local.identifier

  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.username

  # RDS creates and rotates the master password in Secrets Manager. The
  # password never appears in Terraform state or plan output.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.db_security_group_id]
  publicly_accessible    = false
  multi_az               = var.multi_az

  backup_retention_period = var.backup_retention_period
  skip_final_snapshot     = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : coalesce(
    var.final_snapshot_identifier,
    "${local.identifier}-final",
  )
  deletion_protection = var.deletion_protection
  apply_immediately   = var.apply_immediately

  performance_insights_enabled = false
  monitoring_interval          = 0

  tags = merge(local.common_tags, {
    Name = local.identifier
  })
}
