# Terraform Cheatsheet

Quick reference for common Terraform commands, syntax, and patterns.

## Core Commands

| Command | Description | Common Flags |
|---------|-------------|--------------|
| `terraform init` | Initialize working directory | `-upgrade`, `-reconfigure` |
| `terraform validate` | Validate configuration syntax | - |
| `terraform fmt` | Format code to canonical style | `-recursive`, `-check` |
| `terraform plan` | Create execution plan | `-out=file`, `-var="key=value"`, `-var-file=file.tfvars` |
| `terraform apply` | Apply changes | `-auto-approve`, `-var-file=file.tfvars` |
| `terraform destroy` | Destroy all resources | `-auto-approve`, `-target=resource` |
| `terraform show` | Show state or plan | - |
| `terraform output` | Show output values | `-json` |
| `terraform version` | Show version info | - |

## State Commands

| Command | Description |
|---------|-------------|
| `terraform state list` | List resources in state |
| `terraform state show <resource>` | Show details of a resource |
| `terraform state mv <src> <dest>` | Move resource in state |
| `terraform state rm <resource>` | Remove resource from state (doesn't destroy) |
| `terraform refresh` | Update state to match real infrastructure |

## Workspace Commands

| Command | Description |
|---------|-------------|
| `terraform workspace list` | List workspaces |
| `terraform workspace show` | Show current workspace |
| `terraform workspace new <name>` | Create new workspace |
| `terraform workspace select <name>` | Switch workspace |
| `terraform workspace delete <name>` | Delete workspace |

## Import & Other Commands

| Command | Description |
|---------|-------------|
| `terraform import <resource> <id>` | Import existing resource into state |
| `terraform console` | Interactive console for testing expressions |
| `terraform graph` | Generate dependency graph |
| `terraform providers` | Show provider requirements |
| `terraform get` | Download and update modules |

## Basic Syntax

### Provider
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

### Resource
```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
  
  tags = {
    Name = "Example"
  }
}
```

### Data Source
```hcl
data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}
```

### Variable
```hcl
variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}
```

### Output
```hcl
output "instance_ip" {
  value       = aws_instance.example.public_ip
  description = "Public IP of the instance"
}
```

### Module
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr = "10.0.0.0/16"
  environment = "dev"
}
```

## Variable Types

| Type | Example |
|------|---------|
| `string` | `"hello"` |
| `number` | `123` |
| `bool` | `true` / `false` |
| `list(string)` | `["a", "b", "c"]` |
| `set(string)` | `["a", "b"]` |
| `map(string)` | `{"key" = "value"}` |
| `object({...})` | Complex object |
| `tuple([...])` | Mixed types |

## Meta-Arguments

```hcl
resource "aws_instance" "example" {
  count         = 3                    # Create 3 instances
  for_each      = var.users            # Create per map/set item
  depends_on    = [aws_vpc.main]      # Explicit dependency
  provider      = aws.us_west         # Use non-default provider
  
  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes        = [tags]
  }
}
```

## Functions (Common)

| Function | Example | Description |
|----------|---------|-------------|
| `join()` | `join("-", ["a", "b"])` → `"a-b"` | Join list elements |
| `split()` | `split("-", "a-b")` → `["a", "b"]` | Split string |
| `length()` | `length(var.list)` | Get length |
| `lookup()` | `lookup(var.map, "key", "default")` | Lookup map value |
| `format()` | `format("Hello %s", "World")` | String formatting |
| `file()` | `file("script.sh")` | Read file content |
| `cidrsubnet()` | `cidrsubnet("10.0.0.0/16", 8, 0)` | Calculate subnet CIDR |
| `toset()` | `toset(["a", "b", "a"])` → `["a", "b"]` | Convert to set |
| `tomap()` | `tomap({"a" = 1})` | Convert to map |

## Conditionals

```hcl
# Ternary operator
instance_type = var.environment == "prod" ? "t3.large" : "t2.micro"

# Count with condition
resource "aws_instance" "example" {
  count = var.create_instance ? 1 : 0
  ...
}
```

## .gitignore Template

```gitignore
**/.terraform/*
*.tfstate
*.tfstate.*
crash.log
crash.*.log
*.tfvars
*.tfvars.json
override.tf
override.tf.json
*_override.tf
*_override.tf.json
.terraformrc
terraform.rc
```

## Tips & Best Practices

- ✅ Always run `terraform plan` before `terraform apply`
- ✅ Use `terraform fmt` and `terraform validate` regularly
- ✅ Pin provider and Terraform versions
- ✅ Never commit state files or credentials
- ✅ Use variables for reusability
- ✅ Use tags for all resources
- ✅ Always run `terraform destroy` after testing
- ✅ Use remote backend for teams
- ✅ Follow least privilege for AWS credentials
- ✅ Keep modules small and focused
