resource "aws_lambda_function" "listme" {
  depends_on       = ["aws_iam_role.listme_lambda"]
  function_name    = "listme-${terraform.workspace}"
  role             = "${aws_iam_role.listme_lambda.arn}"
  handler          = "index.handler"
  filename         = "listme-${terraform.workspace}.zip"
  //source_code_hash = "${base64sha256(file(sender-${terraform.workspace}.zip))}" // Perhaps to be replaced with s3 key?
  // https://www.terraform.io/docs/providers/aws/guides/serverless-with-aws-lambda-and-api-gateway.html
  runtime          = "nodejs8.10"
  timeout          = "5"
  memory_size      = "1536"

  environment {
    variables = {
      SLACK_TOKEN = "${var.SENDER}"
    }
  }

  tags {
    Environment = "Production"
  }
}
