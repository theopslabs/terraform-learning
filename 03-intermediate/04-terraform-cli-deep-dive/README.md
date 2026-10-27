# Lesson 4: Terraform CLI Deep Dive

**Duration:** 60 minutes | **Level:** Intermediate

## Table of Contents

- [Overview](#overview)
- [terraform fmt and validate](#terraform-fmt-and-validate)
- [terraform show](#terraform-show)
- [terraform console](#terraform-console)
- [terraform graph](#terraform-graph)
- [terraform import](#terraform-import)
- [terraform taint and terraform apply -replace](#terraform-taint-and-terraform-apply--replace)
- [terraform state advanced commands](#terraform-state-advanced-commands)
- [terraform force-unlock](#terraform-force-unlock)
- [Hands-On: Advanced CLI Commands](#hands-on-advanced-cli-commands)
- [Best Practices](#best-practices)
- [Summary](#summary)
- [Next Steps](#next-steps)

## Overview

Beyond the core workflow (init, plan, apply, destroy), Terraform has many useful CLI commands for debugging, importing existing resources, and managing state.

## terraform fmt and validate

### terraform fmt
Formats Terraform configuration files to a canonical style.

```bash
# Format current directory
terraform fmt

# Format recursively
terraform fmt -recursive

# Check if files are formatted (CI/CD use)
terraform fmt -check
```

### terraform validate
Validates the configuration for syntax errors and internal consistency.

```bash
terraform validate
```

**Best Practice:** Run `fmt` and `validate` before committing code.

## terraform show

Displays human-readable output from a state file or plan file.

```bash
# Show current state
terraform show

# Show a saved plan
terraform plan -out=tfplan
terraform show tfplan

# JSON output
terraform show -json
```

## terraform console

Interactive console for testing expressions and functions.

```bash
terraform console
> var.environment
> local.common_tags
> cidrsubnet("10.0.0.0/16", 8, 0)
> exit
```

Great for debugging complex expressions!

## terraform graph

Generates a visual representation of the dependency graph. Outputs in DOT format.

```bash
# Generate DOT graph
terraform graph

# Generate PNG (requires graphviz)
terraform graph | dot -Tpng > graph.png

# Generate SVG
terraform graph | dot -Tsvg > graph.svg
```

You can visualize dependencies between resources, modules, and providers.

## terraform import

Imports existing infrastructure into Terraform state so it can be managed by Terraform.

### Syntax
```bash
terraform import <resource_type>.<resource_name> <resource_id>
```

### Example
Import an existing S3 bucket:

```bash
# First, write the resource block in your config
resource "aws_s3_bucket" "existing" {
  bucket = "my-existing-bucket-name"
}

# Then import it
terraform import aws_s3_bucket.existing my-existing-bucket-name
```

**Important Notes:**
- You must write the resource configuration before importing
- Import only updates state, doesn't modify configuration
- After import, run `terraform plan` to see if config matches
- Different resources have different ID formats (check provider docs)

## terraform taint and terraform apply -replace

Used to force recreation of a resource.

### Old way (deprecated in newer versions): terraform taint
```bash
terraform taint aws_instance.web
terraform apply
```

### New way (recommended): terraform apply -replace
```bash
terraform apply -replace="aws_instance.web"
```

Or in plan:
```bash
terraform plan -replace="aws_instance.web"
```

**Use cases:**
- Resource is in a bad state and needs recreation
- Want to test recreation behavior
- Manual changes made outside Terraform that need fixing

## terraform state advanced commands

```bash
# List all resources
terraform state list

# Show specific resource
terraform state show aws_instance.web

# Move resource in state (rename)
terraform state mv aws_instance.old aws_instance.new

# Remove resource from state WITHOUT destroying it
terraform state rm aws_instance.web

# Pull remote state
terraform state pull > backup.tfstate

# Push local state to remote
terraform state push backup.tfstate
```

> **Warning:** State commands are powerful and can be destructive. Always backup state first!

## terraform force-unlock

If a state lock is stuck (e.g., due to crashed process), you can force unlock.

```bash
terraform force-unlock <LOCK_ID>
```

Only use this if you're sure no other process is using the state!

## Hands-On: Advanced CLI Commands

### Part 1: fmt and validate

```bash
mkdir -p ~/terraform-learning/module3-cli-demo
cd ~/terraform-learning/module3-cli-demo

# Create a poorly formatted file
cat > main.tf << 'EOF'
terraform {
required_providers {
aws = {
source = "hashicorp/aws"
version = "~> 5.0"
}
}
}
provider "aws" {
region = "us-east-1"
}
resource "aws_s3_bucket" "example" {
bucket = "test-bucket-cli-demo-12345"
tags = {
Name = "Test"
Environment = "Dev"
}
}
EOF

# Format it
terraform fmt

# Validate
terraform init
terraform validate
```

### Part 2: console and graph

```bash
# Test expressions
terraform console
> "hello" + " " + "world"
> upper("terraform")
> length(["a", "b", "c"])
> exit

# Generate graph
terraform graph | head -30
```

### Part 3: import (simulation)

Since we can't easily import arbitrary resources, we'll understand the workflow:

1. Create resource block in config
2. Run `terraform import <address> <id>`
3. Run `terraform plan` to see differences
4. Adjust config to match state

### Part 4: replace

```bash
terraform apply -auto-approve

# Force replace the bucket
terraform apply -replace="aws_s3_bucket.example"
# Type yes
```

### Clean up

```bash
terraform destroy -auto-approve
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

## Best Practices

- **Always format** - Run `terraform fmt` before committing
- **Always validate** - Run `terraform validate` in CI/CD
- **Use replace instead of taint** - `-replace` is the newer recommended approach
- **Be careful with import** - Understand resource ID format from docs
- **Backup state before state operations** - Use `terraform state pull`
- **Only force-unlock if necessary** - Ensure no other process is running
- **Use console for debugging** - Test complex expressions safely
- **Generate graphs for documentation** - Helps understand dependencies

## Summary

- **fmt/validate** - Keep code clean and valid
- **show/console** - Inspect state and test expressions
- **graph** - Visualize dependencies
- **import** - Bring existing resources under Terraform management
- **replace/-replace** - Force recreation of resources
- **state commands** - Advanced state manipulation
- **force-unlock** - Recover from stuck locks

## Next Steps

The final lesson of Module 3: [Remote State & Backends](../05-remote-state-and-backends/README.md) - learn how to store state remotely for team collaboration with S3 and DynamoDB locking.
