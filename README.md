# Terraform Deep Dive Course: Zero to Professional

> A complete, self-paced Terraform course for absolute beginners with no IaC experience, focused on AWS.

## 🎯 Course Goal

By the end of this course, you'll go from zero to professional-level proficiency with Terraform on AWS. You'll learn how to write, test, and deploy infrastructure as code following industry best practices.

## 👥 Target Audience

- Complete beginners with no Infrastructure as Code (IaC) experience
- Developers looking to learn cloud infrastructure automation
- DevOps engineers wanting to master Terraform
- Anyone preparing for Terraform Associate certification

## 📋 Prerequisites

Before starting this course, you should have:

- Basic computer literacy and familiarity with the command line/terminal
- A free [AWS Account](https://aws.amazon.com/free/) (we'll use Free Tier resources where possible)
- Basic understanding of networking concepts (helpful but not required - we'll cover basics)
- A text editor (we recommend [VS Code](https://code.visualstudio.com/))

**No prior Terraform, AWS, or IaC experience required!**

## ⚠️ Important Notes About Costs

- **AWS Free Tier has changed**: Accounts created on or after **15 July 2025** receive up to **$200 in credits** and a **6-month free plan**, not the traditional 12-month allowance. Older accounts may still have 12 months. Always check the [current Free Tier page](https://aws.amazon.com/free/).
- **Set a budget first**: Create an [AWS Budget](https://console.aws.amazon.com/billing/home#/budgets) before running any lab that creates paid resources.
- **Always destroy resources**: After completing exercises, run `terraform destroy` to avoid unexpected charges
- **Monitor costs**: Check your [AWS Billing Dashboard](https://console.aws.amazon.com/billing/) regularly
- **Some resources may incur costs**: NAT Gateways, ALBs, RDS instances, and certain data transfer are not free. Every lab marks its cost explicitly

## 🗂️ Course Structure

This course is divided into 5 modules, progressing from beginner to professional level:

| Module | Title | Focus | Lessons |
|--------|-------|-------|---------|
| [01](./01-foundations/) | **Foundations** | IaC basics, Terraform intro, setup, first steps | 5 |
| [02](./02-core-concepts/) | **Core Concepts** | State, variables, data sources, providers, meta-arguments | 5 |
| [03](./03-intermediate/) | **Intermediate Concepts** | Modules, workspaces, functions, CLI deep dive, remote backends | 5 |
| [04](./04-aws-deep-dive/) | **AWS-Specific Deep Dive** | VPC, EC2, S3, RDS, Load Balancing & Auto Scaling | 5 |
| [05](./05-advanced/) | **Advanced & Professional** | Best practices, testing, CI/CD, secrets, multi-env architecture | 5 |

**Total:** 25 lessons with hands-on examples

> 🧪 **Hands-on labs:** The [labs directory](./labs/README.md) contains runnable configurations for every module, plus a full three-tier [capstone project](./capstone/README.md). Labs are free by default; paid labs are clearly marked.

> 🖼️ **Visual learner?** Start with the [Visual Workflow Guide](./resources/visual-workflow-guide.md). It explains the core Terraform workflow diagram and shows how each module fits into the same loop.

## 🚀 How to Use This Course

1. **Follow in order** - Each module builds on the previous one. Don't skip ahead!
2. **Read, then practice** - For each lesson, read the README.md, then work through the examples
3. **Type, don't copy-paste blindly** - Typing helps you learn and catch errors
4. **Do the exercises** - Each module has exercises to reinforce your learning
5. **Destroy your resources** - Always run `terraform destroy` when done with examples
6. **Experiment** - Change values, break things, fix them. That's how you learn!

## 🛠️ Tools You'll Need

| Tool | Purpose | Installation Guide |
|------|---------|-------------------|
| [Terraform](https://developer.hashicorp.com/terraform/install) | Infrastructure as Code tool | [Install Guide](./01-foundations/03-setting-up-your-environment/) |
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) | AWS authentication & management | [Install Guide](./01-foundations/03-setting-up-your-environment/) |
| [VS Code](https://code.visualstudio.com/) | Code editor | Recommended |
| [Terraform Extension](https://marketplace.visualstudio.com/items?itemName=HashiCorp.terraform) | VS Code syntax highlighting | Recommended |

**Supported versions:** Terraform **1.11+** (tested on 1.17.2) and AWS provider **6.x**. See [Supported Versions](./resources/versions.md) for details and upgrade notes.

## 📚 Additional Resources

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs) - Official docs
- [AWS Documentation](https://docs.aws.amazon.com/) - AWS service docs
- [Terraform Registry](https://registry.terraform.io/) - Providers and modules
- [Course Glossary](./resources/glossary.md) - Terms and definitions
- [Terraform Cheatsheet](./resources/cheatsheet.md) - Quick reference
- [Supported Versions](./resources/versions.md) - Tested versions, constraints, and upgrade policy
- [Hands-On Labs](./labs/README.md) - Runnable configurations for every module
- [Capstone Project](./capstone/README.md) - Full three-tier production-style build
- [Visual Workflow Guide](./resources/visual-workflow-guide.md) - Diagram-first explanation of the workflow and how each module fits

## 🤝 Contributing & Feedback

This is a learning resource. If you find errors, have suggestions, or want to improve something, feel free to open an issue or submit a pull request.

## 📄 License

This course is released under the [MIT License](./LICENSE). Use it, remix it, and share it. Infrastructure you create with it is your responsibility — always review plans and destroy paid resources.

---

**Ready to begin?** Start with [Module 1: Foundations](./01-foundations/README.md)
