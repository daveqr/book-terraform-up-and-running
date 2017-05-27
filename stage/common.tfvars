terragrunt = {
  include {
    # This allows us to use remote_state from the parent.
    path = "${find_in_parent_folders()}"
  }
}

env_name = "stage"
