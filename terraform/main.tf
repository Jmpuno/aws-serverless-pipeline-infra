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
  aws_account_id = var.aws_account_id
}

module "lambda"{
  source = "./modules/lambda"

  #NAMING CONVENTION
  project_name = var.project_name
  environment = var.environment

  #IAM ROLES
  lambda_worker_role_arn = module.iam.lambda_worker_role
  trigger_lambda_role_arn = module.iam.trigger_lambda_role

  #CLOUD WATCH LOG GROUPS
  lambda_worker_log_group = module.cloudwatch.lambda_worker_logs
  trigger_lambda_log_group = module.cloudwatch.trigger_lambda_logs
  log_level = var.log_level

  #SQS 
  lambda_worker_queue_arn = module.sqs.lambda_worker_queue_arn

  #SNS
  sns_topic_arn = module.sns.sns_topic_arn

  #DYNAMODB
  dynamodb_table_name = module.dynamodb.dynamodb_table_name
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
}

module "sqs"{
  source = "./modules/sqs"

  project_name = var.project_name
  environment = var.environment
}

module "sns"{
  source = "./modules/sns"

  project_name = var.project_name
  environment = var.environment
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