import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:flutter/material.dart';

class TestingPanel extends StatefulWidget {
  final TokenService tokenService = getIt<TokenService>();

  TestingPanel({super.key});

  @override
  State<TestingPanel> createState() => _TestingPanelState();
}

class _TestingPanelState extends State<TestingPanel> {
  String _status = "جاهز للاختبار";
  bool _isLoading = false;

  void _setStatus(String status) {
    setState(() {
      _status = status;
      _isLoading = false;
    });
  }

  void _setLoading(String status) {
    setState(() {
      _status = status;
      _isLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة الاختبار'),
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
            const Divider(),
            const SizedBox(height: 16),

            // Test 1: Cache Test
            _buildTestSection(
              title: 'اختبار 1: التخزين المؤقت (5 مرات سريعة)',
              description:
                  'يجب أن يكون هناك استدعاء API واحد فقط، والباقي من الذاكرة',
              buttonText: 'تشغيل اختبار التخزين المؤقت',
              buttonColor: Colors.blue,
              onPressed: _runCacheTest,
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Test 2: Force Validation
            _buildTestSection(
              title: 'اختبار 2: فرض التحقق',
              description:
                  'يفرض التحقق عبر الإنترنت حتى لو كان التخزين المؤقت صالحًا',
              buttonText: 'فرض التحقق عبر الإنترنت',
              buttonColor: Colors.orange,
              onPressed: _runForceValidation,
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Test 3: Simulate Max Offline
            _buildTestSection(
              title: 'اختبار 3: محاكاة تجاوز المدة (يومين)',
              description: 'يحاكي مرور أكثر من يومين بدون اتصال',
              buttonText: 'محاكاة تجاوز المدة القصوى',
              buttonColor: Colors.red,
              onPressed: _runMaxOfflineTest,
              warning: true,
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Test 4: Show Current State
            _buildTestSection(
              title: 'اختبار 4: عرض الحالة الحالية',
              description: 'يعرض معلومات مفصلة عن الجلسة الحالية',
              buttonText: 'عرض الحالة الحالية',
              buttonColor: Colors.green,
              onPressed: _showCurrentState,
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Test 5: Expire Tokens
            _buildTestSection(
              title: 'اختبار 5: إنهاء صلاحية الرموز',
              description: 'يجعل الرموز منتهية الصلاحية للاختبار',
              buttonText: 'إنهاء صلاحية الرموز يدويًا',
              buttonColor: Colors.deepOrange,
              onPressed: _expireTokens,
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // Test 6: Clear Cache
            _buildTestSection(
              title: 'اختبار 6: مسح التخزين المؤقت',
              description: 'يمسح جميع البيانات المؤقتة',
              buttonText: 'مسح جميع البيانات المؤقتة',
              buttonColor: Colors.grey,
              onPressed: _clearCache,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
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
                  const SizedBox(height: 12),
                  const Text(
                    '1. قم بتشغيل كل اختبار بالترتيب\n'
                    '2. تحقق من سجلات وحدة التحكم للحصول على التفاصيل\n'
                    '3. راقب رسائل Snackbar والحوارات\n'
                    '4. استخدم "عرض الحالة" لتصحيح الأخطاء',
                    style: TextStyle(height: 1.5),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: const Text(
                      '⚠️ لاختبار تجاوز المدة القصوى:\n'
                      '  • قم بتشغيل الاختبار 3\n'
                      '  • قم بتفعيل وضع الطيران\n'
                      '  • انتقل إلى أي صفحة\n'
                      '  • يجب أن ترى حوار "يجب الاتصال"',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red,
                        height: 1.5,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection({
    required String title,
    required String description,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onPressed,
    bool warning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: warning ? Colors.red.shade200 : Colors.grey.shade300,
          width: warning ? 2 : 1,
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
              backgroundColor: buttonColor,
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

  // Test 1: Cache Test
  Future<void> _runCacheTest() async {
    _setLoading("جاري تشغيل اختبار التخزين المؤقت...");

    try {
      final results = <String>[];

      for (int i = 1; i <= 5; i++) {
        final result = await widget.tokenService.checkSessionValidity();
        results.add("المحاولة $i: ${result.reason}");
        debugPrint("Test attempt $i: ${result.reason}");
        await Future.delayed(const Duration(milliseconds: 500));
      }

      _setStatus(
        "✅ اكتمل اختبار التخزين المؤقت!\n\n"
        "تحقق من وحدة التحكم للحصول على التفاصيل.\n\n"
        "المتوقع: المحاولة الأولى = API، الباقي = مخزن مؤقت\n\n"
        "${results.join('\n')}",
      );
    } catch (e) {
      _setStatus("❌ خطأ: $e");
    }
  }

  // Test 2: Force Validation
  Future<void> _runForceValidation() async {
    _setLoading("جاري فرض التحقق...");

    try {
      final result = await widget.tokenService.checkSessionValidity(
        forceValidation: true,
      );

      _setStatus(
        "نتيجة فرض التحقق:\n\n"
        "✅ صالح: ${result.isValid}\n"
        "📝 السبب: ${result.reason}\n"
        "🔓 يتطلب تسجيل الدخول: ${result.requiresLogin}\n"
        "📵 وضع عدم الاتصال: ${result.isOfflineMode}",
      );
    } catch (e) {
      _setStatus("❌ خطأ: $e");
    }
  }

  // Test 3: Simulate Max Offline
  Future<void> _runMaxOfflineTest() async {
    _setLoading("جاري محاكاة تجاوز المدة...");

    try {
      // Set last check to 2 days + 1 hour ago (exceeds 2 days limit)
      final pastTime = DateTime.now().subtract(
        const Duration(days: 2, hours: 1),
      );
      await widget.tokenService.storage.write(
        key: 'last_online_check',
        value: pastTime.toIso8601String(),
      );

      // Clear in-memory cache to force reload from storage
      widget.tokenService.lastOnlineCheck = null;

      _setStatus(
        "✅ تم تعيين آخر فحص إلى: قبل يومين وساعة\n\n"
        "📱 الآن قم بما يلي:\n\n"
        "1️⃣ قم بتفعيل وضع الطيران\n"
        "2️⃣ انتقل إلى أي صفحة\n"
        "3️⃣ يجب أن ترى حوار 'يجب الاتصال بالإنترنت'\n\n"
        "⚠️ إذا لم تفعل وضع الطيران، سيتم التحديث بنجاح!",
      );
    } catch (e) {
      _setStatus("❌ خطأ: $e");
    }
  }

  // Test 4: Show Current State
  Future<void> _showCurrentState() async {
    _setLoading("جاري تحميل الحالة...");

    try {
      final hasToken = await widget.tokenService.getRefreshToken();
      final expiry = await widget.tokenService.getRefreshTokenExpiry();
      final isValid = await widget.tokenService.isRefreshTokenLocallyValid();

      // Load last online check from storage
      final lastCheckStr = await widget.tokenService.storage.read(
        key: 'last_online_check',
      );
      DateTime? lastCheckTime;
      if (lastCheckStr != null) {
        try {
          lastCheckTime = DateTime.parse(lastCheckStr);
        } catch (e) {
          debugPrint('Error parsing last online check: $e');
        }
      }

      final timeSinceCheck = lastCheckTime != null
          ? DateTime.now().difference(lastCheckTime)
          : null;

      final mustCheckOnline =
          timeSinceCheck != null && timeSinceCheck > const Duration(days: 2);

      _setStatus(
        "📊 الحالة الحالية:\n"
        "━━━━━━━━━━━━━━━━━━━━\n\n"
        "🔑 يوجد رمز: ${hasToken != null ? '✅ نعم' : '❌ لا'}\n\n"
        "📅 انتهاء الرمز:\n${expiry?.toString() ?? '❌ غير موجود'}\n\n"
        "✓ صالح محليًا: ${isValid ? '✅ نعم' : '❌ لا'}\n\n"
        "🕐 آخر تحقق:\n${widget.tokenService.lastValidationTime?.toString() ?? '❌ أبدًا'}\n\n"
        "🌐 آخر فحص عبر الإنترنت:\n${lastCheckTime?.toString() ?? '❌ أبدًا'}\n\n"
        "⏱️ الوقت منذ الفحص:\n${timeSinceCheck != null ? '${timeSinceCheck.inDays} يوم، ${timeSinceCheck.inHours % 24} ساعة' : '❌ غير متوفر'}\n\n"
        "⚠️ يجب الفحص عبر الإنترنت:\n${mustCheckOnline ? '🚨 نعم (تجاوز يومين)' : '✅ لا'}",
      );
    } catch (e) {
      _setStatus("❌ خطأ: $e");
    }
  }

  // Test 5: Expire Tokens
  Future<void> _expireTokens() async {
    _setLoading("جاري إنهاء صلاحية الرموز...");

    try {
      // Set expiry to yesterday
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await widget.tokenService.storage.write(
        key: 'refresh_expiry',
        value: yesterday.toIso8601String(),
      );

      // Clear in-memory cache
      widget.tokenService.refreshExpiry = null;

      _setStatus(
        "✅ تم تعيين الرمز كمنتهي الصلاحية (أمس).\n\n"
        "📱 الآن:\n"
        "انتقل إلى أي صفحة لاختبار تسجيل الخروج التلقائي.\n\n"
        "المتوقع:\n"
        "• رسالة: 'انتهت صلاحية جلستك'\n"
        "• الانتقال إلى شاشة تسجيل الدخول",
      );
    } catch (e) {
      _setStatus("❌ خطأ: $e");
    }
  }

  // Test 6: Clear Cache
  Future<void> _clearCache() async {
    _setLoading("جاري مسح البيانات المؤقتة...");

    try {
      // Clear in-memory cache
      widget.tokenService.lastValidationTime = null;
      widget.tokenService.lastValidationResult = null;
      widget.tokenService.lastOnlineCheck = null;

      // Clear storage
      await widget.tokenService.storage.delete(key: 'last_online_check');

      _setStatus(
        "✅ تم مسح جميع البيانات المؤقتة!\n\n"
        "التحقق التالي سيكون جديدًا تمامًا.\n\n"
        "ملاحظة: الرموز لم يتم حذفها،\n"
        "تم مسح البيانات المؤقتة فقط.",
      );
    } catch (e) {
      _setStatus("❌ خطأ: $e");
    }
  }
}
