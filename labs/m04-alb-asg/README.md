# Lab: Application Load Balancer and Auto Scaling

**Module:** 4 | **Lesson:** 5 | **Time:** 60–90 minutes | **Cost:** ≈ $0.05/hour while running

## Goal

Deploy two or more web servers behind an Application Load Balancer (ALB) with an Auto Scaling Group (ASG). The ALB is the only public entry point; instances accept traffic only from the ALB security group.

## What you will learn

- How a launch template and ASG work together
- How target groups and health checks decide which instances receive traffic
- How to scope security groups so instances are not directly reachable
- How target tracking scales on CPU

## Before you start

- Complete [m04-vpc](../m04-vpc/) or understand security groups and subnets
- Terraform 1.11+ and AWS credentials configured
- A budget alarm set — ALB and instances bill hourly

## Files

| File | Purpose |
|------|---------|
| `versions.tf` | Terraform and provider constraints |
| `main.tf` | Default VPC lookup, security groups, ALB, ASG, scaling policy |
| `variables.tf` | Instance type and capacity |
| `outputs.tf` | ALB DNS name and ASG name |

## Run it

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

Wait 2–5 minutes for the instances to boot, install Apache, and pass health checks. Then open the URL:

```bash
terraform output -raw alb_url
curl "$(terraform output -raw alb_url)"
```

The response includes the instance hostname. Refresh a few times; with `desired_capacity = 2` you should see different hosts.

```bash
terraform apply -var="desired_capacity=2"
```

## Expected output

```text
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:

alb_dns_name           = "terraform-learning-alb-1234567890.us-east-1.elb.amazonaws.com"
alb_url                = "http://terraform-learning-alb-1234567890.us-east-1.elb.amazonaws.com"
autoscaling_group_name = "terraform-learning-asg"
target_group_arn       = "arn:aws:elasticloadbalancing:..."
```

## Break it

1. Set `desired_capacity = 2`. Terraform updates the ASG; a second instance registers with the target group.
2. Change `health_check.path` to `/missing` and apply. Targets become unhealthy and the ALB returns 503. Revert and wait for recovery.
3. Change the instance security group to allow port 80 from `0.0.0.0/0`. Run `terraform plan`, then revert. The plan shows an inline rule change. This is the misconfiguration the lab is designed to avoid.
4. Set `max_size` below `desired_capacity`. The provider or API should reject it; confirm the validation happens before or during apply.
5. Raise `target_value` in the scaling policy to 90. Scaling becomes less aggressive.

## Cost and cleanup

```bash
terraform destroy
terraform state list   # should print nothing
```

The ALB, instances, and EBS volumes bill while they exist. Confirm in the EC2 and Load Balancer consoles that everything is gone. The default VPC and its subnets are not managed by this lab and remain.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `default VPC not found` | Create a default VPC in the region or adapt the lab to use `m04-vpc` outputs |
| ALB returns 503 | Instances are still booting or failing health checks; check the target group's health status |
| `InvalidSubnet` | Pick subnets in at least two AZs |
| `CertificateNotFound` | This lab uses HTTP only; add an ACM certificate and an HTTPS listener for production |
| Instances launch but no web page | Check `/var/log/cloud-init-output.log` on an instance; `dnf` needs outbound internet access |

## Production notes

- Add an HTTPS listener with an ACM certificate and redirect HTTP to HTTPS.
- Restrict ALB ingress to known CIDRs or a WAF.
- Use private subnets for the ASG and a NAT Gateway for package installs.
- Add multi-AZ RDS and a deletion protection policy for production.

## Next

Continue to [m04-rds](../m04-rds/) or combine these pieces in the [capstone](../../capstone/).
