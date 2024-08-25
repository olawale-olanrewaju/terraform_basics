output "app-vpc-id" {
  value = aws_vpc.app-vpc.id
}

output "app-subnet-1-id" {
  value = aws_subnet.app-subnet-1.id
}

output "aws-ami" {
  value = data.aws_ami.app-ami.id
}

output "app-server-public-ip" {
  value = aws_instance.app-server.public_ip
}
