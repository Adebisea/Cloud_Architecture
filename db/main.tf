
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db_techn_subnet_group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "db_techn_subnet_group"
  }
}


resource "aws_db_instance" "default" {
  allocated_storage             = 100
  db_name                       = "db_techn"
  identifier                    = "techn"
  engine                        = "postgres"
  engine_version                = "17.4-R1"
  instance_class                = "db.m5.large"
  manage_master_user_password   = true
  username                      = "postgres"
  deletion_protection           = true
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