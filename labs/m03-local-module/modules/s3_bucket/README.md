# S3 Bucket Module

Creates a private, versioned S3 bucket with a random suffix.

## Inputs

| Name | Type | Required | Description |
|------|------|----------|-------------|
| `bucket_prefix` | `string` | yes | Prefix for the globally unique bucket name |
| `environment` | `string` | yes | One of `dev`, `staging`, `prod` |
| `project_name` | `string` | yes | Project name used in tags |
| `extra_tags` | `map(string)` | no | Additional tags merged into the bucket |

## Outputs

| Name | Description |
|------|-------------|
| `bucket_name` | Bucket name |
| `bucket_arn` | Bucket ARN |
| `bucket_id` | Bucket ID |

## Example

```hcl
module "assets" {
  source = "./modules/s3_bucket"

  bucket_prefix = "my-app-assets"
  environment   = "dev"
  project_name  = "my-app"
}
```
