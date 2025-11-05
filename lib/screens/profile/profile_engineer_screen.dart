import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class EngineerProfileScreen extends StatefulWidget {
  const EngineerProfileScreen({Key? key}) : super(key: key);

  @override
  State<EngineerProfileScreen> createState() => _EngineerProfileScreenState();
}

class _EngineerProfileScreenState extends State<EngineerProfileScreen> {
  File? _imageFile;
  final picker = ImagePicker();

  String name = 'اسم المهندس';
  String specialization = 'تخصص هندسي';
  String phone = '';
  String email = '';
  String location = '';
  String price = '';
  String bio = '';

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
        title: const Text('ملف المهندس'),
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
                child: _imageFile == null ? const Icon(Icons.engineering, size: 60, color: Color(0xFF13A9F6)) : null,
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
                    initialValue: specialization,
                    decoration: const InputDecoration(labelText: 'التخصص/الدرجة', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() {specialization = v;}),
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
                    decoration: const InputDecoration(labelText: 'البريد الإلكترونى', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() {email = v;}),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: location,
                          decoration: const InputDecoration(labelText: 'مكان العمل', border: OutlineInputBorder()),
                          onChanged: (v) => setState(() {location = v;}),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.location_on, color: Color(0xFF13A9F6)),
                        tooltip: 'تحديد الموقع تلقائيًا',
                        onPressed: () async {
                          bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                          if (!serviceEnabled) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قم بتفعيل خدمة الموقع.')));
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
                    initialValue: bio,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'نبذة عني', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() {bio = v;}),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF13A9F6)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ البيانات بنجاح!')));
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
