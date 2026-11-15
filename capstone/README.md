# Capstone: Three-Tier AWS Application

**Level:** Professional | **Time:** 6–10 hours | **Cost:** ≈ $3–5/day while running

## What you will build

A production-style three-tier stack:

- **Network:** VPC across two AZs, public and private subnets, internet gateway, single NAT Gateway, route tables, and three security groups
- **Compute:** Application Load Balancer in public subnets, Auto Scaling Group in private subnets, launch template with a simple web server
- **Data:** Private MySQL RDS instance with managed credentials and encrypted storage
- **State:** Hardened S3 backend with native locking
- **CI:** GitHub Actions plan/apply with OIDC and a saved plan artifact

```text
Internet
   │
   ▼
 ALB (public subnets, port 80)
   │
   ▼
 ASG instances (private subnets, port 80)
   │
   ▼
 RDS MySQL (private subnets, port 3306)
```

## Milestones

1. **Bootstrap** the remote state bucket and verify the backend.
2. **Network** — apply the VPC and inspect the subnets and routes.
3. **Compute** — deploy the ALB and ASG; confirm the page responds.
4. **Data** — add RDS; confirm it is not publicly accessible.
5. **CI** — install the workflow and review a plan on a pull request.
6. **Teardown** — destroy everything and verify the account is clean.

## Cost warning

This capstone is **not free**. A single NAT Gateway, ALB, and RDS instance bill hourly even when idle. Estimate roughly $3–5/day depending on region and data transfer. New AWS accounts may have up to $200 in credits, but do not rely on them.

Before starting:

1. Create an [AWS Budget](https://console.aws.amazon.com/billing/home#/budgets) with an alert at $10.
2. Tag every resource with `Project` and `Environment`.
3. Plan to destroy the stack at the end of each session; the NAT Gateway and RDS instance are the biggest idle costs.

## Repository layout

```text
capstone/
├── bootstrap/              # State bucket
├── modules/
│   ├── network/            # VPC, subnets, NAT, security groups
│   ├── compute/            # ALB, launch template, ASG
│   └── data/               # RDS and subnet group
├── environments/dev/       # Root configuration for the dev environment
├── ci/terraform.yml        # GitHub Actions workflow to copy
├── docs/architecture.md    # Design decisions and diagram
└── docs/runbook.md         # Deploy, destroy, troubleshoot
```

## Step 1: Bootstrap state

```bash
cd bootstrap
terraform init
terraform apply
terraform output
```

Copy the state bucket name and region.

## Step 2: Configure the environment

```bash
cd ../environments/dev
cp backend.hcl.example backend.hcl
cp terraform.tfvars.example terraform.tfvars
```

Edit `backend.hcl` with your state bucket. Review `terraform.tfvars` and adjust the project name, region, and capacity.

```bash
terraform init -backend-config=backend.hcl
terraform plan
```

## Step 3: Deploy in stages

You can deploy everything at once:

```bash
terraform apply
```

For learning, deploy one layer at a time by uncommenting modules in `main.tf`:

1. Network only — inspect the VPC, subnets, and routes.
2. Network + compute — open the ALB URL.
3. All three — verify the application tier can reach RDS on port 3306 (the default stack does not include an application that connects to the database; use the connectivity check in `docs/runbook.md`).

RDS provisioning takes 5–10 minutes. The ALB may return 503 until the instances pass health checks.

## Step 4: Verify

```bash
terraform output
curl "$(terraform output -raw alb_url)"
```

Check in the console:

- RDS **Publicly accessible** is **No**
- RDS **Storage encrypted** is **Yes**
- Instances are in private subnets and have no public IPs
- The ALB is the only public entry point on port 80

## Step 5: Add CI

Follow [labs/m05-ci](../../labs/m05-ci/) to create the OIDC role and state variables, then copy `ci/terraform.yml` into `.github/workflows/capstone.yml`. Update `TF_WORKING_DIR` to `capstone/environments/dev` and use the capstone state bucket.

## Step 6: Destroy

```bash
cd environments/dev
terraform destroy
```

Then destroy the bootstrap state bucket:

```bash
cd ../../bootstrap
terraform destroy
```

Verify:

```bash
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --query 'Reservations[].Instances[].InstanceId'
aws rds describe-db-instances --query 'DBInstances[].DBInstanceIdentifier'
aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerName'
```

See [docs/runbook.md](docs/runbook.md) for a complete teardown checklist.

## Rubric

| Area | What good looks like |
|------|----------------------|
| Correctness | Stack applies cleanly, ALB serves traffic, RDS is reachable only from the app tier |
| Security | Private subnets for compute and data, least-privilege security groups, encrypted storage, no hardcoded secrets |
| State | Remote backend, locking, versioning, no local state committed |
| Testing | `terraform fmt`, `validate`, and `terraform test` pass in CI |
| Operations | Budget alarm, tags, runbook, reproducible destroy |
| Documentation | Architecture decisions and trade-offs are explained |

## Extension ideas

- Add HTTPS with an ACM certificate and redirect HTTP to HTTPS.
- Replace the single NAT Gateway with one per AZ for high availability.
- Add a read replica and a Multi-AZ database.
- Serve the application through CloudFront and WAF.
- Add CloudWatch alarms for ALB 5xx rate, ASG CPU, and RDS storage.
- Replace static ASG capacity with a queue-depth or request-count scaling policy.
- Add Terragrunt or Terraform Stacks for multiple environments.

## Related

- [Architecture notes](docs/architecture.md)
- [Runbook](docs/runbook.md)
- [Capstone CI workflow](ci/terraform.yml)
- [Course version policy](../resources/versions.md)
