// Outputs are like return values from a method

output "asg_name" {
  value = "${aws_autoscaling_group.example.name}"
}

output "elb_dns_name" {
  value = "${aws_elb.example.dns_name}"
}

# Allows users to add custom rules
output "elb_security_group_id" {
  value = "${aws_security_group.elb.id}"
}
