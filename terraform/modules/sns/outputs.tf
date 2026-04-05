output "sns_topic_arn"{
    description = "SNS topic ARN for our lambda worker"
    value = aws_sns_topic.lambda_response.arn
}