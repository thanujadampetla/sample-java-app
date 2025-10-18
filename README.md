# Sample Java App - AWS CI/CD Pipeline

This project sets up a CI/CD pipeline using Jenkins, Maven, Docker, Terraform, Ansible, and Kubernetes (EKS) on AWS.

## Folder Structure
- **terraform/** → AWS infra setup
- **ansible/** → Jenkins setup automation
- **k8s/** → Kubernetes manifests
- **app/** → Java app + Jenkinsfile

## Jenkinsfile Pipeline
1. Clone from GitHub
2. Build with Maven
3. Build & Push Docker Image
4. Deploy to Kubernetes
