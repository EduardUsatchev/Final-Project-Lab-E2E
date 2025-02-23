#!/bin/bash
# run_lab.sh for Level 1: Docker & Kubernetes Lab
# This script builds the Docker image, saves it to a tar file, imports it into the k3d cluster,
# deploys Kubernetes manifests, and runs an end-to-end test.
#
# Usage:
#   chmod +x run_lab.sh
#   ./run_lab.sh
#
# Note: This script assumes that a k3d cluster named "lab-cluster" exists and that the namespace "devops-lab" is created.

set -e

echo "Running Level 1 Lab..."

# Set the cluster name explicitly
CLUSTER_NAME="lab-cluster"
echo "Using cluster: ${CLUSTER_NAME}"

# Build Docker image
echo "Building Docker image..."
docker build -t sample-app:latest .

# Save Docker image to a tar file
echo "Saving Docker image..."
docker save sample-app:latest -o /tmp/sample-app.tar

# Import image into the k3d cluster using the hardcoded cluster name
echo "Importing image into k3d cluster lab-cluster..."
k3d image import lab-cluster /tmp/sample-app.tar
rm /tmp/sample-app.tar

# Deploy Kubernetes manifests (assumes deployment.yaml and service.yaml are in the current directory)
echo "Deploying Kubernetes manifests..."
kubectl apply -f deployment.yaml -n devops-lab
kubectl apply -f service.yaml -n devops-lab

echo "Waiting for deployment rollout..."
kubectl rollout status deployment/sample-app -n devops-lab

# End-to-end test: Port-forward service and check response
echo "Setting up port-forward to test the service..."
kubectl port-forward svc/sample-app-service 8080:80 -n devops-lab &
PF_PID=$!
sleep 5
RESPONSE=$(curl -s http://localhost:8080)
echo "Response from service: $RESPONSE"
kill $PF_PID

if [[ "$RESPONSE" == *"Hello from Level 1 Sample App!"* ]]; then
  echo "Level 1 end-to-end test passed!"
else
  echo "Level 1 end-to-end test failed!"
  exit 1
fi

echo "Level 1 lab completed successfully!"
