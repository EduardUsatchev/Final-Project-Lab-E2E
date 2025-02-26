# **Final Project Lab - End-to-End DevOps Solution**

## **Overview**
This repository contains a multi-level **DevOps Final Project** that builds, automates, and deploys infrastructure using **Terraform**, **Kubernetes**, **AWS (or LocalStack for local testing)**, and other DevOps tools. Each level introduces a new concept, leading to a full-fledged cloud deployment.

Each level contains:
- Terraform configuration files (`.tf`) to provision infrastructure.
- A `check_lab.sh` script to validate your solution.
- A solution document (`levelX_mandatory_solution.md` and `levelX_bonus_solution.md`).

## **Prerequisites**
Before running any level, ensure you have the following installed:
- **Terraform** (`>=1.0`)
- **AWS CLI** (for real AWS) or **LocalStack CLI** (for local testing)
- **Kubernetes CLI (`kubectl`)** (for Level 3+)
- **Docker** (for containerized solutions)

## **Project Structure**
```
Final-Project-Lab-E2E/
│── level1/      # Basic Infrastructure Setup
│── level2/      # CI/CD Pipeline & Docker
│── level3/      # Kubernetes Deployment
│── level4/      # AWS EC2 Deployment (with Terraform)
│── level5/      # AWS EC2 & EBS with Terraform
│── solutions/   # Reference solutions for each level
│── README.md    # This file (Guide & Instructions)
```

## **Running Each Level**
Each level has a **`check_lab.sh`** script that automates validation. Below are the instructions for each level:

### **Level 1: Basic Infrastructure Setup**
- **Objective:** Set up a basic infrastructure.
- **How to run:**
  ```sh
  cd level1
  terraform init
  terraform apply -auto-approve
  ./check_lab1.sh
  ```
- [Check Lab 1](./level1/check_lab1.sh)

---
### **Level 2: CI/CD Pipeline & Docker**
- **Objective:** Build a CI/CD pipeline using **GitHub Actions/Jenkins** & Docker.
- **How to run:**
  ```sh
  cd level2
  ./run_lab.sh  # This script builds and tests the pipeline
  ./check_lab2.sh
  ```
- [Check Lab 2](./level2/check_lab2.sh)

---
### **Level 3: Kubernetes Deployment**
- **Objective:** Deploy the application to Kubernetes using **Helm and Prometheus for monitoring**.
- **How to run:**
  ```sh
  cd level3
  kubectl apply -f k8s-manifests/
  ./check_lab3.sh
  ```
- [Check Lab 3](./level3/check_lab3.sh)

---
### **Level 4: AWS EC2 Deployment (Terraform)**
- **Objective:** Provision **EC2 instances** and deploy the sample app using **Terraform**.
- **How to run (AWS):**
  ```sh
  cd level4
  terraform init
  terraform apply -auto-approve
  ./check_lab4.sh
  ```
- **How to run (LocalStack):**
  ```sh
  localstack start -d
  cd level4
  terraform init
  terraform apply -auto-approve
  ./check_lab4.sh
  ```
- [Check Lab 4](./level4/check_lab4.sh)

---
### **Level 5: AWS EC2 & EBS with Terraform**
- **Objective:** Deploy an EC2 instance with an attached **EBS volume**.
- **How to run (AWS):**
  ```sh
  cd level5
  terraform init
  terraform apply -auto-approve
  ./check_lab5.sh
  ```
- **How to run (LocalStack):**
  ```sh
  localstack start -d
  cd level5
  terraform init
  terraform apply -auto-approve
  ./check_lab5.sh
  ```
- [Check Lab 5](./level5/check_lab5.sh)

---
## **Solution Summary**
Each level builds upon the previous one to form a complete **DevOps workflow**:
- **Level 1**: Sets up basic infrastructure using Terraform.
- **Level 2**: Automates the build & deployment process using CI/CD.
- **Level 3**: Deploys the application in Kubernetes with monitoring.
- **Level 4**: Provisions cloud infrastructure (EC2) using Terraform.
- **Level 5**: Extends EC2 with EBS volumes for persistence.

## **Troubleshooting**
If you face issues:
1. Run Terraform **init & refresh**:
   ```sh
   terraform init
   terraform refresh
   ```
2. Ensure LocalStack is running (if applicable):
   ```sh
   localstack status
   ```
3. Check AWS credentials:
   ```sh
   aws sts get-caller-identity
   ```
4. Check logs:
   ```sh
   tail -f /var/log/syslog
   ```

