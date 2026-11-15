# Lab: Full Core Workflow with EC2

**Module:** 1 | **Lesson:** 5 | **Time:** 45–60 minutes | **Cost:** ≈ $0 with Free Tier credits

## Goal

Run the complete Terraform workflow against a real EC2 instance. Instead of hardcoding an AMI ID, you will use `data "aws_ami"` to find the latest Amazon Linux 2023 image, then create a security group and instance.

This is the runnable version of Module 1, Exercise 5.

## What you will learn

- How a data source feeds a resource argument
- How to create a least-privilege security group
- The difference between `terraform plan` and `terraform apply`
- How to verify and destroy an instance before it costs money

## Before you start

- Complete [m01-first-resource](../m01-first-resource/)
- Terraform 1.11+ and AWS credentials configured
- A budget alarm set

## Files

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform and provider constraints |
| `main.tf` | AMI data source, security group, EC2 instance |
| `variables.tf` | Region and instance type |
| `outputs.tf` | Instance and AMI details |
| `terraform.tfvars.example` | Optional values |

## Run it

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Then inspect what Terraform recorded:

```bash
terraform state list
terraform show
terraform output
```

## Expected output

The plan should start with a data source read, then show two resources to add:

```text
data.aws_ami.amazon_linux: Reading...
data.aws_ami.amazon_linux: Read complete after 1s [id=ami-...]

Terraform will perform the following actions:

  # aws_instance.this will be created
  + resource "aws_instance" "this" {
      + ami                    = "ami-..."
      + instance_type          = "t3.micro"
      ...
    }

  # aws_security_group.instance will be created
  + resource "aws_security_group" "instance" { ... }

Plan: 2 to add, 0 to change, 0 to destroy.
```

After apply:

```text
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

ami_id                      = "ami-..."
ami_name                    = "al2023-ami-2023...-x86_64"
instance_availability_zone  = "us-east-1a"
instance_id                 = "i-..."
instance_public_ip          = "203.0.113.10"
```

The `Plan:` line counts real resource changes only. A data source read is not a change, so a clean second plan should report no changes.

## Break it

1. Change `instance_type` to `t3.small` and run `terraform plan`. Terraform replaces the instance because instance type is immutable for this resource. (In newer providers it may stop/start; check the plan.)
2. Change the `Name` tag in `main.tf`. Terraform updates the tag in place without replacing the instance.
3. Remove the security group from `vpc_security_group_ids` and predict the plan. Revert before applying.
4. Comment out the `owners` argument in the AMI data source. Provider 6.x should fail because `most_recent = true` now requires an owner or identifying filter.

## Cleanup

```bash
terraform destroy
terraform state list   # should print nothing
```

Confirm in the EC2 console that the instance is **terminated** and the security group is gone.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `No AMI found` | Check the region and the name filter; Amazon Linux 2023 may not be available in every region |
| `VcpuLimitExceeded` | Request a quota increase or use a different region |
| `InvalidAMIID.NotFound` | The AMI data source returned a stale ID; rerun `terraform apply` |
| Instance still running after destroy | Check the console and terminate manually, then remove it from state with `terraform state rm` only if you are certain |

## Next

Complete the [Module 1 exercises](../../01-foundations/exercises.md), then move to [Module 2 labs](../m02-variables-meta/).
