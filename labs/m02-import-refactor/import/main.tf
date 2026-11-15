import {
  to = aws_s3_bucket.existing
  id = var.existing_bucket_name
}

resource "aws_s3_bucket" "existing" {
  bucket = var.existing_bucket_name

  tags = {
    ManagedBy = "terraform"
    Imported  = "true"
  }
}

resource "aws_s3_bucket_versioning" "existing" {
  bucket = aws_s3_bucket.existing.id

  versioning_configuration {
    status = "Enabled"
  }
}
