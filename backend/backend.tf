terraform {
   backend "s3" {
   bucket         = "topmost-s3-bucket-terraform"
   key            = "nairatransfer-pro/terraform.tfstate"
   region         = "eu-north-1"
   encrypt        = true
  dynamodb_table = "nairatransfer-tf-locks"
  }
}