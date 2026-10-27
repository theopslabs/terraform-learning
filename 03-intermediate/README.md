# Module 3: Intermediate Concepts

**Duration:** ~5-6 hours | **Level:** Intermediate | **Prerequisites:** Modules 1 & 2 completed

## Module Overview

This module takes your Terraform skills to the next level. You'll learn how to create reusable infrastructure with modules, manage multiple environments with workspaces, leverage built-in functions and expressions, master advanced CLI commands, and set up remote state with proper backend configuration and locking.

## Learning Objectives

By the end of this module, you will be able to:

- Create and use Terraform modules for reusable infrastructure
- Structure modules following best practices
- Use workspaces to manage multiple environments
- Use Terraform's built-in functions (string, numeric, collection, etc.)
- Write complex expressions with conditionals and for loops
- Use advanced CLI commands like `import`, `taint`/`replace`, `graph`
- Configure remote backends (S3) with state locking (DynamoDB)
- Understand backend configuration and partial configuration

## Lessons

| # | Lesson | Description | Time |
|---|--------|-------------|------|
| 1 | [Modules](./01-modules/README.md) | What are modules, module structure, local modules, inputs/outputs, module composition | 90 min |
| 2 | [Workspaces](./02-workspaces/README.md) | Workspace concepts, default workspace, creating/switching workspaces, workspace in configuration | 60 min |
| 3 | [Functions and Expressions](./03-functions-and-expressions/README.md) | Built-in functions, string/numeric/collection functions, conditionals, for expressions, splat operator | 90 min |
| 4 | [Terraform CLI Deep Dive](./04-terraform-cli-deep-dive/README.md) | terraform import, replace/taint, validate/fmt, graph, console, state advanced commands | 60 min |
| 5 | [Remote State & Backends](./05-remote-state-and-backends/README.md) | Backend types, S3 backend, DynamoDB locking, partial backend config, state migration | 90 min |

## Module Summary

After completing this module, you'll be able to build modular, reusable infrastructure, manage multiple environments efficiently, and collaborate safely using remote state.

## Exercises

[View Module 3 Exercises](./exercises.md) - Practice what you've learned

## Next Steps

Once you've completed all lessons and exercises in this module, move on to [Module 4: AWS-Specific Deep Dive](../04-aws-deep-dive/README.md).
