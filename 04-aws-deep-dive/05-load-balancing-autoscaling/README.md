# Lesson 5: Load Balancing & Auto Scaling

**Duration:** 120 minutes | **Level:** Intermediate-Advanced

## Table of Contents

- [Load Balancing Overview](#load-balancing-overview)
- [Application Load Balancer (ALB)](#application-load-balancer-alb)
- [Target Groups](#target-groups)
- [Listeners and Rules](#listeners-and-rules)
- [Auto Scaling Overview](#auto-scaling-overview)
- [Launch Templates with ASG](#launch-templates-with-asg)
- [Scaling Policies](#scaling-policies)
- [Hands-On: ALB with Auto Scaling](#hands-on-alb-with-auto-scaling)
- [Best Practices](#best-practices)
- [Summary](#summary)
- [Module 4 Wrap-up](#module-4-wrap-up)
- [Next Steps](#next-steps)

## Load Balancing Overview

**Elastic Load Balancing (ELB)** automatically distributes incoming traffic across multiple targets (EC2 instances, containers, IP addresses) across multiple Availability Zones.

Types of Load Balancers:
- **Application Load Balancer (ALB)** - Layer 7 (HTTP/HTTPS), best for web apps
- **Network Load Balancer (NLB)** - Layer 4 (TCP/UDP), high performance
- **Gateway Load Balancer (GWLB)** - Layer 3
- **Classic Load Balancer** - Legacy

We'll focus on **ALB** for this course.

## Application Load Balancer (ALB)

```hcl
resource "aws_lb" "web" {
  name               = "web-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
  
  enable_deletion_protection = false
  
  tags = {
    Name = "web-alb"
  }
}
```

## Target Groups

```hcl
resource "aws_lb_target_group" "web" {
  name     = "web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  
  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  
  tags = {
    Name = "web-tg"
  }
}
```

## Listeners and Rules

```hcl
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}
```

## Auto Scaling Overview

**Auto Scaling Group (ASG)** automatically adjusts the number of EC2 instances based on demand, ensuring high availability and cost optimization.

## Launch Templates with ASG

```hcl
resource "aws_launch_template" "web" {
  name_prefix   = "web-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  vpc_security_group_ids = [aws_security_group.app.id]
  
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Instance: $(hostname -f)</h1>" > /var/www/html/index.html
              EOF
  )
  
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-asg-instance"
    }
  }
}

resource "aws_autoscaling_group" "web" {
  name                = "web-asg"
  vpc_zone_identifier = var.private_app_subnet_ids
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"
  health_check_grace_period = 300
  
  min_size         = 2
  max_size         = 4
  desired_capacity = 2
  
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
  
  tag {
    key                 = "Name"
    value               = "web-asg-instance"
    propagate_at_launch = true
  }
}
```

## Scaling Policies

```hcl
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web.name
}
```

## Hands-On: ALB with Auto Scaling

```bash
mkdir -p ~/terraform-learning/module4-alb-asg-demo
cd ~/terraform-learning/module4-alb-asg-demo
```

Create a simplified version using default VPC:

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

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
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

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "alb-sg"
  description = "Allow HTTP"
  vpc_id      = data.aws_vpc.default.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# App Security Group
resource "aws_security_group" "app" {
  name        = "app-sg-asg"
  description = "Allow HTTP from ALB"
  vpc_id      = data.aws_vpc.default.id
  
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ALB
resource "aws_lb" "web" {
  name               = "web-alb-demo"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.default.ids
  
  tags = {
    Name = "web-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "web" {
  name     = "web-tg-demo"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id
  
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }
}

# Listener
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

# Launch Template
resource "aws_launch_template" "web" {
  name_prefix   = "web-lt-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  
  vpc_security_group_ids = [aws_security_group.app.id]
  
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Instance: $(hostname)</h1>" > /var/www/html/index.html
              EOF
  )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web" {
  name                = "web-asg-demo"
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns   = [aws_lb_target_group.web.arn]
  health_check_type   = "ELB"
  min_size            = 2
  max_size            = 4
  desired_capacity    = 2
  
  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }
}

output "alb_dns_name" {
  value = aws_lb.web.dns_name
}

output "website_url" {
  value = "http://${aws_lb.web.dns_name}"
}
```

```bash
terraform init
terraform apply
# Wait a few minutes for instances to be healthy
# Visit website_url - refresh to see different hostnames
terraform destroy
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

> **⚠️ Cost Warning:** ALB has costs (~$0.0225/hour + LCUs). Free Tier has some ALB hours but be careful. Always destroy!

## Best Practices

- Use ALB for HTTP/HTTPS traffic
- Use multiple AZs for high availability
- Set proper health check parameters
- Use Launch Templates with ASG
- Set appropriate min/max/desired capacity
- Use scaling policies for dynamic scaling
- Keep instances in private subnets behind ALB
- Enable deletion protection in production
- Use target group health checks

## Summary

- **ALB** distributes traffic across targets
- **Target Groups** define where traffic goes and health checks
- **ASG** automatically scales instances based on demand
- **Launch Templates** define instance configuration
- **Health checks** ensure traffic only goes to healthy instances
- This creates a highly available, scalable architecture

## Module 4 Wrap-up

Congratulations! You've completed Module 4: AWS-Specific Deep Dive. You now know:

✅ VPC networking - subnets, route tables, IGW, NAT Gateway, security groups  
✅ EC2 and Launch Templates - compute instances and user data  
✅ S3 - object storage with security best practices  
✅ RDS - managed relational databases  
✅ ALB and Auto Scaling - load balancing and high availability  

## Next Steps

Ready for advanced topics? Move on to [Module 5: Advanced & Professional](../../05-advanced/README.md) where you'll learn about best practices, testing, CI/CD with Terraform, secrets management, and multi-environment architecture!
