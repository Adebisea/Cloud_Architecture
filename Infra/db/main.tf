
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db_techn_subnet_group-${var.prefix}"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "db_techn_subnet_group"
    Environment = var.environment
  }
}

#db security group
resource "aws_security_group" "db_traffic" {
  name        = "db_traffic"
  description = "Allow inbound traffic from ec2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [var.ec2_sg]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.egress_cidr_block]
  }
}

resource "aws_db_instance" "db_techn" {
  allocated_storage             = 100
  db_name                       = "db_techn"
  identifier                    = "techn-${var.prefix}"
  engine                        = "postgres"
  engine_version                = "17.4"
  instance_class                = "db.m5.large"
  manage_master_user_password   = true
  username                      = var.db_username
  deletion_protection           = true
  storage_encrypted             = true
  db_subnet_group_name          = aws_db_subnet_group.db_subnet.id
  backup_retention_period       = 14
  final_snapshot_identifier     = var.final_snapshot_identifier
  backup_window                 = "01:00-02:00"
  maintenance_window            = "Sun:03:00-Sun:04:00"


  tags = {
    Name = "db_techn"
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "secret" {
  name        = "/db/secret_name"
  type        = "SecureString"
  value       = aws_db_instance.db_techn.master_user_secret[0].secret_arn

  tags = {
    environment = var.environment
  }
}

resource "aws_ssm_parameter" "host" {
  name        = "/db/host"
  description = "The parameter description"
  type        = "SecureString"
  value       = aws_db_instance.db_techn.address

  tags = {
    environment = var.environment
  }
}


resource "aws_ssm_parameter" "username" {
  name        = "/db/username"
  type        = "SecureString"
  value       = var.db_username

  tags = {
    environment = var.environment
  }
}