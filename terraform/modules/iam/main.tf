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

#CLOUDWATCH POLICY
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

resource "aws_iam_role_policy_attachment" "trigger_lambda_logs" {
  role       = aws_iam_role.trigger_lambda_role.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_logs.arn
}

resource "aws_iam_role_policy_attachment" "lambda_worker_logs" {
  role       = aws_iam_role.lambda_worker_role.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_logs.arn
}

resource "aws_iam_role_policy_attachment" "lambda_s3_url_generator_logs" {
  role       = aws_iam_role.lambda_s3_url_generator_role.name
  policy_arn = aws_iam_policy.lambda_cloudwatch_logs.arn
}


#SQS POLICY

resource "aws_iam_policy" "trigger_lambda_sqs"{
    name = "${var.project_name}-${var.environment}-trigger-lambda-sqs"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = ["sqs:SendMessage"]
                Resource = [
                    var.sqs_queue_arn,
                    var.sqs_dlq_arn
                ]
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "trigger_lambda_sqs" {
    role       = aws_iam_role.trigger_lambda_role.name
    policy_arn = aws_iam_policy.trigger_lambda_sqs.arn
}



resource "aws_iam_policy" "lambda_worker_sqs" {
    name = "${var.project_name}-${var.environment}-lambda-worker-sqs"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "sqs:ReceiveMessage",
                    "sqs:DeleteMessage",
                    "sqs:GetQueueAttributes"
                ]
                Resource = var.sqs_queue_arn 
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "lambda_worker_sqs" {
    role       = aws_iam_role.lambda_worker_role.name
    policy_arn = aws_iam_policy.lambda_worker_sqs.arn
}






#LAMBDA POLICY
resource "aws_iam_policy" "trigger_lambda_policy"{
    name = "${var.project_name}-${var.environment}-trigger-lambda-policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = ["s3:GetObject"]
                Resource =  "${var.bucket_arn}/*"
                        
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "trigger_lambda_policy" {
    role       = aws_iam_role.trigger_lambda_role.name
    policy_arn = aws_iam_policy.trigger_lambda_policy.arn
}

resource "aws_iam_policy" "lambda_worker_policy"{
    name = "${var.project_name}-${var.environment}-lambda-worker-policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = ["s3:GetObject"]
                Resource = "${var.bucket_arn}/*"
                        
            },
            {
                Effect = "Allow"
                Action = ["dynamodb:PutItem"]
                Resource = var.dynamodb_table_arn     
            },
            {
                Effect = "Allow"
                Action = ["ses:SendEmail"]
                Resource = "arn:aws:ses:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:identity/*"  
            },
            {
                Effect = "Allow"
                Action = ["SNS:Publish"]
                Resource = var.sns_topic_arn     
            }
            
            

        ]
    })
}

resource "aws_iam_role_policy_attachment" "lambda_worker_policy" {
    role       = aws_iam_role.lambda_worker_role.name
    policy_arn = aws_iam_policy.lambda_worker_policy.arn
}








