# Who is the cloud provider?
# It's aws

provider "aws" {

# Within the cloud which part of world
# We want to use eu-west-1

  region = "eu-west-1"
}

# init and download required packages
# terraform init

# create a block of code to launch ec2-server
# which resources do we like to create

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "eng122_fatema_tf_vpc"
  }
}      

resource "aws_internet_gateway" "gw" {
  vpc_id = "vpc-0d554fa18268fe0c5"

  tags = {
    Name = "eng122_fatema_tf_ig"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = "vpc-0d554fa18268fe0c5"
  cidr_block = "10.0.11.0/24"

  tags = {
    Name = "eng122_fatema_tf_subnet_public"
  }
}

resource "aws_route_table" "pub_rt" {
  vpc_id = "vpc-0d554fa18268fe0c5"

  tags = {
    Name = "eng122_fatema_tf_rt"
  }
}

resource "aws_route" "r" {
  route_table_id         = "rtb-0a9584f14be77b1fb"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "igw-0dc3224d227c61bb2"
}

resource "aws_route_table_association" "a" {
  subnet_id      = "subnet-095afc39d1a261e94"
  route_table_id = "rtb-0a9584f14be77b1fb"
}

resource "aws_instance" "app_instance" {

# using which ami
  ami = "ami-09d1b85ba67d3f51a"

# instance type
  instance_type = "t2.micro"

# do we need it to have public ip
  associate_public_ip_address = true

# how to name your instance
  tags = {
      Name = "eng122_fatema_appfromterraform"
    }
# attach file.pem
  key_name = "eng122_fatema_tf"

# subnet_id
  subnet_id = "subnet-095afc39d1a261e94"

  root_block_device {
    volume_size = 8
  }

}