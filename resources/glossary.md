# Glossary

A quick reference of Terraform and AWS terms you'll encounter throughout this course.

## A

- **AMI (Amazon Machine Image)** - A template that contains the software configuration (OS, application server, applications) required to launch an EC2 instance.
- **Apply** - The Terraform command that creates, updates, or destroys infrastructure to match the desired configuration.
- **ARN (Amazon Resource Name)** - A unique identifier for AWS resources.

## B

- **Backend** - The location where Terraform stores its state file (e.g., local disk, S3, Terraform Cloud).
- **Block** - A container for configuration in HCL (e.g., `resource`, `provider`, `variable` blocks).

## C

- **Configuration** - A set of `.tf` files that define the desired infrastructure state.
- **Count** - A meta-argument that creates multiple instances of a resource based on a number.
- **CRM (Customer Relationship Management)** - Not directly related, but mentioned in context.

## D

- **Data Source** - Allows Terraform to fetch information about existing resources or external data.
- **Declarative** - An approach where you describe the desired end state, and the tool determines how to achieve it.
- **Destroy** - The Terraform command that removes all resources managed by a configuration.
- **Drift** - When actual infrastructure differs from the state defined in Terraform configuration.

## E

- **EC2 (Elastic Compute Cloud)** - AWS service providing resizable virtual servers in the cloud.

## F

- **For Each** - A meta-argument that creates multiple instances of a resource based on a map or set.

## G

- **HCL (HashiCorp Configuration Language)** - The domain-specific language used by Terraform to write configurations.

## I

- **IaC (Infrastructure as Code)** - Managing and provisioning infrastructure through code rather than manual processes.
- **Idempotent** - Running the same operation multiple times produces the same result without side effects.
- **Init** - The Terraform command that initializes a working directory by downloading providers and modules.
- **Input Variable** - A parameter that allows you to customize configurations without modifying the code.

## M

- **Meta-Argument** - Arguments that can be used with any resource type (e.g., `count`, `for_each`, `depends_on`, `lifecycle`).
- **Module** - A reusable container for multiple Terraform resources.

## O

- **Output** - A value displayed after `terraform apply` that provides useful information about created resources.
- **Output Variable** - Values exported from a module or root configuration.

## P

- **Plan** - The Terraform command that creates an execution plan showing what changes will be made.
- **Provider** - A plugin that allows Terraform to interact with APIs (AWS, Azure, GCP, etc.).
- **Provisioner** - A mechanism to execute scripts or commands on local or remote machines (use sparingly).

## R

- **Resource** - A block that defines an infrastructure object to be created and managed by Terraform.
- **Resource Graph** - A dependency graph that Terraform builds to determine the order of resource creation.
- **Remote Backend** - A backend that stores state remotely (e.g., S3), enabling collaboration.

## S

- **S3 (Simple Storage Service)** - AWS object storage service.
- **State File** (`terraform.tfstate`) - A file that tracks the current state of managed infrastructure.
- **State Locking** - Prevents concurrent operations from corrupting the state file.

## T

- **Taint** - Marking a resource for recreation on the next apply (deprecated in favor of `-replace`).
- **Terraform Registry** - A repository of providers and modules (https://registry.terraform.io/).
- **Terraform Cloud/Enterprise** - HashiCorp's managed Terraform service.

## V

- **VPC (Virtual Private Cloud)** - A logically isolated virtual network in AWS.
- **Variable** - See Input Variable.

## W

- **Workspace** - Allows managing multiple states from the same configuration (e.g., dev, staging, prod).
