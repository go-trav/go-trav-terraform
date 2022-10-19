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