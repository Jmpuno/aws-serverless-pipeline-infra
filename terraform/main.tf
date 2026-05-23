terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

   
}

provider "aws" {
  region = "ap-southeast-1"
  default_tags {
        tags = {
          Project     = var.project_name
          Environment = var.environment
        }
      }
}

module "s3"{
  source = "./modules/s3"

  project_name = var.project_name
  environment = var.environment

  #TRIGGER LAMBDA
  trigger_lambda_arn = module.lambda.trigger_lambda_arn
}

module "lambda"{
  source = "./modules/lambda"

  #NAMING CONVENTION
  project_name = var.project_name
  environment = var.environment

  #IAM ROLES
  lambda_worker_role_arn = module.iam.lambda_worker_role
  trigger_lambda_role_arn = module.iam.trigger_lambda_role
  reprocessor_role = module.iam.reprocessor_role
  scheduler_role_arn = module.iam.scheduler_role

  #CLOUD WATCH LOG GROUPS
  lambda_worker_log_group = module.cloudwatch.lambda_worker_logs
  trigger_lambda_log_group = module.cloudwatch.trigger_lambda_logs
  reprocessor_log_group = module.cloudwatch.reprocessor_logs
  log_level = var.log_level

  #SQS 
  lambda_worker_queue_arn = module.sqs.lambda_worker_queue_arn
  lambda_worker_queue_url = module.sqs.lambda_worker_queue_url
  sqs_queue_dlq_url = module.sqs.sqs_queue_dlq_url

  #SNS
  sns_topic_arn = module.sns.sns_topic_arn
  tl_dlq_alarm_notif_arn = module.sns.tl_dlq_alarm_notif_arn

  #SES
  ses_sender_email = var.admin_email

  #DYNAMODB
  dynamodb_table_name = module.dynamodb.dynamodb_table_name

  #S3 
  bucket_name = module.s3.bucket_name
}

module "lambda_frontend"{
  source = "./modules/lambda_frontend"

  project_name = var.project_name
  environment = var.environment
  allowed_origin = var.allowed_origin

  #IAM ROLES
  lambda_s3_url_generator_role_arn = module.iam.lambda_s3_url_generator_role

  #CLOUDWATCH LOG GROUPS
  lambda_s3_url_generator_log_group = module.cloudwatch.lambda_s3_url_generator_logs
  log_level = var.log_level

  #S3 BUCKET name
  bucket_name = module.s3.bucket_name
}

module "iam"{
  source = "./modules/iam"

  project_name = var.project_name
  environment = var.environment


  bucket_arn = module.s3.bucket_arn


  sqs_queue_arn = module.sqs.lambda_worker_queue_arn
  sqs_dlq_arn   = module.lambda.trigger_lambda_dlq_arn
  sqs_queue_dlq_arn = module.sqs.sqs_queue_dlq_arn

  dynamodb_table_arn = module.dynamodb.dynamodb_table_arn

  admin_email_identity_arn = module.ses.admin_email_identity_arn

  sns_topic_arn = module.sns.sns_topic_arn

  reprocessor_arn = module.lambda.reprocessor_arn

}

module "sqs"{
  source = "./modules/sqs"

  project_name = var.project_name
  environment = var.environment

  #SNS
  lw_dlq_alarm_notif_arn = module.sns.lw_dlq_alarm_notif_arn
}

module "sns"{
  source = "./modules/sns"

  project_name = var.project_name
  environment = var.environment
  admin_email = var.admin_email
}

module "ses"{
  source = "./modules/ses"
  admin_email = var.admin_email
}


module "dynamodb"{
  source = "./modules/dynamodb"

  project_name = var.project_name
  environment = var.environment
}

module "cloudwatch"{
  source = "./modules/cloudwatch"

  project_name = var.project_name
  environment = var.environment
}