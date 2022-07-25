locals {
  handlers = jsondecode(file("${path.root}/lambda_config.json"))
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store the Lambda function code"
  default     = "terraform-api-gateway-lambda-demo-logan-test-1" // must be unique - change this to something unique
}