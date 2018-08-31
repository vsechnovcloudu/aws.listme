resource "aws_kms_key" "secretmanagement" {
  description             = "This key is used to encrypt secrets"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "secretmanagement" {
  name          = "alias/listme/secrets"
  target_key_id = "${aws_kms_key.secretmanagement.key_id}"
}

data "aws_secretsmanager_secret" "slacksecret" {
  name = "slack/signisecret"
}
