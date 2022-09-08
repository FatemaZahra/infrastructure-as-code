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

resource "aws_instance" "app_instance" {

# using which ami
  ami = "ami-0b47105e3d7fc023e"

# instance type
  instance_type = "t2.micro"

# do we need it to have public ip
  associate_public_ip_address = true

# how to name your instance
  tags = {
      Name = "eng122_fatema-terraform-app"
    }
# attach file.pem
  key_name = "eng122_fatema"
}      
