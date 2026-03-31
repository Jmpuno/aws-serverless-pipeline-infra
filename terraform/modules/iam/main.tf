resource "aws_iam_role" "trigger_lambda_role"{
    name ="${var.project_name}-${var.environment}-trigger-lambda-role"
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

resource "aws_iam_role" "lambda_worker_role"{
    name ="${var.project_name}-${var.environment}-lambda-worker-role"
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

resource "aws_iam_role" "lambda_s3_url_generator_role"{
    name ="${var.project_name}-${var.environment}-lambda-s3-url-generator-role"
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