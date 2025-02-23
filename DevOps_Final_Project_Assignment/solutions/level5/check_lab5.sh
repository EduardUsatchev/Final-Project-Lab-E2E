#!/bin/bash

echo "=== Student Lab Level 5 Check (AWS EC2 & EBS with Terraform) ==="

# Define mandatory files
MANDATORY_FILES=("main.tf" "variables.tf" "outputs.tf" "level5_mandatory_solution.md")
OPTIONAL_FILES=("advanced.tf" "level5_bonus_solution.md")

# Function to check file existence
check_files() {
    local files=("$@")
    for file in "${files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "✅ Found: $file"
        else
            echo "❌ Missing: $file"
            EXIT_STATUS=1
        fi
    done
}

# Check mandatory and optional files
EXIT_STATUS=0
check_files "${MANDATORY_FILES[@]}"
check_files "${OPTIONAL_FILES[@]}"

# Initialize Terraform
echo "🔄 Initializing Terraform..."
terraform init -upgrade -no-color &> /dev/null
if [[ $? -ne 0 ]]; then
    echo "❌ Terraform initialization failed!"
    EXIT_STATUS=1
else
    echo "✅ Terraform initialized successfully."
fi

# Validate Terraform configuration
echo "🔍 Validating Terraform configuration..."
terraform validate -no-color &> /dev/null
if [[ $? -ne 0 ]]; then
    echo "❌ Terraform validation failed!"
    EXIT_STATUS=1
else
    echo "✅ Terraform configuration is valid."
fi

# Run Terraform plan (dry run)
echo "🛠️ Running Terraform plan..."
terraform plan -no-color &> /dev/null
if [[ $? -ne 0 ]]; then
    echo "❌ Terraform plan failed!"
    EXIT_STATUS=1
else
    echo "✅ Terraform plan successful."
fi

# Check running EC2 instances
echo "🔍 Checking running EC2 instances..."
INSTANCE_ID=$(awslocal ec2 describe-instances --query "Reservations[].Instances[?State.Name=='running'].InstanceId" --output text)
if [[ -z "$INSTANCE_ID" ]]; then
    echo "❌ No running EC2 instances found!"
    EXIT_STATUS=1
else
    echo "✅ Found running EC2 instance: $INSTANCE_ID"
fi

# Check public IP
echo "🔍 Checking public IP..."
PUBLIC_IP=$(awslocal ec2 describe-instances --query "Reservations[].Instances[?State.Name=='running'].PublicIpAddress" --output text)
if [[ -z "$PUBLIC_IP" ]]; then
    echo "❌ No public IP assigned!"
    EXIT_STATUS=1
else
    echo "✅ EC2 Instance has public IP: $PUBLIC_IP"
fi

# Check if sample application is accessible
echo "🌐 Checking sample application deployment..."
curl --connect-timeout 5 -s "http://$PUBLIC_IP" &> /dev/null
if [[ $? -ne 0 ]]; then
    echo "❌ Sample application is not accessible!"
    EXIT_STATUS=1
else
    echo "✅ Sample application is running at http://$PUBLIC_IP"
fi

# Check security group rules
echo "🔐 Checking security group rules..."
SG_ID=$(awslocal ec2 describe-instances --query "Reservations[].Instances[].SecurityGroups[].GroupId" --output text)
ALLOWED_HTTP=$(awslocal ec2 describe-security-groups --group-ids "$SG_ID" --query "SecurityGroups[].IpPermissions[?FromPort==\`80\`]" --output text)
ALLOWED_SSH=$(awslocal ec2 describe-security-groups --group-ids "$SG_ID" --query "SecurityGroups[].IpPermissions[?FromPort==\`22\`]" --output text)

if [[ -z "$ALLOWED_HTTP" ]]; then
    echo "❌ Security Group does not allow HTTP (80)"
    EXIT_STATUS=1
else
    echo "✅ Security Group allows HTTP (80)"
fi

if [[ -z "$ALLOWED_SSH" ]]; then
    echo "❌ Security Group does not allow SSH (22)"
    EXIT_STATUS=1
else
    echo "✅ Security Group allows SSH (22)"
fi

# Check EBS volume attachment (if applicable)
echo "🖴 Checking EBS volume attachment..."
EBS_VOLUME=$(awslocal ec2 describe-volumes --query "Volumes[?State=='in-use'].VolumeId" --output text)
if [[ -z "$EBS_VOLUME" ]]; then
    echo "❌ No EBS volumes attached."
else
    echo "✅ Found attached EBS volume: $EBS_VOLUME"
fi

# Final status
if [[ $EXIT_STATUS -eq 0 ]]; then
    echo "✅✅✅ Level 5 Lab Check Passed! ✅✅✅"
else
    echo "❌❌❌ Level 5 Lab Check Failed! ❌❌❌"
    exit 1
fi
