import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'settings_screen.dart';

class WorkerRegisterScreen extends StatefulWidget {
  const WorkerRegisterScreen({Key? key}) : super(key: key);

  @override
  State<WorkerRegisterScreen> createState() => _WorkerRegisterScreenState();
}

class _WorkerRegisterScreenState extends State<WorkerRegisterScreen> {
  static Map<String, dynamic>? sessionWorkerData;
  static File? sessionImage;
  File? _imageFile;
  final picker = ImagePicker();

  // Controllers for Form Fields
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _jobController = TextEditingController();
  String salaryType = 'daily';
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _foundUsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (sessionWorkerData != null) {
      _nameController.text = sessionWorkerData!['name'] ?? '';
      _mobileController.text = sessionWorkerData!['mobile'] ?? '';
      _jobController.text = sessionWorkerData!['job'] ?? '';
      salaryType = sessionWorkerData!['salaryType'] ?? 'daily';
      _locationController.text = sessionWorkerData!['location'] ?? '';
      _bioController.text = sessionWorkerData!['bio'] ?? '';
      _passwordController.text = sessionWorkerData!['password'] ?? '';
    }
    _imageFile = sessionImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل عامل'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Color(0xFFF7FAFF),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextFormField(
                controller: _foundUsController,
                decoration: const InputDecoration(
                  labelText: 'كيف عرفت عن التطبيق؟',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    setState(() {
                      _imageFile = File(pickedFile.path);
                      sessionImage = _imageFile;
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey[100],
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null ? const Icon(Icons.camera_alt, color: Color(0xFF13A9F6), size: 32) : null,
                ),
              ),
              TextButton(onPressed: () async {
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    _imageFile = File(pickedFile.path);
                    sessionImage = _imageFile;
                  });
                }
              }, child: const Text('رفع صورة', style: TextStyle(color: Color(0xFF13A9F6)))),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم بالكامل', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'الجوال', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _jobController,
                decoration: const InputDecoration(labelText: 'المهنة', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('يومي'),
                      value: 'daily',
                      groupValue: salaryType,
                      onChanged: (val) { setState(() { salaryType = val!; }); },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('مقطوعية'),
                      value: 'fixed',
                      groupValue: salaryType,
                      onChanged: (val) { setState(() { salaryType = val!; }); },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'الموقع', border: OutlineInputBorder()),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.location_on, color: Color(0xFF13A9F6)),
                    tooltip: 'تحديد الموقع تلقائيًا',
                    onPressed: () async {
                      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                      if (!serviceEnabled) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قم بتفعيل خدمة الموقع على هاتفك.')));
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
                      String address = '';
                      if (placemarks.isNotEmpty) {
                        final place = placemarks.first;
                        address = '${place.country ?? ''} - ${place.administrativeArea ?? ''} - ${place.locality ?? ''} - ${place.street ?? ''}';
                        setState(() { _locationController.text = address; });
                      } else {
                        setState(() { _locationController.text = 'خط العرض: ${pos.latitude}, خط الطول: ${pos.longitude}'; });
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.map, color: Colors.green),
                    tooltip: 'فتح في الخريطة',
                    onPressed: () async {
                      final loc = _locationController.text;
                      final query = Uri.encodeComponent(loc);
                      final url = 'https://www.google.com/maps/search/?api=1&query=$query';
                      if (await canLaunch(url)) {
                        await launch(url);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر فتح الخرائط')));
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'نبذة عنك', border: OutlineInputBorder()),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF13A9F6),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    sessionWorkerData = {
                      'name': _nameController.text,
                      'mobile': _mobileController.text,
                      'job': _jobController.text,
                      'salaryType': salaryType,
                      'location': _locationController.text,
                      'bio': _bioController.text,
                      'password': _passwordController.text,
                    };
                    sessionImage = _imageFile;
                    // حفظ في sessionUser الرئيسى
                    sessionUser['name'] = _nameController.text;
                    sessionUser['phone'] = _mobileController.text;
                    sessionUser['job'] = _jobController.text;
                    sessionUser['address'] = _locationController.text;
                    sessionUser['accountType'] = 'worker';
                    sessionImage = _imageFile;
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('حفظ'),
                ),
              ),
              if (_imageFile != null)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.file(_imageFile!, height: 80, width: 80, fit: BoxFit.cover),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
