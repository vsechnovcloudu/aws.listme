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
                "stacked": true,
                "region": "${var.REGION}",
                "title": "Slack requests",
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
                    [ "AWS/Lambda", "Duration", "FunctionName", "${aws_lambda_function.listme.function_name}", "Resource", "${aws_lambda_function.listme.function_name}", { "stat": "Minimum", "period": 3600 } ],
                    [ "...", { "stat": "Average", "period": 3600 } ],
                    [ "...", { "stat": "Maximum", "period": 3600 } ]
                ],
                "region": "${var.REGION}",
                "view": "timeSeries",
                "stacked": true,
                "title": "Runtime",
                "period": 300
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
                    [ "AWS/Lambda", "Invocations", "FunctionName", "${aws_lambda_function.listme.function_name}", "Resource", "${aws_lambda_function.listme.function_name}", { "stat": "Sum", "period": 86400 } ]
                ],
                "region": "${var.REGION}",
                "view": "singleValue",
                "stacked": false,
                "period": 300
            }
        }
    ]
}
 EOF
}
