import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedPaymentMethod;
  String? _paymentPhone = '';

  Future<void> _showPaymentDialog(String method) async {
    String phone = '';
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(method == 'vodafone_cash' ? 'بيانات فودافون كاش' : 'بيانات إنستا باي'),
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
                setState(() { _paymentPhone = phone; _selectedPaymentMethod = method; });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('تم حفظ بيانات الدفع: $phone'))
                );
              },
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openWhatsapp() async {
    final webUrl = Uri.parse('https://wa.me/201040073077');
    try {
      if (!await launchUrl(webUrl, mode: LaunchMode.externalApplication)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر فتح الواتساب')));
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر فتح الواتساب')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خيارات الدفع', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildPaymentOption(
              title: 'الدفع بفودافون كاش',
              subtitle: 'سيتم تجديد اشتراكك خلال 24 ساعة.',
              value: 'vodafone_cash',
              onTap: () => _showPaymentDialog('vodafone_cash'),
            ),
            const SizedBox(height: 20),
            _buildPaymentOption(
              title: 'الدفع بإنستا باي',
              subtitle: 'سيتم تجديد اشتراكك خلال 24 ساعة.',
              value: 'instapay',
              onTap: () => _showPaymentDialog('instapay'),
            ),
            const Spacer(),
            OutlinedButton.icon(
              icon: const Icon(Icons.support_agent),
              label: const Text('خدمة العملاء'),
              onPressed: _openWhatsapp,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedPaymentMethod == value ? const Color(0xFF13A9F6) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.payment, size: 40, color: Color(0xFF13A9F6)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: _selectedPaymentMethod,
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
