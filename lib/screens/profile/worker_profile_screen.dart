import 'package:flutter/material.dart';

class WorkerProfileScreen extends StatelessWidget {
  const WorkerProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    
    // نموذج بيانات حقيقي (يمكن استبداله بAPI لاحقًا)
    final worker = WorkerProfile(
      image: null,
      name: 'User Name',
      role: 'Plumber',
      phone: '+1 (555) 123-4567',
      email: 'User@example.com',
      location: 'San Francisco, CA',
      price: '75 / hour',
      serviceType: 'Daily',
      bio: 'Experienced and reliable plumber with over 10 years in the industry. I specialize in residential and commercial plumbing services, including repairs, installations, and maintenance. My goal is to provide high-quality workmanship and excellent customer service. I am available for daily hire and emergency call-outs within the San Francisco Bay Area.',
    );
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('الملف الشخصي', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Profile Avatar
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 58,
                backgroundColor: Color(0xFFF4F7FA),
                backgroundImage: worker.image,
                child: worker.image == null
                    ? Icon(Icons.person, size: 60, color: primary)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              worker.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                worker.role,
                style: TextStyle(fontSize: 14, color: primary, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 24),
            
            // Contact Information Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.phone, 'رقم الجوال', worker.phone),
                    const SizedBox(height: 14),
                    _buildDetailRow(Icons.email, 'البريد الإلكتروني', worker.email),
                    const SizedBox(height: 14),
                    _buildDetailRow(Icons.location_on, 'الموقع', worker.location),
                    const SizedBox(height: 14),
                    _buildDetailRow(Icons.monetization_on, 'السعر', worker.price),
                    const SizedBox(height: 14),
                    _buildDetailRow(Icons.calendar_month, 'نوع الخدمة', worker.serviceType),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // About Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primary.withOpacity(0.15),
                          ),
                          child: const Icon(Icons.description, color: primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'عن الصنايعى',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      worker.bio,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.6),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.phone, size: 20),
                    label: const Text('اتصل الآن', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 3,
                    ),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.message, size: 20),
                    label: const Text('رسالة', style: TextStyle(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      side: const BorderSide(color: primary, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF13A9F6).withOpacity(0.1),
          ),
          child: Icon(icon, color: const Color(0xFF13A9F6), size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WorkerProfile {
  final ImageProvider? image;
  final String name;
  final String role;
  final String phone;
  final String email;
  final String location;
  final String price;
  final String serviceType;
  final String bio;
  WorkerProfile({required this.image, required this.name, required this.role, required this.phone, required this.email, required this.location, required this.price, required this.serviceType, required this.bio});
}
