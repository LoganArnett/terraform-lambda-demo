locals {
  handler_objects = jsondecode(file("${path.root}/lambda_config.json"))
  handlers = flatten([
    for obj in local.handler_objects.topLevel : [
      for env in ["dev", "qa", "uat", "ng"] : {
        name = obj.name
        method = obj.method
        path   = obj.path
        authorization = obj.authorization
        env = env
      }
    ]
  ])
  firstChildHandlers = flatten([
    for obj in local.handler_objects.firstChild : [
      for env in ["dev", "qa", "uat", "ng"] : {
        name = obj.name
        method = obj.method
        path   = obj.path
        authorization = obj.authorization
        parent = obj.parent
        pathParameter = obj.pathParameter
        env = env
      }
    ]
  ])
  secondChildHandlers = flatten([
    for obj in local.handler_objects.secondChild : [
      for env in ["dev", "qa", "uat", "ng"] : {
        name = obj.name
        method = obj.method
        path   = obj.path
        authorization = obj.authorization
        parent = obj.parent
        pathParameter = obj.pathParameter
        env = env
      }
    ]
  ])
  thirdChildHandlers = flatten([
    for obj in local.handler_objects.thirdChild : [
      for env in ["dev", "qa", "uat", "ng"] : {
        name = obj.name
        method = obj.method
        path   = obj.path
        authorization = obj.authorization
        parent = obj.parent
        pathParameter = obj.pathParameter
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

variable "lambda_function_arns" {
  description = "The ARN of the Lambda function"
} //value comes from main.tf

variable "lambda_function_child_arns" {
  description = "The ARN of the Lambda function"
} //value comes from main.tf

variable "lambda_function_second_child_arns" {
  description = "The ARN of the Lambda function"
} //value comes from main.tf

variable "lambda_function_third_child_arns" {
  description = "The ARN of the Lambda function"
} //value comes from main.tf


variable "rest_api_stage_name" {
  type        = string
  description = "The name of the API Gateway stage"
  default     = "prod" //add a stage name as per your requirement
}