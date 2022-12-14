# Terraform

![](img/Screenshot%202022-09-08%20at%2013.50.26.png)

## Terraform and Benefits of Terraform

Terraform is HashiCorp's open-source infrastructure as code tool. Orchestration addresses the needs to automate the lifecycle of environments. With infrastructure being codified, modifications of infrastructure are automated and Terraform is used to establish infrastructure across multi-cloud and on-prem data. It is also known for its use of a simple syntax, qualifying it as a prominent automation tool. Using Terraform has several advantages over manually managing your infrastructure:

- Terraform can manage infrastructure on multiple cloud platforms.
- Terraform can be used for on-premises infrastructure
- The human-readable configuration language helps to write infrastructure code quickly.
- Terraform's state allows to track resource changes throughout deployments.
- Terraform can be used to efficiently deploy, release, scale, and monitor infrastructure for multi-tier applications.

## Set-up for Mac

Use commands

`brew tap hashicorp/tap`

`brew install hashicorp/tap/terraform`

Follow link to check installations on other Platforms: https://www.terraform.io/downloads

## Steps

`sudo nano ~/.bashrc`

```
export AWS_ACCESS_KEY_ID="----"
export AWS_SECRET_ACCESS_KEY="----"
```

- Create a file `main.tf`
- Add code to create an instance

```t
# Who is the cloud provider?
# It's aws

provider "aws" {

# Within the cloud which part of world
# We want to use eu-west-1

  region = "provide_your_region"
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
      Name = "name_the_app"
    }
# attach file.pem
  key_name = "name_here"
}

```

Run commands

- `terraform init`

![](img/Screenshot%202022-09-08%20at%2011.40.28.png)

- `terraform plan`
- `terraform apply`
- To terminate instance: `terraform destroy`

## More commands

Main commands:

- init: Prepare your working directory for other commands
- validate: Check whether the configuration is valid
- plan: Show changes required by the current configuration
- apply: Create or update infrastructure
- destroy: Destroy previously-created infrastructure

All other commands:

- console : Try Terraform expressions at an interactive command prompt
- fmt : Reformat your configuration in the standard style
- force-unlock : Release a stuck lock on the current workspace
- get : Install or upgrade remote Terraform modules
- graph : Generate a Graphviz graph of the steps in an operation
- import : Associate existing infrastructure with a Terraform resource
- login : Obtain and save credentials for a remote host
- logout : Remove locally-stored credentials for a remote host
- output : Show output values from your root module
- providers : Show the providers required for this configuration
- refresh : Update the state to match remote systems
- show : Show the current state or a saved plan
- state : Advanced state management
- taint : Mark a resource instance as not fully functional
- test : Experimental support for module integration testing
- untaint : Remove the 'tainted' state from a resource instance
- version : Show the current Terraform version
- workspace : Workspace management

Global options (use these before the subcommand, if any):

- -chdir=DIR: Switch to a different working directory before executing the
  given subcommand.
- -help: Show this help output, or the help for a specified subcommand.
- -version: An alias for the "version" subcommand.

## Create VPC

```t
resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name = var.aws_vpc_name
  }
}
```

## Create internet gateway

```t
resource "aws_internet_gateway" "gw" {
  vpc_id = var.aws_vpc_id

  tags = {
    Name = var.aws_ig_name
  }
}
```

## Create subnet

```t
resource "aws_subnet" "main" {
  vpc_id     = var.aws_vpc_id
  cidr_block = var.vpc_cidr_block_subnet

  tags = {
    Name = var.aws_public_subnet_name
  }
}
```

## Create route table

```t
resource "aws_route_table" "pub_rt" {
  vpc_id = var.aws_vpc_id

  tags = {
    Name = var.aws_route_table_name
  }
}
```

## Attach route tables

```t
resource "aws_route" "r" {
  route_table_id         = var.aws_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.aws_ig_id
}

resource "aws_route_table_association" "a" {
  subnet_id      = var.aws_subnet_id
  route_table_id = var.aws_route_table_id
}
```

## Security Groups

```t
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
```
