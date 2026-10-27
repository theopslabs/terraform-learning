# Lesson 3: Data Sources Deep Dive

**Duration:** 60 minutes | **Level:** Beginner-Intermediate

## Table of Contents

- [What are Data Sources?](#what-are-data-sources)
- [Data Sources vs Resources](#data-sources-vs-resources)
- [When to Use Data Sources](#when-to-use-data-sources)
- [Data Source Syntax](#data-source-syntax)
- [Common AWS Data Sources](#common-aws-data-sources)
- [Filters](#filters)
- [Hands-On: Using Data Sources](#hands-on-using-data-sources)
- [Best Practices](#best-practices)
- [Summary](#summary)
- [Next Steps](#next-steps)

## What are Data Sources?

**Data sources** allow Terraform to read information about existing infrastructure or external data that is not managed by the current Terraform configuration. They're read-only and don't create or modify resources.

Think of data sources as "querying" AWS for information you need.

## Data Sources vs Resources

| Aspect | **Resource** | **Data Source** |
|--------|--------------|-----------------|
| **Purpose** | Creates, updates, or destroys infrastructure | Reads existing infrastructure |
| **State** | Managed by Terraform (tracked in state) | Read-only, not "created" by Terraform |
| **Syntax** | `resource "..." "..." {}` | `data "..." "..." {}` |
| **Example** | Create a new VPC | Look up an existing VPC |
| **Behavior** | Changes when you run apply | Queried on every plan/apply |

## When to Use Data Sources

- **Find latest AMI** - Get the most recent AMI ID without hardcoding
- **Reference existing resources** - Use VPC, subnets, or security groups created outside Terraform
- **Get account/region info** - Use `aws_caller_identity` or `aws_region`
- **Query availability zones** - Dynamically get available AZs
- **Reference shared infrastructure** - Use resources from other teams/configurations
- **Look up certificates, policies, etc.** - Find existing AWS resources

## Data Source Syntax

```hcl
data "<PROVIDER>_<TYPE>" "<NAME>" {
  <ARGUMENTS>
  
  filter {
    name   = "<FILTER_NAME>"
    values = ["<VALUE1>", "<VALUE2>"]
  }
}
```

Reference as: `data.<PROVIDER>_<TYPE>.<NAME>.<ATTRIBUTE>`

## Common AWS Data Sources

| Data Source | Purpose | Example Use Case |
|-------------|---------|------------------|
| `aws_ami` | Find AMI IDs | Get latest Amazon Linux or Ubuntu AMI |
| `aws_vpc` | Look up VPCs | Reference existing VPC |
| `aws_subnets` | Look up subnets | Find subnets in a VPC |
| `aws_availability_zones` | Get available AZs | Deploy across multiple AZs |
| `aws_caller_identity` | Get current AWS account info | Use account ID in policies |
| `aws_region` | Get current region | Make configurations region-agnostic |
| `aws_security_group` | Look up security group | Reference existing SG |
| `aws_route53_zone` | Look up DNS zones | Create DNS records |

## Filters

Many data sources use `filter` blocks to narrow down results. Filters are similar to AWS API filters.

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical's AWS account ID
  
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
```

## Hands-On: Using Data Sources

Let's create a configuration that uses multiple data sources.

### Step 1: Create working directory

```bash
mkdir -p ~/terraform-learning/module2-datasources-demo
cd ~/terraform-learning/module2-datasources-demo
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

# Get current AWS account information
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

# Get all available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Get latest Amazon Linux 2 AMI
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

# Create an EC2 instance using the data sources
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  tags = {
    Name        = "DataSource-Demo"
    Environment = "Learning"
    AccountID   = data.aws_ccaller_identity.current.account_id  # Note: typo in name
  }
}
```

> **Wait:** I made a typo in the resource tags above - `data.aws_ccaller_identity` should be `data.aws_caller_identity`. Let me fix that.

Actually, let me write it correctly:

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

# Get current AWS account information
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

# Get all available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Get latest Amazon Linux 2 AMI
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

# Create an EC2 instance using the data sources
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  tags = {
    Name        = "DataSource-Demo"
    Environment = "Learning"
  }
}
```

### Step 3: Create outputs.tf

```hcl
output "account_id" {
  value       = data.aws_caller_identity.current.account_id
  description = "AWS Account ID"
}

output "region" {
  value       = data.aws_region.current.name
  description = "AWS Region"
}

output "availability_zones" {
  value       = data.aws_availability_zones.available.names
  description = "Available Availability Zones"
}

output "ami_id" {
  value       = data.aws_ami.amazon_linux.id
  description = "Latest Amazon Linux 2 AMI ID"
}

output "instance_id" {
  value       = aws_instance.web.id
  description = "Instance ID"
}

output "instance_public_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP of instance"
}
```

### Step 4: Apply

```bash
terraform init
terraform plan
terraform apply
# Type yes
```

You'll see all the outputs showing the information from data sources!

### Step 5: Clean up

```bash
terraform destroy
# Type yes
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

> **⚠️ Cost Warning:** EC2 t2.micro is Free Tier eligible. Always destroy!

## Best Practices

- **Use data sources for existing resources** - Don't recreate what already exists
- **Use `most_recent = true` for AMIs** - Always get latest versions
- **Specify owners for AMIs** - Prevents getting wrong AMI from unknown sources
- **Use filters effectively** - Narrow down results to avoid ambiguity
- **Make configurations region-agnostic** - Use `aws_region` and `aws_caller_identity` data sources
- **Reference data sources, don't duplicate** - Let Terraform fetch dynamically

## Summary

- **Data sources** are read-only queries for existing or external information
- They don't create resources, just fetch data
- Use them to find AMIs, reference existing infrastructure, or get account/region info
- **Filters** help narrow down search results
- Data sources are referenced as `data.<type>.<name>.<attribute>`

## Next Steps

Now let's learn about [Providers and Versions](../04-providers-and-versions/README.md) - how to manage provider configurations, version constraints, and multiple providers.
