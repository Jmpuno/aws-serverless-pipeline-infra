output "sns_topic_arn"{
    description = "SNS topic ARN for our lambda worker"
    value = aws_sns_topic.lambda_response.arn
}

output "tl_dlq_alarm_notif_arn"{
    description = "SNS topic arn for trigger lambda dlq metric alarm"
    value = aws_sns_topic.tl_dlq_alarm_notif.arn
}

output "lw_dlq_alarm_notif_arn"{
    description = "SNS topic arn for lambda worker dlq metric alarm"
    value = aws_sns_topic.lw_dlq_alarm_notif.arn
}