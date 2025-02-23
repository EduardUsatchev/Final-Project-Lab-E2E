# Level 4 – Mandatory Solution: Cloud (AWS EC2 & Terraform)

## Overview
Deploy a sample web application on AWS EC2 using Terraform.

## Terraform Configuration

**main.tf**
\`\`\`hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "sample_app" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t2.micro"
  tags = {
    Name = "SampleAppServer"
  }
}

output "instance_public_ip" {
  value = aws_instance.sample_app.public_ip
}
\`\`\`

## Steps
1. Initialize Terraform.
2. Apply configuration.
3. Verify EC2 instance is running.

## Deliverables
- Terraform configuration file.
- Evidence of instance provisioning.
- Deployment process report.

---

*This solution demonstrates provisioning of cloud infrastructure using Terraform.*
