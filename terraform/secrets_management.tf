resource "aws_kms_key" "secretmanagement" {
  description             = "This key is used to encrypt secrets in the vault"
  deletion_window_in_days = 10
  policy                  = "${data.aws_iam_policy_document.accesskms.rendered}"
}

resource "aws_kms_alias" "secretmanagement" {
  name          = "alias/listme/secrets"
  target_key_id = "${aws_kms_key.secretmanagement.key_id}"
}

resource "aws_secretsmanager_secret" "slacksecret" {
  name = "slack/secretsignature"
}

# data "aws_secretsmanager_secret" "slacksecret" {
#   name = "slack/signisecret"
# }

data "aws_iam_policy_document" "accesskms" {

  statement {
    sid = "1"
    principal = 
    actions = [
      "kms:DescribeKey"
    ]
    
    resources = ["${aws_kms_key.secretmanagement.arn}"]
  }
}

# resource "aws_iam_policy" "accesskms" {
# 
#   name   = "listme-accesskms-${terraform.workspace}"
#   path   = "/"
#   policy = "${data.aws_iam_policy_document.accesskms.json}"
#   description = "Policy allowing to access KMS key for secrets decryption."
# }

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
