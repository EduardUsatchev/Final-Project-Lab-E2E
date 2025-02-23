variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "ami_id" {
  default = "ami-12345678"
}

variable "key_name" {
  default = "my-key"
}

variable "ebs_size" {
  default = 10
}
