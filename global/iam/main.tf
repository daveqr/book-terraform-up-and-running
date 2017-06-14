terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}

provider "aws" {
  profile = "lipscomb"
  region  = "us-east-1"
}

resource "aws_iam_user" "example" {
  count = "${length(var.user_names)}"
  name  = "${element(var.user_names, count.index)}"
}

# data source which defineds a policy
data "aws_iam_policy_document" "ec2_read_only" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe"]
    resources = ["*"]
  }
}

# create a policy based on a statement data source
resource "aws_iam_policy" "ec2_read_only" {
  name   = "ec2-read-only"
  policy = "${data.aws_iam_policy_document.ec2_read_only.json}"
}

# assigns the ec2_read_only policy to all the users
resource "aws_iam_user_policy_attachment" "ec2_access" {
  count      = "${length(var.user_names)}"
  user       = "${element(aws_iam_user.example.*.name, count.index)}"
  policy_arn = "${aws_iam_policy.ec2_read_only.arn}"
}

data "aws_iam_policy_document" "cloudwatch_read_only" {
  statement {
    effect    = "Allow"
    actions   = ["cloudwatch:Describe*", "cloudwatch:Get*", "cloudwatch:List*"]
    resources = ["*"]
  }
}

# Policy documents are data sources which can be used to construct a JSON template to be
# used by resources which expect JSON, such as the aws_iam_policy. It's easier to create
# a datasource than a JSON representation of the datasource. This is an example of letting
# humans do what they're good at (telling the computer what they want) and letting computers
# do what they're good at (doing what the human has told them to do, ie convert the data
# source into JSON.)
#
# NOTE: This is a data source and therefore doesn't create anything directly on AWS. 
data "aws_iam_policy_document" "cloudwatch_full_access" {
  statement {
    effect    = "Allow"
    actions   = ["cloudwatch:*"]
    resources = ["*"]
  }
}

# IAM policy which allows read-only access to CloudWatch
resource "aws_iam_policy" "cloudwatch_read_only" {
  name = "cloudwatch-read-only"

  # note this is using a data source to create a json policy value
  policy = "${data.aws_iam_policy_document.cloudwatch_read_only.json}"
}

# IAM policy which allows full access to CloudWatch
resource "aws_iam_policy" "cloudwatch_full_access" {
  name   = "cloudwatch-full-access"
  policy = "${data.aws_iam_policy_document.cloudwatch_full_access.json}"
}

resource "aws_iam_user_policy_attachment" "neo_cloudwatch_full_access" {
  # this is an if-statement
  count = "${var.give_neo_cloudwatch_full_access}"

  user       = "${aws_iam_user.example.0.name}"
  policy_arn = "${aws_iam_policy.cloudwatch_full_access.arn}"
}

resource "aws_iam_user_policy_attachment" "neo_cloudwatch_read_only" {
  # this is an if-else statement, inverse behaviour of neo_cloudwatch_full_access
  count = "${1 - var.give_neo_cloudwatch_full_access}"

  user       = "${aws_iam_user.example.0.name}"
  policy_arn = "${aws_iam_policy.cloudwatch_full_access.arn}"
}
