output "vpc_id" {
  description = "ID of the staging VPC."
  value       = module.networking.vpc_id
}

output "public_subnet_id" {
  description = "ID of the public subnet."
  value       = module.networking.subnet_id
}

output "internet_gateway_id" {
  description = "ID of the internet gateway."
  value       = module.networking.igw_id
}

output "security_group_id" {
  description = "ID of the app security group -- pass this to verify_security_defaults.sh."
  value       = module.app_security.security_group_id
}

output "instance_id" {
  description = "ID of the EC2 instance."
  value       = module.app_instance.instance_id
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance -- use this for the reachability verification step."
  value       = module.app_instance.public_ip
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket -- use this for the object-acceptance verification step."
  value       = module.s3_app_bucket.bucket_name
}

output "iam_role_name" {
  description = "Name of the EC2 IAM role -- pass this to verify_security_defaults.sh."
  value       = module.ec2_iam_role.role_name
}
