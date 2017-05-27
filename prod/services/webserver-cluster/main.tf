terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  profile = "lipscomb"
  region  = "us-east-1"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  ami         = "ami-40d28157"
  server_text = "New server text"

  cluster_name           = "${var.env_name}-${var.cluster_name}"
  env_name               = "${var.env_name}"
  db_remote_state_bucket = "${var.db_remote_state_bucket}"
  db_remote_state_key    = "${var.db_remote_state_key}"
  enable_autoscaling     = true

  min_size = 2
  max_size = 10
}
