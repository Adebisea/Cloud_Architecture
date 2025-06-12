variable "environment" {
    type = string
}

variable "vpc_id" {
    type = string
}

variable "instance_id" {
    type = string
}

variable "ec2_sg" {
    type = string
}

variable "public_subnets_ids" {
    type = list(string)
}

variable "prefix" {
    type = string
}