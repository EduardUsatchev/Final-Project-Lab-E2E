# Level 2 – Mandatory Solution: Package Management, Version Control & CI/CD

## Overview
Integrate Helm for package management, Git for version control, and GitHub Actions for CI/CD to automate deployments.

## Helm Chart

Files:
- **Chart.yaml**
- **values.yaml**
- **templates/deployment.yaml**
- **templates/service.yaml**

Refer to the Helm chart files in the \`helm/sample-app\` directory.

## Git Workflow
Initialize a Git repository and use a branching strategy (e.g., GitFlow).

## CI/CD Pipeline

Create a GitHub Actions workflow at \`.github/workflows/ci-cd.yml\` that:
- Checks out code.
- Builds the Docker image.
- Deploys using Helm.

\`\`\`yaml
name: CI/CD Pipeline

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v2
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v1
      - name: Build Docker Image
        uses: docker/build-push-action@v2
        with:
          context: .
          push: false
          tags: yourdockerhub/sample-app:latest

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Set up kubectl
        uses: azure/setup-kubectl@v1
        with:
          version: 'v1.18.0'
      - name: Deploy using Helm
        run: |
          helm upgrade --install sample-app helm/sample-app --namespace default
\`\`\`

## Deliverables
- Helm chart directory.
- Git repository with documentation.
- GitHub Actions workflow file.

---

*This solution demonstrates automated deployments using Helm, Git, and GitHub Actions.*
