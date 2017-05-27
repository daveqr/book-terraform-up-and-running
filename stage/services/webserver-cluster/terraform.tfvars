terragrunt = {
  terraform {
    # source = "git::git@github.com:foo/modules.git//app?ref=v0.0.3"
    source = "../../../modules/services/webserver-cluster"

    extra_arguments "custom_vars" {
      commands = [
        "apply",
        "apply-all",
        "plan",
        "plan-all",
        "destroy",
        "destroy-all",
        "import",
        "push",
        "refresh"
      ]

      # This allows us to put common variables (like env) in the root and
      # refer to it via relative paths.
      arguments = [
        "-var-file=${get_tfvars_dir()}/../../common.tfvars",
        "-var-file=terraform.tfvars"
      ]
    }
  }

  # This looks for terraform.tfvars in its parent folders. It uses the first one it finds. Since
  # we store state info in the root, this allows us to DRY state.
  include {
    path = "${find_in_parent_folders()}"
  }
}

ami = "ami-40d28157"
server_text = "New server text"

# Unfortunatlely, Terragrunt doesn't interpolate tfvars file, so we can't use the env variable in common.tfvars.
# Probably the best approach would be to move it to the module, so you'd have something like
#   name = "$ { var.env }- $ { var.cluster_name } "
cluster_name = "stage-webservers-state"
db_remote_state_bucket = "dave-terraform-book-example-7-state"
db_remote_state_key = "stage/datastores/mysql/terraform.tfstate"
enable_autoscaling = false

min_size = 2
max_size=2