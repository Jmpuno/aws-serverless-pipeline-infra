resource "aws_sqs_queue" "sqs_queue_dlq" {
  name = "${var.project_name}-${var.environment}-sqs-queue-dlq"
  tags = {
    QueueRole = "DLQ-Worker"
  }
}



resource "aws_cloudwatch_metric_alarm" "lw_dlq_not_empty" {
  alarm_name          = "${var.project_name}-${var.environment}-sqs-lambda-worker-dlq-not-empty"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "The alarm fires if for 3 consecutive evaluation periods the metric value remains greater than 5"

  alarm_actions = [var.lw_dlq_alarm_notif_arn]

  dimensions = {
    QueueName = aws_sqs_queue.sqs_queue_dlq.name
  }
}



resource "aws_sqs_queue" "lambda_worker_queue" {
  name                       = "${var.project_name}-${var.environment}-lambda-worker-queue"
  message_retention_seconds  = 345600
  receive_wait_time_seconds  = 20
  visibility_timeout_seconds = 300
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.sqs_queue_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    QueueType = "Main"
  }
}