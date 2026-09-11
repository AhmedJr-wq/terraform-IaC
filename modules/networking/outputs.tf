output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.staging.id
}

output "subnet_id" {
  description = "ID of the public subnet."
  value       = aws_subnet.public.id
}

output "igw_id" {
  description = "ID of the internet gateway."
  value       = aws_internet_gateway.staging.id
}
