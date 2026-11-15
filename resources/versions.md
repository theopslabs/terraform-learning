# Supported Versions & Upgrade Policy

This course is tested against the versions below. Terraform and providers move quickly, so treat this page as the source of truth and update the **Last verified** date whenever the labs are re-tested.

**Last verified:** 2026-11-15

## Tested matrix

| Component | Tested version | Course requirement |
|-----------|----------------|--------------------|
| Terraform CLI | **1.17.2** | `>= 1.11.0, < 2.0.0` |
| HashiCorp AWS provider | **6.73.0** | `~> 6.0` in lesson snippets |
| AWS CLI | v2 (current) | v2 recommended |
| Go (optional, Terratest) | 1.23+ | Only needed for the optional Terratest appendix |

## Why Terraform 1.11 is the minimum

The course uses language and CLI features that were added over several releases:

| Feature | Minimum Terraform |
|---------|-------------------|
| `terraform test` | 1.6 |
| `mock_provider` in tests | 1.7 |
| `override_resource` / `override_data` | 1.9 |
| S3 native state locking (`use_lockfile`) | 1.10 |
| Ephemeral resources | 1.10 |
| Write-only arguments (`password_wo`) | 1.11 |

Requiring 1.11 keeps every lab runnable without version-specific caveats. The labs are verified on 1.17.2, the current stable release at the time of writing.

## Installing a specific version

Version managers are the easiest way to match the course:

```bash
# mise (recommended if you already use it)
mise use -g terraform@1.17.2

# tfenv
tfenv install 1.17.2
tfenv use 1.17.2

# tenv
tenv tf install 1.17.2
tenv tf use 1.17.2
```

Or install manually from the [official downloads page](https://developer.hashicorp.com/terraform/install). Always verify:

```bash
terraform version
```

## Version constraints used in this course

Lesson snippets use a readable constraint:

```hcl
terraform {
  required_version = ">= 1.11.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

Runnable labs commit a `.terraform.lock.hcl` file so every learner gets the same provider build. **Commit lock files for root modules.** Do not commit lock files for reusable child modules unless your team has a reason to pin them.

## Upgrading the course

When a new Terraform or AWS provider release lands:

1. Read the upgrade guide (for AWS provider majors, see the [v6 upgrade guide](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-6-upgrade)).
2. Update the tested version in this file and in `.github/workflows/course-ci.yml`.
3. Run `terraform init -upgrade` in each lab, then `terraform fmt -check -recursive`, `terraform validate`, and `terraform test` where present.
4. Apply and destroy at least the free labs in a sandbox account.
5. Update the **Last verified** date.

## AWS provider 6.x notes

The course examples are written for AWS provider 6.x. These are the changes most likely to affect learners coming from older tutorials:

| Change | What to do |
|--------|------------|
| `data "aws_ami"` with `most_recent = true` now requires `owners` or an identifying filter | Always set `owners = ["amazon"]` (or the correct owner) |
| `aws_eip.vpc` was removed | Use `domain = "vpc"` |
| `aws_instance.user_data` is stored in plaintext and no longer hashed | Never put secrets in `user_data`; use `user_data_base64` only for pre-encoded data |
| `aws_s3_bucket.region` now means enhanced region support | Use the `bucket_region` attribute to read a bucket's region |
| Enhanced region support adds a `region` argument to many resources | Prefer it over duplicate provider configurations for simple cross-region resources |

## Free Tier note

AWS changed the Free Tier for accounts created on or after **15 July 2025**. New accounts receive up to **$200 in credits** and a **6-month free plan** rather than the traditional 12-month allowance. Lessons that say "12 months" refer to older accounts; always check the [current Free Tier page](https://aws.amazon.com/free/) and set an AWS Budget before running paid labs.

## Related

- [Terraform install guide](https://developer.hashicorp.com/terraform/install)
- [AWS provider releases](https://github.com/hashicorp/terraform-provider-aws/releases)
- [Course labs](../labs/README.md)
