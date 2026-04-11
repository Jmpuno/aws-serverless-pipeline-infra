data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


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


resource "aws_iam_policy" "lambda_cloudwatch_logs"{
    name = "${var.project_name}-${var.environment}-lambda-logs"

    policy = jsonencode ({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ]
                Resource = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.project_name}-${var.environment}-*:log-stream:*"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "lambda_worker_logs" {
  role       = aws_iam_role.lambda_worker_role.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_logs.arn
}
resource "aws_iam_role_policy_attachment" "trigger_lambda_logs" {
  role       = aws_iam_role.trigger_lambda_role.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_logs.arn
}
resource "aws_iam_role_policy_attachment" "lambda_s3_url_generator_logs" {
  role       = aws_iam_role.lambda_s3_url_generator_role.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_logs.arn
}


