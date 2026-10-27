# Lesson 1: Introduction to Infrastructure as Code (IaC)

**Duration:** 45 minutes | **Level:** Beginner

## Table of Contents

- [What is Infrastructure as Code?](#what-is-infrastructure-as-code)
- [Why Use Infrastructure as Code?](#why-use-infrastructure-as-code)
- [Declarative vs Imperative Approaches](#declarative-vs-imperative-approaches)
- [Benefits of IaC](#benefits-of-iac)
- [Challenges of IaC](#challenges-of-iac)
- [Real-World Use Cases](#real-world-use-cases)
- [Summary](#summary)
- [Next Steps](#next-steps)

## What is Infrastructure as Code?

**Infrastructure as Code (IaC)** is the practice of managing and provisioning computing infrastructure through machine-readable definition files, rather than through physical hardware configuration or interactive configuration tools.

Instead of:
- Clicking through AWS Console to create a VPC
- Manually configuring servers via SSH
- Documenting steps in a runbook

You write code that describes your desired infrastructure state, and tools like Terraform automatically provision it for you.

**Key Concept:** Treat your infrastructure the same way you treat your application code - version it, test it, review it, and automate it.

## Why Use Infrastructure as Code?

Traditionally, infrastructure was managed manually (often called "ClickOps"). This approach has significant problems:

| Problem | Impact |
|---------|--------|
| **Human Error** | Manual steps are prone to mistakes, especially in complex environments |
| **Inconsistency** | Different environments (dev, staging, prod) drift and become different |
| **Slow Provisioning** | Setting up infrastructure can take hours or days of manual work |
| **Lack of Documentation** | Hard to know exactly what was configured and why |
| **Poor Scalability** | Can't easily replicate infrastructure across regions or accounts |
| **No Audit Trail** | Difficult to track who changed what and when |

IaC solves these problems by making infrastructure provisioning repeatable, consistent, and automated.

## Declarative vs Imperative Approaches

There are two main approaches to IaC:

### Declarative (What, not How)
You describe the **desired end state** of your infrastructure. The IaC tool figures out how to achieve it.

- **Example:** "I want a VPC with 2 public subnets"
- **Tools:** Terraform, AWS CloudFormation, Pulumi (can be both)
- **Pros:** Idempotent, easier to understand, tool handles dependencies
- **Cons:** Less control over the exact steps

### Imperative (How, step by step)
You specify the **exact commands and sequence** of steps to achieve the desired state.

- **Example:** "Create VPC, then create subnet 1, then create subnet 2..."
- **Tools:** AWS CLI scripts, Ansible (can be both), Bash scripts
- **Pros:** More control, easier for complex procedural logic
- **Cons:** Not idempotent by default, harder to maintain, order matters

**Terraform uses a declarative approach.** You declare what you want, Terraform determines how to build it.

### Example Comparison

**Declarative (Terraform):**
```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"
}
```
*You just say "I want this EC2 instance" - Terraform handles creation.*

**Imperative (AWS CLI):**
```bash
aws ec2 run-instances --image-id ami-12345678 --instance-type t2.micro
```
*You run a specific command to create it. If you run it again, you might create duplicates.*

## Benefits of IaC

- **Version Control** - Store infrastructure definitions in Git, track changes over time
- **Consistency** - Identical infrastructure across all environments
- **Automation** - Provision infrastructure in minutes, not hours
- **Collaboration** - Teams can review infrastructure changes like code (pull requests)
- **Disaster Recovery** - Rebuild entire infrastructure from code if needed
- **Cost Control** - Easily spin up/down environments, avoid idle resources
- **Documentation as Code** - Your infrastructure definition IS your documentation
- **Testing** - Validate and test infrastructure before deploying to production
- **Scalability** - Replicate across regions, accounts, or clouds easily

## Challenges of IaC

- **Learning Curve** - Requires learning new tools, languages (HCL), and cloud concepts
- **State Management** - Need to track what resources exist (more on this later)
- **Secrets Handling** - Must be careful not to commit credentials or secrets
- **Drift** - Manual changes can cause infrastructure to diverge from code
- **Debugging** - Troubleshooting can be complex when things go wrong
- **Provider Limitations** - Not all cloud features may be immediately available

Don't worry - this course will teach you how to navigate these challenges!

## Real-World Use Cases

| Use Case | Description |
|----------|-------------|
| **Multi-environment Setup** | Create identical dev/staging/prod environments with different configurations |
| **Application Deployment** | Provision VPC, load balancers, databases, and compute for apps |
| **Disaster Recovery** | Quickly rebuild infrastructure in a different region during outages |
| **Compliance & Security** | Enforce security policies as code, audit all changes |
| **Auto-scaling Infrastructure** | Define scalable architectures that can grow/shrink as needed |
| **Hybrid/Multi-cloud** | Manage resources across AWS, Azure, GCP with a single tool |

## Summary

- **IaC** = Managing infrastructure through code files instead of manual processes
- **Declarative** = Describe desired end state (what) - Terraform uses this
- **Imperative** = Describe steps to take (how)
- **Benefits** = Consistency, automation, version control, scalability
- **Challenges** = Learning curve, state management, security considerations

## Next Steps

Now that you understand IaC fundamentals, let's learn about [Terraform specifically](../02-intro-to-terraform/README.md) - what makes it unique and why it's so popular.
