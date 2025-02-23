#!/bin/bash
# check_lab1.sh – End-to-End (E2E) Check for Student Level 1 Lab (Mandatory and Bonus)
#
# This script performs the following:
#   - Verifies that mandatory files exist: Dockerfile, app.py, requirements.txt, deployment.yaml, service.yaml.
#   - Optionally verifies bonus files if provided: hpa.yaml, deployment-green.yaml.
#   - Checks for required commands: docker, kubectl, k3d, and optionally hey.
#   - Ensures that a k3d cluster named "lab-cluster" exists (or creates it).
#   - Switches kubectl context to the k3d cluster and creates the namespace "devops-lab".
#   - Builds the Docker image, displays vulnerability info (using docker scout), saves and imports the image into the k3d cluster.
#   - Deploys the Kubernetes manifests and waits for rollout.
#   - Sets up port-forwarding on an available port and tests the service response.
#   - If bonus files exist, deploys bonus manifests.
#   - If bonus HPA is deployed and the "hey" tool is installed, it runs a load test to simulate scaling and displays the HPA status.
#
# Usage:
#   chmod +x check_lab1.sh
#   ./check_lab1.sh

set -e

echo "=== Student Lab Level 1 Check (Mandatory + Bonus + HPA Scaling Test) ==="

# -----------------------------
# 1. Check for Required Files
# -----------------------------
MANDATORY_FILES=("Dockerfile" "app.py" "requirements.txt" "deployment.yaml" "service.yaml")
for file in "${MANDATORY_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "ERROR: Mandatory file '$file' is missing."
    exit 1
  else
    echo "Found mandatory file: $file"
  fi
done

# Check for bonus files (if provided)
BONUS_FILES=()
if [ -f "hpa.yaml" ]; then
  BONUS_FILES+=("hpa.yaml")
fi
if [ -f "deployment-green.yaml" ]; then
  BONUS_FILES+=("deployment-green.yaml")
fi

if [ ${#BONUS_FILES[@]} -gt 0 ]; then
  echo "Found bonus file(s): ${BONUS_FILES[*]}"
else
  echo "No bonus files provided. Proceeding with mandatory solution only."
fi

# -----------------------------
# 2. Check for Required Commands
# -----------------------------
for cmd in docker kubectl k3d; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: $cmd is required but not installed. Aborting."
    exit 1
  fi
done

# Optionally check for "hey" (used for load testing)
if command -v hey >/dev/null 2>&1; then
  HEY_AVAILABLE=true
  echo "'hey' is installed; load test for HPA scaling will be performed."
else
  HEY_AVAILABLE=false
  echo "'hey' is not installed; skipping load test for HPA scaling check."
fi

# -----------------------------
# 3. Ensure k3d Cluster and Namespace
# -----------------------------
CLUSTER_NAME="lab-cluster"
NAMESPACE="devops-lab"

if ! k3d cluster list | grep -q "$CLUSTER_NAME"; then
  echo "Creating k3d cluster named $CLUSTER_NAME..."
  k3d cluster create "$CLUSTER_NAME" --agents 1
else
  echo "k3d cluster $CLUSTER_NAME already exists."
fi

echo "Switching kubectl context to k3d-$CLUSTER_NAME..."
kubectl config use-context k3d-$CLUSTER_NAME

echo "Creating namespace '$NAMESPACE' if it doesn't exist..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# -----------------------------
# 4. Build and Import Docker Image
# -----------------------------
echo "Building Docker image 'sample-app:latest'..."
docker build -t sample-app:latest .

echo "Viewing image vulnerabilities (Docker Scout):"
docker scout quickview sample-app:latest

echo "Saving Docker image to /tmp/sample-app.tar..."
docker save sample-app:latest -o /tmp/sample-app.tar

echo "Importing image into k3d cluster $CLUSTER_NAME..."
k3d image import --cluster "$CLUSTER_NAME" /tmp/sample-app.tar
rm /tmp/sample-app.tar

# -----------------------------
# 5. Deploy Mandatory Kubernetes Manifests
# -----------------------------
echo "Deploying mandatory Kubernetes manifests..."
kubectl apply -f deployment.yaml -n "$NAMESPACE"
kubectl apply -f service.yaml -n "$NAMESPACE"

echo "Waiting for mandatory deployment rollout..."
kubectl rollout status deployment/sample-app -n "$NAMESPACE"

# -----------------------------
# 6. Run End-to-End Test for Mandatory Solution
# -----------------------------
# Function to check if a port is available
check_port() {
  if lsof -i :"$1" >/dev/null 2>&1; then
    return 1
  else
    return 0
  fi
}

# Choose port for port-forward
PORT=8080
if ! check_port $PORT; then
  echo "Port $PORT is in use, trying alternate port 8081."
  PORT=8081
  if ! check_port $PORT; then
    echo "Error: Neither port 8080 nor 8081 is available. Aborting E2E test."
    exit 1
  fi
fi

echo "Setting up port-forward on localhost:${PORT}..."
kubectl port-forward svc/sample-app-service ${PORT}:80 -n "$NAMESPACE" &
PF_PID=$!
trap "kill $PF_PID 2>/dev/null" EXIT
sleep 5
RESPONSE=$(curl -s http://localhost:${PORT})
echo "Mandatory solution response: $RESPONSE"
if kill -0 $PF_PID 2>/dev/null; then
  kill $PF_PID
fi
trap - EXIT

EXPECTED="Hello from Level 1 Sample App!"
if [[ "$RESPONSE" == *"$EXPECTED"* ]]; then
  echo "Mandatory end-to-end test passed!"
else
  echo "Mandatory end-to-end test failed: Expected '$EXPECTED' but got '$RESPONSE'."
  exit 1
fi

# -----------------------------
# 7. Deploy Bonus Manifests (if provided)
# -----------------------------
if [ ${#BONUS_FILES[@]} -gt 0 ]; then
  echo "Deploying bonus manifests..."
  if [ -f "hpa.yaml" ]; then
    echo "Deploying bonus HPA manifest..."
    kubectl apply -f hpa.yaml -n "$NAMESPACE"
  fi
  if [ -f "deployment-green.yaml" ]; then
    echo "Deploying bonus blue-green deployment manifest..."
    kubectl apply -f deployment-green.yaml -n "$NAMESPACE"
  fi
  echo "Bonus manifests deployed. Please verify bonus configurations manually."
fi

# -----------------------------
# 8. Bonus HPA Scaling Test (if applicable and hey is installed)
# -----------------------------
if [ -f "hpa.yaml" ] && [ "$HEY_AVAILABLE" = true ]; then
  echo "Simulating load to test HPA scaling..."
  kubectl port-forward svc/sample-app-service ${PORT}:80 -n "$NAMESPACE" &
  PF_PID=$!
  hey -z 60s http://localhost:${PORT}/
  kill $PF_PID
  echo "Waiting 10 seconds for HPA metrics to update..."
  sleep 10
  echo "HPA status after load test:"
  kubectl get hpa sample-app-hpa -n "$NAMESPACE"
  echo "Detailed HPA status:"
  kubectl describe hpa sample-app-hpa -n "$NAMESPACE"
  echo "Please verify that the desired replica count increases when load is applied."
else
  echo "Bonus HPA scaling check skipped (either hpa.yaml is missing or 'hey' is not installed)."
fi

echo "All checks for Level 1 lab passed successfully."
