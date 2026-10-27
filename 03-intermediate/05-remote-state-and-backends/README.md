# Lesson 5: Remote State & Backends

**Duration:** 90 minutes | **Level:** Intermediate

## Table of Contents

- [What is a Backend?](#what-is-a-backend)
- [Local vs Remote Backends](#local-vs-remote-backends)
- [Backend Configuration](#backend-configuration)
- [S3 Backend with DynamoDB Locking](#s3-backend-with-dynamodb-locking)
- [Partial Backend Configuration](#partial-backend-configuration)
- [State Migration](#state-migration)
- [Backend Best Practices](#backend-best-practices)
- [Hands-On: Setting Up Remote State](#hands-on-setting-up-remote-state)
- [Summary](#summary)
- [Module 3 Wrap-up](#module-3-wrap-up)
- [Next Steps](#next-steps)

## What is a Backend?

A **backend** defines where Terraform stores its state file. It also determines if operations are performed locally or remotely.

By default, Terraform uses the **local backend** (stores `terraform.tfstate` on disk).

## Local vs Remote Backends

| Feature | **Local Backend** | **Remote Backend** |
|---------|-------------------|-------------------|
| **State Location** | Local disk | Remote (S3, Azure, G3, Terraform Cloud) |
| **Collaboration** | Not possible safely | Multiple team members can work together |
| **State Locking** | No | Yes (with supported backends) |
| **Encryption** | Manual | Built-in encryption at rest/in transit |
| **Versioning** | Manual | Often automatic (S3 versioning) |
| **Backup** | Manual | Automatic with backend features |
| **Use Case** | Learning, personal projects | Teams, production environments |

## Backend Configuration

Configure backend in the `terraform` block:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "path/to/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

After changing backend configuration, run `terraform init` to migrate/reconfigure.

## S3 Backend with DynamoDB Locking

**Amazon S3** is commonly used to store Terraform state files. **DynamoDB** provides state locking to prevent concurrent modifications.

### Required Resources:
1. **S3 Bucket** - Store state file (with versioning enabled)
2. **DynamoDB Table** - Lock state (with partition key `LockID` of type String)

### DynamoDB Table Schema
- **Table name**: e.g., `terraform-state-lock`
- **Partition key**: `LockID` (String)
- **Billing mode**: Pay per request or provisioned (Free Tier eligible with minimal usage)

## Partial Backend Configuration

You can leave some backend values empty and provide them via command line or a backend config file. This is useful for different environments.

### Method 1: Backend config file
Create `backend.hcl`:
```hcl
bucket         = "my-terraform-state-bucket"
key            = "dev/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-state-lock"
encrypt        = true
```

In `main.tf`:
```hcl
terraform {
  backend "s3" {}
}
```

Initialize with:
```bash
terraform init -backend-config=backend.hcl
```

### Method 2: Command line
```bash
terraform init \
  -backend-config="bucket=my-bucket" \
  -backend-config="key=prod/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="dynamodb_table=terraform-lock"
```

## State Migration

When switching from local to remote backend, Terraform will prompt to migrate state.

```bash
# After adding backend block
terraform init
```

Terraform will ask: "Do you want to copy existing state to the new backend?" - Answer `yes`.

## Backend Best Practices

- **Enable S3 versioning** - Recover from accidental state corruption/deletion
- **Enable S3 encryption** - Encrypt state at rest
- **Enable DynamoDB locking** - Prevent concurrent operations
- **Use separate state files per environment** - Different keys for dev/staging/prod
- **Restrict S3 bucket access** - Use IAM policies with least privilege
- **Enable S3 bucket logging** - Audit access
- **Block public access** - Keep state bucket private
- **Use MFA delete** - Extra protection for critical environments
- **Don't use workspaces with complex backends** - Separate keys often clearer
- **Backup state** - S3 versioning provides this

## Hands-On: Setting Up Remote State

> **Important:** This creates real AWS resources (S3 bucket, DynamoDB table). Both are Free Tier eligible but always destroy when done!

### Step 1: Create backend infrastructure first

Create a separate configuration to create the S3 bucket and DynamoDB table for state.

```bash
mkdir -p ~/terraform-learning/module3-backend-setup
cd ~/terraform-learning/module3-backend-setup
```

Create `backend-infra.tf`:
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

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-bucket-${random_id.bucket_suffix.hex}"
  
  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Management"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" public_access_block {
  bucket = aws_s3_bucket.terraform_state.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "Management"
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state.bucket
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_lock.name
}
```

> **Fix typos:** `aws_s_s3_bucket` → `aws_s3_bucket`, `by default` → `by_default`, `public_access_block` missing `resource`, etc. Let me write it correctly.

### Corrected backend-infra.tf

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

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-bucket-${random_id.bucket_suffix.hex}"
  
  tags = {
    Name        = "Terraform State Bucket"
    Environment = "Management"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
  bucket = aws_s3_bucket.terraform_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.terraform_state.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  
  attribute {
    name = "LockID"
    type = "S"
  }
  
  tags = {
    Name        = "Terraform State Lock Table"
    Environment = "Management"
  }
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.terraform_state.bucket
  description = "S3 bucket name for Terraform state"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_lock.name
  description = "DynamoDB table name for state locking"
}
```

### Step 2: Create the backend infrastructure

```bash
terraform init
terraform plan
terraform apply
# Type yes
```

Save the bucket name from the outputs.

### Step 3: Create a configuration using remote backend

```bash
cd ~/terraform-learning/module3-backend-demo
mkdir -p ~/terraform-learning/module3-backend-demo
cd ~/terraform-learning/module3-backend-demo
```

Create `main.tf`:
```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    bucket         = "terraform-state-bucket-REPLACE_WITH_YOUR_BUCKET_NAME"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "demo" {
  bucket = "remote-state-demo-bucket-${random_id.suffix.hex}"
  
  tags = {
    Name = "Remote State Demo"
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "bucket_name" {
  value = aws_s3_bucket.demo.bucket
}
```

Replace the bucket name with the actual bucket name from step 2.

### Step 4: Initialize with remote backend

```bash
terraform init
```

If you had local state, it would ask to migrate. Since it's a new project, it will just initialize.

### Step 5: Apply

```bash
terraform apply
# Type yes
```

Now your state is stored in S3! You can verify in the AWS Console.

### Step 6: Clean up

```bash
# Destroy the demo resources
terraform destroy
# Type yes

# Clean up backend infrastructure
cd ~/terraform-learning/module3-backend-setup
terraform destroy
# Type yes

# Remove directories
rm -rf ~/terraform-learning/module3-backend-demo ~/terraform-learning/module3-backend-setup
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

> **⚠️ Cost Warning:** S3 and DynamoDB are mostly Free Tier friendly, but always destroy! DynamoDB with PAY_PER_REQUEST has minimal costs.

## Summary

- **Backends** define where Terraform stores state
- **Remote backends** enable collaboration with locking and security
- **S3 + DynamoDB** is a common AWS solution for remote state
- **Enable versioning and encryption** on S3 for state safety
- **State locking** prevents concurrent modifications
- **Partial configuration** allows flexible backend setup
- **Always migrate state carefully** when changing backends

## Module 3 Wrap-up

Congratulations! You've completed Module 3: Intermediate Concepts. You now know:

✅ Modules - creating reusable, composable infrastructure  
✅ Workspaces - managing multiple environments with same code  
✅ Functions and expressions - writing dynamic, flexible configurations  
✅ Terraform CLI deep dive - import, replace, graph, console, and more  
✅ Remote state and backends - collaborative, secure state management  

## Next Steps

Time for the AWS-specific deep dive! Move on to [Module 4: AWS-Specific Deep Dive](../../04-aws-deep-dive/README.md) where you'll build real-world AWS infrastructure including VPCs, EC2, S3, RDS, Load Balancers, and Auto Scaling Groups!
