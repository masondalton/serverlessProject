variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "region" {
  type = string
}

variable "table_name" {
  type = string
}

variable "table_arn" {
  type = string
}

variable "lambda_source_dir" {
  type = string
}

variable "user_pool_arn" {
  type = string
}

# Zip up the lambda source directory (your ../lambda folder from root)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = var.lambda_source_dir
  output_path = "${path.module}/build/lambda.zip"
}

resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-${var.environment}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-${var.environment}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          var.table_arn,
          "${var.table_arn}/*"
        ]
      }
    ]
  })
}

resource "aws_lambda_function" "get_benders" {
  function_name = "${var.project_name}-${var.environment}-get-benders"

  role    = aws_iam_role.lambda_role.arn
  handler = "app.get_benders"
  runtime = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.table_name
      REGION     = var.region
    }
  }
}

resource "aws_lambda_function" "get_techniques" {
  function_name = "${var.project_name}-${var.environment}-get-techniques"

  role    = aws_iam_role.lambda_role.arn
  handler = "app.get_techniques"
  runtime = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.table_name
      REGION     = var.region
    }
  }
}

resource "aws_lambda_function" "get_nation_lore" {
  function_name = "${var.project_name}-${var.environment}-get-nation-lore"

  role    = aws_iam_role.lambda_role.arn
  handler = "app.get_nation_lore"
  runtime = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.table_name
      REGION     = var.region
    }
  }
}

resource "aws_lambda_function" "suggest_element" {
  function_name = "${var.project_name}-${var.environment}-suggest-element"

  role    = aws_iam_role.lambda_role.arn
  handler = "app.suggest_element"
  runtime = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.table_name
      REGION     = var.region
    }
  }
}

resource "aws_lambda_function" "create_or_update_bender" {
  function_name = "${var.project_name}-${var.environment}-create-update-bender"

  role    = aws_iam_role.lambda_role.arn
  handler = "app.create_or_update_bender"
  runtime = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.table_name
      REGION     = var.region
    }
  }
}

resource "aws_lambda_function" "delete_bender" {
  function_name = "${var.project_name}-${var.environment}-delete-bender"

  role    = aws_iam_role.lambda_role.arn
  handler = "app.delete_bender"
  runtime = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.table_name
      REGION     = var.region
    }
  }
}

resource "aws_lambda_function" "create_or_update_technique" {
  function_name = "${var.project_name}-${var.environment}-create-update-technique"

  role    = aws_iam_role.lambda_role.arn
  handler = "app.create_or_update_technique"
  runtime = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.table_name
      REGION     = var.region
    }
  }
}

resource "aws_lambda_function" "delete_technique" {
  function_name = "${var.project_name}-${var.environment}-delete-technique"

  role    = aws_iam_role.lambda_role.arn
  handler = "app.delete_technique"
  runtime = "python3.11"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = var.table_name
      REGION     = var.region
    }
  }
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project_name}-${var.environment}-api"
  description = "Four Nations Archive API"
}

resource "aws_api_gateway_resource" "benders" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "benders"
}

resource "aws_api_gateway_method" "get_benders" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.benders.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_benders" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.benders.id
  http_method             = aws_api_gateway_method.get_benders.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_benders.invoke_arn
}

resource "aws_api_gateway_method" "options_benders" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.benders.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_benders" {
  rest_api_id       = aws_api_gateway_rest_api.api.id
  resource_id       = aws_api_gateway_resource.benders.id
  http_method       = aws_api_gateway_method.options_benders.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{ \"statusCode\": 200 }" }
}

resource "aws_api_gateway_method_response" "options_benders" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.benders.id
  http_method = aws_api_gateway_method.options_benders.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_benders" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.benders.id
  http_method = aws_api_gateway_method.options_benders.http_method
  status_code = aws_api_gateway_method_response.options_benders.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
}

resource "aws_lambda_permission" "apigw_invoke_get_benders" {
  statement_id  = "AllowAPIGatewayInvokeGetBenders"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_benders.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_resource" "techniques" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "techniques"
}

resource "aws_api_gateway_method" "get_techniques" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.techniques.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_techniques" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.techniques.id
  http_method             = aws_api_gateway_method.get_techniques.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_techniques.invoke_arn
}

resource "aws_api_gateway_method" "options_techniques" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.techniques.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_techniques" {
  rest_api_id       = aws_api_gateway_rest_api.api.id
  resource_id       = aws_api_gateway_resource.techniques.id
  http_method       = aws_api_gateway_method.options_techniques.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{ \"statusCode\": 200 }" }
}

resource "aws_api_gateway_method_response" "options_techniques" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.techniques.id
  http_method = aws_api_gateway_method.options_techniques.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_techniques" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.techniques.id
  http_method = aws_api_gateway_method.options_techniques.http_method
  status_code = aws_api_gateway_method_response.options_techniques.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
}

resource "aws_lambda_permission" "apigw_invoke_get_techniques" {
  statement_id  = "AllowAPIGatewayInvokeGetTechniques"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_techniques.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_resource" "admin_technique" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.admin.id
  path_part   = "technique"
}

resource "aws_api_gateway_resource" "admin_technique_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.admin_technique.id
  path_part   = "{id}"
}

resource "aws_api_gateway_resource" "nations" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "nations"
}

resource "aws_api_gateway_resource" "nation_name" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.nations.id
  path_part   = "{name}"
}

resource "aws_api_gateway_method" "get_nation_lore" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.nation_name.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_nation_lore" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.nation_name.id
  http_method             = aws_api_gateway_method.get_nation_lore.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_nation_lore.invoke_arn
}

resource "aws_api_gateway_method" "options_nation_lore" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.nation_name.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_nation_lore" {
  rest_api_id       = aws_api_gateway_rest_api.api.id
  resource_id       = aws_api_gateway_resource.nation_name.id
  http_method       = aws_api_gateway_method.options_nation_lore.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{ \"statusCode\": 200 }" }
}

resource "aws_api_gateway_method_response" "options_nation_lore" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.nation_name.id
  http_method = aws_api_gateway_method.options_nation_lore.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_nation_lore" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.nation_name.id
  http_method = aws_api_gateway_method.options_nation_lore.http_method
  status_code = aws_api_gateway_method_response.options_nation_lore.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
}

resource "aws_lambda_permission" "apigw_invoke_get_nation_lore" {
  statement_id  = "AllowAPIGatewayInvokeGetNationLore"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_nation_lore.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_resource" "quiz" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "quiz"
}

resource "aws_api_gateway_method" "suggest_element" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.quiz.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "suggest_element" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.quiz.id
  http_method             = aws_api_gateway_method.suggest_element.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.suggest_element.invoke_arn
}

resource "aws_api_gateway_method" "options_quiz" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.quiz.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_quiz" {
  rest_api_id       = aws_api_gateway_rest_api.api.id
  resource_id       = aws_api_gateway_resource.quiz.id
  http_method       = aws_api_gateway_method.options_quiz.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{ \"statusCode\": 200 }" }
}

resource "aws_api_gateway_method_response" "options_quiz" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.quiz.id
  http_method = aws_api_gateway_method.options_quiz.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_quiz" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.quiz.id
  http_method = aws_api_gateway_method.options_quiz.http_method
  status_code = aws_api_gateway_method_response.options_quiz.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
}

resource "aws_api_gateway_method_response" "options_admin_bender" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.admin_bender.id
  http_method = aws_api_gateway_method.options_admin_bender.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_method_response" "options_admin_bender_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.admin_bender_id.id
  http_method = aws_api_gateway_method.options_admin_bender_id.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_method_response" "options_admin_technique" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.admin_technique.id
  http_method = aws_api_gateway_method.options_admin_technique.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_method_response" "options_admin_technique_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.admin_technique_id.id
  http_method = aws_api_gateway_method.options_admin_technique_id.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

resource "aws_api_gateway_integration_response" "options_admin_bender" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.admin_bender.id
  http_method = aws_api_gateway_method.options_admin_bender.http_method
  status_code = aws_api_gateway_method_response.options_admin_bender.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'PUT,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
}

resource "aws_api_gateway_integration_response" "options_admin_bender_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.admin_bender_id.id
  http_method = aws_api_gateway_method.options_admin_bender_id.http_method
  status_code = aws_api_gateway_method_response.options_admin_bender_id.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
}

resource "aws_api_gateway_integration_response" "options_admin_technique" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.admin_technique.id
  http_method = aws_api_gateway_method.options_admin_technique.http_method
  status_code = aws_api_gateway_method_response.options_admin_technique.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'PUT,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
}

resource "aws_api_gateway_integration_response" "options_admin_technique_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.admin_technique_id.id
  http_method = aws_api_gateway_method.options_admin_technique_id.http_method
  status_code = aws_api_gateway_method_response.options_admin_technique_id.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }
}

resource "aws_lambda_permission" "apigw_invoke_suggest_element" {
  statement_id  = "AllowAPIGatewayInvokeSuggestElement"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.suggest_element.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_resource" "admin" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "admin"
}

resource "aws_api_gateway_resource" "admin_bender" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.admin.id
  path_part   = "bender"
}

resource "aws_api_gateway_resource" "admin_bender_id" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.admin_bender.id
  path_part   = "{id}"
}

resource "aws_api_gateway_authorizer" "cognito" {
  name                   = "${var.project_name}-${var.environment}-cognito-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.api.id
  type                   = "COGNITO_USER_POOLS"
  identity_source        = "method.request.header.Authorization"
  provider_arns          = [var.user_pool_arn]
}

resource "aws_api_gateway_method" "create_or_update_bender" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.admin_bender.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_method" "options_admin_bender" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.admin_bender.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "create_or_update_technique" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.admin_technique.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_method" "options_admin_technique" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.admin_technique.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "create_or_update_bender" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.admin_bender.id
  http_method             = aws_api_gateway_method.create_or_update_bender.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_or_update_bender.invoke_arn
}

resource "aws_api_gateway_integration" "options_admin_bender" {
  rest_api_id       = aws_api_gateway_rest_api.api.id
  resource_id       = aws_api_gateway_resource.admin_bender.id
  http_method       = aws_api_gateway_method.options_admin_bender.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{ \"statusCode\": 200 }" }
}

resource "aws_lambda_permission" "apigw_invoke_create_or_update_bender" {
  statement_id  = "AllowAPIGatewayInvokeCreateOrUpdateBender"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_or_update_bender.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_integration" "create_or_update_technique" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.admin_technique.id
  http_method             = aws_api_gateway_method.create_or_update_technique.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_or_update_technique.invoke_arn
}

resource "aws_api_gateway_integration" "options_admin_technique" {
  rest_api_id       = aws_api_gateway_rest_api.api.id
  resource_id       = aws_api_gateway_resource.admin_technique.id
  http_method       = aws_api_gateway_method.options_admin_technique.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{ \"statusCode\": 200 }" }
}

resource "aws_lambda_permission" "apigw_invoke_create_or_update_technique" {
  statement_id  = "AllowAPIGatewayInvokeCreateOrUpdateTechnique"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_or_update_technique.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_method" "delete_bender" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.admin_bender_id.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_method" "options_admin_bender_id" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.admin_bender_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "delete_technique" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.admin_technique_id.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_method" "options_admin_technique_id" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.admin_technique_id.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "delete_bender" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.admin_bender_id.id
  http_method             = aws_api_gateway_method.delete_bender.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_bender.invoke_arn
}

resource "aws_api_gateway_integration" "options_admin_bender_id" {
  rest_api_id       = aws_api_gateway_rest_api.api.id
  resource_id       = aws_api_gateway_resource.admin_bender_id.id
  http_method       = aws_api_gateway_method.options_admin_bender_id.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{ \"statusCode\": 200 }" }
}

resource "aws_lambda_permission" "apigw_invoke_delete_bender" {
  statement_id  = "AllowAPIGatewayInvokeDeleteBender"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_bender.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_integration" "delete_technique" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.admin_technique_id.id
  http_method             = aws_api_gateway_method.delete_technique.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_technique.invoke_arn
}

resource "aws_api_gateway_integration" "options_admin_technique_id" {
  rest_api_id       = aws_api_gateway_rest_api.api.id
  resource_id       = aws_api_gateway_resource.admin_technique_id.id
  http_method       = aws_api_gateway_method.options_admin_technique_id.http_method
  type              = "MOCK"
  request_templates = { "application/json" = "{ \"statusCode\": 200 }" }
}

resource "aws_lambda_permission" "apigw_invoke_delete_technique" {
  statement_id  = "AllowAPIGatewayInvokeDeleteTechnique"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_technique.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deploy" {
  depends_on = [
    aws_api_gateway_integration.get_benders,
    aws_api_gateway_integration.get_techniques,
    aws_api_gateway_integration.get_nation_lore,
    aws_api_gateway_integration.suggest_element,
    aws_api_gateway_integration.create_or_update_bender,
    aws_api_gateway_integration.delete_bender,
    aws_api_gateway_integration.create_or_update_technique,
    aws_api_gateway_integration.delete_technique,
    aws_api_gateway_integration.options_benders,
    aws_api_gateway_integration.options_techniques,
    aws_api_gateway_integration.options_nation_lore,
    aws_api_gateway_integration.options_quiz,
    aws_api_gateway_integration.options_admin_bender,
    aws_api_gateway_integration.options_admin_bender_id,
    aws_api_gateway_integration.options_admin_technique,
    aws_api_gateway_integration.options_admin_technique_id,
    aws_api_gateway_integration_response.options_benders,
    aws_api_gateway_integration_response.options_techniques,
    aws_api_gateway_integration_response.options_nation_lore,
    aws_api_gateway_integration_response.options_quiz,
    aws_api_gateway_integration_response.options_admin_bender,
    aws_api_gateway_integration_response.options_admin_bender_id,
    aws_api_gateway_integration_response.options_admin_technique,
    aws_api_gateway_integration_response.options_admin_technique_id
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.api_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "prod"
}
