resource "aws_sns_topic" "lambda_response"{
    name = "${var.project_name}-${var.environment}-lambda-response"
}

resource "aws_sns_topic" "tl_dlq_alarm_notif"{
    name = "${var.project_name}-${var.environment}-tl-dlq-alarm-notif"
}

resource "aws_sns_topic" "lw_dlq_alarm_notif"{
    name = "${var.project_name}-${var.environment}-lw-dlq-alarm-notif"
}

resource "aws_sns_topic_subscription" "admin_email"{
    topic_arn = aws_sns_topic.lambda_response.arn
    protocol = "email"
    endpoint = var.admin_email
}



