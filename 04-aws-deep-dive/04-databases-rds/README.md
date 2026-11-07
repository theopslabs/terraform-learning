# Lesson 4: Databases - RDS

**Duration:** 90 minutes | **Level:** Intermediate-Advanced

## Table of Contents

- [RDS Overview](#rds-overview)
- [RDS vs Self-Managed Databases](#rds-vs-self-managed-databases)
- [Core RDS Concepts](#core-rds-concepts)
- [Networking and Subnet Groups](#networking-and-subnet-groups)
- [Security](#security)
- [High Availability: Single-AZ vs Multi-AZ](#high-availability-single-az-vs-multi-az)
- [Backups and Maintenance](#backups-and-maintenance)
- [Cost Considerations](#cost-considerations)
- [Hands-On: Private MySQL Database](#hands-on-private-mysql-database)
- [Best Practices](#best-practices)
- [Summary](#summary)
- [Next Steps](#next-steps)

## RDS Overview

**Amazon RDS (Relational Database Service)** is a managed service for running relational databases in AWS. You choose the engine, instance size, storage, and network placement; AWS handles provisioning, patching, backups, and failover.

RDS supports several engines:

- **MySQL**
- **PostgreSQL**
- **MariaDB**
- **Oracle**
- **Microsoft SQL Server**
- **Amazon Aurora** (MySQL- and PostgreSQL-compatible)

Terraform manages the RDS resources — the DB instance, subnet group, parameter group, and security groups — just like any other AWS resource.

## RDS vs Self-Managed Databases

| Concern | Self-managed on EC2 | Amazon RDS |
|---|---|---|
| Installation and patching | You manage | AWS manages |
| Backups | You build and test | Automated backups built in |
| High availability | You build replication/failover | Multi-AZ option |
| Monitoring | You install agents | CloudWatch metrics included |
| Scaling storage | Manual | Can grow storage automatically |
| Access | Full OS access | No OS access |
| Cost | Often lower on paper, more ops time | Higher per hour, much lower ops burden |

For most application databases, the operational savings of RDS outweigh the higher hourly price. Self-managed makes sense when you need OS-level control, custom extensions, or a database engine RDS does not support.

## Core RDS Concepts

| Concept | Purpose |
|---|---|
| **DB instance** | The actual database server (`aws_db_instance`) |
| **DB subnet group** | The set of subnets where RDS can place the instance (`aws_db_subnet_group`) |
| **Parameter group** | Engine settings such as `max_connections` (`aws_db_parameter_group`) |
| **Option group** | Engine features and add-ons (mostly for Oracle/SQL Server) |
| **Security group** | Controls network access to the database |
| **Automated backups** | Point-in-time recovery within the retention window |
| **Snapshots** | Manual or final backups you manage yourself |

## Networking and Subnet Groups

RDS does **not** let you choose a subnet directly. Instead, you create a **DB subnet group** containing subnets in at least two Availability Zones, and RDS selects subnets from that group.

Key rules:

- A DB subnet group needs subnets in **two or more AZs**.
- The subnets should be **private** in production — databases should not be reachable from the internet.
- RDS places the instance in one subnet, but Multi-AZ uses a second AZ for the standby.
- The DB security group must allow traffic from the application tier, not from `0.0.0.0/0`.

In this lesson we use the **default VPC** so you can focus on RDS without building a VPC first. In production, use the private DB subnets from the [VPC lesson](../01-networking-vpc/README.md).

> **Note:** If your AWS account has no default VPC (for example, someone deleted it), either recreate it in the VPC console or replace the two data sources in the hands-on with the private DB subnets you built in the VPC lesson.

## Security

Database security has three layers:

1. **Network** — private subnets, no public accessibility, security groups limited to the app tier.
2. **Authentication** — strong master password, rotated regularly. Never hardcode it in `.tf` files or commit it.
3. **Encryption** — storage encryption at rest (KMS) and TLS in transit.

For learning, this lesson generates a password with the `random` provider. That password is stored in Terraform state, so the state itself must be protected (see [Remote State & Backends](../../03-intermediate/05-remote-state-and-backends/README.md)). In production, prefer AWS Secrets Manager or RDS-managed credentials.

> **⚠️ Never commit** `terraform.tfstate`, `*.tfvars` containing secrets, or plan files. Treat state as sensitive data.

## High Availability: Single-AZ vs Multi-AZ

| Mode | What it does | Cost | Use case |
|---|---|---|---|
| **Single-AZ** | One instance in one AZ | Baseline | Development, learning, non-critical workloads |
| **Multi-AZ** | Synchronous standby in another AZ, automatic failover | Roughly double | Production databases |

Multi-AZ is about **availability**, not read scaling. For read scaling, use **read replicas** instead.

## Backups and Maintenance

- **Automated backups** enable point-in-time recovery. Set `backup_retention_period` to a number of days (0 disables them).
- **Backup window** is the daily time range when backups run.
- **Maintenance window** is when AWS may apply patches or minor upgrades.
- **Final snapshot** is taken when the instance is deleted — unless `skip_final_snapshot = true`.
- **Deletion protection** prevents accidental deletion of production databases.

For a learning database, disable the final snapshot and deletion protection so `terraform destroy` completes cleanly. For production, do the opposite.

## Cost Considerations

> **⚠️ Cost Warning:** RDS is **not free forever**. `db.t3.micro` with 20 GB of gp2 storage is Free Tier eligible in many accounts for the first 12 months, but Free Tier terms vary by region and account age. Multi-AZ, extra storage, backups beyond the free allowance, and data transfer all cost money.

- Creating an RDS instance takes **several minutes**; deletion also takes several minutes.
- Destroy the database as soon as you finish the exercise.
- The default VPC keeps this lesson cheap because it avoids NAT Gateway charges.
- Set an AWS Budget alert before running database labs if you are unsure about your account's Free Tier status.

## Hands-On: Private MySQL Database

We will create a small MySQL instance in the default VPC, reachable only from inside the VPC, with a generated password and encrypted storage.

### Step 1: Create working directory

```bash
mkdir -p ~/terraform-learning/module4-rds-demo
cd ~/terraform-learning/module4-rds-demo
```

### Step 2: Create main.tf

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Use the default VPC so the lesson is self-contained.
# In production, use the private DB subnets from the VPC lesson.
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "random_password" "db" {
  length           = 20
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# RDS needs subnets in at least two Availability Zones
resource "aws_db_subnet_group" "main" {
  name       = "terraform-course-db-subnets-${random_id.suffix.hex}"
  subnet_ids = data.aws_subnets.default.ids

  tags = {
    Name = "Terraform course DB subnet group"
  }
}

# Allow MySQL only from inside the VPC
resource "aws_security_group" "rds" {
  name        = "terraform-course-rds-${random_id.suffix.hex}"
  description = "Allow MySQL from inside the VPC"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "MySQL from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.default.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-course-rds-sg"
  }
}

resource "aws_db_parameter_group" "mysql" {
  name   = "terraform-course-mysql80-${random_id.suffix.hex}"
  family = "mysql8.0"

  parameter {
    name  = "max_connections"
    value = "100"
  }

  tags = {
    Name = "Terraform course MySQL 8.0 parameters"
  }
}

resource "aws_db_instance" "main" {
  identifier = "terraform-course-db-${random_id.suffix.hex}"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name  = "appdb"
  username = "adminuser"
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  parameter_group_name   = aws_db_parameter_group.mysql.name

  publicly_accessible = false
  multi_az            = false

  backup_retention_period = 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  skip_final_snapshot = true
  deletion_protection = false
  apply_immediately   = true

  tags = {
    Name        = "terraform-course-db"
    Environment = "Learning"
  }
}
```

### Step 3: Create outputs.tf

```hcl
output "db_endpoint" {
  value       = aws_db_instance.main.endpoint
  description = "Host:port endpoint of the database"
}

output "db_address" {
  value       = aws_db_instance.main.address
  description = "Hostname of the database"
}

output "db_port" {
  value       = aws_db_instance.main.port
  description = "Port the database listens on"
}

output "db_name" {
  value       = aws_db_instance.main.db_name
  description = "Name of the initial database"
}

output "db_password" {
  value       = random_password.db.result
  description = "Generated master password"
  sensitive   = true
}
```

### Step 4: Apply

```bash
terraform init
terraform plan
terraform apply
# Type yes
```

RDS takes **5–10 minutes** to create. The apply will appear to pause while the instance is provisioned.

### Step 5: Verify

```bash
terraform output
terraform output -raw db_endpoint
```

Because the database is private, you cannot connect from your laptop. To test a connection, launch an EC2 instance in the same VPC, install the MySQL client, and connect:

```bash
mysql -h <db_address> -P 3306 -u adminuser -p appdb
```

You can also inspect the instance in the AWS Console under **RDS → Databases**.

### Step 6: Clean up

```bash
terraform destroy
# Type yes
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

> **⚠️ Cost Warning:** Destroy immediately after testing. RDS charges by the hour, and deletion can take several minutes. If `destroy` fails, check for deletion protection or a final snapshot requirement.

## Best Practices

- Place databases in **private subnets** across at least two AZs
- Use a **DB subnet group** — never try to pin RDS to a single subnet
- Restrict the DB security group to the **application security group**, not the whole internet
- Never hardcode passwords; use `random_password`, Secrets Manager, or RDS-managed credentials
- Enable **storage encryption** and use KMS
- Use **Multi-AZ** and **deletion protection** for production
- Set meaningful **backup retention** and test restores
- Keep **parameter groups** in code so settings are reproducible
- Use **read replicas** for read scaling, not Multi-AZ
- Tag every resource for cost allocation and ownership
- Protect Terraform state — it may contain the database password

## Summary

- **RDS** is a managed relational database service
- **DB subnet groups** place instances across AZs
- Databases belong in **private subnets** with tightly scoped security groups
- **Parameter groups** control engine settings
- **Single-AZ** is for learning; **Multi-AZ** is for production availability
- **Automated backups** and **maintenance windows** are part of the resource configuration
- `db.t3.micro` can be Free Tier eligible, but RDS is **not free forever**
- Always run `terraform destroy` after the lab

## Next Steps

Now let's put the pieces together with load balancing and auto scaling: [Load Balancing & Auto Scaling](../05-load-balancing-autoscaling/README.md).
