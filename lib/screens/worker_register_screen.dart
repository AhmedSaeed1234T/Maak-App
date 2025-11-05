import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/Worker.dart';
import '../controllers/RegisterController.dart';
import '../helpers/ServiceLocator.dart';
import 'settings_screen.dart';

class WorkerRegisterScreen extends StatefulWidget {
  const WorkerRegisterScreen({super.key});

  @override
  State<WorkerRegisterScreen> createState() => _WorkerRegisterScreenState();
}

class _WorkerRegisterScreenState extends State<WorkerRegisterScreen> {
  final registerController = getIt<RegisterController>();
  static Map<String, dynamic>? sessionWorkerData;
  static File? sessionImage;
  File? _imageFile;
  final picker = ImagePicker();

  // Controllers
  final _foundUsController = TextEditingController();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _jobController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String salaryType = 'daily';

  @override
  void initState() {
    super.initState();
    if (sessionWorkerData != null) {
      _foundUsController.text = sessionWorkerData!['foundUs'] ?? '';
      _nameController.text = sessionWorkerData!['name'] ?? '';
      _mobileController.text = sessionWorkerData!['mobile'] ?? '';
      _jobController.text = sessionWorkerData!['job'] ?? '';
      salaryType = sessionWorkerData!['salaryType'] ?? 'daily';
      _locationController.text = sessionWorkerData!['location'] ?? '';
      _bioController.text = sessionWorkerData!['bio'] ?? '';
      _passwordController.text = sessionWorkerData!['password'] ?? '';
      _confirmPasswordController.text = sessionWorkerData!['password'] ?? '';
    }
    _imageFile = sessionImage;
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        sessionImage = _imageFile;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('قم بتفعيل خدمة الموقع')));
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم رفض إذن الموقع')));
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('إذن الموقع مرفوض دائمًا')));
      return;
    }
    Position pos = await Geolocator.getCurrentPosition();
    List<Placemark> placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      String address =
          '${place.country ?? ''} - ${place.administrativeArea ?? ''} - ${place.locality ?? ''} - ${place.street ?? ''}';
      setState(() {
        _locationController.text = address;
      });
    } else {
      setState(() {
        _locationController.text =
            'Lat: ${pos.latitude}, Lon: ${pos.longitude}';
      });
    }
  }

  Future<void> _registerWorker() async {
    final worker = Worker(
      '', // userName (can be empty for now)
      _nameController.text,
      '', // lastName (optional)
      _mobileController.text, // using as email for now
      _imageFile?.path ?? '',
      _mobileController.text,
      _passwordController.text,
      _locationController.text,
      _jobController.text,
      _bioController.text,
      salaryType == 'daily' ? 0 : 1, // pay example
      _foundUsController.text,
      true, // workerType example
      0, // points
      true, // isAvailable
      null, // subscription
    );

    sessionWorkerData = {
      'name': _nameController.text,
      'mobile': _mobileController.text,
      'job': _jobController.text,
      'salaryType': salaryType,
      'location': _locationController.text,
      'bio': _bioController.text,
      'password': _passwordController.text,
      'foundUs': _foundUsController.text,
    };
    sessionImage = _imageFile;

    sessionUser['name'] = _nameController.text;
    sessionUser['phone'] = _mobileController.text;
    sessionUser['job'] = _jobController.text;
    sessionUser['address'] = _locationController.text;
    sessionUser['accountType'] = 'worker';
    sessionImage = _imageFile;

    registerController.RegisterWorker(worker);
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل عامل'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7FAFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
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
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey[100],
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : null,
                child: _imageFile == null
                    ? const Icon(
                        Icons.camera_alt,
                        color: Color(0xFF13A9F6),
                        size: 32,
                      )
                    : null,
              ),
            ),
            TextButton(onPressed: _pickImage, child: const Text('رفع صورة')),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'الاسم بالكامل',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _mobileController,
              decoration: const InputDecoration(
                labelText: 'الجوال',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _jobController,
              decoration: const InputDecoration(
                labelText: 'المهنة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('يومي'),
                    value: 'daily',
                    groupValue: salaryType,
                    onChanged: (val) => setState(() => salaryType = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('مقطوعية'),
                    value: 'fixed',
                    groupValue: salaryType,
                    onChanged: (val) => setState(() => salaryType = val!),
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
                    decoration: const InputDecoration(
                      labelText: 'الموقع',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _getCurrentLocation,
                  icon: const Icon(Icons.location_on, color: Color(0xFF13A9F6)),
                ),
                IconButton(
                  icon: const Icon(Icons.map, color: Colors.green),
                  onPressed: () async {
                    final query = Uri.encodeComponent(_locationController.text);
                    final url =
                        'https://www.google.com/maps/search/?api=1&query=$query';
                    if (await canLaunch(url)) await launch(url);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bioController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'نبذة عنك',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _registerWorker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF13A9F6),
                ),
                child: const Text('حفظ'),
              ),
            ),
            if (_imageFile != null)
              Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.file(
                    _imageFile!,
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
