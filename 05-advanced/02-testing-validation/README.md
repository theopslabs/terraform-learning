# Lesson 2: Testing & Validation

**Duration:** 60 minutes | **Level:** Advanced

## Table of Contents

- [Why Test Terraform?](#why-test-terraform)
- [Built-in Validation](#built-in-validation)
- [Linting with tflint](#linting-with-tflint)
- [Security Scanning](#security-scanning)
- [Plan Review](#plan-review)
- [Testing Strategies](#testing-strategies)
- [Tools Overview](#tools-overview)
- [Best Practices](#best-practices)
- [Summary](#summary)
- [Next Steps](#next-steps)

## Why Test Terraform?

- **Catch errors early** - Syntax, logic, and security issues
- **Prevent misconfigurations** - Avoid deploying broken infrastructure
- **Ensure compliance** - Meet security and regulatory requirements
- **Save costs** - Avoid expensive mistakes
- **Improve confidence** - Deploy with assurance

## Built-in Validation

### terraform validate
Checks configuration syntax and internal consistency.

```bash
terraform validate
```

### terraform fmt
Ensures consistent code formatting.

```bash
terraform fmt -check -recursive
```

### terraform plan
The most important validation - shows what will change.

```bash
terraform plan
```

## Linting with tflint

**tflint** is a Terraform linter that finds errors, deprecated syntax, and enforces best practices.

### Installation
```bash
# macOS
brew install tflint

# Linux
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
```

### Usage
```bash
tflint --init
tflint
```

tflint can check for:
- AWS provider specific issues
- Deprecated resource types
- Invalid instance types
- Naming conventions
- Missing required arguments

## Security Scanning

### Checkov
**Checkov** scans Terraform for security and compliance issues.

```bash
# Install
pip install checkov

# Scan
checkov -d .
```

### tfsec
**tfsec** is another security scanner for Terraform.

```bash
# Install
brew install tfsec

# Scan
tfsec .
```

Both tools check for:
- Unencrypted resources
- Open security groups (0.0.0.0/0)
- Missing logging
- Weak configurations
- Compliance violations (CIS, PCI-DSS, etc.)

## Plan Review

Always review `terraform plan` output carefully:

- Check resources being added/changed/destroyed
- Verify counts and values
- Look for unexpected replacements
- Ensure no sensitive data in plan
- Review in pull requests

## Testing Strategies

| Strategy | When to Use | Tools |
|----------|-------------|-------|
| **Static Analysis** | Every commit | terraform fmt, validate, tflint |
| **Security Scanning** | Every commit | checkov, tfsec |
| **Plan Review** | Pull requests | Manual review of plan output |
| **Integration Testing** | Before merge to main | terratest, kitchen-terraform |
| **End-to-End Testing** | In staging environment | Manual or automated tests |

**Note:** Full integration testing is advanced. For this course, focus on static analysis and plan review.

## Tools Overview

| Tool | Purpose | Free |
|------|---------|------|
| **terraform validate** | Syntax validation | Yes (built-in) |
| **terraform fmt** | Formatting | Yes (built-in) |
| **tflint** | Linting | Yes |
| **checkov** | Security/compliance | Yes |
| **tfsec** | Security scanning | Yes |
| **terratest** | Integration testing (Go) | Yes |
| **terraform-compliance** | BDD testing | Yes |

## Best Practices

- Run `terraform fmt` and `validate` locally before pushing
- Use pre-commit hooks to automate checks
- Run security scans in CI/CD
- Always review plans in pull requests
- Block merges if checks fail
- Test in dev/staging before production
- Document exceptions if you must skip checks
- Keep scanning tools updated

### Pre-commit Hook Example
```yaml
repos:
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.83.5
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_tflint
      - id: terraform_checkov
```

## Summary

- **Validation** catches syntax and configuration errors
- **Linting** enforces best practices and catches issues
- **Security scanning** identifies vulnerabilities
- **Plan review** is critical before applying
- Use automated tools in CI/CD pipelines
- Prevention is better than remediation

## Next Steps

Learn about [CI/CD with Terraform](../03-cicd-with-terraform/README.md).
