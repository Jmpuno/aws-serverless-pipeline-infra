output "lambda_worker_logs" {
    description = "output for our lambda worker logs "
    value = aws_cloudwatch_log_group.lambda_worker.name
}

output "trigger_lambda_logs" {
    description = "output for our trigger lambda logs"
    value = aws_cloudwatch_log_group.trigger_lambda.name
}