terragrunt = {
  remote_state {
    backend = "s3"
    config {
      profile = "lipscomb"
      bucket = "dave-terraform-book-example-xx-state"
      key = "${path_relative_to_include()}/terraform.tfstate"
      region = "us-east-1"
      encrypt = true
      lock_table = "dave-terraform-book-example-lock-table"
    }
  }
}
