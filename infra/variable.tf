variable "region" {
    description = "The AWS region to deploy resources in."
    default = "eu-north-1"
}

variable "project_name" {
    description = "The name of the project to be used in resource naming."
    default = "nairatransfer-pro"
}
  
  variable "environment" {
    description = "The deployment environment (e.g., dev, staging, prod)."
    default = "dev"
}

variable "image_tag" {
    description = "The Docker image tag to be used for the application."
    default = "latest"
  
}