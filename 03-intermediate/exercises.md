# Module 3 Exercises

**Goal:** Practice the concepts learned in Module 3

## Exercise 1: Modules (Theory)
Answer the following questions:

1. What is a Terraform module? What are the benefits?
2. What's the difference between root module and child module?
3. How do you pass values to a module and get values from it?
4. When would you use local modules vs remote modules?
5. What files should a well-structured module contain?

## Exercise 2: Create and Use a Module
Create a VPC module and use it:

**Requirements:**
- Create a module at `modules/vpc/` with variables, main.tf, outputs.tf
- Module should create: VPC, 2 public subnets, 2 private subnets
- Use variables for VPC CIDR, availability zones, environment
- Output VPC ID and subnet IDs
- Use the module in root configuration
- Make it configurable and reusable

**Bonus:** Add Internet Gateway and route tables

## Exercise 3: Workspaces
Use workspaces to manage dev and prod:

**Requirements:**
- Create configuration with `terraform.workspace`
- Use different instance types per workspace (dev: t2.micro, prod: t3.small)
- Use different instance counts per workspace
- Tag all resources with workspace name
- Create dev and prod workspaces and deploy to both
- Destroy both workspaces

## Exercise 4: Functions and Expressions
Practice using functions:

**Requirements:**
- Use string functions: `lower()`, `upper()`, `join()`, `format()`
- Use collection functions: `merge()`, `length()`, `lookup()`
- Use `cidrsubnet()` to calculate subnet CIDRs
- Use conditional expressions with `? :`
- Use for expressions to transform lists
- Use `terraform console` to test at least 5 functions
- Create a configuration that demonstrates at least 3 of the above

## Exercise 5: CLI Deep Dive
Practice advanced CLI commands:

**Requirements:**
- Create a configuration and run `terraform fmt` and `terraform validate`
- Use `terraform console` to test expressions
- Generate a graph with `terraform graph`
- Practice `terraform state list` and `terraform state show`
- Use `terraform apply -replace` to force recreate a resource
- Document what each command does

## Exercise 6: Remote State
Set up remote state (if possible in your AWS account):

**Requirements:**
- Create S3 bucket and DynamoDB table for state
- Configure S3 backend with DynamoDB locking
- Migrate local state to remote state
- Verify state is in S3
- Test state locking (optional - try running apply in two terminals)
- Destroy and clean up

**Note:** If you're concerned about costs, do this exercise quickly and destroy immediately. All resources are Free Tier eligible.

## Challenge (Optional)
Build a complete, modular infrastructure:

1. Create modules for VPC, Security Groups, and EC2
2. Use workspaces for dev/staging/prod
3. Use functions for dynamic naming and CIDR calculations
4. Configure remote state
5. Follow all best practices from Module 3
6. Make it as reusable and configurable as possible

## Tips
- Test functions in `terraform console` first
- Always run `terraform plan` before apply
- Be careful with state operations
- Destroy all workspaces and resources
- Use `terraform fmt -recursive` to format all files
- Never commit `.tfstate` files or backend configs with sensitive data
