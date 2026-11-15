# Hands-On Labs

These labs turn the lessons into runnable configurations. Each lab is a complete reference implementation: read the lesson, run the lab, then use the "break it" challenge to rebuild part of it yourself.

> **New to the course?** Start with [Module 1: Foundations](../01-foundations/README.md), then run the labs in order.

## Before you start

1. Install Terraform **1.11 or newer** (tested on 1.17.2) — see [Supported Versions](../resources/versions.md).
2. Configure AWS credentials: `aws sts get-caller-identity` should succeed.
3. Set an AWS Budget before running any paid lab. See [Costs and cleanup](#costs-and-cleanup).
4. Work from the lab directory, not the repository root:

   ```bash
   cd labs/m01-first-resource
   terraform init
   terraform plan
   terraform apply
   ```

## Lab index

| Lab | Module | What you build | AWS cost |
|-----|--------|----------------|----------|
| [m01-first-resource](./m01-first-resource/) | 1 | S3 bucket with tags and outputs | ≈ $0 |
| [m01-full-workflow](./m01-full-workflow/) | 1 | EC2 instance discovered through a data source | ≈ $0 (credits) |
| [m02-variables-meta](./m02-variables-meta/) | 2 | Variables, validation, locals, `count` / `for_each` | $0 |
| [m02-import-refactor](./m02-import-refactor/) | 2 | Import, `moved`, and `removed` blocks | $0 |
| [m03-local-module](./m03-local-module/) | 3 | Reusable S3 module used by two environments | ≈ $0 |
| [m03-remote-backend](./m03-remote-backend/) | 3 | Hardened S3 backend with native locking | < $0.10/day |
| [m04-vpc](./m04-vpc/) | 4 | VPC, public/private subnets, IGW, optional NAT | $0 without NAT |
| [m04-alb-asg](./m04-alb-asg/) | 4 | ALB, launch template, Auto Scaling Group | ≈ $0.05/hour |
| [m04-rds](./m04-rds/) | 4 | RDS MySQL with generated credentials | ≈ $0.03/hour |
| [m05-terraform-test](./m05-terraform-test/) | 5 | Native `terraform test` with mocked providers | $0 |
| [m05-secrets](./m05-secrets/) | 5 | Secrets Manager, SSM, write-only arguments | ≈ $0.40/secret/month |
| [m05-ci](./m05-ci/) | 5 | GitHub Actions plan/apply with OIDC | $0 until apply |

The [capstone](../capstone/) combines the paid building blocks into a full three-tier stack (~$3–5/day). Do not start it until you have completed the free labs.

## Anatomy of a lab

```text
m01-first-resource/
├── README.md                 # goal, cost, steps, expected output, teardown
├── versions.tf               # Terraform + provider constraints
├── main.tf                   # resources
├── variables.tf              # inputs
├── outputs.tf                # useful values
├── terraform.tfvars.example  # copy to terraform.tfvars if needed
└── .terraform.lock.hcl       # committed provider lock file
```

Every lab README includes:

- **Goal** and the lesson it supports
- **Time** and **cost**
- **Commands** to run
- **Expected output** to compare against
- **Break it** challenge — change something and predict the plan
- **Cleanup** — destroy and verify nothing is left

## Costs and cleanup

- AWS resources cost money even when you are learning. Set a budget alarm first:
  [AWS Budgets](https://console.aws.amazon.com/billing/home#/budgets).
- NAT Gateways, ALBs, and RDS instances bill hourly. Destroy them when you finish a session.
- Run `terraform destroy` from the same directory, then confirm with:

  ```bash
  terraform state list
  ```

  An empty state list means Terraform is no longer managing resources. Check the AWS console for anything created outside Terraform (for example, a manually created bucket used in the import lab).

## Validate without spending money

Most labs can be checked without AWS credentials or applying changes:

```bash
terraform init -backend=false
terraform validate
```

Labs with tests can also run:

```bash
terraform test
```

The repository CI runs these checks on every pull request.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `No valid credential sources found` | AWS CLI not configured | Run `aws configure` or set `AWS_PROFILE` |
| `Error acquiring the state lock` | Another run crashed or is active | Wait, then `terraform force-unlock <LOCK_ID>` if you are certain no run is active |
| `BucketAlreadyExists` | S3 names are global | Change the `random_id` suffix or bucket prefix |
| `Unsupported argument` | Provider 6.x removed or renamed an argument | Check [versions.md](../resources/versions.md) and the provider upgrade guide |
| Plan wants to replace everything | State/backend mismatch | Confirm you are in the right directory and backend |

## Contributing a lab

Use [resources/lab-template](../resources/lab-template/) as the starting point. Keep labs:

- Self-contained, with no dependency on files outside their directory
- Formatted (`terraform fmt -recursive`)
- Free by default; clearly marked if they cost money
- Destructible in one command
