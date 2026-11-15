# Lab: Build a VPC

**Module:** 4 | **Lesson:** 1 | **Time:** 60–90 minutes | **Cost:** $0 without NAT, ~$0.045/hour plus data with NAT

## Goal

Build a two-AZ VPC with public and private subnets, an internet gateway, route tables, a web security group, and an optional NAT Gateway. This is the network foundation for the ALB, RDS, and capstone labs.

## What you will learn

- How CIDR blocks map to subnets with `cidrsubnet`
- Why public subnets need an internet gateway and a default route
- Why private subnets need a NAT Gateway for outbound traffic
- How to keep paid resources optional with `count`

## Before you start

- Complete Modules 1–3 or be comfortable with variables, modules, and state
- Terraform 1.11+ and AWS credentials configured
- A budget alarm set if you enable NAT

## Files

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform and provider constraints |
| `main.tf` | VPC, subnets, gateways, routes, security group |
| `variables.tf` | CIDR, AZ count, NAT toggle |
| `outputs.tf` | IDs used by later labs |
| `terraform.tfvars.example` | Optional values |

## Run it without NAT (free)

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Confirm the plan has **no** NAT Gateway or Elastic IP:

```text
Plan: 13 to add, 0 to change, 0 to destroy.
```

The exact count grows with `az_count`. With the default of 2 you get:

- 1 VPC
- 1 internet gateway
- 2 public subnets + 2 private subnets
- 1 public route table + 1 private route table
- 4 route table associations
- 1 security group

## Run it with NAT (paid)

```bash
terraform apply -var="enable_nat_gateway=true"
```

This adds one Elastic IP, one NAT Gateway, and a default route for the private route table. **Destroy it as soon as you finish testing.** NAT Gateways are not covered by the old 12-month Free Tier.

## Expected output

```text
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:

availability_zones     = ["us-east-1a", "us-east-1b"]
nat_gateway_public_ip  = null
private_subnet_ids     = ["subnet-...", "subnet-..."]
public_subnet_ids      = ["subnet-...", "subnet-..."]
vpc_cidr               = "10.0.0.0/16"
vpc_id                 = "vpc-..."
web_security_group_id  = "sg-..."
```

## Break it

1. Set `az_count = 3`. Terraform adds one public subnet, one private subnet, and two associations. Confirm the CIDRs are non-overlapping.
2. Change `vpc_cidr` to `10.1.0.0/16`. Terraform replaces the VPC and every subnet, because CIDR blocks are immutable. Do this only in a sandbox.
3. Enable NAT, then disable it. Terraform destroys the NAT Gateway, Elastic IP, and private default route, but keeps the private route table.
4. Add an inbound rule to `aws_security_group.web` for port 443 and inspect the plan. Security group rules update in place.

## Cost and cleanup

```bash
# If you enabled NAT, disable it first
terraform apply -var="enable_nat_gateway=false"

terraform destroy
terraform state list   # should print nothing
```

Check the VPC console for leftover NAT Gateways and Elastic IPs. An unattached Elastic IP can still incur charges.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `InvalidSubnet.Conflict` | The CIDRs overlap; keep public and private ranges distinct |
| `InsufficientFreeAddressesInSubnet` | Change the VPC CIDR or subnet new bits |
| NAT Gateway stuck deleting | Wait a few minutes; NAT deletion is asynchronous |
| `UnauthorizedOperation` | Your user needs VPC, EC2, and Elastic IP permissions |

## Next

Use this network in [m04-alb-asg](../m04-alb-asg/) and [m04-rds](../m04-rds/), or jump to the [capstone](../../capstone/).
