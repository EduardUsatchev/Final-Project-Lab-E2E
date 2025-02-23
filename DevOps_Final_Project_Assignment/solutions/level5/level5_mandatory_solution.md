# Level 5 – Mandatory Solution: Cloud (AWS VPC & Secrets/Lambda)

## Overview
Build a secure network on AWS using Terraform and deploy a Lambda function to retrieve a secret from AWS Secrets Manager.

## AWS VPC Setup

**vpc.tf**
\`\`\`hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "main-vpc" }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "public-subnet" }
}
\`\`\`

## Lambda Function and Secrets Management

**lambda_function.py**
\`\`\`python
import boto3
import os

def lambda_handler(event, context):
    secret_name = os.environ.get('SECRET_NAME')
    region_name = os.environ.get('AWS_REGION', 'us-east-1')
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=region_name)
    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret = response['SecretString']
    except Exception as e:
        secret = str(e)
    return {
        'statusCode': 200,
        'body': secret
    }
\`\`\`

## Deliverables
- Terraform files for VPC.
- Lambda function source code.
- Documentation explaining network security and secret management.

---

*This solution demonstrates AWS VPC configuration and secret management using Lambda and Secrets Manager.*
