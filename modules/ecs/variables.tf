# modules/ecs/variables.tf

variable "vpc_id" {
  description = "ID of the VPC."
}

variable "subnet_ids" {
  description = "List of subnet IDs."
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs."
  type        = list(string)
}


variable "db_host" {
  description = "Hostname of the RDS database."
}

variable "db_name" {
  description = "Name of the RDS database."
}

variable "db_username" {
  description = "Username for the RDS database."
}

variable "db_password" {
  description = "Password for the RDS database."
}

variable "region" {
  description = "AWS region where resources will be provisioned."
  default     = "eu-central-1"
}

variable "ecs_container_name"{
  type    = string
  default = "app-container"  
}
## ALB

variable "alb_name" {
  type    = string
  default = "ecs-alb"
}

## ALB Target Group

variable "alb_target_group_name" {
  type        = string
  default     = "ecs-tg"
}

variable "security_group_alb_ids" {
  description = "List of security group alb ."
  type        = list(string)
}
