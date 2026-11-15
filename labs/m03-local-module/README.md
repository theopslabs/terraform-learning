# Lab: Build and Use a Local Module

**Module:** 3 | **Lesson:** 1 | **Time:** 45–60 minutes | **Cost:** ≈ $0

## Goal

Extract the S3 bucket pattern from Module 1 into a reusable local module, then call it twice to create separate dev and staging buckets.

## What you will learn

- The difference between a root module and a child module
- How module inputs and outputs work
- Why `source` paths are relative to the root module
- How module boundaries improve consistency

## Before you start

- Complete [m01-first-resource](../m01-first-resource/)
- Terraform 1.11+ and AWS credentials configured

## Files

| Path | Purpose |
|------|---------|
| `main.tf` | Calls the module twice |
| `variables.tf` | Root inputs |
| `outputs.tf` | Exposes module outputs |
| `modules/s3_bucket/` | Reusable bucket module |
| `modules/s3_bucket/README.md` | Module interface documentation |

## Run it

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Inspect the module addresses:

```bash
terraform state list
terraform output
```

## Expected output

```text
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:

bucket_arns = {
  "dev" = "arn:aws:s3:::terraform-learning-dev-1a2b3c4d"
  "staging" = "arn:aws:s3:::terraform-learning-staging-5e6f7a8b"
}
dev_bucket_name = "terraform-learning-dev-1a2b3c4d"
staging_bucket_name = "terraform-learning-staging-5e6f7a8b"
```

State addresses look like `module.dev_bucket.aws_s3_bucket.this`.

## Break it

1. Add a third call for `prod`. Predict how many new resources Terraform adds. (Three: bucket, versioning, public access block.)
2. Pass `extra_tags = { CostCenter = "training" }` to the dev module only. Confirm the tag appears only on that bucket.
3. Move the module source to `../shared/s3_bucket` and update the `source` argument. Terraform needs `terraform init` again because module sources are resolved during init.
4. Try an invalid `environment` value. The module's validation should reject it, showing that modules enforce their own contracts.

## Module design notes

- The module owns naming and security defaults; callers only choose the prefix and environment.
- Inputs are validated inside the module, so every caller gets the same guardrails.
- Outputs expose only what callers need, not the entire resource object.
- A module without a `provider` block inherits the caller's provider configuration.

## Cleanup

```bash
terraform destroy
terraform state list   # should print nothing
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Module not installed` | Run `terraform init` after changing a module source |
| `Unsupported argument` | Check the module's `variables.tf`; callers cannot pass undeclared inputs |
| Duplicate bucket names | The module adds a random suffix; confirm `random_id` is declared in the module |
| Output is null | Confirm the module declares the output and the caller references `module.<name>.<output>` |

## Next

Continue to [m03-remote-backend](../m03-remote-backend/) to store state safely for a team.
