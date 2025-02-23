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
