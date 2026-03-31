output "lambda_worker_role" {
    description = "output for our lambda_worker"
    value = aws_iam_role.lambda_worker_role.arn
}

output "trigger_lambda_role" {
    description = "output for our trigger lambda"
    value = aws_iam_role.trigger_lambda_role.arn
}
output "lambda_s3_url_generator_role"{
    description = ""
    value = aws_iam_role.lambda_s3_url_generator_role.arn
}