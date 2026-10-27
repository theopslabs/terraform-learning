# Lesson 4: Secrets Management

**Duration:** 60 minutes | **Level:** Advanced

## Table of Contents

- [Why Secrets Management?](#why-secrets-management)
- [Common Mistakes](#common-mistakes)
- [AWS Secrets Manager](#aws-secrets-manager)
- [AWS Systems Manager Parameter Store](#aws-systems-manager-parameter-store)
- [Secrets Manager vs Parameter Store](#secrets-manager-vs-parameter-store)
- [Hands-On: Using Secrets](#hands-on-using-secrets)
- [Best Practices](#best-practices)
- [Summary](#summary)
- [Next Steps](#next-steps)

## Why Secrets Management?

- **Security** - Prevent exposure of credentials
- **Compliance** - Meet regulatory requirements
- **Rotation** - Automatically rotate secrets
- **Audit Trail** - Track who accesses secrets
- **Centralization** - Manage all secrets in one place

## Common Mistakes

- ❌ Hardcoding passwords in `.tf` files
- ❌ Committing `terraform.tfvars` with secrets
- ❌ Storing secrets in state files (state is sensitive!)
- ❌ Passing secrets via CLI in plain text
- ❌ Using same password everywhere

## AWS Secrets Manager

AWS Secrets Manager helps you protect secrets needed to access applications, services, and IT resources.

```hcl
resource "aws_secretsmanager_secret" "db_password" {
  name = "db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
}

resource "aws_db_instance" "mysql" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
  # ...
}
```

## AWS Systems Manager Parameter Store

Parameter Store provides secure, hierarchical storage for configuration data and secrets.

```hcl
resource "aws_ssm_parameter" "db_password" {
  name        = "/app/db/password"
  description = "Database password"
  type        = "SecureString"
  value       = random_password.db_password.result
  key_id      = "alias/aws/ssm"  # KMS key
}

data "aws_ssm_parameter" "db_password" {
  name            = "/app/db/password"
  with_decryption = true
}

resource "aws_db_instance" "mysql" {
  password = data.aws_ssm_parameter.db_password.value
  # ...
}
```

## Secrets Manager vs Parameter Store

| Feature | **Secrets Manager** | **Parameter Store** |
|---------|---------------------|---------------------|
| **Purpose** | Secrets with rotation | Configuration + secrets |
| **Rotation** | Built-in automatic rotation | Manual or Lambda-based |
| **Cost** | $0.40/secret/month + API calls | Standard: Free, Advanced: Paid |
| **Cross-account** | Yes | Yes |
| **Integration** | RDS, Redshift, DocumentDB | Broad AWS service integration |
| **Best For** | Database credentials needing rotation | App config, less frequent rotation |

## Hands-On: Using Secrets

```bash
mkdir -p ~/terraform-learning/module5-secrets-demo
cd ~/terraform-learning/module5-secrets-demo
```

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

resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Store in Parameter Store (cheaper for learning)
resource "aws_ssm_parameter" "db_password" {
  name        = "/terraform-demo/db/password"
  description = "Database password"
  type        = "SecureString"
  value       = random_password.db_password.result
  
  tags = {
    Environment = "dev"
  }
}

# Retrieve it
data "aws_ssm_parameter" "db_password" {
  name            = "/terraform-demo/db/password"
  with_decryption = true
}

output "password_retrieved" {
  value     = data.aws_ssm_parameter.db_password.value
  sensitive = true
}
```

```bash
terraform init
terraform apply
terraform output -json
terraform destroy
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

> **⚠️ Note:** Even with Parameter Store, the value ends up in `terraform.tfstate`. Always secure your state file!

## Best Practices

- **Never hardcode secrets** in code
- **Use Secrets Manager or Parameter Store** for sensitive values
- **Mark as sensitive** in Terraform
- **Secure your state file** - Use encrypted remote backend
- **Use least privilege IAM** for accessing secrets
- **Enable rotation** for database credentials
- **Use environment variables** for local development
- **Don't log secrets** - Be careful with outputs
- **Use KMS keys** for additional encryption
- **Audit access** - Use CloudTrail

## Summary

- Never hardcode secrets in Terraform code
- Use AWS Secrets Manager for secrets needing rotation
- Use SSM Parameter Store for configuration and simple secrets
- State files can contain secrets - secure them!
- Mark sensitive values appropriately
- Follow principle of least privilege

## Next Steps

Learn about [Multi-Environment Architecture](../05-multi-env-architecture/README.md).
