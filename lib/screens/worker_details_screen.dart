import 'package:abokamall/controllers/PresenceController.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/HelperMethods.dart';
import 'package:abokamall/models/SearchResultDto.dart';
import 'package:abokamall/screens/chat_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:abokamall/helpers/CustomSnackBar.dart';

class WorkerProfilePage extends StatelessWidget {
  final ServiceProvider provider;
  const WorkerProfilePage({super.key, required this.provider});
  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    const secondary = Color(
      0xFF536DFE,
    ); // Defined a secondary color for chat button
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (provider.userId == null || provider.userId!.isEmpty) {
            CustomSnackBar.show(
              context,
              message: 'لا يمكن بدء المحادثة مع هذا المستخدم (المعرف مفقود)',
              type: SnackBarType.error,
            );
            return;
          }
          debugPrint(provider.workerType.toString());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                targetUserId: provider.userId!,
                targetUserName: provider.name,
                targetUserImage: provider.imageUrl,
              ),
            ),
          );
        },
        label: const Text("محادثة", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.chat, color: Colors.white),
        backgroundColor: primary,
      ),
      appBar: AppBar(
        title: const Text('ملف الصنايعى', style: TextStyle(color: Colors.black)),
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
            ValueListenableBuilder<Set<String>>(
              valueListenable: getIt<PresenceController>().onlineUsers,
              builder: (context, onlineUsers, _) {
                final isOnline = getIt<PresenceController>().isUserOnline(
                  provider.userId,
                );
                return Column(
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: isOnline ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isOnline ? 'متصل الآن' : 'غير متصل',
                              style: TextStyle(
                                fontSize: 14,
                                color: isOnline
                                    ? Colors.green
                                    : Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (provider.isOccupied) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.block,
                                  size: 16,
                                  color: Colors.orange[700],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'غير متاح حالياً',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                );
              },
            ),
            if (provider.typeOfService != 'Sculptor') ...[
              Text(
                provider.skill,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
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
                  CustomSnackBar.show(
                    context,
                    message: 'تم نسخ رقم الهاتف',
                    type: SnackBarType.info,
                  );
                },
              ),
            ],
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
            Icons.store,
            'المحلات',
            (provider.marketplace == null || provider.marketplace!.isEmpty)
                ? 'غير محدد'
                : provider.marketplace!,
            primary,
          ),
          const Divider(),

          // Hide specialization for sculptors (نحات)
          if (provider.typeOfService != 'Sculptor') ...[
            _detailRow(
              Icons.build,
              'التخصص الفرعي',
              (provider.derivedSpec == null || provider.derivedSpec!.isEmpty)
                  ? 'نحات'
                  : provider.derivedSpec!,
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
