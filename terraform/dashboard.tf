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
                       [ "AWS/Lambda", "Invocations", "FunctionName", "listme-master", "Resource", "listme-master", { "period": 86400 } ],
                       [ ".", "Errors", ".", ".", ".", ".", { "period": 86400 } ]
                   ],
                   "view": "timeSeries",
                   "stacked": false,
                   "region": "eu-west-1",
                   "title": "Slack commands in time"
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
                       [ "AWS/Lambda", "Throttles", "FunctionName", "listme-master", "Resource", "listme-master", { "period": 60 } ]
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
                       [ "AWS/Lambda", "Invocations", "FunctionName", "listme-master", "Resource", "listme-master", { "period": 86400 } ]
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
