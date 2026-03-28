terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"


       default_tags {
        tags = {
          Project     = var.project_name
          Environment = var.environment
        }
      }
    }
  }
}

provider "aws" {
  region = "ap-southeast-1"
}