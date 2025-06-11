provider "aws" {
  region = "us-west-1"
  profile = "IProfile"
}


module "vpc" {
  source = "./vpc"
  environment = var.environment
}


module "ec2" {
 source = "./ec2"
 vpc_id         = module.vpc.vpc_id
 environment    = var.environment
 prv2_subnet_id = module.vpc.prv2_subnet_id

}

module "db" {
  source     = "./db"
  vpc_id     = module.vpc.vpc_id
  ec2_sg     = module.ec2.ec2_sg
  subnet_ids = [module.vpc.prv1_subnet_id, module.vpc.prv2_subnet_id]
  environment    = var.environment
}

module "alb" {
  source             = "./alb"
  vpc_id             = module.vpc.vpc_id
  ec2_sg             = module.ec2.ec2_sg
  public_subnets_ids = [module.vpc.pub1_subnet_id, module.vpc.pub2_subnet_id ]
  instance_id        = module.ec2.instance_id
  environment        = var.environment
  

}


# Egress rule: allows only EC2 to access RDS
resource "aws_security_group_rule" "allow_alb_to_ec2" {
  type                     = "ingress"
  from_port               = 80
  to_port                 = 80
  protocol                = "tcp"
  source_security_group_id = module.ec2.ec2_sg
  security_group_id        = module.alb.alb_sg
}

