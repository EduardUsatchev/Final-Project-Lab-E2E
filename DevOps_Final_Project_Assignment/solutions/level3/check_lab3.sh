#!/bin/bash
# check_lab3.sh – End-to-End Check for Student Level 3 Lab (GitOps, Monitoring, & Full Deployments)
#
# This script verifies that the following files exist in the solutions/level3/ folder:
#
# Mandatory:
#   - argo-app.yaml         (ArgoCD Application manifest)
#   - prometheus.yml        (Prometheus configuration file)
#   - alertmanager.yml      (Alertmanager configuration file)
#
# Optional Bonus:
#   - prometheus-rules.yml  (custom Prometheus alert rules; must include an always-firing rule)
#   - Any Grafana dashboard JSON files (if any exist in the root)
#
# Optional Full Deployments:
#   - Prometheus: prometheus-deployment.yaml, prometheus-service.yaml
#   - Alertmanager: alertmanager-deployment.yaml, alertmanager-service.yaml
#   - Grafana: a folder "grafana/" with grafana-configmap.yaml, grafana-deployment.yaml, and grafana-service.yaml
#
# The script ensures that a k3d cluster ("lab-cluster") exists, sets the kubectl context,
# creates (or ensures) the "devops-lab" namespace,
# and then deploys:
#   - The ArgoCD Application (if CRDs exist)
#   - ConfigMaps for Prometheus, Alertmanager, and (optionally) Prometheus rules
#   - Full deployments for Prometheus, Alertmanager, and Grafana (if their manifest files exist)
#
# Before deploying Prometheus and Alertmanager, it applies RBAC rules that grant the default
# service account in devops-lab permissions to list and watch pods and nodes.
#
# Then, it deletes any existing monitoring pods to force a fresh deployment,
# waits for 120 seconds to let Prometheus evaluate the alert rules,
# and finally port-forwards Alertmanager (using port 9094 locally) to query its API for the test alert.
#
# Usage:
#   chmod +x check_lab3.sh
#   ./check_lab3.sh
#

set -e

echo "=== Student Lab Level 3 Check (Mandatory + Optional Bonus) ==="

# --- Mandatory Files Check ---
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

# --- Optional Bonus Files ---
if [ -f "prometheus-rules.yml" ]; then
  echo "Found optional bonus file: prometheus-rules.yml"
fi

GRAFANA_FILES=$(find . -maxdepth 1 -type f -name "*.json")
if [ -n "$GRAFANA_FILES" ]; then
  echo "Found optional Grafana dashboard JSON files:"
  echo "$GRAFANA_FILES"
else
  echo "No optional Grafana dashboard JSON files found."
fi

# --- Optional Deployment Manifests Check ---
if [ -f "prometheus-deployment.yaml" ] && [ -f "prometheus-service.yaml" ]; then
  echo "Prometheus deployment files found."
  PROMETHEUS_DEPLOYMENT=true
  for file in prometheus-deployment.yaml prometheus-service.yaml; do
    if [ ! -s "$file" ]; then
      echo "ERROR: Deployment file '$file' exists but is empty."
      exit 1
    else
      echo "Deployment file '$file' is valid."
    fi
  done
else
  echo "No Prometheus deployment files found; using ConfigMap only for Prometheus."
  PROMETHEUS_DEPLOYMENT=false
fi

if [ -f "alertmanager-deployment.yaml" ] && [ -f "alertmanager-service.yaml" ]; then
  echo "Alertmanager deployment files found."
  ALERTMANAGER_DEPLOYMENT=true
  for file in alertmanager-deployment.yaml alertmanager-service.yaml; do
    if [ ! -s "$file" ]; then
      echo "ERROR: Deployment file '$file' exists but is empty."
      exit 1
    else
      echo "Deployment file '$file' is valid."
    fi
  done
else
  echo "No Alertmanager deployment files found; using ConfigMap only for Alertmanager."
  ALERTMANAGER_DEPLOYMENT=false
fi

if [ -d "grafana" ]; then
  echo "Grafana deployment files found in the 'grafana/' folder."
  GRAFANA_DEPLOYMENT=true
else
  echo "No Grafana deployment files found (folder 'grafana/' missing)."
  GRAFANA_DEPLOYMENT=false
fi

# --- Required Commands Check ---
for cmd in kubectl k3d; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: $cmd is required but not installed. Aborting."
    exit 1
  fi
done

# --- Cluster and Namespace Setup ---
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

# --- Apply RBAC for Prometheus/Alertmanager ---
echo "Applying RBAC for Prometheus and Alertmanager..."
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: prometheus-role
rules:
- apiGroups: [""]
  resources: ["pods", "nodes"]
  verbs: ["list", "watch"]
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: prometheus-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: prometheus-role
subjects:
- kind: ServiceAccount
  name: default
  namespace: $NAMESPACE
EOF

# --- Deployment Phase ---
echo "Checking for ArgoCD CRDs..."
if kubectl get crd applications.argoproj.io >/dev/null 2>&1; then
  echo "ArgoCD CRDs are installed. Deploying ArgoCD application manifest..."
  kubectl apply -f argo-app.yaml -n "$NAMESPACE"
else
  echo "WARNING: ArgoCD CRDs not found in the cluster. Skipping ArgoCD application deployment."
fi

echo "Creating ConfigMap for Prometheus configuration..."
kubectl create configmap prometheus-config --from-file=prometheus.yml -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f - --validate=false

echo "Creating ConfigMap for Alertmanager configuration..."
kubectl create configmap alertmanager-config --from-file=alertmanager.yml -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f - --validate=false

if [ -f "prometheus-rules.yml" ]; then
  echo "Creating ConfigMap for Prometheus rules..."
  kubectl create configmap prometheus-rules --from-file=prometheus-rules.yml -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f - --validate=false
fi

if [ "$PROMETHEUS_DEPLOYMENT" = true ]; then
  echo "Deploying Prometheus..."
  kubectl apply -f prometheus-deployment.yaml -n "$NAMESPACE"
  kubectl apply -f prometheus-service.yaml -n "$NAMESPACE"
fi

if [ "$ALERTMANAGER_DEPLOYMENT" = true ]; then
  echo "Deploying Alertmanager..."
  kubectl apply -f alertmanager-deployment.yaml -n "$NAMESPACE"
  kubectl apply -f alertmanager-service.yaml -n "$NAMESPACE"
fi

if [ "$GRAFANA_DEPLOYMENT" = true ]; then
  echo "Deploying Grafana..."
  kubectl apply -f grafana/grafana-configmap.yaml -n "$NAMESPACE"
  kubectl apply -f grafana/grafana-deployment.yaml -n "$NAMESPACE"
  kubectl apply -f grafana/grafana-service.yaml -n "$NAMESPACE"
fi

# --- Delete Existing Monitoring Pods ---
echo "Deleting existing monitoring pods..."
kubectl delete pod -l app=prometheus -n "$NAMESPACE" --ignore-not-found
kubectl delete pod -l app=alertmanager -n "$NAMESPACE" --ignore-not-found
if [ "$GRAFANA_DEPLOYMENT" = true ]; then
  kubectl delete pod -l app=grafana -n "$NAMESPACE" --ignore-not-found
fi

echo "Waiting for resources to be created..."
sleep 20

echo "Listing pods in namespace $NAMESPACE (monitoring components and Grafana)..."
kubectl get pods -n "$NAMESPACE"

# --- Trigger and Verify Test Alert ---
echo "Waiting for alert rules to evaluate (120 seconds)..."
sleep 120

echo "Port-forwarding Alertmanager to check active alerts..."
kubectl port-forward svc/alertmanager 9094:9093 -n "$NAMESPACE" &
ALERT_PID=$!
sleep 10
ALERTS=$(curl -s http://localhost:9094/api/v2/alerts)
kill $ALERT_PID

echo "Active alerts from Alertmanager:"
echo "$ALERTS"

if echo "$ALERTS" | grep -q "AlwaysFiringTestAlert"; then
  echo "Test alert 'AlwaysFiringTestAlert' successfully triggered!"
else
  echo "ERROR: Test alert 'AlwaysFiringTestAlert' not found in Alertmanager!"
  exit 1
fi

echo "All checks for Level 3 lab passed successfully."
