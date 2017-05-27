variable "env_name" {
  description = "The environment name"
  default     = "prod"
}

variable "cluster_name" {
  default = "webservers-state"
}

variable "db_remote_state_bucket" {
  default = "dave-terraform-book-example-7-state"
}

variable "db_remote_state_key" {
  default = "prod/datastores/mysql/terraform.tfstate"
}
