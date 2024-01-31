# Lambda function weather_etl
resource "aws_lambda_function" "weather_etl" {
  function_name = "weather_etl"
  runtime       = "python3.8"  # Replace with the runtime of your choice

  # Use archive_file to detect changes in the zip file
  filename         = data.archive_file.weather_etl.output_path
  source_code_hash = data.archive_file.weather_etl.output_base64sha256

  role = aws_iam_role.weather_etl.arn

  environment {
    variables = {
      TRANSFORMED_BUCKET_NAME = aws_s3_bucket.weather_transformed.bucket
    }
  }
}

# IAM Role for weather_etl Lambda function
resource "aws_iam_role" "weather_etl" {
  name = "weather_etl_role"

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
resource "aws_iam_role_policy_attachment" "weather_etl_policy_attachment" {
  role       = aws_iam_role.weather_etl.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

# Lambda function permission to write to weather_transformed S3 bucket
resource "aws_lambda_permission" "s3_write_permission_weather_etl" {
  statement_id  = "AllowS3WriteWeatherETL"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.weather_etl.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.weather_transformed.arn
}

data "archive_file" "weather_etl" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_functions/weather_etl/weather_etl.py"
  output_path = "${path.module}/lambda_function/weather_etl/weather_etl.zip"
}
