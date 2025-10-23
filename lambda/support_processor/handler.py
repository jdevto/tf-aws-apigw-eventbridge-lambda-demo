import json
import logging
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Lambda function to process support ticket events from EventBridge
    """
    logger.info(f"Received support event: {json.dumps(event)}")

    # Extract event details
    detail = event.get('detail', {})
    ticket_id = detail.get('ticketId', 'unknown')
    customer_id = detail.get('customerId', 'unknown')
    priority = detail.get('priority', 'medium')
    category = detail.get('category', 'general')
    description = detail.get('description', 'No description provided')

    # Simulate support ticket processing
    ticket_status = process_ticket(ticket_id, priority, category)

    # Generate response
    response = {
        "statusCode": 200,
        "body": {
            "message": f"Support ticket {ticket_id} processed successfully",
            "ticketId": ticket_id,
            "customerId": customer_id,
            "priority": priority,
            "category": category,
            "status": ticket_status,
            "assignedTo": get_assignment(priority, category),
            "estimatedResolution": get_eta(priority),
            "processedAt": datetime.utcnow().isoformat(),
            "requestId": context.aws_request_id
        }
    }

    logger.info(f"Support processing completed: {json.dumps(response)}")
    return response

def process_ticket(ticket_id, priority, category):
    """Simulate ticket processing logic"""
    if priority == 'high':
        return 'escalated'
    elif category in ['billing', 'payment']:
        return 'assigned_to_finance'
    elif category == 'technical':
        return 'assigned_to_engineering'
    else:
        return 'assigned_to_support'

def get_assignment(priority, category):
    """Determine ticket assignment based on priority and category"""
    if priority == 'high':
        return 'senior_support_team'
    elif category == 'billing':
        return 'finance_team'
    elif category == 'technical':
        return 'engineering_team'
    else:
        return 'general_support_team'

def get_eta(priority):
    """Get estimated resolution time based on priority"""
    eta_map = {
        'high': '2-4 hours',
        'medium': '1-2 business days',
        'low': '3-5 business days'
    }
    return eta_map.get(priority, '2-3 business days')
