output "trigger_lambda_arn" {
    description = "Trigger lambda arn for other services"
    value = aws_lambda_function.trigger_lambda.arn
}

output "trigger_lambda_dlq_arn"{
    description = "Trigger lambda dlq arn for other services"
    value = aws_sqs_queue.trigger_lambda_dlq.arn
}