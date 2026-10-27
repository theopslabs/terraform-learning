# Lesson 2: Variables and Outputs

**Duration:** 90 minutes | **Level:** Beginner-Intermediate

## Table of Contents

- [Why Use Variables?](#why-use-variables)
- [Input Variables](#input-variables)
- [Variable Types](#variable-types)
- [Variable Defaults and Required Variables](#variable-defaults-and-required-variables)
- [Variable Validation](#variable-validation)
- [Passing Variables](#passing-variables)
- [tfvars Files](#tfvars-files)
- [Outputs](#outputs)
- [Sensitive Values](#sensitive-values)
- [Hands-On: Variables and Outputs](#hands-on-variables-and-outputs)
- [Best Practices](#best-practices)
- [Summary](#summary)
- [Next Steps](#next-steps)

## Why Use Variables?

Hardcoding values in your Terraform configurations makes them inflexible and hard to reuse. Variables allow you to:

- **Make configurations reusable** - Use same code for dev, staging, prod
- **Avoid repetition** - Define values once
- **Improve security** - Separate sensitive values from code
- **Enable collaboration** - Different team members can use different values
- **Follow DRY principles** - Don't Repeat Yourself

## Input Variables

Input variables are declared using the `variable` block.

### Syntax
```hcl
variable "variable_name" {
  type        = string
  description = "Description of the variable"
  default     = "default_value"  # Optional
  sensitive   = false           # Optional
  validation { ... }            # Optional
}
```

### Accessing Variables
Use `var.variable_name` to reference variables in your configuration.

```hcl
resource "aws_instance" "example" {
  instance_type = var.instance_type
  ...
}
```

## Variable Types

Terraform supports several data types:

| Type | Description | Example |
|------|-------------|---------|
| `string` | Text values | `"t2.micro"` |
| `number` | Numeric values | `2` or `1.5` |
| `bool` | Boolean true/false | `true` |
| `list(type)` | Ordered sequence of values | `["us-east-1a", "us-east-1b"]` |
| `set(type)` | Unordered collection of unique values | `["t2.micro", "t3.micro"]` |
| `map(type)` | Key-value pairs | `{"dev" = "t2.micro", "prod" = "t3.large"}` |
| `object({...})` | Complex structure with named attributes | `object({name=string, port=number})` |
| `tuple([...])` | Sequence of elements with specific types | `tuple([string, number, bool])` |
| `any` | Accepts any type (use sparingly) | - |

### Examples

```hcl
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "dev"
    Project     = "learning"
  }
}

variable "server_config" {
  type = object({
    instance_type = string
    count         = number
    monitoring    = bool
  })
  default = {
    instance_type = "t2.micro"
    count         = 1
    monitoring    = false
  }
}
```

## Variable Defaults and Required Variables

- **With default**: Variable is optional, uses default if not provided
- **Without default**: Variable is required, Terraform will prompt for it

```hcl
variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  # No default - required
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"  # Optional
}
```

## Variable Validation

You can add validation rules to ensure variables meet certain criteria:

```hcl
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
  
  validation {
    condition     = contains(["t2.micro", "t3.micro", "t2.small"], var.instance_type)
    error_message = "Instance type must be t2.micro, t3.micro, or t2.small (Free Tier compatible)."
  }
}

variable "environment" {
  type        = string
  description = "Environment name"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}
```

## Passing Variables

There are multiple ways to pass variables to Terraform:

| Method | Priority | Notes |
|--------|----------|-------|
| `-var` flag | Highest | `terraform apply -var="instance_type=t3.micro"` |
| `-var-file` flag | High | `terraform apply -var-file="dev.tfvars"` |
| `*.auto.tfvars` files | High | Automatically loaded |
| `terraform.tfvars` | Medium | Automatically loaded if named `terraform.tfvars` |
| Environment variables | Low | `TF_VAR_instance_type=t2.micro` |
| Default values | Lowest | Used if no other value provided |

**Priority order (highest to lowest):** CLI `-var` > `-var-file` > `*.auto.tfvars` > `terraform.tfvars` > env vars > defaults

## tfvars Files

`.tfvars` files are used to set variable values outside of configuration files.

### terraform.tfvars
```hcl
environment   = "dev"
instance_type = "t2.micro"
region        = "us-east-1"
tags = {
  Owner   = "John Doe"
  Project = "TerraformLearning"
}
```

### dev.tfvars
```hcl
environment   = "dev"
instance_type = "t2.micro"
```

### prod.tfvars
```hcl
environment   = "prod"
instance_type = "t3.large"
```

Use with: `terraform apply -var-file="prod.tfvars"`

> **Important:** Add `*.tfvars` to `.gitignore` if they contain sensitive data!

## Outputs

**Outputs** allow you to display useful information after `terraform apply`. They're also used to pass values between modules.

### Syntax
```hcl
output "output_name" {
  value       = <expression>
  description = "Description of output"
  sensitive   = false
}
```

### Examples

```hcl
output "instance_public_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP address of the EC2 instance"
}

output "bucket_name" {
  value       = aws_s3_bucket.example.bucket
  description = "Name of the S3 bucket"
}
```

### Viewing Outputs
```bash
# Show all outputs
terraform output

# Show specific output
terraform output instance_public_ip

# Output in JSON format
terraform output -json
```

## Sensitive Values

Mark outputs or variables as sensitive to prevent them from being displayed in logs:

```hcl
variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

output "db_connection_string" {
  value       = "postgresql://user:${var.db_password}@${aws_db_instance.example.endpoint}/db"
  description = "Database connection string"
  sensitive   = true
}
```

When marked sensitive, Terraform will show `<sensitive>` in the output instead of the actual value.

## Hands-On: Variables and Outputs

Let's create a reusable configuration for an EC2 instance.

### Step 1: Create working directory

```bash
mkdir -p ~/terraform-learning/module2-variables-demo
cd ~/terraform-learning/module2-variables-demo
```

### Step 2: Create variables.tf

```hcl
variable "aws_region" {
  type        = string
  description = "AWS region for resources"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment name"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
  
  validation {
    condition     = contains(["t2.micro", "t3.micro", "t2.small"], var.instance_type)
    error_message = "Instance type must be Free Tier compatible."
  }
}

variable "instance_name" {
  type        = string
  description = "Name tag for the instance"
  default     = "Terraform-Instance"
}

variable "allowed_cidr" {
  type        = string
  description = "CIDR block allowed to access SSH"
  default     = "0.0.0.0/0"  # WARNING: Only for learning!
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
    values = ["amzn2-ami-hvm-*-x86_taget_x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "${var.environment}-web-sg"
  description = "Allow SSH and HTTP"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_cidr]
  }
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.environment}-web-sg"
    Environment = var.environment
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  
  tags = {
    Name        = var.instance_name
    Environment = var.environment
  }
}
```

### Step 4: Create outputs.tf

```hcl
output "instance_id" {
  value       = aws_instance.web.id
  description = "ID of the EC2 instance"
}

output "instance_public_ip" {
  value       = aws_instance.web.public_ip
  description = "Public IP address of the EC2 instance"
}

output "instance_public_dns" {
  value       = aws_instance.web.public_dns
  description = "Public DNS of the EC2 instance"
}

output "security_group_id" {
  value       = aws_security_group.web_sg.id
  description = "ID of the security group"
}
```

### Step 5: Create terraform.tfvars

```hcl
environment    = "dev"
instance_type  = "t2.micro"
instance_name  = "MyLearningInstance"
aws_region     = "us-east-1"
# allowed_cidr = "YOUR_IP/32"  # More secure - uncomment and replace
```

> **Security Note:** Using `0.0.0.0/0` for SSH is insecure. For better security, use your own IP: `curl ifconfig.me` to get your IP, then use `YOUR_IP/32`.

### Step 6: Apply

```bash
terraform init
terraform plan
terraform apply
# Type yes
```

After apply, you'll see the outputs displayed!

### Step 7: Test outputs

```bash
terraform output
terraform output instance_public_ip
```

### Step 8: Clean up

```bash
terraform destroy
# Type yes
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

> **⚠️ Cost Warning:** EC2 t2.micro is Free Tier eligible. Security groups are free. Always destroy!

## Best Practices

- **Always use descriptions** - Help others understand variables and outputs
- **Use types** - Prevent errors by specifying types
- **Validate inputs** - Catch errors before applying
- **Use tfvars for environment-specific values** - Don't hardcode in main.tf
- **Mark sensitive values** - Protect secrets and passwords
- **Don't commit tfvars with secrets** - Use environment variables instead
- **Use meaningful names** - Variables should be descriptive
- **Keep outputs minimal** - Only output what you'll need
- **Separate files** - Put variables in `variables.tf`, outputs in `outputs.tf`

## Summary

- **Variables** make configurations reusable and flexible
- **Types** ensure correct data is passed
- **Validation** enforces rules on variable values
- **tfvars files** store environment-specific values
- **Outputs** display useful information after deployment
- **Sensitive** flag protects secret values from being displayed
- **Variable precedence** determines which value is used

## Next Steps

Now that you know variables and outputs, let's dive deeper into [Data Sources](../03-data-sources-deep-dive/README.md) to query existing infrastructure.
