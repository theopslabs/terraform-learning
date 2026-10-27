# Lesson 3: Setting Up Your Environment

**Duration:** 60 minutes | **Level:** Beginner

## Table of Contents

- [Prerequisites Check](#prerequisites-check)
- [AWS Account Setup](#aws-account-setup)
- [Installing AWS CLI](#installing-aws-cli)
- [Installing Terraform](#installing-terraform)
- [Configuring AWS Credentials](#configuring-aws-credentials)
- [Verifying Your Setup](#verifying-your-setup)
- [Security Best Practices](#security-best-practices)
- [Troubleshooting](#troubleshooting)
- [Summary](#summary)
- [Next Steps](#next-steps)

## Prerequisites Check

Before we begin, ensure you have:
- [ ] A computer with internet access (Linux, macOS, or Windows)
- [ ] Administrator/sudo privileges to install software
- [ ] A valid email address for AWS account creation
- [ ] Credit/debit card for AWS account (won't be charged if using Free Tier properly)

## AWS Account Setup

If you don't have an AWS account yet:

1. Go to [aws.amazon.com/free](https://aws.amazon.com/free/)
2. Click "Create a Free Account"
3. Follow the registration process (email, password, account details, payment, verification)
4. Choose the **Basic Support - Free** plan
5. Complete setup and sign in to [AWS Console](https://console.aws.amazon.com/)

> **Note:** AWS Free Tier is free for 12 months for many services, and some services are always free. We'll stick to Free Tier eligible resources in this course.

## Installing AWS CLI

The AWS CLI allows us to authenticate with AWS from the command line.

### For Linux

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### For macOS

```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

Or using Homebrew:
```bash
brew install awscli
```

### For Windows

Download and run the [AWS CLI MSI installer](https://awscli.amazonaws.com/AWSCLIV2.msi).

### Verify Installation

```bash
aws --version
```

Expected output: `aws-cli/2.x.x Python/3.x.x ...`

## Installing Terraform

Terraform installation varies by OS.

### For Linux (Ubuntu/Debian)

```bash
# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install
sudo apt update && sudo apt install terraform
```

### For Linux (Manual Install)

```bash
# Download latest version (check https://developer.hashicorp.com/terraform/install for current version)
wget https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
unzip terraform_1.9.8_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### For macOS

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

### For Windows

Option 1: Using Chocolatey
```powershell
choco install terraform
```

Option 2: Using Winget
```powershell
winget install Hashicorp.Terraform
```

Option 3: Manual - Download from [Terraform downloads page](https://developer.hashicorp.com/terraform/install), unzip, and add to PATH.

### Verify Installation

```bash
terraform version
```

Expected output: `Terraform v1.9.x` (or newer)

## Configuring AWS Credentials

We need to give Terraform permission to create resources in your AWS account. **Never commit credentials to Git!**

### Step 1: Create IAM User (Recommended for learning)

1. Sign in to [AWS Console](https://console.aws.amazon.com/)
2. Go to IAM > Users > Create user
3. User name: `terraform-user` (or similar)
4. Select "Provide user access to the AWS Management Console" - optional for CLI
5. Click Next
6. Attach policies directly: `AdministratorAccess` (for learning purposes only)
   - **Warning:** AdministratorAccess gives full access. In production, use least privilege.
7. Create user

### Step 2: Create Access Keys

1. Go to the user you just created
2. Go to "Security credentials" tab
3. Click "Create access key"
4. Use case: "Command Line Interface (CLI)"
5. Check the confirmation box
6. Click Next, add description (optional), Create access key
7. **IMPORTANT:** Download the CSV or copy both keys - you won't see the secret again!

### Step 3: Configure AWS CLI

```bash
aws configure
```

You'll be prompted for:
```
AWS Access Key ID [None]: YOUR_ACCESS_KEY_ID
AWS Secret Access Key [None]: YOUR_SECRET_ACCESS_KEY
Default region name [None]: us-east-1
Default output format [None]: json
```

**Recommended region:** `us-east-1` (N. Virginia) - most Free Tier resources available here.

### Alternative: Environment Variables

```bash
export AWS_ACCESS_KEY_ID="your_access_key"
export AWS_SECRET_ACCESS_KEY="your_secret_key"
export AWS_DEFAULT_REGION="us-east-1"
```

**Note:** Environment variables are session-based. Add to `~/.bashrc` or `~/.zshrc` to persist.

## Verifying Your Setup

Test that everything is configured correctly:

```bash
# Check AWS identity
aws sts get-caller-identity
```

Expected output:
```json
{
    "UserId": "AIDAXXXXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-user"
}
```

If you see this, AWS CLI is configured correctly!

```bash
# Check Terraform
terraform version
```

Both tools should be working.

## Security Best Practices

- **Never hardcode credentials** in Terraform files
- **Use IAM users with minimal permissions** in production (we use Admin for learning only)
- **Enable MFA** on your AWS root account
- **Don't commit** `terraform.tfstate`, `.terraform/`, or credentials to Git
- **Use AWS profiles** for multiple accounts: `aws configure --profile dev`
- **Consider AWS CloudShell** or temporary credentials for extra security
- **Rotate access keys** regularly

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `terraform: command not found` | Check PATH, reinstall, or use full path |
| `aws: command not found` | Reinstall AWS CLI, check PATH |
| `Unable to locate credentials` | Run `aws configure` or set environment variables |
| `UnauthorizedOperation` | Check IAM permissions for your user |
| `InvalidClientTokenId` | Check access key is correct, no spaces |
| Permission denied during install | Use `sudo` on Linux/macOS |

## Summary

- Created/configured AWS account (Free Tier)
- Installed AWS CLI and Terraform
- Configured credentials using `aws configure`
- Verified setup with `aws sts get-caller-identity`
- Learned security best practices for credentials

## Next Steps

Now that your environment is set up, let's learn [Terraform Basics](../04-terraform-basics/README.md) - HCL syntax, providers, resources, and write your first Terraform configuration!
