import 'package:abokamall/helpers/HelperMethods.dart';
import 'package:abokamall/models/SearchResultDto.dart';
import 'package:flutter/material.dart';
class WorkerProfilePage extends StatelessWidget {
  final ServiceProvider provider;
  const WorkerProfilePage({super.key, required this.provider});
  @override
  Widget build(BuildContext context) {
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
                        color: Colors.grey,
                      )
                    : null,
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
          ),
          _detailRow(
            Icons.email,
            'البريد الإلكتروني',
            provider.email ?? 'غير متوفر',
          ),
          _detailRow(
            Icons.location_on,
            'منطقة الخدمة',
            provider.locationOfServiceArea ?? provider.location,
          ),
          _detailRow(Icons.attach_money, 'السعر', formatPay(provider)),
          _detailRow(
            Icons.work,
            'نوع الخدمة',
            translateProviderTypeToArabic(provider.typeOfService!),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text('$title: $value', style: const TextStyle(fontSize: 14)),
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
