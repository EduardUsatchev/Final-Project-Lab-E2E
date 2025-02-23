# DevOps Engineering Final Project – Assignment Overview and Submission Instructions

## Project Narrative
In this final project, you will assume the role of a DevOps professional tasked with solving real-world challenges such as scaling applications, automating continuous integration and delivery, managing cloud infrastructure securely, and automating operations end-to-end. Your solution will be divided into five levels, each building upon the previous one, and each designed to prepare you for market-ready DevOps practices.

### Goal
Present a solution that addresses the identified challenges by:
- Designing a robust architecture diagram (using a tool like draw.io).
- Submitting a detailed technical solution that demonstrates your understanding of each technology and practice covered in the course.

---

## Assignment Levels

### **Level 1: Docker & Kubernetes**

**Objective:**
- Build a containerized application using Docker with a multi-stage Dockerfile.
- Deploy the application to a Kubernetes cluster (using k3d) with appropriate manifests.
- Optionally, implement bonus features such as a Horizontal Pod Autoscaler (HPA) and a blue-green deployment.

**Mandatory Files to Submit:**
- `Dockerfile`  
  *(Defines the multi-stage build for your container.)*
- `app.py`  
  *(Your sample application code, e.g., a simple Flask app returning "Hello from Level 1 Sample App!")*
- `requirements.txt`  
  *(Lists your Python dependencies. Please pin versions, e.g., `Flask==2.0.3` and `Werkzeug==2.0.3`.)*
- `deployment.yaml`  
  *(Kubernetes deployment manifest that references the local image `sample-app:latest`, with `imagePullPolicy: Never` and a readiness probe.)*
- `service.yaml`  
  *(Kubernetes service manifest exposing your application.)*

**Bonus Files (Optional):**
- `hpa.yaml`  
  *(Horizontal Pod Autoscaler manifest using autoscaling/v1 with CPU requests defined.)*
- `deployment-green.yaml`  
  *(Optional blue-green deployment manifest for advanced deployment strategies.)*

**Submission Instructions for Level 1:**
- Package the mandatory files into a ZIP file or provide a link to a Git repository.
- Ensure the file names match exactly as listed above.
- If you implemented bonus features, include the bonus files as well.
- Include a cover sheet or README describing your implementation and any challenges encountered.

---

### **Level 2: Package Management, Version Control & CI/CD**

**Objective:**
- Package your Kubernetes manifests as a Helm chart.
- Manage your code using Git with a clear branching strategy.
- Automate the build, test, and deployment process using GitHub Actions.

**Mandatory Files to Submit:**
- **Helm Chart Directory** (include all files in the following structure):
  - `Chart.yaml`  
    *(Metadata for your Helm chart.)*
  - `values.yaml`  
    *(Default configuration values.)*
  - `templates/deployment.yaml`  
    *(Templated Kubernetes deployment manifest.)*
  - `templates/service.yaml`  
    *(Templated Kubernetes service manifest.)*
- **Git Repository Submission:**  
  - Provide a link to your Git repository (or a ZIP file of your repository) including documentation of your branching strategy.
- **GitHub Actions Workflow File:**  
  - `.github/workflows/ci-cd.yml`  
    *(Defines your CI/CD pipeline to build the Docker image and deploy using Helm.)*

**Bonus Files (Optional):**
- Any additional configuration files that enhance your CI/CD pipeline (e.g., configurations for canary releases or automated rollbacks).
- Documentation explaining how the bonus enhancements were implemented.

**Submission Instructions for Level 2:**
- Provide your Git repository link or a ZIP file containing your repository, ensuring that the Helm chart and CI/CD workflow file are included.
- Include documentation that explains your Git workflow and CI/CD process.

---

### **Level 3: GitOps & Monitoring**

**Objective:**
- Implement GitOps by using ArgoCD to continuously deploy your application.
- Set up monitoring with Prometheus, Alertmanager, and Grafana.

**Mandatory Files to Submit:**
- `argo-app.yaml`  
  *(ArgoCD application manifest linking your Git repository to your deployment.)*
- `prometheus.yml`  
  *(Configuration for Prometheus to scrape metrics from your application pods.)*
- `alertmanager.yml`  
  *(Configuration for Alertmanager to define alert routes and receivers.)*
- **Grafana Dashboard Exports/Screenshots:**  
  *(Optional but recommended; provide JSON exports or screenshots of your dashboards.)*
- Documentation explaining your GitOps and monitoring setup.

**Bonus Files (Optional):**
- `prometheus-rules.yml`  
  *(Custom Prometheus alert rules.)*
- Any additional manifests or configuration files for enhanced monitoring (e.g., updated HPA configuration).
- Documentation describing your advanced monitoring setup.

**Submission Instructions for Level 3:**
- Package and submit the above YAML files, dashboard exports/screenshots (if applicable), and documentation.
- Clearly label your mandatory and bonus components.

---

### **Level 4: Cloud (AWS EC2 & Terraform)**

**Objective:**
- Provision cloud infrastructure (an EC2 instance) using Terraform.
- Deploy your sample application to AWS using Infrastructure as Code (IaC).

**Mandatory Files to Submit:**
- `main.tf`  
  *(Terraform configuration that provisions an EC2 instance.)*
- Documentation (and/or screenshots) showing successful provisioning of the EC2 instance.

**Bonus Files (Optional):**
- `advanced.tf`  
  *(Additional Terraform configuration for a more advanced architecture.)*
- An updated architecture diagram showing the enhanced infrastructure.
- A bonus report explaining your design decisions and cost optimization strategies.

**Submission Instructions for Level 4:**
- Submit your Terraform configuration file(s) along with documentation confirming the successful deployment.
- Include bonus files and diagrams if you implemented the bonus assignment.


---

### **Level 5: Cloud (AWS VPC & Secrets/Lambda)**

**Objective:**
- Configure a secure AWS VPC using Terraform.
- Deploy an AWS Lambda function that retrieves secrets from AWS Secrets Manager.

**Mandatory Files to Submit:**
- `vpc.tf`  
  *(Terraform configuration for your VPC and subnet.)*
- `lambda_function.py`  
  *(Your AWS Lambda function code.)*
- Documentation describing your VPC configuration and how your Lambda function integrates with AWS Secrets Manager.

**Bonus Files (Optional):**
- `lambda_function_bonus.py`  
  *(Enhanced Lambda function with additional security features, such as simulated MFA checks.)*
- Additional security configuration files (e.g., for network ACLs, CloudWatch alarms).
- A bonus report explaining your advanced security measures.

**Submission Instructions for Level 5:**
- Package and submit your VPC Terraform configuration and Lambda function source code along with documentation.
- If bonus enhancements are implemented, include those files and the accompanying documentation.

---

## General Submission Instructions

- **File Naming & Structure:**  
  Ensure all files are named exactly as listed above. Use the provided directory structure for clarity.

- **Packaging:**  
  You may either submit a link to your Git repository (with a well-organized commit history and documentation) or compress your project folder into a ZIP file named `DevOps_Final_Project_<YourName>.zip`.

- **Documentation:**  
  Include a README file that summarizes your work, the challenges encountered, and any bonus features implemented. Also, include architecture diagrams and screenshots where applicable.

By following these instructions and submitting all required files with the correct naming, you ensure that your project will be evaluated thoroughly. Good luck, and make sure your submission is complete and well-documented!
