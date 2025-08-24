variable "algorithm" {
    type    = string
    default = "RSA"
}

variable "rsa_bits" {
  type = string
  default = 4096
}

variable "environment" {
  type = string
}

variable "instance_type" {
    type    = string
    default = "t2.micro"
}

variable "ssh_cidr_block" {
  type = string
  default = "15.20.0.0/16"
}

variable "egress_cidr_block" {
  type = string
  default = "0.0.0.0/0"
}

variable "vpc_id" {
  type = string
}


variable "prv2_subnet_id" {
  type = string
}

variable "prefix" {
    type = string
}

variable "secret_arn" {
    type = string
}

