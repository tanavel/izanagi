provider "aws" {
  default_tags {
    tags = {
      Env       = terraform.workspace
      Sys       = var.sys
      Component = "data"
    }
  }
}
