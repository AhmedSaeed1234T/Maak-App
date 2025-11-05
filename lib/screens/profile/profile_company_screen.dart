import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({Key? key}) : super(key: key);
  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  File? _imageFile;
  final picker = ImagePicker();

  String companyName = 'اسم الشركة';
  String type = 'نوع الشركة';
  String specialization = 'تخصص';
  String owner = '';
  String phone = '';
  String email = '';
  String address = '';
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
        title: const Text('ملف الشركة/المتجر'),
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
                child: _imageFile == null ? const Icon(Icons.store, size: 60, color: Color(0xFF13A9F6)) : null,
              ),
            ),
            const SizedBox(height: 10),
            TextButton(onPressed: _pickImage, child: const Text('تغيير الصورة أو الشعار', style: TextStyle(color: Color(0xFF13A9F6)))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  TextFormField(
                    initialValue: companyName,
                    decoration: const InputDecoration(labelText: 'اسم الشركة أو المتجر', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() {companyName = v;}),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: type,
                    decoration: const InputDecoration(labelText: 'نوع', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() {type = v;}),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: specialization,
                    decoration: const InputDecoration(labelText: 'تخصص', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() {specialization = v;}),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: owner,
                    decoration: const InputDecoration(labelText: 'اسم المالك', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() {owner = v;}),
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
                          initialValue: address,
                          decoration: const InputDecoration(labelText: 'العنوان/الموقع', border: OutlineInputBorder()),
                          onChanged: (v) => setState(() {address = v;}),
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
                            String addressText = '${place.country ?? ''} - ${place.administrativeArea ?? ''} - ${place.locality ?? ''} - ${place.street ?? ''}';
                            setState(() { address = addressText; });
                          } else {
                            setState(() { address = 'خط العرض: ${pos.latitude}, خط الطول: ${pos.longitude}'; });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: about,
                    maxLines: 2,
                    decoration: const InputDecoration(labelText: 'نبذة عن النشاط', border: OutlineInputBorder()),
                    onChanged: (v) => setState(() {about = v;}),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF13A9F6)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ البيانات!')));
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
