output "lambda_function_arn" {
  value = tomap({for v in values(aws_lambda_function.lambda_function) :
    v.function_name => {
      arn = v.arn
    }
  })
}

output "lambda_function_name" {
  value = values(aws_lambda_function.lambda_function).*.function_name
}