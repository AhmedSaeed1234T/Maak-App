import 'dart:async';
import 'dart:io';

import 'package:abokamall/controllers/ProfileController.dart';
import 'package:abokamall/helpers/ContextFunctions.dart';
import 'package:abokamall/helpers/HelperMethods.dart';
import 'package:abokamall/helpers/ServiceLocator.dart';
import 'package:abokamall/helpers/TokenService.dart';
import 'package:abokamall/models/ApiMessage.dart';
import 'package:abokamall/models/UserProfile.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:abokamall/helpers/CustomSnackBar.dart';
import 'package:abokamall/data/egypt_locations.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});
  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  bool hasValidCache = false;
  bool _isConnected = true;
  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;

  Future<void> _checkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    setState(() {
      _isConnected = connectivityResult != ConnectivityResult.none;
    });

    // Optional: show warning when offline
    if (!_isConnected && mounted) {
      CustomSnackBar.show(
        context,
        message: "لا يوجد اتصال بالإنترنت - لا يمكن تعديل البيانات",
        type: SnackBarType.info,
      );
    }
  }

  final ProfileController _controller = getIt<ProfileController>();
  final TokenService tokenService = getIt<TokenService>();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasChanges = false;
  bool _isLogingOut = false;
  bool _isOccupied = false;
  bool _isLoadingOccupation = false;
  bool _isTogglingOccupation = false;
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
  String _marketplace = '';
  String _derivedSpec = '';
  int _workerTypes = 1;
  File? _newProfileImage;
  // State variables for cascading dropdowns
  String? _selectedGovernorate;
  String? _selectedCity;
  @override
  void initState() {
    super.initState();

    checkSessionValidity(context, tokenService);

    _connectivity = Connectivity(); // IMPORTANT: Initialize first

    _connectivityStream = _connectivity.onConnectivityChanged;
    _connectivityStream.listen(_onConnectivityChanged);

    _checkConnection();
    _loadProfile();
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    final isConnected = result != ConnectivityResult.none;

    if (!mounted) return;

    setState(() {
      _isConnected = isConnected;
    });

    if (!_isConnected) {
      CustomSnackBar.show(
        context,
        message: 'تم الاتصال بالإنترنت - يمكنك الآن تعديل البيانات',
        type: SnackBarType.info,
      );
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    final profile = await _controller.fetchProfile();

    if (!mounted) return;

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
        // Initialize state variables for cascading dropdowns
        _selectedGovernorate = profile.governorate;
        _selectedCity = profile.city;

        // Provider-specific fields
        if (profile.serviceProvider != null) {
          _pay = profile.serviceProvider!.pay.toString();
          _specialization = profile.serviceProvider!.specialization;
          _business = profile.serviceProvider!.business;
          _owner = profile.serviceProvider!.owner;
          _marketplace = profile.serviceProvider!.marketplace ?? '';
          _derivedSpec = profile.serviceProvider!.derivedSpec ?? '';
          _workerTypes = profile.serviceProvider!.workerTypes;
        }
      });
    } else {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'فشل تحميل الملف الشخصي',
          type: SnackBarType.error,
        );
        Navigator.pop(context);
      }
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Load occupation status
    _loadOccupationStatus();
  }

  Future<void> _loadOccupationStatus() async {
    setState(() => _isLoadingOccupation = true);
    final isOccupied = await _controller.getOccupationStatus();
    if (!mounted) return;
    setState(() {
      _isOccupied = isOccupied ?? false;
      _isLoadingOccupation = false;
    });
  }

  Future<void> _toggleOccupation() async {
    if (!_isConnected) {
      CustomSnackBar.show(
        context,
        message: 'لا يوجد اتصال بالإنترنت',
        type: SnackBarType.error,
      );
      return;
    }

    setState(() => _isTogglingOccupation = true);

    ApiMessage result;
    if (_isOccupied) {
      result = await _controller.removeOccupied();
    } else {
      result = await _controller.setOccupied();
    }

    if (!mounted) return;
    setState(() => _isTogglingOccupation = false);

    CustomSnackBar.show(
      context,
      message:
          result.message ?? (result.success ? "تم التحديث بنجاح" : "حدث خطأ"),
      type: result.success ? SnackBarType.success : SnackBarType.error,
    );

    if (result.success) {
      // Refresh occupation status
      await _loadOccupationStatus();
    }
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
      CustomSnackBar.show(
        context,
        message: 'لا توجد تغييرات للحفظ',
        type: SnackBarType.info,
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
    String? marketplace;
    String? derivedSpec;

    switch (providerType) {
      case 'worker':
      case 'assistant':
        specialization = _specialization;
        if (_marketplace.isNotEmpty) marketplace = _marketplace;
        if (_derivedSpec.isNotEmpty) derivedSpec = _derivedSpec;
        break;
      case 'sculptor':
        // Sculptors don't have specialization or derived spec
        workerTypes = _workerTypes;
        if (_marketplace.isNotEmpty) marketplace = _marketplace;
        break;
      case 'engineer':
        specialization = _specialization;
        if (_derivedSpec.isNotEmpty) derivedSpec = _derivedSpec;
        break;
      case 'marketplace':
        business = _business;
        owner = _owner;
        if (_marketplace.isNotEmpty) marketplace = _marketplace;
        if (_derivedSpec.isNotEmpty) derivedSpec = _derivedSpec;
        break;
      case 'contractor':
        specialization = _specialization;
        break;
      case 'company':
        business = _business;
        owner = _owner;
        break;
    }

    final result = await _controller.updateProfile(
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
      marketplace: marketplace,
      derivedSpec: derivedSpec,
      profileImage: _newProfileImage,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    CustomSnackBar.show(
      context,
      message: result.message ?? "حدث خطأ",
      type: result.success ? SnackBarType.success : SnackBarType.error,
    );

    if (result.success) {
      setState(() => _hasChanges = false);
      await _loadProfile(); // refresh data after save
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
            const Divider(height: 32, thickness: 1),
            // Occupation Status Section
            _buildOccupationStatusSection(),
            const SizedBox(height: 24),

            // Change Password Button
            /*SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConnected
                      ? const Color(0xFF13A9F6)
                      : Colors.grey[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'تغيير كلمة المرور',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            */
            const SizedBox(height: 16),
            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isConnected
                    ? (_isSaving ? null : _saveProfile)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _hasChanges
                      ? const Color(0xFF13A9F6)
                      : Colors.grey[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isConnected ? _logout : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConnected
                      ? Colors.red.shade500
                      : Colors.grey[400],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLogingOut
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'تسجيل الخروج',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            // Save Button
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
                      : (imageUrl.isNotEmpty
                                ? CachedNetworkImageProvider(imageUrl)
                                : null)
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
                  onTap: (_isConnected) ? _pickImage : null,
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
        Row(
          children: [
            Expanded(
              child: _buildNonEditableField(
                label: 'اسم المستخدم',
                value: _userProfile!.userName,
                icon: Icons.person,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _userProfile!.userName));
                CustomSnackBar.show(
                  context,
                  message: 'تم نسخ اسم المستخدم',
                  type: SnackBarType.info,
                );
              },
            ),
          ],
        ),

        // Email (non-editable)
        _buildNonEditableField(
          label: 'نقاط الاشتراك',
          value: _userProfile!.subscriptionPoints.toString(),
          icon: Icons.star_outline,
        ),

        // Phone number (non-editable)
        _buildNonEditableField(
          label: 'رقم الهاتف',
          value: _userProfile!.phoneNumber.substring(2),
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
          label: 'النقاط الاساسية',
          value: _userProfile!.points.toString(),
          icon: Icons.stars,
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
            Icon(Icons.location_on_outlined, color: const Color(0xFF13A9F6)),
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
          onEdit: () => _showGovernorateDialog(
            initialValue: _governorate,
            onSave: (value) {
              setState(() {
                _governorate = value;
                _selectedGovernorate = value;
                // Reset city and district when governorate changes
                _selectedCity = null;
              });
              _markAsChanged();
            },
          ),
        ),

        _buildDisplayField(
          label: 'المدينة',
          value: _city,
          icon: Icons.location_city,
          onEdit: () => _showCityDialog(
            initialValue: _city,
            onSave: (value) {
              setState(() {
                _city = value;
                _selectedCity = value;
              });
              _markAsChanged();
            },
          ),
        ),

        _buildDisplayField(
          label: 'الحي',
          value: _district,
          icon: Icons.home_outlined,
          onEdit: () => _showDistrictDialog(
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

      case 'assistant':
        return _buildAssistantSection();

      case 'sculptor':
        return _buildSculptorSection();
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
              'معلومات الصنايعى',
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

        _buildDisplayField(
          label: 'المحلات',
          value: _marketplace,
          icon: Icons.store,
          onEdit: () => _showEditDialog(
            title: 'تعديل المحلات',
            initialValue: _marketplace,
            onSave: (value) {
              setState(() => _marketplace = value);
              _markAsChanged();
            },
          ),
        ),

        _buildDisplayField(
          label: 'التخصص الفرعي',
          value: _derivedSpec,
          icon: Icons.build,
          onEdit: () => _showEditDialog(
            title: 'تعديل التخصص الفرعي',
            initialValue: _derivedSpec,
            onSave: (value) {
              setState(() => _derivedSpec = value);
              _markAsChanged();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAssistantSection() {
    const primary = Color(0xFF13A9F6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.work_outline, color: primary),
            const SizedBox(width: 8),
            Text(
              'معلومات الصنايعى',
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
          label: 'الأجر (جنيه/يومية)',
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
          value: 'يومية',
          icon: Icons.group,
        ),

        _buildDisplayField(
          label: 'المحلات',
          value: _marketplace,
          icon: Icons.store,
          onEdit: () => _showEditDialog(
            title: 'تعديل المحلات',
            initialValue: _marketplace,
            onSave: (value) {
              setState(() => _marketplace = value);
              _markAsChanged();
            },
          ),
        ),

        _buildDisplayField(
          label: 'التخصص الفرعي',
          value: _derivedSpec,
          icon: Icons.build,
          onEdit: () => _showEditDialog(
            title: 'تعديل التخصص الفرعي',
            initialValue: _derivedSpec,
            onSave: (value) {
              setState(() => _derivedSpec = value);
              _markAsChanged();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSculptorSection() {
    const primary = Color(0xFF13A9F6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.construction, color: primary),
            const SizedBox(width: 8),
            Text(
              'معلومات الهدام',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),

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

        _buildDisplayField(
          label: 'المحلات',
          value: _marketplace,
          icon: Icons.store,
          onEdit: () => _showEditDialog(
            title: 'تعديل المحلات',
            initialValue: _marketplace,
            onSave: (value) {
              setState(() => _marketplace = value);
              _markAsChanged();
            },
          ),
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

        _buildDisplayField(
          label: 'التخصص الفرعي',
          value: _derivedSpec,
          icon: Icons.build,
          onEdit: () => _showEditDialog(
            title: 'تعديل التخصص الفرعي',
            initialValue: _derivedSpec,
            onSave: (value) {
              setState(() => _derivedSpec = value);
              _markAsChanged();
            },
          ),
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
              'معلومات المحلات',
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

  Widget _buildOccupationStatusSection() {
    const primary = Color(0xFF13A9F6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.access_time, color: primary),
            const SizedBox(width: 8),
            Text(
              'حالة التوفر',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Occupation Status Display
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(
                _isOccupied ? Icons.block : Icons.check_circle,
                color: _isOccupied ? Colors.orange : Colors.green,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الحالة الحالية',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isLoadingOccupation
                          ? 'جاري التحميل...'
                          : (_isOccupied ? 'غير متاح' : 'متاح'),
                      style: TextStyle(
                        fontSize: 16,
                        color: _isOccupied ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Toggle Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isConnected && !_isTogglingOccupation
                ? _toggleOccupation
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isConnected && !_isTogglingOccupation
                  ? (_isOccupied ? Colors.green : Colors.orange)
                  : Colors.grey[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isTogglingOccupation
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    _isOccupied ? 'تعيين كمتاح' : 'تعيين كغير متاح',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
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
          if (_isConnected) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF13A9F6)),
              onPressed: onEdit,
            ),
          ],
        ],
      ),
    );
  }

  // List of Egyptian governorates
  static const List<String> _egyptianGovernorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الدقهلية',
    'الشرقية',
    'القليوبية',
    'كفر الشيخ',
    'الغربية',
    'المنوفية',
    'البحيرة',
    'دمياط',
    'بورسعيد',
    'السويس',
    'الإسماعيلية',
    'بني سويف',
    'الفيوم',
    'المنيا',
    'أسيوط',
    'سوهاج',
    'قنا',
    'الأقصر',
    'أسوان',
    'البحر الأحمر',
    'الوادي الجديد',
    'مطروح',
    'شمال سيناء',
    'جنوب سيناء',
    'الاخري', // Other option
  ];

  Future<void> _showGovernorateDialog({
    required String initialValue,
    required Function(String) onSave,
  }) async {
    String? selectedGovernorate;
    bool isOtherSelected = false;
    final controller = TextEditingController();

    // Initialize selection
    if (_egyptianGovernorates.contains(initialValue)) {
      selectedGovernorate = initialValue;
      isOtherSelected = initialValue == 'الاخري';
      if (isOtherSelected) {
        controller.text = initialValue;
      }
    } else if (initialValue.isNotEmpty) {
      // Custom value - set to "Other"
      selectedGovernorate = 'الاخري';
      isOtherSelected = true;
      controller.text = initialValue;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('تعديل المحافظة'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isOtherSelected) ...[
                    // Dropdown mode
                    DropdownButtonFormField<String>(
                      initialValue: selectedGovernorate,
                      decoration: InputDecoration(
                        labelText: 'المحافظة',
                        prefixIcon: const Icon(
                          Icons.location_on,
                          color: Color(0xFF13A9F6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _egyptianGovernorates.map((String governorate) {
                        return DropdownMenuItem<String>(
                          value: governorate,
                          child: Text(governorate),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedGovernorate = newValue;
                          if (newValue == 'الاخري') {
                            isOtherSelected = true;
                            controller.clear();
                          }
                        });
                      },
                      isExpanded: true,
                    ),
                  ] else ...[
                    // Text field mode (when "Other" is selected)
                    TextFormField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'المحافظة',
                        hintText: 'اكتب اسم المحافظة',
                        prefixIcon: const Icon(
                          Icons.location_on,
                          color: Color(0xFF13A9F6),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF13A9F6),
                          ),
                          onPressed: () {
                            setDialogState(() {
                              isOtherSelected = false;
                              selectedGovernorate = null;
                            });
                          },
                          tooltip: 'العودة للقائمة',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  String valueToSave;
                  if (isOtherSelected) {
                    valueToSave = controller.text.trim();
                  } else {
                    valueToSave = selectedGovernorate ?? '';
                  }

                  if (valueToSave.isNotEmpty) {
                    onSave(valueToSave);
                    Navigator.pop(context);
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        },
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

  Future<void> _logout() async {
    setState(() => _isLogingOut = true);
    bool allowed = await _controller.logout();
    if (!mounted) return;

    if (allowed == false) {
      if (mounted) {
        CustomSnackBar.show(
          context,
          message: 'لا يوجد اتصال بالإنترنت - تعذر تسجيل الخروج',
          type: SnackBarType.info,
        );
      }
      setState(() => _isLogingOut = false);
      return;
    }
    setState(() => _isLogingOut = false);

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _changePassword() {
    Navigator.pushNamed(context, '/reset_password');
  }

  Future<void> _showCityDialog({
    required String initialValue,
    required Function(String) onSave,
  }) async {
    String? selectedCity;
    bool isOtherSelected = false;
    final controller = TextEditingController();

    // Get cities for the selected governorate
    List<String> cityList = [];
    if (_selectedGovernorate != null &&
        _selectedGovernorate!.isNotEmpty &&
        _selectedGovernorate != 'الاخري') {
      cityList = [...getCityNames(_selectedGovernorate!), 'الاخري'];
    } else {
      cityList = ['الاخري'];
    }

    // Initialize selection
    if (cityList.contains(initialValue)) {
      selectedCity = initialValue;
      isOtherSelected = initialValue == 'الاخري';
      if (isOtherSelected) {
        controller.text = initialValue;
      }
    } else if (initialValue.isNotEmpty) {
      // Custom value - set to \"Other\"
      selectedCity = 'الاخري';
      isOtherSelected = true;
      controller.text = initialValue;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('تعديل المدينة'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (cityList.length == 1 && cityList[0] == 'الاخري') ...[
                    // Only \"Other\" option available (no governorate selected)
                    Text(
                      'يرجى اختيار المحافظة أولاً',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'المدينة',
                        hintText: 'اكتب اسم المدينة',
                        prefixIcon: const Icon(
                          Icons.location_city,
                          color: Color(0xFF13A9F6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ] else if (!isOtherSelected) ...[
                    // Dropdown mode
                    DropdownButtonFormField<String>(
                      initialValue: selectedCity,
                      decoration: InputDecoration(
                        labelText: 'المدينة',
                        prefixIcon: const Icon(
                          Icons.location_city,
                          color: Color(0xFF13A9F6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: cityList.map((String city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedCity = newValue;
                          if (newValue == 'الاخري') {
                            isOtherSelected = true;
                            controller.clear();
                          }
                        });
                      },
                      isExpanded: true,
                    ),
                  ] else ...[
                    // Text field mode (when \"Other\" is selected)
                    TextFormField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'المدينة',
                        hintText: 'اكتب اسم المدينة',
                        prefixIcon: const Icon(
                          Icons.location_city,
                          color: Color(0xFF13A9F6),
                        ),
                        suffixIcon: cityList.length > 1
                            ? IconButton(
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFF13A9F6),
                                ),
                                onPressed: () {
                                  setDialogState(() {
                                    isOtherSelected = false;
                                    selectedCity = null;
                                  });
                                },
                                tooltip: 'العودة للقائمة',
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  String valueToSave;
                  if (isOtherSelected || cityList.length == 1) {
                    valueToSave = controller.text.trim();
                  } else {
                    valueToSave = selectedCity ?? '';
                  }

                  if (valueToSave.isNotEmpty) {
                    onSave(valueToSave);
                    Navigator.pop(context);
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showDistrictDialog({
    required String initialValue,
    required Function(String) onSave,
  }) async {
    String? selectedDistrict;
    bool isOtherSelected = false;
    final controller = TextEditingController();

    // Get districts for the selected governorate and city
    List<String> districtList = [];
    if (_selectedGovernorate != null &&
        _selectedGovernorate!.isNotEmpty &&
        _selectedGovernorate != 'الاخري' &&
        _selectedCity != null &&
        _selectedCity!.isNotEmpty &&
        _selectedCity != 'الاخري') {
      final districts = getDistrictNames(_selectedGovernorate!, _selectedCity!);
      if (districts.isNotEmpty) {
        districtList = [...districts, 'الاخري'];
      } else {
        districtList = ['الاخري'];
      }
    } else {
      districtList = ['الاخري'];
    }

    // Initialize selection
    if (districtList.contains(initialValue)) {
      selectedDistrict = initialValue;
      isOtherSelected = initialValue == 'الاخري';
      if (isOtherSelected) {
        controller.text = initialValue;
      }
    } else if (initialValue.isNotEmpty) {
      // Custom value - set to \"Other\"
      selectedDistrict = 'الاخري';
      isOtherSelected = true;
      controller.text = initialValue;
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('تعديل الحي'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (districtList.length == 1 &&
                      districtList[0] == 'الاخري') ...[
                    // Only \"Other\" option available (no city selected)
                    Text(
                      'يرجى اختيار المحافظة والمدينة أولاً',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'الحي',
                        hintText: 'اكتب اسم الحي',
                        prefixIcon: const Icon(
                          Icons.home_outlined,
                          color: Color(0xFF13A9F6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ] else if (!isOtherSelected) ...[
                    // Dropdown mode
                    DropdownButtonFormField<String>(
                      initialValue: selectedDistrict,
                      decoration: InputDecoration(
                        labelText: 'الحي',
                        prefixIcon: const Icon(
                          Icons.home_outlined,
                          color: Color(0xFF13A9F6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: districtList.map((String district) {
                        return DropdownMenuItem<String>(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedDistrict = newValue;
                          if (newValue == 'الاخري') {
                            isOtherSelected = true;
                            controller.clear();
                          }
                        });
                      },
                      isExpanded: true,
                    ),
                  ] else ...[
                    // Text field mode (when \"Other\" is selected)
                    TextFormField(
                      controller: controller,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'الحي',
                        hintText: 'اكتب اسم الحي',
                        prefixIcon: const Icon(
                          Icons.home_outlined,
                          color: Color(0xFF13A9F6),
                        ),
                        suffixIcon: districtList.length > 1
                            ? IconButton(
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Color(0xFF13A9F6),
                                ),
                                onPressed: () {
                                  setDialogState(() {
                                    isOtherSelected = false;
                                    selectedDistrict = null;
                                  });
                                },
                                tooltip: 'العودة للقائمة',
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  String valueToSave;
                  if (isOtherSelected || districtList.length == 1) {
                    valueToSave = controller.text.trim();
                  } else {
                    valueToSave = selectedDistrict ?? '';
                  }

                  if (valueToSave.isNotEmpty) {
                    onSave(valueToSave);
                    Navigator.pop(context);
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        },
      ),
    );
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
