# NairaTransfer Pro

**Production-Grade Fintech Payment Transfer System on AWS**

A scalable, observable, and asynchronous backend for money transfers, built with modern DevOps tools on AWS.

**Live Endpoint**: [Health Check](http://nairatransfer-pro-alb-723344055.eu-north-1.elb.amazonaws.com/health)

---

## Architecture

### System Context Diagram v3.2# Fintech Transfer System Architecture

````mermaid
graph TD
A[Start] --> B[End]```






---

## Tech Stack

- **IaC**: Terraform
- **Compute**: Amazon ECS Fargate + Amazon EKS (with HPA)
- **Container Registry**: Amazon ECR
- **CI/CD**: GitHub Actions + OIDC
- **Async**: Amazon SQS + DLQ + AWS Lambda
- **Observability**: Amazon CloudWatch (Metrics, Alarms & Logs)
- **Security**: AWS Secrets Manager + IAM Least Privilege
- **Backend**: FastAPI (Python)
- **Terraform State**: S3(Remote) + DynamoDB Locking

---

## Key Features & Capabilities

- **Multi-Orchestration**: Deployed the same application on both **ECS Fargate** (serverless) and **EKS** to demonstrate platform comparison and trade-offs.
- **Fully Automated CI/CD**: Secure pipeline using GitHub Actions with OIDC federation. Zero hardcoded credentials.
- **Reliable Async Processing**: SQS queue with Dead Letter Queue (DLQ) and retry mechanism for failed transfers.
- **Production Observability**: CloudWatch alarms for CPU, latency, and error rates with SNS notifications.
- **Autoscaling**: ECS Application Autoscaling + Kubernetes Horizontal Pod Autoscaler (HPA).
- **Security & Cost Control**: Secrets Manager integration, private subnets, least-privilege IAM, and strict cost optimization during development.

---

## What This Project Demonstrates

- End-to-end ownership of infrastructure using Terraform (Including remote state using S3 + DynamoDB locking) and deployment pipelines
- Real-world problem solving (stale image caching, orphaned resources, EKS controller issues)
- Understanding of high availability (Multi-AZ), reliability (DLQ), and observability patterns
- Ability to compare and work with different orchestration tools (ECS vs EKS)

---

## Repository Structure

```bash
nairatransfer-pro/
├── app/                    # FastAPI application code
├── backend/                # Terraform Remote Backend (S3 + DynamoDB)
├── infra/                  # Terraform Infrastructure
├── k8s/                    # Kubernetes manifests
├── lambda/                 # Lambda worker code
├── .github/workflows/      # CI/CD pipelines
└── docs/                   # Architecture & runbooks

````
