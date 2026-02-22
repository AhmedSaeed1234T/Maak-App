import 'package:flutter/material.dart';

class CompanyProfileScreen extends StatelessWidget {
  const CompanyProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    final profile = CompanyProfile(
      image: null,
      name: 'The Fashion Hub',
      email: 'User@gmail.com',
      about:
          'The Fashion Hub is your one-stop destination for the latest trends in apparel and accessories. We offer a curated collection of high-quality clothing for men and women, ensuring you always step out in style.',
      location: '456 Style Avenue, Fashion City, NY 10001',
      phone: '(555) 987-6543',
      shopkeeper: 'User Name',
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'الملف الشركي',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                boxShadow: [
                  BoxShadow(
                    color: primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(Icons.store, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),

            // Store Avatar with Shadow
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
                backgroundImage: profile.image,
                child: profile.image == null
                    ? Icon(Icons.store, size: 58, color: primary)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Store Name and Email
            Text(
              profile.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              profile.email,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 28),

            // Main Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // About Section
                      _buildSectionWithContent(
                        'عن المحلات',
                        Icons.info_outline,
                        profile.about,
                        primary,
                      ),
                      const SizedBox(height: 24),

                      // Location Section
                      _buildSectionWithContent(
                        'الموقع',
                        Icons.location_on,
                        profile.location,
                        primary,
                      ),
                      const SizedBox(height: 24),

                      // Phone Section
                      _buildSectionWithContent(
                        'جوال المحلات',
                        Icons.phone,
                        profile.phone,
                        primary,
                      ),
                      const SizedBox(height: 24),

                      // Shopkeeper Section
                      _buildSectionWithContent(
                        'اسم صاحب المحلات',
                        Icons.person,
                        profile.shopkeeper,
                        primary,
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
                        label: const Text(
                          'اتصل الآن',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                        label: const Text(
                          'رسالة',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: const BorderSide(
                            color: Color(0xFF13A9F6),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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

  Widget _buildSectionWithContent(
    String title,
    IconData icon,
    String content,
    Color primary,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withOpacity(0.1),
          ),
          child: Icon(icon, color: primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CompanyProfile {
  final ImageProvider? image;
  final String name;
  final String email;
  final String about;
  final String location;
  final String phone;
  final String shopkeeper;
  CompanyProfile({
    required this.image,
    required this.name,
    required this.email,
    required this.about,
    required this.location,
    required this.phone,
    required this.shopkeeper,
  });
}
