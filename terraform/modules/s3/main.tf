data "aws_caller_identity" "current" {}


resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = var.trigger_lambda_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.file_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.file_bucket.id

  lambda_function {
    lambda_function_arn = var.trigger_lambda_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}


resource "aws_s3_bucket" "file_bucket" {
    bucket = "${var.project_name}-${var.environment}-file-bucket-${data.aws_caller_identity.current.account_id}"

    tags = {
        dataClassification = "confidential"
    }


}

resource "aws_s3_bucket_cors_configuration" "file_bucket_cors" {
  bucket = aws_s3_bucket.file_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST", "HEAD"]
    allowed_origins = ["https://aws-severless-pipeline-file-uploader.netlify.app"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}