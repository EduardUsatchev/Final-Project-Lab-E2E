# Reference Document – Hints and Guidance

This document provides hints and best practices to help you complete the DevOps Final Project assignment.

## General Hints
- Read the project narrative and plan your solution.
- Use draw.io (or similar) to create architecture diagrams.
- Tackle each level individually and test thoroughly.

## Level-Specific Hints
### Level 1: Docker & Kubernetes
- Build efficient Docker images using multi-stage builds.
- Deploy your containerized app on Kubernetes using YAML manifests.
- Bonus: Add Horizontal Pod Autoscaling (HPA) and blue-green deployments.

### Level 2: Helm, Git & CI/CD
- Package your Kubernetes manifests as a Helm chart.
- Use Git with a clear branching strategy.
- Set up GitHub Actions to automate building and deploying.
- Bonus: Enhance CI/CD with canary releases and rollbacks.

### Level 3: GitOps & Monitoring
- Use ArgoCD to sync your Git repo with Kubernetes.
- Configure Prometheus and Alertmanager for monitoring.
- Bonus: Integrate custom metrics and dynamic Grafana dashboards.

### Level 4: AWS EC2 & Terraform
- Provision cloud resources with Terraform.
- Deploy a sample app on an EC2 instance.
- Bonus: Design a high-availability, auto-scaling architecture.

### Level 5: AWS VPC & Secrets/Lambda
- Create a secure VPC using Terraform.
- Deploy a Lambda function that retrieves secrets.
- Bonus: Add network ACLs, MFA simulation, and CloudWatch alarms.

Good luck and document every step!
