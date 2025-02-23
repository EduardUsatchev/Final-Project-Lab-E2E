# Level 3 – Bonus Solution: Advanced GitOps & Monitoring

## Overview
Enhance monitoring by integrating custom metrics and auto-scaling with advanced Grafana dashboards.

## Enhancements
1. **Custom Prometheus Rules:**

**prometheus-rules.yml**
\`\`\`yaml
groups:
- name: sample-app-alerts
  rules:
  - alert: HighCPULoad
    expr: sum(rate(container_cpu_usage_seconds_total{pod=~"sample-app.*"}[1m])) by (pod) > 0.8
    for: 2m
    labels:
      severity: critical
    annotations:
      summary: "High CPU load on {{ \$labels.pod }}"
      description: "CPU usage exceeds 80% for over 2 minutes."
\`\`\`

2. **HPA with Custom Metrics:**

**hpa-custom.yaml**
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
  - type: Pods
    pods:
      metric:
        name: custom_cpu_metric
      target:
        type: AverageValue
        averageValue: "50m"
\`\`\`

3. **Grafana Dashboards:**
Export dynamic dashboards that reflect auto-scaling events.

## Deliverables
- Custom Prometheus rules file.
- HPA configuration using custom metrics.
- Grafana dashboard exports or screenshots.
- Documentation of the advanced monitoring enhancements.

---

*This bonus solution demonstrates dynamic monitoring and auto-scaling capabilities.*
