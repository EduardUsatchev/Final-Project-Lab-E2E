# Level 1 – Mandatory Solution: Docker & Kubernetes (Basics & Advanced)

## Overview
This solution demonstrates how to build a containerized application using Docker and deploy it on a Kubernetes cluster. The task covers:
- Creating a multi-stage Dockerfile for a simple application (for example, a Flask web app).
- Deploying the built image using Kubernetes manifests for a Deployment and a Service.

## Docker – Multi-Stage Build

**Dockerfile**
\`\`\`dockerfile
# Stage 1: Builder
FROM python:3.9-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Stage 2: Final image
FROM python:3.9-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:\$PATH
EXPOSE 5000
CMD ["python", "app.py"]
\`\`\`

*Notes:*
- \`requirements.txt\` lists your dependencies.
- \`app.py\` is a simple Flask app running on port 5000.

## Kubernetes – Deployment and Service

**deployment.yaml**
\`\`\`yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - name: sample-app
        image: yourdockerhub/sample-app:latest
        ports:
        - containerPort: 5000
\`\`\`

**service.yaml**
\`\`\`yaml
apiVersion: v1
kind: Service
metadata:
  name: sample-app-service
spec:
  selector:
    app: sample-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 5000
  type: ClusterIP
\`\`\`

## Steps to Complete
1. **Build the Docker Image:**
   \`\`\`bash
   docker build -t yourdockerhub/sample-app:latest .
   \`\`\`
2. **Test Locally:**
   \`\`\`bash
   docker run -p 5000:5000 yourdockerhub/sample-app:latest
   \`\`\`
3. **Deploy to Kubernetes:**
   \`\`\`bash
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
   \`\`\`
4. **Verify:**
   Check pods with \`kubectl get pods\` and services with \`kubectl get svc sample-app-service\`.

## Architecture Diagram
Sketch a diagram that shows:
- The Docker multi-stage build.
- The deployment of containers in Kubernetes.

---

*This solution demonstrates building, testing, and deploying a containerized application using Docker and Kubernetes.*
