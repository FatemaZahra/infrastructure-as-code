
resource "aws_subnet" "private" {
  vpc_id     = var.aws_vpc_id
  cidr_block = var.vpc_cidr_block_subnet_private

  tags = {
    Name = var.aws_private_subnet_name
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = var.aws_vpc_id

  tags = {
    Name = var.aws_prvt_route_table_name
  }
}


resource "aws_route_table_association" "db" {
  subnet_id      = var.aws_subnet_id_private
  route_table_id = var.aws_route_table_id_prvt
}

# Security Groups
resource "aws_security_group" "db_group"  {
  name = var.db_security_group_name
  description = "fatema_db_sg_terraform"
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

# allow port 27017

ingress {
    from_port       = "27017"
    to_port         = "27017"
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
    Name = var.db_security_group_name
  }
}

resource "aws_instance" "db_instance" {

# using which ami
  ami = var.ami_id

# instance type
  instance_type = "t2.micro"

# do we need it to have public ip
  associate_public_ip_address = true

# how to name your instance
  tags = {
      Name = var.db_instance_name
    }
# attach file.pem
  key_name = var.key_name

# security group
  vpc_security_group_ids = [var.db_sg_id]

# subnet_id
  subnet_id = var.aws_subnet_id_private

  root_block_device {
    volume_size = 8
  }

}