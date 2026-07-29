terraform {
  backend "s3" {
    bucket         = "REPLACE_WITH_YOUR_STATE_BUCKET"
    key            = "networking-capstone/terraform.tfstate"
    region         = "us-west-1"
    dynamodb_table = "networking-capstone-tf-locks"
    encrypt        = true
  }
}
