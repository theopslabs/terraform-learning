| `reverse()` | Reverse list | `reverse(["a", "b"])` | `["b", "a"]` |
| `sort()` | Sort list | `sort(["b", "a"])` | `["a", "b"]` |
| `keys()` | Get keys from map | `keys({a=1, b=2})` | `["a", "b"]` |
| `values()` | Get values from map | `values({a=1, b=2})` | `[1, 2]` |
| `merge()` | Merge maps | `merge({a=1}, {b=2})` | `{a=1, b=2}` |
| `lookup()` | Lookup value in map | `lookup({a=1}, "a", 0)` | `1` |
| `zipmap()` | Create map from lists | `zipmap(["a"], [1])` | `{a=1}` |

## Date/Time Functions

| Function | Description | Example | Result |
|----------|-------------|---------|--------|
| `timestamp()` | Current UTC timestamp | `timestamp()` | `"2024-01-01T00:00:00Z"` |
| `formatdate()` | Format timestamp | `formatdate("DD-MM-YYYY", timestamp())` | `"01-01-2024"` |

## File Functions

| Function | Description | Example |
|----------|-------------|---------|
| `file()` | Read file content | `file("${path.module}/script.sh")` |
| `fileexists()` | Check if file exists | `fileexists("config.json")` |
| `templatefile()` | Render template file | `templatefile("template.tpl", {name="world"})` |

## IP Network Functions

| Function | Description | Example | Result |
|----------|-------------|---------|--------|
| `cidrhost()` | Get host IP from CIDR | `cidrhost("10.0.0.0/16", 5)` | `"10.0.0.5"` |
| `cidrnetmask()` | Get netmask | `cidrnetmask("10.0.0.0/16")` | `"255.255.0.0"` |
| `cidrsubnet()` | Calculate subnet CIDR | `cidrsubnet("10.0.0.0/16", 8, 1)` | `"10.0.1.0/24"` |

## Type Conversion Functions

| Function | Description | Example | Result |
|----------|-------------|---------|--------|
| `tostring()` | Convert to string | `tostring(123)` | `"123"` |
| `tonumber()` | Convert to number | `tonumber("123")` | `123` |
| `tobool()` | Convert to bool | `tobool("true")` | `true` |
| `tolist()` | Convert to list | `tolist(toset(["a", "b"]))` | `["a", "b"]` |
| `toset()` | Convert to set | `toset(["a", "a"])` | `["a"]` |
| `tomap()` | Convert to map | `tomap({a="1"})` | `{a="1"}` |

## Conditional Expressions

Conditional expressions use the ternary operator: `condition ? true_value : false_value`

```hcl
instance_type = var.environment == "prod" ? "t3.large" : "t2.micro"

count = var.enable_monitoring ? 1 : 0
```

## For Expressions

For expressions transform lists and maps.

### For expression over list
```hcl
[for s in var.list : upper(s)]
```

### For expression over map
```hcl
[for k, v in var.map : "${k}=${v}"]
{for k, v in var.map : k => upper(v)}
```

### With condition
```hcl
[for s in var.list : upper(s) if s != ""]
```

## Splat Operator

The splat operator `[*]` extracts attributes from a list of resources created with `count`.

```hcl
# Instead of:
[aws_instance.web[0].public_ip, aws_instance.web[1].public_ip]

# Use splat:
aws_instance.web[*].public_ip
```

For maps/objects with `for_each`, use `values()` or for expressions.

## Hands-On: Functions and Expressions

Let's create a configuration that uses various functions and expressions.

### Step 1: Create working directory

```bash
mkdir -p ~/terraform-learning/module3-functions-demo
cd ~/terraform-learning/module3-functions-demo
```

### Step 2: Create variables.tf

```hcl
variable "environment" {
  type    = string
  default = "dev"
}

variable "project_name" {
  type    = string
  default = "myapp"
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "enable_monitoring" {
  type    = bool
  default = false
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
  region = "us-east-1"
}

locals {
  # String functions
  bucket_name = lower(join("-", [var.project_name, var.environment, random_id.suffix.hex]))
  
  # Tags with merge
  common_tags = merge(
    {
      Project     = title(var.project_name)
      Environment = upper(var.environment)
      ManagedBy   = "Terraform"
      CreatedAt   = formatdate("YYYY-MM-DD", timestamp())
    },
    var.enable_monitoring ? { Monitoring = "Enabled" } : {}
  )
  
  # Create subnets using cidrsubnet
  subnet_cidrs = [for i in range(length(var.availability_zones)) : cidrsubnet(var.cidr_block, 8, i + 1)]
  
  # Instance type based on environment
  instance_type = var.environment == "prod" ? "t3.large" : "t2.micro"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "example" {
  bucket = local.bucket_name
  
  tags = local.common_tags
}

# Create subnets in different AZs
resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  
  tags = merge(local.common_tags, {
    Name = join("-", [var.project_name, "vpc"])
  })
}

resource "aws_subnet" "public" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  
  tags = merge(local.common_tags, {
    Name = format("public-subnet-%d", count.index + 1)
    Type = "Public"
  })
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
  count         = var.environment == "prod" ? 2 : 1
  ami           = data.aws_ami.amazon_linux.id
  instance_type = local.instance_type
  subnet_id     = aws_subnet.public[count.index].id
  
  tags = merge(local.common_tags, {
    Name = format("web-server-%s-%d", var.environment, count.index + 1)
  })
}
```

### Step 4: Create outputs.tf

```hcl
output "bucket_name" {
  value       = aws_s3_bucket.example.bucket
  description = "S3 bucket name (lowercase with functions)"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "subnet_cidrs" {
  value       = local.subnet_cidrs
  description = "Calculated subnet CIDRs using cidrsubnet"
}

output "subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Subnet IDs using splat operator"
}

output "instance_ids" {
  value       = aws_instance.web[*].id
  description = "Instance IDs using splat operator"
}

output "instance_type" {
  value       = local.instance_type
  description = "Instance type based on environment"
}

output "common_tags" {
  value       = local.common_tags
  description = "Merged tags"
}
```

### Step 5: Apply

```bash
terraform init
terraform plan
terraform apply
# Type yes
```

Observe how functions and expressions are used to create dynamic configurations!

### Step 6: Clean up

```bash
terraform destroy
# Type yes
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

> **⚠️ Cost Warning:** EC2 instances and VPC resources. t2.micro is Free Tier eligible. NAT Gateways would cost money but we're not creating them. Always destroy!

## Best Practices

- **Use locals for complex expressions** - Improves readability
- **Use functions to avoid repetition** - DRY principle
- **Prefer for expressions over count when transforming data** - More flexible
- **Use `lookup()` with defaults** - Safer than direct map access
- **Use `merge()` for combining maps** - Clean way to add tags
- **Use `format()` and `join()` for naming** - Consistent naming conventions
- **Test in terraform console** - Try functions before using them
- **Keep it simple** - Don't overuse functions unnecessarily

### Test functions with terraform console

```bash
terraform console
> lower("HELLO")
> join("-", ["a", "b"])
> cidrsubnet("10.0.0.0/16", 8, 0)
> merge({a=1}, {b=2})
> exit
```

## Summary

- **Functions** transform and manipulate data in Terraform
- **String functions** for formatting and manipulation
- **Collection functions** work with lists and maps
- **Conditional expressions** provide if/else logic with ternary operator
- **For expressions** transform lists and maps
- **Splat operator** `[*]` extracts attributes from lists
- **Locals** store computed values for reuse
- Use `terraform console` to test functions

## Next Steps

Now let's learn about [Terraform CLI Deep Dive](../04-terraform-cli-deep-dive/README.md) - advanced commands like import, replace, graph, and more.
