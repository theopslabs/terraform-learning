resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "demo" {
  bucket = "${var.project_name}-remote-state-demo-${random_id.suffix.hex}"

  tags = {
    Name      = "Remote state demo bucket"
    ManagedBy = "terraform"
  }
}
