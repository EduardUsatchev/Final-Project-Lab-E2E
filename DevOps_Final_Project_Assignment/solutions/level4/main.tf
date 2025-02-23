provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "sample_app" {
  ami           = "ami-0abcdef1234567890"  # Replace with a valid AMI ID for your region
  instance_type = "t2.micro"
  tags = {
    Name = "SampleAppServer"
  }
}

output "instance_public_ip" {
  value = aws_instance.sample_app.public_ip
}
