import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:abokamall/helpers/apiroute.dart';

class PaymentService {
  /// Initiate a subscription payment (Credit Card or Mobile Wallet)
  /// Uses query parameter for payment method
  /// Returns payment link and payment ID
  static Future<Map<String, dynamic>?> initiateSubscriptionPayment({
    required String paymentMethod, // 'CreditCard' or 'MobileWallet'
    required String authToken,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      };

      final response = await http.post(
        Uri.parse('$apiRoute/payment/subscribe?paymentMethod=$paymentMethod'),
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Failed to initiate payment: ${response.statusCode}');
        print('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error initiating payment: $e');
      return null;
    }
  }

  /// Get payment status by payment ID
  /// Requires authentication
  static Future<Map<String, dynamic>?> getPaymentStatus(
    int paymentId,
    String authToken,
  ) async {
    try {
      final headers = {'Authorization': 'Bearer $authToken'};

      final response = await http.get(
        Uri.parse('$apiRoute/payment/status/$paymentId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Failed to get payment status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error getting payment status: $e');
      return null;
    }
  }

  /// Poll payment status until it's completed or failed
  /// Useful for checking payment status after WebView returns
  static Future<Map<String, dynamic>?> pollPaymentStatus(
    int paymentId,
    String authToken, {
    int maxAttempts = 30,
    Duration interval = const Duration(seconds: 2),
  }) async {
    for (int i = 0; i < maxAttempts; i++) {
      final status = await getPaymentStatus(paymentId, authToken);

      if (status != null) {
        final paymentStatus = status['status'] as String?;

        if (paymentStatus == 'Success' || paymentStatus == 'Failed') {
          return status;
        }
      }

      if (i < maxAttempts - 1) {
        await Future.delayed(interval);
      }
    }

    return await getPaymentStatus(paymentId, authToken);
  }

  /// Parse payment status string to boolean
  static bool isPaymentSuccessful(String? status) {
    return status?.toLowerCase() == 'success';
  }

  /// Parse payment status string to boolean for failure
  static bool isPaymentFailed(String? status) {
    return status?.toLowerCase() == 'failed';
  }

  /// Parse payment status string to boolean for processing
  static bool isPaymentProcessing(String? status) {
    return status?.toLowerCase() == 'processing';
  }

  /// Parse payment status string to boolean for pending
  static bool isPaymentPending(String? status) {
    return status?.toLowerCase() == 'pending';
  }
}
