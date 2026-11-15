# Lab: Remote State with S3 Native Locking

**Module:** 3 | **Lesson:** 5 | **Time:** 45–60 minutes | **Cost:** < $0.10/day

## Goal

Create a hardened S3 bucket for Terraform state, then point a second configuration at it using partial backend configuration. Use Terraform 1.10+ native S3 locking (`use_lockfile`) instead of a DynamoDB lock table.

## What you will learn

- Why local state does not work for teams
- How partial backend configuration keeps environment values out of code
- How S3 versioning, encryption, and public access blocks protect state
- How `use_lockfile` replaces DynamoDB for most new projects

## Before you start

- Terraform 1.11+ and AWS credentials configured
- Permission to create S3 buckets and objects
- A budget alarm set (cost is negligible, but good habit)

## Part 1: Bootstrap the state bucket

```bash
cd bootstrap
terraform init
terraform plan
terraform apply
```

Save the outputs:

```bash
terraform output
```

Note `state_bucket_name` and `backend_config_example`.

## Part 2: Configure the app backend

```bash
cd ../app
cp backend.hcl.example backend.hcl
```

Edit `backend.hcl` and replace `bucket` with your state bucket name. Then initialize:

```bash
terraform init -backend-config=backend.hcl
```

Terraform stores state at `labs/remote-backend/terraform.tfstate` inside the bucket. Apply the demo:

```bash
terraform plan
terraform apply
```

Verify in the S3 console:

- The state object exists under the key
- Versioning is enabled on the bucket
- Default encryption is on
- All public access is blocked

Run a second plan and confirm the lock file appears and disappears during the operation.

## Expected output

```text
Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

...

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

demo_bucket_name = "terraform-learning-remote-state-demo-1a2b3c4d"
```

## Migrating existing local state

If you already applied a configuration locally, adding a backend and running `terraform init` prompts you to migrate. In automation, use:

```bash
terraform init -migrate-state -backend-config=backend.hcl
```

Review the diff carefully. Migration copies state; it does not change infrastructure.

## Break it

1. Remove `use_lockfile = true` from `backend.hcl` and run `terraform init -reconfigure`. Without a lock, two simultaneous applies could corrupt state. Re-enable it.
2. Add `key = "labs/remote-backend/other.tfstate"` and run `terraform init -reconfigure`. The plan now looks like everything is new because it is reading an empty state. Switch back with `-reconfigure`.
3. Add `encrypt = false` (not recommended) and inspect the backend configuration warning.

## Cleanup

Destroy the app first, then the bootstrap bucket:

```bash
cd app
terraform destroy

cd ../bootstrap
terraform destroy
```

Do not delete the state bucket before the app. The app's destroy needs the remote state.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Error: Failed to get existing workspaces` | The bucket name or region in `backend.hcl` is wrong |
| `AccessDenied` on the state object | The caller needs `s3:GetObject`, `PutObject`, `DeleteObject`, and `ListBucket` |
| `Backend configuration changed` | Run `terraform init -reconfigure` |
| Lock stuck after a crash | With `use_lockfile`, remove the `.tflock` object only after confirming no run is active |
| `DynamoDB table not found` | You copied an old backend config; remove `dynamodb_table` and use `use_lockfile` |

## Next

Continue to [m04-vpc](../m04-vpc/) to build networking from scratch.
