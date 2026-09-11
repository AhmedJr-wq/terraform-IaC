variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the single public subnet. Must sit inside vpc_cidr."
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for the public subnet."
  type        = string
}

variable "project_tag" {
  description = "Project identifier applied as the Project tag / Name prefix on every resource."
  type        = string
}
