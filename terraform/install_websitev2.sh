#!/bin/bash
sudo su
yum update -y
yum install -y httpd
cd /var/www/html
wget https://github.com/go-trav/go-trav/archive/refs/heads/main.zip
unzip main.zip
cp -r go-trav-main/* /var/www/html/
rm -rf go-trav-main main.zip
systemctl enable httpd 
systemctl start httpd