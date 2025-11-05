import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'settings_screen.dart';

class CompanyRegisterScreen extends StatefulWidget {
  const CompanyRegisterScreen({Key? key}) : super(key: key);

  @override
  State<CompanyRegisterScreen> createState() => _CompanyRegisterScreenState();
}

class _CompanyRegisterScreenState extends State<CompanyRegisterScreen> {
  static Map<String, dynamic>? sessionCompanyData;
  static File? sessionImage;
  File? _imageFile;
  final picker = ImagePicker();
  int userTypeIndex = 0; // 0 for Company, 1 for Commercial Store

  final _howDidYouHearController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (sessionCompanyData != null) {
      _howDidYouHearController.text = sessionCompanyData!['howDidYouHear'] ?? '';
      _companyNameController.text = sessionCompanyData!['companyName'] ?? '';
      _ownerNameController.text = sessionCompanyData!['ownerName'] ?? '';
      _emailController.text = sessionCompanyData!['email'] ?? '';
      _mobileController.text = sessionCompanyData!['mobile'] ?? '';
      _locationController.text = sessionCompanyData!['location'] ?? '';
      _passwordController.text = sessionCompanyData!['password'] ?? '';
    }
    _imageFile = sessionImage;
  }

  Future<void> _getCurrentLocation() async {
    // Same implementation as in EngineerRegisterScreen
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
    if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String address = '${place.country ?? ''} - ${place.administrativeArea ?? ''} - ${place.locality ?? ''} - ${place.street ?? ''}';
        setState(() {
            _locationController.text = address;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تسجيل شركة/متجر', style: TextStyle(color: Colors.black)),
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
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('شركة')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('متجر تجاري')),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(_howDidYouHearController, 'كيف سمعت عن التطبيق؟'),
            _buildTextField(_companyNameController, 'اسم الشركة أو المحل'),
            _buildTextField(_ownerNameController, 'اسم المالك/صاحب المحل'),
            _buildTextField(_emailController, 'البريد الإلكتروني للأعمال', keyboardType: TextInputType.emailAddress),
            _buildTextField(_mobileController, 'رقم الجوال', keyboardType: TextInputType.phone),
            OutlinedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('رفع شعار الشركة/صورة المتجر'),
              onPressed: () async {
                final pickedFile = await picker.pickImage(source: ImageSource.gallery);
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
            const SizedBox(height: 16),
            _buildTextField(_passwordController, 'كلمة المرور', obscureText: true),
            _buildTextField(TextEditingController(), 'تأكيد كلمة المرور', obscureText: true),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildTextField(_locationController, 'الموقع/العنوان')),
                IconButton(icon: const Icon(Icons.location_on, color: Color(0xFF13A9F6)), onPressed: _getCurrentLocation),
                IconButton(
                  icon: const Icon(Icons.map, color: Colors.green),
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
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF13A9F6),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                sessionCompanyData = {
                  'howDidYouHear': _howDidYouHearController.text,
                  'companyName': _companyNameController.text,
                  'ownerName': _ownerNameController.text,
                  'email': _emailController.text,
                  'mobile': _mobileController.text,
                  'location': _locationController.text,
                  'password': _passwordController.text,
                };
                sessionImage = _imageFile;
                sessionUser['name'] = _companyNameController.text;
                sessionUser['phone'] = _mobileController.text;
                sessionUser['email'] = _emailController.text;
                sessionUser['address'] = _locationController.text;
                sessionUser['job'] = _ownerNameController.text;
                sessionUser['accountType'] = 'company';
                sessionImage = _imageFile;
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscureText = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
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
