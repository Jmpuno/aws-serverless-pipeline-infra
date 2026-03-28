output "lambda_worker_queue_arn" {
    description = "ARN for our sqs to send message to lambda worker"
    value = aws_sqs_queue.lambda_worker_queue.arn
}

output "sqs_queue_dlq_arn"{
    description = "ARN for our sqs dlq to send retried message to lambda worker"
    value = aws_sqs_queue.sqs_queue_dlq.arn
}

output "lambda_worker_queue_url"{
    description = "URL of main sqs queue for lambda trigger"
    value = aws_sqs_queue.lambda_worker_queue.url
}