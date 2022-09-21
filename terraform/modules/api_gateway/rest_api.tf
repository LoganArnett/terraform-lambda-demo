resource "aws_api_gateway_rest_api" "rest_api"{
    for_each = toset(["dev", "qa", "uat", "ng"])
    name = "${var.rest_api_name}-${each.value}"
}

## API Gateway resources
resource "aws_api_gateway_resource" "topLevel" {
  for_each = {
    for inst in local.topLevel : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.env].id
  parent_id = aws_api_gateway_rest_api.rest_api[each.value.env].root_resource_id
  path_part = each.value.path
}

resource "aws_api_gateway_resource" "firstChild" {
  for_each = {
    for inst in local.firstChild : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.env].id
  parent_id = aws_api_gateway_resource.topLevel["${each.value.parent}-${each.value.env}"].id
  path_part = each.value.path
}

resource "aws_api_gateway_resource" "secondChild" {
  for_each = {
    for inst in local.secondChild : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.env].id
  parent_id = aws_api_gateway_resource.firstChild["${each.value.parent}-${each.value.env}"].id
  path_part = each.value.path
}

resource "aws_api_gateway_resource" "thirdChild" {
  for_each = {
    for inst in local.thirdChild : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.env].id
  parent_id = aws_api_gateway_resource.secondChild["${each.value.parent}-${each.value.env}"].id
  path_part = each.value.path
}

## API Gateway Methods
resource "aws_api_gateway_method" "topLevel"{
  for_each = {
    for inst in local.topLevel : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.env].id
  resource_id = aws_api_gateway_resource.topLevel["${each.value.name}-${each.value.env}"].id
  http_method = each.value.method
  authorization = each.value.authorization
}

resource "aws_api_gateway_method" "firstChild"{
  for_each = {
    for inst in local.firstChild : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.env].id
  resource_id = aws_api_gateway_resource.firstChild["${each.value.name}-${each.value.env}"].id
  http_method = each.value.method
  authorization = each.value.authorization
  request_parameters = length(each.value.pathParameter) > 0 ? {
    "method.request.path.${each.value.pathParameter}" = true
  } : {}
}

resource "aws_api_gateway_method" "secondChild"{
  for_each = {
    for inst in local.secondChild : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.env].id
  resource_id = aws_api_gateway_resource.secondChild["${each.value.name}-${each.value.env}"].id
  http_method = each.value.method
  authorization = each.value.authorization
  request_parameters = length(each.value.pathParameter) > 0 ? {
    "method.request.path.${each.value.pathParameter}" = true
  } : {}
}

resource "aws_api_gateway_method" "thirdChild"{
  for_each = {
    for inst in local.thirdChild : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.env].id
  resource_id = aws_api_gateway_resource.thirdChild["${each.value.name}-${each.value.env}"].id
  http_method = each.value.method
  authorization = each.value.authorization
  request_parameters = length(each.value.pathParameter) > 0 ? {
    "method.request.path.${each.value.pathParameter}" = true
  } : {}
}

## API Gateway Integrations
resource "aws_api_gateway_integration" "topLevel" {
  for_each = {
    for inst in local.topLevel : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  rest_api_id             = aws_api_gateway_rest_api.rest_api[each.value.env].id
  resource_id             = aws_api_gateway_resource.topLevel["${each.value.name}-${each.value.env}"].id
  http_method             = aws_api_gateway_method.topLevel["${each.value.name}-${each.value.env}"].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_arn_topLevel["${each.value.name}-handler-${each.value.env}"].arn
}

resource "aws_api_gateway_integration" "firstChild" {
  for_each = {
    for inst in local.firstChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  rest_api_id             = aws_api_gateway_rest_api.rest_api[each.value.env].id
  resource_id             = aws_api_gateway_resource.firstChild["${each.value.name}-${each.value.env}"].id
  http_method             = aws_api_gateway_method.firstChild["${each.value.name}-${each.value.env}"].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_arn_firstChild["${each.value.name}-handler-${each.value.env}"].arn
}

resource "aws_api_gateway_integration" "secondChild" {
  for_each = {
    for inst in local.secondChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  rest_api_id             = aws_api_gateway_rest_api.rest_api[each.value.env].id
  resource_id             = aws_api_gateway_resource.secondChild["${each.value.name}-${each.value.env}"].id
  http_method             = aws_api_gateway_method.secondChild["${each.value.name}-${each.value.env}"].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_arn_secondChild["${each.value.name}-handler-${each.value.env}"].arn
}

resource "aws_api_gateway_integration" "thirdChild" {
  for_each = {
    for inst in local.thirdChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  rest_api_id             = aws_api_gateway_rest_api.rest_api[each.value.env].id
  resource_id             = aws_api_gateway_resource.thirdChild["${each.value.name}-${each.value.env}"].id
  http_method             = aws_api_gateway_method.thirdChild["${each.value.name}-${each.value.env}"].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_function_arn_thirdChild["${each.value.name}-handler-${each.value.env}"].arn
}

## API Gateway Method Response 200

resource "aws_api_gateway_method_response" "topLevel_200" {
  for_each = {
    for inst in local.topLevel : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.env].id
  resource_id = aws_api_gateway_resource.topLevel["${each.value.name}-${each.value.env}"].id
  http_method = aws_api_gateway_method.topLevel["${each.value.name}-${each.value.env}"].http_method
  status_code = "200"
}

resource "aws_api_gateway_method_response" "firstChild_200" {
  for_each = {
    for inst in local.firstChild : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.env].id
  resource_id = aws_api_gateway_resource.firstChild["${each.value.name}-${each.value.env}"].id
  http_method = aws_api_gateway_method.firstChild["${each.value.name}-${each.value.env}"].http_method
  status_code = "200"
}

resource "aws_api_gateway_method_response" "secondChild_200" {
  for_each = {
    for inst in local.secondChild : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.env].id
  resource_id = aws_api_gateway_resource.secondChild["${each.value.name}-${each.value.env}"].id
  http_method = aws_api_gateway_method.secondChild["${each.value.name}-${each.value.env}"].http_method
  status_code = "200"
}

resource "aws_api_gateway_method_response" "thirdChild_200" {
  for_each = {
    for inst in local.thirdChild : "${inst.name}-${inst.env}" => inst
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.env].id
  resource_id = aws_api_gateway_resource.thirdChild["${each.value.name}-${each.value.env}"].id
  http_method = aws_api_gateway_method.thirdChild["${each.value.name}-${each.value.env}"].http_method
  status_code = "200"
}


## API Gateway Method Integration Response
resource "aws_api_gateway_integration_response" "topLevel_integration_response_200" {
  for_each = {
    for inst in local.topLevel : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.env].id
  resource_id = aws_api_gateway_resource.topLevel["${each.value.name}-${each.value.env}"].id
  http_method = aws_api_gateway_integration.topLevel["${each.value.name}-${each.value.env}"].http_method
  status_code = aws_api_gateway_method_response.topLevel_200["${each.value.name}-${each.value.env}"].status_code
  response_templates = {
    "application/json" = jsonencode({
      body = "Hello from the Hello API!"
    })
  }
}

resource "aws_api_gateway_integration_response" "firstChild_integration_response_200" {
  for_each = {
    for inst in local.firstChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.env].id
  resource_id = aws_api_gateway_resource.firstChild["${each.value.name}-${each.value.env}"].id
  http_method = aws_api_gateway_integration.firstChild["${each.value.name}-${each.value.env}"].http_method
  status_code = aws_api_gateway_method_response.firstChild_200["${each.value.name}-${each.value.env}"].status_code
  response_templates = {
    "application/json" = jsonencode({
      body = "Hello from the Hello API!"
    })
  }
}

resource "aws_api_gateway_integration_response" "secondChild_integration_response_200" {
  for_each = {
    for inst in local.secondChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.env].id
  resource_id = aws_api_gateway_resource.secondChild["${each.value.name}-${each.value.env}"].id
  http_method = aws_api_gateway_integration.secondChild["${each.value.name}-${each.value.env}"].http_method
  status_code = aws_api_gateway_method_response.secondChild_200["${each.value.name}-${each.value.env}"].status_code
  response_templates = {
    "application/json" = jsonencode({
      body = "Hello from the Hello API!"
    })
  }
}

resource "aws_api_gateway_integration_response" "thirdChild_integration_response_200" {
  for_each = {
    for inst in local.thirdChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value.env].id
  resource_id = aws_api_gateway_resource.thirdChild["${each.value.name}-${each.value.env}"].id
  http_method = aws_api_gateway_integration.thirdChild["${each.value.name}-${each.value.env}"].http_method
  status_code = aws_api_gateway_method_response.thirdChild_200["${each.value.name}-${each.value.env}"].status_code
  response_templates = {
    "application/json" = jsonencode({
      body = "Hello from the Hello API!"
    })
  }
}

## API gateway Lambda Execution Permission
resource "aws_lambda_permission" "topLevel" {
  for_each = {
    for inst in local.topLevel : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${each.value.name}-handler-${each.value.env}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.api_gateway_region}:${var.api_gateway_account_id}:${aws_api_gateway_rest_api.rest_api[each.value.env].id}/*/${aws_api_gateway_method.topLevel["${each.value.name}-${each.value.env}"].http_method}${aws_api_gateway_resource.topLevel["${each.value.name}-${each.value.env}"].path}"
}

resource "aws_lambda_permission" "firstChild" {
  for_each = {
    for inst in local.firstChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${each.value.name}-handler-${each.value.env}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.api_gateway_region}:${var.api_gateway_account_id}:${aws_api_gateway_rest_api.rest_api[each.value.env].id}/*/${aws_api_gateway_method.firstChild["${each.value.name}-${each.value.env}"].http_method}${aws_api_gateway_resource.firstChild["${each.value.name}-${each.value.env}"].path}"
}

resource "aws_lambda_permission" "secondChild" {
  for_each = {
    for inst in local.secondChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${each.value.name}-handler-${each.value.env}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.api_gateway_region}:${var.api_gateway_account_id}:${aws_api_gateway_rest_api.rest_api[each.value.env].id}/*/${aws_api_gateway_method.secondChild["${each.value.name}-${each.value.env}"].http_method}${aws_api_gateway_resource.secondChild["${each.value.name}-${each.value.env}"].path}"
}

resource "aws_lambda_permission" "thirdChild" {
  for_each = {
    for inst in local.thirdChild : "${inst.name}-${inst.env}" => inst
    if inst.hasHandler
  }
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "${each.value.name}-handler-${each.value.env}"
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.api_gateway_region}:${var.api_gateway_account_id}:${aws_api_gateway_rest_api.rest_api[each.value.env].id}/*/${aws_api_gateway_method.thirdChild["${each.value.name}-${each.value.env}"].http_method}${aws_api_gateway_resource.thirdChild["${each.value.name}-${each.value.env}"].path}"
}

## API Gateway Deployment
resource "aws_api_gateway_deployment" "rest_api_deployment" {
  for_each = local.topLevel.*.hasHandler == true ? toset(["dev", "qa", "uat", "ng"]) : toset([])
  # for_each = {
  #   for inst in local.topLevel : "${inst.name}-${inst.env}" => inst
  #   if inst.hasHandler
  #   for env in toset(["dev", "qa", "uat", "ng"])
  # }
  rest_api_id = aws_api_gateway_rest_api.rest_api[each.value].id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.topLevel["hello-dev"].id,
      aws_api_gateway_method.topLevel["hello-dev"].id,
      aws_api_gateway_integration.topLevel["hello-dev"].id,
      aws_api_gateway_resource.topLevel["goodbye-dev"].id,
      aws_api_gateway_method.topLevel["goodbye-dev"].id,
      aws_api_gateway_integration.topLevel["goodbye-dev"].id
    ]))
  }
  depends_on = [
    aws_api_gateway_method.topLevel, 
    aws_api_gateway_integration.topLevel,
    # aws_api_gateway_method.firstChild,
    # aws_api_gateway_method.secondChild,
    # aws_api_gateway_method.thirdChild,
    # aws_api_gateway_integration.firstChild,
    # aws_api_gateway_integration.secondChild,
    # aws_api_gateway_integration.thirdChild
  ]
}
resource "aws_api_gateway_stage" "rest_api_stage" {
  #for_each = toset(["dev", "qa", "uat", "ng"])
  for_each = local.topLevel.*.hasHandler == true ? toset(["dev", "qa", "uat", "ng"]) : toset([])
  deployment_id = aws_api_gateway_deployment.rest_api_deployment[each.value].id
  rest_api_id   = aws_api_gateway_rest_api.rest_api[each.value].id
  stage_name    = var.rest_api_stage_name
}