output "lambda_function_arn_topLevel" {
  value = tomap({for v in values(aws_lambda_function.topLevel) :
    v.function_name => {
      arn = v.invoke_arn
    }
  })
}

output "lambda_function_arn_firstChild" {
  value = tomap({for v in values(aws_lambda_function.firstChild) :
    v.function_name => {
      arn = v.invoke_arn
    }
  })
}

output "lambda_function_arn_secondChild" {
  value = tomap({for v in values(aws_lambda_function.secondChild) :
    v.function_name => {
      arn = v.invoke_arn
    }
  })
}

output "lambda_function_arn_thirdChild" {
  value = tomap({for v in values(aws_lambda_function.thirdChild) :
    v.function_name => {
      arn = v.invoke_arn
    }
  })
}

output "lambda_function_name_topLevel" {
  value = values(aws_lambda_function.topLevel).*.function_name
}

output "lambda_function_name_firstChild" {
  value = values(aws_lambda_function.firstChild).*.function_name
}

output "lambda_function_name_secondChild" {
  value = values(aws_lambda_function.secondChild).*.function_name
}

output "lambda_function_name_thirdChild" {
  value = values(aws_lambda_function.thirdChild).*.function_name
}