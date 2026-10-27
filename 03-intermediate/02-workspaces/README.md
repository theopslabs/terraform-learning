# Lesson 2: Workspaces

**Duration:** 60 minutes | **Level:** Intermediate

## Table of Contents

- [What are Workspaces?](#what-are-workspaces)
- [Why Use Workspaces?](#why-use-workspaces)
- [Default Workspace](#default-workspace)
- [Workspace Commands](#workspace-commands)
- [Using Workspaces in Configuration](#using-workspaces-in-configuration)
- [Workspaces vs Separate Directories](#workspaces-vs-separate-directories)
- [Best Practices](#best-practices)
- [Hands-On: Using Workspaces](#hands-on-using-workspaces)
- [Summary](#summary)
- [Next Steps](#next-steps)

## What are Workspaces?

**Workspaces** allow you to manage multiple states for the same Terraform configuration. Each workspace has its own separate `terraform.tfstate` file, enabling you to deploy the same infrastructure code to different environments.

Think of workspaces as multiple instances of your infrastructure using the same code but different state files.

## Why Use Workspaces?

- **Manage multiple environments** - dev, staging, prod with same configuration
- **Avoid code duplication** - Don't copy/paste configuration files
- **Separate state** - Each environment has isolated state
- **Cost effective** - Test in dev before deploying to prod
- **Easy switching** - Quickly switch between environments

## Default Workspace

When you initialize a Terraform project, you're automatically in the **default** workspace. You can't delete the default workspace.

## Workspace Commands

| Command | Purpose |
|---------|---------|
| `terraform workspace list` | List all workspaces (current marked with `*`) |
| `terraform workspace show` | Show current workspace name |
| `terraform workspace new <name>` | Create and switch to a new workspace |
| `terraform workspace select <name>` | Switch to an existing workspace |
| `terraform workspace delete <name>` | Delete a workspace (cannot delete current or default) |

## Using Workspaces in Configuration

You can reference the current workspace using `terraform.workspace`. This is useful for naming resources differently per environment.

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = terraform.workspace == "prod" ? "t3.large" : "t2.micro"
  
  tags = {
    Name        = "web-${terraform.workspace}"
    Environment = terraform.workspace
  }
}
```

You can also use it in bucket names, resource counts, etc.

## Workspaces vs Separate Directories

| Aspect | **Workspaces** | **Separate Directories** |
|--------|----------------|---------------------------|
| **Code Reuse** | Same code for all environments | Can use modules or copy code |
| **State Isolation** | Separate state per workspace | Separate state per directory |
| **Simplicity** | Quick and easy | More explicit and flexible |
| **Backend** | Works with same backend | Can have different backends |
| **Best For** | Similar environments with small differences | Very different environments or complex setups |
| **Scalability** | Can get confusing with many workspaces | More scalable for complex multi-env setups |

**For production:** Many teams prefer separate directories with modules over workspaces. Workspaces are great for learning and simple cases.

## Best Practices

- **Use meaningful workspace names** - dev, staging, prod
- **Don't store secrets in workspace names** - They're visible
- **Be careful with commands** - Always check which workspace you're in
- **Use with remote backends** - Especially important for teams
- **Consider directory structure for prod** - Workspaces can be risky if misused
- **Tag resources with workspace** - Use `terraform.workspace` in tags
- **Don't delete wrong workspace** - Double-check before deleting

## Hands-On: Using Workspaces

Let's create infrastructure that behaves differently per workspace.

### Step 1: Create working directory

```bash
mkdir -p ~/terraform-learning/module3-workspaces-demo
cd ~/terraform-learning/module3-workspaces-demo
```

### Step 2: Create main.tf

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

# Map instance types per workspace
locals {
  instance_type = {
    dev     = "t2.micro"
    staging = "t2.small"
    prod    = "t3.medium"
  }
  
  # Number of instances per workspace
  instance_count = {
    dev     = 1
    staging = 2
    prod    = 3
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  count         = lookup(local.instance_count, terraform.workspace, 1)
  ami           = data.aws_ami.amazon_linux.id
  instance_type = lookup(local.instance_type, terraform.workspace, "t2.micro")
  
  tags = {
    Name        = "web-${terraform.workspace}-${count.index + 1}"
    Environment = terraform.workspace
    Workspace   = terraform.workspace
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "terraform-workspace-demo-${terraform.workspace}-${random_id.suffix.hex}"
  
  tags = {
    Name        = "bucket-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
```

### Step 3: Create outputs.tf

```hcl
output "workspace_name" {
  value       = terraform.workspace
  description = "Current workspace name"
}

output "instance_ids" {
  value       = aws_instance.web[*].id
  description = "IDs of EC2 instances"
}

output "instance_type" {
  value       = lookup(local.instance_type, terraform.workspace, "t2.micro")
  description = "Instance type for current workspace"
}

output "bucket_name" {
  value       = aws_s3_bucket.bucket.bucket
  description = "S3 bucket name"
}
```

### Step 4: Initialize and work with workspaces

```bash
# Initialize
terraform init

# Check current workspace
terraform workspace show
# Should show: default

# List workspaces
terraform workspace list
# Should show: * default

# Create and switch to dev workspace
terraform workspace new dev
terraform workspace show
# Should show: dev

# Apply in dev workspace
terraform plan
terraform apply
# Type yes - will create 1 t2.micro instance
```

### Step 5: Switch to staging

```bash
# Create and switch to staging
terraform workspace new staging
terraform apply
# Type yes - will create 2 t2.small instances (different state!)
```

### Step 6: Switch to prod

```bash
# Create and switch to prod
terraform workspace new prod
terraform apply
# Type yes - will create 3 t3.medium instances
```

### Step 7: Switch between workspaces

```bash
# Switch back to dev
terraform workspace select dev
terraform show
# Shows only dev resources

# Switch to prod
terraform workspace select prod
terraform show
# Shows only prod resources
```

Notice each workspace has its own completely separate state!

### Step 8: Clean up all workspaces

```bash
# Switch to dev and destroy
terraform workspace select dev
terraform destroy
# Type yes

# Switch to staging and destroy
terraform workspace select staging
terraform destroy
# Type yes

# Switch to prod and destroy
terraform workspace select prod
terraform destroy
# Type yes

# Switch back to default
terraform workspace select default

# Delete non-default workspaces
terraform workspace delete dev
terraform workspace delete staging
terraform workspace delete prod

# Clean files
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

> **⚠️ Cost Warning:** Depending on workspace, you're creating multiple instances. Always destroy all workspaces!  
> **Note:** Cannot delete workspace you're currently in or the default workspace.

## Summary

- **Workspaces** provide separate state files for the same configuration
- Use `terraform.workspace` to customize behavior per environment
- Commands: `list`, `show`, `new`, `select`, `delete`
- **Workspaces are great for learning** but separate directories are often preferred for production
- Each workspace is completely isolated with its own state

## Next Steps

Now let's learn about [Functions and Expressions](../03-functions-and-expressions/README.md) - Terraform's powerful built-in functions and how to use them to write more dynamic configurations.
