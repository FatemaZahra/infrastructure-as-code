# Who is the cloud provider?
# It's aws

provider "aws" {

# Within the cloud which part of world
# We want to use eu-west-1

  region = var.aws_region
}

# init and download required packages
# terraform init

# create a block of code to launch ec2-server
# which resources do we like to create

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = var.aws_vpc_name
  }
}      

resource "aws_internet_gateway" "gw" {
  vpc_id = var.aws_vpc_id

  tags = {
    Name = var.aws_ig_name
  }
}
resource "aws_subnet" "main" {
  vpc_id     = var.aws_vpc_id
  cidr_block = var.vpc_cidr_block_subnet

  tags = {
    Name = var.aws_public_subnet_name
  }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = var.aws_vpc_id

  tags = {
    Name = var.aws_route_table_name
  }
}

resource "aws_route" "r" {
  route_table_id         = var.aws_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.aws_ig_id
}

resource "aws_route_table_association" "a" {
  subnet_id      = var.aws_subnet_id
  route_table_id = var.aws_route_table_id
}

# Security Groups
resource "aws_security_group" "app_group"  {
  name = var.security_group_name
  description = "fatema_app_sg_terraform"
  vpc_id = var.aws_vpc_id 

# Inbound rules
  ingress {
    from_port       = "80"
    to_port         = "80"
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]   
  }

# ssh access 
  ingress {
    from_port       = "22"
    to_port         = "22"
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]  
  }

# allow port 3000

ingress {
    from_port       = "3000"
    to_port         = "3000"
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]  
  }

# Outbound rules
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1" # allow all
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}

resource "aws_instance" "app_instance" {

# using which ami
  ami = var.ami_id

# instance type
  instance_type = "t2.micro"

# do we need it to have public ip
  associate_public_ip_address = true

# how to name your instance
  tags = {
      Name = var.instance_name
    }
# attach file.pem
  key_name = var.key_name

# security group
  vpc_security_group_ids = [var.sg_id]

# subnet_id
  subnet_id = var.aws_subnet_id

  root_block_device {
    volume_size = 8
  }

}