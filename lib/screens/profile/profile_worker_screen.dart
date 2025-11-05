import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WorkerProfileScreen extends StatefulWidget {
  const WorkerProfileScreen({Key? key}) : super(key: key);

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  File? _imageFile;
  final picker = ImagePicker();

  String name = 'الاسم';
  String profession = 'المهنة';
  String location = 'الموقع';
  String price = 'السعر';
  String phone = '';
  String email = '';
  String about = '';

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() { _imageFile = File(pickedFile.path); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف العامل'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Color(0xFFF7FAFF),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 54,
                backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                backgroundColor: Colors.grey[300],
                child: _imageFile == null ? const Icon(Icons.person, size: 64, color: Color(0xFF13A9F6)) : null,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: _pickImage, child: const Text('تغيير الصورة', style: TextStyle(color: Color(0xFF13A9F6)))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(labelText: 'الاسم', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() {name = v;}),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: profession,
                    decoration: const InputDecoration(labelText: 'المهنة', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() {profession = v;}),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: location,
                          decoration: const InputDecoration(labelText: 'مكان العمل', border: OutlineInputBorder()),
                          onChanged: (v) => setState(() { location = v; }),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.location_on, color: Color(0xFF13A9F6)),
                        tooltip: 'تحديد الموقع تلقائيًا',
                        onPressed: () async {
                          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                          if (!serviceEnabled) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يجب تفعيل خدمة الموقع.')));
                            return;
                          }
                          LocationPermission permission = await Geolocator.checkPermission();
                          if (permission == LocationPermission.denied) {
                            permission = await Geolocator.requestPermission();
                            if (permission == LocationPermission.denied) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفض إذن الموقع')));
                              return;
                            }
                          }
                          if (permission == LocationPermission.deniedForever) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('إذن الموقع مرفوض دائمًا')));
                            return;
                          }
                          Position pos = await Geolocator.getCurrentPosition();
                          List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
                          if (placemarks.isNotEmpty) {
                            final place = placemarks.first;
                            String address = '${place.country ?? ''} - ${place.administrativeArea ?? ''} - ${place.locality ?? ''} - ${place.street ?? ''}';
                            setState(() { location = address; });
                          } else {
                            setState(() { location = 'خط العرض: ${pos.latitude}, خط الطول: ${pos.longitude}'; });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: price,
                    decoration: const InputDecoration(labelText: 'السعر', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() {price = v;}),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: phone,
                    decoration: const InputDecoration(labelText: 'الجوال', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() {phone = v;}),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: email,
                    decoration: const InputDecoration(labelText: 'البريد الإلكتروني', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() {email = v;}),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: about,
                    decoration: const InputDecoration(labelText: 'نبذة عني', border: OutlineInputBorder()),
                    maxLines: 2,
                    onChanged: (v) => setState(() {about = v;}),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF13A9F6)),
                      onPressed: () {
                        // هنا يتم حفظ بيانات التعديل فعلياً فى state ويمكن لاحقًا إرسالها لل backend
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحفظ!')));
                      },
                      child: const Text('حفظ'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
