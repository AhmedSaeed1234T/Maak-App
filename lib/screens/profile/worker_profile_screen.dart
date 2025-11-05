import 'package:flutter/material.dart';

class WorkerProfileScreen extends StatelessWidget {
  const WorkerProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // نموذج بيانات حقيقي (يمكن استبداله بAPI لاحقًا)
    final worker = WorkerProfile(
      image: null, // FileImage/File أو NetworkImage حين الربط
      name: 'John Doe',
      role: 'Plumber',
      phone: '+1 (555) 123-4567',
      email: 'john.doe@example.com',
      location: 'San Francisco, CA',
      price: '	75 / hour',
      serviceType: 'Daily',
      bio: 'Experienced and reliable plumber with over 10 years in the industry. I specialize in residential and commercial plumbing services, including repairs, installations, and maintenance. My goal is to provide high-quality workmanship and excellent customer service. I am available for daily hire and emergency call-outs within the San Francisco Bay Area.',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Worker Profile', style: TextStyle(color: Colors.black)),
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
              backgroundImage: worker.image, // قم بالربط هنا لاحقًا
              child: worker.image == null ? const Icon(Icons.person, size: 65, color: Color(0xFF13A9F6)) : null,
            ),
            const SizedBox(height: 12),
            Text(worker.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(worker.role, style: TextStyle(fontSize: 17, color: Colors.black54)),
            const SizedBox(height: 23),
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
                        Text(worker.phone),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.email, color: Color(0xFF13A9F6)),
                        const SizedBox(width: 10),
                        Text(worker.email),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.place, color: Color(0xFF13A9F6)),
                        const SizedBox(width: 10),
                        Text(worker.location),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: Color(0xFF13A9F6)),
                        const SizedBox(width: 10),
                        Text(worker.price),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Color(0xFF13A9F6)),
                        const SizedBox(width: 10),
                        Text(worker.serviceType),
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
                      const Text('About Me', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(worker.bio, style: const TextStyle(color: Colors.black87)),
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
