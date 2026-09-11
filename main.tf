# --- Networking -------------------------------------------------------------

module "networking" {
  source = "./modules/networking"

  vpc_cidr          = var.vpc_cidr
  subnet_cidr       = var.public_subnet_cidr
  availability_zone = var.availability_zone
  project_tag       = var.project_tag
}

# --- Security group -----------------------------------------------------------

module "app_security" {
  source = "./modules/app-security"

  vpc_id       = module.networking.vpc_id
  allowed_cidr = var.allowed_ssh_cidr
  project_tag  = var.project_tag
}

# --- Storage -------------------------------------------------------------------

module "s3_app_bucket" {
  source = "./modules/s3-app-bucket"

  bucket_name = "${var.project_tag}-${var.bucket_name_suffix}"
  project_tag = var.project_tag
}

# --- IAM: EC2 instance role scoped to its own bucket -------------------------

module "ec2_iam_role" {
  source = "./modules/ec2-iam-role"

  bucket_arn  = module.s3_app_bucket.bucket_arn
  project_tag = var.project_tag
}

# --- Compute -------------------------------------------------------------------

module "app_instance" {
  source = "./modules/app-instance"

  ami_id                = var.ami_id
  instance_type         = var.instance_type
  subnet_id             = module.networking.subnet_id
  security_group_id     = module.app_security.security_group_id
  instance_profile_name = module.ec2_iam_role.instance_profile_name
  project_tag           = var.project_tag
}
