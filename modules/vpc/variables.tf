# modules/vpc/variables.tf

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC."
}

variable "vpc_name" {
  description = "Name tag for the VPC."
}

variable "subnet1_cidr_block" {
  description = "CIDR block for subnet 1."
}

variable "subnet2_cidr_block" {
  description = "CIDR block for subnet 2."
}

variable "availability_zone1" {
  description = "Availability zone for subnet 1."
}

variable "availability_zone2" {
  description = "Availability zone for subnet 2."
}
