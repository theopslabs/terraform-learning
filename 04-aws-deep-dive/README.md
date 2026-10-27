# Module 4: AWS-Specific Deep Dive

**Duration:** ~8-10 hours | **Level:** Intermediate-Advanced | **Prerequisites:** Modules 1, 2 & 3 completed

## Module Overview

This module focuses on building real-world AWS infrastructure using Terraform. You'll learn to design and deploy production-like architectures including VPC networking, EC2 compute instances, S3 storage, RDS databases, and load balancing with auto-scaling. All examples are designed to be AWS Free Tier compatible where possible.

## Learning Objectives

By the end of this module, you will be able to:

- Design and build a custom VPC with public and private subnets across multiple AZs
- Configure route tables, NAT Gateways, and Internet Gateways
- Implement Security Groups following least privilege principles
- Deploy EC2 instances with user data and launch templates
- Configure S3 buckets with proper security, versioning, and encryption
- Deploy RDS databases with proper networking and security
- Set up Application Load Balancers (ALB) with target groups
- Implement Auto Scaling Groups for high availability
- Build a complete multi-tier architecture

## Lessons

| # | Lesson | Description | Time |
|---|--------|-------------|------|
| 1 | [Networking with Terraform - VPC](./01-networking-vpc/README.md) | VPC, CIDR blocks, subnets, IGW, NAT Gateway, route tables, Security Groups | 120 min |
| 2 | [Compute - EC2 and Launch Templates](./02-compute-ec2/README.md) | EC2 instances, AMIs, user data, key pairs, Launch Templates, placement | 90 min |
| 3 | [Storage - S3](./03-storage-s3/README.md) | S3 buckets, bucket policies, versioning, encryption, lifecycle rules, static website hosting | 60 min |
| 4 | [Databases - RDS](./04-databases-rds/README.md) | RDS basics, subnet groups, parameter groups, security, MySQL/Postgres, backups | 90 min |
| 5 | [Load Balancing & Auto Scaling](./05-load-balancing-autoscaling/README.md) | ALB, target groups, listeners, health checks, ASG, scaling policies | 120 min |

## Module Summary

After completing this module, you'll be able to build production-ready AWS architectures using Terraform, following networking best practices, security principles, and high availability patterns.

## Important Notes

- **Costs**: Most resources are Free Tier eligible, but NAT Gateways incur charges. We'll call them out explicitly.
- **Security**: Never hardcode credentials. Use proper security groups and avoid 0.0.0.0/0 where possible.
- **Cleanup**: Always run `terraform destroy` after exercises to avoid charges.
- **Regions**: Examples use `us-east-1` but should work in other regions.

## Exercises

[View Module 4 Exercises](./exercises.md) - Practice what you've learned

## Next Steps

Once you've completed all lessons and exercises in this module, move on to [Module 5: Advanced & Professional](../05-advanced/README.md).
