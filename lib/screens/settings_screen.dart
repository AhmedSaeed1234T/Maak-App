import 'dart:io';
import 'package:abokamall/controllers/ProfileController.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helpers/ServiceLocator.dart';

// Session storage
Map<String, dynamic> sessionUser = {
  'accountType': 'user',
  'firstName': 'الاسم الأول',
  'lastName': 'اسم العائلة',
  'username': 'اسم الشهرة',
  'email': 'email@example.com',
  'phone': '+123456789',
  'address': 'العنوان',
  'job': 'الوظيفة',
};
File? sessionImage;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ProfileController profileController;
  final picker = ImagePicker();
  File? _imageFile;
  bool notifications = true;

  // Common controllers
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController jobController;

  // Service provider controllers
  late TextEditingController bioController;
  late TextEditingController skillController;
  late TextEditingController specializationController;
  late TextEditingController payController;
  late TextEditingController businessController;
  late TextEditingController ownerController;

  @override
  void initState() {
    super.initState();
    profileController = getIt<ProfileController>();
    _initProfile();

    // Initialize common controllers
    firstNameController = TextEditingController(text: sessionUser['firstName']);
    lastNameController = TextEditingController(text: sessionUser['lastName']);
    usernameController = TextEditingController(text: sessionUser['username']);
    emailController = TextEditingController(text: sessionUser['email']);
    phoneController = TextEditingController(text: sessionUser['phone']);
    addressController = TextEditingController(text: sessionUser['address']);
    jobController = TextEditingController(text: sessionUser['job']);

    // Initialize service provider controllers
    bioController = TextEditingController(text: sessionUser['bio'] ?? '');
    skillController = TextEditingController(text: sessionUser['skill'] ?? '');
    specializationController = TextEditingController(
      text: sessionUser['specialization'] ?? '',
    );
    payController = TextEditingController(
      text: sessionUser['pay']?.toString() ?? '',
    );
    businessController = TextEditingController(
      text: sessionUser['business'] ?? '',
    );
    ownerController = TextEditingController(text: sessionUser['owner'] ?? '');

    _imageFile = sessionImage;
  }

  Future<void> _initProfile() async {
    final success = await profileController.fetchProfile();
    if (success) {
      setState(() {
        firstNameController.text = sessionUser['firstName'];
        lastNameController.text = sessionUser['lastName'];
        usernameController.text = sessionUser['username'];
        emailController.text = sessionUser['email'];
        phoneController.text = sessionUser['phone'];
        addressController.text = sessionUser['address'];
        jobController.text = sessionUser['job'];

        bioController.text = sessionUser['bio'] ?? '';
        skillController.text = sessionUser['skill'] ?? '';
        specializationController.text = sessionUser['specialization'] ?? '';
        payController.text = sessionUser['pay']?.toString() ?? '';
        businessController.text = sessionUser['business'] ?? '';
        ownerController.text = sessionUser['owner'] ?? '';

        _imageFile = sessionImage;
      });
    }
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        sessionImage = _imageFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountType = sessionUser['accountType'] ?? 'user';
    final points = sessionUser['points'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Points
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFF13A9F6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'نقاطي',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$points',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Image
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 48,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : (sessionUser['imageUrl'] != null
                          ? NetworkImage(sessionUser['imageUrl'])
                                as ImageProvider
                          : null),
                child: _imageFile == null && sessionUser['imageUrl'] == null
                    ? const Icon(Icons.person, size: 48)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Account type
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.verified_user, color: Color(0xFF13A9F6)),
                const SizedBox(width: 10),
                const Text(
                  'نوع الحساب: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
                Text(
                  formatAccountType(accountType),
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Editable fields for firstName and lastName
            _buildEditableField('الاسم الأول', firstNameController),
            _buildEditableField('اسم العائلة', lastNameController),
            // username read-only
            _buildReadOnlyField('اسم المستخدم', usernameController),

            // The other common fields, read-only
            _buildReadOnlyField('البريد الإلكتروني', emailController),
            _buildReadOnlyField('رقم الجوال', phoneController),
            _buildReadOnlyField('العنوان', addressController),
            _buildReadOnlyField('الوظيفة', jobController),

            const SizedBox(height: 12),

            // Service provider fields editable depending on account type
            if (accountType == 'worker') ...[
              _buildEditableField('المهارة', skillController),
              _buildEditableField('الأجر', payController),
            ] else if (accountType == 'contractor' ||
                accountType == 'engineer') ...[
              _buildEditableField('التخصص', specializationController),
              _buildEditableField('السيرة الذاتية', bioController),
              _buildEditableField('الأجر', payController),
              _buildEditableField('الشركة', businessController),
              _buildEditableField('المالك', ownerController),
            ] else if (accountType == 'company' ||
                accountType == 'marketplace') ...[
              _buildEditableField('الشركة', businessController),
              _buildEditableField('المالك', ownerController),
            ],

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
              onTap: () => Navigator.pushNamed(context, '/reset_password'),
            ),

            ListTile(
              title: const Text('تسجيل الخروج'),
              subtitle: const Text('سيتم تسجيل خروجك بعد موافقة الدعم'),
              onTap: () {
                setState(() {
                  sessionUser = {
                    'accountType': 'user',
                    'firstName': 'الاسم الأول',
                    'lastName': 'اسم العائلة',
                    'username': 'اسم الشهرة',
                    'email': 'email@example.com',
                    'phone': '+123456789',
                    'address': 'العنوان',
                    'job': 'الوظيفة',
                  };
                  sessionImage = null;
                });
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/splash', (route) => false);
              },
            ),

            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF13A9F6),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () async {
                final providerType = sessionUser['accountType'] ?? 'user';

                bool success = await profileController.updateProfile(
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  providerType: providerType,
                  bio: bioController.text,
                  skill: skillController.text,
                  specialization: specializationController.text,
                  pay: payController.text,
                  business: businessController.text,
                  owner: ownerController.text,
                );

                if (success) {
                  setState(() {
                    sessionUser['firstName'] = firstNameController.text;
                    sessionUser['lastName'] = lastNameController.text;
                    sessionUser['bio'] = bioController.text;
                    sessionUser['skill'] = skillController.text;
                    sessionUser['specialization'] =
                        specializationController.text;
                    sessionUser['pay'] = payController.text;
                    sessionUser['business'] = businessController.text;
                    sessionUser['owner'] = ownerController.text;
                    sessionImage = _imageFile;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حفظ الإعدادات بنجاح!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('حدث خطأ أثناء الحفظ.')),
                  );
                }
              },
              child: const Text('حفظ التغييرات'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  controller.text,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF13A9F6)),
            onPressed: () => _showEditDialog(label, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  controller.text,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock, color: Colors.grey),
        ],
      ),
    );
  }

  void _showEditDialog(String label, TextEditingController controller) {
    final editController = TextEditingController(text: controller.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل $label'),
        content: TextField(controller: editController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                controller.text = editController.text;
              });
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  String formatAccountType(String type) {
    switch (type.toLowerCase()) {
      case 'worker':
        return 'عامل';
      case 'engineer':
        return 'مهندس';
      case 'contractor':
        return 'مقاول';
      case 'company':
        return 'شركة';
      case 'marketplace':
        return 'سوق';
      case 'user':
        return 'مستخدم عادي';
      default:
        return 'غير محدد';
    }
  }
}
