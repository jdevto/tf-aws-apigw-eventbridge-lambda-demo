output "aws_region" {
  description = "AWS region used for deployment"
  value       = data.aws_region.current.region
}

output "api_gateway_url" {
  description = "API Gateway invoke URL"
  value       = "${aws_api_gateway_stage.this.invoke_url}/events"
}

output "api_gateway_id" {
  description = "API Gateway REST API ID"
  value       = aws_api_gateway_rest_api.this.id
}

output "api_gateway_stage_name" {
  description = "API Gateway stage name"
  value       = aws_api_gateway_stage.this.stage_name
}

output "event_bus_arn" {
  description = "EventBridge event bus ARN (default)"
  value       = "arn:aws:events:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:event-bus/default"
}

output "lambda_functions" {
  description = "Lambda function details"
  value = {
    order_processor = {
      name = aws_lambda_function.order_processor.function_name
      arn  = aws_lambda_function.order_processor.arn
    }
    user_processor = {
      name = aws_lambda_function.user_processor.function_name
      arn  = aws_lambda_function.user_processor.arn
    }
    notification_processor = {
      name = aws_lambda_function.notification_processor.function_name
      arn  = aws_lambda_function.notification_processor.arn
    }
    support_processor = {
      name = aws_lambda_function.support_processor.function_name
      arn  = aws_lambda_function.support_processor.arn
    }
    analytics_processor = {
      name = aws_lambda_function.analytics_processor.function_name
      arn  = aws_lambda_function.analytics_processor.arn
    }
  }
}

output "eventbridge_rules" {
  description = "EventBridge rule details"
  value = {
    order_created = {
      name = aws_cloudwatch_event_rule.order_created.name
      arn  = aws_cloudwatch_event_rule.order_created.arn
    }
    user_registered = {
      name = aws_cloudwatch_event_rule.user_registered.name
      arn  = aws_cloudwatch_event_rule.user_registered.arn
    }
    notification_sent = {
      name = aws_cloudwatch_event_rule.notification_sent.name
      arn  = aws_cloudwatch_event_rule.notification_sent.arn
    }
  }
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log group details"
  value = {
    order_processor = {
      name = aws_cloudwatch_log_group.order_processor.name
      arn  = aws_cloudwatch_log_group.order_processor.arn
    }
    user_processor = {
      name = aws_cloudwatch_log_group.user_processor.name
      arn  = aws_cloudwatch_log_group.user_processor.arn
    }
    notification_processor = {
      name = aws_cloudwatch_log_group.notification_processor.name
      arn  = aws_cloudwatch_log_group.notification_processor.arn
    }
  }
}

output "iam_policies" {
  description = "IAM policy details for monitoring"
  value = {
    eventbridge_read_policy = {
      name = aws_iam_policy.eventbridge_read_policy.name
      arn  = aws_iam_policy.eventbridge_read_policy.arn
    }
    lambda_execution_policy = {
      name = aws_iam_role_policy.lambda_execution_policy.name
      role = aws_iam_role.lambda_execution_role.name
    }
    api_gateway_eventbridge_policy = {
      name = aws_iam_role_policy.api_gateway_eventbridge_policy.name
      role = aws_iam_role.api_gateway_eventbridge_role.name
    }
  }
}
