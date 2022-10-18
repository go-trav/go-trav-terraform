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
  
  owners = ["211544326561"]
}

provider "aws" {
  region  = "ap-south-1"
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  key_name      = "gotravkeypair"
  user_data     = file("install_website.sh")

  tags = {
    Name = var.ec2_name
  }
}

output "public_ipv4_address" {
  value = aws_instance.app_server.public_ip
}
 