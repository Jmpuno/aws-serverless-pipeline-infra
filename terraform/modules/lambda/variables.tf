variable "project_name"{
    description = "variable for project name"
    type = string
}


variable "environment"{
    description= "The deployment environment"
    type = string
}

variable "lambda_worker_role_arn"{
    description = "IAM role arn for lambda_worker"
    type = string
}

variable "trigger_lambda_role_arn"{
    description = "IAM role arn for trigger_lambda"
    type = string
}