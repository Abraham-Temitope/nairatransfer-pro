output "s3_bucket_name" {
  description = "Name of the S3 bucket used for Terraform state storage"
  value       = "topmost-s3-bucket-terraform"
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used for Terraform state locking"
  value       = "nairatransfer-tf-locks"
}