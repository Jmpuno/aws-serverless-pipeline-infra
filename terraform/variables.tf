variable "project_name"{
    description = "variable for project name"
    type = string
}

variable "environment"{
    description= "The deployment environment"
    type = string
    default = "dev"
}



variable "allowed_origin" {
  description = "Allowed origin for CORS"
  type        = string
}

variable "admin_email"{
    description = "Email address of the admin"
    type = string
}


variable "log_level" {
    description = "log_level for lambda function"
    type = string
    default = "info"
}