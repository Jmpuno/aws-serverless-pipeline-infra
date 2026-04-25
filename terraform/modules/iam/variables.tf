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

variable "bucket_arn"{
    description = "s3 bucket arn for trigger lambda policy"
    type = string
}

