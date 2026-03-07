terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.1"
    }
  }

  # Backend configuration supports both local and S3
  # For LocalStack: use local backend in terraform.tfvars
  # For AWS: configure s3 backend in terraform.tfvars
}

provider "aws" {
  region = var.aws_region

  # LocalStack-specific configuration
  skip_credentials_validation = var.use_localstack
  skip_metadata_api_check     = var.use_localstack
  skip_region_validation      = var.use_localstack
  skip_requesting_account_id  = var.use_localstack

  dynamic "endpoints" {
    for_each = var.use_localstack ? [1] : []
    content {
      apigateway   = var.localstack_endpoint
      apigatewayv2 = var.localstack_endpoint
      cognito_idp  = var.localstack_endpoint
      lambda       = var.localstack_endpoint
      iam          = var.localstack_endpoint
    }
  }
}
