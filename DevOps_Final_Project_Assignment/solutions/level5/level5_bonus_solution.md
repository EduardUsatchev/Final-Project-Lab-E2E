# Level 5 – Bonus Solution: Advanced AWS VPC & Serverless Security

## Overview
Enhance the secure AWS setup with additional security measures such as network ACLs, enhanced Lambda functionality with simulated MFA checks, and CloudWatch alarms for monitoring.

## VPC Enhancements

**Example ACL in Terraform:**
\`\`\`hcl
resource "aws_network_acl" "main_acl" {
  vpc_id = aws_vpc.main.id

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "10.0.0.0/16"
    from_port  = 80
    to_port    = 80
  }
  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }
  tags = { Name = "main-acl" }
}
\`\`\`

## Enhanced Lambda Function

**lambda_function_bonus.py**
\`\`\`python
import boto3
import os
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    secret_name = os.environ.get('SECRET_NAME')
    region_name = os.environ.get('AWS_REGION', 'us-east-1')
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=region_name)
    try:
        response = client.get_secret_value(SecretId=secret_name)
        secret = response['SecretString']
        if not event.get('mfa_verified', False):
            logger.warning("MFA not verified! Triggering security alert.")
    except Exception as e:
        secret = str(e)
        logger.error("Error retrieving secret: " + secret)
    return {
        'statusCode': 200,
        'body': secret
    }
\`\`\`

## CloudWatch Alarm Example

**cloudwatch_alarm.tf**
\`\`\`hcl
resource "aws_cloudwatch_metric_alarm" "lambda_alarm" {
  alarm_name          = "LambdaSecurityAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Alarm if Lambda function errors exceed 1 in 60 seconds."
  dimensions = {
    FunctionName = "YourLambdaFunctionName"
  }
}
\`\`\`

## Deliverables
- Updated Terraform configurations with additional security measures.
- Enhanced Lambda function code.
- CloudWatch alarm configuration evidence.
- Bonus report explaining the advanced security improvements.

---

*This bonus solution demonstrates an advanced, secure, serverless architecture on AWS.*
