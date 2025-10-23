import json
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Lambda function to process analytics events from EventBridge
    """
    logger.info(f"Received analytics event: {json.dumps(event)}")

    # Extract event details
    detail = event.get('detail', {})
    event_type = detail.get('eventType', 'unknown')
    user_id = detail.get('userId', 'anonymous')
    session_id = detail.get('sessionId', 'unknown')
    properties = detail.get('properties', {})

    # Process analytics event
    analytics_data = process_analytics(event_type, user_id, session_id, properties)

    # Generate response
    response = {
        "statusCode": 200,
        "body": {
            "message": f"Analytics event {event_type} processed successfully",
            "eventType": event_type,
            "userId": user_id,
            "sessionId": session_id,
            "processedData": analytics_data,
            "timestamp": datetime.utcnow().isoformat(),
            "requestId": context.aws_request_id
        }
    }

    logger.info(f"Analytics processing completed: {json.dumps(response)}")
    return response

def process_analytics(event_type, user_id, session_id, properties):
    """Process analytics data based on event type"""
    base_data = {
        "timestamp": datetime.utcnow().isoformat(),
        "userId": user_id,
        "sessionId": session_id,
        "eventType": event_type
    }

    if event_type == "page_view":
        return {
            **base_data,
            "page": properties.get("page", "unknown"),
            "referrer": properties.get("referrer", "direct"),
            "userAgent": properties.get("userAgent", "unknown")
        }
    elif event_type == "purchase":
        return {
            **base_data,
            "orderValue": properties.get("orderValue", 0),
            "currency": properties.get("currency", "USD"),
            "items": properties.get("items", []),
            "conversionValue": calculate_conversion_value(properties)
        }
    elif event_type == "signup":
        return {
            **base_data,
            "signupMethod": properties.get("method", "email"),
            "source": properties.get("source", "unknown"),
            "campaign": properties.get("campaign", "organic")
        }
    else:
        return {
            **base_data,
            "customProperties": properties
        }

def calculate_conversion_value(properties):
    """Calculate conversion value for purchase events"""
    order_value = properties.get("orderValue", 0)
    # Add any business logic for conversion value calculation
    return order_value * 0.1  # Example: 10% margin
