# App data bucket. Public access block is hardcoded on here, not exposed as a
# variable -- a caller shouldn't be able to opt out of it.

resource "aws_s3_bucket" "app_data" {
  bucket = var.bucket_name

  tags = {
    Name    = var.bucket_name
    Project = var.project_tag
  }
}

resource "aws_s3_bucket_public_access_block" "app_data" {
  bucket = aws_s3_bucket.app_data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
