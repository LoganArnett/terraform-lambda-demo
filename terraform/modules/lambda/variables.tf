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

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store the Lambda function code"
  default     = "terraform-api-gateway-lambda-demo-ek" // must be unique - change this to something unique
}