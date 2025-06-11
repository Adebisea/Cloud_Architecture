
variable "vpc_id" {
    type = list(string
    )
}

variable "subnet_ids" {
    type = list(string
    )
}

variable "final_snapshot_identifier" {
    type = string
    default = "db_techn_final_snapshot"
}

variable "ingress_cidr_block" {
  type = string
  default = "15.20.40.0/24"
}

variable "egress_cidr_block" {
  type = string
  default = "0.0.0.0/0"
}