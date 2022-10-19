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
on:
  push:
    branches: [ "main" ]
resource "aws_s3_bucket" "s3Bucket" {
     bucket = "vinayworks"
     acl       = "public-read"

     policy  = <<EOF
  {
     "id" : "MakePublic",
   "version" : "2012-10-17",
   "statement" : [
      {
         "action" : [
             "s3:GetObject"
          ],
         "effect" : "Allow",
         "resource" : "arn:aws:s3:::vinayworks/*",
         "principal" : "*"
      }
    ]
  }
EOF

   website {
       index_document = "index.html"
   }
}