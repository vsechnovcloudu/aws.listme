resource "aws_lambda_function" "listme" {
  depends_on       = ["aws_iam_role.listme_lambda"]
  function_name    = "listme-${terraform.workspace}"
  role             = "${aws_iam_role.listme_lambda.arn}"
  handler          = "index.handler"
  s3_bucket        = "${var.OPS_BUCKET}"
  s3_key           = "listme-${terraform.workspace}.zip"
  source_code_hash = "${timestamp()}" // Enforcing deployment every time.
  runtime          = "nodejs8.10"
  timeout          = "5"
  memory_size      = "1536"

  environment {
    variables = {
      SLACK_SIGNING_SECRET = "${aws_secretsmanager_secret_version.slacksecret.secret.string}"
    }
  }

  tags {
    Environment = "Production"
  }
}

resource "aws_lambda_permission" "allow-apigw" {
  depends_on     = ["aws_api_gateway_method.listmeget"]
  statement_id   = "AllowExecutionFromAPIGW"
  action         = "lambda:InvokeFunction"
  function_name  = "${aws_lambda_function.listme.function_name}"
  principal      = "apigateway.amazonaws.com"
  source_arn     = "arn:aws:execute-api:${var.REGION}:${var.aws_account_id}:${aws_api_gateway_rest_api.listme.id}/*/${aws_api_gateway_method.listmeget.http_method}${aws_api_gateway_resource.listme.path}"
}
