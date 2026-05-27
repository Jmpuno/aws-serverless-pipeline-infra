resource "aws_sns_topic" "lambda_response"{
    name = "${var.project_name}-${var.environment}-lambda-response"
}

resource "aws_sns_topic" "tl_dlq_alarm_notif"{
    name = "${var.project_name}-${var.environment}-tl-dlq-alarm-notif"
}

resource "aws_sns_topic" "lw_dlq_alarm_notif"{
    name = "${var.project_name}-${var.environment}-lw-dlq-alarm-notif"
}

locals {
  topic_to_subscribe = {
    lambda_response    = aws_sns_topic.lambda_response.arn
    tl_dlq_alarm_notif = aws_sns_topic.tl_dlq_alarm_notif.arn
    lw_dlq_alarm_notif = aws_sns_topic.lw_dlq_alarm_notif.arn
  }
}

resource "aws_sns_topic_subscription" "admin_email" {
  for_each = local.topic_to_subscribe

  topic_arn = each.value
  protocol  = "email"
  endpoint  = var.admin_email
}


