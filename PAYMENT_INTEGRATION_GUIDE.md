# Payment Integration Guide

## Overview
This payment system integrates a central payment service with your Flutter mobile app. It handles payment processing through an iframe-based payment gateway with proper success/failure routing.

## Components

### 1. **PaymentService** (`lib/services/PaymentService.dart`)
Central service for all payment operations. Key methods:

```dart
// Initiate a payment
final payment = await PaymentService.initiatePayment(
  userId: 'user123',
  amount: 99.99,
  paymentMethod: 'credit_card', // or 'vodafone_cash'
  authToken: token,
);

// Get payment status
final status = await PaymentService.getPaymentStatus(paymentId);

// Poll for payment completion (useful after WebView closes)
final finalStatus = await PaymentService.pollPaymentStatus(paymentId);

// Create subscription renewal payment
final renewal = await PaymentService.createSubscriptionRenewal(
  userId: 'user123',
  amount: 99.99,
  paymentMethod: 'credit_card',
);

// Helper methods
bool isSuccessful = PaymentService.isPaymentSuccessful(status['status']);
bool isFailed = PaymentService.isPaymentFailed(status['status']);
bool isProcessing = PaymentService.isPaymentProcessing(status['status']);
```

### 2. **PaymentWebViewScreen** (`lib/screens/payment_webview_screen.dart`)
Handles the iframe-based payment gateway. Features:

- Opens payment iframe in a WebView
- Monitors URL changes to detect payment success/failure
- Polls backend to verify payment status
- Auto-navigates to success/failure screens
- Handles WebView errors gracefully

### 3. **Updated Subscription Status Screen** (`lib/screens/subscription_status_screen.dart`)
Integrated payment buttons that:

- Initiate payment through PaymentService
- Navigate to PaymentWebViewScreen
- Support multiple payment methods (Vodafone Cash, Credit Card)
- Show loading states during payment initialization

### 4. **Payment Success/Failure Screens**
Updated to accept payment details:

```dart
// Success Screen
PaymentSuccessScreen(
  paymentId: 123,
  userId: 'user123',
  amount: 99.99,
)

// Failure Screen  
PaymentFailureScreen(
  paymentId: 123,
  userId: 'user123',
  amount: 99.99,
  error: 'Payment declined',
)
```

## Payment Flow

```
1. User clicks payment button on SubscriptionStatusScreen
   ↓
2. PaymentService.initiatePayment() creates payment transaction
   ↓
3. Navigate to PaymentWebViewScreen with paymentId
   ↓
4. Payment iframe loads in WebView
   ↓
5. User completes payment in iframe
   ↓
6. Iframe redirects to success/failure URL
   ↓
7. PaymentWebViewScreen detects URL change
   ↓
8. Poll backend to verify payment status
   ↓
9. Navigate to PaymentSuccessScreen or PaymentFailureScreen
   ↓
10. User can continue or retry
```

## Backend Integration

Your backend should expose these endpoints:

### 1. Initiate Payment
```
POST /api/v1/payment/initiate
Headers: Content-Type: application/json
         Authorization: Bearer {token} (optional)

Request:
{
  "userId": "user123",
  "amount": 99.99,
  "paymentMethod": "credit_card",
  "description": "Subscription Renewal"
}

Response:
{
  "id": 123,
  "status": "Processing",
  "paymentMethod": "credit_card",
  "amount": 99.99,
  "userId": "user123"
}
```

### 2. Get Payment Iframe
```
GET /api/v1/payment/iframe/{paymentId}

Response: HTML page containing iframe with payment gateway
```

### 3. Get Payment Status
```
GET /api/v1/payment/status/{paymentId}

Response:
{
  "paymentId": 123,
  "status": "Success",  // "Success", "Failed", "Processing"
  "amount": 99.99,
  "paymentMethod": "credit_card",
  "createdAt": "2024-01-22T10:30:00Z",
  "processedAt": "2024-01-22T10:31:00Z",
  "userId": "user123",
  "errorMessage": null
}
```

### 4. Webhook (Optional)
```
POST /api/v1/payment/webhook
(Receives callbacks from payment gateway)
```

## Setup Instructions

### 1. Add Route Registration
In your main.dart or router, add:

```dart
routes: {
  '/payment-webview': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return PaymentWebViewScreen(
      paymentId: args?['paymentId'] ?? 0,
      userId: args?['userId'] ?? '',
      amount: args?['amount'] ?? 0.0,
    );
  },
  '/payment-success': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return PaymentSuccessScreen(
      paymentId: args?['paymentId'],
      userId: args?['userId'],
      amount: args?['amount'],
    );
  },
  '/payment-failure': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    return PaymentFailureScreen(
      paymentId: args?['paymentId'],
      userId: args?['userId'],
      amount: args?['amount'],
      error: args?['error'],
    );
  },
  '/dashboard': (context) => DashboardScreen(),
  // ... other routes
},
```

### 2. Add WebView Dependency
In pubspec.yaml:

```yaml
dependencies:
  webview_flutter: ^4.2.0
```

### 3. Update User ID Reference
In `subscription_status_screen.dart`, replace:

```dart
final userId = 'USER_ID_HERE'; // Get from authentication/app state
```

With actual user ID from your authentication/app state management:

```dart
final userId = AuthService.getCurrentUserId(); // or from Provider/GetX/etc.
```

### 4. Update Amount (if needed)
Replace the hardcoded amount:

```dart
final amount = 99.99; // Subscription amount
```

With dynamic amount based on your subscription data.

## Error Handling

The system handles:

- ✅ Network errors during payment initiation
- ✅ WebView loading errors
- ✅ Payment processing errors
- ✅ Timeout errors (auto-retry with polling)
- ✅ User cancellation

## Security Notes

1. Never store payment tokens in the app
2. Always verify payment status on backend
3. Use HTTPS for all payment communications
4. Implement CSRF protection on backend
5. Validate amount and userId on backend
6. Log all payment transactions for audit

## Testing

### Test Payment Flow:
1. Navigate to subscription status screen
2. Click payment button
3. System initiates payment and opens WebView
4. Complete payment in test mode
5. Verify success/failure screens are displayed

### Debug Payment Status:
```dart
// Add in PaymentService calls
print('Payment Response: $paymentData');
print('Payment Status: $status');
```

## Troubleshooting

### Payment not starting
- Check userId is not empty
- Verify amount is valid
- Check network connectivity
- Verify backend endpoint is accessible

### WebView not loading iframe
- Check iframe URL is correct
- Verify HTTPS certificate
- Check browser settings in WebView
- Review WebView logs

### Payment status not updating
- Check polling interval (default: 2 seconds)
- Check max attempts (default: 30)
- Verify backend status endpoint
- Check backend payment processing

### Navigation not working
- Verify route names match exactly
- Check arguments are passed correctly
- Verify mounted check before navigation
- Check context is valid

## Future Enhancements

- [ ] Apple Pay integration
- [ ] Google Pay integration
- [ ] Biometric payment confirmation
- [ ] Payment history screen
- [ ] Multiple currency support
- [ ] Saved payment methods
- [ ] Subscription management dashboard
