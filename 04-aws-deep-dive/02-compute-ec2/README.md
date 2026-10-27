# Lesson 2: Compute - EC2 and Launch Templates

**Duration:** 90 minutes | **Level:** Intermediate-Advanced

## Table of Contents

- [EC2 Overview](#ec2-overview)
- [EC2 Instance Types](#ec2-instance-types)
- [AMIs](#amis)
- [User Data](#user-data)
- [Key Pairs](#key-pairs)
- [Launch Templates](#launch-templates)
- [Hands-On: Deploy EC2 Instances](#hands-on-deploy-ec2-instances)
- [Best Practices](#best-practices)
- [Summary](#summary)
- [Next Steps](#next-steps)

## EC2 Overview

**Amazon EC2 (Elastic Compute Cloud)** provides resizable virtual servers in the cloud. With Terraform, we can automate provisioning, configuration, and scaling of EC2 instances.

## EC2 Instance Types

| Type | Use Case | Free Tier |
|------|----------|-----------|
| **t2.micro** | General purpose, low traffic | Yes (750 hours/month for 12 months) |
| **t3.micro** | General purpose, burstable | Yes in some regions |
| **t2.small** | Small apps | No (paid) |

**For this course, we use t2.micro which is Free Tier eligible.**

## AMIs

AMIs (Amazon Machine Images) are templates for EC2 instances. Use data sources to get latest AMIs.

```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```

## User Data

User data allows you to run scripts on instance launch.

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform</h1>" > /var/www/html/index.html
              EOF
  
  tags = {
    Name = "web-server"
  }
}
```

## Key Pairs

For SSH access (use with caution and only when necessary).

```hcl
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}
```

> **Security Note:** For learning, we often skip key pairs and use SSM Session Manager instead.

## Launch Templates

Launch Templates define instance configuration and are used by Auto Scaling Groups.

```hcl
resource "aws_launch_template" "web" {
  name_prefix   = "web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  vpc_security_group_ids = [aws_security_group.app.id]
  
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from ASG</h1>" > /var/www/html/index.html
              EOF
  )
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-instance"
    }
  }
}
```

## Hands-On: Deploy EC2 Instances

```bash
mkdir -p ~/terraform-learning/module4-ec2-demo
cd ~/terraform-learning/module4-ec2-demo
```

Create `main.tf`:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Use default VPC for simplicity (or reference your VPC)
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_security_group" "web" {
  name        = "web-sg-ec2"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.default.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Only for learning!
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.web.id]
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform EC2</h1>" > /var/www/html/index.html
              EOF
  
  tags = {
    Name = "terraform-web-server"
  }
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}

output "website_url" {
  value = "http://${aws_instance.web.public_ip}"
}
```

```bash
terraform init
terraform apply
# Type yes
# Visit the website_url
terraform destroy
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

> **⚠️ Security Note:** Opening SSH to 0.0.0.0/0 is insecure. Use your IP or SSM.

## Best Practices

- Use Launch Templates with Auto Scaling Groups
- Use User Data for bootstrapping
- Don't hardcode AMI IDs - use data sources
- Use Security Groups properly
- Consider IMDSv2 for metadata security
- Use SSM Session Manager instead of SSH keys when possible
- Tag all resources

## Summary

- EC2 provides virtual servers
- Use data sources for AMIs
- User data automates instance configuration
- Launch Templates are preferred for scalability
- Always follow security best practices

## Next Steps

Learn about [S3 Storage](../03-storage-s3/README.md).
