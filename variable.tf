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

variable "my-ip-address" {
  description = "My local ip address"
  type        = string
}

variable "instance_type" {
  type = string
}

variable "public_key_location" {
  description = "Path to local public key"
  type = string
}

variable "number_of_instance" {
  type = number
}

variable "private_key_location" {
  description = "Path to local public key"
  type = string
}