# CloudWatch Event Rule for triggering weather_retrieve
resource "aws_cloudwatch_event_rule" "weather_trigger" {
  name        = "weather_trigger"
  schedule_expression = "cron(0 5 ? * MON-FRI *)"  # Trigger every weekday at 5 AM
} 

# CloudWatch Event Target for weather_retrieve
resource "aws_cloudwatch_event_target" "weather_retrieve_target" {
  rule      = aws_cloudwatch_event_rule.weather_trigger.name
  target_id = "weather_retrieve_target"
  arn       = aws_lambda_function.weather_retrieve.arn
}     

# Lambda function permission to be triggered by CloudWatch Event
resource "aws_lambda_permission" "cloudwatch_event_permission_weather_retrieve" {
  statement_id  = "AllowExecutionFromCloudWatchEventWeatherRetrieve"
  action        = "lambda:InvokeFunction"
  function_name = aws_cloudwatch_event_target.weather_retrieve_target.arn
  principal     = "events.amazonaws.com"
} 

# CloudWatch Event Rule for triggering weather_etl
resource "aws_cloudwatch_event_rule" "weather_etl_trigger" {
  name        = "weather_etl_trigger"
  event_pattern = <<EOF
{
  "source": ["aws.s3"],
  "detail": { 
    "eventName": ["PutObject"]
  },
  "resources": ["${aws_s3_bucket.weather_transformed.arn}"]
}
EOF
}

# CloudWatch Event Target for weather_etl
resource "aws_cloudwatch_event_target" "weather_etl_target" {
  rule      = aws_cloudwatch_event_rule.weather_etl_trigger.name
  target_id = "weather_etl_target"
  arn       = aws_lambda_function.weather_etl.arn
}

# Lambda function permission to be triggered by CloudWatch Event
resource "aws_lambda_permission" "cloudwatch_event_permission_weather_etl" {
  statement_id  = "AllowExecutionFromCloudWatchEventWeatherETL"
  action        = "lambda:InvokeFunction"
  function_name = aws_cloudwatch_event_target.weather_etl_target.arn
  principal     = "events.amazonaws.com"
}

