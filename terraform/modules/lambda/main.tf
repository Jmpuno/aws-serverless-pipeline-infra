data "archive_file" "lambda_worker"{
    type = "zip"
    source_dir = "${path.module}/../../../src/lambda_worker"
    output_path = "${path.module}/../../../src/builds/lambda_worker.zip"
}

data "archive_file" "trigger_lambda"{
    type = "zip"
    source_dir = "${path.module}/../../../src/trigger_lambda"
    output_path = "${path.module}/../../../src/builds/trigger_lambda.zip"
}

data "archive_file" "reprocessor"{
    type = "zip"
    source_dir = "${path.module}/../../../src/reprocessor"
    output_path = "${path.module}/../../../src/builds/reprocessor.zip"
}






resource "aws_sqs_queue" "trigger_lambda_dlq"{
    name = "${var.project_name}-${var.environment}-trigger-lambda-dlq"

    tags = {
        QueueRole = "DLQ-Trigger"
    }
}


resource "aws_cloudwatch_metric_alarm" "tl_dlq_not_empty"{
    alarm_name = "${var.project_name}-${var.environment}-sqs-trigger-lambda-dlq-not-empty"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 3
    metric_name = "ApproximateNumberOfMessagesVisible"
    namespace = "AWS/SQS"
    period = 60
    statistic = "Sum"
    threshold = 1
    alarm_description = "The alarm fires if for 3 consecutive evaluation periods the metric value remains greater than 5"

    alarm_actions = [var.tl_dlq_alarm_notif_arn]

    dimensions = {
        QueueName = aws_sqs_queue.trigger_lambda_dlq.name
    }
}




resource "aws_lambda_function" "trigger_lambda"{
    filename = data.archive_file.trigger_lambda.output_path
    function_name = "${var.project_name}-${var.environment}-trigger-lambda"
    role = var.trigger_lambda_role_arn
    handler = "trigger_lambda.lambda_handler"
    code_sha256 = data.archive_file.trigger_lambda.output_base64sha256
    runtime = "python3.14"

    dead_letter_config{
        target_arn = aws_sqs_queue.trigger_lambda_dlq.arn
    }

    environment {
        variables = {
            ENVIRONMENT = var.environment
            LOG_LEVEL   = var.log_level
            SQS_QUEUE_URL = var.lambda_worker_queue_url
            BUCKET_NAME   = var.bucket_name
        }
    }

     tags = {
       Function = "trigger"
    }

    logging_config {
    log_format            = "JSON"
    application_log_level = var.log_level
    system_log_level      = "WARN"
    log_group             = var.trigger_lambda_log_group
  }
}


resource "aws_lambda_function" "lambda_worker"{
    filename = data.archive_file.lambda_worker.output_path
    function_name = "${var.project_name}-${var.environment}-lambda-worker"
    role = var.lambda_worker_role_arn
    handler = "lambda_worker.lambda_handler"
    code_sha256 = data.archive_file.lambda_worker.output_base64sha256
    runtime = "python3.14"

   environment{
        variables = {
            ENVIRONMENT = var.environment
            LOG_LEVEL   = var.log_level
            SNS_TOPIC_ARN       = var.sns_topic_arn
            DYNAMODB_TABLE_NAME = var.dynamodb_table_name
            SES_SENDER_EMAIL = var.ses_sender_email
        }
   }

     tags = {
        Function = "worker"
    }


    logging_config {
    log_format            = "JSON"
    application_log_level = var.log_level
    system_log_level      = "WARN"
    log_group             = var.lambda_worker_log_group
  }
}

resource "aws_lambda_event_source_mapping" "lambda_worker_trigger"{
    event_source_arn = var.lambda_worker_queue_arn
    function_name = aws_lambda_function.lambda_worker.arn
    batch_size = 1
    enabled = true
}


resource "aws_lambda_function" "reprocessor"{
    filename = data.archive_file.reprocessor.output_path
    function_name = "${var.project_name}-${var.environment}-reprocessor"
    role =  var.reprocessor_role
    handler = "reprocessor.lambda_handler"
    code_sha256 = data.archive_file.reprocessor.output_base64sha256
    runtime = "python3.14"

    environment {
        variables = {
            ENVIRONMENT = var.environment
            LOG_LEVEL = var.log_level
            MAIN_QUEUE_URL = var.lambda_worker_queue_url
            TL_DLQ_URL  = aws_sqs_queue.trigger_lambda_dlq.url
            LW_DLQ_URL = var.sqs_queue_dlq_url
        }
    }

    tags = {
        Function = "reprocessor"
    }

    logging_config {
        log_format            = "JSON"
        application_log_level = var.log_level
        system_log_level      = "WARN"
        log_group             = var.reprocessor_log_group
    }
}


resource "aws_scheduler_schedule" "reprocessor" {
    name = "dlq-reprocessor-schedule"
    flexible_time_window { mode = "OFF"}
    schedule_expression = "rate(5 minutes)"

    target{
        arn = aws_lambda_function.reprocessor.arn
        role_arn = var.scheduler_role_arn
    }
}