
variable "vpc_id" {
    type = string
}

variable "subnet_ids" {
    type = list(string
    )
}

variable "final_snapshot_identifier" {
    type = string
    default = "db-techn-final-snapshot"
}

variable "ec2_sg" {
    type = string
}

variable "egress_cidr_block" {
  type = string
  default = "0.0.0.0/0"
}

variable "environment" {
    type = string
}

variable "db_username" {
    type = string
    default = "postgres"
}
