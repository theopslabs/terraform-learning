# Lesson 4: Terraform Basics

**Duration:** 90 minutes | **Level:** Beginner

## Table of Contents

- [Introduction to HCL](#introduction-to-hcl)
- [Terraform Configuration Files](#terraform-configuration-files)
- [Providers](#providers)
- [Resources](#resources)
- [Data Sources](#data-sources)
- [Comments in Terraform](#comments-in-terraform)
- [Your First Terraform Configuration](#your-first-terraform-configuration)
- [Understanding the Code](#understanding-the-code)
- [Summary](#summary)
- [Next Steps](#next-steps)

## Introduction to HCL

**HashiCorp Configuration Language (HCL)** is a domain-specific language designed to be both human-readable and machine-friendly. It's used by Terraform to describe infrastructure.

HCL characteristics:
- **Simple syntax** - Looks like JSON but more readable
- **Declarative** - Focus on what you want, not how
- **Extensible** - Supports variables, functions, loops, conditionals
- **Type-safe** - Has string, number, bool, list, map types

## Terraform Configuration Files

Terraform reads all files ending in `.tf` in the current directory. Common file names:

| File | Purpose | Notes |
|------|---------|-------|
| `main.tf` | Primary configuration | Most resources go here |
| `variables.tf` | Input variables | Good practice for organization |
| `outputs.tf` | Output values | Good practice for organization |
| `terraform.tf` | Terraform settings, provider versions | Recommended for version pinning |
| `versions.tf` | Provider and Terraform version constraints | Alternative naming |
| `providers.tf` | Provider configurations | Good practice for organization |

You can split files however you want - Terraform merges them all.

## Providers

A **provider** is a plugin that allows Terraform to interact with cloud platforms, SaaS providers, and other APIs. Each provider adds a set of resource and data source types.

### Provider Configuration Syntax

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
```

**Breaking it down:**
- `terraform {}` block - Configures Terraform itself and required providers
- `required_providers` - Specifies which providers and versions to use
- `source` - Where to download the provider from (Terraform Registry)
- `version` - Version constraint (we'll learn more about this)
- `provider "aws" {}` - Configures the AWS provider (like region)

## Resources

A **resource** is the most important building block in Terraform. It describes one or more infrastructure objects, such as a virtual network, compute instance, or DNS record.

### Resource Syntax

```hcl
resource "<PROVIDER>_<TYPE>" "<NAME>" {
  <ARGUMENT> = <VALUE>
  ...
}
```

- **PROVIDER** - The provider name (e.g., `aws`)
- **TYPE** - The resource type (e.g., `s3_bucket`, `instance`, `vpc`)
- **NAME** - A local name for this resource in your Terraform code (must be unique per module)
- **ARGUMENTS** - Configuration parameters for the resource

### Example

```hcl
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-unique-bucket-name-12345"
}
```

You can reference this resource elsewhere as `aws_s3_bucket.my_bucket`.

## Data Sources

A **data source** allows Terraform to read information defined outside of Terraform, or defined by another separate Terraform configuration.

### Data Source Syntax

```hcl
data "<PROVIDER>_<TYPE>" "<NAME>" {
  <ARGUMENT> = <VALUE>
  ...
}
```

### Example

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
```

This finds the latest Ubuntu AMI without hardcoding the AMI ID.

## Comments in Terraform

```hcl
# This is a single-line comment

// This is also a single-line comment (less common in Terraform)

# Comments are great for explaining complex configurations
```

## Your First Terraform Configuration

Let's create a simple S3 bucket. **Note:** S3 bucket names must be globally unique across all AWS accounts!

### Step 1: Create a working directory

```bash
mkdir -p ~/terraform-learning/first-project
cd ~/terraform-learning/first-project
```

### Step 2: Create main.tf

Create a file called `main.tf` with the following content:

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

resource "aws_s3_bucket" "example" {
  bucket = "my-terraform-first-bucket-12345678" # Change this to be unique!
  
  tags = {
    Name        = "My First Bucket"
    Environment = "Learning"
  }
}
```

> **Important:** Change `my-terraform-first-bucket-12345678` to something unique (add random numbers/letters). S3 bucket names must be globally unique.

### Step 3: Initialize Terraform

```bash
terraform init
```

This downloads the AWS provider plugin. You'll see output showing the provider was installed.

### Step 4: Plan the deployment

```bash
terraform plan
```

This shows what Terraform will do without actually creating anything. Look for `+ create` indicating new resources.

### Step 5: Apply the configuration

```bash
terraform apply
```

Type `yes` when prompted. Terraform will create the S3 bucket.

### Step 6: Verify in AWS Console

Go to S3 in AWS Console and you should see your bucket!

### Step 7: Destroy (cleanup)

```bash
terraform destroy
```

Type `yes` when prompted. This removes the bucket to avoid costs.

> **⚠️ Cost Warning:** S3 buckets in Free Tier have limits, but creating/destroying is usually fine. Always destroy after learning!

## Understanding the Code

Let's break down what we just did:

1. **terraform block** - Declares we need the AWS provider from HashiCorp's registry, version 5.x
2. **provider block** - Tells Terraform to use AWS in us-east-1 region
3. **resource block** - Creates an S3 bucket with a unique name and tags
4. **tags** - Key-value pairs for organizing and identifying resources (AWS best practice)

## Summary

- **HCL** is Terraform's human-readable configuration language
- **Providers** connect Terraform to APIs (like AWS)
- **Resources** define infrastructure objects you want to create
- **Data sources** read existing infrastructure information
- **Configuration files** use `.tf` extension, can be split across multiple files
- We created our first resource (S3 bucket) using init, plan, apply, destroy

## Next Steps

Now let's dive deeper into [The Core Terraform Workflow](../05-core-workflow/README.md) - understanding each command in detail and the full lifecycle.
