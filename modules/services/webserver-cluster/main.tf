terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  profile = "lipscomb"
  region  = "us-east-1"
}

# Can set debug level in environment.
# export TF_LOG=TRACE
# unset TF_LOG
# terragrunt plan 2>log.txt

data "aws_availability_zones" "all" {}

# read-only data
data "terraform_remote_state" "db" {
  backend = "s3"

  # this is the db state config, which seems redundant, but that's
  # how it works 
  config {
    bucket  = "${var.db_remote_state_bucket}"
    key     = "${var.db_remote_state_key}"
    profile = "lipscomb"
    region  = "us-east-1"
  }
}

# renders the user-data.sh script as a template for the instance
data "template_file" "user_data" {
  # because this is in a module, need to use a module-relative path for user-data.sh location
  template = "${file("${path.module}/user-data.sh")}"

  vars {
    server_port = "${var.server_port}"
    db_address  = "${data.terraform_remote_state.db.address}"
    db_port     = "${data.terraform_remote_state.db.port}"
    server_text = "${var.server_text}"
  }
}

resource "aws_elb" "example" {
  name = "${var.cluster_name}"

  availability_zones = [
    "${data.aws_availability_zones.all.names}",
  ]

  security_groups = [
    "${aws_security_group.elb.id}",
  ]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }

  lifecycle {
    # When Terraform tries to replace this, it will create the replacement first
    create_before_destroy = true
  }
}

resource "aws_security_group" "elb" {
  # name_prefix is prefixed to the auto-generated name. This makes it easy to distinguish staging vs prod, for
  # example. However, for greater control, can use "name"
  #   name = "${var.name}" 
  name_prefix = "${var.env_name}"

  lifecycle {
    # When Terraform tries to replace this, it will create the replacement first
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_http_inbound" {
  # Who can access this resource. Having a CIDR or  "0.0.0.0/0" means any address can access.
  type              = "ingress"
  security_group_id = "${aws_security_group.elb.id}"

  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = "${aws_security_group.elb.id}"

  from_port = 0
  to_port   = 0
  protocol  = "-1"

  cidr_blocks = ["0.0.0.0/0"]
}

# Configured for zero-downtime deployment (see comments)
resource "aws_autoscaling_group" "example" {
  # the name depends on the launch config, so that when the launch config changes, Terraform
  # will try to replace this ASG
  name = "${var.cluster_name}-${aws_launch_configuration.example.name}"

  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]
  load_balancers       = ["${aws_elb.example.name}"]
  health_check_type    = "ELB"

  min_size = "${var.min_size}"
  max_size = "${var.max_size}"

  # Terraform will wait for at least this many servers to register before it starts destroying the ASG
  min_elb_capacity = "${var.min_size}"

  lifecycle {
    # When Terraform tries to replace this, it will create the replacement first
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "example" {
  image_id      = "ami-40d28157"
  instance_type = "t2.micro"
  name_prefix   = "${var.env_name}"

  security_groups = [
    "${aws_security_group.instance.id}",
  ]

  # read from the user_data data source
  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "instance" {
  name_prefix = "${var.env_name}"

  ingress {
    from_port = "${var.server_port}"
    to_port   = "${var.server_port}"
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  # enable_autoscaling is a boolean; if it is set, count will be 1
  count = "${var.enable_autoscaling}"

  scheduled_action_name = "scale-out-during-business-hours"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 10
  recurrence            = "0 9 * * *"

  autoscaling_group_name = "${aws_autoscaling_group.example.name}"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  # enable_autoscaling is a boolean; if it is set, count will be 1
  count = "${var.enable_autoscaling}"

  scheduled_action_name = "scale-in-at-night"
  min_size              = 2
  max_size              = 10
  desired_capacity      = 2
  recurrence            = "0 17 * * *"

  autoscaling_group_name = "${aws_autoscaling_group.example.name}"
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name  = "${var.cluster_name}-high-cpu-utilization"
  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.example.name}"
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Average"
  threshold           = 90
  unit                = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_credit_balance" {
  # uses a ternary operator to determine whether this should be created or not
  count = "${format("%.1s", var.instance_type) == "t" ? 1 : 0}"

  alarm_name  = "${var.cluster_name}-low-cpu-credit-balance"
  namespace   = "AWS/EC2"
  metric_name = "CPUCreditBalance"

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.example.name}"
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  period              = 300
  statistic           = "Minimum"
  threshold           = 10
  unit                = "Count"
}
