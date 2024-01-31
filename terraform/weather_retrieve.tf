# Lambda function weather_retrieve
resource "aws_lambda_function" "weather_retrieve" {
  function_name = "weather_retrieve"
  runtime       = "python3.8"  # Replace with the runtime of your choice
  handler       = "handler.lambda_handler"

  # Use archive_file to detect changes in the zip file
  filename         = data.archive_file.weather_retrieve.output_path
  source_code_hash = data.archive_file.weather_retrieve.output_base64sha256

  role = aws_iam_role.weather_retrieve.arn

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.weather_landing.bucket
    }
  }
}

# IAM Role for weather_retrieve Lambda function
resource "aws_iam_role" "weather_retrieve" {
  name = "weather_retrieve_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# IAM Role policy attachment
resource "aws_iam_role_policy_attachment" "weather_retrieve_policy_attachment" {
  role       = aws_iam_role.weather_retrieve.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

# Lambda function permission to write to weather_transformed S3 bucket
resource "aws_lambda_permission" "s3_write_permission_weather_retrieve" {
  statement_id  = "AllowS3WriteWeatherRetrieve"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.weather_retrieve.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.weather_landing.arn
}

data "archive_file" "weather_retrieve" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/weather_retrieve/weather_retrieve.py"
  output_path = "${path.module}/lambda_functions/weather_retrieve/weather_retrieve.zip"
}

