resource "aws_cloudwatch_log_group" "trigger_lambda"{
    name = "/aws/lambda/${var.project_name}-${var.environment}-trigger-lambda"

    retention_in_days = 30

    tags = {
        Project = var.project_name
        Environment = var.environment
    }
}

resource "aws_cloudwatch_log_group" "lambda_worker"{
    name = "/aws/lambda/${var.project_name}-${var.environment}-lambda-worker"

    retention_in_days = 30
}