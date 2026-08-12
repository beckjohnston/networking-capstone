variable "aws_region" {
  type    = string
  default = "us-west-1"
}

variable "state_bucket_name" {
  type    = string
  default = "beck-networking-capstone-tfstate-2026"
}

variable "lock_table_name" {
  type    = string
  default = "networking-capstone-tf-locks"
}
