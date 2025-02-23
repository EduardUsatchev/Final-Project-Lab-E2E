#!/bin/bash
# check_lab2.sh – End-to-End (E2E) Check for Student Level 2 Lab (Helm, Git, CI/CD)
#
# This script verifies that all required mandatory files for Level 2 exist,
# including the Helm chart files and the bonus CI/CD workflow file (if provided).
# It renders the Helm chart to ensure required Helm metadata is present,
# ensures that a k3d cluster ("lab-cluster") and namespace ("devops-lab") exist,
# deploys the Helm chart, waits for the rollout to complete, and runs an end-to-end test.
#
# Mandatory files (must be present in the Level 2 folder):
#   - helm/sample-app/Chart.yaml
#   - helm/sample-app/values.yaml
#   - helm/sample-app/templates/deployment.yaml
#   - helm/sample-app/templates/service.yaml
#   - helm/sample-app/templates/_helpers.tpl    <-- Required for Helm metadata.
#
# Bonus file (optional but recommended):
#   - .github/workflows/ci-cd.yml
#     --> This file MUST contain "runs-on: self-hosted" and ideally include bonus features (e.g., "canary" or "rollback").
#
# Usage:
#   chmod +x check_lab2.sh
#   ./check_lab2.sh

set -e

echo "=== Student Lab Level 2 Check (Mandatory + Optional Bonus) ==="

# List of mandatory Helm chart files.
MANDATORY_FILES=(
  "helm/sample-app/Chart.yaml"
  "helm/sample-app/values.yaml"
  "helm/sample-app/templates/deployment.yaml"
  "helm/sample-app/templates/service.yaml"
  "helm/sample-app/templates/_helpers.tpl"
)

for file in "${MANDATORY_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "ERROR: Mandatory file '$file' is missing."
    exit 1
  else
    echo "Found mandatory file: $file"
  fi
done

# Check for the bonus CI/CD workflow file.
if [ -f ".github/workflows/ci-cd.yml" ]; then
  echo "Found bonus CI/CD workflow file: .github/workflows/ci-cd.yml"
  # Verify that the file specifies self-hosted runners.
  if grep -q "runs-on: self-hosted" .github/workflows/ci-cd.yml; then
    echo "CI/CD workflow is configured to run on self-hosted runners."
  else
    echo "ERROR: The CI/CD workflow file does not specify 'runs-on: self-hosted'."
    exit 1
  fi
  # Check for bonus keywords such as "canary" or "rollback"
  if grep -qiE "canary|rollback" .github/workflows/ci-cd.yml; then
    echo "Bonus CI/CD features detected (canary/rollback)."
  else
    echo "Warning: Bonus CI/CD features (canary/rollback) not detected in the workflow file."
  fi
else
  echo "Note: Bonus file .github/workflows/ci-cd.yml is missing. Ensure you have documented your CI/CD process and are using self-hosted runners."
fi

# Render the Helm chart to verify required Helm metadata.
echo "Rendering Helm chart to verify required Helm metadata..."
RENDERED=$(helm template sample-app helm/sample-app --debug)
if [[ "$RENDERED" != *"app.kubernetes.io/managed-by: Helm"* ]]; then
  echo "ERROR: Rendered template does not include required Helm metadata."
  echo "Ensure that your _helpers.tpl file and your templates include the following labels:"
  echo "  app.kubernetes.io/managed-by: Helm"
  echo "  meta.helm.sh/release-name: <release name>"
  echo "  meta.helm.sh/release-namespace: <release namespace>"
  exit 1
else
  echo "Helm chart rendering includes required Helm metadata."
fi

# Verify required commands.
for cmd in docker helm kubectl k3d; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: $cmd is required but not installed. Aborting."
    exit 1
  fi
done

# Set variables for cluster and namespace.
CLUSTER_NAME="lab-cluster"
NAMESPACE="devops-lab"

# Ensure k3d cluster exists; if not, create it.
if ! k3d cluster list | grep -q "$CLUSTER_NAME"; then
  echo "Creating k3d cluster named $CLUSTER_NAME..."
  k3d cluster create "$CLUSTER_NAME" --agents 1
else
  echo "k3d cluster $CLUSTER_NAME already exists."
fi

# Switch kubectl context to the k3d cluster.
echo "Switching kubectl context to k3d-$CLUSTER_NAME..."
kubectl config use-context k3d-$CLUSTER_NAME

# Create (or ensure) the namespace exists.
echo "Creating namespace '$NAMESPACE' if it doesn't exist..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Deploy the Helm chart.
echo "Deploying Helm chart from helm/sample-app into namespace $NAMESPACE..."
helm upgrade --install sample-app helm/sample-app --namespace "$NAMESPACE"

# Wait for the rollout to complete.
echo "Waiting for deployment rollout..."
kubectl rollout status deployment/sample-app -n "$NAMESPACE"

# End-to-end test: Use port-forward to verify application response.
echo "Setting up port-forward for end-to-end test..."
kubectl port-forward svc/sample-app-service 8080:80 -n "$NAMESPACE" &
PF_PID=$!
sleep 5
RESPONSE=$(curl -s http://localhost:8080)
echo "Response from service: $RESPONSE"
kill $PF_PID

EXPECTED="Hello from Level 1 Sample App!"
if [[ "$RESPONSE" == *"$EXPECTED"* ]]; then
  echo "Level 2 end-to-end test passed!"
else
  echo "Level 2 end-to-end test failed: Expected '$EXPECTED' but got '$RESPONSE'."
  exit 1
fi

echo "All checks for Level 2 lab passed successfully."
