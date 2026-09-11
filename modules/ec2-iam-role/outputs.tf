output "role_name" {
  description = "Name of the EC2 IAM role."
  value       = aws_iam_role.app.name
}

output "instance_profile_name" {
  description = "Name of the EC2 instance profile."
  value       = aws_iam_instance_profile.app.name
}
