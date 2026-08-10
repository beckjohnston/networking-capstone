variable "vpc1_cidr" {
  default = "10.0.0.0/16"
}

variable "vpc2_cidr" {
  default = "10.1.0.0/16"
}

variable "vpc3_cidr" {
  default = "10.2.0.0/16"
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}
