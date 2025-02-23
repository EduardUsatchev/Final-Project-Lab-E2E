#############################
# VPC and Networking Setup  #
#############################

resource "aws_vpc" "advanced_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "advanced-vpc"
  }
}

resource "aws_internet_gateway" "advanced_igw" {
  vpc_id = aws_vpc.advanced_vpc.id
  tags = {
    Name = "advanced-igw"
  }
}

resource "aws_subnet" "advanced_public_subnet" {
  vpc_id                  = aws_vpc.advanced_vpc.id
  cidr_block              = "10.0.3.0/24" # Updated to avoid conflicts
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "advanced-public-subnet"
  }
}

resource "aws_route_table" "advanced_public_rt" {
  vpc_id = aws_vpc.advanced_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.advanced_igw.id
  }

  tags = {
    Name = "advanced-public-rt"
  }
}

resource "aws_route_table_association" "advanced_rt_assoc" {
  subnet_id      = aws_subnet.advanced_public_subnet.id
  route_table_id = aws_route_table.advanced_public_rt.id
}

#############################
# Security Groups           #
#############################

resource "aws_security_group" "advanced_ec2_sg" {
  name        = "advanced-ec2-sg"
  description = "Allow HTTP and SSH traffic for EC2 instances"
  vpc_id      = aws_vpc.advanced_vpc.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "advanced-ec2-sg"
  }
}

#############################
# EC2 Instance Setup        #
#############################

data "aws_ami" "advanced_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "advanced_ec2" {
  ami                    = data.aws_ami.advanced_amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.advanced_public_subnet.id
  vpc_security_group_ids = [aws_security_group.advanced_ec2_sg.id]
  key_name               = "my-key"  # Add this line


  user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install -y nginx git
    git clone https://github.com/your-org/sample-app.git /var/www/html/sample-app
    sudo systemctl start nginx
    sudo systemctl enable nginx
  EOF

  tags = {
    Name = "advanced-ec2-instance"
  }
}
