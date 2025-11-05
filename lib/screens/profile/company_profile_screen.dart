import 'package:flutter/material.dart';

class CompanyProfileScreen extends StatelessWidget {
  const CompanyProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profile = CompanyProfile(
      image: null, // NetworkImage أو FileImage عند الحاجة
      name: 'The Fashion Hub',
      email: 'contact@fashionhub.com',
      about: 'The Fashion Hub is your one-stop destination for the latest trends in apparel and accessories. We offer a curated collection of high-quality clothing for men and women, ensuring you always step out in style.',
      location: '456 Style Avenue, Fashion City, NY 10001',
      phone: '(555) 987-6543',
      shopkeeper: 'Jane Smith',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFF7FAFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF7FAFF),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 18),
            CircleAvatar(
              radius: 54,
              backgroundColor: Colors.grey[300],
              backgroundImage: profile.image,
              child: profile.image == null ? const Icon(Icons.store, size: 65, color: Color(0xFF13A9F6)) : null,
            ),
            const SizedBox(height: 12),
            Text(profile.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(profile.email, style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 5),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      sectionTitle('About Our Shop'),
                      Text(profile.about, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                      const SizedBox(height: 20),
                      sectionTitle('Location'),
                      Text(profile.location, style: const TextStyle(fontSize: 15, color: Colors.black87)),
                      const SizedBox(height: 20),
                      sectionTitle('Contact Information'),
                      Text('Shop Mobile: ${profile.phone}', style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 14),
                      sectionTitle('Shopkeeper Name'),
                      Text(profile.shopkeeper, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 34),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 4.0),
        child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      );
}

class CompanyProfile {
  final ImageProvider? image;
  final String name;
  final String email;
  final String about;
  final String location;
  final String phone;
  final String shopkeeper;
  CompanyProfile({required this.image, required this.name, required this.email, required this.about, required this.location, required this.phone, required this.shopkeeper});
}
