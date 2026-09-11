# EC2 instance role scoped to exactly one bucket ARN -- a caller can't widen
# this to s3:* without changing the module itself.

resource "aws_iam_role" "app" {
  name = "${var.project_tag}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  tags = {
    Project = var.project_tag
  }
}

resource "aws_iam_role_policy" "app_s3_access" {
  name = "${var.project_tag}-s3-access"
  role = aws_iam_role.app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid      = "AllowAppBucketReadWrite"
      Effect   = "Allow"
      Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
      Resource = [var.bucket_arn, "${var.bucket_arn}/*"]
    }]
  })
}

resource "aws_iam_instance_profile" "app" {
  name = "${var.project_tag}-ec2-profile"
  role = aws_iam_role.app.name
}
