terraform {
  required_version = "~> 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.74.0"
    }
  }

  backend "s3" {
    workspace_key_prefix = "env"
    key                  = "data.tfstate"
  }
}
