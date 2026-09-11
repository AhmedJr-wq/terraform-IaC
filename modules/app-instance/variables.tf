variable "ami_id" {
  description = "AMI ID for the instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "subnet_id" {
  description = "Subnet the instance launches into."
  type        = string
}

variable "security_group_id" {
  description = "Security group attached to the instance."
  type        = string
}

variable "instance_profile_name" {
  description = "IAM instance profile attached to the instance."
  type        = string
}

variable "project_tag" {
  description = "Project identifier applied as the Name/Project tag."
  type        = string
}
