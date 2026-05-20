variable "project_name"{
    description = "variable for project name"
    type = string
}


variable "environment"{
    description= "The deployment environment"
    type = string
}


variable "lw_dlq_alarm_notif_arn"{
    description = "arn for lambda worker dlq alarm sns topic"
    type        = string
}

