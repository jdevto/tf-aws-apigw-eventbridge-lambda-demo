# =============================================================================
# DATA SOURCES
# =============================================================================

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# =============================================================================
# CLOUDWATCH LOG GROUPS
# =============================================================================


resource "aws_cloudwatch_log_group" "notification_processor" {
  name              = "/aws/lambda/${var.project_name}-notification-processor"
  retention_in_days = 1

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(local.tags, {
    Name = "/aws/lambda/${var.project_name}-notification-processor"
  })
}

resource "aws_cloudwatch_log_group" "order_processor" {
  name              = "/aws/lambda/${var.project_name}-order-processor"
  retention_in_days = 1

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(local.tags, {
    Name = "/aws/lambda/${var.project_name}-order-processor"
  })
}

resource "aws_cloudwatch_log_group" "user_processor" {
  name              = "/aws/lambda/${var.project_name}-user-processor"
  retention_in_days = 1

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(local.tags, {
    Name = "/aws/lambda/${var.project_name}-user-processor"
  })
}

resource "aws_cloudwatch_log_group" "support_processor" {
  name              = "/aws/lambda/${var.project_name}-support-processor"
  retention_in_days = 1

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(local.tags, {
    Name = "/aws/lambda/${var.project_name}-support-processor"
  })
}

resource "aws_cloudwatch_log_group" "analytics_processor" {
  name              = "/aws/lambda/${var.project_name}-analytics-processor"
  retention_in_days = 1

  lifecycle {
    prevent_destroy = false
  }

  tags = merge(local.tags, {
    Name = "/aws/lambda/${var.project_name}-analytics-processor"
  })
}

# =============================================================================
# LAMBDA FUNCTIONS
# =============================================================================

# Order Processor Lambda
data "archive_file" "notification_processor_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/notification_processor/handler.py"
  output_path = "${path.module}/lambda/notification_processor.zip"
}

data "archive_file" "order_processor_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/order_processor/handler.py"
  output_path = "${path.module}/lambda/order_processor.zip"
}

data "archive_file" "user_processor_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/user_processor/handler.py"
  output_path = "${path.module}/lambda/user_processor.zip"
}

data "archive_file" "support_processor_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/support_processor/handler.py"
  output_path = "${path.module}/lambda/support_processor.zip"
}

data "archive_file" "analytics_processor_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/analytics_processor/handler.py"
  output_path = "${path.module}/lambda/analytics_processor.zip"
}

resource "aws_lambda_function" "notification_processor" {
  filename         = data.archive_file.notification_processor_zip.output_path
  function_name    = "${var.project_name}-notification-processor"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "handler.lambda_handler"
  source_code_hash = data.archive_file.notification_processor_zip.output_base64sha256
  runtime          = "python3.13"
  timeout          = 30

  depends_on = [aws_cloudwatch_log_group.notification_processor]

  tags = merge(local.tags, {
    Name = "${var.project_name}-notification-processor"
  })
}

resource "aws_lambda_function" "order_processor" {
  filename         = data.archive_file.order_processor_zip.output_path
  function_name    = "${var.project_name}-order-processor"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "handler.lambda_handler"
  source_code_hash = data.archive_file.order_processor_zip.output_base64sha256
  runtime          = "python3.13"
  timeout          = 30

  depends_on = [aws_cloudwatch_log_group.order_processor]

  tags = merge(local.tags, {
    Name = "${var.project_name}-order-processor"
  })
}

resource "aws_lambda_function" "user_processor" {
  filename         = data.archive_file.user_processor_zip.output_path
  function_name    = "${var.project_name}-user-processor"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "handler.lambda_handler"
  source_code_hash = data.archive_file.user_processor_zip.output_base64sha256
  runtime          = "python3.13"
  timeout          = 30

  depends_on = [aws_cloudwatch_log_group.user_processor]

  tags = merge(local.tags, {
    Name = "${var.project_name}-user-processor"
  })
}

resource "aws_lambda_function" "support_processor" {
  filename         = data.archive_file.support_processor_zip.output_path
  function_name    = "${var.project_name}-support-processor"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "handler.lambda_handler"
  source_code_hash = data.archive_file.support_processor_zip.output_base64sha256
  runtime          = "python3.13"
  timeout          = 30

  depends_on = [aws_cloudwatch_log_group.support_processor]

  tags = merge(local.tags, {
    Name = "${var.project_name}-support-processor"
  })
}

resource "aws_lambda_function" "analytics_processor" {
  filename         = data.archive_file.analytics_processor_zip.output_path
  function_name    = "${var.project_name}-analytics-processor"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "handler.lambda_handler"
  source_code_hash = data.archive_file.analytics_processor_zip.output_base64sha256
  runtime          = "python3.13"
  timeout          = 30

  depends_on = [aws_cloudwatch_log_group.analytics_processor]

  tags = merge(local.tags, {
    Name = "${var.project_name}-analytics-processor"
  })
}

# =============================================================================
# IAM ROLES AND POLICIES
# =============================================================================

# Lambda Execution Role
resource "aws_iam_role" "lambda_execution_role" {
  name = "${var.project_name}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LambdaAssumeRole"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "${var.project_name}-lambda-execution-role"
  })
}

resource "aws_iam_role_policy" "lambda_execution_policy" {
  name = "${var.project_name}-lambda-execution-policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogsWrite"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${var.project_name}-*"
      }
    ]
  })
}

# API Gateway EventBridge Role
resource "aws_iam_role" "api_gateway_eventbridge_role" {
  name = "${var.project_name}-api-gateway-eventbridge-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ApiGatewayAssumeRole"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "api_gateway_eventbridge_policy" {
  name = "${var.project_name}-api-gateway-eventbridge-policy"
  role = aws_iam_role.api_gateway_eventbridge_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EventBridgeWriteEvents"
        Effect = "Allow"
        Action = [
          "events:PutEvents"
        ]
        Resource = "arn:aws:events:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:event-bus/default"
      }
    ]
  })
}




# EventBridge Read Policy (for debugging)
resource "aws_iam_policy" "eventbridge_read_policy" {
  name        = "${var.project_name}-eventbridge-read-policy"
  description = "Read-only access to EventBridge for monitoring and debugging"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EventBridgeReadAccess"
        Effect = "Allow"
        Action = [
          "events:ListEvents",
          "events:DescribeEventBus",
          "events:ListRules",
          "events:DescribeRule",
          "events:ListTargetsByRule"
        ]
        Resource = [
          "arn:aws:events:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:event-bus/default",
          "arn:aws:events:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:rule/default/*"
        ]
        Condition = {
          StringEquals = {
            "events:event-bus-name" = "default"
          }
        }
      }
    ]
  })

  tags = merge(local.tags, {
    Name = "${var.project_name}-eventbridge-read-policy"
  })
}

# =============================================================================
# EVENTBRIDGE RULES AND TARGETS
# =============================================================================

# Order Created Rule
resource "aws_cloudwatch_event_rule" "order_created" {
  name        = "${var.project_name}-order-created-rule"
  description = "Rule to trigger order processor for order-created events"

  event_pattern = jsonencode({
    "detail-type" = ["order-created"]
  })

  tags = merge(local.tags, {
    Name = "${var.project_name}-order-created-rule"
  })
}

resource "aws_cloudwatch_event_target" "order_processor_target" {
  rule      = aws_cloudwatch_event_rule.order_created.name
  target_id = "OrderProcessorTarget"
  arn       = aws_lambda_function.order_processor.arn
}

resource "aws_lambda_permission" "allow_eventbridge_order" {
  statement_id  = "AllowExecutionFromEventBridgeOrderRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.order_processor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.order_created.arn
}

# Notification Sent Rule
resource "aws_cloudwatch_event_rule" "notification_sent" {
  name        = "${var.project_name}-notification-sent-rule"
  description = "Rule to trigger notification processor for notification-sent events"

  event_pattern = jsonencode({
    "detail-type" = ["notification-sent"]
  })

  tags = merge(local.tags, {
    Name = "${var.project_name}-notification-sent-rule"
  })
}

resource "aws_cloudwatch_event_target" "notification_processor_target" {
  rule      = aws_cloudwatch_event_rule.notification_sent.name
  target_id = "NotificationProcessorTarget"
  arn       = aws_lambda_function.notification_processor.arn
}

resource "aws_lambda_permission" "allow_eventbridge_notification" {
  statement_id  = "AllowExecutionFromEventBridgeNotificationRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notification_processor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.notification_sent.arn
}

# User Registered Rule
resource "aws_cloudwatch_event_rule" "user_registered" {
  name        = "${var.project_name}-user-registered-rule"
  description = "Rule to trigger user processor for user-registered events"

  event_pattern = jsonencode({
    "detail-type" = ["user-registered"]
  })

  tags = merge(local.tags, {
    Name = "${var.project_name}-user-registered-rule"
  })
}

resource "aws_cloudwatch_event_target" "user_processor_target" {
  rule      = aws_cloudwatch_event_rule.user_registered.name
  target_id = "UserProcessorTarget"
  arn       = aws_lambda_function.user_processor.arn
}

resource "aws_lambda_permission" "allow_eventbridge_user" {
  statement_id  = "AllowExecutionFromEventBridgeUserRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.user_processor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.user_registered.arn
}

# Support Ticket Rule
resource "aws_cloudwatch_event_rule" "support_ticket" {
  name        = "${var.project_name}-support-ticket-rule"
  description = "Rule to trigger support processor for support-ticket events"

  event_pattern = jsonencode({
    "detail-type" = ["support-ticket"]
  })

  tags = merge(local.tags, {
    Name = "${var.project_name}-support-ticket-rule"
  })
}

resource "aws_cloudwatch_event_target" "support_processor_target" {
  rule      = aws_cloudwatch_event_rule.support_ticket.name
  target_id = "SupportProcessorTarget"
  arn       = aws_lambda_function.support_processor.arn
}

resource "aws_lambda_permission" "allow_eventbridge_support" {
  statement_id  = "AllowExecutionFromEventBridgeSupportRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.support_processor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.support_ticket.arn
}

# Analytics Event Rule
resource "aws_cloudwatch_event_rule" "analytics_event" {
  name        = "${var.project_name}-analytics-event-rule"
  description = "Rule to trigger analytics processor for analytics-event events"

  event_pattern = jsonencode({
    "detail-type" = ["analytics-event"]
  })

  tags = merge(local.tags, {
    Name = "${var.project_name}-analytics-event-rule"
  })
}

resource "aws_cloudwatch_event_target" "analytics_processor_target" {
  rule      = aws_cloudwatch_event_rule.analytics_event.name
  target_id = "AnalyticsProcessorTarget"
  arn       = aws_lambda_function.analytics_processor.arn
}

resource "aws_lambda_permission" "allow_eventbridge_analytics" {
  statement_id  = "AllowExecutionFromEventBridgeAnalyticsRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.analytics_processor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.analytics_event.arn
}

# =============================================================================
# API GATEWAY
# =============================================================================

# API Gateway REST API
resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.project_name}-api"
  description = "API Gateway for EventBridge integration demo"

  tags = merge(local.tags, {
    Name = "${var.project_name}-api"
  })
}

# API Gateway Resources
resource "aws_api_gateway_resource" "events" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "events"
}

# API Gateway Methods
resource "aws_api_gateway_method" "events_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.events.id
  http_method   = "POST"
  authorization = "NONE"
}

# API Gateway Integrations
resource "aws_api_gateway_integration" "events_eventbridge" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.events.id
  http_method = aws_api_gateway_method.events_post.http_method

  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.region}:events:path//"
  credentials             = aws_iam_role.api_gateway_eventbridge_role.arn

  request_parameters = {
    "integration.request.header.X-Amz-Target" = "'AWSEvents.PutEvents'"
    "integration.request.header.Content-Type" = "'application/x-amz-json-1.1'"
  }

  request_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{
  "Entries": [
    {
      "Source": "api-gateway",
      "DetailType": "$input.path('$.detail-type')",
      "Detail": "$util.escapeJavaScript($input.json('$.detail'))",
      "EventBusName": "default"
    }
  ]
}
EOF
  }
}

# API Gateway Method Responses
resource "aws_api_gateway_method_response" "events_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.events.id
  http_method = aws_api_gateway_method.events_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "events_post_500" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.events.id
  http_method = aws_api_gateway_method.events_post.http_method
  status_code = "500"

  response_models = {
    "application/json" = "Empty"
  }
}

# API Gateway Integration Responses
resource "aws_api_gateway_integration_response" "events_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.events.id
  http_method = aws_api_gateway_method.events_post.http_method
  status_code = aws_api_gateway_method_response.events_post_200.status_code

  selection_pattern = "^2\\d{2}$"

  response_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{
  "message": "Event sent to EventBridge successfully",
  "entries": $input.json('$.Entries')
}
EOF
  }
}

resource "aws_api_gateway_integration_response" "events_post_500" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.events.id
  http_method = aws_api_gateway_method.events_post.http_method
  status_code = aws_api_gateway_method_response.events_post_500.status_code

  selection_pattern = "^5\\d{2}$"

  response_templates = {
    "application/json" = <<EOF
{
  "message": "Error sending event to EventBridge",
  "error": "$input.path('$.errorMessage')"
}
EOF
  }
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration.events_eventbridge,
    aws_api_gateway_integration_response.events_post_200,
    aws_api_gateway_integration_response.events_post_500
  ]

  rest_api_id = aws_api_gateway_rest_api.this.id

  lifecycle {
    create_before_destroy = true
  }
}

# CloudWatch Log Group for API Gateway
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.this.id}/${local.tags.Environment}"
  retention_in_days = 1

  tags = merge(local.tags, {
    Name = "API-Gateway-Logs-${var.project_name}"
  })
}

# IAM Role for API Gateway CloudWatch Logs
resource "aws_iam_role" "api_gateway_cloudwatch" {
  name = "${var.project_name}-api-gateway-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ApiGatewayAssumeRole"
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch" {
  role       = aws_iam_role.api_gateway_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}

# API Gateway Method Settings
resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    data_trace_enabled     = true
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = local.tags.Environment

  # Enable CloudWatch Logs
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId        = "$context.requestId"
      ip               = "$context.identity.sourceIp"
      requestTime      = "$context.requestTime"
      httpMethod       = "$context.httpMethod"
      resourcePath     = "$context.resourcePath"
      status           = "$context.status"
      protocol         = "$context.protocol"
      responseLength   = "$context.responseLength"
      integrationError = "$context.integrationErrorMessage"
    })
  }

  # Enable X-Ray tracing
  xray_tracing_enabled = true

  tags = merge(local.tags, {
    Name = "${var.project_name}-api-gateway-stage"
  })

  depends_on = [aws_api_gateway_account.this]
}
