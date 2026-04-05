resource "aws_sns_topic" "lambda_response"{
    name = "${var.project_name}-${var.environment}-lambda-response"
}

resource "aws_sns_topic_subscription" "admin_email"{
    topic_arn = aws_sns_topic.lambda_response.arn
    protocol = "email"
    endpoint = var.admin_email
}

