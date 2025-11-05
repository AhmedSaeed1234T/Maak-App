import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

Map<String, dynamic> sessionUser = {
  'accountType': 'user',
  'name': 'اسم المستخدم',
  'username': 'اسم الشهرة',
  'email': 'email@example.com',
  'phone': '+123456789',
  'address': 'العنوان',
  'job': 'الوظيفة',
};
File? sessionImage;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? _imageFile;
  final picker = ImagePicker();
  int points = 1250;
  String name = sessionUser['name'] ?? '';
  String username = sessionUser['username'] ?? '';
  String email = sessionUser['email'] ?? '';
  String phone = sessionUser['phone'] ?? '';
  String address = sessionUser['address'] ?? '';
  String job = sessionUser['job'] ?? '';
  String accountType = sessionUser['accountType'] ?? 'user';
  bool notifications = true;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() { _imageFile = File(pickedFile.path); });
    }
  }

  @override
  void initState() {
    super.initState();
    name = sessionUser['name'] ?? '';
    username = sessionUser['username'] ?? '';
    email = sessionUser['email'] ?? '';
    phone = sessionUser['phone'] ?? '';
    address = sessionUser['address'] ?? '';
    job = sessionUser['job'] ?? '';
    accountType = sessionUser['accountType'] ?? 'user';
    _imageFile = sessionImage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات والملف الشخصي'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFF13A9F6),
                ),
                child: Column(
                  children: [
                    Text('نقاطي', style: TextStyle(color: Colors.white, fontSize: 18)),
                    SizedBox(height: 8),
                    Text('$points', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
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
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null ? Icon(Icons.person, size: 48) : null,
                ),
              ),
              const SizedBox(height: 20),
              if (accountType.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified_user, color: Color(0xFF13A9F6)),
                      const SizedBox(width: 10),
                      Text('نوع الحساب: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                      Text(formatAccountType(accountType), style: const TextStyle(fontSize: 16, color: Colors.black54),)
                    ],
                  ),
                ),
              _buildEditableField('الاسم', name, (val) => setState(() => name = val)),
              _buildEditableField('اسم المستخدم', username, (val) => setState(() => username = val)),
              _buildEditableField('البريد الإلكتروني', email, (val) => setState(() => email = val)),
              _buildEditableField('رقم الجوال', phone, (val) => setState(() => phone = val)),
              _buildEditableField('العنوان', address, (val) => setState(() => address = val)),
              _buildEditableField('الوظيفة', job, (val) => setState(() => job = val)),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('تفعيل الإشعارات'),
                value: notifications,
                onChanged: (val) => setState(() => notifications = val),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('تغيير كلمة المرور'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.pushNamed(context, '/reset_password');
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                title: const Text('تسجيل الخروج'),
                subtitle: const Text('سيتم تسجيل خروجك بعد موافقة الدعم'),
                onTap: () {
                  setState(() {
                    sessionUser = {
                      'accountType': 'user',
                      'name': 'اسم المستخدم',
                      'username': 'اسم الشهرة',
                      'email': 'email@example.com',
                      'phone': '+123456789',
                      'address': 'العنوان',
                      'job': 'الوظيفة',
                    };
                    sessionImage = null;
                  });
                  Navigator.of(context).pushNamedAndRemoveUntil('/splash', (route) => false);
                },
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF13A9F6),
                  minimumSize: Size(double.infinity, 48),
                ),
                onPressed: () {
                  setState(() {
                    sessionUser['name'] = name;
                    sessionUser['username'] = username;
                    sessionUser['email'] = email;
                    sessionUser['phone'] = phone;
                    sessionUser['address'] = address;
                    sessionUser['job'] = job;
                    sessionImage = _imageFile;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ الإعدادات بنجاح!')));
                },
                child: const Text('حفظ التغييرات'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(value, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF13A9F6)),
            onPressed: () {
              _showEditDialog(label, value, onChanged);
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(String label, String initialValue, Function(String) onSave) {
    final controller = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل $label'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  String formatAccountType(String type) {
    switch(type) {
      case 'worker': return 'عامل';
      case 'engineer': return 'مهندس';
      case 'company': return 'شركة';
      case 'user': return 'مستخدم عادي';
      default: return 'غير محدد';
    }
  }
}
