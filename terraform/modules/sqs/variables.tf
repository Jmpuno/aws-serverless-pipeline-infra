variable "project_name"{
    description = "variable for project name"
    type = string
}


variable "environment"{
    description= "The deployment environment"
    type = string
}


#DQL ARN
variable "sqs_dlq_arn"{
    description = "DLQ ARN for SQS"
    type = string
}