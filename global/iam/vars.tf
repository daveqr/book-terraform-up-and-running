variable "user_names" {
  description = "Create IAM uisers with these names"
  type        = "list"
  default     = ["neo", "trinity", "morpheus"]
}

variable "give_neo_cloudwatch_full_access" {
  description = "If true, neo gets full acccess to CloudWatch"
  default     = true
}
