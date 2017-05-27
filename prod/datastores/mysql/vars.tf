variable "env_name" {
  description = "The environment name"
  default     = "prod"
}

variable "db_name" {
  description = "The db name"
  default     = "example_db"
}

variable "db_user_name" {
  description = "The database user name"
  default     = "admin"
}

variable "db_password" {
  # Note: don't normally want to include this in vars! Use an env variable instead.
  description = "Master user password"
  default     = "adminpasswordwhichyoudontwanthere"
}
