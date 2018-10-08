resource "aws_cloudwatch_dashboard" "main" {
   dashboard_name = "ListMeStats"
   dashboard_body = <<EOF
   {
    "widgets": [
        {
            "type": "metric",
            "x": 3,
            "y": 0,
            "width": 21,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Invocations", "FunctionName", "${aws_lambda_function.listme.function_name}", "Resource", "${aws_lambda_function.listme.function_name}", { "period": 86400, "stat": "Sum" } ],
                    [ ".", "Errors", ".", ".", ".", ".", { "period": 86400, "stat": "Sum" } ]
                ],
                "view": "timeSeries",
                "stacked": false,
                "region": "eu-west-1",
                "title": "Slack commands in time",
                "period": 300
            }
        },
        {
            "type": "metric",
            "x": 3,
            "y": 6,
            "width": 21,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Throttles", "FunctionName", "${aws_lambda_function.listme.function_name}", "Resource", "${aws_lambda_function.listme.function_name}", { "period": 60 } ]
                ],
                "view": "timeSeries",
                "stacked": true,
                "region": "eu-west-1",
                "title": "Slack command throttles"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 3,
            "height": 12,
            "properties": {
                "metrics": [
                    [ "AWS/Lambda", "Invocations", "FunctionName", "${aws_lambda_function.listme.function_name}", "Resource", "${aws_lambda_function.listme.function_name}", { "period": 86400, "stat": "Sum" } ]
                ],
                "view": "singleValue",
                "region": "eu-west-1",
                "period": 300,
                "title": "Slack commands"
            }
        }
    ]
}
 EOF
}
