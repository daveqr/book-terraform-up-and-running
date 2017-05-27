terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  profile = "lipscomb"
  region  = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.remote_state_bucket}"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
