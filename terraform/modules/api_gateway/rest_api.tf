resource "aws_api_gateway_rest_api" "rest_api"{
    name = var.rest_api_name
}

resource "aws_api_gateway_resource" "rest_api_resource" {
  for_each = {
    for inst in local.handlers : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part = each.value.path
}

resource "aws_api_gateway_resource" "rest_api_resource_child" {
  for_each = {
    for inst in local.childHandlers : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id = aws_api_gateway_resource.rest_api_resource["${each.value.parent}-${each.value.env}"].id
  path_part = each.value.path
}

resource "aws_api_gateway_method" "rest_api_get_method"{
  for_each = {
    for inst in local.handlers : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource["${each.value.name}-${each.value.env}"].id
  http_method = each.value.method
  authorization = each.value.authorization
}

resource "aws_api_gateway_method" "rest_api_get_method_child"{
  for_each = {
    for inst in local.childHandlers : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource_child["${each.value.name}-${each.value.env}"].id
  http_method = each.value.method
  authorization = each.value.authorization
  request_parameters = length(each.value.pathParameter) > 0 ? {
    "method.request.path.${each.value.pathParameter}" = true
  } : {}
}

resource "aws_api_gateway_integration" "rest_api_get_method_integration" {
  for_each = {
    for inst in local.handlers : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.rest_api_resource["${each.value.name}-${each.value.env}"].id
  http_method             = aws_api_gateway_method.rest_api_get_method["${each.value.name}-${each.value.env}"].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_arns["${each.value.name}-handler-${each.value.env}"].arn
}

resource "aws_api_gateway_integration" "rest_api_get_method_integration_child" {
  for_each = {
    for inst in local.childHandlers : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.rest_api_resource_child["${each.value.name}-${each.value.env}"].id
  http_method             = aws_api_gateway_method.rest_api_get_method_child["${each.value.name}-${each.value.env}"].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_child_arns["${each.value.name}-handler-${each.value.env}"].arn
}

resource "aws_api_gateway_method_response" "rest_api_get_method_response_200" {
  for_each = {
    for inst in local.handlers : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource["${each.value.name}-${each.value.env}"].id
  http_method = aws_api_gateway_method.rest_api_get_method["${each.value.name}-${each.value.env}"].http_method
  status_code = "200"
}

resource "aws_api_gateway_method_response" "rest_api_get_method_response_200_child" {
  for_each = {
    for inst in local.childHandlers : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource_child["${each.value.name}-${each.value.env}"].id
  http_method = aws_api_gateway_method.rest_api_get_method_child["${each.value.name}-${each.value.env}"].http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "rest_api_get_method_integration_response_200" {
  for_each = {
    for inst in local.handlers : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource["${each.value.name}-${each.value.env}"].id
  http_method = aws_api_gateway_integration.rest_api_get_method_integration["${each.value.name}-${each.value.env}"].http_method
  status_code = aws_api_gateway_method_response.rest_api_get_method_response_200["${each.value.name}-${each.value.env}"].status_code
  response_templates = {
    "application/json" = jsonencode({
      body = "Hello from the Hello API!"
    })
  }
}

resource "aws_api_gateway_integration_response" "rest_api_get_method_integration_response_200_child" {
  for_each = {
    for inst in local.childHandlers : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  resource_id = aws_api_gateway_resource.rest_api_resource_child["${each.value.name}-${each.value.env}"].id
  http_method = aws_api_gateway_integration.rest_api_get_method_integration_child["${each.value.name}-${each.value.env}"].http_method
  status_code = aws_api_gateway_method_response.rest_api_get_method_response_200_child["${each.value.name}-${each.value.env}"].status_code
  response_templates = {
    "application/json" = jsonencode({
      body = "Hello from the Hello API!"
    })
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
  source_arn = "arn:aws:execute-api:${var.api_gateway_region}:${var.api_gateway_account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.rest_api_get_method["${each.value.name}-${each.value.env}"].http_method}${aws_api_gateway_resource.rest_api_resource["${each.value.name}-${each.value.env}"].path}"
}

resource "aws_lambda_permission" "api_gateway_lambda_child" {
  for_each = {
    for inst in local.childHandlers : "${inst.name}-${inst.env}" => inst
  }
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${each.value.name}-handler-${each.value.env}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.api_gateway_region}:${var.api_gateway_account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.rest_api_get_method_child["${each.value.name}-${each.value.env}"].http_method}${aws_api_gateway_resource.rest_api_resource_child["${each.value.name}-${each.value.env}"].path}"
}

resource "aws_api_gateway_deployment" "rest_api_deployment" {
  for_each = toset(["dev", "qa", "uat", "ng"])
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.rest_api_resource["hello-dev"].id,
      aws_api_gateway_method.rest_api_get_method["hello-dev"].id,
      aws_api_gateway_integration.rest_api_get_method_integration["hello-dev"].id,
      aws_api_gateway_resource.rest_api_resource["goodbye-dev"].id,
      aws_api_gateway_method.rest_api_get_method["goodbye-dev"].id,
      aws_api_gateway_integration.rest_api_get_method_integration["goodbye-dev"].id
    ]))
  }
}
resource "aws_api_gateway_stage" "rest_api_stage" {
  for_each = toset(["dev", "qa", "uat", "ng"])
  deployment_id = aws_api_gateway_deployment.rest_api_deployment[each.value].id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  stage_name    = var.rest_api_stage_name
}