# Lab: Variables, Validation, and Meta-Arguments

**Module:** 2 | **Lessons:** 2 and 5 | **Time:** 45–60 minutes | **Cost:** $0

## Goal

Build a small configuration that writes application settings to AWS Systems Manager Parameter Store. Along the way, practice variable validation, locals, `for_each`, `count`, and `depends_on` without creating paid infrastructure.

## What you will learn

- When to use `count` versus `for_each`
- How variable validation fails before Terraform calls AWS
- How `locals` keep tags and paths consistent
- How `depends_on` expresses a dependency that is not visible in an argument

## Before you start

- Terraform 1.11+ and AWS credentials configured
- No paid resources are created, but your user needs `ssm:PutParameter` and `ssm:DeleteParameter`

## Files

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform and provider constraints |
| `main.tf` | SSM parameters (`for_each`) and logical replicas (`count`) |
| `variables.tf` | Inputs with validation rules |
| `outputs.tf` | Parameter names, replica IDs, summary |

## Run it

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Then inspect the graph and state:

```bash
terraform state list
terraform graph | head -40
terraform output
```

## Expected output

```text
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

parameter_names = [
  "/terraform-learning/dev/feature_flag",
  "/terraform-learning/dev/log_level",
  "/terraform-learning/dev/page_size",
]
replica_ids = [
  "0f1e2d3c...",
  "4a5b6c7d...",
]
summary = {
  "environment" = "dev"
  "parameters"  = 3
  "replicas"    = 2
}
```

## Break it

1. Set `replica_count = 5` and run `terraform plan`. The validation rule should reject it before any AWS call.
2. Change `environment` to `"staging"`. Terraform creates a new set of parameters at a new path and removes the old ones.
3. Add a key to `app_config`. Only that one parameter is added thanks to `for_each`; the others are untouched.
4. Switch `replica_count` from `2` to `1`. Only the second `terraform_data` instance is removed, demonstrating stable `count` indexes.
5. Remove `depends_on` and inspect the graph. The dependency may disappear, even though the `terraform_data` input still references a string path (not the resource).

## Why `for_each` for parameters?

`for_each` keys resources by map key, so adding or removing one entry does not renumber the others. `count` indexes by position, so removing the first item shifts every later index. Use `count` for identical copies and `for_each` for named items.

## Cleanup

```bash
terraform destroy
terraform state list   # should print nothing
```

SSM standard parameters are free, but always destroy to keep the account clean.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Invalid value for variable` | Read the validation message; it tells you the accepted range or values |
| `ParameterAlreadyExists` | Another lab or run used the same path; change `project_name` |
| `AccessDenied` | Add `ssm:PutParameter`, `ssm:GetParameter`, and `ssm:DeleteParameter` permissions |
| `terraform_data` not found | It is built in since Terraform 1.4; upgrade Terraform |

## Next

Continue to [m02-import-refactor](../m02-import-refactor/) to bring existing infrastructure under Terraform.
