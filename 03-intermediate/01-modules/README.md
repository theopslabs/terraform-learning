# Lesson 1: Modules

**Duration:** 90 minutes | **Level:** Intermediate

## Table of Contents

- [What are Modules?](#what-are-modules)
- [Why Use Modules?](#why-use-modules)
- [Module Types](#module-types)
- [Module Structure](#module-structure)
- [Creating a Local Module](#creating-a-local-module)
- [Using a Module](#using-a-module)
- [Module Inputs and Outputs](#module-inputs-and-outputs)
- [Module Composition](#module-composition)
- [Best Practices](#best-practices)
- [Hands-On: Creating and Using Modules](#hands-on-creating-and-using-modules)
- [Summary](#summary)
- [Next Steps](#next-steps)

## What are Modules?

A **module** is a container for multiple resources that are used together. Modules allow you to create reusable, configurable, and shareable infrastructure components.

Every Terraform configuration has at least one module - the **root module**, which consists of the `.tf` files in the main working directory.

## Why Use Modules?

- **Reusability** - Write once, use many times
- **Organization** - Break large configurations into smaller, logical components
- **Encapsulation** - Hide complex implementation details
- **Consistency** - Standardize infrastructure across teams/environments
- **Maintainability** - Easier to test, update, and debug
- **Collaboration** - Share modules across teams
- **DRY Principle** - Don't Repeat Yourself

## Module Types

| Type | Description | Usage |
|------|-------------|-------|
| **Root Module** | The main configuration you're working with | Always present |
| **Child Module** | A module called from another module | Local, remote, or registry modules |
| **Local Module** | Stored in your local filesystem | `./modules/vpc` or `../modules/vpc` |
| **Remote Module** | Stored in a remote location | Git repo, Terraform Registry, S3, etc. |
| **Registry Module** | Published on Terraform Registry | `terraform-aws-modules/vpc/aws` |

## Module Structure

A well-structured module typically includes:

```
modules/
└── vpc/
    ├── main.tf       # Main resource definitions
    ├── variables.tf  # Input variables
    ├── outputs.tf    # Output values
    ├── README.md     # Documentation
    └── versions.tf   # Provider/version constraints (optional)
```

## Creating a Local Module

Let's create a simple VPC module structure to understand the concept.

### Module Files

**modules/vpc/variables.tf:**
```hcl
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "project_name" {
  type        = string
  description = "Project name"
}
```

**modules/vpc/main.tf:**
```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}
```

**modules/vpc/outputs.tf:**
```hcl
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the VPC"
}

output "vpc_cidr" {
  value       = aws_vpc.main.cidr_block
  description = "CIDR block of the VPC"
}
```

## Using a Module

Call a module using the `module` block:

```hcl
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr     = "10.0.0.0/16"
  environment  = "dev"
  project_name = "myapp"
}
```

Reference module outputs: `module.vpc.vpc_id`

## Module Inputs and Outputs

- **Inputs**: Passed via module block arguments (like function parameters)
- **Outputs**: Returned from module, accessed via `module.<name>.<output>`
- **All variables in module must be passed** unless they have defaults
- **Outputs must be explicitly defined** to be accessible

## Module Composition

Combine multiple modules to build complex infrastructure:

```hcl
module "vpc" {
  source = "./modules/vpc"
  vpc_cidr = "10.0.0.0/16"
  ...
}

module "web_server" {
  source = "./modules/ec2"
  vpc_id = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_id
  ...
}
```

## Best Practices

- **Keep modules focused** - One module per logical component (VPC, security groups, etc.)
- **Use variables for everything configurable** - Don't hardcode values
- **Always output useful values** - IDs, ARNs, endpoints
- **Version your modules** - For remote modules, use version tags
- **Document your modules** - Add README.md with usage examples
- **Use consistent naming** - Follow naming conventions
- **Don't nest modules too deeply** - Keep it simple
- **Pin module versions** - Especially for remote/registry modules

## Hands-On: Creating and Using Modules

Let's create a simple S3 bucket module and use it.

### Step 1: Create directory structure

```bash
mkdir -p ~/terraform-learning/module3-modules-demo
cd ~/terraform-learning/module3-modules-demo
mkdir -p modules/s3_bucket
```

### Step 2: Create module - modules/s3_bucket/variables.tf

```hcl
variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "enable_versioning" {
  type        = bool
  description = "Enable versioning for the bucket"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Additional tags for the bucket"
  default     = {}
}
```

### Step 3: Create module - modules/s3_bucket/main.tf

```hcl
resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name
  
  tags = merge(
    {
      Name        = var.bucket_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.tags
  )
}

resource "aws_s3_bucket_versioning" "this" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.this.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

### Step 4: Create module - modules/s3_bucket/outputs.tf

```hcl
output "bucket_id" {
  value       = aws_s3_bucket.this.id
  description = "ID of the S3 bucket"
}

output "bucket_arn" {
  value       = aws_s3_bucket.this.arn
  description = "ARN of the S3 bucket"
}

output "bucket_domain_name" {
  value       = aws_s3_bucket.this.bucket_domain_name
  description = "Bucket domain name"
}
```

### Step 5: Create root module - main.tf

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Use the S3 bucket module
module "logs_bucket" {
  source = "./modules/s3_bucket"
  
  bucket_name        = "my-logs-bucket-${random_id.suffix.hex}"
  environment        = "dev"
  enable_versioning  = true
  tags = {
    Purpose = "Logs"
  }
}

module "data_bucket" {
  source = "./modules/sops-bucket"  # Note: typo - should be s3_bucket
  bucket_name        = "my-data-bucket-${random_id.suffix.hex}"
  environment        = "dev"
  enable_versioning  = false
  tags = {
    Purpose = "Data"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
```

> **Fix typo:** `source = "./modules/s3_bucket"` not `./modules/sops-bucket`

### Corrected main.tf

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Use the S3 bucket module
module "logs_bucket" {
  source = "./modules/s3_bucket"
  
  bucket_name       = "my-logs-bucket-${random_id.suffix.hex}"
  environment       = "dev"
  enable_versioning = true
  tags = {
    Purpose = "Logs"
  }
}

module "data_bucket" {
  source = "./modules/s3_bucket"
  
  bucket_name       = "my-data-bucket-${random_id.suffix.hex}"
  environment       = "dev"
  enable_versioning = false
  tags = {
    Purpose = "Data"
  }
}
```

### Step 6: Create outputs.tf

```hcl
output "logs_bucket_arn" {
  value       = module.logs_bucket.bucket_arn
  description = "ARN of the logs bucket"
}

output "data_bucket_arn" {
  value       = module.data_bucket.bucket_arn
  description = "ARN of the data bucket"
}

output "logs_bucket_id" {
  value       = module.logs_bucket.bucket_id
  description = "ID of the logs bucket"
}
```

### Step 7: Apply

```bash
terraform init
terraform plan
terraform apply
# Type yes
```

You'll see two S3 buckets created using the same module with different configurations!

### Step 8: Clean up

```bash
terraform destroy
# Type yes
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

> **⚠️ Cost Warning:** S3 buckets are Free Tier friendly. Always destroy!

## Summary

- **Modules** are reusable containers for infrastructure components
- **Root module** is your main configuration, **child modules** are called from it
- **Local modules** are stored in your filesystem
- Modules have **inputs** (variables) and **outputs**
- Use modules to organize, reuse, and standardize infrastructure
- **Module composition** combines multiple modules to build complete architectures

## Next Steps

Now let's learn about [Workspaces](../02-workspaces/README.md) to manage multiple environments like dev, staging, and production.
