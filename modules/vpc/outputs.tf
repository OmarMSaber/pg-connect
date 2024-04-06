# modules/vpc/outputs.tf

output "vpc_id" {
  description = "ID of the created VPC."
  value       = aws_vpc.main.id
}

output "subnet1_id" {
  description = "ID of the created subnet 1."
  value       = aws_subnet.subnet1.id
}

output "subnet2_id" {
  description = "ID of the created subnet 2."
  value       = aws_subnet.subnet2.id
}

output "security_group_id" {
  description = "ID of the created security group."
  value       = aws_security_group.ecs_servers_sg.id
}

output "security_group_db_id" {
  description = "ID of the created security group."
  value       = aws_security_group.database_sg.id
}

output "security_group_alb_id" {
  description = "ID of the created security group."
  value       = aws_security_group.alb_sg.id
}