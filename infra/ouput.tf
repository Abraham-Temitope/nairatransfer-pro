output "alb_dns_name" {
    value = aws_lb.alb.dns_name
}

output "aws_ecr_repository_uri" {
    value = aws_ecr_repository.main.repository_url
  
}

output "ecs_cluster_name" {
    value = aws_ecs_cluster.main.name
}

output "rds_endpoint" {
    value = aws_db_instance.main.endpoint
}