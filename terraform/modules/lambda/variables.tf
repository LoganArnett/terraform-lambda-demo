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
        env = env
      }
    ]
  ])
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store the Lambda function code"
  default     = "terraform-api-gateway-lambda-demo-ek" // must be unique - change this to something unique
}