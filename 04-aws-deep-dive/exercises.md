# Module 4 Exercises

**Goal:** Practice building real-world AWS infrastructure

## Exercise 1: VPC Networking
Build a custom VPC from scratch:

**Requirements:**
- VPC with CIDR 10.0.0.0/16
- 2 public subnets and 2 private subnets across 2 AZs
- Internet Gateway attached
- NAT Gateway in one public subnet
- Public route table routing to IGW
- Private route table routing to NAT Gateway
- Proper security groups
- Use variables and outputs

**Challenge:** Do it without looking at the solution!

## Exercise 2: EC2 with User Data
Deploy a web server:

**Requirements:**
- Use data source to get latest Amazon Linux 2 AMI
- Create EC2 instance in public subnet
- Install and start Apache using user data
- Create security group allowing HTTP (80) and SSH (22)
- Output the public IP and website URL
- Make it Free Tier compatible

## Exercise 3: S3 Secure Bucket
Create a secure S3 bucket:

**Requirements:**
- Bucket with unique name
- Enable versioning
- Enable server-side encryption (AES256)
- Block all public access
- Upload a file using `aws_s3_object`
- Add appropriate tags

## Exercise 4: RDS Database
Deploy an RDS instance (be mindful of costs):

**Requirements:**
- Create DB subnet group in private subnets
- Create security group allowing MySQL from app tier only
- Deploy db.t3.micro MySQL instance
- Use gp2 storage (20GB)
- Disable public accessibility
- Skip final snapshot for learning
- Output the endpoint

**Important:** Destroy immediately after testing!

## Exercise 5: Complete 3-Tier Architecture
Build a complete architecture combining everything:

**Requirements:**
- Custom VPC with public, private app, and private DB subnets
- ALB in public subnets
- Auto Scaling Group in private app subnets
- RDS in private DB subnets
- Security groups with proper rules (least privilege)
- User data to install Apache on instances
- All resources properly tagged

**This is the capstone for Module 4 - take your time!**

## Tips
- Always use `terraform plan` before apply
- Start simple, then add complexity
- Use the default VPC for exercises where you want to save on NAT Gateway costs
- NAT Gateways are expensive - skip them if just practicing basic concepts
- Always destroy resources immediately
- Use variables to make configurations reusable
- Follow security best practices
- Test connectivity where possible

## Cost Reminder
- **NAT Gateway**: ~$0.045/hour - AVOID if possible for learning
- **ALB**: ~$0.0225/hour + charges
- **RDS**: db.t3.micro Free Tier eligible for 12 months
- **EC2**: t2.micro Free Tier eligible
- **S3**: Very cheap, mostly Free Tier
- **Data transfer**: Usually minimal

**Always run `terraform destroy` when done!**
