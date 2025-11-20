import 'package:abokamall/helpers/HelperMethods.dart';
import 'package:abokamall/models/SearchResultDto.dart';
import 'package:flutter/material.dart';
class WorkerProfilePage extends StatelessWidget {
  final ServiceProvider provider;
  const WorkerProfilePage({super.key, required this.provider});
  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text('ملف العامل', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: primary.withOpacity(0.16), blurRadius: 14, offset: Offset(0,6))],
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: provider.imageUrl != null
                      ? NetworkImage(provider.imageUrl!)
                      : null,
                  child: provider.imageUrl == null
                      ? Icon(
                          provider.isCompany ? Icons.business : Icons.person,
                          size: 50,
                          color: Colors.grey[700],
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              provider.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            Text(
              provider.skill,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            _buildDetailsSection(provider),
            const SizedBox(height: 24),
            _buildAboutSection(provider),
          ],
        ),
      ),
    );
  }
  Widget _buildDetailsSection(ServiceProvider provider) {
    const primary = Color(0xFF13A9F6);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'التفاصيل',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _detailRow(
            Icons.phone,
            'رقم الهاتف',
            provider.mobileNumber ?? 'غير متوفر',
            primary,
          ),
          const Divider(),
          _detailRow(
            Icons.email,
            'البريد الإلكتروني',
            provider.email ?? 'غير متوفر',
            primary,
          ),
          const Divider(),
          _detailRow(
            Icons.location_on,
            'منطقة الخدمة',
            provider.locationOfServiceArea ?? provider.location,
            primary,
          ),
          const Divider(),
          _detailRow(Icons.attach_money, 'السعر', formatPay(provider), primary),
          const Divider(),
          _detailRow(
            Icons.work,
            'نوع الخدمة',
            translateProviderTypeToArabic(provider.typeOfService!),
            primary,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAboutSection(ServiceProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'نبذة عني',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            provider.aboutMe ??
                'لا توجد معلومات متاحة عن هذا الموفر. يرجى التواصل مباشرة لمزيد من التفاصيل.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
