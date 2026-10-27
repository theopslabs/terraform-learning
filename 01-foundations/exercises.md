# Module 1 Exercises

**Goal:** Practice the concepts learned in Module 1

## Exercise 1: IaC Concepts (Theory)
Answer the following questions in your own words:

1. What is Infrastructure as Code? Why is it important?
2. What's the difference between declarative and imperative approaches? Which one does Terraform use?
3. List 3 benefits of using IaC over manual infrastructure management.
4. What are some challenges of IaC?

## Exercise 2: Environment Setup
Complete the following:

1. Verify Terraform is installed: `terraform version`
2. Verify AWS CLI is installed: `aws --version`
3. Verify AWS credentials are configured: `aws sts get-caller-identity`
4. Take a screenshot or note of your outputs

## Exercise 3: Create Your First Resource
Create a Terraform configuration to provision an S3 bucket:

**Requirements:**
- Use the AWS provider in `us-east-1`
- Create an S3 bucket with a unique name
- Add tags: `Project = "TerraformLearning"`, `Owner = "<your-name>"`
- Use Terraform version constraint `>= 1.0, < 2.0` and AWS provider `~> 5.0`

**Steps:**
1. Create a new directory: `exercise-3`
2. Write `main.tf`
3. Run `terraform init`, `terraform plan`, `terraform apply`
4. Verify the bucket exists in AWS Console
5. Run `terraform destroy` and clean up

## Exercise 4: Use a Data Source
Modify your configuration to use a data source:

**Requirements:**
- Use the `aws_caller_identity` data source to get your AWS account ID
- Create an output that displays your account ID
- Apply and see the output

**Hint:** 
```hcl
data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
```

## Exercise 5: Practice the Full Workflow
Create a configuration for a simple EC2 instance:

**Requirements:**
- Use `data "aws_ami"` to find the latest Amazon Linux 2 AMI (owners = ["amazon"])
- Create an `aws_instance` with instance_type `t2.micro`
- Add appropriate tags
- Use `terraform fmt` and `terraform validate`
- Run through the full workflow: init, plan, apply, destroy

**Bonus:** Use `terraform state list` to see the resources in your state

## Solutions

Check your solutions against best practices:

- Bucket names must be globally unique - use random suffixes if needed
- Always use `terraform fmt` before committing
- Never commit `.tfstate` files
- Always destroy resources after exercises
- Use version constraints in your `terraform` block

## Challenge (Optional)

Create a configuration that:
1. Creates an S3 bucket
2. Uses a data source to get the current AWS region
3. Outputs both the bucket name and region

This will help you understand combining resources and data sources!
