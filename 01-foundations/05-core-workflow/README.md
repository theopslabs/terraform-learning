# Lesson 5: Core Terraform Workflow

**Duration:** 60 minutes | **Level:** Beginner

## Table of Contents

- [The Core Workflow](#the-core-workflow)
- [terraform init](#terraform-init)
- [terraform plan](#terraform-plan)
- [terraform apply](#terraform-apply)
- [terraform destroy](#terraform-destroy)
- [Additional Useful Commands](#additional-useful-commands)
- [Understanding the Workflow in Practice](#understanding-the-workflow-in-practice)
- [Best Practices](#best-practices)
- [Summary](#summary)
- [Module 1 Wrap-up](#module-1-wrap-up)
- [Next Steps](#next-steps)

## The Core Workflow

Terraform follows a simple, consistent workflow for managing infrastructure:

```
1. Write    → Define infrastructure in .tf files
2. Init     → Initialize working directory (terraform init)
3. Plan     → Preview changes (terraform plan)
4. Apply    → Create/update infrastructure (terraform apply)
5. Destroy  → Remove infrastructure when done (terraform destroy)
```

This workflow is safe because you can always preview changes before applying them.

## terraform init

**Purpose:** Initialize a Terraform working directory.

When you run `terraform init`, Terraform:
- Downloads and installs provider plugins
- Initializes the backend (where state is stored)
- Downloads modules if referenced
- Creates a `.terraform/` directory
- Creates `.terraform.lock.hcl` (dependency lock file)

### Syntax
```bash
terraform init
```

### Example Output (truncated)
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...
- Installed hashicorp/aws v5.x.x

Terraform has been successfully initialized!
```

**Important:** Run `terraform init` whenever you:
- Start a new Terraform project
- Add a new provider
- Add a new module
- Change backend configuration

## terraform plan

**Purpose:** Create an execution plan showing what Terraform will do.

`terraform plan` compares:
- Your configuration files (what you want)
- The current state file (what exists)
- The actual infrastructure (if state is out of sync)

It shows a preview without making any changes.

### Syntax
```bash
terraform plan

# Save plan to a file
terraform plan -out=tfplan

# Show plan from saved file
terraform show tfplan
```

### Understanding Plan Output

```hcl
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  - destroy
  ~ update in-place
-/+ destroy and then create replacement
```

| Symbol | Meaning |
|--------|---------|
| `+` | Create new resource |
| `-` | Destroy resource |
| `~` | Modify resource in place |
| `-/+` | Replace resource (destroy old, create new) |
| `<=` | Read data source |
| `# forces replacement` | Change requires resource replacement |

### Example Plan
```bash
Plan: 1 to add, 0 to change, 0 to destroy.
```

## terraform apply

**Purpose:** Apply the changes required to reach the desired state.

`terraform apply`:
- Creates a plan (if not already created)
- Asks for confirmation (unless auto-approve is used)
- Executes the plan and provisions infrastructure
- Updates the state file

### Syntax
```bash
# Interactive (asks for confirmation)
terraform apply

# Apply without confirmation (use with caution!)
terraform apply -auto-approve

# Apply a saved plan
terraform apply tfplan
```

### Example Output
```
aws_s3_bucket.example: Creating...
aws_s3_bucket.example: Creation complete after 2s [id=my-bucket-name]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

**State File:** After apply, Terraform creates/updates `terraform.tfstate`. This file contains the mapping between your configuration and real infrastructure.

> **⚠️ Important:** Never manually edit `terraform.tfstate`. Terraform manages it.

## terraform destroy

**Purpose:** Destroy all resources managed by the current Terraform configuration.

`terraform destroy`:
- Creates a plan to delete everything in the state
- Asks for confirmation
- Removes all managed resources
- Updates the state file (removes destroyed resources)

### Syntax
```bash
# Interactive
terraform destroy

# Without confirmation
terraform destroy -auto-approve
```

**Use this when:** You're done with an exercise, testing, or want to clean up resources to avoid costs.

## Additional Useful Commands

| Command | Purpose | Example |
|---------|---------|---------|
| `terraform validate` | Check configuration syntax and internal consistency | `terraform validate` |
| `terraform fmt` | Format code to canonical style | `terraform fmt` |
| `terraform show` | Show current state or plan file | `terraform show` |
| `terraform output` | Show output values from state | `terraform output` |
| `terraform refresh` | Update state to match real infrastructure | `terraform refresh` |
| `terraform state list` | List all resources in state | `terraform state list` |
| `terraform graph` | Generate visual dependency graph (can use with graphviz) | `terraform graph \| dot -Tpng > graph.png` |
| `terraform version` | Show Terraform version | `terraform version` |

## Understanding the Workflow in Practice

Let's walk through a complete cycle to solidify your understanding:

### Scenario: Create and destroy an EC2 instance

Create a new directory and configuration:

```bash
mkdir ~/terraform-learning/workflow-demo
cd ~/terraform-learning/workflow-demo
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
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  tags = {
    Name = "Workflow-Demo"
  }
}
```

> **Free Tier Note:** t2.micro is Free Tier eligible in most regions for 12 months.

Now run the workflow:

```bash
# 1. Initialize
terraform init

# 2. Validate and format
terraform validate
terraform fmt

# 3. Plan
terraform plan

# 4. Apply
terraform apply
# Type yes

# 5. Verify
terraform state list
terraform show

# 6. Destroy
terraform destroy
# Type yes
```

Notice how Terraform uses the AMI data source to find the latest Amazon Linux 2 AMI automatically - no hardcoded AMI ID needed!

## Best Practices

- **Always plan before apply** - Review changes carefully
- **Use version control** - Commit `.tf` files to Git, but NOT `terraform.tfstate` or `.terraform/`
- **Create a `.gitignore`** - Add `*.tfstate`, `*.tfstate.*`, `.terraform/`, `crash.log`, etc.
- **Format regularly** - Use `terraform fmt` to keep code consistent
- **Validate before applying** - Use `terraform validate`
- **Destroy test resources** - Avoid unnecessary costs
- **Use descriptive names** - Resource names should be clear
- **Pin versions** - Always pin provider and Terraform versions
- **Store state remotely** - We'll learn this in Module 3 (important for teams)

### Sample .gitignore for Terraform

```gitignore
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files, which may contain sensitive data
*.tfvars
*.tfvars.json

# Ignore override files
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Ignore CLI configuration files
.terraformrc
terraform.rc
```

## Summary

- **terraform init** - Downloads providers, initializes backend
- **terraform plan** - Previews changes safely
- **terraform apply** - Creates/updates infrastructure
- **terraform destroy** - Removes all managed resources
- **State file** tracks what Terraform manages
- **Always plan before apply** to avoid surprises
- **Never commit state files** or sensitive data to Git

## Module 1 Wrap-up

Congratulations! You've completed Module 1: Foundations. You now know:

✅ What is Infrastructure as Code and why use it  
✅ What is Terraform and why it's popular  
✅ How to set up Terraform and AWS CLI  
✅ Terraform basics - HCL, providers, resources, data sources  
✅ The core workflow - init, plan, apply, destroy  

## Next Steps

Ready for more advanced concepts? Move on to [Module 2: Core Concepts](../../02-core-concepts/README.md) where you'll learn about Terraform state, variables, outputs, meta-arguments, and more!

**Before moving on:** Complete the [Module 1 Exercises](../exercises.md) to reinforce what you've learned.
