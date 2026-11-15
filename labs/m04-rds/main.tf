data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

locals {
  common_tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
    Lab       = "m04-rds"
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.project_name}-db-subnets"
  subnet_ids = data.aws_subnets.default.ids

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-db-subnets"
  })
}

resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds"
  description = "MySQL access from inside the VPC only"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "MySQL from the VPC CIDR"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-rds"
  })
}

resource "aws_db_instance" "this" {
  identifier = "${var.project_name}-db"

  engine         = "mysql"
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage     = 20
  max_allocated_storage = 50
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.username

  # RDS creates and rotates the master password in Secrets Manager. The
  # password never appears in Terraform state or plan output.
  manage_master_user_password = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  multi_az               = false

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false
  apply_immediately       = true

  performance_insights_enabled = false
  monitoring_interval          = 0

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-db"
  })
}
