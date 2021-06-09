terraform {
  backend "s3" {
    region               = "ap-northeast-1"
    profile              = "terraform"
    bucket               = "tanavel-tf-state"
    workspace_key_prefix = "data"
    key                  = "terraform.tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "terraform"
  region  = "ap-northeast-1"
}

#================================================#
# RDS
#================================================#
resource "aws_db_instance" "this" {
  # required
  instance_class    = "db.t2.micro"
  allocated_storage = 20
  engine            = "mysql"
  username          = "root"
  password          = "password"
  # optional
  engine_version      = "8.0.20"
  skip_final_snapshot = true
  apply_immediately   = true
  tags = {
    Name = "tanavel-prd-db-1"
    Env  = "prd"
    Sys  = "tanavel"
  }
}
