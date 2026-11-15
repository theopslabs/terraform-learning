# Lab: Secrets with Write-Only Arguments

**Module:** 5 | **Lesson:** 4 | **Time:** 30–45 minutes | **Cost:** ≈ $0.40/secret/month

## Goal

Generate a database password at apply time and store it in AWS Secrets Manager and SSM Parameter Store **without writing the plaintext to Terraform state**. This lab uses ephemeral resources and write-only arguments, both available in Terraform 1.11+.

## What you will learn

- Why `random_password` alone still leaves secrets in state
- How `ephemeral "random_password"` differs from a managed resource
- How `secret_string_wo` and `value_wo` keep values out of state
- How to rotate a write-only value by bumping its version

## Before you start

- Terraform 1.11+ (`terraform version`)
- AWS credentials configured
- Permission to create Secrets Manager secrets and SSM parameters
- A budget alarm set — Secrets Manager charges per secret per month

## Files

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform and provider constraints |
| `main.tf` | Ephemeral password, secret, secret version, SSM parameter |
| `variables.tf` | Names for the secret and parameter |
| `outputs.tf` | ARNs and names only, never the password |

## Run it

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

## Verify the password is not in state

```bash
terraform show | grep -i "password" || echo "No plaintext password in state"
terraform show -json | grep -i "$(terraform output -raw secret_name)" | head
```

You will see the resource metadata, but not the generated value. To read the secret intentionally, use the AWS CLI:

```bash
aws secretsmanager get-secret-value \
  --secret-id "$(terraform output -raw secret_arn)" \
  --query SecretString --output text

aws ssm get-parameter \
  --name "$(terraform output -raw parameter_name)" \
  --with-decryption \
  --query Parameter.Value --output text
```

Both commands return the same generated password.

## Expected output

```text
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

parameter_arn  = "arn:aws:ssm:us-east-1:123456789012:parameter/app/db/password"
parameter_name = "/app/db/password"
secret_arn     = "arn:aws:secretsmanager:us-east-1:123456789012:secret:app/db/password-abc123"
secret_name    = "app/db/password"
```

## Rotate the password

1. Change `secret_string_wo_version` and `value_wo_version` from `1` to `2`.
2. Run `terraform plan`. Terraform proposes a new secret version and parameter update.
3. Run `terraform apply`.
4. Read the secret again; it has a new value.

The version numbers are the trigger. Terraform cannot compare write-only values, so you must bump the version yourself.

## Break it

1. Replace `secret_string_wo` with `secret_string` and apply. Then run `terraform show` and search for the password. This demonstrates the problem write-only arguments solve. Revert and destroy.
2. Replace `ephemeral "random_password"` with `resource "random_password"`. Apply and inspect state. The generated password is now stored in state, even though the secret version uses a write-only argument.
3. Remove `recovery_window_in_days = 0`. Destroying the secret now schedules deletion after the default recovery window; the name remains reserved.
4. Add a second secret that stores a JSON document with `username` and `password` using `jsonencode`. Check whether the password appears in the plan before apply.

## Cost and cleanup

```bash
terraform destroy
terraform state list   # should print nothing
```

`recovery_window_in_days = 0` makes cleanup immediate. SSM standard parameters are free; Secrets Manager charges about $0.40 per secret per month, prorated.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Write-only attribute is not supported` | Upgrade Terraform to 1.11+ and the AWS provider to 6.x |
| `secret_string_wo_version` required | Set it whenever you use `secret_string_wo` |
| `AlreadyExistsException` | A secret with that name exists; change `secret_name` or delete the old one |
| `AccessDenied` | Add `secretsmanager:CreateSecret`, `PutSecretValue`, and `ssm:PutParameter` permissions |
| Secret still listed after destroy | It is in the recovery window; use `aws secretsmanager delete-secret --force-delete-without-recovery` if needed |

## Production notes

- Prefer short-lived credentials or IAM roles over static passwords.
- Use RDS-managed master passwords (`manage_master_user_password = true`) for databases.
- Enable automatic rotation with a Lambda rotation function where supported.
- Restrict who can call `secretsmanager:GetSecretValue`.
- Never output secrets, even marked `sensitive`; outputs are still stored in state.

## Next

Continue to [m05-ci](../m05-ci/) or review [Secrets Management](../../05-advanced/04-secrets-management/).
