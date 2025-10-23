#!/bin/bash

# Comprehensive Test Script for API Gateway → EventBridge → Lambda Demo
# This script demonstrates both basic functionality and real-world business scenarios

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get API Gateway URL and region from Terraform output
API_URL=$(terraform output -raw api_gateway_url 2>/dev/null)
AWS_REGION=$(terraform output -raw aws_region 2>/dev/null)

if [ -z "$API_URL" ]; then
    echo -e "${RED}Error: Could not get API Gateway URL from Terraform output${NC}"
    echo "Make sure you have deployed the infrastructure with 'terraform apply'"
    exit 1
fi

if [ -z "$AWS_REGION" ]; then
    echo -e "${RED}Error: Could not get AWS region from Terraform output${NC}"
    echo "Make sure you have deployed the infrastructure with 'terraform apply'"
    exit 1
fi

echo -e "${BLUE}🚀 API Gateway → EventBridge → Lambda Demo Testing${NC}"
echo -e "${BLUE}API Gateway URL: ${API_URL}${NC}"
echo ""

# Function to send test event
send_event() {
    local event_type=$1
    local event_data=$2
    local description=$3

    echo -e "${YELLOW}Testing: ${description}${NC}"
    echo "Event Type: $event_type"
    echo "Payload: $event_data"

    response=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
        -X POST \
        -H "Content-Type: application/json" \
        -H "Cache-Control: no-cache" \
        -d "$event_data" \
        "$API_URL")

    http_code=$(echo "$response" | grep "HTTP_CODE:" | cut -d: -f2)
    response_body=$(echo "$response" | sed '/HTTP_CODE:/d')

    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✓ Success (HTTP $http_code)${NC}"
        echo "Response: $response_body"
    else
        echo -e "${RED}✗ Failed (HTTP $http_code)${NC}"
        echo "Response: $response_body"
    fi
    echo ""
}

# =============================================================================
# BASIC FUNCTIONALITY TESTS
# =============================================================================

echo -e "${PURPLE}🔧 === BASIC FUNCTIONALITY TESTS ===${NC}"

# Test 1: Order Created Event
echo -e "${CYAN}--- Test 1: Order Created Event ---${NC}"
send_event "order-created" '{
    "detail-type": "order-created",
    "detail": {
        "orderId": "ORD-12345",
        "customerId": "CUST-001",
        "amount": 99.99,
        "items": ["laptop", "mouse"],
        "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
    }
}' "Order processing"

# Test 2: User Registered Event
echo -e "${CYAN}--- Test 2: User Registered Event ---${NC}"
send_event "user-registered" '{
    "detail-type": "user-registered",
    "detail": {
        "userId": "USER-789",
        "email": "john.doe@example.com",
        "name": "John Doe",
        "registrationDate": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
        "source": "web"
    }
}' "User registration processing"

# Test 3: Notification Sent Event
echo -e "${CYAN}--- Test 3: Notification Sent Event ---${NC}"
send_event "notification-sent" '{
    "detail-type": "notification-sent",
    "detail": {
        "notificationId": "NOTIF-456",
        "recipient": "user@example.com",
        "message": "Your order has been processed successfully!",
        "channel": "email",
        "priority": "high",
        "sentAt": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
    }
}' "Notification processing"

# =============================================================================
# BUSINESS SCENARIOS TESTS
# =============================================================================

echo -e "${PURPLE}🏢 === BUSINESS SCENARIOS TESTS ===${NC}"

# Scenario 1: E-commerce Order with Full Details
echo -e "${CYAN}--- Scenario 1: E-commerce Order Processing ---${NC}"
send_event "order-created" '{
    "detail-type": "order-created",
    "detail": {
        "orderId": "ECOMM-2025-001",
        "customerId": "CUST-ECOMM-001",
        "amount": 299.99,
        "items": [
            {"name": "MacBook Pro", "sku": "MBP-16-2024", "price": 2499.99, "quantity": 1},
            {"name": "Magic Mouse", "sku": "MM-2024", "price": 79.99, "quantity": 1}
        ],
        "shippingAddress": {
            "street": "123 Tech Street",
            "city": "San Francisco",
            "state": "CA",
            "zipCode": "94105"
        },
        "paymentMethod": "credit_card",
        "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
    }
}' "E-commerce order processing"

# Scenario 2: Customer Registration with Marketing Data
echo -e "${CYAN}--- Scenario 2: Customer Registration with Marketing Data ---${NC}"
send_event "user-registered" '{
    "detail-type": "user-registered",
    "detail": {
        "userId": "USER-ECOMM-001",
        "email": "john.smith@example.com",
        "name": "John Smith",
        "registrationDate": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
        "source": "website",
        "marketingConsent": true,
        "preferredLanguage": "en-US",
        "referralCode": "FRIEND2025"
    }
}' "Customer onboarding with marketing data"

# Scenario 3: Order Confirmation Notification
echo -e "${CYAN}--- Scenario 3: Order Confirmation Notification ---${NC}"
send_event "notification-sent" '{
    "detail-type": "notification-sent",
    "detail": {
        "notificationId": "NOTIF-ECOMM-001",
        "recipient": "john.smith@example.com",
        "message": "Your order ECOMM-2025-001 has been confirmed! We will send you tracking information soon.",
        "channel": "email",
        "priority": "high",
        "templateId": "order_confirmation",
        "sentAt": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
        "metadata": {
            "orderId": "ECOMM-2025-001",
            "customerId": "CUST-ECOMM-001"
        }
    }
}' "Order confirmation notification"

# Scenario 4: High Priority Support Ticket
echo -e "${CYAN}--- Scenario 4: High Priority Support Ticket ---${NC}"
send_event "support-ticket" '{
    "detail-type": "support-ticket",
    "detail": {
        "ticketId": "SUPPORT-2025-001",
        "customerId": "CUST-ECOMM-001",
        "priority": "high",
        "category": "technical",
        "subject": "Unable to access my account",
        "description": "I cannot log into my account after the recent password reset. Getting 500 error.",
        "contactMethod": "email",
        "createdAt": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
        "attachments": ["error_screenshot.png"],
        "tags": ["urgent", "login", "authentication"]
    }
}' "High priority support ticket processing"

# Scenario 5: Billing Inquiry
echo -e "${CYAN}--- Scenario 5: Billing Inquiry ---${NC}"
send_event "support-ticket" '{
    "detail-type": "support-ticket",
    "detail": {
        "ticketId": "SUPPORT-2025-002",
        "customerId": "CUST-ECOMM-001",
        "priority": "medium",
        "category": "billing",
        "subject": "Question about my recent charge",
        "description": "I was charged twice for the same order. Can you please investigate?",
        "contactMethod": "phone",
        "createdAt": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
        "orderReference": "ECOMM-2025-001",
        "amount": 299.99
    }
}' "Billing inquiry processing"

# Scenario 6: Page View Analytics
echo -e "${CYAN}--- Scenario 6: Page View Analytics ---${NC}"
send_event "analytics-event" '{
    "detail-type": "analytics-event",
    "detail": {
        "eventType": "page_view",
        "userId": "USER-ECOMM-001",
        "sessionId": "SESS-2025-001",
        "properties": {
            "page": "/products/macbook-pro",
            "referrer": "https://google.com/search?q=macbook+pro",
            "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)",
            "viewport": "1920x1080",
            "language": "en-US",
            "timeOnPage": 45
        },
        "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
    }
}' "Page view analytics tracking"

# Scenario 7: Purchase Conversion Analytics
echo -e "${CYAN}--- Scenario 7: Purchase Conversion Analytics ---${NC}"
send_event "analytics-event" '{
    "detail-type": "analytics-event",
    "detail": {
        "eventType": "purchase",
        "userId": "USER-ECOMM-001",
        "sessionId": "SESS-2025-001",
        "properties": {
            "orderValue": 299.99,
            "currency": "USD",
            "items": [
                {"name": "MacBook Pro", "category": "Electronics", "price": 2499.99},
                {"name": "Magic Mouse", "category": "Accessories", "price": 79.99}
            ],
            "paymentMethod": "credit_card",
            "couponCode": "SAVE10",
            "discountAmount": 30.00,
            "shippingCost": 0.00,
            "taxAmount": 24.00
        },
        "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
    }
}' "Purchase conversion analytics"

# Scenario 8: User Signup Analytics
echo -e "${CYAN}--- Scenario 8: User Signup Analytics ---${NC}"
send_event "analytics-event" '{
    "detail-type": "analytics-event",
    "detail": {
        "eventType": "signup",
        "userId": "USER-ECOMM-001",
        "sessionId": "SESS-2025-001",
        "properties": {
            "method": "email",
            "source": "organic_search",
            "campaign": "summer_sale_2025",
            "referrer": "https://google.com",
            "signupFlow": "quick_checkout",
            "timeToSignup": 120
        },
        "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'"
    }
}' "User signup analytics tracking"

# =============================================================================
# ERROR HANDLING TEST
# =============================================================================

echo -e "${PURPLE}⚠️  === ERROR HANDLING TEST ===${NC}"

# Test: Invalid event type (should not trigger any Lambda)
echo -e "${CYAN}--- Test: Invalid Event Type (No Lambda Trigger) ---${NC}"
send_event "invalid-event" '{
    "detail-type": "invalid-event",
    "detail": {
        "message": "This event should not trigger any Lambda function",
        "testPurpose": "Demonstrates event filtering"
    }
}' "Invalid event (should not trigger Lambda)"

# =============================================================================
# SUMMARY
# =============================================================================

echo -e "${BLUE}🎉 === Testing Complete ===${NC}"
echo ""
echo -e "${YELLOW}📋 Summary of Tests:${NC}"
echo "  🔧 Basic Functionality: Order, User, Notification processing"
echo "  🏢 Business Scenarios: E-commerce, Support, Analytics"
echo "  ⚠️  Error Handling: Invalid events (filtered out)"
echo ""
echo -e "${YELLOW}📊 Event Types Tested:${NC}"
echo "  • order-created → Order Processor Lambda"
echo "  • user-registered → User Processor Lambda"
echo "  • notification-sent → Notification Processor Lambda"
echo "  • support-ticket → Support Processor Lambda"
echo "  • analytics-event → Analytics Processor Lambda"
echo "  • invalid-event → No Lambda (filtered out)"
echo ""
echo -e "${YELLOW}🔍 To view Lambda logs:${NC}"
echo "aws logs describe-log-groups --log-group-name-prefix '/aws/lambda/apigw-eventbridge-lambda-demo' --region $AWS_REGION"
echo ""
echo -e "${YELLOW}📝 To view specific Lambda logs:${NC}"
echo "aws logs tail /aws/lambda/apigw-eventbridge-lambda-demo-order-processor --region $AWS_REGION --since 1h"
echo "aws logs tail /aws/lambda/apigw-eventbridge-lambda-demo-user-processor --region $AWS_REGION --since 1h"
echo "aws logs tail /aws/lambda/apigw-eventbridge-lambda-demo-notification-processor --region $AWS_REGION --since 1h"
echo "aws logs tail /aws/lambda/apigw-eventbridge-lambda-demo-support-processor --region $AWS_REGION --since 1h"
echo "aws logs tail /aws/lambda/apigw-eventbridge-lambda-demo-analytics-processor --region $AWS_REGION --since 1h"
echo ""
echo -e "${YELLOW}📡 To view EventBridge events:${NC}"
echo "aws events list-events --event-bus-name default --region $AWS_REGION"
