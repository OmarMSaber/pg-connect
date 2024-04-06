module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block        = "10.0.0.0/16"
  vpc_name              = "my-vpc"
  subnet1_cidr_block    = "10.0.1.0/24"
  subnet2_cidr_block    = "10.0.2.0/24"
  availability_zone1    = "eu-central-1a"
  availability_zone2    = "eu-central-1b"
}

module "rds" {
  source = "./modules/rds"

  db_instance_identifier = "postgres"
  db_name                = "postgres"
  db_username            = "postgres"
  db_password            = "s3cr3t123"
  db_instance_class      = "db.m5d.large"
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.1"
  vpc_security_group_db_ids = [module.vpc.security_group_db_id]
  subnet_ids             = [module.vpc.subnet2_id,module.vpc.subnet1_id]
  db_subnet_group_name   = "my-db-subnet-group"
}
module "ecs" {
  source = "./modules/ecs"

  vpc_id        = module.vpc.vpc_id
  subnet_ids         = [module.vpc.subnet1_id,module.vpc.subnet2_id]
  security_group_ids = [module.vpc.security_group_id]
  security_group_alb_ids = [module.vpc.security_group_alb_id]
  db_host       = module.rds.db_instance_endpoint
  db_name       = module.rds.db_name
  db_username   = module.rds.db_username
  db_password   = module.rds.db_password
}

