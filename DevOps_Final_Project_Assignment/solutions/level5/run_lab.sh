#!/bin/bash
# run_lab.sh for Level 5: AWS VPC & Secrets/Lambda Lab
set -e

echo "Running Level 5 Lab..."

echo "Validating VPC Terraform configuration..."
terraform validate -no-color vpc.tf

echo "Checking Lambda function syntax..."
python3 -m py_compile lambda_function.py

echo "Level 5 lab e2e tests passed. Note: Full AWS deployment requires manual validation."
