
provider "aws" {
  region  = "ap-south-1"
}

terraform {
  backend "s3" {
      bucket = "vinayworks"
      key    = "build/terraform.tfstate"
      region = "ap-south-1"
  }
}

# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {

  tags    = {
    Name  = "default vpc"
  }
}

# use data source to get a registered amazon linux 2 ami
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


# launch the ec2 instance and install website
resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = "t2.micro"
  subnet_id              = "subnet-022fb114ac07feb3b"
  vpc_security_group_ids = ["sg-0f488d51c8c3be3c7"]
  key_name               = "gotravkeypair"
  user_data              = file("install_websitev2.sh")

  tags = {
    Name = var.ec2_name
  }
}

# print the ec2's public ipv4 address
output "public_ipv4_address" {
  value = aws_instance.ec2_instance.public_ip
}