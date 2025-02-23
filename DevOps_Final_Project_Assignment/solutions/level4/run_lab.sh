#!/bin/bash
# run_lab.sh for Level 4: AWS EC2 & Terraform Lab
set -e

echo "Running Level 4 Lab..."

echo "Initializing Terraform..."
terraform init

echo "Applying Terraform configuration..."
terraform apply -auto-approve

echo "Retrieving Terraform output..."
IP=\$(terraform output -raw instance_public_ip)
if [ -n "\$IP" ]; then
  echo "Instance public IP: \$IP"
  echo "Level 4 e2e test passed!"
else
  echo "Level 4 e2e test failed: No public IP output."
  exit 1
fi
