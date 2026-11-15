# Compute Module

Deploys an Application Load Balancer in public subnets and an Auto Scaling Group in private subnets. Instances run a minimal Apache page so health checks have something to verify.

## Inputs

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `project_name` | `string` | required | Prefix for names and tags |
| `vpc_id` | `string` | required | VPC ID |
| `public_subnet_ids` | `list(string)` | required | At least two public subnets |
| `private_subnet_ids` | `list(string)` | required | At least two private subnets |
| `alb_security_group_id` | `string` | required | ALB security group |
| `app_security_group_id` | `string` | required | Instance security group |
| `instance_type` | `string` | `t3.micro` | Instance type |
| `min_size` | `number` | `1` | Minimum ASG size |
| `max_size` | `number` | `3` | Maximum ASG size |
| `desired_capacity` | `number` | `2` | Desired capacity |
| `app_port` | `number` | `80` | Application port |
| `health_check_path` | `string` | `/` | Health check path |
| `tags` | `map(string)` | `{}` | Extra tags |

## Outputs

| Name | Description |
|------|-------------|
| `alb_url` | HTTP URL of the load balancer |
| `alb_dns_name` | ALB DNS name |
| `target_group_arn` | Target group ARN |
| `autoscaling_group_name` | ASG name |

## Notes

- The ASG runs in private subnets. Instances need outbound access (NAT Gateway) to install packages at boot.
- The launch template uses plaintext `user_data`; never put secrets there.
- Add an HTTPS listener and ACM certificate before exposing real traffic.
