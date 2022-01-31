data "terraform_remote_state" "network" {
  backend   = "s3"
  workspace = terraform.workspace

  config = {
    bucket               = var.backend_s3_bucket_name
    workspace_key_prefix = "env"
    key                  = "network.tfstate"
  }
}
