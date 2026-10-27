# Lesson 3: Storage - S3

**Duration:** 60 minutes | **Level:** Intermediate-Advanced

## Table of Contents

- [S3 Overview](#s3-overview)
- [S3 Bucket Configuration](#s3-bucket-configuration)
- [Versioning](#versioning)
- [Encryption](#encryption)
- [Bucket Policies](#bucket-policies)
- [Lifecycle Rules](#lifecycle-rules)
- [Static Website Hosting](#static-website-hosting)
- [Hands-On: S3 with Security](#hands-on-s3-with-security)
- [Best Practices](#best-practices)
- [Summary](#summary)
- [Next Steps](#next-steps)

## S3 Overview

**Amazon S3 (Simple Storage Service)** is object storage with industry-leading scalability, data availability, security, and performance.

## S3 Bucket Configuration

```hcl
resource "aws_s3_bucket" "example" {
  bucket = "my-unique-bucket-name-${random_id.suffix.hex}"
  
  tags = {
    Name = "MyBucket"
  }
}
```

Bucket names must be globally unique.

## Versioning

```hcl
resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id
  
  versioning_configuration {
    status = "Enabled"
  }
}
```

## Encryption

```hcl
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

## Bucket Policies

```hcl
resource "aws_s3_bucket_policy" "example" {
  bucket = aws_s3_bucket.example.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.example.arn}/*"
      }
    ]
  })
}
```

> **Warning:** Only make buckets public if absolutely necessary (e.g., static website).

## Lifecycle Rules

```hcl
resource "aws_s3_bucket_lifecycle_configuration" "example" {
  bucket = aws_s3_bucket.example.id
  
  rule {
    id     = "transition-to-ia"
    status = "Enabled"
    
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    
    expiration {
      days = 365
    }
  }
}
```

## Static Website Hosting

```hcl
resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.example.id
  
  index_document {
    suffix = "index.html"
  }
  
  error_document {
    key = "error.html"
  }
}
```

## Hands-On: S3 with Security

```bash
mkdir -p ~/terraform-learning/module4-s3-demo
cd ~/terraform-learning/module4-s3-demo
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
}

provider "aws" {
  region = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "secure_bucket" {
  bucket = "secure-bucket-${random_id.suffix.hex}"
  
  tags = {
    Name        = "Secure Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.secure_bucket.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.secure_bucket.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.secure_bucket.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.secure_bucket.id
  key          = "hello.txt"
  content      = "Hello from Terraform S3!"
  content_type = "text/plain"
}

output "bucket_name" {
  value = aws_s3_bucket.secure_bucket.bucket
}

output "object_url" {
  value = "s3://${aws_s3_bucket.secure_bucket.bucket}/${aws_s3_object.index.key}"
}
```

```bash
terraform init
terraform apply
# Check bucket in AWS Console
terraform destroy
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

## Best Practices

- Enable versioning for important data
- Always encrypt buckets
- Block public access unless necessary
- Use bucket policies with least privilege
- Enable logging for audit trails
- Use lifecycle rules to optimize costs
- Use unique bucket names

## Summary

- S3 is object storage
- Always enable encryption and versioning for production
- Block public access by default
- Use bucket policies carefully
- Lifecycle rules help manage costs

## Next Steps

Learn about [RDS Databases](../04-databases-rds/README.md).
