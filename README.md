# NairaTransfer Pro

**Production-Grade Fintech Payment Transfer System on AWS**

A scalable, observable, and asynchronous backend for money transfers, built with modern DevOps tools on AWS.

**Live Endpoint**: [Health Check](http://nairatransfer-pro-alb-723344055.eu-north-1.elb.amazonaws.com/health)

---

## Architecture

### System Context Diagram v3.2
This diagram shows the full 5-layer AWS architecture. It renders directly in GitHub.

```mermaid
C4Context
    title nairatransfer.com - AWS Fintech Architecture v3.2

    Person(customer, "Customer", "Uses Web/Mobile App to send transfers")

    System_Ext(dns, "Amazon Route 53", "nairatransfer.com DNS")
    System_Ext(bank, "Partner Bank / NIBSS", "Outbound Payouts")
    System_Ext(gh, "GitHub Actions", "Build, Test, Deploy. OIDC to AWS")

    System_Boundary(vpc, "AWS VPC - 10.0.0.0/16") {
        
        System(waf, "AWS WAF", "Rate Limiting, Bot Protection")
        System(alb, "Application Load Balancer", "TLS Termination")

        System(eks, "Amazon EKS", "FastAPI Backend API. HPA")
        System(ecs, "Amazon ECS Fargate", "Background Workers")
        System(irsa, "IRSA", "IAM Roles for Service Accounts. No Static Keys")

        SystemDb(rds, "Amazon RDS PostgreSQL", "Ledger, Wallets. Multi-AZ")
        SystemDb(redis, "Amazon ElastiCache Redis", "API Cache")

        System(sqs, "Amazon SQS", "Transfer Job Queue")
        System(dlq, "SQS Dead Letter Queue", "Failed Jobs")
        System(lambda, "AWS Lambda", "DLQ Processor")

        System(ecr, "Amazon ECR", "Container Registry")
        System(s3, "Amazon S3", "Terraform State")
        System(ddb, "Amazon DynamoDB", "Terraform State Lock")
        System(secrets, "AWS Secrets Manager", "Secrets")
        System(cw, "Amazon CloudWatch", "Metrics, Logs, Alarms")
        System(nat, "NAT Gateway", "Outbound Internet")
    }

    Rel(customer, dns, "HTTPS 443")
    Rel(dns, waf, "")
    Rel(waf, alb, "")
    Rel(alb, eks, "Ingress")
    Rel(eks, irsa, "Assume Role")
    Rel(ecs, irsa, "Assume Role")
    Rel(eks, sqs, "")
    Rel(ecs, sqs, "")
    Rel(ecs, rds, "")
    Rel(eks, rds, "")
    Rel(ecs, bank, "via NAT")
    Rel(ecs, dlq, "")
    Rel(dlq, lambda, "")
    Rel(gh, ecr, "")
    Rel(eks, ecr, "")
    Rel(ecs, ecr, "")
    Rel(eks, cw, "")
    Rel(ecs, cw, "")
    Rel(gh, s3, "")
    Rel(gh, ddb, "")



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

```
