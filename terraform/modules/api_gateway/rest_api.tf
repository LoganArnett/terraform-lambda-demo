resource "aws_api_gateway_rest_api" "rest_api"{
    name = var.rest_api_name
}

resource "aws_api_gateway_resource" "rest_api_resource" {
  for_each = local.handlers
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part = each.value.path
}

resource "aws_api_gateway_method" "rest_api_get_method"{
  for_each = local.handlers
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource[each.key].id
  http_method = each.value.method
  authorization = each.value.authorization
}

resource "aws_api_gateway_integration" "rest_api_get_method_integration" {
  for_each = local.handlers
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.rest_api_resource[each.key].id
  http_method             = aws_api_gateway_method.rest_api_get_method[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_arns["${each.key}-handler"].arn
}

resource "aws_api_gateway_method_response" "rest_api_get_method_response_200" {
  for_each = local.handlers
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource[each.key].id
  http_method = aws_api_gateway_method.rest_api_get_method[each.key].http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "rest_api_get_method_integration_response_200" {
  for_each = local.handlers
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource[each.key].id
  http_method = aws_api_gateway_integration.rest_api_get_method_integration[each.key].http_method
  status_code = aws_api_gateway_method_response.rest_api_get_method_response_200[each.key].status_code
  response_templates = {
    "application/json" = jsonencode({
      body = "Hello from the Hello API!"
    })
  }
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  for_each = local.handlers
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${each.key}-handler"
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.api_gateway_region}:${var.api_gateway_account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.rest_api_get_method[each.key].http_method}${aws_api_gateway_resource.rest_api_resource[each.key].path}"
}

resource "aws_api_gateway_deployment" "rest_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.rest_api_resource["hello"].id,
      aws_api_gateway_method.rest_api_get_method["hello"].id,
      aws_api_gateway_integration.rest_api_get_method_integration["hello"].id,
      aws_api_gateway_resource.rest_api_resource["goodbye"].id,
      aws_api_gateway_method.rest_api_get_method["goodbye"].id,
      aws_api_gateway_integration.rest_api_get_method_integration["goodbye"].id
    ]))
  }
}
resource "aws_api_gateway_stage" "rest_api_stage" {
  deployment_id = aws_api_gateway_deployment.rest_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = var.rest_api_stage_name
}