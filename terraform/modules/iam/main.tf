resource "aws_iam_role" "trigger_lambda"{
    name ="${var.project_name}-${var.environment}-trigger-lambda"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid = ""
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            },
        ]

    })

}

resource "aws_iam_role" "lambda_worker"{
    name ="${var.project_name}-${var.environment}-lambda-worker"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Sid = ""
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            },
        ]

    })

}