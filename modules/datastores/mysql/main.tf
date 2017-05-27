terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  profile = "lipscomb"
  region  = "us-east-1"
}

resource "aws_db_instance" "example" {
  engine            = "mysql"
  allocated_storage = 10
  instance_class    = "db.t2.micro"
  name              = "${var.db_name}"

  # Terraform doesn't interpolate variables for identifier and identifier_prefix
  # identifier = "${var.db_name}" <-- won't work
  identifier_prefix = "${var.env_name}"

  username = "${var.db_user_name}"
  password = "${var.db_password}"

  # In this project we don't take a final snapshot, but Terraform takes a final snapshot by default. 
  # This would be the name of the final snapshot if we were to take it.
  # Commented because Terraform recognizes this as a change even though we are skipping the final snapshot.
  # final_snapshot_identifier = "${var.env_name}-final-snapshot-${md5(timestamp())}"

  # This is false by default. Skipping because this is an example project.
  skip_final_snapshot = true
}
