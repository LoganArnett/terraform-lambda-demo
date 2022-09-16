locals {
  handler_objects = jsondecode(file("${path.root}/lambda_config.json"))
  child_handler_objects = jsondecode(file("${path.root}/lambda_child_config.json"))
  handlers = flatten([
    for obj in local.handler_objects : [
      for env in ["dev", "qa", "uat", "ng"] : {
        name = obj.name
        method = obj.method
        path   = obj.path
        authorization = obj.authorization
        env = env
      }
    ]
  ])
  childHandlers = flatten([
    for obj in local.child_handler_objects : [
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

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store the Lambda function code"
  default     = "terraform-api-gateway-lambda-demo-ek" // must be unique - change this to something unique
}