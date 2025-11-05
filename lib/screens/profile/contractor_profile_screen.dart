import 'package:flutter/material.dart';

class ContractorProfileScreen extends StatelessWidget {
  const ContractorProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = ContractorProfile(
      image: null,
      name: 'Ethan Carter',
      role: 'Plumbing Specialist',
      phone: '+1 (555) 123-4567',
      email: 'ethan.carter@example.com',
      location: 'San Francisco, CA',
      bio: 'With over 10 years of experience in plumbing, I specialize in residential and commercial plumbing services. My expertise includes leak detection, pipe repair, water heater installation, and drain cleaning. I am committed to providing high-quality workmanship and excellent customer service. Available for projects in San Francisco and surrounding areas.',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contractor', style: TextStyle(color: Colors.black)),
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
              backgroundImage: model.image,
              child: model.image == null ? const Icon(Icons.person, size: 65, color: Color(0xFF13A9F6)) : null,
            ),
            const SizedBox(height: 12),
            Text(model.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(model.role, style: TextStyle(fontSize: 17, color: Colors.black54)),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              margin: const EdgeInsets.symmetric(horizontal: 23),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.phone, color: Color(0xFF13A9F6)),
                        const SizedBox(width: 10),
                        Text(model.phone),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.email, color: Color(0xFF13A9F6)),
                        const SizedBox(width: 10),
                        Text(model.email),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.place, color: Color(0xFF13A9F6)),
                        const SizedBox(width: 10),
                        Text(model.location),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Bio', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(model.bio, style: const TextStyle(color: Colors.black87)),
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
