terraform {
  backend "s3" {
    bucket         = "beck-networking-capstone-tfstate-2026"
    key            = "networking-capstone/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "networking-capstone-tf-locks"
    encrypt        = true
  }
}
