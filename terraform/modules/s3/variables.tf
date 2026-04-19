variable "project_name"{
    description = "project name for our s3 bucket name"
    type = string
}

variable "environment"{
    description= "Environment for our s3 bucket name"
    type = string
}

variable "trigger_lambda_arn" {
    description = "trigger lambda arn for our s3 notification"
    type = string
}