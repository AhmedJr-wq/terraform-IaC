output "bucket_arn" {
  description = "ARN of the app data bucket."
  value       = aws_s3_bucket.app_data.arn
}

output "bucket_name" {
  description = "Name of the app data bucket."
  value       = aws_s3_bucket.app_data.bucket
}
