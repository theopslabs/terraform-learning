# Lesson 1: Terraform State

**Duration:** 60 minutes | **Level:** Beginner-Intermediate

## Table of Contents

- [What is Terraform State?](#what-is-terraform-state)
- [Why is State Important?](#why-is-state-important)
- [The terraform.tfstate File](#the-terraformtfstate-file)
- [Local vs Remote State](#local-vs-remote-state)
- [State Locking](#state-locking)
- [Terraform State Commands](#terraform-state-commands)
- [State Best Practices](#state-best-practices)
- [Hands-On: Exploring State](#hands-on-exploring-state)
- [Summary](#summary)
- [Next Steps](#next-steps)

## What is Terraform State?

**Terraform state** is a file that maps your Terraform configuration to the real-world infrastructure. It acts as a source of truth for what Terraform is managing.

When you run `terraform apply`, Terraform:
1. Reads your configuration files
2. Compares with the state file
3. Determines what changes are needed
4. Updates the state file after making changes

The default state file is called `terraform.tfstate` and is stored in your working directory.

## Why is State Important?

- **Resource Mapping** - Tracks which real resources correspond to which resources in your config
- **Performance** - Caching resource attributes so Terraform doesn't need to query everything every time
- **Dependency Resolution** - Helps Terraform understand relationships between resources
- **Metadata Storage** - Stores resource IDs, attributes, and provider configurations
- **Collaboration** - When using remote backends, state allows teams to work together safely

## The terraform.tfstate File

The state file is JSON formatted. You should **never manually edit it**.

Here's a simplified example:
```json
{
  "version": 4,
  "terraform_version": "1.9.8",
  "resources": [
    {
      "mode": "managed",
      "type": "aws_s3_bucket",
      "name": "example",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "attributes": {
            "bucket": "my-bucket-name",
            "id": "my-bucket-name"
          }
        }
      ]
    }
  ]
}
```

## Local vs Remote State

| Feature | **Local State** | **Remote State** |
|---------|-----------------|-------------------|
| **Location** | Stored on your local disk (`terraform.tfstate`) | Stored in a remote backend (S3, Azure Blob, Terraform Cloud, etc.) |
| **Collaboration** | Difficult - only one person can work at a time | Easy - multiple team members can collaborate |
| **Security** | Less secure if on shared machines | More secure with encryption, IAM, and locking |
| **Backup** | Manual backup needed | Backend often provides versioning/backups |
| **State Locking** | Not available | Available with supported backends |
| **Best For** | Learning, personal projects | Teams, production environments |

We'll cover remote backends in detail in Module 3.

## State Locking

**State locking** prevents multiple users from running Terraform commands simultaneously, which could corrupt the state file.

- **Local state**: No locking by default
- **Remote state with locking**: Supported backends like S3 (with DynamoDB) or Terraform Cloud provide locking
- When locked, other operations will fail with a lock error until the first operation completes

## Terraform State Commands

These commands are useful for inspecting and managing state. Use with caution!

| Command | Purpose |
|---------|---------|
| `terraform state list` | List all resources tracked in state |
| `terraform state show <resource>` | Show detailed attributes of a specific resource |
| `terraform state mv <source> <destination>` | Move a resource to a different address in state |
| `terraform state rm <resource>` | Remove a resource from state without destroying it |
| `terraform refresh` | Update state to match real infrastructure |
| `terraform show` | Show the entire state or a plan file |

> **Warning:** Commands like `state rm` and `state mv` can be dangerous. Always backup your state first!

## State Best Practices

- **Never edit state manually** - Let Terraform manage it
- **Don't commit state to Git** - Add `*.tfstate` and `*.tfstate.*` to `.gitignore`
- **Use remote state for teams** - Essential for collaboration and safety
- **Enable state locking** - Prevents concurrent modifications
- **Enable encryption** - Encrypt state at rest and in transit
- **Back up state** - Remote backends like S3 can version your state
- **Use workspaces carefully** - Or better, use separate state files per environment
- **Restrict access** - Use IAM policies to control who can access state

## Hands-On: Exploring State

Let's create a simple configuration and explore the state.

### Step 1: Create working directory

```bash
mkdir -p ~/terraform-learning/module2-state-demo
cd ~/terraform-learning/module2-state-demo
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

resource "aws_s3_bucket" "demo" {
  bucket = "terraform-state-demo-${random_id.bucket_suffix.hex}"
  
  tags = {
    Name        = "State Demo"
    Environment = "Learning"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

output "bucket_name" {
  value = aws_s3_bucket.demo.bucket
}
```

> **Note:** You'll need to add the `random` provider. Terraform will prompt to install it on init.

### Step 3: Initialize and apply

```bash
terraform init
terraform plan
terraform apply
# Type yes
```

### Step 4: Explore the state

```bash
# List all resources in state
terraform state list

# Show details of the bucket
terraform state show aws_s3_bucket.demo

# Show the full state
terraform show
```

### Step 5: Look at the state file

```bash
# View the raw state file (it's JSON)
cat terraform.tfstate | head -50
```

You'll see the `.terraform/` directory was created and `terraform.tfstate` exists locally.

### Step 6: Clean up

```bash
terraform destroy
# Type yes
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

> **⚠️ Cost Warning:** Always destroy resources when done!

## Summary

- **State** maps configuration to real infrastructure and is Terraform's source of truth
- **terraform.tfstate** is the default local state file (JSON format)
- **Never edit state manually** or commit it to version control
- **Remote state** enables team collaboration with locking and security features
- **State commands** let you inspect and manipulate state (use with extreme caution)
- **Always follow state best practices** especially in team environments

## Next Steps

Now that you understand state, let's learn how to make configurations reusable with [Variables and Outputs](../02-variables-and-outputs/README.md).
