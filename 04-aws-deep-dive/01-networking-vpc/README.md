# Lesson 1: Networking with Terraform - VPC

**Duration:** 120 minutes | **Level:** Intermediate-Advanced

## Table of Contents

- [AWS Networking Fundamentals](#aws-networking-fundamentals)
- [VPC Architecture Planning](#vpc-architecture-planning)
- [Creating a VPC](#creating-a-vpc)
- [Subnets](#subnets)
- [Internet Gateway](#internet-gateway)
- [Route Tables](#route-tables)
- [NAT Gateway](#nat-gateway)
- [Security Groups](#security-groups)
- [Network ACLs (NACLs)](#network-acls-nacls)
- [Hands-On: Build a Complete VPC](#hands-on-build-a-complete-vpc)
- [Best Practices](#best-practices)
- [Summary](#summary)
- [Next Steps](#next-steps)

## AWS Networking Fundamentals

Before diving in, let's understand key AWS networking components:

| Component | Description |
|-----------|-------------|
| **VPC** | Virtual Private Cloud - logically isolated network in AWS |
| **Subnet** | Range of IP addresses in a VPC, in a specific AZ |
| **Public Subnet** | Subnet with route to Internet Gateway, accessible from internet |
| **Private Subnet** | Subnet without direct route to internet, more secure |
| **Internet Gateway (IGW)** | Allows communication between VPC and internet |
| **NAT Gateway** | Allows private subnet instances to access internet outbound |
| **Route Table** | Rules that determine where network traffic goes |
| **Security Group** | Virtual firewall at instance level (stateful) |
| **NACL** | Network Access Control List - firewall at subnet level (stateless) |

## VPC Architecture Planning

For a typical 3-tier architecture, we'll create:

```
VPC (10.0.0.0/16)
├── Public Subnets (10.0.1.0/24, 10.0.2.0/24) - For ALB, NAT Gateway
├── Private App Subnets (10.0.10.0/24, 10.0.11.0/24) - For EC2 instances
└── Private DB Subnets (10.0.20.0/24, 10.0.21.0/24) - For RDS
```

We'll deploy across 2 Availability Zones for high availability.

## Creating a VPC

```hcl
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name = "main-vpc"
  }
}
```

## Subnets

```hcl
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "public-subnet-${count.index + 1}"
    Type = "Public"
  }
}

resource "aws_subnet" "private_app" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "private-app-subnet-${count.index + 1}"
    Type = "Private-App"
  }
}

resource "aws_subnet" "private_db" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 20)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name = "private-db-subnet-${count.index + 1}"
    Type = "Private-DB"
  }
}
```

## Internet Gateway

```hcl
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name = "main-igw"
  }
}
```

## Route Tables

### Public Route Table
```hcl
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
```

## NAT Gateway

> **⚠️ Cost Warning:** NAT Gateway costs ~$0.045/hour + data processing charges. NAT Gateways are NOT fully covered by Free Tier. Consider using NAT Instance for learning, or destroy immediately after testing.

```hcl
# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  
  tags = {
    Name = "nat-eip"
  }
  
  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway in public subnet
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  
  tags = {
    Name = "main-nat-gateway"
  }
  
  depends_on = [aws_internet_gateway.main]
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  
  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_app" {
  count          = length(aws_subnet.private_app)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db" {
  count          = length(aws_subnet.private_db)
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private.id
}
```

## Security Groups

Security groups are stateful - if you allow inbound, response is allowed automatically.

```hcl
# Web Security Group (for ALB)
resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Security group for web traffic"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "web-sg"
  }
}

# App Security Group (for EC2 instances)
resource "aws_security_group" "app" {
  name        = "app-sg"
  description = "Security group for app instances"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description     = "HTTP from web SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  
  ingress {
    description     = "SSH from bastion (optional)
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "app-sg"
  }
}

# DB Security Group (for RDS)
resource "aws_security_group" "db" {
  name        = "db-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description     = "MySQL/Aurora from app SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "db-sg"
  }
}
```

## Network ACLs (NACLs)

NACLs are optional and stateless. Security groups are usually sufficient. We'll keep it simple and focus on security groups.

## Hands-On: Build a Complete VPC

Let's build a production-like VPC with all components.

### Step 1: Create working directory

```bash
mkdir -p ~/terraform-learning/module4-vpc-demo
cd ~/terraform-learning/module4-vpc-demo
```

### Step 2: Create variables.tf

```hcl
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "terraform-demo"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
```

### Step 3: Create main.tf

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
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  
  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 1)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name        = "${var.project_name}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Public"
  }
}

# Private App Subnets
resource "aws_subnet" "private_app" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name        = "${var.project_name}-private-app-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Private-App"
  }
}

# Private DB Subnets
resource "aws_subnet" "private_db" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 20)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  
  tags = {
    Name        = "${var.project_name}-private-db-subnet-${count.index + 1}"
    Environment = var.environment
    Type        = "Private-DB"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  
  tags = {
    Name        = "${var.project_name-nat-eip}"
    Environment = var.environment
  }
  
  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  
  tags = {
    Name        = "${var.project_name}-nat-gateway"
    Environment = var.environment
  }
  
  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  
  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
  }
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  
  tags = {
    Name        = "${var.project_name}-private-rt"
    Environment = var.environment
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_app" {
  count          = length(aws_subnet.private_app)
  subnet_id      = aws_subpen.private_app[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db" {
  count          = length(aws_subnet.private_db)
  subnet_id      = aws_subnet.private_db[count.index].id
  route_table_id = aws_route_table.private.id
}

# Security Groups
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for web traffic"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.project_name}-web-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for app instances"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description     = "HTTP from web SG"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.project_name}-app-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Security group for RDS"
  vpc_id      = aws_vpc.main.id
  
  ingress {
    description     = "MySQL from app SG"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.project_name}-db-sg"
    Environment = var.environment
  }
}
```

> **Fix typos:** `var.project_name-nat-eip` → `var.project_name}-nat-eip`, `aws_subpen` → `aws_subnet`

### Corrected main.tf (key fixes)

```hcl
# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"
  
  tags = {
    Name        = "${var.project_name}-nat-eip"
    Environment = var.environment
  }
  
  depends_on = [aws_internet_gateway.main]
}
```

And fix the route table association:
```hcl
resource "aws_route_table_association" "private_app" {
  count          = length(aws_subnet.private_app)
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private.id
}
```

### Step 4: Create outputs.tf

```hcl
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "Public subnet IDs"
}

output "private_app_subnet_ids" {
  value       = aws_subnet.private_app[*].id
  description = "Private app subnet IDs"
}

output "private_db_subnet_ids" {
  value       = aws_subnet.private_db[*].id
  description = "Private DB subnet IDs"
}

output "nat_gateway_ip" {
  value       = aws_eip.nat.public_ip
  description = "NAT Gateway public IP"
}

output "web_security_group_id" {
  value       = aws_security_group.web.id
  description = "Web security group ID"
}

output "app_security_group_id" {
  value       = aws_security_group.app.id
  description = "App security group ID"
}

output "db_security_group_id" {
  value       = aws_security_group.db.id
  description = "DB security group ID"
}
```

### Step 5: Apply

```bash
terraform init
terraform plan
terraform apply
# Type yes
```

This will create a complete VPC. **Note: NAT Gateway will incur costs (~$0.045/hour)**. Destroy as soon as possible after reviewing.

### Step 6: Clean up

```bash
terraform destroy
# Type yes
rm -rf .terraform terraform.tfstate* .terraform.lock.hcl
```

> **⚠️ CRITICAL COST WARNING:** NAT Gateways are NOT Free Tier eligible. They cost money per hour and per GB processed. Always destroy immediately after testing! Consider skipping NAT Gateway for pure Free Tier learning or use a NAT instance.

## Best Practices

- **Use multiple AZs** for high availability
- **Separate public and private subnets** properly
- **Use Security Groups over NACLs** when possible
- **Follow least privilege** - only open necessary ports
- **Use CIDR calculations** with `cidrsubnet()`
- **Tag everything** for better management
- **Plan IP addressing** in advance
- **Use NAT Gateway in one AZ** for cost savings (or skip for dev)
- **Enable DNS hostnames/support** in VPC

## Summary

- **VPC** provides isolated networking in AWS
- **Public subnets** have routes to IGW for internet access
- **Private subnets** use NAT Gateway for outbound internet
- **Route tables** control traffic routing
- **Security Groups** act as instance-level firewalls (stateful)
- **Multi-AZ design** provides high availability
- **NAT Gateway incurs costs** - be careful

## Next Steps

Now let's learn about [Compute - EC2 and Launch Templates](../02-compute-ec2/README.md).
