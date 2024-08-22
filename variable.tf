variable "subnet-cidr-block" {
  description = "CIDR block for the subnet"
  type        = string
}

variable "vpc-cidr-block" {
  description = "CIDR block for the vpc"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}