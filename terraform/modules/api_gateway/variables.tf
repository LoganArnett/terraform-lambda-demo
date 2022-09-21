locals {
  handlers = jsondecode(file("${path.root}/multi-level-config.json"))
  topLevel = flatten([
    for obj in local.handlers.topLevel : [
      for env in ["dev", "qa", "uat", "ng"] : {
        name = obj.name
        method = obj.method
        path   = obj.path
        authorization = obj.authorization
        hasHandler = obj.hasHandler
        env = env
      }
    ]
  ])
  firstChild = flatten([
    for obj in local.handlers.firstChild : [
      for env in ["dev", "qa", "uat", "ng"] : {
        name = obj.name
        method = obj.method
        path   = obj.path
        authorization = obj.authorization
        parent = obj.parent
        pathParameter = obj.pathParameter
        hasHandler = obj.hasHandler
        env = env
      }
    ]
  ])
  secondChild = flatten([
    for obj in local.handlers.secondChild: [
      for env in ["dev", "qa", "uat", "ng"] : {
        name = obj.name
        method = obj.method
        path   = obj.path
        authorization = obj.authorization
        parent = obj.parent
        pathParameter = obj.pathParameter
        hasHandler = obj.hasHandler
        env = env
      }
    ]
  ])
  thirdChild = flatten([
    for obj in local.handlers.thirdChild: [
      for env in ["dev", "qa", "uat", "ng"] : {
        name = obj.name
        method = obj.method
        path   = obj.path
        authorization = obj.authorization
        parent = obj.parent
        pathParameter = obj.pathParameter
        hasHandler = obj.hasHandler
        env = env
      }
    ]
  ])
}

variable "rest_api_name" {
  type        = string
  description = "Name of the API Gateway created"
  default     = "terraform-api-gateway-example"
}

variable "api_gateway_region" {
  type        = string
  description = "The region in which to create/manage resources"
} //value comes from main.tf

variable "api_gateway_account_id" {
  type        = string
  description = "The account ID in which to create/manage resources"
} //value comes from main.tf

variable "lambda_function_arn_topLevel" {
  description = "The ARN of the Lambda function"
} //value comes from main.tf

variable "lambda_function_arn_firstChild" {
  description = "The ARN of the Lambda function"
} //value comes from main.tf

variable "lambda_function_arn_secondChild" {
  description = "The ARN of the Lambda function"
} //value comes from main.tf

variable "lambda_function_arn_thirdChild" {
  description = "The ARN of the Lambda function"
} //value comes from main.tf


variable "rest_api_stage_name" {
  type        = string
  description = "The name of the API Gateway stage"
  default     = "prod" //add a stage name as per your requirement
}