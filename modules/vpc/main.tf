# modules/vpc/main.tf

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route" "internet_gateway_route" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id

}

resource "aws_subnet" "subnet1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet1_cidr_block
  availability_zone       = var.availability_zone1
  map_public_ip_on_launch = true  # Make subnet1 public

  tags = {
    Name = "${var.vpc_name}-subnet1"
    type = "public-subnet"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet2_cidr_block
  availability_zone       = var.availability_zone2

  tags = {
    Name = "${var.vpc_name}-subnet2",
    type = "private-subnet"
  }
}

resource "aws_security_group" "ecs_servers_sg" {
  name        = "ecs_servers_sg"
  description = "Security group for ecs servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Allow traffic only from the alb security group
  }

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Allow traffic only from the alb security group
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"] # Allow outbound traffic to anywhere. Adjust as per your requirements
  }

  tags = {
    Name = "ecs_servers_sg"
  }
}

resource "aws_security_group" "database_sg" {
  name        = "database-sg"
  description = "Security group for database servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = "5432"
    to_port         = "5432"
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_servers_sg.id]  # Allow traffic only from the ecs_servers_sg security group
  }

  egress {
    from_port       = "0"
    to_port         = "0"
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"] # Allow outbound traffic to anywhere. Adjust as per your requirements
  }

  tags = {
    Name = "database-sg"
  }
}
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet1.id
}

resource "aws_eip" "nat_eip" {
  domain  = "vpc"
}

resource "aws_route" "nat_gateway_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}


## ALB
resource "aws_security_group" "alb_sg" {
  name        = "alb_sg"
  description = "Security group for loadbalancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"] # Allow outbound traffic to anywhere. Adjust as per your requirements
  }

  tags = {
    Name = "ecs_lb_sg"
  }
}