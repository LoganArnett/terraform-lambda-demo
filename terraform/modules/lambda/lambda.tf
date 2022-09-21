//using archive_file data source to zip the lambda code:
data "archive_file" "topLevel" {
  for_each = {
    for inst in local.topLevel : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  type        = "zip"
  source_dir  = "${path.root}/../handlers/${each.value.name}"
  output_path = "${path.root}/../${each.value.name}.zip"
}

data "archive_file" "firstChild" {
  for_each = {
    for inst in local.firstChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  type        = "zip"
  source_dir  = "${path.root}/../handlers/${each.value.name}"
  output_path = "${path.root}/../${each.value.name}.zip"
}

data "archive_file" "secondChild" {
  for_each = {
    for inst in local.secondChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  type        = "zip"
  source_dir  = "${path.root}/../handlers/${each.value.name}"
  output_path = "${path.root}/../${each.value.name}.zip"
}

data "archive_file" "thirdChild" {
  for_each = {
    for inst in local.thirdChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  type        = "zip"
  source_dir  = "${path.root}/../handlers/${each.value.name}"
  output_path = "${path.root}/../${each.value.name}.zip"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.s3_bucket_name
}

//making the s3 bucket private as it houses the lambda code:
resource "aws_s3_bucket_acl" "lambda_bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

##S3 Objects Upload
resource "aws_s3_object" "topLevel" {
  for_each = {
    for inst in local.topLevel : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${each.value.name}.zip"
  source = data.archive_file.topLevel[each.key].output_path
  etag   = filemd5(data.archive_file.topLevel[each.key].output_path)
}

resource "aws_s3_object" "firstChild" {
  for_each = {
    for inst in local.firstChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${each.value.name}.zip"
  source = data.archive_file.firstChild[each.key].output_path
  etag   = filemd5(data.archive_file.firstChild[each.key].output_path)
}

resource "aws_s3_object" "secondChild" {
  for_each = {
    for inst in local.secondChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${each.value.name}.zip"
  source = data.archive_file.secondChild[each.key].output_path
  etag   = filemd5(data.archive_file.secondChild[each.key].output_path)
}

resource "aws_s3_object" "thirdChild" {
  for_each = {
    for inst in local.thirdChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${each.value.name}.zip"
  source = data.archive_file.thirdChild[each.key].output_path
  etag   = filemd5(data.archive_file.thirdChild[each.key].output_path)
}

## Lambda Functions
resource "aws_lambda_function" "topLevel" {
  for_each = {
    for inst in local.topLevel : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  function_name    = "${each.value.name}-handler-${each.value.env}"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.topLevel[each.key].key
  runtime          = "nodejs16.x"
  handler          = "index.handler"
  source_code_hash = data.archive_file.topLevel[each.key].output_base64sha256
  role             = aws_iam_role.lambda_execution_role.arn
}

resource "aws_lambda_function" "firstChild" {
  for_each = {
    for inst in local.firstChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  function_name    = "${each.value.name}-handler-${each.value.env}"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.firstChild[each.key].key
  runtime          = "nodejs16.x"
  handler          = "index.handler"
  source_code_hash = data.archive_file.firstChild[each.key].output_base64sha256
  role             = aws_iam_role.lambda_execution_role.arn
}

resource "aws_lambda_function" "secondChild" {
  for_each = {
    for inst in local.secondChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  function_name    = "${each.value.name}-handler-${each.value.env}"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.secondChild[each.key].key
  runtime          = "nodejs16.x"
  handler          = "index.handler"
  source_code_hash = data.archive_file.secondChild[each.key].output_base64sha256
  role             = aws_iam_role.lambda_execution_role.arn
}

resource "aws_lambda_function" "thirdChild" {
  for_each = {
    for inst in local.thirdChild: "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  function_name    = "${each.value.name}-handler-${each.value.env}"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.thirdChild[each.key].key
  runtime          = "nodejs16.x"
  handler          = "index.handler"
  source_code_hash = data.archive_file.thirdChild[each.key].output_base64sha256
  role             = aws_iam_role.lambda_execution_role.arn
}

## Cloud Watch Log groups
resource "aws_cloudwatch_log_group" "topLevel" {
  for_each = {
    for inst in local.topLevel : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  name              = "/aws/lambda/${each.value.name}-handler-${each.value.env}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "firstChild" {
  for_each = {
    for inst in local.firstChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  name              = "/aws/lambda/${each.value.name}-handler-${each.value.env}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "secondChild" {
  for_each = {
    for inst in local.secondChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  name              = "/aws/lambda/${each.value.name}-handler-${each.value.env}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "thirdChild" {
  for_each = {
    for inst in local.thirdChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  name              = "/aws/lambda/${each.value.name}-handler-${each.value.env}"
  retention_in_days = 7
}

## Lambda Execution Role
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role-handler-child-multiple-levels"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

## Lambda IAM Policy
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
