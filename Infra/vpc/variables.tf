variable "vpc_cidr_block" {
  type    = string
  default = "15.20.0.0/16"
}

variable "pub1_subnet_cidr_block" {
  type    = string
  default = "15.20.25.0/24"
}

variable "pub2_subnet_cidr_block" {
  type    = string
  default = "15.20.30.0/24"
}

variable "prv1_subnet_cidr_block" {
  type    = string
  default = "15.20.35.0/24"
}

variable "prv2_subnet_cidr_block" {
  type    = string
  default = "15.20.40.0/24"
}

variable "environment" {
  type = string
}

variable "prefix" {
    type = string
}
