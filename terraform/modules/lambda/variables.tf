variable "project_name"{
    description = "variable for project name"
    type = string
}


variable "environment"{
    description= "The deployment environment"
    type = string
}


#IAM ROLES FOR LAMBDA FUNCTIONS
variable "lambda_worker_role_arn"{
    description = "IAM role arn for lambda_worker"
    type = string
}

variable "trigger_lambda_role_arn"{
    description = "IAM role arn for trigger_lambda"
    type = string
}


#LOG GROUPS FOR LAMBDA FUNCTIONS
variable "lambda_worker_log_group" {
    description = "Log group for our lambda worker"
    type = string
}

variable "trigger_lambda_log_group" {
    description = "Log group for our trigger lambda"
    type = string
}


#log_level
variable "log_level" {
    description = "log_level for lambda function"
    type = string
    default = "info"
}


#DQL ARN
/*variable "lambda_dlq_arn"{
    description = "DLQ ARN for Lambda Trigger"
    type = string
}*/


#SQS ARN

variable "lambda_worker_queue_arn" {
    description = "SQS arn for lambda worker"
    type = string
}

variable "lambda_worker_queue_url" {
    description = "sqs url for trigger lambda"
    type = string
}

variable "sns_topic_arn" {
    description = "SNS topic ARN for worker lambda notifications"
    type        = string
}

variable "dynamodb_table_name" {
    description = "DynamoDB table name for storing results"
    type        = string
}

variable "bucket_name"{
    description = "s3 bucket name for our lambda"
    type = string
}

variable "ses_sender_email" {
    description = "Verified SES sender email address"
    type        = string
}
