# Lesson 5: Meta-Arguments

**Duration:** 90 minutes | **Level:** Beginner-Intermediate

## Table of Contents

- [What are Meta-Arguments?](#what-are-meta-arguments)
- [count](#count)
- [for_each](#for_each)
- [count vs for_each](#count-vs-for_each)
- [depends_on](#depends_on)
- [lifecycle Block](#lifecycle-block)
- [Hands-On: Meta-Arguments](#hands-on-meta-arguments)
- [Best Practices](#best-practices)
- [Summary](#summary)
- [Module 2 Wrap-up](#module-2-wrap-up)
- [Next Steps](#next-steps)

## What are Meta-Arguments?

**Meta-arguments** are arguments that can be used with any resource type (or module) to change how Terraform creates and manages resources. They affect the behavior of the resource rather than configuring the resource itself.

The meta-arguments we'll cover:
- `count` - Create multiple resource instances based on a number
- `for_each` - Create multiple resource instances based on a map or set
- `depends_on` - Explicitly define dependencies between resources
- `lifecycle` - Customize resource lifecycle behavior
- `provider` - Specify which provider to use (covered in previous lesson)
- `provisioner` - Execute scripts (advanced, use with caution)

## count

`count` creates multiple instances of a resource. It's simple and works well for identical resources.

### Syntax
```hcl
resource "aws_instance" "example" {
  count         = 3
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  tags = {
    Name = "Instance-${count.index}"
  }
}
```

- `count.index` gives the index (0, 1, 2, ...)
- Each instance is a separate resource: `aws_instance.example[0]`, `aws_instance.example[1]`, `aws_instance.example[2]`

### Example with Conditional
```hcl
resource "aws_instance" "example" {
  count         = var.create_instance ? 1 : 0
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
}
```

## for_each

`for_each` creates multiple instances based on a map or a set of strings. It's more flexible than `count` because each instance can have different values.

### Syntax with Map
```hcl
variable "users" {
  type = map(object({
    role = string
    department = string
  }))
  default = {
    alice = { role = "admin", department = "IT" }
    bob   = { role = "user", department = "HR" }
  }
}

resource "aws_iam_user" "users" {
  for_each = var.users
  name     = each.key
  
  tags = {
    Role       = each.value.role
    Department = each.value.department
  }
}
```

- `each.key` - The map key or set element
- `each.value` - The map value (or the element itself for sets)

### Syntax with Set
```hcl
variable "bucket_names" {
  type    = set(string)
  default = ["dev-bucket", "staging-bucket", "prod-bucket"]
}

resource "aws_s3_bucket" "buckets" {
  for_each = var.bucket_names
  bucket   = each.value
}
```

## count vs for_each

| Feature | **count** | **for_each** |
|---------|-----------|--------------|
| **Input** | Number | Map or Set of strings |
| **Access** | `count.index` | `each.key`, `each.value` |
| **Resource Address** | List index: `[0]`, `[1]` | Map key: `["alice"]`, `["bob"]` |
| **Removing Middle Item** | Can cause recreation of all items after it (problematic!) | Only removes that specific item |
| **Use Case** | Identical resources or simple duplication | Resources with different configurations |
| **Flexibility** | Limited | More flexible and safer |

**Recommendation:** Prefer `for_each` over `count` when resources have different values or could be removed in the middle.

## depends_on

By default, Terraform automatically determines dependencies based on references. However, sometimes you need to explicitly specify dependencies when Terraform can't infer them.

### Syntax
```hcl
resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  depends_on = [aws_security_group.example, aws_s3_bucket.example]
  
  tags = {
    Name = "Example"
  }
}
```

**Use cases:**
- When a resource depends on another but there's no direct reference
- When using modules
- When creating IAM policies that need to be attached before EC2 instances
- For complex dependencies

> **Note:** Use `depends_on` sparierly. Terraform's dependency graph is usually smart enough.

## lifecycle Block

The `lifecycle` block allows you to customize how Terraform manages resources during updates.

### create_before_destroy

Creates the replacement resource before destroying the old one. This prevents downtime.

```hcl
resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  lifecycle {
    create_before_destroy = true
  }
}
```

### prevent_destroy

Prevents accidental destruction of critical resources.

```hcl
resource "aws_s3_bucket" "important" {
  bucket = "my-important-bucket"
  
  lifecycle {
    prevent_destroy = true
  }
}
```

If you try to destroy it, Terraform will throw an error. To destroy, you must first remove or set `prevent_destroy = false`.

### ignore_changes

Ignores changes to specific attributes. Useful when external systems modify resource attributes.

```hcl
resource "aws_instance" "example" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  tags = {
    Name = "Example"
  }
  
  lifecycle {
    ignore_changes = [
      tags,
      # Or ignore_changes = all
    ]
  }
}
```

### Multiple lifecycle rules

```hcl
lifecycle {
  create_before_destroy = true
  prevent_destroy       = true
  ignore_changes        = [ami]
}
```

## Hands-On: Meta-Arguments

Let's create a configuration using `count`, `for_each`, and `lifecycle`.

### Step 1: Create working directory

```bash
mkdir -p ~/terraform-learning/module2-meta-demo
cd ~/terraform-learning/module2-meta-demo
```

### Step 2: Create variables.tf

```hcl
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "environments" {
  type    = set(string)
  default = ["dev", "staging"]
}

variable "users" {
  type = map(object({
    department = string
    role       = string
  }))
  default = {
    alice = { department = "Engineering", role = "Developer" }
    bob   = { department = "Marketing", role = "Manager" }
  }
}
```

### Step 3: Create main.tf

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
  region = var.aws_region
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

# Using count - create multiple identical instances
resource "aws_instance" "count_example" {
  count         = var.instance_count
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  tags = {
    Name        = "Instance-${count.index + 1}"
    Environment = "Learning"
    Method      = "count"
  }
}

# Using for_each with set - create buckets for each environment
resource "aws_s3_bucket" "env_buckets" {
  for_each = var.environments
  bucket   = "terraform-meta-demo-${each.value}-${random_id.bucket_suffix.hex}"
  
  tags = {
    Name        = "${each.value}-bucket"
    Environment = each.value
    Method      = "for_each"
  }
}

# Using for_each with map - create IAM users
resource "aws_iam_user" "users" {
  for_each = var.users
  name     = each.key
  
  tags = {
    Department = each.value.department
    Role       = each.value.role
    Method     = "for_each"
  }
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Example with lifecycle
resource "aws_s3_bucket" "lifecycle_example" {
  bucket = "terraform-lifecycle-demo-${random_id.bucket_suffix.hex}"
  
  lifecycle {
    create_before_destroy = true
    # prevent_destroy = true  # Uncomment only if you want to prevent destruction
  }
  
  tags = {
    Name   = "Lifecycle-Demo"
    Method = "lifecycle"
  }
}
```

### Step 4: Create outputs.tf

```hcl
output "count_instance_ids" {
  value       = aws_instance.count_example[*].id
  description = "IDs of instances created with count"
}

output "count_instance_ips" {
  value       = aws_instance.count_example[*].public_ip
  description = "Public IPs of instances created with count"
}

output "env_bucket_names" {
  value       = [for bucket in aws_s3_bucket.env_buckets : bucket.bucket]
  description = "Names of buckets created with for_each"
}

output "iam_user_names" {
  value       = [for user in aws_iam_user.users : user.name]
  description = "Names of IAM users created with for_each"
}
```

### Step 5: Apply

```bash
terraform init
terraform plan
terraform apply
# Type yes
```

Notice how Terraform creates resources:
- 2 EC2 instances (count)
- 2 S3 buckets (for_each with set)
- 2 IAM users (for_each with map)

Also look at the outputs showing different reference styles.

### Step 6: Clean up

```bash
terraform destroy
# Type yes
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

> **⚠️ Cost Warning:** EC2 instances, S3 buckets, and IAM users - all Free Tier compatible in this setup. Always destroy!  
> **Note:** IAM users are free, but be careful not to create many.

## Best Practices

- **Prefer for_each over count** - Safer for resources that might change
- **Use count for identical resources** - Simple cases work fine
- **Avoid hardcoding counts** - Use variables
- **Use depends_on sparingly** - Let Terraform infer dependencies when possible
- **Use create_before_destroy** for resources where downtime matters
- **Use prevent_destroy** for critical production resources (with extreme caution)
- **Use ignore_changes** when external systems modify attributes
- **Reference resources correctly** - `[*]` for count lists, `for` expressions for for_each maps

## Summary

- **Meta-arguments** change how Terraform manages resources
- **count** creates N identical resources, indexed by `count.index`
- **for_each** creates resources from maps/sets with unique keys/values
- **depends_on** explicitly declares dependencies
- **lifecycle** customizes behavior: `create_before_destroy`, `prevent_destroy`, `ignore_changes`
- **for_each is generally safer** than count for most use cases

## Module 2 Wrap-up

Congratulations! You've completed Module 2: Core Concepts. You now know:

✅ Terraform state - what it is, why it's important, and best practices  
✅ Variables and outputs - making configurations reusable and flexible  
✅ Data sources - querying existing infrastructure  
✅ Providers and versions - managing multiple providers and version constraints  
✅ Meta-arguments - `count`, `for_each`, `depends_on`, and `lifecycle`  

## Next Steps

Ready for intermediate concepts? Move on to [Module 3: Intermediate Concepts](../../03-intermediate/README.md) where you'll learn about modules, workspaces, functions and expressions, Terraform CLI deep dive, and remote state backends!
