# main.tf placeholder
# Modules usage

module "vpc" {
  source      = "./modules/vpc"
  vpc_cidr    = var.vpc_cidr
  Environment = var.Environment
  Owner       = var.Owner
}

module "nat_gateway" {
  source           = "./modules/nat_gateway"
  vpc_id           = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_1_id
  Environment      = var.Environment
  Owner            = var.Owner
}

module "route_tables" {
  source             = "./modules/route_tables"
  vpc_id             = module.vpc.vpc_id
  igw_id             = module.nat_gateway.igw_id
  nat_gateway_id     = module.nat_gateway.nat_gateway_id
  public_subnet_ids  = [module.vpc.public_subnet_1_id]
  private_subnet_ids = [module.vpc.private_subnet_1_id]
  Environment        = var.Environment
  Owner              = var.Owner
}

module "security_groups" {
  source      = "./modules/security_groups"
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = var.vpc_cidr
  Environment = var.Environment
  Owner       = var.Owner
}

module "ec2_key_pair" {
  source = "./modules/ec2_key_pair"
}

module "autoscaling" {
  source               = "./modules/autoscaling"
  public_subnet_ids    = [module.vpc.public_subnet_1_id, module.vpc.public_subnet_1_id]
  alb_target_group_arn = module.load_balancer.target_group_arn
  ami                  = var.ami
  instance_type        = var.instance_type
  public_sg            = module.security_groups.public_sg
  key_name             = module.ec2_key_pair.key_name
  rds_endpoint         = module.rds.rds_endpoint
  Environment          = var.Environment
  Owner                = var.Owner
}

module "load_balancer" {
  source            = "./modules/load_balancer"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = [module.vpc.public_subnet_1_id, module.vpc.public_subnet_2_id]
  alb_sg            = module.security_groups.public_sg
  Environment       = var.Environment
  Owner             = var.Owner
}

module "rds" {
  source             = "./modules/rds"
  private_subnet_ids = [module.vpc.private_subnet_1_id, module.vpc.private_subnet_2_id]
  rds_sg_id          = module.security_groups.rds_sg
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  Environment        = var.Environment
  Owner              = var.Owner
}
