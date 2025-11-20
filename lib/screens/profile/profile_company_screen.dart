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
    const primary = Color(0xFF13A9F6);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('تعديل الملف الشركي', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
              child: const Icon(Icons.store, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'ملف الشركة',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'حدّث معلومات متجرك أو شركتك',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 28),

            // Profile Image
            GestureDetector(
              onTap: _pickImage,
              child: Container(
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
                  radius: 55,
                  backgroundColor: Color(0xFFF4F7FA),
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? Icon(Icons.store, size: 55, color: primary)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('تغيير الشعار'),
              style: TextButton.styleFrom(foregroundColor: primary, textStyle: const TextStyle(fontSize: 14)),
            ),
            const SizedBox(height: 28),

            // Main Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Company Info Section
                    _buildSectionLabel('معلومات الشركة'),
                    const SizedBox(height: 12),
                    _buildTextField('اسم الشركة أو المتجر', Icons.store, companyName, (v) => setState(() => companyName = v)),
                    const SizedBox(height: 14),
                    _buildTextField('النوع', Icons.category, type, (v) => setState(() => type = v)),
                    const SizedBox(height: 14),
                    _buildTextField('التخصص', Icons.work, specialization, (v) => setState(() => specialization = v)),
                    const SizedBox(height: 20),

                    // Owner & Contact Section
                    _buildSectionLabel('المالك والاتصال'),
                    const SizedBox(height: 12),
                    _buildTextField('اسم المالك', Icons.person, owner, (v) => setState(() => owner = v)),
                    const SizedBox(height: 14),
                    _buildTextField('رقم الجوال', Icons.phone, phone, (v) => setState(() => phone = v), TextInputType.phone),
                    const SizedBox(height: 14),
                    _buildTextField('البريد الإلكتروني', Icons.email, email, (v) => setState(() => email = v), TextInputType.emailAddress),
                    const SizedBox(height: 20),

                    // Location Section
                    _buildSectionLabel('الموقع'),
                    const SizedBox(height: 12),
                    _buildLocationField(),
                    const SizedBox(height: 20),

                    // About Section
                    _buildSectionLabel('نبذة عن النشاط'),
                    const SizedBox(height: 12),
                    _buildTextFieldMultiline('نبذة عن النشاط', Icons.description, about, (v) => setState(() => about = v)),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save, size: 20),
                        label: const Text('حفظ البيانات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم حفظ البيانات بنجاح'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    String initialValue,
    Function(String) onChanged, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF13A9F6)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF13A9F6), width: 2),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildTextFieldMultiline(
    String label,
    IconData icon,
    String initialValue,
    Function(String) onChanged,
  ) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: 3,
      minLines: 3,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Icon(icon, color: const Color(0xFF13A9F6)),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF13A9F6), width: 2),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildLocationField() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: address,
            decoration: InputDecoration(
              labelText: 'العنوان/الموقع',
              prefixIcon: const Icon(Icons.location_on, color: Color(0xFF13A9F6)),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF13A9F6), width: 2),
              ),
            ),
            onChanged: (v) => setState(() => address = v),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF13A9F6).withOpacity(0.15),
          ),
          child: IconButton(
            icon: const Icon(Icons.my_location, color: Color(0xFF13A9F6), size: 20),
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
                String addressText = '${place.country ?? ''} - ${place.administrativeArea ?? ''} - ${place.locality ?? ''} - ${place.street ?? ''}';
                setState(() => address = addressText);
              } else {
                setState(() => address = 'خط العرض: ${pos.latitude}, خط الطول: ${pos.longitude}');
              }
            },
          ),
        ),
      ],
    );
  }
}
