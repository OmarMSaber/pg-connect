# modules/rds/variables.tf

variable "db_instance_identifier" {
  description = "Identifier for the DB instance."
}

variable "db_name" {
  description = "Name of the database to create."
}

variable "db_username" {
  description = "Username for the master DB user."
}

variable "db_password" {
  description = "Password for the master DB password."
}

variable "db_instance_class" {
  description = "The instance class to use."
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes."
}

variable "engine" {
  description = "The name of the database engine."
}

variable "engine_version" {
  description = "The engine version to use."
}

variable "vpc_security_group_db_ids" {
  description = "List of security group IDs."
  type        = list(string)
}

variable "subnet_ids" {
  description = "A list of subnet IDs to launch the DB instance in."
  type        = list(string)
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group."
}
