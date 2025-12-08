import 'package:abokamall/helpers/TokenService.dart';
import 'package:flutter/material.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';

class OfflineModeTestingPanel extends StatefulWidget {
  const OfflineModeTestingPanel({super.key});

  @override
  State<OfflineModeTestingPanel> createState() =>
      _OfflineModeTestingPanelState();
}

class _OfflineModeTestingPanelState extends State<OfflineModeTestingPanel> {
  final tokenService = getIt<TokenService>();
  String _status = "جاهز للاختبار";
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة اختبار الوضع غير المتصل'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 32,
                    ),
                  const SizedBox(height: 12),
                  Text(
                    _status,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Test 1: Show Current State
            _buildTestCard(
              title: 'عرض الحالة الحالية',
              description: 'يعرض معلومات مفصلة عن الجلسة والتوكن',
              buttonText: 'عرض الحالة',
              color: Colors.green,
              onPressed: _showCurrentState,
            ),

            const SizedBox(height: 16),

            // Test 2: Simulate 1 Day Offline
            _buildTestCard(
              title: 'محاكاة يوم واحد بدون اتصال',
              description: 'يجب أن يعمل التطبيق بشكل طبيعي',
              buttonText: 'محاكاة يوم واحد',
              color: Colors.blue,
              onPressed: () => _simulateOfflineDays(1),
            ),

            const SizedBox(height: 16),

            // Test 3: Simulate 2+ Days Offline
            _buildTestCard(
              title: 'محاكاة يومين+ بدون اتصال',
              description: 'يجب أن يظهر حوار "يجب الاتصال"',
              buttonText: 'محاكاة يومين',
              color: Colors.red,
              onPressed: () => _simulateOfflineDays(3),
              isWarning: true,
            ),

            const SizedBox(height: 16),

            // Test 4: Expire Tokens
            _buildTestCard(
              title: 'إنهاء صلاحية التوكن',
              description: 'يجب أن يتم تسجيل الخروج تلقائيًا',
              buttonText: 'إنهاء صلاحية التوكن',
              color: Colors.orange,
              onPressed: _expireTokens,
            ),

            const SizedBox(height: 16),

            // Test 5: Reset Everything
            _buildTestCard(
              title: 'إعادة تعيين كل شيء',
              description: 'مسح جميع البيانات المؤقتة',
              buttonText: 'إعادة تعيين',
              color: Colors.grey,
              onPressed: _resetEverything,
            ),

            const SizedBox(height: 24),

            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'تعليمات الاختبار:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '📱 لاختبار الوضع غير المتصل (يومين+):\n'
                    '1. اضغط "محاكاة يومين"\n'
                    '2. قم بتفعيل وضع الطيران\n'
                    '3. انتقل إلى أي صفحة\n'
                    '4. يجب أن ترى حوار "يجب الاتصال"\n\n'
                    '✅ لاختبار الوضع غير المتصل (يوم واحد):\n'
                    '1. اضغط "محاكاة يوم واحد"\n'
                    '2. قم بتفعيل وضع الطيران\n'
                    '3. انتقل إلى صفحات مختلفة\n'
                    '4. يجب أن يعمل التطبيق بشكل طبيعي',
                    style: TextStyle(height: 1.5),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCard({
    required String title,
    required String description,
    required String buttonText,
    required Color color,
    required VoidCallback onPressed,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning ? Colors.red.shade200 : Colors.grey.shade300,
          width: isWarning ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // Test 1: Show Current State
  Future<void> _showCurrentState() async {
    setState(() {
      _isLoading = true;
      _status = "جاري تحميل الحالة...";
    });

    try {
      final hasToken = await tokenService.getRefreshToken();
      final expiry = await tokenService.getRefreshTokenExpiry();
      final isValid = await tokenService.isRefreshTokenLocallyValid();

      final lastCheckStr = await tokenService.storage.read(
        key: TokenService.lastOnlineCheckKey,
      );
      DateTime? lastCheckTime;
      if (lastCheckStr != null) {
        try {
          lastCheckTime = DateTime.parse(lastCheckStr);
        } catch (e) {}
      }

      final timeSinceCheck = lastCheckTime != null
          ? DateTime.now().difference(lastCheckTime)
          : null;

      final mustCheckOnline = await tokenService.mustCheckOnline();

      setState(() {
        _status =
            '''
📊 الحالة الحالية:
━━━━━━━━━━━━━━━━━━━━

🔑 يوجد توكن: ${hasToken != null ? '✅ نعم' : '❌ لا'}

📅 انتهاء التوكن:
${expiry?.toLocal().toString() ?? '❌ غير موجود'}

✓ صالح محليًا: ${isValid ? '✅ نعم' : '❌ لا'}

🌐 آخر فحص عبر الإنترنت:
${lastCheckTime?.toLocal().toString() ?? '❌ أبدًا'}

⏱️ الوقت منذ الفحص:
${timeSinceCheck != null ? '${timeSinceCheck.inDays} يوم، ${timeSinceCheck.inHours % 24} ساعة' : '❌ غير متوفر'}

⚠️ يجب الفحص عبر الإنترنت:
${mustCheckOnline ? '🚨 نعم (تجاوز يومين)' : '✅ لا'}
        ''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = "❌ خطأ: $e";
        _isLoading = false;
      });
    }
  }

  // Test 2 & 3: Simulate Offline Days
  Future<void> _simulateOfflineDays(int days) async {
    setState(() {
      _isLoading = true;
      _status = "جاري محاكاة $days يوم بدون اتصال...";
    });

    try {
      // Set last online check to X days ago
      final pastTime = DateTime.now().subtract(Duration(days: days));
      await tokenService.storage.write(
        key: TokenService.lastOnlineCheckKey,
        value: pastTime.toIso8601String(),
      );

      // Clear in-memory cache
      tokenService.lastOnlineCheck = null;

      setState(() {
        _status =
            '''
✅ تم تعيين آخر فحص إلى: قبل $days يوم

📱 الآن قم بما يلي:

${days >= 2 ? '''
⚠️ اختبار تجاوز المدة:
1️⃣ قم بتفعيل وضع الطيران
2️⃣ انتقل إلى أي صفحة
3️⃣ يجب أن ترى حوار "يجب الاتصال بالإنترنت"
4️⃣ لن تستطيع استخدام التطبيق حتى تتصل بالإنترنت
''' : '''
✅ اختبار عمل التطبيق بدون اتصال:
1️⃣ قم بتفعيل وضع الطيران
2️⃣ انتقل إلى صفحات مختلفة
3️⃣ يجب أن يعمل التطبيق بشكل طبيعي
4️⃣ قد ترى رسالة "وضع عدم الاتصال"
'''}
        ''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = "❌ خطأ: $e";
        _isLoading = false;
      });
    }
  }

  // Test 4: Expire Tokens
  Future<void> _expireTokens() async {
    setState(() {
      _isLoading = true;
      _status = "جاري إنهاء صلاحية التوكن...";
    });

    try {
      // Set expiry to yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await tokenService.storage.write(
        key: TokenService.refreshExpiryKey,
        value: yesterday.toIso8601String(),
      );

      // Clear in-memory cache
      tokenService.refreshExpiry = null;

      setState(() {
        _status = '''
✅ تم تعيين التوكن كمنتهي الصلاحية (أمس)

📱 الآن:
انتقل إلى أي صفحة لاختبار تسجيل الخروج التلقائي

المتوقع:
- رسالة: "انتهت صلاحية جلستك"
- الانتقال إلى شاشة تسجيل الدخول
        ''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = "❌ خطأ: $e";
        _isLoading = false;
      });
    }
  }

  // Test 5: Reset Everything
  Future<void> _resetEverything() async {
    setState(() {
      _isLoading = true;
      _status = "جاري إعادة التعيين...";
    });

    try {
      // Clear in-memory cache
      tokenService.lastOnlineCheck = null;

      // Reset last online check to now
      await tokenService.storage.write(
        key: TokenService.lastOnlineCheckKey,
        value: DateTime.now().toIso8601String(),
      );

      setState(() {
        _status = '''
✅ تم إعادة تعيين كل شيء!

تم:
- مسح البيانات المؤقتة
- إعادة تعيين آخر فحص عبر الإنترنت إلى الآن
- يمكنك الآن البقاء بدون اتصال لمدة يومين

ملاحظة: التوكن لم يتم حذفه
        ''';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = "❌ خطأ: $e";
        _isLoading = false;
      });
    }
  }
}
