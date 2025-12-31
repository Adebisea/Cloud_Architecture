provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket = "tf-state-microservices-app-deploy"
    key    = "prod/terraform.tfstate"
    region = "eu-west-1"
  }
}

module "vpc" {
  source = "./vpc"
  environment = var.environment
  prefix = var.prefix
}


module "ec2" {
 source = "./ec2"
 vpc_id         = module.vpc.vpc_id
 environment    = var.environment
 prv2_subnet_id = module.vpc.prv2_subnet_id
 prefix = var.prefix
 secret_arn = module.db.secret_arn

}

module "db" {
  source     = "./db"
  vpc_id     = module.vpc.vpc_id
  ec2_sg     = module.ec2.ec2_sg
  subnet_ids = [module.vpc.prv1_subnet_id, module.vpc.prv2_subnet_id]
  prefix = var.prefix
  environment    = var.environment
}

module "alb" {
  source             = "./alb"
  vpc_id             = module.vpc.vpc_id
  ec2_sg             = module.ec2.ec2_sg
  public_subnets_ids = [module.vpc.pub1_subnet_id, module.vpc.pub2_subnet_id ]
  instance_id        = module.ec2.instance_id
  prefix = var.prefix
  environment        = var.environment
  

}
resource "aws_s3_bucket" "example" {
  bucket = "technn-deployment-bucket"

  tags = {
    Environment = var.environment
  }
}

module "github-oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "~> 2"

  create_oidc_provider = true
  create_oidc_role     = true

  repositories              = ["Adebisea/Cloud_Architecture"]
  oidc_role_attach_policies = [    
                                   "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore", 
                                   "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess",
                                   
                              ]
}

resource "aws_iam_role_policy" "github_oidc_s3_policy" {
  name = "github-s3-access"
  role = "github-oidc-provider-aws"
  depends_on = [module.github-oidc]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::technn-deployment-bucket",
          "arn:aws:s3:::technn-deployment-bucket/*"
        ]
      }
    ]
  })
}

# # Egress rule: allows only EC2 to access RDS
# resource "aws_security_group_rule" "allow_alb_to_ec2" {
#   type                     = "ingress"
#   from_port               = 80
#   to_port                 = 80
#   protocol                = "tcp"
#   source_security_group_id = module.ec2.ec2_sg
#   security_group_id        = module.alb.alb_sg
# }

