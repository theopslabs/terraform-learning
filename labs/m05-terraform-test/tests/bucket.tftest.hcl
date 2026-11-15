# Mock the AWS provider so tests run without credentials or API calls.
mock_provider "aws" {}

run "bucket_is_configured" {
  command = plan

  variables {
    bucket_name = "tf-course-test-bucket"
    environment = "dev"
  }

  assert {
    condition     = aws_s3_bucket.this.bucket == "tf-course-test-bucket"
    error_message = "The bucket name should match the input variable."
  }

  assert {
    condition     = aws_s3_bucket.this.tags["Environment"] == "dev"
    error_message = "The Environment tag should match the input variable."
  }

  assert {
    condition     = aws_s3_bucket_versioning.this.versioning_configuration[0].status == "Enabled"
    error_message = "Versioning should be enabled."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls
    error_message = "Public ACLs should be blocked."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.restrict_public_buckets
    error_message = "Public bucket policies should be restricted."
  }
}

run "extra_tags_are_merged" {
  command = plan

  variables {
    bucket_name = "tf-course-test-bucket"
    extra_tags = {
      CostCenter = "training"
      Owner      = "learner"
    }
  }

  assert {
    condition     = aws_s3_bucket.this.tags["CostCenter"] == "training"
    error_message = "extra_tags should be merged into the bucket tags."
  }

  assert {
    condition     = aws_s3_bucket.this.tags["Owner"] == "learner"
    error_message = "extra_tags should be merged into the bucket tags."
  }
}

run "rejects_invalid_environment" {
  command = plan

  variables {
    bucket_name = "tf-course-test-bucket"
    environment = "production"
  }

  expect_failures = [var.environment]
}

run "rejects_invalid_bucket_name" {
  command = plan

  variables {
    bucket_name = "Invalid_Bucket_Name"
  }

  expect_failures = [var.bucket_name]
}
