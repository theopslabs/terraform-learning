# Lesson 3: CI/CD with Terraform

**Duration:** 90 minutes | **Level:** Advanced

## Table of Contents

- [CI/CD Overview](#cicd-overview)
- [Git Workflow for Terraform](#git-workflow-for-terraform)
- [GitHub Actions Basics](#github-actions-basics)
- [Terraform Workflow in CI/CD](#terraform-workflow-in-cicd)
- [Approvals and Safeguards](#approvals-and-safeguards)
- [Best Practices](#best-practices)
- [Hands-On: GitHub Actions Workflow](#hands-on-github-actions-workflow)
- [Summary](#summary)
- [Next Steps](#next-steps)

## CI/CD Overview

**CI/CD (Continuous Integration/Continuous Deployment)** automates the testing, validation, and deployment of infrastructure changes. This ensures consistency, reduces human error, and enables safe collaboration.

## Git Workflow for Terraform

Recommended workflow:

1. **Create feature branch** - `git checkout -b feature/add-vpc`
2. **Make changes** - Edit Terraform files
3. **Validate locally** - `terraform fmt`, `validate`, `plan`
4. **Commit and push** - `git commit -m "Add VPC module"`
5. **Open Pull Request** - Triggers CI to run plan
6. **Review plan** - Team reviews changes
7. **Approve and merge** - Triggers CD to run apply
8. **Apply to infrastructure** - Changes deployed

## GitHub Actions Basics

GitHub Actions allows you to automate workflows. Workflows are defined in `.github/workflows/` as YAML files.

## Terraform Workflow in CI/CD

Typical pipeline stages:

1. **Checkout** - Clone repository
2. **Setup Terraform** - Install Terraform
3. **Configure AWS Credentials** - Use OIDC or secrets
4. **terraform init** - Initialize
5. **terraform fmt -check** - Check formatting
6. **terraform validate** - Validate configuration
7. **terraform plan** - Generate plan
8. **Comment plan on PR** - Show plan to reviewers
9. **terraform apply** - Apply (only on merge to main, with approval)

## Approvals and Safeguards

- **Required reviews** - PR must be approved
- **Environment protection rules** - Require manual approval for production
- **Plan output in PR** - Review before applying
- **Branch protection** - Prevent direct pushes to main
- **State locking** - Prevent concurrent runs
- **OIDC authentication** - More secure than long-lived keys

## Hands-On: GitHub Actions Workflow

Create `.github/workflows/terraform.yml`:

```yaml
name: 'Terraform CI/CD'

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

permissions:
  contents: read
  pull-requests: write
  id-token: write

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    environment: production
    
    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.9.8

    - name: Configure AWS Credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
        aws-region: us-east-1

    - name: Terraform Format
      run: terraform fmt -check -recursive

    - name: Terraform Init
      run: terraform init

    - name: Terraform Validate
      run: terraform validate -no-color

    - name: Terraform Plan
      id: plan
      if: github.event_name == 'pull_request'
      run: terraform plan -no-color -input=false
      continue-on-error: true

    - name: Comment Plan on PR
      if: github.event_name == 'pull_request'
      uses: actions/github-script@v7
      with:
        github-token: ${{ secrets.GITHUB_TOKEN }}
        script: |
          const output = `#### Terraform Plan 📖\`${{ steps.plan.outcome }}\`
          
          <details><summary>Show Plan</summary>
          
          \`\`\`terraform
          ${{ steps.plan.outputs.stdout }}
          \`\`\`
          
          </details>`;
          github.rest.issues.createComment({
            issue_number: context.issue.number,
            owner: context.repo.owner,
            repo: context.repo.repo,
            body: output
          })

    - name: Terraform Apply
      if: github.ref == 'refs/heads/main' && github.event_name == 'push'
      run: terraform apply -auto-approve -input=false
```

> **Note:** This is a template. You'll need to set up AWS OIDC, IAM roles, and adjust for your setup.

## Best Practices

- **Use remote backend** - Essential for CI/CD
- **Use OIDC instead of access keys** - More secure
- **Separate plan and apply** - Plan on PR, apply on merge
- **Require approvals** - For production environments
- **Use environment variables** - Store configuration
- **Lock Terraform version** - Use same version locally and in CI
- **Run security scans** - Add checkov/tfsec steps
- **Use workspaces or directories** - For multi-environment
- **Implement cost estimation** - Use Infracost
- **Keep workflows simple** - Start basic, iterate

## Summary

- CI/CD automates Terraform workflows
- Use Git flow with PR reviews
- GitHub Actions can automate plan/apply
- Always require approvals for production
- Use secure authentication (OIDC)
- Add safeguards and validations

## Next Steps

Learn about [Secrets Management](../04-secrets-management/README.md).
