# Lab: Native Terraform Tests

**Module:** 5 | **Lesson:** 2 | **Time:** 30–45 minutes | **Cost:** $0

## Goal

Write and run `terraform test` files that verify your configuration logic without calling AWS. The tests use `mock_provider`, so no credentials, no resources, and no cost.

## What you will learn

- How `terraform test` discovers `.tftest.hcl` files
- How `mock_provider` replaces real API calls
- How to assert on planned values
- How to test variable validation with `expect_failures`

## Before you start

- Terraform 1.11+ (`terraform version`)
- No AWS credentials required

## Files

| Path | Purpose |
|------|---------|
| `versions.tf` | Terraform and provider constraints |
| `main.tf` | Bucket, versioning, public access block |
| `variables.tf` | Inputs with validation |
| `outputs.tf` | Bucket outputs |
| `tests/bucket.tftest.hcl` | Unit-style tests with mocked AWS |

## Run it

```bash
terraform init
terraform test
```

You should see four test runs pass:

```text
tests/bucket.tftest.hcl... in progress
  run "bucket_is_configured"... pass
  run "extra_tags_are_merged"... pass
  run "rejects_invalid_environment"... pass
  run "rejects_invalid_bucket_name"... pass
tests/bucket.tftest.hcl... tearing down
tests/bucket.tftest.hcl... pass

Success! 4 passed, 0 failed.
```

## How the tests work

- `mock_provider "aws" {}` tells Terraform to answer provider calls with generated values instead of calling AWS.
- `command = plan` evaluates the configuration without creating anything. Assertions run against planned values.
- `expect_failures = [var.environment]` asserts that a validation rule rejects the input.
- Tests run in isolated state, so they do not touch your existing `terraform.tfstate`.

## Break it

1. Change the `restrict_public_buckets` assertion to `false` and rerun. The test should fail, proving the test is actually checking behavior.
2. Add an `assert` for a tag that does not exist, such as `aws_s3_bucket.this.tags["Missing"] == "x"`. Observe the failure message.
3. Add a new variable `force_destroy` and a test that verifies it is passed to the bucket. Use `command = plan`.
4. Create `tests/integration.tftest.hcl` with `command = apply` and no mock provider. This would call AWS and cost money. Do not run it unless you intend to create and destroy the bucket. The README for the module shows the pattern.

## Optional: a real integration test

When you are ready to test against AWS, remove `mock_provider` and use:

```hcl
run "creates_and_destroys_bucket" {
  command = apply

  variables {
    bucket_name = "tf-course-integration-${plantimestamp()}"
  }

  assert {
    condition     = aws_s3_bucket.this.id != ""
    error_message = "The bucket should be created."
  }
}
```

Terraform destroys test-created resources automatically at the end of the run. Still check the console afterward.

## Cleanup

No cleanup is required for the mocked tests. `terraform test` does not create real resources.

If you ran an integration test, confirm the bucket is gone:

```bash
aws s3 ls | grep tf-course-integration || echo "clean"
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `No test files found` | Run from the lab root; tests live in `tests/*.tftest.hcl` |
| `Mock provider not found` | Upgrade to Terraform 1.7+ and run `terraform init` |
| Test reads real AWS values | Remove the mock provider only for integration tests, and expect cost |
| `plantimestamp()` not available | Use Terraform 1.8+ or pass a variable instead |

## Next

Continue to [m05-secrets](../m05-secrets/) to keep credentials out of state, or review [Testing & Validation](../../05-advanced/02-testing-validation/).
