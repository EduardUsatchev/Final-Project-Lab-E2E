provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  endpoints {
    ec2 = "http://localhost:4566"
  }
}

resource "aws_instance" "sample_app_instance" {
  ami                    = "ami-12345678"
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
    Name = "sample-app-instance"
  }
}
