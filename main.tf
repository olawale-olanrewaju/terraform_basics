
provider "aws" {
  # Configuration options
  region = "us-east-1"
}

resource "aws_vpc" "app-vpc" {
  cidr_block = var.vpc-cidr-block

  tags = {
    Name : "${var.environment}-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "app-subnet-1" {
  vpc_id            = aws_vpc.app-vpc.id
  cidr_block        = var.subnet-cidr-block
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name : "${var.environment}-subnet-1"
  }
}

resource "aws_route_table" "app-rt" {
  vpc_id = aws_vpc.app-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name : "${var.environment}-rtb"
  }
}

resource "aws_route_table_association" "rt_assoc-subnet-1" {
  subnet_id      = aws_subnet.app-subnet-1.id
  route_table_id = aws_route_table.app-rt.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app-vpc.id

  tags = {
    Name : "${var.environment}-igw"
  }
}

# Add new route to default route table
# resource "aws_default_route_table" "default-rtb" {
#   default_route_table_id = aws_vpc.app-vpc.default_route_table_id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }

#   tags = {
#     Name: "${var.environment}-main-rtb"
#   }

# }

resource "aws_security_group" "app-sg" {
  name        = "app-sg"
  description = "Allow http and ssh traffic"
  vpc_id      = aws_vpc.app-vpc.id

  tags = {
    Name : "${var.environment}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-incoming-http" {
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.app-sg.id
  ip_protocol       = "tcp"
  to_port           = 8080
  from_port         = 8080
}

resource "aws_vpc_security_group_ingress_rule" "allow-incoming-ssh" {
  cidr_ipv4         = "${var.my-ip-address}/32"
  security_group_id = aws_security_group.app-sg.id
  ip_protocol       = "tcp"
  to_port           = 22
  from_port         = 22
}

resource "aws_vpc_security_group_egress_rule" "allow-all-egress" {
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.app-sg.id
  ip_protocol       = "-1"
}

# Or edit the default security group
# resource "aws_default_security_group" "default-sg" {
#   vpc_id = aws_vpc.app-vpc.id

#   ingress {
#     protocol  = "tcp"
#     from_port = 8080
#     to_port   = 8080
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   ingress {
#     protocol  = "tcp"
#     from_port = 22
#     to_port   = 22
#     cidr_blocks = ["${var.my-ip-address}/32"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

# }

resource "aws_instance" "app-server" {
  count = var.number_of_instance
  ami           = data.aws_ami.app-ami.id
  instance_type = var.instance_type

  subnet_id              = aws_subnet.app-subnet-1.id
  vpc_security_group_ids = [aws_security_group.app-sg.id]

  associate_public_ip_address = true
  
  key_name                    = aws_key_pair.ssh_key.key_name

  # user_data = file("entry-script.sh")

  connection {
    type = "ssh"
    host = self.public_ip
    user = "ec2-user"
    private_key = file(var.private_key_location)

  }

  provisioner "file" {
    destination = "/home/ec2-user/entry-script-on-ec2.sh"
    source = "entry-script.sh"
  }

  provisioner "remote-exec" {
    # script = "/home/ec2-user/entry-script-on-ec2.sh"
    inline = [ 
      "chmod +x /home/ec2-user/entry-script-on-ec2.sh",
      "./home/ec2-user/entry-script-on-ec2.sh",
      "export ENV=dev",
      "mkdir newdir"
     ]
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> instance_ip.txt"
  }

  tags = {
    Name : "${var.environment}-app-server-${count.index}"
  }
}

data "aws_ami" "app-ami" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "ssh_key" {
  key_name = "app-server-key"
  public_key = file(var.public_key_location)
}