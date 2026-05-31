# NairaTransfer Pro - Runbook

## System Overview

- **Backend**: FastAPI (Python)
- **Orchestration**: Amazon ECS Fargate + Amazon EKS
- **Async Processing**: SQS + Lambda Worker + DLQ
- **Infrastructure**: Terraform + (S3 Remote State & DynamoDB Locking)
- **CI/CD**: GitHub Actions + OIDC

---

## Common Incidents & Recovery

### 1. Application Not Responding (503 / 404)

**Checks:**

- ALB Target Group health
- ECS Task status
- CloudWatch Logs (`/ecs/nairatransfer-pro`)

**Recovery:**

```bash
aws ecs update-service \
  --cluster nairatransfer-pro-cluster \
  --service nairatransfer-pro-service \
  --force-new-deployment \
  --region eu-north-1

2. Transfers Not Being Processed
Checks:

    SQS Console → Messages Available / In Flight
    Lambda Logs
    DLQ (nairatransfer-pro-dlq)

Recovery:

aws logs tail /aws/lambda/nairatransfer-pro-worker --region eu-north-1 --follow

3. High CPU / Performance Issues
Checks:

    CloudWatch Alarms
    ECS / EKS metrics

Recovery:

    ECS autoscaling should trigger automatically
    For EKS: kubectl get hpa

4. Secret or Database Issues
Recovery:

    Update value in AWS Secrets Manager
    Run terraform apply


# Health Check
curl http://nairatransfer-pro-alb-723344055.eu-north-1.elb.amazonaws.com/health

# Force Redeploy ECS
aws ecs update-service --cluster nairatransfer-pro-cluster --service nairatransfer-pro-service --force-new-deployment --region eu-north-1

# Check Lambda Logs
aws logs tail /aws/lambda/nairatransfer-pro-worker --region eu-north-1 --follow

# Check SQS Queue
aws sqs get-queue-attributes \
  --queue-url https://sqs.eu-north-1.amazonaws.com/006508975119/nairatransfer-pro-main-queue \
  --attribute-names ApproximateNumberOfMessages




```
