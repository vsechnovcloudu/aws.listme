resource "aws_kms_key" "secretmanagement" {
  description             = "Used to encrypt secrets in the vault, master key"
  deletion_window_in_days = 10
  policy                  = "${data.aws_iam_policy_document.accesskms.json}"
}

resource "aws_kms_alias" "secretmanagement" {
  name          = "alias/listme/secrets"
  target_key_id = "${aws_kms_key.secretmanagement.key_id}"
}

resource "aws_secretsmanager_secret" "slacksecret" {
  name = "slack/secretsignature"
}

data "aws_iam_policy_document" "accesskms" {

  statement {
    sid = "Root access"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:root"]
    }
    actions = [
      "kms:*"
    ]
    
    resources = ["*"]
  }
  
  statement {
    sid = "User access"
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.listme_lambda.arn}"]
    }
    actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
    ]
    
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "accesssecrets" {

  statement {
    sid = "1"

    actions = [
      "secretsmanager:GetSecretValue"
    ]
    
    resources = ["${aws_secretsmanager_secret.slacksecret.arn}"]
  }
}

resource "aws_iam_policy" "accesssecrets" {

  name   = "listme-accesssecrets-${terraform.workspace}"
  path   = "/"
  policy = "${data.aws_iam_policy_document.accesssecrets.json}"
  description = "Policy allowing to access secrets in the vault."
}

resource "aws_iam_role_policy_attachment" "accesssecrets" {
    role       = "${aws_iam_role.listme_lambda.name}"
    policy_arn = "${aws_iam_policy.accesssecrets.arn}"
}
