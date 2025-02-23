# Level 2 – Bonus Solution: Advanced Package Management, Version Control & CI/CD

## Overview
Enhance the CI/CD pipeline to support zero-downtime deployments through canary releases and automated rollbacks.

## Enhancements
1. **Helm:** Update charts to support multiple environments.
2. **CI/CD:** Extend the GitHub Actions workflow with:
   - Canary deployment stage.
   - Automated rollback on failure.

Example snippet:
\`\`\`yaml
jobs:
  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Set up kubectl
        uses: azure/setup-kubectl@v1
        with:
          version: 'v1.18.0'
      - name: Deploy Canary Release
        run: |
          helm upgrade --install sample-app-canary helm/sample-app --namespace default --set replicaCount=1,image.tag=canary
      - name: Monitor Deployment
        run: |
          echo "Monitoring deployment..."
      - name: Rollback Deployment
        if: failure()
        run: |
          helm rollback sample-app-canary 1
\`\`\`

## Deliverables
- Updated Helm chart supporting multi-environment.
- Enhanced CI/CD workflow.
- Documentation of the zero-downtime strategy.

---

*This bonus solution adds advanced CI/CD practices for zero-downtime deployments.*
