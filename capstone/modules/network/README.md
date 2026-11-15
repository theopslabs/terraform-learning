# Network Module

Creates a two- or three-AZ VPC with public and private subnets, an internet gateway, a single NAT Gateway, and security groups for the ALB, application tier, and database tier.

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_name` | `string` | required | Prefix for names and tags |
| `vpc_cidr` | `string` | `10.0.0.0/16` | VPC CIDR |
| `az_count` | `number` | `2` | Number of AZs (2–3) |
| `enable_nat_gateway` | `bool` | `true` | Create a NAT Gateway (paid) |
| `tags` | `map(string)` | `{}` | Extra tags |

## Outputs

| Name | Description |
|------|-------------|
| `vpc_id` | VPC ID |
| `public_subnet_ids` | Public subnet IDs |
| `private_subnet_ids` | Private subnet IDs |
| `alb_security_group_id` | ALB security group |
| `app_security_group_id` | Application security group |
| `db_security_group_id` | Database security group |
| `nat_gateway_public_ip` | NAT public IP, or `null` |

## Notes

- A single NAT Gateway is a cost/availability trade-off. Production stacks often use one per AZ.
- The ALB security group allows HTTP from anywhere. Add HTTPS and restrict ingress for real workloads.
