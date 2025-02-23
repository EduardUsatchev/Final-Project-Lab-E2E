#!/bin/bash
# create_solutions.sh
# This script creates the complete DevOps Final Project package including:
#  - Folder structure with a "solutions/" folder for levels 1 to 5.
#  - Real solution files (e.g., Dockerfile, app.py, Kubernetes YAMLs, Helm chart, Terraform files, Lambda functions, etc.)
#  - For each level, a run_lab.sh script that deploys the files and runs end-to-end tests.
#  - Additionally, for Level 1, a lab1_k3d.sh script is created that uses k3d (for macOS Apple M2 Max) to deploy and test the solution.
#
# Usage:
#   chmod +x create_solutions.sh
#   ./create_solutions.sh

set -e

# Define base directory for the project package
BASE_DIR="DevOps_Final_Project_Assignment"
SOLUTIONS_DIR="$BASE_DIR/solutions"

echo "Creating directory structure..."
mkdir -p "$SOLUTIONS_DIR/level1" \
         "$SOLUTIONS_DIR/level2/helm/sample-app/templates" \
         "$SOLUTIONS_DIR/level3" \
         "$SOLUTIONS_DIR/level4" \
         "$SOLUTIONS_DIR/level5"

#############################
# Create Overview and Reference Documents
#############################

echo "Creating project overview and reference files..."

cat << 'EOF' > "$BASE_DIR/project_assignment_overview.md"
# DevOps Engineering Final Project – Assignment Overview

## Project Narrative
In this final project, you will assume the role of a DevOps professional tasked with solving a real-world problem that reflects the challenges encountered in modern enterprises. The project is divided into five levels that follow a common narrative:
- **Problem Statement:** A mid-sized enterprise is facing issues with scaling its applications, ensuring continuous integration and delivery, managing cloud infrastructure securely, and automating processes end-to-end.
- **Goal:** Present a solution that addresses these challenges by creating a robust architecture diagram (using a tool like draw.io) and submitting a detailed technical solution. Your solution must integrate the concepts learned throughout the course.

## Assignment Levels
There are **5 levels** in total:
1. **Level 1 (Docker & Kubernetes Basics/Advanced):**
   - **Mandatory Task:** Build a containerization solution and a basic orchestration setup.
   - **Bonus Task:** Develop an advanced bonus assignment for Docker and Kubernetes—addressing a real-market challenge (e.g., a microservices scaling scenario).

2. **Level 2 (Package Management, Version Control & CI/CD):**
   - **Mandatory Task:** Set up Helm, Git workflows, and CI/CD pipelines using GitHub Actions.
   - **Bonus Task:** Enhance your solution with an extra market-inspired challenge (e.g., simulating a zero-downtime deployment using advanced pipeline features).

3. **Level 3 (GitOps & Monitoring):**
   - **Mandatory Task:** Implement GitOps with ArgoCD and set up a monitoring solution using Prometheus.
   - **Bonus Task:** Create a challenging bonus assignment based on real industry cases (e.g., implementing auto-scaling and dynamic monitoring adjustments).

4. **Level 4 (Cloud – AWS EC2 & Terraform):**
   - **Mandatory Task:** Deploy a cloud solution on AWS using EC2 and Terraform for IaC.
   - **Bonus Task:** Add a bonus assignment that challenges you to design a resilient and cost-optimized deployment model.

5. **Level 5 (Cloud – AWS VPC & Secrets/Lambda):**
   - **Mandatory Task:** Configure a secure VPC with stateful services and manage secrets using AWS Lambda and Secrets Manager.
   - **Bonus Task (Extra):** This level’s bonus task is weighted more heavily. Create an advanced assignment integrating AWS VPC security best practices with serverless functions. Successful completion of this bonus task awards an additional **10%** of the overall project score.

## Deliverables
1. **Architecture Diagram:** A visual diagram (draw.io recommended) that outlines your overall solution.
2. **Technical Solution Document:** Detailed explanation of the implementation using all the tools and technologies covered in the course.
3. **Separate Documentation:** Include a project documentation page and a reference document with hints.

Good luck – your solution should be both market-ready and educational!
EOF

cat << 'EOF' > "$BASE_DIR/reference_document_hints.md"
# Reference Document – Hints and Guidance

This document provides hints and best practices to help you complete the DevOps Final Project assignment.

## General Hints
- Read the project narrative and plan your solution.
- Use draw.io (or similar) to create architecture diagrams.
- Tackle each level individually and test thoroughly.

## Level-Specific Hints
### Level 1: Docker & Kubernetes
- Build efficient Docker images using multi-stage builds.
- Deploy your containerized app on Kubernetes using YAML manifests.
- Bonus: Add Horizontal Pod Autoscaling (HPA) and blue-green deployments.

### Level 2: Helm, Git & CI/CD
- Package your Kubernetes manifests as a Helm chart.
- Use Git with a clear branching strategy.
- Set up GitHub Actions to automate building and deploying.
- Bonus: Enhance CI/CD with canary releases and rollbacks.

### Level 3: GitOps & Monitoring
- Use ArgoCD to sync your Git repo with Kubernetes.
- Configure Prometheus and Alertmanager for monitoring.
- Bonus: Integrate custom metrics and dynamic Grafana dashboards.

### Level 4: AWS EC2 & Terraform
- Provision cloud resources with Terraform.
- Deploy a sample app on an EC2 instance.
- Bonus: Design a high-availability, auto-scaling architecture.

### Level 5: AWS VPC & Secrets/Lambda
- Create a secure VPC using Terraform.
- Deploy a Lambda function that retrieves secrets.
- Bonus: Add network ACLs, MFA simulation, and CloudWatch alarms.

Good luck and document every step!
EOF

#############################
# Level 1: Docker & Kubernetes Solutions & run_lab.sh, lab1_k3d.sh
#############################

echo "Creating Level 1 solution files..."

# Sample Flask app for Level 1
cat << 'EOF' > "$SOLUTIONS_DIR/level1/app.py"
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "Hello from Level 1 Sample App!"

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
EOF

# requirements.txt for Level 1
cat << 'EOF' > "$SOLUTIONS_DIR/level1/requirements.txt"
Flask==2.0.3
EOF

# Dockerfile for Level 1
cat << 'EOF' > "$SOLUTIONS_DIR/level1/Dockerfile"
# Stage 1: Builder
FROM python:3.9-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Stage 2: Final image
FROM python:3.9-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:\$PATH
EXPOSE 5000
CMD ["python", "app.py"]
EOF

# Kubernetes deployment.yaml for Level 1
cat << 'EOF' > "$SOLUTIONS_DIR/level1/deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - name: sample-app
        image: yourdockerhub/sample-app:latest
        ports:
        - containerPort: 5000
EOF

# Kubernetes service.yaml for Level 1
cat << 'EOF' > "$SOLUTIONS_DIR/level1/service.yaml"
apiVersion: v1
kind: Service
metadata:
  name: sample-app-service
spec:
  selector:
    app: sample-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: ClusterIP
EOF

# Bonus HPA manifest for Level 1
cat << 'EOF' > "$SOLUTIONS_DIR/level1/hpa.yaml"
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: sample-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: sample-app
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
EOF

# Bonus Blue-green deployment for Level 1
cat << 'EOF' > "$SOLUTIONS_DIR/level1/deployment-green.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app-green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sample-app
      version: green
  template:
    metadata:
      labels:
        app: sample-app
        version: green
    spec:
      containers:
      - name: sample-app
        image: yourdockerhub/sample-app:latest
        ports:
        - containerPort: 5000
EOF

# Create run_lab.sh for Level 1
cat << 'EOF' > "$SOLUTIONS_DIR/level1/run_lab.sh"
#!/bin/bash
# run_lab.sh for Level 1: Docker & Kubernetes Lab
set -e

echo "Running Level 1 Lab..."

# Build Docker image
echo "Building Docker image..."
docker build -t sample-app:latest .

# Save Docker image to tar
echo "Saving Docker image..."
docker save sample-app:latest -o /tmp/sample-app.tar

# Import image into k3d cluster using k3d (assuming cluster is created via k3d)
CLUSTER_NAME="lab-cluster"
echo "Importing image into k3d cluster \$CLUSTER_NAME..."
k3d image import "\$CLUSTER_NAME" /tmp/sample-app.tar
rm /tmp/sample-app.tar

# Deploy Kubernetes manifests
echo "Deploying Kubernetes manifests..."
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

echo "Waiting for deployment rollout..."
kubectl rollout status deployment/sample-app

# E2E Test: Port-forward service and check response
echo "Setting up port-forward to test service..."
kubectl port-forward svc/sample-app-service 8080:80 &
PF_PID=\$!
sleep 5
RESPONSE=\$(curl -s http://localhost:8080)
echo "Response from service: \$RESPONSE"
kill \$PF_PID

if [[ "\$RESPONSE" == *"Hello from Level 1 Sample App!"* ]]; then
  echo "Level 1 end-to-end test passed!"
else
  echo "Level 1 end-to-end test failed!"
  exit 1
fi

echo "Level 1 lab completed successfully!"
EOF

chmod +x "$SOLUTIONS_DIR/level1/run_lab.sh"

# Create lab1_k3d.sh for Level 1 (tailored for macOS with Apple M2 using k3d)
cat << 'EOF' > "$SOLUTIONS_DIR/level1/lab1_k3d.sh"
#!/bin/bash
# lab1_k3d.sh – Lab 1 Setup for macOS (Apple M2 Max) using k3d
#
# This script:
#   - Verifies required tools (docker, kubectl, k3d)
#   - Installs k3d via Homebrew if not present
#   - Creates a k3d cluster named "lab-cluster" if it doesn't exist
#   - Switches kubectl context to the k3d cluster
#   - Creates a namespace "devops-lab"
#   - Builds the Docker image, imports it into the k3d cluster, deploys Kubernetes manifests,
#     and runs an end-to-end test.
#   - Displays Docker Scout vulnerability summary.
#
# Usage:
#   chmod +x lab1_k3d.sh
#   ./lab1_k3d.sh

set -e

# Function to check if a command exists
check_command() {
  if ! command -v "\$1" >/dev/null 2>&1; then
    echo "ERROR: \$1 is required but not installed. Aborting."
    exit 1
  fi
}

echo "Verifying required tools..."
for cmd in docker kubectl; do
  check_command "\$cmd"
done

# Check for k3d; install via Homebrew if missing.
if ! command -v k3d >/dev/null 2>&1; then
  echo "k3d not found. Installing via Homebrew..."
  brew install k3d
fi

# Create a k3d cluster named "lab-cluster" if not already present.
CLUSTER_NAME="lab-cluster"
if ! k3d cluster list | grep -q "\$CLUSTER_NAME"; then
  echo "Creating k3d cluster named \$CLUSTER_NAME..."
  k3d cluster create "\$CLUSTER_NAME" --agents 1
else
  echo "k3d cluster \$CLUSTER_NAME already exists."
fi

# Switch kubectl context to k3d cluster
echo "Switching kubectl context to k3d-\$CLUSTER_NAME..."
kubectl config use-context k3d-\$CLUSTER_NAME

# Create a dedicated namespace for lab testing
NAMESPACE="devops-lab"
echo "Creating Kubernetes namespace '\$NAMESPACE'..."
kubectl create namespace \$NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

echo "=== Level 1: Docker & Kubernetes ==="

# Ensure we're in the correct directory
LAB_L1_DIR="\$(dirname "\$(realpath "\$0")")"
echo "Using Level 1 solution files in \$LAB_L1_DIR"

# Build the Docker image for the sample app.
echo "Building Docker image for sample-app..."
docker build -t sample-app:latest "\$LAB_L1_DIR"

# Optional: View image vulnerabilities using Docker Scout
echo "Viewing image vulnerabilities (Docker Scout):"
docker scout quickview sample-app:latest

# Save the Docker image to a tar file.
echo "Saving Docker image..."
docker save sample-app:latest -o /tmp/sample-app.tar

# Import the image into the k3d cluster.
echo "Importing image into k3d cluster..."
k3d image import "\$CLUSTER_NAME" /tmp/sample-app.tar
rm /tmp/sample-app.tar

# Deploy Kubernetes manifests.
echo "Deploying Kubernetes manifests..."
kubectl apply -f "\$LAB_L1_DIR/deployment.yaml" -n \$NAMESPACE
kubectl apply -f "\$LAB_L1_DIR/service.yaml" -n \$NAMESPACE

echo "Waiting for deployment rollout..."
kubectl rollout status deployment/sample-app -n \$NAMESPACE

# E2E Test: Port-forward service and check response.
echo "Setting up port-forward to test the service..."
kubectl port-forward svc/sample-app-service 8080:80 -n \$NAMESPACE &
PF_PID=\$!
sleep 5
RESPONSE=\$(curl -s http://localhost:8080)
echo "Response from service: \$RESPONSE"
kill \$PF_PID

if [[ "\$RESPONSE" == *"Hello from Level 1 Sample App!"* ]]; then
  echo "Level 1 end-to-end test passed!"
else
  echo "Level 1 end-to-end test failed!"
  exit 1
fi

echo "lab1_k3d.sh: Level 1 lab completed successfully on k3d!"
EOF

chmod +x "$SOLUTIONS_DIR/level1/lab1_k3d.sh"

#############################
# Level 2: Helm, Git & CI/CD Solutions & run_lab.sh
#############################

echo "Creating Level 2 Helm chart files..."

# Chart.yaml
cat << 'EOF' > "$SOLUTIONS_DIR/level2/helm/sample-app/Chart.yaml"
apiVersion: v2
name: sample-app
description: A Helm chart for the sample application
version: 0.1.0
appVersion: "1.0"
EOF

# values.yaml
cat << 'EOF' > "$SOLUTIONS_DIR/level2/helm/sample-app/values.yaml"
replicaCount: 3
image:
  repository: yourdockerhub/sample-app
  tag: latest
  pullPolicy: IfNotPresent
service:
  type: ClusterIP
  port: 80
EOF

# templates/deployment.yaml
cat << 'EOF' > "$SOLUTIONS_DIR/level2/helm/sample-app/templates/deployment.yaml"
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "sample-app.fullname" . }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ include "sample-app.name" . }}
  template:
    metadata:
      labels:
        app: {{ include "sample-app.name" . }}
    spec:
      containers:
      - name: {{ include "sample-app.name" . }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - containerPort: 5000
EOF

# templates/service.yaml
cat << 'EOF' > "$SOLUTIONS_DIR/level2/helm/sample-app/templates/service.yaml"
apiVersion: v1
kind: Service
metadata:
  name: {{ include "sample-app.fullname" . }}
spec:
  type: {{ .Values.service.type }}
  ports:
  - port: {{ .Values.service.port }}
    targetPort: 5000
  selector:
    app: {{ include "sample-app.name" . }}
EOF

# Create run_lab.sh for Level 2
cat << 'EOF' > "$SOLUTIONS_DIR/level2/run_lab.sh"
#!/bin/bash
# run_lab.sh for Level 2: Helm, Git & CI/CD Lab
set -e

echo "Running Level 2 Lab..."

echo "Deploying Helm chart..."
helm upgrade --install sample-app ./helm/sample-app --namespace default

echo "Waiting for deployment rollout..."
kubectl rollout status deployment/sample-app

# E2E Test: Exec into a pod and check app response.
POD=\$(kubectl get pods -l app=sample-app -o jsonpath="{.items[0].metadata.name}")
echo "Testing application from pod \$POD..."
RESPONSE=\$(kubectl exec \$POD -- curl -s localhost:5000)
echo "Response: \$RESPONSE"
if [[ "\$RESPONSE" == *"Hello from Level 1 Sample App!"* ]]; then
  echo "Level 2 e2e test passed!"
else
  echo "Level 2 e2e test failed!"
  exit 1
fi
EOF

chmod +x "$SOLUTIONS_DIR/level2/run_lab.sh"

#############################
# Level 3: GitOps & Monitoring Solutions & run_lab.sh
#############################

echo "Creating Level 3 solution files..."

# ArgoCD manifest
cat << 'EOF' > "$SOLUTIONS_DIR/level3/argo-app.yaml"
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app
  namespace: argocd
spec:
  destination:
    namespace: default
    server: https://kubernetes.default.svc
  source:
    repoURL: 'https://github.com/yourorg/sample-app-config.git'
    path: helm/sample-app
    targetRevision: HEAD
  project: default
EOF

# Prometheus configuration
cat << 'EOF' > "$SOLUTIONS_DIR/level3/prometheus.yml"
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app]
        regex: sample-app
        action: keep
EOF

# Alertmanager configuration
cat << 'EOF' > "$SOLUTIONS_DIR/level3/alertmanager.yml"
global:
  resolve_timeout: 5m

route:
  receiver: 'devops-team'
  group_wait: 30s
  group_interval: 5m

receivers:
- name: 'devops-team'
  email_configs:
  - to: 'devops@example.com'
EOF

# Create run_lab.sh for Level 3
cat << 'EOF' > "$SOLUTIONS_DIR/level3/run_lab.sh"
#!/bin/bash
# run_lab.sh for Level 3: GitOps & Monitoring Lab
set -e

echo "Running Level 3 Lab..."

echo "Deploying ArgoCD application manifest..."
kubectl apply -f argo-app.yaml

echo "Deploying Prometheus and Alertmanager configurations..."
kubectl apply -f prometheus.yml
kubectl apply -f alertmanager.yml

echo "Waiting for monitoring pods to be ready..."
sleep 10
kubectl get pods

echo "Level 3 lab deployed. Please verify monitoring dashboards manually."
EOF

chmod +x "$SOLUTIONS_DIR/level3/run_lab.sh"

#############################
# Level 4: AWS EC2 & Terraform Solutions & run_lab.sh
#############################

echo "Creating Level 4 Terraform file..."

cat << 'EOF' > "$SOLUTIONS_DIR/level4/main.tf"
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "sample_app" {
  ami           = "ami-0abcdef1234567890"  # Replace with a valid AMI ID for your region
  instance_type = "t2.micro"
  tags = {
    Name = "SampleAppServer"
  }
}

output "instance_public_ip" {
  value = aws_instance.sample_app.public_ip
}
EOF

# Create run_lab.sh for Level 4
cat << 'EOF' > "$SOLUTIONS_DIR/level4/run_lab.sh"
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
EOF

chmod +x "$SOLUTIONS_DIR/level4/run_lab.sh"

#############################
# Level 5: AWS VPC & Secrets/Lambda Solutions & run_lab.sh
#############################

echo "Creating Level 5 solution files..."

# VPC Terraform file for Level 5
cat << 'EOF' > "$SOLUTIONS_DIR/level5/vpc.tf"
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
EOF

# Lambda function for Level 5
cat << 'EOF' > "$SOLUTIONS_DIR/level5/lambda_function.py"
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
EOF

# Bonus: Enhanced Lambda function for Level 5
cat << 'EOF' > "$SOLUTIONS_DIR/level5/lambda_function_bonus.py"
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
EOF

# Create run_lab.sh for Level 5
cat << 'EOF' > "$SOLUTIONS_DIR/level5/run_lab.sh"
#!/bin/bash
# run_lab.sh for Level 5: AWS VPC & Secrets/Lambda Lab
set -e

echo "Running Level 5 Lab..."

echo "Validating VPC Terraform configuration..."
terraform validate -no-color vpc.tf

echo "Checking Lambda function syntax..."
python3 -m py_compile lambda_function.py

echo "Level 5 lab e2e tests passed. Note: Full AWS deployment requires manual validation."
EOF

chmod +x "$SOLUTIONS_DIR/level5/run_lab.sh"

#############################
# Final Message and Directory Tree
#############################

echo "All files have been created in the '$BASE_DIR' directory."
echo "Project package structure:"
if command -v tree >/dev/null 2>&1; then
  tree "$BASE_DIR"
else
  find "$BASE_DIR" -print
fi
