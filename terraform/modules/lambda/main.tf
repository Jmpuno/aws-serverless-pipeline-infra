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


resource "aws_lambda_function" "trigger_lambda"{
    filename = data.archive_file.trigger_lambda.output_path
    function_name = "${var.project_name}-${var.environment}-trigger-lambda"
    role = var.trigger_lambda_role_arn
    handler = "trigger_lambda.lambda_handler"
    code_sha256 = data.archive_file.trigger_lambda.output_base64sha256
    runtime = "python3.14"

    environment {
        variables = {
            ENVIRONMENT = var.environment
            LOG_LEVEL   = "info"
        }
    }

     tags = {
        Project = var.project_name
        Environment = var.environment
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
            LOG_LEVEL   = "info"
        }
   }

     tags = {
        Project = var.project_name
        Environment = var.environment
    }
}