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

resource "aws_sqs_queue" "trigger_lambda_dlq"{
    name = "${var.project_name}-${var.environment}-trigger-lambda-dlq"

    tags = {
        QueueRole = "DLQ-Trigger"
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