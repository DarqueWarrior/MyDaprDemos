provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_s3_bucket" "dapr_binding" {
  bucket = var.bucket_name

  tags = {
    Name        = "Dapr Bucket"
    environment = "${var.environment}"
  }
}

resource "aws_s3_bucket_acl" "private_acl" {
  bucket = aws_s3_bucket.dapr_binding.id
  acl    = "private"
}
