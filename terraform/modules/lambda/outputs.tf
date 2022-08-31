output "lambda_function_arn" {
  value = tomap({for v in values(aws_lambda_function.lambda_function) :
    v.function_name => {
      arn = v.invoke_arn
    }
  })
}

output "lambda_function_arn_child" {
  value = tomap({for v in values(aws_lambda_function.lambda_function_child) :
    v.function_name => {
      arn = v.invoke_arn
    }
  })
}

output "lambda_function_name" {
  value = values(aws_lambda_function.lambda_function).*.function_name
}

output "lambda_function_name_child" {
  value = values(aws_lambda_function.lambda_function_child).*.function_name
}