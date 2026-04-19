output "trigger_lambda_arn" {
    description = "Trigger lambda arn for other services"
    value = aws_lambda_function.trigger_lambda.arn
}