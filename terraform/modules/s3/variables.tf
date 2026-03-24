variable "project_name"{
    description = "project name for our s3 bucket name"
    type = string
}

variable "environment"{
    description= "Environment for our s3 bucket name"
    type = string
}

variable "aws_account_id" {
    description = "aws account id for our s3 bucket name"
    type = string
}