variable "app_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "nairatransfer-pro"
}

variable "aws_region" {
  description = "AWS REGION"
  type        = string
  default     = "eu-north-1"
}

variable "environment" {
  description = "Environment dev or prod"
  type        = string
  default     = "dev"
}

variable "image_tag" {
  description = "Docker image tag to deploy"
  type        = string
  default     = "latest"
}
variable "container_port" {
  description = "Port on which the container listens"
  type        = number
  default     = 8000
}