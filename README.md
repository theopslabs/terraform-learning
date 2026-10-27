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

- **AWS Free Tier**: Most examples in this course are designed to work within AWS Free Tier limits
- **Always destroy resources**: After completing exercises, run `terraform destroy` to avoid unexpected charges
- **Monitor costs**: Check your [AWS Billing Dashboard](https://console.aws.amazon.com/billing/) regularly
- **Some resources may incur costs**: NAT Gateways, certain data transfer, or resources outside Free Tier may have charges. We'll call these out explicitly

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

## 📚 Additional Resources

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs) - Official docs
- [AWS Documentation](https://docs.aws.amazon.com/) - AWS service docs
- [Terraform Registry](https://registry.terraform.io/) - Providers and modules
- [Course Glossary](./resources/glossary.md) - Terms and definitions
- [Terraform Cheatsheet](./resources/cheatsheet.md) - Quick reference

## 🤝 Contributing & Feedback

This is a learning resource. If you find errors, have suggestions, or want to improve something, feel free to open an issue or submit a pull request.

## 📄 License

This course is provided for educational purposes. Use at your own risk.

---

**Ready to begin?** Start with [Module 1: Foundations](./01-foundations/README.md)
