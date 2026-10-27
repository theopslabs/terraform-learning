# Module 5 Exercises

**Goal:** Practice advanced Terraform concepts

## Exercise 1: Best Practices Review
Review and improve a configuration:

**Requirements:**
- Take any of your previous configurations
- Apply all best practices from Module 5 Lesson 1
- Add proper file structure (main.tf, variables.tf, outputs.tf, versions.tf)
- Add descriptions to all variables and outputs
- Add tags to all resources
- Create a comprehensive README.md
- Add proper .gitignore

## Exercise 2: Testing and Validation
Set up validation for a project:

**Requirements:**
- Create a simple Terraform configuration
- Run `terraform fmt` and `terraform validate`
- Install and run `tflint`
- Install and run `checkov` or `tfsec`
- Fix any issues found
- Document the findings

## Exercise 3: CI/CD Pipeline
Design a CI/CD workflow:

**Requirements:**
- Create a GitHub Actions workflow file
- Include fmt, validate, plan steps for PRs
- Include apply step for main branch (with approval)
- Add security scanning
- Document the workflow
- Explain the safeguards

## Exercise 4: Secrets Management
Implement secure secrets handling:

**Requirements:**
- Create a configuration using AWS Secrets Manager or SSM Parameter Store
- Generate a random password
- Store it securely
- Use it in an RDS instance (or simulate)
- Mark outputs as sensitive
- Ensure it's not hardcoded
- Clean up properly

## Exercise 5: Multi-Environment Architecture
Design a multi-environment setup:

**Requirements:**
- Create directory structure for dev, staging, prod
- Create a reusable module (e.g., VPC or S3)
- Use the module in all three environments
- Use environment-specific values
- Configure separate backend state per environment
- Document the structure and how to use it

## Final Challenge: Capstone Project
Build a complete production-ready infrastructure:

**Requirements:**
- Use modules for all components
- Multi-environment ready structure
- Remote backend with locking
- All resources tagged consistently
- Security best practices followed
- No hardcoded secrets
- Proper variable validation
- Complete documentation
- CI/CD ready structure

**Project Idea:** Deploy a highly available web application with:
- VPC with public/private subnets across 2 AZs
- ALB in public subnets
- Auto Scaling Group in private subnets
- RDS in private subnets
- S3 bucket for static assets
- CloudWatch logs (optional)

## Tips for Completion
- Review all modules to reinforce learning
- Practice, practice, practice
- Build your own projects
- Consider the Terraform Associate certification
- Join the Terraform community
- Keep your code on GitHub as a portfolio
- Always follow security best practices
- Never stop learning!

## Course Complete!
You've finished all 5 modules. You now have the knowledge to:
- Build infrastructure as code with Terraform
- Deploy to AWS confidently
- Follow production best practices
- Work in team environments
- Prepare for Terraform certifications

**Congratulations on your achievement!**
