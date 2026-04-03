output "lambda_s3_url"{
    description = "lambda_url for presigned s3 url"
    value = aws_lambda_function_url.lambda_s3_url.function_url
}