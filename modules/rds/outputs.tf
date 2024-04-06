# modules/rds/outputs.tf

output "db_instance_endpoint" {
  description = "Endpoint of the RDS DB instance."
  value       = aws_db_instance.main.endpoint
}

output "db_instance_id" {
  description = "ID of the RDS DB instance."
  value       = aws_db_instance.main.id
}

output "db_username" {
  value = var.db_username
}

output "db_password" {
  value = var.db_password
}

output "db_name" {
  value = var.db_name
}
