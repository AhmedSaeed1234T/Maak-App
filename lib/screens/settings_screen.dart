import 'dart:io';

import 'package:abokamall/controllers/ProfileController.dart';
import 'package:abokamall/helpers/HelperMethods.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/models/UserProfile.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});
  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}
class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final ProfileController _controller = getIt<ProfileController>();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasChanges = false;
  // Profile data from API
  UserProfile? _userProfile;
  // Local editable data
  String _firstName = '';
  String _lastName = '';
  String _bio = '';
  String _governorate = '';
  String _city = '';
  String _district = '';
  String _pay = '0';
  String _specialization = '';
  String _business = '';
  String _owner = '';
  int _workerTypes = 1;
  File? _newProfileImage;
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    final profile = await _controller.fetchProfile();

    if (profile != null) {
      setState(() {
        _userProfile = profile;
        // Populate local variables
        _firstName = profile.firstName;
        _lastName = profile.lastName;
        _bio = profile.serviceProvider?.bio ?? '';
        _governorate = profile.governorate;
        _city = profile.city;
        _district = profile.district;

        // Provider-specific fields
        if (profile.serviceProvider != null) {
          _pay = profile.serviceProvider!.pay.toString();
          _specialization = profile.serviceProvider!.specialization;
          _business = profile.serviceProvider!.business;
          _owner = profile.serviceProvider!.owner;
          _workerTypes = profile.serviceProvider!.workerTypes;
        }
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل تحميل الملف الشخصي'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _newProfileImage = File(pickedFile.path);
        _hasChanges = true;
      });
    }
  }
  void _markAsChanged() {
    setState(() => _hasChanges = true);
  }
  Future<void> _saveProfile() async {
    if (!_hasChanges) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد تغييرات للحفظ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    final providerType =
        _userProfile?.serviceProvider?.providerType.toLowerCase() ?? '';
    // Determine which fields to send based on provider type
    String? specialization;
    String? business;
    String? owner;
    int? workerTypes;

    switch (providerType) {
      case 'worker':
        specialization = _specialization;
        workerTypes = _workerTypes;
        break;
      case 'engineer':
        specialization = _specialization;
        break;
      case 'marketplace':
        business = _business;
        owner = _owner;
        break;
      case 'contractor':
        specialization = _specialization;
        break;
      case 'company':
        business = _business;
        owner = _owner;
        break;
    }

    final success = await _controller.updateProfile(
      firstName: _firstName,
      lastName: _lastName,
      bio: _bio,
      pay: _pay,
      governorate: _governorate,
      city: _city,
      district: _district,
      specialization: specialization,
      business: business,
      owner: owner,
      workerTypes: workerTypes,
      profileImage: _newProfileImage,
    );

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'تم الحفظ بنجاح ✓' : 'فشل الحفظ'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }

    if (success) {
      setState(() => _hasChanges = false);
      // Reload profile to get updated data
      await _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: primary),
              const SizedBox(height: 16),
              Text(
                'جاري تحميل الملف الشخصي...',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (_userProfile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('إعدادات الملف الشخصي')),
        body: const Center(child: Text('فشل تحميل البيانات')),
      );
    }

    final providerType =
        _userProfile!.serviceProvider?.providerType.toLowerCase() ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('إعدادات الملف الشخصي'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Image Section
            _buildProfileImageSection(),
            const SizedBox(height: 32),
            // Shared Fields Section
            _buildSharedFieldsSection(),
            const SizedBox(height: 24),
            const Divider(height: 32, thickness: 1),
            // Provider-Specific Section
            _buildProviderSpecificSection(providerType),
            const SizedBox(height: 24),
            // Change Password Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF13A9F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text('تغيير كلمة المرور', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text('تسجيل الخروج', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 24),
            // Save Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasChanges ? const Color(0xFF13A9F6) : Colors.grey[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: _hasChanges ? 4 : 0,
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _hasChanges ? 'حفظ التغييرات' : 'لا توجد تغييرات',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    final imageUrl = _userProfile!.imageUrl;

    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _newProfileImage != null
                      ? FileImage(_newProfileImage!)
                      : (imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null)
                            as ImageProvider?,
                  child: _newProfileImage == null && imageUrl.isEmpty
                      ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'اضغط لتغيير الصورة',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSharedFieldsSection() {
    const primary = Color(0xFF13A9F6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.person_outline, color: primary),
            const SizedBox(width: 8),
            Text(
              'المعلومات الأساسية',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Username (non-editable)
        _buildNonEditableField(
          label: 'اسم المستخدم',
          value: _userProfile!.userName,
          icon: Icons.person,
        ),

        // Email (non-editable)
        _buildNonEditableField(
          label: 'البريد الإلكتروني',
          value: _userProfile!.email,
          icon: Icons.email_outlined,
        ),

        // Phone number (non-editable)
        _buildNonEditableField(
          label: 'رقم الهاتف',
          value: _userProfile!.phoneNumber,
          icon: Icons.phone_outlined,
        ),

        _buildNonEditableField(
          label: 'الوظيفة',
          value: translateProviderTypeToArabic(
            _userProfile!.serviceProvider!.providerType,
          ),
          icon: Icons.person,
        ),

        _buildNonEditableField(
          label: 'النقاط',
          value: _userProfile!.points.toString(),
          icon: Icons.stars,
        ),
        _buildNonEditableField(
          label: 'اول يوم للاشتراك',
          value: _userProfile!.subscription!.startDate.toString(),
          icon: Icons.date_range,
        ),
        _buildNonEditableField(
          label: 'اخر يوم للاشتراك',
          value: _userProfile!.subscription!.endDate.toString(),

          icon: Icons.error,
        ),

        const SizedBox(height: 16),

        // First name
        _buildDisplayField(
          label:
              (_userProfile?.serviceProvider!.providerType == "Company" ||
                  _userProfile?.serviceProvider!.providerType == "Marketplace")
              ? 'الاسم'
              : 'الاسم الأول',
          value: _firstName,
          icon: Icons.person,
          onEdit: () => _showEditDialog(
            title: 'تعديل الاسم الأول',
            initialValue: _firstName,
            onSave: (value) {
              setState(() => _firstName = value);
              _markAsChanged();
            },
          ),
        ),

        // Last name
        (_userProfile?.serviceProvider!.providerType == "Company" ||
                _userProfile?.serviceProvider!.providerType == "Marketplace")
            ? SizedBox.shrink()
            : _buildDisplayField(
                label: 'اسم العائلة',
                value: _lastName,
                icon: Icons.person,
                onEdit: () => _showEditDialog(
                  title: 'تعديل اسم العائلة',
                  initialValue: _lastName,
                  onSave: (value) {
                    setState(() => _lastName = value);
                    _markAsChanged();
                  },
                ),
              ),

        // Bio
        _buildDisplayField(
          label: 'نبذة عنك',
          value: _bio.isEmpty ? 'لم يتم إضافة نبذة' : _bio,
          icon: Icons.info_outline,
          maxLines: 3,
          onEdit: () => _showEditDialog(
            title: 'تعديل النبذة',
            initialValue: _bio,
            maxLines: 4,
            onSave: (value) {
              setState(() => _bio = value);
              _markAsChanged();
            },
          ),
        ),

        const SizedBox(height: 24),

        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: const Color(0xFF13A9F6),
            ),
            const SizedBox(width: 8),
            Text(
              'العنوان',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildDisplayField(
          label: 'المحافظة',
          value: _governorate,
          icon: Icons.map,
          onEdit: () => _showEditDialog(
            title: 'تعديل المحافظة',
            initialValue: _governorate,
            onSave: (value) {
              setState(() => _governorate = value);
              _markAsChanged();
            },
          ),
        ),

        _buildDisplayField(
          label: 'المدينة',
          value: _city,
          icon: Icons.location_city,
          onEdit: () => _showEditDialog(
            title: 'تعديل المدينة',
            initialValue: _city,
            onSave: (value) {
              setState(() => _city = value);
              _markAsChanged();
            },
          ),
        ),

        _buildDisplayField(
          label: 'الحي',
          value: _district,
          icon: Icons.home_outlined,
          onEdit: () => _showEditDialog(
            title: 'تعديل الحي',
            initialValue: _district,
            onSave: (value) {
              setState(() => _district = value);
              _markAsChanged();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProviderSpecificSection(String providerType) {
    switch (providerType) {
      case 'worker':
        return _buildWorkerSection();
      case 'engineer':
        return _buildEngineerSection();
      case 'marketplace':
        return _buildMarketplaceSection();
      case 'contractor':
        return _buildContractorSection();
      case 'company':
        return _buildCompanySection();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWorkerSection() {
    const primary = Color(0xFF13A9F6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.work_outline, color: primary),
            const SizedBox(width: 8),
            Text(
              'معلومات العامل',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Specialization (non-editable)
        _buildNonEditableField(
          label: 'التخصص',
          value: _specialization,
          icon: Icons.construction,
        ),

        // Pay (editable)
        _buildDisplayField(
          label: _workerTypes == 0
              ? 'الأجر (جنيه/يومية)'
              : 'الأجر (جنيه/مشروع)',
          value: '$_pay جنيه',
          icon: Icons.attach_money,
          onEdit: () => _showEditDialog(
            title: 'تعديل الأجر',
            initialValue: _pay,
            keyboardType: TextInputType.number,
            onSave: (value) {
              setState(() => _pay = value);
              _markAsChanged();
            },
          ),
        ),

        // Worker type (non-editable)
        _buildNonEditableField(
          label: 'نوع العمل',
          value: _workerTypes == 1 ? 'مقطوعية' : 'يومية',
          icon: Icons.group,
        ),
      ],
    );
  }

  Widget _buildEngineerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.engineering_outlined,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'معلومات المهندس',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Specialization (non-editable)
        _buildNonEditableField(
          label: 'التخصص الهندسي',
          value: _specialization,
          icon: Icons.school,
        ),

        // Pay (editable)
        _buildDisplayField(
          label: 'الراتب (جنيه/شهر)',
          value: '$_pay جنيه',
          icon: Icons.attach_money,
          onEdit: () => _showEditDialog(
            title: 'تعديل الأجر',
            initialValue: _pay,
            keyboardType: TextInputType.number,
            onSave: (value) {
              setState(() => _pay = value);
              _markAsChanged();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMarketplaceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.store_outlined, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(
              'معلومات السوق',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildNonEditableField(
          label: 'اسم النشاط التجاري',
          value: _business,
          icon: Icons.business,
        ),

        _buildNonEditableField(
          label: 'اسم المالك',
          value: _owner,
          icon: Icons.person_outline,
        ),
      ],
    );
  }

  Widget _buildContractorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.handyman_outlined,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'معلومات المقاول',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildNonEditableField(
          label: 'التخصص',
          value: _specialization,
          icon: Icons.build,
        ),

        _buildDisplayField(
          label: 'الأجر (جنيه/مشروع)',
          value: '$_pay جنيه',
          icon: Icons.attach_money,
          onEdit: () => _showEditDialog(
            title: 'تعديل الأجر',
            initialValue: _pay,
            keyboardType: TextInputType.number,
            hint: 'الأجر التقريبي للمشروع الواحد',
            onSave: (value) {
              setState(() => _pay = value);
              _markAsChanged();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompanySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.apartment_outlined,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'معلومات الشركة',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildNonEditableField(
          label: 'اسم الشركة',
          value: _business,
          icon: Icons.business_center,
        ),

        _buildNonEditableField(
          label: 'اسم المالك/المدير',
          value: _owner,
          icon: Icons.person_outline,
        ),
      ],
    );
  }

  Widget _buildDisplayField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onEdit,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'غير محدد' : value,
                  style: TextStyle(
                    fontSize: 16,
                    color: value.isEmpty ? Colors.grey[400] : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: maxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF13A9F6)),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog({
    required String title,
    required String initialValue,
    required Function(String) onSave,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            autofocus: true,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'هذا الحقل مطلوب';
              if (keyboardType == TextInputType.number &&
                  double.tryParse(value) == null) {
                return 'يرجى إدخال رقم صحيح';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                onSave(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );

    // ✅ Remove this:
    // controller.dispose();
  }

  void _logout() async {
    await _controller.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/splash', (route) => false);
  }

  void _changePassword() {
    Navigator.pushNamed(context, '/reset_password');
  }
}

Widget _buildNonEditableField({
  required String label,
  required String value,
  required IconData icon,
  VoidCallback? onPressed, // optional button action
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey[300]!),
    ),
    child: Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value.isEmpty ? 'غير محدد' : value,
                style: TextStyle(
                  fontSize: 16,
                  color: value.isEmpty ? Colors.grey[400] : Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (onPressed != null)
          IconButton(
            icon: Icon(
              Icons.info_outline,
              color: Colors.grey[400],
            ), // or any icon
            onPressed: onPressed,
          ),
      ],
    ),
  );
}