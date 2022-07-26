locals {
  handler_objects = jsondecode(file("${path.root}/lambda_config.json"))
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
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store the Lambda function code"
  default     = "terraform-api-gateway-lambda-demo-logan-test-1" // must be unique - change this to something unique
}