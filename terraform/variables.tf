variable "project_name"{
    description = "variable for project name"
    type = string
}

variable "environment"{
    description= "The deployment environment"
    type = string
    default = "dev"
}

variable "aws_account_id" {
    description = "variable for our aws account identification"
    type = string
}