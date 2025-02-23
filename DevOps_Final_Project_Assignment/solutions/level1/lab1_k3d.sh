#!/bin/bash
# lab1_k3d.sh – Lab 1 Setup for macOS (Apple M2 Max) using k3d
#
# IMPORTANT:
#   Ensure your requirements.txt is updated to pin versions that are compatible.
#   For example, in requirements.txt, use:
#     Flask==2.0.3
#     Werkzeug==2.0.3
#
# This script:
#   - Verifies required tools (docker, kubectl, k3d)
#   - Installs k3d via Homebrew if not present
#   - Creates a k3d cluster named "lab-cluster" if it doesn't exist
#   - Switches kubectl context to the k3d cluster and waits for nodes to be ready
#   - Creates a namespace "devops-lab" for lab testing
#   - Builds the Docker image, displays vulnerability info, imports it into the k3d cluster,
#     deploys Kubernetes manifests, and runs an end-to-end test.
#
# Usage:
#   chmod +x lab1_k3d.sh
#   ./lab1_k3d.sh

set -e

# Function to check if a command exists
check_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "ERROR: $1 is required but not installed. Aborting."
    exit 1
  fi
}

echo "Verifying required tools..."
for cmd in docker kubectl; do
  check_command "$cmd"
done

# Check for k3d; install via Homebrew if missing.
if ! command -v k3d >/dev/null 2>&1; then
  echo "k3d not found. Installing via Homebrew..."
  if command -v brew >/dev/null 2>&1; then
    brew install k3d
  else
    echo "ERROR: Homebrew is not installed. Please install Homebrew or install k3d manually."
    exit 1
  fi
fi

# Create a k3d cluster named "lab-cluster" if not already present.
CLUSTER_NAME="lab-cluster"
if ! k3d cluster list | grep -q "$CLUSTER_NAME"; then
  echo "Creating k3d cluster named $CLUSTER_NAME..."
  k3d cluster create "$CLUSTER_NAME" --agents 1
else
  echo "k3d cluster $CLUSTER_NAME already exists."
fi

# Switch kubectl context to the k3d cluster
echo "Switching kubectl context to k3d-$CLUSTER_NAME..."
kubectl config use-context k3d-$CLUSTER_NAME

# Wait for cluster nodes to be ready.
echo "Waiting for k3d cluster nodes to be ready..."
while [ $(kubectl get nodes --no-headers | wc -l) -eq 0 ]; do
  echo "No nodes found yet, waiting..."
  sleep 5
done
echo "Cluster nodes are now ready."

# Create a dedicated namespace for lab testing.
NAMESPACE="devops-lab"
echo "Creating Kubernetes namespace '$NAMESPACE'..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

echo "=== Level 1: Docker & Kubernetes ==="

# Determine the directory of this script (assumes Level 1 solution files are in the same folder)
LAB_L1_DIR="$(dirname "$(realpath "$0")")"
echo "Using Level 1 solution files in $LAB_L1_DIR"

# Build the Docker image for the sample app.
echo "Building Docker image for sample-app..."
docker build -t sample-app:latest "$LAB_L1_DIR"

# Optional: View image vulnerabilities using Docker Scout
echo "Viewing image vulnerabilities (Docker Scout):"
docker scout quickview sample-app:latest

# Save the Docker image to a tar file.
echo "Saving Docker image..."
docker save sample-app:latest -o /tmp/sample-app.tar

# Import the image into the k3d cluster using the --cluster flag.
echo "Importing image into k3d cluster..."
k3d image import --cluster "$CLUSTER_NAME" /tmp/sample-app.tar
rm /tmp/sample-app.tar

# Deploy Kubernetes manifests.
echo "Deploying Kubernetes manifests..."
kubectl apply -f "$LAB_L1_DIR/deployment.yaml" -n "$NAMESPACE"
kubectl apply -f "$LAB_L1_DIR/service.yaml" -n "$NAMESPACE"

echo "Waiting for deployment rollout..."
kubectl rollout status deployment/sample-app -n "$NAMESPACE"

# End-to-end test: Port-forward service and check response.
echo "Setting up port-forward to test the service..."
kubectl port-forward svc/sample-app-service 8080:80 -n "$NAMESPACE" &
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

echo "lab1_k3d.sh: Level 1 lab completed successfully on k3d!"
