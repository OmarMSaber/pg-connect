# modules/rds/main.tf
resource "aws_db_subnet_group" "main" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = {
    Name = var.db_instance_identifier
  }
}
resource "aws_db_instance" "main" {
  identifier           = var.db_instance_identifier
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.db_instance_class
  allocated_storage    = var.allocated_storage
  db_name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  publicly_accessible = false
  multi_az                 = true
  backup_retention_period  = 7 # Set the number of days for automatic backups

  vpc_security_group_ids = var.vpc_security_group_db_ids
  db_subnet_group_name      = aws_db_subnet_group.main.name

  tags = {
    Name = var.db_instance_identifier
  }
}
# Read replica
resource "aws_db_instance" "read_replica" {
  identifier             = "${var.db_instance_identifier}-read-replica"
  engine                 = aws_db_instance.main.engine
  instance_class         = aws_db_instance.main.instance_class
  allocated_storage      = aws_db_instance.main.allocated_storage
  replicate_source_db = aws_db_instance.main.identifier  # Set source DB instance
  publicly_accessible   = false
  multi_az               = aws_db_instance.main.multi_az  # Use the same multi-AZ setting as primary instance

  vpc_security_group_ids = var.vpc_security_group_db_ids
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name = "${var.db_instance_identifier}-read-replica"
  }
}