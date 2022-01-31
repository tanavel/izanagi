data "terraform_remote_state" "security" {
  backend   = "s3"
  workspace = terraform.workspace

  config = {
    bucket               = var.backend_s3_bucket_name
    workspace_key_prefix = "env"
    key                  = "security.tfstate"
  }
}

data "terraform_remote_state" "network" {
  backend   = "s3"
  workspace = "prd"

  config = {
    bucket               = var.backend_s3_bucket_name
    workspace_key_prefix = "env"
    key                  = "network.tfstate"
  }
}

data "aws_route53_zone" "this" {
  name = var.hosted_zone_name
}
