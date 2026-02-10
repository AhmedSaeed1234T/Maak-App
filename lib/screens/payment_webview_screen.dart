import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Add this import for Android
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Add this import for iOS
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:abokamall/services/PaymentService.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentLink;
  final int paymentId;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentLink,
    required this.paymentId,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isPolling = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    // Platform-specific initialization
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
            _checkPaymentCompletion(url);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            print('Web Resource Error: ${error.description}');
            setState(() => _hasError = true);
          },
          onNavigationRequest: (NavigationRequest request) {
            _checkPaymentCompletion(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentLink));

    // Platform-specific settings for Android
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }

    _webViewController = controller;
  }

  void _checkPaymentCompletion(String url) {
    print('Navigation URL: $url');

    if (url.contains('webhook') ||
        url.contains('success') ||
        url.contains('failure')) {
      if (!_isPolling) {
        _isPolling = true;
        _verifyPaymentStatus();
      }
    }
  }

  Future<void> _verifyPaymentStatus() async {
    print('🔍 Verifying payment status...');

    final token = await getIt<TokenService>().getAccessToken();
    if (token == null) {
      _handlePaymentFailure('Authentication failed');
      return;
    }

    final status = await PaymentService.pollPaymentStatus(
      widget.paymentId,
      token,
      maxAttempts: 5,
      interval: const Duration(seconds: 3),
    );

    if (!mounted) return;

    if (status != null) {
      final paymentStatus = status['status'] as String?;

      if (PaymentService.isPaymentSuccessful(paymentStatus)) {
        await getIt<TokenService>().refreshAccessToken();

        _handlePaymentSuccess(status);
      } else if (PaymentService.isPaymentFailed(paymentStatus)) {
        _handlePaymentFailure(status['errorMessage'] ?? 'Payment failed');
      } else {
        _handlePaymentFailure('Payment status unknown');
      }
    } else {
      _handlePaymentFailure('Could not verify payment status');
    }
  }

  void _handlePaymentSuccess(Map<String, dynamic> status) {
    print('✅ Payment successful');
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
        '/payment_success',
        arguments: {
          'paymentId': widget.paymentId,
          'amount': status['amount'],
          'status': status,
        },
      );
    }
  }

  void _handlePaymentFailure(String error) {
    print('❌ Payment failed: $error');

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(
        '/payment_failure',
        arguments: {'paymentId': widget.paymentId, 'error': error},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isPolling) {
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'عملية الدفع',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Stack(
          children: [
            if (!_hasError)
              WebViewWidget(controller: _webViewController)
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'حدث خطأ في تحميل صفحة الدفع',
                      style: TextStyle(fontFamily: 'Cairo', fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('العودة'),
                    ),
                  ],
                ),
              ),
            if (_isLoading || _isPolling)
              Container(
                color: Colors.white.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      if (_isPolling) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'جاري التحقق من حالة الدفع...',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
