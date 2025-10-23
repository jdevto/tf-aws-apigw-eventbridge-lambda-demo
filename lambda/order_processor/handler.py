import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Lambda function to process order-created events from EventBridge
    """
    logger.info(f"Received order event: {json.dumps(event)}")

    # Extract event details
    detail = event.get('detail', {})
    order_id = detail.get('orderId', 'unknown')
    customer_id = detail.get('customerId', 'unknown')
    amount = detail.get('amount', 0)

    logger.info(f"Processing order {order_id} for customer {customer_id} with amount ${amount}")

    # Simulate order processing logic
    response = {
        "statusCode": 200,
        "body": {
            "message": f"Order {order_id} processed successfully",
            "orderId": order_id,
            "customerId": customer_id,
            "amount": amount,
            "processedAt": context.aws_request_id
        }
    }

    logger.info(f"Order processing completed: {json.dumps(response)}")
    return response
