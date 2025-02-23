provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_requesting_account_id  = true

  endpoints {
    ec2 = "http://localhost:4566"
    s3  = "http://localhost:4566"
    iam = "http://localhost:4566"
    sts = "http://localhost:4566"
  }
}



resource "aws_instance" "level5_instance" {
  ami                    = "ami-12345678"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.main_subnet.id
  security_groups        = [aws_security_group.instance_sg.id]  # FIX: Reference existing SG

  tags = {
    Name = "level5-instance"
  }
}




resource "aws_ebs_volume" "level5_ebs" {
  availability_zone = "us-east-1a"
  size             = 10
}

resource "aws_volume_attachment" "ebs_attach" {
  device_name = "/dev/xvdf"
  volume_id   = aws_ebs_volume.level5_ebs.id
  instance_id = aws_instance.level5_instance.id
}

resource "aws_security_group" "instance_sg" {
  name        = "instance-security-group"
  description = "Allow HTTP and SSH traffic for EC2 instances"
  vpc_id      = aws_vpc.main_vpc.id  # Ensure this matches your VPC

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
    Name = "instance-security-group"
  }
}
