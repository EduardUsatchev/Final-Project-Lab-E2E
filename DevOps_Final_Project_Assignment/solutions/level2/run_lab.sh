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
