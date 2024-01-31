# Create weather_landing S3 bucket
resource "aws_s3_bucket" "weather_landing" {
  bucket = "weather_landing"
  acl    = "private"
  
  versioning {
    enabled = true
  }
}
  
# Create weather_transformed S3 bucket
resource "aws_s3_bucket" "weather_transformed" {
  bucket = "weather_transformed"
  acl    = "private"

  versioning {
    enabled = true
  }
} 

