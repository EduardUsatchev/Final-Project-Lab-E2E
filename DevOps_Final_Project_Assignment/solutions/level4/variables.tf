variable "aws_region" {
  description = "AWS region (LocalStack will ignore this, but Terraform requires it)"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key" {
  description = "AWS access key for authentication"
  type        = string
  default     = "test"
}

variable "aws_secret_key" {
  description = "AWS secret key for authentication"
  type        = string
  default     = "test"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "Fake AMI ID for LocalStack"
  type        = string
  default     = "ami-12345678"
}
