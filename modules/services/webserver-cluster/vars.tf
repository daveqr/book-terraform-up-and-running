// Vars are the API of a module

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 8080
}

variable "env_name" {
  description = "The environment name"
}

variable "cluster_name" {
  description = "The name to use for all the cluster resources"
}

variable "db_remote_state_bucket" {
  description = "The name of the S3 bucket for the database's remote state"
}

variable "db_remote_state_key" {
  description = "The path for the database's remote state in S3"
}

variable "enable_autoscaling" {
  description = "If set to true, enable auto scaling"
}

variable "instance_type" {
  description = "The instance type"
  default     = "t"
}

variable "ami" {
  description = "The AMI to run in the cluster"
  default     = "ami-40d28157"
}

variable "server_text" {
  description = "The text the web server should return"
  default     = "Hello, World"
}

variable "min_size" {
  default = 2
}

variable "max_size" {
  default = 10
}
