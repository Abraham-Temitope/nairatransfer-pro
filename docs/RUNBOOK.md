# NairaTransfer Pro - Runbook

## Overview

- ECS Fargate + ALB
- SQS + Lambda worker
- EKS deployment

## Common Incidents & Recovery

### 1. High CPU / Scaling Issue

- Check: CloudWatch → Alarms
- Action:
  - ECS autoscaling should handle it
  - For EKS: `kubectl get hpa`

  ### 2. SQS Messages Not Processing
  - Check:
  - SQS Console → Messages Available
  - Lambda logs: `aws logs tail /aws/lambda/nairatransfer-pro-worker`
  - Action: - Check DLQ (`nairatransfer-pro-dlq`)
  - Reprocess failed messages if needed

  ### 3. Application 503 / Not Found

- Check:
- ALB Target Health
  - ECS Task status
  - Logs: CloudWatch Log Group `/ecs/nairatransfer-pro`
- Action: Force new deployment

## Quick Commands

```bash
# Check ECS

aws ecs describe-services --cluster nairatransfer-pro-cluster --services nairatransfer-pro-service --region eu-north-1

# Check Lambda
aws logs tail /aws/lambda/nairatransfer-pro-worker --region eu-north-1 --follow

# Force deployment
aws ecs update-service --cluster nairatransfer-pro-cluster --service nairatransfer-pro-service --force-new-deployment --region eu-north-1



```
