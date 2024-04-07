# Deployment README

## Overview

This README provides guidance on deploying the architecture consisting of an ECS (Elastic Container Service) cluster, RDS (Relational Database Service) instance, ALB (Application Load Balancer), and associated resources.

## Deployment Steps

### Step 1: VPC Setup

1. Create a VPC with the specified CIDR block.
2. Attach an internet gateway to enable internet access.
3. Define public and private subnets with associated route tables.
4. Configure NAT gateway for private subnet internet access.
5. Implement security groups for ECS servers, database, and ALB.

### Step 2: ECS Setup

1. Provision an ECS cluster.
2. Define ECS task definition specifying container image, resource requirements, and environment variables.
3. Create an ECS service with desired count and networking configurations.
4. Configure an Application Load Balancer (ALB) to route traffic to ECS tasks.
5. Set up auto-scaling for ECS tasks based on CPU utilization.

### Step 3: RDS Setup

1. Configure an RDS database instance with the desired engine, instance class, and storage.
2. Define security group rules to allow access to the database from ECS servers only.
3. Optionally, set up read replicas for high availability and scalability.

## Terraform Creation Steps

1. Install Terraform: Download and install Terraform from the official website: [Terraform Downloads](https://www.terraform.io/downloads.html).
2. Set Up AWS Credentials: Configure AWS CLI or set AWS access keys as environment variables.
3. Initialize Terraform: Navigate to the directory containing your Terraform configuration files and run `terraform init`.
4. Review and Customize Configuration: Modify the Terraform configuration files (`*.tf`) to match your requirements, including variables, resource settings, and dependencies.
5. Plan Deployment: Run `terraform plan` to preview the changes Terraform will make to your infrastructure.
6. Apply Changes: Execute `terraform apply` to apply the Terraform configuration and create/update AWS resources.
7. Review Output: After successful deployment, Terraform will display outputs containing useful information such as resource IDs and endpoints.
8. Verify Deployment: Validate that the deployed resources match your expectations and are functioning correctly.
9. Destroy Infrastructure (Optional): To tear down the infrastructure, run `terraform destroy` after verifying the deployment.

## Design Decisions

### Public and Private Subnets:

- **Subnet1** is designated as public for resources requiring internet access, like ALB.
- **Subnet2** is marked private to host backend services like the database, ensuring enhanced security by restricting direct internet access.

### Security Groups:

- **ECS Servers Security Group**: Allows HTTP (port 80) and HTTPS (port 443) traffic only from ALB Security Group. This restricts direct access to ECS servers and enhances security.
- **Database Security Group**: Permits PostgreSQL (port 5432) traffic from ECS Servers Security Group to facilitate communication between ECS tasks and the database.
- **ALB Security Group**: Allows HTTP and HTTPS traffic from anywhere, ensuring accessibility to the ALB.

### Auto-scaling:

Auto-scaling is enabled for ECS tasks to dynamically adjust task count based on CPU utilization, ensuring optimal resource utilization and performance.

## Assumptions

1. **Single Region Deployment**: The configuration assumes deployment within a single AWS region (e.g., eu-central-1).
2. **Minimalistic Access Requirements**: The security configurations prioritize security by granting minimum required access between components.
3. **Familiarity with AWS**: Users deploying this architecture are assumed to have a basic understanding of AWS services and Terraform.

By following these deployment steps and design decisions, the architecture ensures a secure, scalable, and well-structured environment for deploying web applications on AWS using ECS and RDS.
