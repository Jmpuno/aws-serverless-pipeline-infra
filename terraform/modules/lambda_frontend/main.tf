data "archive_file" "lambda_s3_url_generator"{
    type = "zip"
    source_dir = "${path.module}/../../../src/lambda_s3_url_generator"
    output_path = "${path.module}/../../../src/builds/lambda_s3_url_generator.zip"
}

resource "aws_lambda_function_url" "lambda_s3_url"{
  function_name      = "${var.project_name}-${var.environment}-lambda-s3-url"
  authorization_type = "AWS_IAM"

  cors {
    allow_credentials = true
    allow_origins     = var.allowed_origin
    allow_methods     = ["GET,"PUT"]
    allow_headers     = ["date", "keep-alive", "content-type"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }

}


resource "aws_lambda_function" "lambda_s3_url_generator"{
    filename = data.archive_file.lambda_worker.output_path
    function_name = "${var.project_name}-${var.environment}-lambda-s3-url-generator"
    role = var.lambda_s3_url_generator_role_arn
    handler = "lambda_s3_url_generator.lambda_handler"
    code_sha256 = data.archive_file.lambda_s3_url_generator.output_base64sha256
    runtime = "python3.14"

   environment{
        variables = {
            ENVIRONMENT = var.environment
            LOG_LEVEL   = var.log_level
        }
   }

     tags = {
        Function = "url-generator"
    }


    logging_config {
    log_format            = "JSON"
    application_log_level = var.log_level
    system_log_level      = "WARN"
    log_group             = var.lambda_s3_url_generator_log_group
  }
}