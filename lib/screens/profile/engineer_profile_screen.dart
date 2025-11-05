import 'package:flutter/material.dart';

class EngineerProfileScreen extends StatelessWidget {
  const EngineerProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // نموذج بيانات تجريبي جاهز للربط
    final profile = EngineerProfile(
      image: null, // للمستقبل/NetworkImage
      name: 'Sophia Chen',
      title: 'Civil Engineer',
      phone: '+1 (555) 987-6543',
      email: 'sophia.chen@example.com',
      location: 'New York, NY',
      price: '	150 / hour',
      bio: 'As a licensed Civil Engineer with 8 years of experience, I specialize in structural design and analysis for residential and commercial buildings. My expertise covers a wide range of projects, from small-scale renovations to large new constructions. I am proficient in using AutoCAD, SAP2000, and ETABS for detailed structural modeling. Committed to delivering safe, efficient, and innovative engineering solutions.',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Engineer Profile', style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFF7FAFF),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        automaticallyImplyLeading: true,
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
              child: profile.image == null ? const Icon(Icons.person, size: 65, color: Color(0xFF13A9F6)) : null,
            ),
            const SizedBox(height: 12),
            Text(profile.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(profile.title, style: TextStyle(fontSize: 17, color: Colors.black54)),
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
                        Text(profile.phone),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.email, color: Color(0xFF13A9F6)),
                        const SizedBox(width: 10),
                        Text(profile.email),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.place, color: Color(0xFF13A9F6)),
                        const SizedBox(width: 10),
                        Text(profile.location),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: Color(0xFF13A9F6)),
                        const SizedBox(width: 10),
                        Text(profile.price),
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
                      const Text('Professional Bio', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(profile.bio, style: const TextStyle(color: Colors.black87)),
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

class EngineerProfile {
  final ImageProvider? image;
  final String name;
  final String title;
  final String phone;
  final String email;
  final String location;
  final String price;
  final String bio;
  EngineerProfile({required this.image, required this.name, required this.title, required this.phone, required this.email, required this.location, required this.price, required this.bio});
}
