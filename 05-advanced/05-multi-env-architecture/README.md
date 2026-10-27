# Lesson 5: Multi-Environment Architecture

**Duration:** 90 minutes | **Level:** Advanced

## Table of Contents

- [Why Multi-Environment?](#why-multi-environment)
- [Common Patterns](#common-patterns)
- [Directory Structure Patterns](#directory-structure-patterns)
- [Workspaces vs Directories](#workspaces-vs-directories)
- [Terragrunt Introduction](#terragrunt-introduction)
- [Best Practices](#best-practices)
- [Hands-On: Multi-Env Structure](#hands-on-multi-env-structure)
- [Summary](#summary)
- [Course Completion](#course-completion)
- [Next Steps](#next-steps)

## Why Multi-Environment?

- **Isolation** - Separate dev, staging, production
- **Safety** - Test changes before production
- **Cost Control** - Smaller resources in dev
- **Access Control** - Different permissions per environment
- **Compliance** - Meet organizational requirements

## Common Patterns

| Pattern | Description | When to Use |
|---------|-------------|-------------|
| **Workspaces** | Same code, different state per workspace | Simple environments with minor differences |
| **Separate Directories** | Different directories per environment, shared modules | Most common, flexible approach |
| **Terragrunt** | DRY wrapper for Terraform | Large-scale, complex multi-env setups |
| **Branches** | Different branches per environment | Not recommended, hard to maintain |

## Directory Structure Patterns

### Pattern 1: Environments with Shared Modules (Recommended)

```
terraform-project/
├── modules/
│   ├── vpc/
│   ├── ec2/
│   └── rds/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   │   └── ...
│   └── prod/
│       └── ...
└── README.md
```

### Pattern 2: Per-Service Structure

```
terraform-project/
├── networking/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── compute/
│   ├── dev/
│   ├── staging/
│   └── prod/
└── database/
    ├── dev/
    ├── staging/
    └── prod/
```

## Workspaces vs Directories

| Aspect | **Workspaces** | **Directories** |
|--------|----------------|-----------------|
| **Code Duplication** | None - same code | Can be avoided with modules |
| **State Isolation** | Separate state per workspace | Separate state per directory |
| **Flexibility** | Limited - same structure | Very flexible - can differ per env |
| **Safety** | Easy to accidentally apply to wrong workspace | More explicit, harder to mix up |
| **Complexity** | Simple for basic cases | Better for production |
| **Recommendation** | Learning/simple cases | **Production/teams - recommended** |

## Terragrunt Introduction

**Terragrunt** is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules. It helps keep configurations DRY.

Key features:
- DRY backend configuration
- DRY provider configuration
- Dependency management between modules
- Automatic remote state management
- Execute commands across multiple modules

**Note:** Terragrunt is advanced. This is just an introduction.

Example structure:
```
terragrunt-project/
├── terragrunt.hcl (root config)
├── dev/
│   ├── vpc/
│   │   └── terragrunt.hcl
│   └── app/
│       └── terragrunt.hcl
└── prod/
    └── ...
```

## Best Practices

- **Use separate directories** for production environments
- **Share modules** across environments
- **Use different state files** per environment (different S3 keys)
- **Use environment-specific tfvars**
- **Apply least privilege** per environment
- **Tag all resources** with environment
- **Use CI/CD with approvals** for production
- **Keep dev and prod as similar as possible**
- **Use version control** for all configurations
- **Document environment differences**

## Hands-On: Multi-Env Structure

Let's create a simple multi-environment structure.

```bash
mkdir -p ~/terraform-learning/module5-multi-env/{modules/vpc,environments/{dev,staging,prod}}
```

Create a simple VPC module:

**modules/vpc/variables.tf:**
```hcl
variable "vpc_cidr" {
  type = string
}

variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}
```

**modules/vpc/main.tf:**
```hcl
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
  }
}
```

**modules/vpc/outputs.tf:**
```hcl
output "vpc_id" {
  value = aws_vpc.main.id
}
```

Create dev environment:

**environments/dev/main.tf:**
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

module "vpc" {
  source = "../../modules/vpc"
  
  vpc_cidr     = "10.0.0.0/16"
  environment  = "dev"
  project_name = "myapp"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
```

This structure allows you to:
- Reuse the same module across environments
- Have different configurations per environment
- Maintain separate state files (configure backend per environment)
- Scale easily

## Summary

- Multi-environment architecture is essential for professional work
- **Separate directories with shared modules** is the recommended approach
- Workspaces are simpler but less flexible for complex setups
- Terragrunt helps with DRY configurations at scale
- Always isolate environments with separate state and proper access control
- Follow best practices for security and organization

## Course Completion

🎉 **Congratulations!** 🎉

You've completed the entire **Terraform Deep Dive Course: Zero to Professional**!

### What You've Learned

- **Module 1:** IaC fundamentals, Terraform basics, core workflow
- **Module 2:** State, variables, data sources, providers, meta-arguments
- **Module 3:** Modules, workspaces, functions, CLI, remote state
- **Module 4:** AWS networking, EC2, S3, RDS, ALB, Auto Scaling
- **Module 5:** Best practices, testing, CI/CD, secrets, multi-environment architecture

### Next Steps

- **Practice regularly** - Build real projects
- **Get certified** - Consider HashiCorp Terraform Associate Certification
- **Join communities** - Reddit r/Terraform, HashiCorp forums, Discord
- **Stay updated** - Follow HashiCorp blog and Terraform docs
- **Build a portfolio** - Showcase your Terraform projects on GitHub

### Final Tips

- Always destroy resources after learning
- Never commit secrets or state files
- Follow security best practices
- Keep learning and experimenting
- The more you practice, the better you'll become

**Good luck with your Terraform journey!**
