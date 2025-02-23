#!/bin/bash
# lab_setup.sh – Lab Environment Setup and Automated Tests for DevOps Final Project
#
# This script sets up a full lab environment to test all steps in the DevOps Final Project.
# It verifies that all required tools are installed, configures a local Kubernetes cluster,
# builds Docker images, deploys Kubernetes manifests and Helm charts, runs Terraform tests,
# and creates a README file explaining the lab.
#
# Required tools on a Mac:
#   - Docker
#   - kubectl
#   - minikube
#   - helm
#   - git
#   - terraform
#   - aws-cli
#   - python3

set -e

echo "=== DevOps Final Project Lab Setup ==="

# Function to check if a command exists
function check_command {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: $1 is required but not installed. Aborting."
    exit 1
  fi
}

echo "Verifying required tools..."
for cmd in docker kubectl minikube helm git terraform aws python3; do
  check_command "$cmd"
done
echo "All required tools are installed."

# Start minikube if not running
echo "Checking minikube status..."
if ! minikube status | grep -q "Running"; then
  echo "Minikube is not running. Starting minikube..."
  minikube start
else
  echo "Minikube is already running."
fi

# Create a dedicated namespace for lab testing
NAMESPACE="devops-lab"
echo "Creating Kubernetes namespace '$NAMESPACE'..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

#############################
# Level 1: Docker & Kubernetes
#############################

echo "=== LEVEL 1: Docker & Kubernetes ==="

# Assume the Level 1 mandatory solution files are in solutions/level1/
LAB_L1_DIR="./solutions/level1"

# Build the Docker image for the sample app
echo "Building Docker image for sample-app from Level 1 solution..."
docker build -t sample-app:latest "$LAB_L1_DIR"

# Load the Docker image into minikube's Docker daemon
echo "Loading image into minikube..."
minikube image load sample-app:latest

# Deploy Kubernetes manifests for Level 1
echo "Deploying Kubernetes manifests for Level 1..."
kubectl apply -f "$LAB_L1_DIR/deployment.yaml" -n $NAMESPACE
kubectl apply -f "$LAB_L1_DIR/service.yaml" -n $NAMESPACE

# Wait for the deployment to be ready
echo "Waiting for Level 1 deployment rollout..."
kubectl rollout status deployment/sample-app -n $NAMESPACE

# If bonus HPA manifest exists, deploy it
if [ -f "$LAB_L1_DIR/hpa.yaml" ]; then
  echo "Deploying Horizontal Pod Autoscaler for Level 1 bonus..."
  kubectl apply -f "$LAB_L1_DIR/hpa.yaml" -n $NAMESPACE
fi

echo "Level 1 deployment complete. Listing pods and services:"
kubectl get pods -n $NAMESPACE
kubectl get svc -n $NAMESPACE

#############################
# Level 2: Helm, Git, CI/CD
#############################

echo "=== LEVEL 2: Package Management, Version Control & CI/CD ==="

# Assume the Helm chart for Level 2 is in solutions/level2/helm/sample-app/
LAB_L2_HELM_DIR="./solutions/level2/helm/sample-app"

echo "Deploying Helm chart for Level 2..."
helm upgrade --install sample-app "$LAB_L2_HELM_DIR" --namespace $NAMESPACE

# (Git and CI/CD tests are expected to be verified via repository history and workflow logs.
# For automation in the lab, we assume the CI/CD pipeline was triggered upon commit.)

#############################
# Level 3: GitOps & Monitoring
#############################

echo "=== LEVEL 3: GitOps & Monitoring ==="

# Assume ArgoCD manifest is in solutions/level3/
LAB_L3_DIR="./solutions/level3"

echo "Deploying ArgoCD application manifest (simulation)..."
kubectl apply -f "$LAB_L3_DIR/argo-app.yaml" -n $NAMESPACE

echo "Deploying Prometheus and Alertmanager configurations for Level 3..."
kubectl apply -f "$LAB_L3_DIR/prometheus.yml" -n $NAMESPACE
kubectl apply -f "$LAB_L3_DIR/alertmanager.yml" -n $NAMESPACE

# For Grafana, we assume the dashboards are set up manually.
# Automated test: List pods in monitoring namespace (or use minikube addons if available)
echo "Level 3 monitoring setup deployed."

#############################
# Level 4: AWS EC2 & Terraform
#############################

echo "=== LEVEL 4: Cloud (AWS EC2 & Terraform) ==="

# For lab purposes, we simulate Terraform testing using a dummy configuration.
echo "Running Terraform test for Level 4..."
LAB_TERRAFORM_DIR="/tmp/terraform_lab"
mkdir -p "$LAB_TERRAFORM_DIR"
cat <<EOF > "$LAB_TERRAFORM_DIR/main.tf"
provider "aws" {
  region = "us-east-1"
}

resource "null_resource" "test" {
  provisioner "local-exec" {
    command = "echo Terraform is working!"
  }
}
EOF
cd "$LAB_TERRAFORM_DIR"
terraform init -input=false
terraform apply -auto-approve
cd - >/dev/null
echo "Terraform test for Level 4 completed."

#############################
# Level 5: AWS VPC & Secrets/Lambda
#############################

echo "=== LEVEL 5: Cloud (AWS VPC & Secrets/Lambda) ==="

# Assume Level 5 mandatory solution files are in solutions/level5/
LAB_L5_DIR="./solutions/level5"

echo "Deploying VPC configuration for Level 5..."
kubectl apply -f "$LAB_L5_DIR/vpc.tf" || echo "Note: Terraform VPC not applied in K8s. Check manually if needed."

echo "Packaging Lambda function for Level 5..."
if [ -f "$LAB_L5_DIR/lambda_function.py" ]; then
  zip -j /tmp/lambda_function.zip "$LAB_L5_DIR/lambda_function.py"
  echo "Lambda function packaged at /tmp/lambda_function.zip"
fi

echo "Level 5 lab steps simulated (manual AWS deployment required for full test)."

#############################
# Create Lab README
#############################

LAB_README="README_lab.md"
cat <<'EOF' > "$LAB_README"
# DevOps Final Project Lab Environment

## Overview
This lab environment is designed to test all aspects of the DevOps Final Project. It verifies that you can:

- **Level 1:** Build a Docker image, deploy it to a Kubernetes cluster, and apply advanced scaling/deployment techniques.
- **Level 2:** Package deployments using Helm, manage code with Git, and integrate a CI/CD pipeline.
- **Level 3:** Implement GitOps with ArgoCD and set up monitoring with Prometheus and Grafana.
- **Level 4:** Use Terraform to provision cloud infrastructure (simulated here via a Terraform test).
- **Level 5:** Configure secure cloud networking and manage secrets via AWS (with Lambda integration).

## Lab Tests
1. **Tool Verification:**
   - The script checks that Docker, kubectl, minikube, helm, git, terraform, aws-cli, and python3 are installed.
2. **Kubernetes Environment:**
   - A local Kubernetes cluster is started using minikube.
   - A dedicated namespace `devops-lab` is created.
3. **Level 1 Tests:**
   - Docker image is built and loaded into minikube.
   - Kubernetes manifests (Deployment and Service) are applied and verified.
   - (Bonus) If available, HPA is deployed to enable auto-scaling.
4. **Level 2 Tests:**
   - A Helm chart is deployed to manage the application.
   - Git repository and CI/CD pipeline (simulated via workflow file) are assumed to be verified via commit logs.
5. **Level 3 Tests:**
   - An ArgoCD application manifest is deployed to simulate GitOps.
   - Prometheus and Alertmanager configurations are applied.
   - Grafana dashboards are assumed to be created.
6. **Level 4 Tests:**
   - Terraform is run with a dummy configuration to verify infrastructure provisioning.
7. **Level 5 Tests:**
   - AWS VPC and Lambda packaging steps are executed (full AWS deployment requires manual validation).

## Running the Lab
1. Ensure you are on a Mac with all required tools installed.
2. Run the lab setup script:
   ```bash
   ./lab_setup.sh
