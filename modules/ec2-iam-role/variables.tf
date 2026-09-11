variable "bucket_arn" {
  description = "ARN of the single S3 bucket this role is scoped to. A single ARN (not a list) keeps the 'scoped to one bucket, not s3:*' guarantee structural."
  type        = string
}

variable "project_tag" {
  description = "Project identifier used to name the role/profile."
  type        = string
}
