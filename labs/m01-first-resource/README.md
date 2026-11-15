# Lab: Your First Resource

**Module:** 1 | **Lesson:** 4–5 | **Time:** 30–45 minutes | **Cost:** ≈ $0

## Goal

Create a real, secure S3 bucket with Terraform. You will use a data source–free configuration, generate a unique name, add tags, enable versioning, and block public access. Then you will walk through the full workflow: `init`, `plan`, `apply`, and `destroy`.

This is the runnable version of Module 1, Exercise 3.

## What you will learn

- How `provider`, `resource`, and `output` blocks fit together
- Why S3 bucket names need a unique suffix
- How tags become part of your infrastructure contract
- How to verify and destroy resources safely

## Before you start

- Terraform 1.11+ installed (`terraform version`)
- AWS credentials configured (`aws sts get-caller-identity`)
- You are in a learning account with a budget alarm set

## Files

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform and provider constraints |
| `main.tf` | Bucket, versioning, and public access block |
| `variables.tf` | Inputs and validation |
| `outputs.tf` | Bucket name, ARN, and region |
| `terraform.tfvars.example` | Optional values to copy |

## Run it

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan
terraform apply
```

Type `yes` when prompted. Then inspect the outputs:

```bash
terraform output
terraform state list
```

## Expected output

```text
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

bucket_arn    = "arn:aws:s3:::tf-course-first-resource-1a2b3c4d"
bucket_name   = "tf-course-first-resource-1a2b3c4d"
bucket_region = "us-east-1"
environment   = "dev"
```

Your suffix and ARN will differ. Verify in the AWS console that:

- Versioning is **Enabled**
- Block all public access is **On**

## Break it

1. Change `environment` to `"prod"` and run `terraform plan`. Predict whether Terraform updates the bucket in place or replaces it. (It updates tags in place.)
2. Change `bucket_prefix` and run `terraform plan`. Predict what happens. (Terraform replaces the bucket because the name is immutable.)
3. Try `environment = "production"` and observe the validation error before Terraform calls AWS.

## Cleanup

```bash
terraform destroy
terraform state list   # should print nothing
```

S3 versioning keeps old object versions, but this lab never uploads objects, so the bucket deletes cleanly.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `BucketAlreadyExists` | The suffix should prevent this; rerun `terraform apply` to generate a new `random_id` |
| `AccessDenied` | Your AWS user needs `s3:CreateBucket`, `s3:PutBucketVersioning`, and related permissions |
| `Unsupported argument` | Confirm you are using AWS provider 6.x and Terraform 1.11+ |

## Next

Continue to [m01-full-workflow](../m01-full-workflow/) to use a data source and an EC2 instance.
