# Lab: CI/CD with GitHub Actions

**Module:** 5 | **Lesson:** 3 | **Time:** 60–90 minutes | **Cost:** $0 until the pipeline applies resources

## Goal

Wire Terraform into GitHub Actions using OIDC instead of long-lived AWS keys. The pipeline plans on pull requests, uploads the plan artifact, and applies that **exact plan** after approval on `main`.

## What you will learn

- Why OIDC is safer than storing access keys in GitHub secrets
- How to keep the plan and apply in separate jobs with an approval gate
- Why applying a saved plan is safer than re-planning during deploy
- How remote state and native locking fit into CI

## Before you start

- A GitHub repository containing this lab
- AWS permissions to create an OIDC provider, IAM role, S3 state bucket, and IAM policy
- Terraform 1.11+ locally for validation
- A budget alarm set

## Files

| File | Purpose |
|------|---------|
| `infra/` | Small S3 configuration managed by the pipeline |
| `ci/terraform.yml` | Workflow to copy into `.github/workflows/` |
| `ci/oidc-trust-policy.json` | Trust policy template for the GitHub OIDC role |

## Part 1: Create the GitHub OIDC provider and role

1. In the AWS console, open **IAM → Identity providers → Add provider**.
2. Choose **OpenID Connect**.
3. Provider URL: `https://token.actions.githubusercontent.com`
4. Audience: `sts.amazonaws.com`
5. Create the provider.

Create an IAM role with the trust policy from `ci/oidc-trust-policy.json`. Replace:

- `ACCOUNT_ID` with your AWS account ID
- `ORG/REPO` with your GitHub owner and repository

For tighter security, remove the `pull_request` subject and use only the `main` branch subject for the apply role. Use a separate, read-only role for plans if your organization requires it.

Attach a least-privilege policy for the resources in `infra/` (S3 bucket creation and management). Do not attach `AdministratorAccess`.

## Part 2: Create the state bucket

The pipeline needs remote state. Create a bucket with versioning, encryption, and public access blocked. You can reuse the pattern from [m03-remote-backend](../../m03-remote-backend/bootstrap/), or create one manually.

## Part 3: Configure GitHub variables

In **Settings → Secrets and variables → Actions → Variables**, add:

| Variable | Example | Purpose |
|----------|---------|---------|
| `AWS_ROLE_ARN` | `arn:aws:iam::123456789012:role/GitHubActionsTerraform` | Role assumed via OIDC |
| `AWS_REGION` | `us-east-1` | Region for the provider and backend |
| `TF_STATE_BUCKET` | `my-terraform-state-bucket` | Remote state bucket |
| `TF_STATE_KEY` | `labs/m05-ci/terraform.tfstate` | State object key |

No `AWS_ACCESS_KEY_ID` or `AWS_SECRET_ACCESS_KEY` is needed.

## Part 4: Install the workflow and open a pull request

```bash
mkdir -p .github/workflows
cp ci/terraform.yml .github/workflows/terraform.yml
git checkout -b feature/ci-lab
git add .github/workflows/terraform.yml labs/m05-ci/infra
git commit -m "Add Terraform CI pipeline"
git push -u origin feature/ci-lab
```

> The workflow sets `TF_WORKING_DIR` to `labs/m05-ci/infra`, matching this repository. If you copy the lab into the root of your own repository, change that value to `infra`.

Open a pull request. The `plan` job should:

1. Assume the role via OIDC
2. Run `fmt`, `init`, `validate`, and `plan`
3. Upload `tfplan`
4. Comment the plan on the PR

The `apply` job is skipped on pull requests. Merge to `main` to trigger it. If you configured the `production` environment with required reviewers, the job waits for approval.

## Expected output

```text
Run terraform plan -input=false -no-color -out=tfplan

Terraform will perform the following actions:

  # aws_s3_bucket.this will be created
  + resource "aws_s3_bucket" "this" { ... }

Plan: 3 to add, 0 to change, 0 to destroy.

...
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.
```

## Break it

1. Remove `id-token: write` from `permissions`. The OIDC step fails with `Not authorized to perform sts:AssumeRoleWithWebIdentity`.
2. Change the trust policy subject to a different repository. The assume-role call fails.
3. Delete the `Download plan artifact` step. `terraform apply tfplan` fails because the file is missing. This proves the apply is using the reviewed plan.
4. Add `-auto-approve` to the apply command and remove the `production` environment. The approval gate disappears; revert immediately.
5. Introduce a formatting error (`terraform fmt` locally) and push. The plan job fails at `fmt -check`.

## Cost and cleanup

The pipeline itself is free on GitHub-hosted runners for public repositories (within limits). The S3 bucket and state storage cost pennies. To clean up:

```bash
# From a local checkout with the same backend
cd labs/m05-ci/infra
terraform init -backend-config="bucket=..." -backend-config="key=..." -backend-config="region=..."
terraform destroy
```

Delete the state bucket separately after confirming it is empty.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Credentials could not be loaded` | Check `AWS_ROLE_ARN`, the OIDC provider audience, and the trust policy |
| `AccessDenied` on S3 state | The role needs `s3:GetObject`, `PutObject`, `DeleteObject`, and `ListBucket` on the state bucket |
| `Backend configuration changed` | Confirm the workflow's `-backend-config` values match the state bucket |
| Plan comment is empty | Check the `plan` step `id` and the `PLAN_STDOUT` environment variable |
| Apply runs on a PR | Check the `if:` condition on the apply job |

## Production notes

- Split plan and apply into separate IAM roles with different permissions.
- Require reviewers on the `production` GitHub environment.
- Restrict the trust policy to `ref:refs/heads/main` for apply.
- Set artifact retention carefully; plan files can contain sensitive values.
- Add `tflint`, `checkov`, and `terraform test` steps before plan.
- Use branch protection so the plan job must pass before merge.

## Next

Continue to the [capstone](../../capstone/) to apply this pipeline to a full three-tier stack.
