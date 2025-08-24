
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
  default = "15.20.0.0/16"
}

variable "environment" {
    type = string
}

variable "db_username" {
    type = string
    default = "postgres"
}

variable "prefix" {
    type = string
}