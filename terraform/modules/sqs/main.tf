resource "aws_sqs_queue" "sqs_queue_dlq"{
    name = "${var.project_name}-${var.environment}-sqs-queue-dql"
}



resource "aws_sqs_queue" "lambda_worker_queue"{
    name = "${var.project_name}-${var.environment}-lambda-worker-queue"
    message_retention_seconds = 345600
    receive_wait_time_seconds = 20
    visibility_timeout_seconds = 300
    redrive_policy = jsonencode({
        deadLetterTargetArn  = var.sqs_dlq_arn
        maxReceiveCount = 3
    })

    tags = {
        Environment = var.environment
    }
}