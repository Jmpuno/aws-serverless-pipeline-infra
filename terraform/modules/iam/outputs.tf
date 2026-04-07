output "lambda_worker_role" {
    description = "IAM role arn for our lambda_worker"
    value = aws_iam_role.lambda_worker_role.arn
}

output "trigger_lambda_role" {
    description = "IAM role arn for our trigger lambda"
    value = aws_iam_role.trigger_lambda_role.arn
}
output "lambda_s3_url_generator_role"{
    description = "IAM role arn for our s3 url generator"
    value = aws_iam_role.lambda_s3_url_generator_role.arn
}