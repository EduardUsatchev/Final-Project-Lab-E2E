# Level 4 – Bonus Solution: Advanced Cloud Deployment & Terraform

## Overview
Enhance your AWS deployment with a resilient, high-availability architecture using multi-AZ, auto-scaling, and an Application Load Balancer.

## Terraform Enhancements

**advanced.tf**
\`\`\`hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "main-vpc" }
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "public-subnet-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  tags = { Name = "public-subnet-b" }
}

resource "aws_security_group" "lb_sg" {
  name        = "lb-sg"
  description = "Security group for ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "app_lb" {
  name               = "sample-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

resource "aws_launch_template" "sample_app_lt" {
  name_prefix   = "sample-app-"
  image_id      = "ami-0abcdef1234567890"
  instance_type = "t2.micro"
  key_name      = "your-key-pair"
}

resource "aws_autoscaling_group" "sample_app_asg" {
  name                      = "sample-app-asg"
  launch_template {
    id      = aws_launch_template.sample_app_lt.id
    version = "$Latest"
  }
  min_size                  = 2
  max_size                  = 6
  desired_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
  target_group_arns         = [aws_lb_target_group.sample_app_tg.arn]
  health_check_type         = "EC2"
}

resource "aws_lb_target_group" "sample_app_tg" {
  name     = "sample-app-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sample_app_tg.arn
  }
}

output "lb_dns_name" {
  value = aws_lb.app_lb.dns_name
}
\`\`\`

## Deliverables
- Enhanced Terraform configuration files.
- Updated architecture diagram.
- Bonus report documenting design decisions.

---

*This bonus solution demonstrates advanced cloud deployment strategies for high availability and resilience.*
