# Lab Title

**Module:** X | **Lesson:** Y | **Time:** 30–45 minutes | **Cost:** $0

## Goal

One paragraph describing what the learner will build and why it matters.

## What you will learn

- Concept one
- Concept two

## Before you start

- Terraform 1.11+ installed
- AWS credentials configured (`aws sts get-caller-identity`)
- A budget alarm set if this lab creates paid resources

## Files

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform and provider constraints |
| `main.tf` | Resources |
| `variables.tf` | Inputs |
| `outputs.tf` | Outputs |

## Run it

```bash
terraform init
terraform plan
terraform apply
```

## Expected output

```text
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

bucket_name = "example-abc123"
```

## Break it

Change one value and predict the plan before running it. For example, change a tag and confirm the resource is updated in place rather than replaced.

## Cleanup

```bash
terraform destroy
terraform state list   # should print nothing
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| ... | ... |

## Next

Continue to the next lesson or lab.
