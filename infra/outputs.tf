# ====================== OUTPUTS ======================

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer - Your live URL"
  value       = aws_lb.main.dns_name
}

output "health_check_url" {
  description = "Direct URL to test health endpoint"
  value       = "http://${aws_lb.main.dns_name}/health"
}


output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.main.repository_url
}

#### ECS Outputs
output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.app.name
}

# VPC Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "github_actions_role_arn" {
  description = "ARN of the IAM Role for GitHub Actions (OIDC)"
  value       = aws_iam_role.github_actions.arn

}

# EKS Outputs
output "eks_cluster_enpoint" {
  description = "EKS Cluster Endpoint"
  value       = aws_eks_cluster.main.endpoint
}
output "aws_eks_cluster_name" {
  description = "Name of the EKS Cluster"
  value       = aws_eks_cluster.main.name
}

output "aws_cluster_arn" {
  description = "ARN of the EKS Cluster"
  value       = aws_eks_cluster.main.arn
}

# sqs outputs
output "sqs_main_queue_url" {
  description = "URL of the main SQS queue"
  value       = aws_sqs_queue.main.id
}

output "sqs_dlq_url" {
  description = "URL of the dead-letter SQS queue"
  value       = aws_sqs_queue.dlq.id
}

# lambda outputs
output "lambda_function_name" {
  description = "the name of the Lambda functiom"
  value = aws_lambda_function.worker.function_name
}



