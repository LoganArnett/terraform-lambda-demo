terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.region
}

module "lambda_functions" {
  source = "./modules/lambda"
}

module "api_gateway" {
  source = "./modules/api_gateway"
  api_gateway_region = var.region
  api_gateway_account_id = var.account_id
  lambda_function_arn_topLevel = module.lambda_functions.lambda_function_arn_topLevel
  lambda_function_arn_firstChild = module.lambda_functions.lambda_function_arn_firstChild
  lambda_function_arn_secondChild = module.lambda_functions.lambda_function_arn_secondChild
  lambda_function_arn_thirdChild = module.lambda_functions.lambda_function_arn_thirdChild

  depends_on = [
    module.lambda_functions
  ]
}