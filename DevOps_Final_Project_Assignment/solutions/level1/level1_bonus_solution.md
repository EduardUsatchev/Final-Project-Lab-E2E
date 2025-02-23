# Level 1 – Bonus Solution: Advanced Docker & Kubernetes Assignment

## Overview
Enhance your Level 1 solution by adding:
- Docker image optimizations.
- Advanced Kubernetes features such as Horizontal Pod Autoscaling (HPA) and blue-green deployments.

## Docker Optimization
Optimize the Dockerfile for smaller image size and faster builds.

## Kubernetes Enhancements

1. **Horizontal Pod Autoscaler (HPA):**

**hpa.yaml**
\`\`\`yaml
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: sample-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: sample-app
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
\`\`\`

2. **Blue-Green Deployment:**

**deployment-green.yaml**
\`\`\`yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app-green
spec:
  replicas: 3
  selector:
    matchLabels:
      app: sample-app
      version: green
  template:
    metadata:
      labels:
        app: sample-app
        version: green
    spec:
      containers:
      - name: sample-app
        image: yourdockerhub/sample-app:latest
        ports:
        - containerPort: 5000
\`\`\`

## Documentation
Update your architecture diagram and explain:
- How HPA scales your application.
- How blue-green deployments minimize downtime.

---

*This bonus solution demonstrates advanced scaling and deployment techniques.*
