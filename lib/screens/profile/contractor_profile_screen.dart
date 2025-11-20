import 'package:flutter/material.dart';

class ContractorProfileScreen extends StatelessWidget {
  const ContractorProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    final model = ContractorProfile(
      image: null,
      name: 'user name',
      role: 'Plumbing Specialist',
      phone: '+1 (555) 123-4567',
      email: 'user@example.com',
      location: 'San Francisco, CA',
      bio: 'With over 10 years of experience in plumbing, I specialize in residential and commercial plumbing services. My expertise includes leak detection, pipe repair, water heater installation, and drain cleaning. I am committed to providing high-quality workmanship and excellent customer service. Available for projects in San Francisco and surrounding areas.',
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('الملف الشخصي', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))],
              ),
              child: const Icon(Icons.build, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),

            // Profile Avatar with Shadow
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
                backgroundImage: model.image,
                child: model.image == null ? Icon(Icons.build, size: 58, color: primary) : null,
              ),
            ),
            const SizedBox(height: 20),

            // Name and Role
            Text(
              model.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                model.role,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF13A9F6)),
              ),
            ),
            const SizedBox(height: 28),

            // Contact Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _buildDetailRow('رقم الجوال', Icons.phone, model.phone),
                      const SizedBox(height: 16),
                      _buildDetailRow('البريد الإلكتروني', Icons.email, model.email),
                      const SizedBox(height: 16),
                      _buildDetailRow('الموقع', Icons.location_on, model.location),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Bio Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
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
                              color: primary.withOpacity(0.1),
                            ),
                            child: Icon(Icons.description, color: primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'نبذة عني',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        model.bio,
                        style: TextStyle(fontSize: 14, height: 1.6, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.phone, size: 20),
                        label: const Text('اتصل الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.message, size: 20),
                        label: const Text('رسالة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: const BorderSide(color: Color(0xFF13A9F6), width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, IconData icon, String value) {
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
          child: Icon(icon, color: const Color(0xFF13A9F6), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[600]),
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

class ContractorProfile {
  final ImageProvider? image;
  final String name;
  final String role;
  final String phone;
  final String email;
  final String location;
  final String bio;
  ContractorProfile({required this.image, required this.name, required this.role, required this.phone, required this.email, required this.location, required this.bio});
}
