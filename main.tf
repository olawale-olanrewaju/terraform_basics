
provider "aws" {
  # Configuration options
  region = "us-east-1"
}

resource "aws_vpc" "dev-vpc" {
  cidr_block = var.vpc-cidr-block

  tags = {
    Name: var.environment
  }
}

resource "aws_subnet" "dev-subnet-1" {
  vpc_id = aws_vpc.dev-vpc.id
  cidr_block = var.subnet-cidr-block
  availability_zone = "us-east-1a"

  tags = {
    Name: var.environment
  }
}