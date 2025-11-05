import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'settings_screen.dart';

class EngineerRegisterScreen extends StatefulWidget {
  const EngineerRegisterScreen({Key? key}) : super(key: key);

  @override
  State<EngineerRegisterScreen> createState() => _EngineerRegisterScreenState();
}

class _EngineerRegisterScreenState extends State<EngineerRegisterScreen> {
  static Map<String, dynamic>? sessionEngineerData;
  static File? sessionImage;
  File? _imageFile;
  final picker = ImagePicker();
  int userTypeIndex = 0; // 0 for Contractor, 1 for Engineer

  final _specializationController = TextEditingController();
  final _howDidYouHearController = TextEditingController();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (sessionEngineerData != null) {
      _specializationController.text = sessionEngineerData!['specialization'] ?? '';
      _howDidYouHearController.text = sessionEngineerData!['howDidYouHear'] ?? '';
      _nameController.text = sessionEngineerData!['name'] ?? '';
      _mobileController.text = sessionEngineerData!['mobile'] ?? '';
      _emailController.text = sessionEngineerData!['email'] ?? '';
      _locationController.text = sessionEngineerData!['location'] ?? '';
      _bioController.text = sessionEngineerData!['bio'] ?? '';
      _passwordController.text = sessionEngineerData!['password'] ?? '';
    }
    _imageFile = sessionImage;
  }

  Future<void> _getCurrentLocation() async {
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
        title: const Text('تسجيل مقاول/مهندس', style: TextStyle(color: Colors.black)),
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
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('مقاول')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('مهندس')),
              ],
            ),
            const SizedBox(height: 16),
            _buildTextField(_specializationController, 'التخصص'),
            _buildTextField(_howDidYouHearController, 'كيف سمعت عنا؟'),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('رفع صورة'),
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
            _buildTextField(_nameController, 'الاسم بالكامل'),
            _buildTextField(_mobileController, 'رقم الجوال', keyboardType: TextInputType.phone),
            _buildTextField(_emailController, 'البريد الإلكتروني', keyboardType: TextInputType.emailAddress),
            Row(
              children: [
                Expanded(child: _buildTextField(_locationController, 'منطقة النشاط/الخدمة')),
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
            _buildTextField(_bioController, 'نبذة تعريفية', maxLines: 3),
            _buildTextField(_passwordController, 'كلمة المرور', obscureText: true),
            _buildTextField(TextEditingController(), 'تأكيد كلمة المرور', obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF13A9F6),
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: () {
                sessionEngineerData = {
                  'specialization': _specializationController.text,
                  'howDidYouHear': _howDidYouHearController.text,
                  'name': _nameController.text,
                  'mobile': _mobileController.text,
                  'email': _emailController.text,
                  'location': _locationController.text,
                  'bio': _bioController.text,
                  'password': _passwordController.text,
                };
                sessionImage = _imageFile;
                // تحديث sessionUser في settings_screen
                sessionUser['name'] = _nameController.text;
                sessionUser['phone'] = _mobileController.text;
                sessionUser['email'] = _emailController.text;
                sessionUser['address'] = _locationController.text;
                sessionUser['job'] = _specializationController.text;
                sessionUser['accountType'] = 'engineer';
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

  Widget _buildTextField(TextEditingController controller, String label, {int? maxLines, bool obscureText = false, TextInputType? keyboardType}) {
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
