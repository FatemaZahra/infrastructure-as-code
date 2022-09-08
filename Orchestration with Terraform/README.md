# Terraform

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
}

```

Run commands

- `terraform init`

![](img/Screenshot%202022-09-08%20at%2011.40.28.png)

- `terraform plan`
- `terraform apply`
- To terminate instance: `terraform destroy`
