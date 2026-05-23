variable "project_name"{
    description = "variable for our project name"
    type = string
}
variable "environment" {
    description = "Deployment environment"
    type = string
}



variable "sqs_queue_arn"{
    description = "sqs queue arn for our trigger lambda to send message"
    type = string
}

variable "sqs_dlq_arn"{
    description = " sqs dlq arn for our trigger lambda to send message if it fails"
    type = string
}

variable "sqs_queue_dlq_arn"{
    description = " sqs dlq arn for lambda reprocessor"
    type = string
}

variable "bucket_arn"{
    description = "s3 bucket arn for trigger lambda policy"
    type = string
}

variable "dynamodb_table_arn"{
    description = "dynamo database table arn for policy"
    type = string
}

variable "admin_email_identity_arn"{
    description = "Ses admin email identity arn for policy"
    type = string
}

variable "sns_topic_arn"{
    description = "SNS topic arn for policy"
    type = string
}

variable "reprocessor_arn"{
    description = "arn of our lambda reprocessor"
    type = string
}
