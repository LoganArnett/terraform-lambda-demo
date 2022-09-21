//using archive_file data source to zip the lambda code:
data "archive_file" "lambda_code" {
  for_each = {
    for inst in local.handlers : "${inst.name}-${inst.env}" => inst
  }
  type        = "zip"
  source_dir  = "${path.root}/../handlers/${each.value.name}"
  output_path = "${path.root}/../${each.value.name}.zip"
}

data "archive_file" "lambda_code_child" {
  for_each = {
    for inst in local.firstChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  type        = "zip"
  source_dir  = "${path.root}/../handlers/${each.value.name}"
  output_path = "${path.root}/../${each.value.name}.zip"
}

data "archive_file" "lambda_code_second_child" {
  for_each = {
    for inst in local.secondChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  type        = "zip"
  source_dir  = "${path.root}/../handlers/${each.value.name}"
  output_path = "${path.root}/../${each.value.name}.zip"
}

data "archive_file" "lambda_code_third_child" {
  for_each = {
    for inst in local.thirdChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
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

resource "aws_s3_object" "lambda_code" {
  for_each = {
    for inst in local.handlers : "${inst.name}-${inst.env}" => inst
  }
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${each.value.name}.zip"
  source = data.archive_file.lambda_code[each.key].output_path
  etag   = filemd5(data.archive_file.lambda_code[each.key].output_path)
}

resource "aws_s3_object" "lambda_code_child" {
  for_each = {
    for inst in local.firstChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${each.value.name}.zip"
  source = data.archive_file.lambda_code_child[each.key].output_path
  etag   = filemd5(data.archive_file.lambda_code_child[each.key].output_path)
}

resource "aws_s3_object" "lambda_code_second_child" {
  for_each = {
    for inst in local.secondChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${each.value.name}.zip"
  source = data.archive_file.lambda_code_second_child[each.key].output_path
  etag   = filemd5(data.archive_file.lambda_code_second_child[each.key].output_path)
}

resource "aws_s3_object" "lambda_code_third_child" {
  for_each = {
    for inst in local.thirdChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${each.value.name}.zip"
  source = data.archive_file.lambda_code_third_child[each.key].output_path
  etag   = filemd5(data.archive_file.lambda_code_third_child[each.key].output_path)
}

resource "aws_lambda_function" "lambda_function" {
  for_each = {
    for inst in local.handlers : "${inst.name}-${inst.env}" => inst
  }
  function_name    = "${each.value.name}-handler-${each.value.env}"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.lambda_code[each.key].key
  runtime          = "nodejs16.x"
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_code[each.key].output_base64sha256
  role             = aws_iam_role.lambda_execution_role[each.key].arn
}

resource "aws_lambda_function" "lambda_function_child" {
  for_each = {
    for inst in local.firstChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  function_name    = "${each.value.name}-handler-${each.value.env}"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.lambda_code_child[each.key].key
  runtime          = "nodejs16.x"
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_code_child[each.key].output_base64sha256
  role             = aws_iam_role.lambda_execution_role_child[each.key].arn
}

resource "aws_lambda_function" "lambda_function_second_child" {
  for_each = {
    for inst in local.secondChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  function_name    = "${each.value.name}-handler-${each.value.env}"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.lambda_code_second_child[each.key].key
  runtime          = "nodejs16.x"
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_code_second_child[each.key].output_base64sha256
  role             = aws_iam_role.lambda_execution_role_second_child[each.key].arn
}

resource "aws_lambda_function" "lambda_function_third_child" {
  for_each = {
    for inst in local.thirdChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  function_name    = "${each.value.name}-handler-${each.value.env}"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.lambda_code_third_child[each.key].key
  runtime          = "nodejs16.x"
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_code_third_child[each.key].output_base64sha256
  role             = aws_iam_role.lambda_execution_role_third_child[each.key].arn
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  for_each = {
    for inst in local.handlers : "${inst.name}-${inst.env}" => inst
  }
  name              = "/aws/lambda/${each.value.name}-handler-${each.value.env}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "lambda_log_group_child" {
  for_each = {
    for inst in local.firstChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  name              = "/aws/lambda/${each.value.name}-handler-${each.value.env}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "lambda_log_group_second_child" {
  for_each = {
    for inst in local.secondChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  name              = "/aws/lambda/${each.value.name}-handler-${each.value.env}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "lambda_log_group_third_child" {
  for_each = {
    for inst in local.thirdChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  name              = "/aws/lambda/${each.value.name}-handler-${each.value.env}"
  retention_in_days = 7
}

resource "aws_iam_role" "lambda_execution_role" {
  for_each = {
    for inst in local.handlers : "${inst.name}-${inst.env}" => inst
  }
  name = "lambda_execution_role_${each.value.name}-handler-${each.value.env}"

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

resource "aws_iam_role" "lambda_execution_role_child" {
  for_each = {
    for inst in local.firstChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  name = "lambda_execution_role_child_${each.value.name}-handler-${each.value.env}"

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

resource "aws_iam_role" "lambda_execution_role_second_child" {
  for_each = {
    for inst in local.secondChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  name = "lambda_execution_role_second_child_${each.value.name}-handler-${each.value.env}"

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

resource "aws_iam_role" "lambda_execution_role_third_child" {
  for_each = {
    for inst in local.thirdChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  name = "lambda_execution_role_third_child_${each.value.name}-handler-${each.value.env}"

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

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  for_each = {
    for inst in local.handlers : "${inst.name}-${inst.env}" => inst
  }
  role       = aws_iam_role.lambda_execution_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_child" {
  for_each = {
    for inst in local.firstChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  role       = aws_iam_role.lambda_execution_role_child[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_second_child" {
  for_each = {
    for inst in local.secondChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  role       = aws_iam_role.lambda_execution_role_second_child[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_policy_third_child" {
  for_each = {
    for inst in local.thirdChildHandlers : "${inst.name}-${inst.env}" => inst
    if length(inst.method) > 0
  }
  role       = aws_iam_role.lambda_execution_role_third_child[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}