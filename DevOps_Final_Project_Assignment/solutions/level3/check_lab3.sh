#!/bin/bash
# check_lab3.sh – End-to-End Check for Student Level 3 Lab (GitOps, Monitoring & Grafana, Prometheus & Alertmanager)
#
# This script verifies that all mandatory Level 3 files exist:
#   - argo-app.yaml         (ArgoCD application manifest)
#   - prometheus.yml        (Prometheus configuration file)
#   - alertmanager.yml      (Alertmanager configuration file)
#
# It also checks for optional bonus files:
#   - prometheus-rules.yml  (custom Prometheus alert rules)
#   - Grafana dashboard JSON files
#
# Additionally, if deployment files for Grafana, Prometheus, and Alertmanager exist,
# this script deploys full instances:
#   - Grafana: via grafana-configmap.yaml, grafana-deployment.yaml, and grafana-service.yaml
#   - Prometheus: via prometheus-deployment.yaml and prometheus-service.yaml
#   - Alertmanager: via alertmanager-deployment.yaml and alertmanager-service.yaml
#
# It ensures that a k3d cluster ("lab-cluster") exists, switches context,
# creates the "devops-lab" namespace, deploys all manifests, waits for resources,
# and finally lists pods.
#
# Usage:
#   chmod +x check_lab3.sh
#   ./check_lab3.sh
#
set -e

echo "=== Student Lab Level 3 Check (Mandatory + Optional Bonus) ==="

# List mandatory files.
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

# Optional bonus file: Prometheus rules.
if [ -f "prometheus-rules.yml" ]; then
  echo "Found optional bonus file: prometheus-rules.yml"
fi

# Optional Grafana dashboard JSON files.
GRAFANA_FILES=$(find . -maxdepth 1 -type f -name "*.json")
if [ -n "$GRAFANA_FILES" ]; then
  echo "Found optional Grafana dashboard files:"
  echo "$GRAFANA_FILES"
else
  echo "No optional Grafana dashboard JSON files found."
fi

# Check for Grafana deployment files.
if [ -d "grafana" ]; then
  echo "Grafana deployment files found in the 'grafana/' folder."
  GRAFANA_DEPLOYMENT=true
else
  echo "No Grafana deployment files found (folder 'grafana/' missing)."
  GRAFANA_DEPLOYMENT=false
fi

# Check for Prometheus deployment files.
if [ -f "prometheus-deployment.yaml" ] && [ -f "prometheus-service.yaml" ]; then
  echo "Prometheus deployment files found."
  PROMETHEUS_DEPLOYMENT=true
else
  echo "No Prometheus deployment files found; using ConfigMap only for Prometheus."
  PROMETHEUS_DEPLOYMENT=false
fi

# Check for Alertmanager deployment files.
if [ -f "alertmanager-deployment.yaml" ] && [ -f "alertmanager-service.yaml" ]; then
  echo "Alertmanager deployment files found."
  ALERTMANAGER_DEPLOYMENT=true
else
  echo "No Alertmanager deployment files found; using ConfigMap only for Alertmanager."
  ALERTMANAGER_DEPLOYMENT=false
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

# Ensure k3d cluster exists.
if ! k3d cluster list | grep -q "$CLUSTER_NAME"; then
  echo "Creating k3d cluster named $CLUSTER_NAME..."
  k3d cluster create "$CLUSTER_NAME" --agents 1
else
  echo "k3d cluster $CLUSTER_NAME already exists."
fi

# Switch kubectl context.
echo "Switching kubectl context to k3d-$CLUSTER_NAME..."
kubectl config use-context k3d-$CLUSTER_NAME

# Create (or ensure) namespace exists.
echo "Creating namespace '$NAMESPACE' if it doesn't exist..."
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Deploy ArgoCD Application if CRDs are present.
echo "Checking for ArgoCD CRDs..."
if kubectl get crd applications.argoproj.io >/dev/null 2>&1; then
  echo "ArgoCD CRDs are installed. Deploying ArgoCD application manifest..."
  kubectl apply -f argo-app.yaml -n "$NAMESPACE"
else
  echo "WARNING: ArgoCD CRDs not found in the cluster. Skipping ArgoCD application deployment."
fi

# Deploy Prometheus/Alertmanager configurations as ConfigMaps.
echo "Creating ConfigMap for Prometheus configuration..."
kubectl create configmap prometheus-config --from-file=prometheus.yml -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f - --validate=false

echo "Creating ConfigMap for Alertmanager configuration..."
kubectl create configmap alertmanager-config --from-file=alertmanager.yml -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f - --validate=false

if [ -f "prometheus-rules.yml" ]; then
  echo "Creating ConfigMap for Prometheus rules..."
  kubectl create configmap prometheus-rules --from-file=prometheus-rules.yml -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f - --validate=false
fi

# Optionally deploy Prometheus if deployment files exist.
if [ "$PROMETHEUS_DEPLOYMENT" = true ]; then
  echo "Deploying Prometheus..."
  kubectl apply -f prometheus-deployment.yaml -n "$NAMESPACE"
  kubectl apply -f prometheus-service.yaml -n "$NAMESPACE"
fi

# Optionally deploy Alertmanager if deployment files exist.
if [ "$ALERTMANAGER_DEPLOYMENT" = true ]; then
  echo "Deploying Alertmanager..."
  kubectl apply -f alertmanager-deployment.yaml -n "$NAMESPACE"
  kubectl apply -f alertmanager-service.yaml -n "$NAMESPACE"
fi

# Optionally deploy Grafana if files are present.
if [ "$GRAFANA_DEPLOYMENT" = true ]; then
  echo "Deploying Grafana..."
  kubectl apply -f grafana/grafana-configmap.yaml -n "$NAMESPACE"
  kubectl apply -f grafana/grafana-deployment.yaml -n "$NAMESPACE"
  kubectl apply -f grafana/grafana-service.yaml -n "$NAMESPACE"
fi

# Wait for resources to settle.
echo "Waiting for resources to be created..."
sleep 20

# List pods in the namespace.
echo "Listing pods in namespace $NAMESPACE (monitoring and Grafana)..."
kubectl get pods -n "$NAMESPACE"

echo "All checks for Level 3 lab passed successfully."
