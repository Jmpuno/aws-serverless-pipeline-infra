variable "allowed_origin" {
  description = "Allowed origin for CORS — localhost for dev, domain for prod"
  type        = string
}

variable "lambda_s3_url_generator_role_arn"{
    description = "ARN for our lambda function role"
    type = string
}

variable "project_name"{
    description = "variable for project name"
    type = string
}


variable "environment"{
    description= "The deployment environment"
    type = string
}


variable "lambda_s3_url_generator_role_arn"{
    description = "IAM role arn for trigger_lambda"
    type = string
}

variable "lambda_s3_url_generator_log_group" {
    description = "Log group for our trigger lambda"
    type = string
}