resource "aws_sns_topic" "email_notification"{
    name = "lambda-worker-completion-topic"
}

resource "aws_sns__publish" "publish_