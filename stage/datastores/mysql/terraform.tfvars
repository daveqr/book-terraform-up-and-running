terragrunt = {
  terraform {
    # Can use relative or Git paths. Note the ref, which allows us to deploy
    # different versions in different environments.
    # source = "git::git@github.com:foo/modules.git//app?ref=v0.0.3"
    source = "../../../modules/datastores/mysql"

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

db_name = "example_db"
db_user_name = "admin"
db_password = "adminpasswordwhichyoudontwanthere"