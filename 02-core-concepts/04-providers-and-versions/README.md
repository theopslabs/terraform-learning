# Lesson 4: Providers and Versions

**Duration:** 60 minutes | **Level:** Beginner-Intermediate

## Table of Table of Contents

- [What are Providers?](#what-are-providers)
- [Provider Configuration](#provider-configuration)
- [Required Providers Block](#required-providers-block)
- [Version Constraints](#version-constraints)
- [Multiple Providers](#multiple-providers)
- [Provider Aliases](#provider-aliases)
- [Hands-On: Multiple Providers](#hands-on-multiple-providers)
- [Best Practices](#best-practices)
- [Summary](#summary)
- [Next Steps](#next-steps)

## What are Providers?

**Providers** are plugins that Terraform uses to interact with APIs of cloud providers, SaaS providers, and other services. They translate Terraform configuration into API calls.

Examples of providers:
- `aws` - Amazon Web Services
- `azurerm` - Microsoft Azure
- `google` - Google Cloud Platform
- `random` - Generate random values
- `local` - Manage local files
- `null` - Run provisioners or triggers

## Provider Configuration

The `provider` block configures a specific provider instance.

```hcl
provider "aws" {
  region  = "us-east-1"
  profile = "default"  # Optional: AWS CLI profile
}
```

## Required Providers Block

The `terraform` block with `required_providers` specifies which providers are needed and where to get them from.

```hcl
terraform {
  required_version = ">= 1.0, < 2.0"
  
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
```

**Components:**
- `source` - Where to download from (format: `namespace/type`, e.g., `hashicorp/aws`)
- `version` - Version constraint
- `required_version` - Terraform CLI version constraint

## Version Constraints

Version constraints prevent unexpected breaking changes when providers update.

| Operator | Meaning | Example | Explanation |
|----------|---------|---------|-------------|
| `=` | Exact version | `= 5.0.0` | Must be exactly 5.0.0 |
| `!=` | Exclude version | `!= 5.0.1` | Not 5.0.1 |
| `>`, `<`, `>=`, `<=` | Comparison | `>= 5.0` | Greater or equal to 5.0 |
| `~>` | Pessimistic constraint | `~> 5.0` | >= 5.0 and < 6.0 |
| `~>` (minor) | Pessimistic constraint | `~> 5.30` | >= 5.30 and < 5.40 |
| Multiple | Combine constraints | `>= 5.0, < 6.0` | Must satisfy both |

### Examples

```hcl
version = "~> 5.0"      # Allows 5.1, 5.99 but not 6.0
version = "~> 5.30.0"   # Allows 5.30.1, 5.30.9 but not 5.31.0
version = ">= 5.0"      # Allows any 5.x or higher
version = "= 5.30.0"    # Only 5.30.0
```

**Best Practice:** Use `~>` for providers to get bug fixes while avoiding breaking changes.

## Multiple Providers

You can use multiple providers in the same configuration. For example, AWS in different regions or different providers entirely.

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

provider "aws" {
  region = "us-west-2"
}
```

But Terraform won't know which one to use - that's where **provider aliases** come in.

## Provider Aliases

**Aliases** allow you to have multiple configurations of the same provider.

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Default provider
provider "aws" {
  region = "us-east-1"
}

# Provider alias for West Coast
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

# Use default provider
resource "aws_s3_bucket" "east_bucket" {
  bucket = "my-east-bucket-12345"
}

# Use aliased provider
resource "aws_s3_bucket" "west_bucket" {
  provider = aws.west
  bucket   = "my-west-bucket-67890"
}
```

Reference alias: `provider.<provider_name>.<alias>` or just `provider.<alias>` after definition? Actually, when using: `provider = aws.west`

## Hands-On: Multiple Providers

Let's create resources in two different AWS regions.

### Step 1: Create working directory

```bash
mkdir -p ~/terraform-learning/module2-providers-demo
cd ~/terraform-learning/module2-providers-demo
```

### Step 2: Create main.tf

```hcl
terraform {
  required_version = ">= 1.0, < 2.0"
  
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

# Default provider - us-east-1
provider "aws" {
  region = "us-east-1"
}

# Aliased provider - us-west-2
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

# Random ID for bucket names
resource "random_id" "east_suffix" {
  byte_length = 4
}

resource "random_id" "west_suffix" {
  byte_length = 4
}

# S3 bucket in us-east-1 (default provider)
resource "aws_s3_bucket" "east_bucket" {
  bucket = "terraform-demo-east-${random_id.east_suffix.hex}"
  
  tags = {
    Name   = "East Bucket"
    Region = "us-east-1"
  }
}

# S3 bucket in us-west-2 (aliased provider)
resource "aws_s3_bucket" "west_bucket" {
  provider = aws.west
  bucket   = "terraform-demo-west-${random_id.west_suffix.hex}"
  
  tags = {
    Name   = "West Bucket"
    Region = "us-west-2"
  }
}
```

### Step 3: Create outputs.tf

```hcl
output "east_bucket_name" {
  value       = aws_s3_bucket.east_bucket.bucket
  description = "Name of bucket in us-east-1"
}

output "west_bucket_name" {
  value       = aws_s_s3_bucket.west_bucket.bucket
  description = "Name of bucket in us-west-2"
}
```

> **Fix typo:** `aws_s_s3_bucket` should be `aws_s3_bucket`

### Corrected outputs.tf

```hcl
output "east_bucket_name" {
  value       = aws_s3_bucket.east_bucket.bucket
  description = "Name of bucket in us-east-1"
}

output "west_bucket_name" {
  value       = aws_s3_bucket.west_bucket.bucket
  description = "Name of bucket in us-west-2"
}
```

### Step 4: Apply

```bash
terraform init
terraform plan
terraform apply
# Type yes
```

You'll create buckets in both regions!

### Step 5: Clean up

```bash
terraform destroy
# Type yes
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

> **⚠️ Cost Warning:** S3 buckets are mostly Free Tier friendly. Always destroy!

## Best Practices

- **Always pin provider versions** - Use `required_providers` with version constraints
- **Use `~>` for providers** - Get bug fixes without breaking changes
- **Pin Terraform version** - Use `required_version` to avoid compatibility issues
- **Use aliases for multiple instances** - Clear and explicit
- **Keep provider configuration simple** - Only configure what needed
- **Check Terraform Registry** - Look up provider docs for configuration options
- **Don't use `latest` without constraints** - Always constrain versions

## Summary

- **Providers** are plugins that connect Terraform to APIs
- **required_providers** specifies provider sources and versions
- **Version constraints** prevent breaking changes
- **Provider aliases** allow multiple configurations of the same provider (e.g., different regions)
- Use `provider = aws.alias_name` to reference aliased providers

## Next Steps

Now the most important part of Module 2 - [Meta-Arguments](../05-meta-arguments/README.md)! Learn how to create multiple resources efficiently with `count` and `for_each`, manage dependencies with `depends_on`, and control resource lifecycle.
