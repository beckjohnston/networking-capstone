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

variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
  default     = "networking-capstone"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
