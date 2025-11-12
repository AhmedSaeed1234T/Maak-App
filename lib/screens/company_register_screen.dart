import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../controllers/RegisterController.dart';
import '../helpers/ServiceLocator.dart';
import '../models/RegisterClass.dart';

class CompanyRegisterScreen extends StatefulWidget {
  const CompanyRegisterScreen({super.key});

  @override
  State<CompanyRegisterScreen> createState() => _CompanyRegisterScreenState();
}

class _CompanyRegisterScreenState extends State<CompanyRegisterScreen> {
  final registerController = getIt<RegisterController>();
  File? _imageFile;
  final picker = ImagePicker();

  static Map<String, dynamic>? sessionCompanyData;
  static File? sessionImage;

  int userTypeIndex = 0; // 0 = Company, 1 = Commercial Store

  final _specializationController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _passwordController = TextEditingController();
  final _salaryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (sessionCompanyData != null) {
      _specializationController.text =
          sessionCompanyData!['specialization'] ?? '';
      _businessNameController.text = sessionCompanyData!['businessName'] ?? '';
      _ownerNameController.text = sessionCompanyData!['ownerName'] ?? '';
      _emailController.text = sessionCompanyData!['email'] ?? '';
      _mobileController.text = sessionCompanyData!['mobile'] ?? '';
      _locationController.text = sessionCompanyData!['location'] ?? '';
      _bioController.text = sessionCompanyData!['bio'] ?? '';
      _passwordController.text = sessionCompanyData!['password'] ?? '';
      _salaryController.text = sessionCompanyData!['salary'] ?? '';
    }
    _imageFile = sessionImage;
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('قم بتفعيل خدمة الموقع على هاتفك.')),
      );
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
    }
  }

  Future<void> _registerCompany() async {
    if (_passwordController.text.isEmpty) return;

    final company = RegisterUserDto(
      firstName: _businessNameController.text,
      lastName: _ownerNameController.text,
      email: _emailController.text,
      phoneNumber: _mobileController.text,
      password: _passwordController.text,
      location: _locationController.text,
      lat: 30.0444,
      lng: 31.2357,
      userType: "SP", // Service Provider
      providerType: userTypeIndex == 0 ? "Company" : "Marketplace",
      business: _businessNameController.text,
      owner: _ownerNameController.text,
      workerType: 1,
      bio: _bioController.text,
    );
    debugPrint(company.toString());
    sessionCompanyData = {
      'businessName': _businessNameController.text,
      'ownerName': _ownerNameController.text,
      'email': _emailController.text,
      'mobile': _mobileController.text,
      'location': _locationController.text,
      'bio': _bioController.text,
      'password': _passwordController.text,
    };
    sessionImage = _imageFile;

    if (await registerController.registerUser(company) == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("تم تسجيل بياناتك بنجاح")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ يرجى إعادة التسجيل")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تسجيل شركة/متجر',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [userTypeIndex == 0, userTypeIndex == 1],
              onPressed: (index) {
                setState(() {
                  userTypeIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: const Color(0xFF13A9F6),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('شركة'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('متجر تجاري'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(_specializationController, 'التخصص/مجال العمل'),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _businessNameController,
                    'اسم الشركة/المؤسسة',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(_ownerNameController, 'اسم المالك'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              _emailController,
              'البريد الإلكتروني',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              _mobileController,
              'رقم الجوال',
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('رفع شعار/صورة الشركة'),
              onPressed: () async {
                final pickedFile = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (pickedFile != null) {
                  setState(() {
                    _imageFile = File(pickedFile.path);
                    sessionImage = _imageFile;
                  });
                }
              },
            ),
            if (_imageFile != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: CircleAvatar(
                  radius: 36,
                  backgroundImage: FileImage(_imageFile!),
                  backgroundColor: Colors.grey[300],
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(_locationController, 'الموقع/العنوان'),
                ),
                IconButton(
                  icon: const Icon(Icons.location_on, color: Color(0xFF13A9F6)),
                  onPressed: _getCurrentLocation,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(_bioController, 'نبذة عن الشركة', maxLines: 2),
            const SizedBox(height: 12),
            _buildTextField(
              _passwordController,
              'كلمة المرور',
              obscureText: true,
            ),
            _buildTextField(
              TextEditingController(),
              'تأكيد كلمة المرور',
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _registerCompany,
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int? maxLines,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines ?? 1,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
