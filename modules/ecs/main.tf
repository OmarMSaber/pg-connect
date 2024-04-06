# modules/ecs/main.tf

resource "aws_ecs_cluster" "main" {
  name = "my-ecs-cluster"
}

resource "aws_ecs_task_definition" "main" {
  family                   = "my-task-definition"
  network_mode             = "awsvpc"
  cpu                      = "2048"
  memory                   = "4096"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.ecs_container_name}"
      image     = "ghcr.io/sosafe-cloud-engineering/pg-connect:amd64"
      cpu       = 512
      memory    = 1024
      portMappings = [
        {
          containerPort = 8000,
          hostPort      = 8000,
          protocol      = "tcp"
        }
      ],
      environment = [
        {
          name  = "DB_HOST",
        #   value = "postgres://${var.db_username}@${var.db_host}/${var.db_username}"
          value = var.db_host
        },
        {
          name  = "DB_NAME",
          value = var.db_name
        },
        {
          name  = "DB_USERNAME",
          value = var.db_username
        },
        # {
        #   name  = "DB_PASSWORD",
        #   value = {"username":"postgres","password":"s3cr3t123"}
        # },
        {
          name  = "DB_PASSWORD",
          value = jsonencode({
            username = "postgres",
            password = "s3cr3t123"
          })
        }
      ]
      logConfiguration = {   # Highlighted code: Adding logging configuration
        logDriver = "awslogs"
        options = {
          "awslogs-group"  = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region" = var.region
          "awslogs-stream-prefix" = "my-ecs-task"
        }
    }
    }
  ])
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/my-ecs-logs"
  retention_in_days = 14  # Optional: Set retention period for logs
}

resource "aws_ecs_service" "main" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  deployment_controller {
    type = "ECS"
  }
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = true
  }
  lifecycle {
    ignore_changes = [desired_count]  # Optional: Ignore changes to desired count after service creation
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_alb_target_group.arn
    container_name   = var.ecs_container_name
    container_port   = 8000
  }
}
## Roles for running ecs

# modules/ecs/main.tf

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs-task-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "ecs-task-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "ecs_task_policy" {
  name        = "ecs-task-policy"
  description = "Policy for ECS task"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "*"
      },
      {   # Highlighted code: Adding IAM policy to access RDS
        Effect   = "Allow",
        Action    = [
          "rds:DescribeDBInstances",  # Allow describing RDS instances
          "rds-db:connect"            # Allow connecting to RDS databases
        ],

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_policy.arn
}

##### ALB

## ALB

resource "aws_lb" "ecs_alb" {
  name                   = var.alb_name
  internal               = false
  load_balancer_type     = "application"
  security_groups        = var.security_group_alb_ids
  subnets                = var.subnet_ids
  idle_timeout           = 60
  enable_http2           = true
  desync_mitigation_mode = "defensive"
}

## ALB Target Group

resource "aws_lb_target_group" "ecs_alb_target_group" {
  name                          = var.alb_target_group_name
  target_type                   = "ip"
  port                          = 8000
  protocol                      = "HTTP"
  vpc_id                        = var.vpc_id
  load_balancing_algorithm_type = "round_robin"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
  }
}

## ALB Target Group Listerner

resource "aws_alb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 8000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_alb_target_group.arn
  }
}
