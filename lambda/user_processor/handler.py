import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Lambda function to process user-registered events from EventBridge
    """
    logger.info(f"Received user event: {json.dumps(event)}")

    # Extract event details
    detail = event.get('detail', {})
    user_id = detail.get('userId', 'unknown')
    email = detail.get('email', 'unknown')
    name = detail.get('name', 'unknown')

    logger.info(f"Processing user registration for {name} ({email}) with ID {user_id}")

    # Simulate user processing logic (e.g., send welcome email, create profile)
    response = {
        "statusCode": 200,
        "body": {
            "message": f"User {name} registered successfully",
            "userId": user_id,
            "email": email,
            "name": name,
            "processedAt": context.aws_request_id
        }
    }

    logger.info(f"User processing completed: {json.dumps(response)}")
    return response
