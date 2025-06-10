variable "algorithm" {
    type    = string
    default = "RSA"
}

variable " rsa_bits" {
  type = string
  default = 4096
}

variable "environment" {
  type = string
  default = "Production"
}

variable "instance_type" {
    type    = string
    default = "t2.micro"
}

variable "dest_cidr_block" {
  type = string
  default = "0.0.0.0/0"
}

variable "vpc_id" {
  type = string
}


variable "prv2_subnet_id" {
  type = string
}