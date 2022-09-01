resource "aws_api_gateway_rest_api" "rest_api" {
  body = "${local.rest_api_spec}"

  name = var.rest_api_name

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  for_each = {
    for inst in local.handlers : "${inst.name}-${inst.env}" => inst
  }
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${each.value.name}-handler-${each.value.env}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.api_gateway_region}:${var.api_gateway_account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${each.value.method}/${each.value.path}}"
}

resource "aws_api_gateway_stage" "rest_api_stage" {
  for_each = toset(["dev", "qa", "uat", "ng"])
  deployment_id = aws_api_gateway_deployment.rest_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = each.value

  variables = merge({ envName: each.value }, {for name in local.list_handler_names : name => var.lambda_function_arns["${name}-handler-${each.value}"].arn})
}