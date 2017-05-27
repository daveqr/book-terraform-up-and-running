# This is a template for Terraform state.
#
# Must add
#   terraform {
#     backend "s3" {}
#   }
# to main.tf of subdirectories, which Terragrunt
# will replace with this configuration.
#
# Can't be overridden in subdirectories.
#
terragrunt = {
  
  // NOTE: Lock blocks are not supported by Terragrunt anymore.

  remote_state {
    backend = "s3"
    config {
      profile = "lipscomb"
      region = "us-east-1"
      
      # Terraform stores all variables in its state files in plain text, including
      # passwords, so make sure to encrypt.
      encrypt = true

      # Must be globally unique in AWS. Unfortunately, there's no way to
      # interpolate, so it must be duplicated wherever it's needed.
      bucket = "dave-terraform-book-example-7-state"

      # Will provide a one-to-one mapping of the directory structure to key.
      # Note, Terragrunt interpolates the relative path to scope the key, but
      # the state file names will all be the same.
      key = "${path_relative_to_include()}/terraform.tfstate"

      # Terragrunt creates lock table automatically in DynamoDB. I think
      # it's best to let Terragrunt handle this.
      lock_table = "dave-terraform-book-example-7-lock"
    }
  }

  terraform {
    # Force Terraform to keep trying to acquire a lock for up to 20 minutes
    # if someone else already has the lock. This might be useful as part of
    # an automated script, such as a CI build.
    extra_arguments "retry_lock" {
      commands = [
        "init",
        "apply",
        "refresh",
        "import",
        "plan",
        "taint",
        "untaint"
      ]

      arguments = [
        "-lock-timeout=20m"
      ]
    }
  }
}