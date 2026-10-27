# Module 2: Core Concepts

**Duration:** ~5-6 hours | **Level:** Beginner-Intermediate | **Prerequisites:** Module 1 completed

## Module Overview

This module builds on the foundations from Module 1. You'll learn how Terraform tracks infrastructure with state, how to make configurations reusable with variables and outputs, how to query existing resources with data sources, how to manage providers and versions, and how to create multiple resources efficiently with meta-arguments.

## Learning Objectives

By the end of this module, you will be able to:

- Explain what the Terraform state file is and why it's critical
- Understand local vs remote state and state locking
- Use input variables, variable types, validation, and `.tfvars` files
- Define and use outputs, including sensitive outputs
- Query existing AWS resources using data sources
- Configure providers with version constraints and use provider aliases
- Use `count` and `for_each` to create multiple resources
- Use `depends_on` and control resource behavior with `lifecycle` blocks

## Lessons

| # | Lesson | Description | Time |
|---|--------|-------------|------|
| 1 | [Terraform State](./01-terraform-state/README.md) | State file, purpose, local state, state locking, remote state basics, state commands | 60 min |
| 2 | [Variables and Outputs](./02-variables-and-outputs/README.md) | Input variables, types, defaults, validation, tfvars, outputs, sensitive values | 90 min |
| 3 | [Data Sources Deep Dive](./03-data-sources-deep-dive/README.md) | Querying existing resources, filters, combining data sources with resources | 60 min |
| 4 | [Providers and Versions](./04-providers-and-versions/README.md) | required_providers, version constraints, multiple providers, aliases, regions | 60 min |
| 5 | [Meta-Arguments](./05-meta-arguments/README.md) | count, for_each, depends_on, lifecycle (create_before_destroy, prevent_destroy, ignore_changes) | 90 min |

## Module Summary

After completing this module, you'll be able to write reusable, flexible Terraform configurations and understand how Terraform tracks and manages your infrastructure.

## Exercises

[View Module 2 Exercises](./exercises.md) - Practice what you've learned

## Next Steps

Once you've completed all lessons and exercises in this module, move on to [Module 3: Intermediate Concepts](../03-intermediate/README.md).
