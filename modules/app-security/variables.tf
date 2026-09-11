variable "vpc_id" {
  description = "VPC the security group belongs to."
  type        = string
}

variable "allowed_cidr" {
  description = "CIDR allowed to reach every ingress port opened by this module. Must be a specific IP/range you control."
  type        = string

  validation {
    condition     = var.allowed_cidr != "0.0.0.0/0"
    error_message = "allowed_cidr must never be 0.0.0.0/0 -- restrict to a specific IP/CIDR you control (spec section 4)."
  }
}

variable "ingress_ports" {
  description = "TCP ports to open, each restricted to allowed_cidr."
  type        = list(number)
  default     = [22, 8080]
}

variable "project_tag" {
  description = "Project identifier applied as the Project tag / Name prefix."
  type        = string
}
