import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Lambda function to process notification-sent events from EventBridge
    """
    logger.info(f"Received notification event: {json.dumps(event)}")

    # Extract event details
    detail = event.get('detail', {})
    notification_id = detail.get('notificationId', 'unknown')
    recipient = detail.get('recipient', 'unknown')
    message = detail.get('message', 'unknown')
    channel = detail.get('channel', 'unknown')

    logger.info(f"Processing notification {notification_id} to {recipient} via {channel}")

    # Simulate notification processing logic
    response = {
        "statusCode": 200,
        "body": {
            "message": f"Notification {notification_id} processed successfully",
            "notificationId": notification_id,
            "recipient": recipient,
            "message": message,
            "channel": channel,
            "processedAt": context.aws_request_id
        }
    }

    logger.info(f"Notification processing completed: {json.dumps(response)}")
    return response
