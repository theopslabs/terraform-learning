# Lab: Import and Refactor

**Module:** 2 | **Lessons:** 1, 4 | **Time:** 45–60 minutes | **Cost:** $0

This lab has two parts:

1. **`import/`** — bring an existing S3 bucket under Terraform management without recreating it.
2. **`refactor/`** — practice `moved` and `removed` blocks with zero-cost `terraform_data` resources.

Run the parts in order.

---

## Part 1: Import an existing bucket

### Create a bucket outside Terraform

Pick a globally unique name and create it with the AWS CLI:

```bash
BUCKET="tf-course-import-$(date +%s)"
aws s3 mb "s3://${BUCKET}" --region us-east-1
echo "$BUCKET"
```

### Import it

```bash
cd import
terraform init

# Pass the bucket name directly
terraform plan -var="existing_bucket_name=${BUCKET}"

# The plan should show one resource to import, not create
terraform apply -var="existing_bucket_name=${BUCKET}"
```

Terraform reads the existing bucket, records it in state, and applies the tags from `main.tf`.

```bash
terraform state list
# aws_s3_bucket.existing
```

### Alternative: generate configuration

The `import` block in `main.tf` is the declarative approach. For a bucket with many existing settings, let Terraform generate a starting configuration:

1. Comment out the `resource "aws_s3_bucket" "existing"` block.
2. Run:

   ```bash
   terraform plan -generate-config-out=generated.tf -var="existing_bucket_name=${BUCKET}"
   ```

3. Review `generated.tf`, then merge what you need into `main.tf`.

### Cleanup part 1

```bash
terraform destroy -var="existing_bucket_name=${BUCKET}"
aws s3 rb "s3://${BUCKET}"
```

Terraform deletes the bucket because it now manages it. The second command is a safety net if the bucket is not empty.

> **Why import matters:** real teams inherit infrastructure. Import lets you adopt it without downtime, then manage it with the same review and plan process as everything else.

---

## Part 2: Refactor with `moved` and `removed`

The `refactor/` directory uses built-in `terraform_data` resources, so it costs nothing and needs no AWS credentials.

### Run it

```bash
cd refactor
terraform init
terraform apply
terraform state list
```

You should see `terraform_data.current` and `terraform_data.kept`.

### Understand the blocks

`main.tf` includes:

- A `moved` block from `terraform_data.legacy` to `terraform_data.current`. On a fresh state this is a no-op; on a state that still has `terraform_data.legacy`, Terraform rewrites the address without destroying anything.
- A `removed` block for `terraform_data.temporary` with `destroy = false`. On a state that contains it, Terraform forgets the object but does not destroy it.

### Try a real move

1. Apply the current configuration.
2. Rename `terraform_data.current` to `terraform_data.renamed` in `main.tf` and in the `moved` block destination.
3. Add a new `moved` block:

   ```hcl
   moved {
     from = terraform_data.current
     to   = terraform_data.renamed
   }
   ```

4. Run `terraform plan`. It should show **no changes** — only a state address update.
5. Run `terraform apply`, then `terraform state list` to confirm the new address.

Without `moved`, Terraform would propose destroying the old resource and creating a new one.

### Cleanup part 2

```bash
terraform destroy
terraform state list   # should print nothing
```

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `BucketAlreadyExists` | Choose a different name; S3 names are global |
| `AccessDenied` when importing | Your user needs `s3:GetBucket*`, `s3:ListBucket`, and tagging permissions |
| Import plan wants to replace the bucket | The configured `bucket` name must exactly match the existing bucket; remove immutable arguments you cannot match |
| `Moved object still exists` | Both old and new addresses are present in state; inspect `terraform state list` and resolve duplicates deliberately |
| `removed` block has no effect | The address is not in state; that is expected on a fresh run |

## Next

Continue to [m03-local-module](../m03-local-module/) to package resources for reuse.
