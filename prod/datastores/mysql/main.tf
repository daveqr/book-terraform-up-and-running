terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  profile = "lipscomb"
  region  = "us-east-1"
}

module "mysql_datastore" {
  # This is using a relative module. It's possible to use a Git repository, which
  # is what most people seem to be doing, eg
  #   source  = "github.com/hashicorp/consul/terraform/aws"
  source = "../../../modules/datastores/mysql"

  db_name      = "${var.db_name}"
  db_user_name = "${var.db_user_name}"
  db_password  = "${var.db_password}"
  env_name     = "${var.env_name}"
}
