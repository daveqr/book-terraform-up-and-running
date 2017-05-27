variable "db_name" {
  description = "The database name"
}

variable "db_user_name" {
  description = "The database user name"
}

variable "db_password" {
  # Note: don't normally want to include this in vars! Use an env variable instead.
  description = "Master user password"
}

variable "env_name" {
  description = "The environment name"
}
