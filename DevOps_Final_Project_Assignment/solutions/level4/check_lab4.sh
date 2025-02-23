#!/bin/bash
# check_lab4.sh – End-to-End Check for Student Level 4 Lab (AWS EC2 & Terraform)
#
# Mandatory Files:
#   - main.tf
#   - level4_mandatory_solution.md
#
# Optional Bonus Files:
#   - advanced.tf
#   - level4_bonus_solution.md
#   - architecture_diagram.* (optional)
#
# The script sets environment variables and runs Terraform commands: init, validate, plan, apply, and destroy.
#
# Usage:
#   chmod +x check_lab4.sh
#   ./check_lab4.sh
#

set -e

echo "=== Student Lab Level 4 Check (AWS EC2 & Terraform) ==="

# --- Mandatory Files Check ---
MANDATORY_FILES=("main.tf" "level4_mandatory_solution.md")
for file in "${MANDATORY_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "ERROR: Mandatory file '$file' is missing."
    exit 1
  else
    echo "Found mandatory file: $file"
  fi
done

# --- Optional Bonus Files Check ---
BONUS_FILES=("advanced.tf" "level4_bonus_solution.md")
for file in "${BONUS_FILES[@]}"; do
  if [ -f "$file" ]; then
    echo "Found optional bonus file: $file"
  else
    echo "Optional bonus file '$file' not found."
  fi
done

# Check for an architecture diagram (any file matching the pattern)
ARCH_DIAGRAM=$(find . -maxdepth 1 -type f -iregex ".*architecture_diagram\..*")
if [ -n "$ARCH_DIAGRAM" ]; then
  echo "Found architecture diagram file(s):"
  echo "$ARCH_DIAGRAM"
else
  echo "No architecture diagram file found (optional bonus)."
fi

# --- Check Terraform Installation ---
if ! command -v terraform >/dev/null 2>&1; then
  echo "ERROR: Terraform is required but not installed. Aborting."
  exit 1
fi

# --- Set AWS Provider Environment Variables ---
export AWS_ACCESS_KEY_ID="your_access_key"  # Replace if not using variables.tf defaults
export AWS_SECRET_ACCESS_KEY="your_secret_key"
export AWS_DEFAULT_REGION="us-east-1"
# Uncomment if using LocalStack:
# export AWS_ENDPOINT_URL="http://127.0.0.1:4566"
echo "Using AWS Region: ${AWS_DEFAULT_REGION}"
# If using LocalStack, uncomment:
# echo "Using AWS Endpoint: ${AWS_ENDPOINT_URL}"

# --- Terraform Initialization and Validation ---
echo "Initializing Terraform with upgrade..."
terraform init -input=false -upgrade

echo "Validating Terraform configuration..."
terraform validate

# --- Create Terraform Plan ---
echo "Creating Terraform plan..."
terraform plan -out=tfplan

# --- Apply the Terraform Plan ---
echo "Applying Terraform plan..."
terraform apply -auto-approve tfplan

echo "Terraform apply completed. Terraform outputs (if any):"
terraform output

# --- Destroy Deployed Resources ---
echo "Destroying the deployed resources..."
terraform destroy -auto-approve

echo "All checks for Level 4 lab passed successfully."
