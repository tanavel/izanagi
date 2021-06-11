terraform {
  backend "s3" {
    region               = "ap-northeast-1"
    profile              = "terraform"
    bucket               = "tanavel-tf-state"
    workspace_key_prefix = "network"
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
