module "dev_bucket" {
  source = "./modules/s3_bucket"

  bucket_prefix = "${var.project_name}-dev"
  environment   = "dev"
  project_name  = var.project_name
}

module "staging_bucket" {
  source = "./modules/s3_bucket"

  bucket_prefix = "${var.project_name}-staging"
  environment   = "staging"
  project_name  = var.project_name
}
