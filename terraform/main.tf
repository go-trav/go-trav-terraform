# configured aws provider with proper credentials
terraform {
  required_providers {
    aws = {
      source = "hashicorp/terraform-provider-aws"
      version = "4.34.0"
    }
  }

  required_version = ">=0.14.9"

  backend "s3" {
      bucket = "vinayworks"
      key    = "arn:aws:kms:ap-south-1:211544326561:alias/aws/s3"
      region = "ap-south-1"
  }
}

provider "aws" {
  version = "4.34.0"
  region  = "ap-south-1"
}

resource "aws_s3_bucket" "s3Bucket" {
     bucket = "vinayworks"

     versioning {
       enabled = true
     }
}

# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {

  tags    = {
    Name  = "default vpc"
  }
}


# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


# create default subnet if one does not exit
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]

  tags   = {
    Name = "default subnet"
  }
}


# create security group for the ec2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group"
  description = "allow access on ports 80 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description      = "http access"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp" 
    cidr_blocks      = []
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1 
    cidr_blocks      = ["0.0.0.0/0"] 
  }

  tags   = {
    Name = "ec2 security group"
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
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.ec2_security_group.id]
  key_name               = "gotravkeypair"
  user_data              = file("install_website.sh")

  tags = {
    Name = "gotrav server"
  }
}


# print the ec2's public ipv4 address
output "public_ipv4_address" {
  value = aws_instance.ec2_instance.public_ip
}