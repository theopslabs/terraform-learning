# Module 2 Exercises

**Goal:** Practice the concepts learned in Module 2

## Exercise 1: Terraform State (Theory)
Answer the following questions:

1. What is Terraform state and why is it important?
2. What's the difference between local and remote state?
3. Why should you never commit `terraform.tfstate` to Git?
4. What does state locking do?
5. When would you use `terraform state rm` vs `terraform destroy`?

## Exercise 2: Variables and Outputs
Create a reusable Terraform configuration:

**Requirements:**
- Create `variables.tf` with variables for `instance_type`, `environment`, and `ami_id`
- Use validation for `environment` (must be dev/staging/prod)
- Use `terraform.tfvars` to set values
- Create `outputs.tf` with outputs for instance ID and public IP
- Mark any sensitive values appropriately (if you add any)
- Use `t2.micro` (Free Tier compatible)

**Bonus:** Add a variable for tags as a map and use it in your resources

## Exercise 3: Data Sources
Create a configuration that uses data sources:

**Requirements:**
- Use `aws_ami` data source to get the latest Amazon Linux 2 AMI
- Use `aws_availability_zones` data source to get available AZs
- Use `aws_caller_identity` data source
- Use `aws_region` data source
- Create an EC2 instance using the AMI from data source
- Output all the data source values

## Exercise 4: Providers and Versions
Create a multi-region configuration:

**Requirements:**
- Use `required_providers` with version constraints for AWS (`~> 5.0`)
- Configure default provider in `us-east-1`
- Configure aliased provider in `us-west-1`
- Create an S3 bucket in each region using appropriate providers
- Use random provider for unique bucket names
- Pin Terraform version in `required_version`

## Exercise 5: Meta-Arguments - count and for_each
Create a configuration using both meta-arguments:

**Part A - count:**
- Create 3 EC2 instances using `count`
- Name them as "Web-Server-1", "Web-Server-2", "Web-Server-3"
- Use `count.index`

**Part B - for_each:**
- Create S3 buckets using `for_each` with a map of environment -> purpose
- Example: `{"dev" = "logs", "staging" = "backups", "prod" = "data"}`
- Tag each bucket with its purpose

**Bonus:** Use `lifecycle` with `create_before_destroy = true` on one of the buckets

## Challenge (Optional)
Create a comprehensive configuration that combines everything:

1. Use variables for configuration
2. Use data sources to get AMI and AZs
3. Use `for_each` to create subnets in different AZs
4. Use outputs to display all created resources
5. Follow all best practices from Module 2
6. Add proper tags to everything
7. Make it Free Tier compatible

## Tips
- Always use `terraform fmt` before applying
- Always run `terraform plan` first
- Destroy resources after each exercise
- Don't commit state files
- Use unique names for globally unique resources (S3, etc.)
- Be careful with IAM users and policies
