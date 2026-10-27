# Lesson 1: Terraform Best Practices

**Duration:** 90 minutes | **Level:** Advanced

## Table of Contents

- [Code Organization](#code-organization)
- [Naming Conventions](#naming-conventions)
- [State Management Best Practices](#state-management-best-practices)
- [Security Best Practices](#security-best-practices)
- [DRY Principles](#dry-principles)
- [Version Control](#version-control)
- [Documentation](#documentation)
- [General Best Practices](#general-best-practices)
- [Checklist](#checklist)
- [Summary](#summary)
- [Next Steps](#next-steps)

## Code Organization

### Standard File Structure
```
project/
├── main.tf          # Main resources
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── versions.tf      # Provider and Terraform versions
├── terraform.tfvars # Variable values (don't commit secrets)
├── data.tf          # Data sources (optional)
├── locals.tf        # Local values (optional)
└── README.md        # Documentation
```

### For Larger Projects
```
environments/
├── dev/
├── staging/
└── prod/
modules/
├── vpc/
├── ec2/
└── rds/
```

## Naming Conventions

- **Resources**: Use descriptive, lowercase names with underscores
- **Variables**: Clear, descriptive names
- **Outputs**: Descriptive of what they return
- **Tags**: Use consistent tagging strategy
- **Files**: Use lowercase with underscores or hyphens

```hcl
# Good
resource "aws_instance" "web_server" { ... }

# Bad
resource "aws_instance" "instance1" { ... }
```

## State Management Best Practices

- ✅ Use remote backend for team collaboration
- ✅ Enable state locking (DynamoDB with S3)
- ✅ Enable versioning on state bucket
- ✅ Encrypt state at rest and in transit
- ✅ Use separate state files per environment
- ✅ Never commit state files to Git
- ✅ Restrict access to state with IAM
- ✅ Back up state regularly (versioning does this)

## Security Best Practices

- ✅ **Never hardcode secrets** - Use AWS Secrets Manager or environment variables
- ✅ **Use least privilege IAM** - Minimal permissions needed
- ✅ **Mark sensitive variables/outputs** - Use `sensitive = true`
- ✅ **Use .gitignore** - Exclude sensitive files
- ✅ **Enable encryption** - For S3, EBS, RDS, etc.
- ✅ **Use security groups properly** - Follow least privilege
- ✅ **Avoid 0.0.0.0/0** where possible - Restrict to specific IPs
- ✅ **Use AWS STS/temporary credentials** when possible
- ✅ **Rotate credentials regularly**
- ✅ **Scan for security issues** - Use Checkov, tfsec

## DRY Principles

Use modules, variables, locals, and workspaces to avoid repetition.

```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Owner       = var.owner
  }
}

resource "aws_instance" "web" {
  tags = merge(local.common_tags, {
    Name = "web-server"
  })
}
```

## Version Control

**.gitignore for Terraform:**
```gitignore
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log

# Exclude all .tfvars files
*.tfvars
*.tfvars.json

# Override files
override.tf
override.tf.json

# CLI configuration
.terraformrc
terraform.rc

# Sensitive files
*.pem
*.key
```

**Git Workflow:**
- Use feature branches
- Create pull requests for changes
- Review terraform plans in PRs
- Use semantic commit messages
- Tag releases

## Documentation

- **README.md** for every module and project
- Document variables with descriptions
- Document outputs with descriptions
- Include usage examples
- Document prerequisites and costs
- Add architecture diagrams if complex

## General Best Practices

- **Pin versions** - Always pin Terraform and provider versions
- **Use data sources** - Don't hardcode AMI IDs or other values
- **Validate before apply** - Always run plan
- **Format code** - Use `terraform fmt`
- **Use outputs** - Expose useful information
- **Keep modules small and focused** - Single responsibility
- **Use count/for_each appropriately** - Prefer for_each
- **Avoid provisioners** - Use user data or configuration management tools
- **Test in dev first** - Never test in production
- **Destroy resources when not needed** - Control costs

## Checklist

Before committing/merging Terraform code:

- [ ] `terraform fmt -recursive` run
- [ ] `terraform validate` passes
- [ ] `terraform plan` reviewed
- [ ] No secrets in code
- [ ] Variables have descriptions and types
- [ ] Outputs have descriptions
- [ ] Resources are tagged
- [ ] `.gitignore` is up to date
- [ ] README updated
- [ ] State is in remote backend (for teams)
- [ ] Security review done

## Summary

- Organize code logically with standard file structure
- Follow naming conventions consistently
- Manage state securely with remote backends
- Never compromise security - no hardcoded secrets
- Follow DRY principles with modules
- Use proper version control
- Document everything
- Always validate and review changes

## Next Steps

Learn about [Testing & Validation](../02-testing-validation/README.md).
