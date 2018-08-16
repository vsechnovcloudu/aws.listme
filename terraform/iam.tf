data "aws_iam_policy_document" "allow-listing" {

  statement {
    sid = "1"

    actions = [
      "ec2:Describe*"
    ]
    
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "listme-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "listme_lambda" {
  depends_on = ["data.aws_iam_policy_document.listme-assume-role-policy"]
  name = "listme-${terraform.workspace}"
  assume_role_policy = "${data.aws_iam_policy_document.listme-assume-role-policy.json}"
  description = "Role allowing Lambda describe EC2 resources."
}

resource "aws_iam_policy" "listme_lambda" {
  name   = "listme-${terraform.workspace}"
  path   = "/"
  policy = "${data.aws_iam_policy_document.allow-listing.json}"
  description = "Policy allowing to describe EC2 resources."
}

resource "aws_iam_role_policy_attachment" "sender" {
  depends_on = ["aws_iam_role.listme_lambda"]
  role       = "${aws_iam_role.listme_lambda.name}"
  policy_arn = "${aws_iam_policy.listme_lambda.arn}"
}
