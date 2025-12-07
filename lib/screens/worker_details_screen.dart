import 'package:abokamall/helpers/HelperMethods.dart';
import 'package:abokamall/models/SearchResultDto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: ClipOval(
                    child:
                        provider.imageUrl != null &&
                            provider.imageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: provider.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: const Color(0xFFF5F7FA),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFF5F7FA),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: primary,
                              ),
                            ),
                          )
                        : provider.isCompany
                        ? Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.orange.withOpacity(0.15),
                            ),
                            child: Icon(
                              Icons.business,
                              color: Colors.orange,
                              size: 50,
                            ),
                          )
                        : CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              color: Colors.grey[600],
                              size: 28,
                            ),
                          ),
                  ),
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
            _buildDetailsSection(provider, context),
            const SizedBox(height: 24),
            _buildAboutSection(provider),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(ServiceProvider provider, BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: _detailRow(
                  Icons.phone,
                  'رقم الهاتف',
                  provider.mobileNumber.toString().substring(2),
                  primary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: provider.mobileNumber.toString().substring(2),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ رقم الهاتف')),
                  );
                },
              ),
            ],
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
          if (!provider.isCompany) ...[
            _detailRow(
              Icons.attach_money,
              'السعر',
              formatPay(provider),
              primary,
            ),
            const Divider(),
          ],
          if (provider.isCompany) ...[
            _detailRow(
              Icons.person,
              'المالك',
              provider.owner ?? 'غير متوفر',
              primary,
            ),
            const Divider(),
          ],
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
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
      width: double.infinity,
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
