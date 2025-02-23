#!/bin/bash
# check_lab3.sh – End-to-End Check for Student Level 3 Lab (GitOps & Monitoring)
#
# This script verifies that all mandatory files for Level 3 exist:
#   - argo-app.yaml         (ArgoCD application manifest)
#   - prometheus.yml        (Prometheus configuration file)
#   - alertmanager.yml      (Alertmanager configuration file)
#
# Optionally, any Grafana dashboard JSON files are listed.
#
# The script then ensures that a k3d cluster ("lab-cluster") exists, switches the kubectl context to it,
# and ensures that the "devops-lab" namespace exists.
#
# It deploys the manifests as follows:
#   - If ArgoCD CRDs are present, it applies argo-app.yaml into the namespace.
#   - It creates ConfigMaps for the Prometheus and Alertmanager configurations (using --validate=false).
#
# Usage:
#   chmod +x check_lab3.sh
#   ./check_lab3.sh
#
set -e

echo "=== Student Lab Level 3 Check (Mandatory + Optional Bonus) ==="

# List of mandatory Level 3 files.
MANDATORY_FILES=(
  "argo-app.yaml"
  "prometheus.yml"
  "alertmanager.yml"
)

for file in "${MANDATORY_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo "ERROR: Mandatory file '$file' is missing."
    exit 1
  else
    echo "Found mandatory file: $file"
  fi
done

# Optionally check for any Grafana dashboard JSON files.
GRAFANA_FILES=$(find . -maxdepth 1 -type f -name "*.json")
if [ -n "$GRAFANA_FILES" ]; then
  echo "Optional Grafana dashboard files found:"
  echo "$GRAFANA_FILES"
else
  echo "No optional Grafana dashboard files found."
fi

# Verify required commands.
for cmd in kubectl k3d; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: $cmd is required but not installed. Aborting."
    exit 1
  fi
done

# Set variables.
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

# Deploy the ArgoCD Application manifest if CRDs are installed.
echo "Checking for ArgoCD CRDs..."
if kubectl get crd applications.argoproj.io >/dev/null 2>&1; then
  echo "ArgoCD CRDs are installed. Deploying ArgoCD application manifest..."
  kubectl apply -f argo-app.yaml -n "$NAMESPACE"
else
  echo "WARNING: ArgoCD CRDs not found in the cluster. Skipping ArgoCD application deployment."
fi

# Create ConfigMap for Prometheus configuration.
echo "Creating ConfigMap for Prometheus configuration..."
kubectl create configmap prometheus-config --from-file=prometheus.yml -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f - --validate=false

# Create ConfigMap for Alertmanager configuration.
echo "Creating ConfigMap for Alertmanager configuration..."
kubectl create configmap alertmanager-config --from-file=alertmanager.yml -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f - --validate=false

# Wait briefly for resources to be created.
echo "Waiting for resources to be created..."
sleep 10

# Check that the ArgoCD Application exists (if CRDs were installed).
if kubectl get crd applications.argoproj.io >/dev/null 2>&1; then
  echo "Checking for ArgoCD Application resource in namespace $NAMESPACE..."
  ARGO_APP=$(kubectl get application -n "$NAMESPACE" 2>/dev/null || true)
  if [ -z "$ARGO_APP" ]; then
    echo "WARNING: No ArgoCD Application resource found in namespace $NAMESPACE. Please ensure your argo-app.yaml is correct."
  else
    echo "ArgoCD Application resource found:"
    kubectl get application -n "$NAMESPACE"
  fi
fi

# List pods in the namespace (to check monitoring components).
echo "Listing pods in namespace $NAMESPACE (for monitoring components)..."
kubectl get pods -n "$NAMESPACE"

echo "All checks for Level 3 lab passed successfully."
