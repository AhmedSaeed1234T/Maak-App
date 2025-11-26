import 'package:abokamall/helpers/OpenWhatsapp.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod;
  String? _paymentPhone = '';
  bool paymentIsAllowed = false;
  Future<void> _showPaymentDialog(String method) async {
    String phone = '';
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            method == 'vodafone_cash'
                ? 'بيانات فودافون كاش'
                : 'بيانات إنستا باي',
          ),
          content: TextField(
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'رقم الهاتف'),
            onChanged: (v) => phone = v,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _paymentPhone = phone;
                  _selectedPaymentMethod = method;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم حفظ بيانات الدفع: $phone')),
                );
              },
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'خيارات الدفع',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.credit_card,
                color: Colors.white,
                size: 35,
              ),
            ),
            const SizedBox(height: 20),
            if (paymentIsAllowed) ...[
              const Text(
                'طرق الدفع المتاحة',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'اختر طريقة دفع مفضلة لتحديث اشتراكك',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 28),
              // Payment Options
              _buildPaymentOption(
                title: 'الدفع بفودافون كاش',
                subtitle: 'سيتم تجديد اشتراكك خلال 24 ساعة',
                value: 'vodafone_cash',
                icon: Icons.phone_android,
                onTap: () => _showPaymentDialog('vodafone_cash'),
              ),
              const SizedBox(height: 16),
              _buildPaymentOption(
                title: 'الدفع بإنستا باي',
                subtitle: 'سيتم تجديد اشتراكك خلال 24 ساعة',
                value: 'instapay',
                icon: Icons.credit_card,
                onTap: () => _showPaymentDialog('instapay'),
              ),
            ] else ...[
              Text(
                "طرق الدفع غير متاحة في النسخة الحالية من التطبيق, انتظرونا في تحديثات مستقبلية",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 30,
                ),
              ),
            ],
            const SizedBox(height: 32),
            // Customer Service Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.support_agent, size: 22),
                label: const Text(
                  'تواصل مع خدمة العملاء عبر واتساب',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                onPressed: () async => await openWhatsapp(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Info Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withOpacity(0.3), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'بيانات الدفع محفوظة بشكل آمن وسري',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    const primary = Color(0xFF13A9F6);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedPaymentMethod == value
                ? primary
                : Colors.grey[300]!,
            width: _selectedPaymentMethod == value ? 2 : 1,
          ),
          boxShadow: _selectedPaymentMethod == value
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withOpacity(0.15),
              ),
              child: Icon(icon, size: 26, color: primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
              activeColor: primary,
              onChanged: (_) {
                onTap();
              },
            ),
          ],
        ),
      ),
    );
  }
}
