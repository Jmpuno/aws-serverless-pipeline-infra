output "lambda_worker" {
    description = "output for our lambda_worker"
    value = aws_iam_role.lambda_worker.arn
}

output "trigger_lambda" {
    description = "output for our trigger lambda"
    value = aws_iam_role.trigger_lambda.arn
}