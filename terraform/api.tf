resource "aws_api_gateway_rest_api" "listme" {
  depends_on  = ["aws_lambda_function.listme"]
  name        = "ListMeAPI-${terraform.workspace}"
  description = "API for Slack slash command - ListMe."
}

resource "aws_api_gateway_resource" "listme" {
  depends_on  = ["aws_api_gateway_rest_api.listme"]
  rest_api_id = "${aws_api_gateway_rest_api.listme.id}"
  parent_id   = "${aws_api_gateway_rest_api.listme.root_resource_id}"
  path_part   = "listme"
}

resource "aws_api_gateway_method" "listmeget" {
  depends_on    = ["aws_api_gateway_rest_api.listme"]
  rest_api_id   = "${aws_api_gateway_rest_api.listme.id}"
  resource_id   = "${aws_api_gateway_resource.listme.id}"
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "listmeget" {
  depends_on  = ["aws_api_gateway_method.listmeget"]
  rest_api_id = "${aws_api_gateway_rest_api.listme.id}"
  resource_id = "${aws_api_gateway_resource.listme.id}"
  http_method = "${aws_api_gateway_method.listmeget.http_method}"
  status_code = "200"
  response_models {
    "application/json" = "Empty"
  }
  response_parameters {
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration" "listmeget" {
  depends_on              = ["aws_api_gateway_method.listmeget"]
  rest_api_id             = "${aws_api_gateway_rest_api.listme.id}"
  resource_id             = "${aws_api_gateway_resource.listme.id}"
  http_method             = "${aws_api_gateway_method.listmeget.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${var.REGION}:lambda:path/2015-03-31/functions/${aws_lambda_function.listme.arn}/invocations"
}

resource "aws_api_gateway_integration_response" "listmeget" {
  depends_on  = ["aws_api_gateway_method_response.listmeget"]
  rest_api_id = "${aws_api_gateway_rest_api.listme.id}"
  resource_id = "${aws_api_gateway_resource.listme.id}"
  http_method = "${aws_api_gateway_method.listmeget.http_method}"
  status_code = "${aws_api_gateway_method_response.listmeget.status_code}"

  response_templates {
    "application/json" = ""
  }

  response_parameters {
    "method.response.header.Access-Control-Allow-Origin" = "'${var.ORIGIN}'"
  }
}

resource "aws_api_gateway_method" "cors-listme" {
  rest_api_id = "${aws_api_gateway_rest_api.listme.id}"
  resource_id = "${aws_api_gateway_resource.listme.id}"
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors-listme" {
  rest_api_id = "${aws_api_gateway_rest_api.listme.id}"
  resource_id = "${aws_api_gateway_resource.listme.id}"
  http_method = "${aws_api_gateway_method.cors-listme.http_method}"
  type = "MOCK"
  request_templates {
      "application/json" = <<EOF
        {
        "statusCode" : 200
        }
        EOF
  }
}

resource "aws_api_gateway_integration_response" "cors-listme" {
  depends_on  = ["aws_api_gateway_integration.cors-listme"]
  rest_api_id = "${aws_api_gateway_rest_api.listme.id}"
  resource_id = "${aws_api_gateway_resource.listme.id}"
  http_method = "${aws_api_gateway_method.cors-listme.http_method}"
  status_code = "${aws_api_gateway_method_response.cors-listme.status_code}"
  response_parameters {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.ORIGIN}'"
  }
}

resource "aws_api_gateway_method_response" "cors-listme" {
  depends_on  = ["aws_api_gateway_method.cors-listme"]
  rest_api_id = "${aws_api_gateway_rest_api.listme.id}"
  resource_id = "${aws_api_gateway_resource.listme.id}"
  http_method = "${aws_api_gateway_method.cors-listme.http_method}"
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
  response_parameters {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_deployment" "listme" {
  depends_on = ["aws_api_gateway_integration.listmeget"]
  rest_api_id = "${aws_api_gateway_rest_api.listme.id}"
  stage_name = "${var.APISTAGE}"
  stage_description = "Latest"
  stage_description = "Deployed at ${timestamp()}"
  lifecycle {
    create_before_destroy = true
  }
}
