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

output "ecs_cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.app.name
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = aws_db_instance.main.endpoint
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}
