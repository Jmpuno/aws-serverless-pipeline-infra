output "lambda_worker_queue_arn" {
    description = "ARN for our sqs to send message to lambda worker"
    value = aws_sqs_queue.arn
}