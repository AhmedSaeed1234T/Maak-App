import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../controllers/RegisterController.dart';
import '../helpers/ServiceLocator.dart';
import '../models/RegisterClass.dart';

class EngineerRegisterScreen extends StatefulWidget {
  const EngineerRegisterScreen({super.key});

  @override
  State<EngineerRegisterScreen> createState() => _EngineerRegisterScreenState();
}

class _EngineerRegisterScreenState extends State<EngineerRegisterScreen> {
  final registerController = getIt<RegisterController>();
  File? _imageFile;
  final picker = ImagePicker();

  // Session storage
  static Map<String, dynamic>? sessionEngineerData;
  static File? sessionImage;

  // User selection: 0 = Contractor, 1 = Engineer
  int userTypeIndex = 1;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _specializationController = TextEditingController();
  final _salaryController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();

  String salaryType = 'daily'; // 0 = daily, 1 = fixed

  @override
  void initState() {
    super.initState();
    if (sessionEngineerData != null) {
      _firstNameController.text = sessionEngineerData!['firstName'] ?? '';
      _lastNameController.text = sessionEngineerData!['lastName'] ?? '';
      _emailController.text = sessionEngineerData!['email'] ?? '';
      _mobileController.text = sessionEngineerData!['phoneNumber'] ?? '';
      _specializationController.text =
          sessionEngineerData!['specialization'] ?? '';
      _salaryController.text = sessionEngineerData!['pay']?.toString() ?? '';
      _bioController.text = sessionEngineerData!['bio'] ?? '';
      _locationController.text = sessionEngineerData!['location'] ?? '';
      _passwordController.text = sessionEngineerData!['password'] ?? '';
    }
    _imageFile = sessionImage;
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      sessionImage = _imageFile;
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
      setState(() => _locationController.text = address);
    } else {
      setState(
        () => _locationController.text =
            'Lat: ${pos.latitude}, Lon: ${pos.longitude}',
      );
    }
  }

  Future<void> _registerEngineer() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('كلمات المرور غير متطابقة')));
      return;
    }

    final worker = RegisterUserDto(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      phoneNumber: _mobileController.text,
      password: _passwordController.text,
      location: _locationController.text,
      lat: 30.0444,
      lng: 31.2357,
      userType: "SP",
      providerType: userTypeIndex == 0 ? "Contractor" : "Engineer",
      specialization: _specializationController.text,
      workerType: 1, // always 1
      pay: double.tryParse(_salaryController.text) ?? 0,
      bio: _bioController.text,
    );

    // Store session data
    sessionEngineerData = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
      'phoneNumber': _mobileController.text,
      'specialization': _specializationController.text,
      'pay': double.tryParse(_salaryController.text) ?? 0,
      'bio': _bioController.text,
      'location': _locationController.text,
      'password': _passwordController.text,
      'providerType': worker.providerType,
    };

    if (await registerController.registerUser(worker, _imageFile) == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("تم تسجيل بياناتك بنجاح")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("حدث خطأ يرجي اعادة التسجيل")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل مقاول/مهندس'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF7FAFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
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
            Row(
              children: [
                Expanded(
                  child: RadioListTile<int>(
                    title: const Text('مقاول'),
                    value: 0,
                    groupValue: userTypeIndex,
                    onChanged: (val) => setState(() => userTypeIndex = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<int>(
                    title: const Text('مهندس'),
                    value: 1,
                    groupValue: userTypeIndex,
                    onChanged: (val) => setState(() => userTypeIndex = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الاول',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 6,
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'الاسم الاخير',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'البريد الالكتروني',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
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
              controller: _specializationController,
              decoration: const InputDecoration(
                labelText: 'التخصص',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _salaryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'الاجر',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bioController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'نبذة عنك',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'الموقع',
                border: OutlineInputBorder(),
              ),
            ),
            IconButton(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on, color: Color(0xFF13A9F6)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
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
                onPressed: _registerEngineer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF13A9F6),
                ),
                child: const Text('حفظ'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
