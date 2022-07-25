//using archive_file data source to zip the lambda code:
data "archive_file" "lambda_code" {
  for_each = local.handlers
  type        = "zip"
  source_dir  = "${path.root}/../handlers/${each.key}"
  output_path = "${path.root}/../${each.key}.zip"
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
  for_each = local.handlers
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "${each.key}.zip"
  source = data.archive_file.lambda_code[each.key].output_path
  etag   = filemd5(data.archive_file.lambda_code[each.key].output_path)
}

resource "aws_lambda_function" "lambda_function" {
  for_each = local.handlers
  function_name    = "${each.key}-handler"
  s3_bucket        = aws_s3_bucket.lambda_bucket.id
  s3_key           = aws_s3_object.lambda_code[each.key].key
  runtime          = "nodejs16.x"
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambda_code[each.key].output_base64sha256
  role             = aws_iam_role.lambda_execution_role[each.key].arn
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  for_each = local.handlers
  name              = "/aws/lambda/${each.key}-handler"
  retention_in_days = 7
}

resource "aws_iam_role" "lambda_execution_role" {
  for_each = local.handlers
  name = "lambda_execution_role_${each.key}-handler"

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
  for_each = local.handlers
  role       = aws_iam_role.lambda_execution_role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}