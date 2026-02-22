// SubscriptionStatusScreen.dart (Updated)
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/models/UserProfile.dart';
import 'package:abokamall/helpers/CustomSnackBar.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:abokamall/services/PaymentService.dart';

class SubscriptionStatusScreen extends StatefulWidget {
  final UserProfile userProfile;

  const SubscriptionStatusScreen({super.key, required this.userProfile});

  @override
  State<SubscriptionStatusScreen> createState() =>
      _SubscriptionStatusScreenState();
}

class _SubscriptionStatusScreenState extends State<SubscriptionStatusScreen> {
  bool _isOnline = true;
  bool _isGracePassed = false; // ✅ NEW
  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _checkInitialConnectivity();
    _checkOfflineStatus(); // ✅ NEW
    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivityStream.listen(_onConnectivityChanged);
  }

  Future<void> _checkOfflineStatus() async {
    final gracePassed = await getIt<TokenService>().mustCheckOnline();
    if (mounted) {
      setState(() {
        _isGracePassed = gracePassed;
      });
    }
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    if (mounted) {
      setState(() => _isOnline = result != ConnectivityResult.none);
    }
  }

  void _onConnectivityChanged(ConnectivityResult result) async {
    if (mounted) {
      final isOnline = result != ConnectivityResult.none;
      if (isOnline && !_isOnline) {
        // Just reconnected
        await _checkOfflineStatus();
      }
      setState(() => _isOnline = isOnline);
    }
  }

  Future<void> _handlePaymentTap(
    BuildContext context,
    String paymentMethod,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const AlertDialog(
        title: Text(
          'جاري إعداد عملية الدفع...',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        content: SizedBox(
          height: 50,
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
    );

    try {
      final token = await getIt<TokenService>().getAccessToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final paymentData = await PaymentService.initiateSubscriptionPayment(
        paymentMethod: paymentMethod,
        authToken: token,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();

      if (paymentData != null && paymentData['paymentLink'] != null) {
        final paymentLink = paymentData['paymentLink'] as String;
        final paymentId = paymentData['paymentId'] as int;

        print('✅ Payment initiated with ID: $paymentId');
        print('🔗 Payment Link: $paymentLink');

        if (context.mounted) {
          Navigator.of(context).pushNamed(
            '/payment-webview',
            arguments: {'paymentLink': paymentLink, 'paymentId': paymentId},
          );
        }
      } else {
        if (context.mounted) {
          CustomSnackBar.show(
            context,
            message: 'فشل في إعداد عملية الدفع',
            type: SnackBarType.error,
          );
        }
      }
    } catch (e) {
      print('❌ Error initiating payment: $e');
      if (context.mounted) {
        Navigator.of(context).pop();
        CustomSnackBar.show(
          context,
          message: 'خطأ: $e',
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);

    DateTime start = _parseDate(widget.userProfile.subscription!.startDate);
    DateTime end = _parseDate(widget.userProfile.subscription!.endDate);
    DateTime now = DateTime.now();

    double progress = 0.0;
    String statusText = '';
    Color statusColor = Colors.grey;

    int totalDays = end.difference(start).inDays;
    int daysPassed = now.difference(start).inDays;

    if (totalDays > 0) {
      progress = (daysPassed / totalDays).clamp(0.0, 1.0);
    }

    if (now.isAfter(end)) {
      int graceRemaining = 1 - now.difference(end).inDays;
      if (graceRemaining >= 0) {
        statusText = 'فترة سماح (يوم واحد)';
        statusColor = Colors.orange;
        progress = 1.0;
      } else {
        statusText = 'انتهى الاشتراك';
        statusColor = Colors.red;
        progress = 1.0;
      }
    } else {
      statusText = 'نشط';
      statusColor = Colors.green;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'حالة الاشتراك',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CustomPaint(
                      painter: SubscriptionMeterPainter(
                        progress: progress,
                        color: statusColor,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        'من الوقت المنقضي',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            const SizedBox(height: 48),
            _buildDetailRow(
              'تاريخ البدء',
              _formatDate(widget.userProfile.subscription!.startDate),
            ),

            const Divider(height: 32),
            _buildDetailRow(
              'تاريخ الانتهاء',
              _formatDate(widget.userProfile.subscription!.endDate),
            ),
            const Divider(height: 32),

            _buildDetailRow(
              'اخر تحديث',
              _formatDate(widget.userProfile.subscription!.updatedAt),
            ),
            /*
            const SizedBox(height: 60),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'تجديد الاشتراك عبر:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildPaymentButton(
                    label: 'محفظة موبايل',
                    icon: Icons.phone_android,
                    color: _isOnline ? Colors.red : Colors.grey,
                    onTap: _isOnline
                        ? () => _handlePaymentTap(context, 'MobileWallet')
                        : (_isGracePassed
                              ? () {
                                  CustomSnackBar.show(
                                    context,
                                    message:
                                        'يجب الاتصال بالإنترنت لإتمام عملية الدفع',
                                    type: SnackBarType.warning,
                                  );
                                }
                              : null),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildPaymentButton(
                    label: 'بطاقة ائتمان',
                    icon: Icons.credit_card,
                    color: _isOnline ? primary : Colors.grey,
                    onTap: _isOnline
                        ? () => _handlePaymentTap(context, 'CreditCard')
                        : (_isGracePassed
                              ? () {
                                  CustomSnackBar.show(
                                    context,
                                    message:
                                        'يجب الاتصال بالإنترنت لإتمام عملية الدفع',
                                    type: SnackBarType.warning,
                                  );
                                }
                              : null),
                  ),
                ),
              ],
            ),
            */
            if (!_isOnline)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _isGracePassed
                      ? 'يجب الاتصال بالإنترنت لتحديث حالة الدفع'
                      : 'يرجى الاتصال بالإنترنت لتتمكن من التجديد',
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  DateTime _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      return DateTime.now();
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
          color: color.withOpacity(0.05),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubscriptionMeterPainter extends CustomPainter {
  final double progress;
  final Color color;

  SubscriptionMeterPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 15.0;

    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

String _formatDate(String dateStr) {
  try {
    final date = DateTime.parse(dateStr);
    // Return yyyy-mm-dd
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  } catch (e) {
    return dateStr;
  }
}
