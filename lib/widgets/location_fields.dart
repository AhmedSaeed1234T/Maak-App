import 'package:flutter/material.dart';
import 'package:abokamall/data/egypt_locations.dart';

/// Reusable Governorate Dropdown Field Widget
class GovernorateDropdownField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Color primaryColor;
  final bool isRequired;
  final Function(String?)? onChanged;

  const GovernorateDropdownField({
    super.key,
    required this.controller,
    this.validator,
    this.primaryColor = const Color(0xFF13A9F6),
    this.isRequired = true,
    this.onChanged,
  });

  @override
  State<GovernorateDropdownField> createState() =>
      _GovernorateDropdownFieldState();
}

class _GovernorateDropdownFieldState extends State<GovernorateDropdownField> {
  String? selectedGovernorate;
  bool isOtherSelected = false;
  final List<String> governorateList = [...getGovernorateNames(), 'الاخري'];

  @override
  void initState() {
    super.initState();
    // Initialize from controller if it has a value
    if (widget.controller.text.isNotEmpty) {
      if (governorateList.contains(widget.controller.text)) {
        selectedGovernorate = widget.controller.text;
        isOtherSelected = widget.controller.text == 'الاخري';
      } else {
        // Custom value - set to "Other"
        selectedGovernorate = 'الاخري';
        isOtherSelected = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isOtherSelected && selectedGovernorate == 'الاخري') {
      // Show text field when "Other" is selected
      return TextFormField(
        controller: widget.controller,
        validator: widget.isRequired
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'المحافظة مطلوبة';
                }
                return null;
              }
            : widget.validator,
        decoration: InputDecoration(
          labelText: 'المحافظة *',
          hintText: 'اكتب اسم المحافظة',
          prefixIcon: Icon(Icons.location_on, color: widget.primaryColor),
          suffixIcon: IconButton(
            icon: Icon(Icons.arrow_drop_down, color: widget.primaryColor),
            onPressed: () {
              setState(() {
                isOtherSelected = false;
                selectedGovernorate = null;
                widget.controller.clear();
              });
              if (widget.onChanged != null) {
                widget.onChanged!(null);
              }
            },
            tooltip: 'العودة للقائمة',
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      );
    }

    // Show dropdown
    return DropdownButtonFormField<String>(
      initialValue: selectedGovernorate,
      decoration: InputDecoration(
        labelText: 'المحافظة ${widget.isRequired ? '*' : ''}',
        prefixIcon: Icon(Icons.location_on, color: widget.primaryColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: widget.isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'المحافظة مطلوبة';
              }
              return null;
            }
          : widget.validator,
      items: governorateList.map((String governorate) {
        return DropdownMenuItem<String>(
          value: governorate,
          child: Text(governorate, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          selectedGovernorate = newValue;
          if (newValue == 'الاخري') {
            isOtherSelected = true;
            widget.controller.clear();
          } else {
            isOtherSelected = false;
            widget.controller.text = newValue ?? '';
          }
        });
        if (widget.onChanged != null) {
          widget.onChanged!(newValue);
        }
      },
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down, color: widget.primaryColor),
    );
  }
}

/// Reusable City Dropdown Field Widget with cascading based on governorate
class CityDropdownField extends StatefulWidget {
  final TextEditingController controller;
  final String? selectedGovernorate;
  final String? Function(String?)? validator;
  final Color primaryColor;
  final bool isRequired;
  final Function(String?)? onChanged;

  const CityDropdownField({
    super.key,
    required this.controller,
    required this.selectedGovernorate,
    this.validator,
    this.primaryColor = const Color(0xFF13A9F6),
    this.isRequired = true,
    this.onChanged,
  });

  @override
  State<CityDropdownField> createState() => _CityDropdownFieldState();
}

class _CityDropdownFieldState extends State<CityDropdownField> {
  String? selectedCity;
  bool isOtherSelected = false;
  List<String> cityList = [];

  @override
  void initState() {
    super.initState();
    _updateCityList();
    _initializeSelectedCity();
  }

  @override
  void didUpdateWidget(CityDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedGovernorate != widget.selectedGovernorate) {
      _updateCityList();
      // Reset city selection when governorate changes
      // Use post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            selectedCity = null;
            isOtherSelected = false;
            widget.controller.clear();
          });
          if (widget.onChanged != null) {
            widget.onChanged!(null);
          }
        }
      });
    }
  }

  void _updateCityList() {
    if (widget.selectedGovernorate != null &&
        widget.selectedGovernorate!.isNotEmpty &&
        widget.selectedGovernorate != 'الاخري') {
      cityList = [...getCityNames(widget.selectedGovernorate!), 'الاخري'];
    } else {
      cityList = ['الاخري'];
    }
  }

  void _initializeSelectedCity() {
    if (widget.controller.text.isNotEmpty) {
      if (cityList.contains(widget.controller.text)) {
        selectedCity = widget.controller.text;
        isOtherSelected = widget.controller.text == 'الاخري';
      } else if (widget.controller.text != '') {
        // Custom value - set to "Other"
        selectedCity = 'الاخري';
        isOtherSelected = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isOtherSelected && selectedCity == 'الاخري') {
      // Show text field when "Other" is selected
      return TextFormField(
        controller: widget.controller,
        validator: widget.isRequired
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'المدينة مطلوبة';
                }
                return null;
              }
            : widget.validator,
        decoration: InputDecoration(
          labelText: 'المدينة ${widget.isRequired ? '*' : ''}',
          hintText: 'اكتب اسم المدينة',
          prefixIcon: Icon(Icons.location_city, color: widget.primaryColor),
          suffixIcon: IconButton(
            icon: Icon(Icons.arrow_drop_down, color: widget.primaryColor),
            onPressed: () {
              setState(() {
                isOtherSelected = false;
                selectedCity = null;
                widget.controller.clear();
              });
              if (widget.onChanged != null) {
                widget.onChanged!(null);
              }
            },
            tooltip: 'العودة للقائمة',
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      );
    }

    // Show dropdown
    return DropdownButtonFormField<String>(
      initialValue: selectedCity,
      decoration: InputDecoration(
        labelText: 'المدينة ${widget.isRequired ? '*' : ''}',
        prefixIcon: Icon(Icons.location_city, color: widget.primaryColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: widget.isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'المدينة مطلوبة';
              }
              return null;
            }
          : widget.validator,
      items: cityList.map((String city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: cityList.isEmpty
          ? null
          : (String? newValue) {
              setState(() {
                selectedCity = newValue;
                if (newValue == 'الاخري') {
                  isOtherSelected = true;
                  widget.controller.clear();
                } else {
                  isOtherSelected = false;
                  widget.controller.text = newValue ?? '';
                }
              });
              if (widget.onChanged != null) {
                widget.onChanged!(newValue);
              }
            },
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down, color: widget.primaryColor),
    );
  }
}

/// Reusable District Dropdown Field Widget with cascading based on city
class DistrictDropdownField extends StatefulWidget {
  final TextEditingController controller;
  final String? selectedGovernorate;
  final String? selectedCity;
  final String? Function(String?)? validator;
  final Color primaryColor;
  final bool isRequired;

  const DistrictDropdownField({
    super.key,
    required this.controller,
    required this.selectedGovernorate,
    required this.selectedCity,
    this.validator,
    this.primaryColor = const Color(0xFF13A9F6),
    this.isRequired = false,
  });

  @override
  State<DistrictDropdownField> createState() => _DistrictDropdownFieldState();
}

class _DistrictDropdownFieldState extends State<DistrictDropdownField> {
  String? selectedDistrict;
  bool isOtherSelected = false;
  List<String> districtList = [];

  @override
  void initState() {
    super.initState();
    _updateDistrictList();
    _initializeSelectedDistrict();
  }

  @override
  void didUpdateWidget(DistrictDropdownField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedGovernorate != widget.selectedGovernorate ||
        oldWidget.selectedCity != widget.selectedCity) {
      _updateDistrictList();
      // Reset district selection when governorate or city changes
      // Use post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            selectedDistrict = null;
            isOtherSelected = false;
            widget.controller.clear();
          });
        }
      });
    }
  }

  void _updateDistrictList() {
    if (widget.selectedGovernorate != null &&
        widget.selectedGovernorate!.isNotEmpty &&
        widget.selectedGovernorate != 'الاخري' &&
        widget.selectedCity != null &&
        widget.selectedCity!.isNotEmpty &&
        widget.selectedCity != 'الاخري') {
      final districts = getDistrictNames(
        widget.selectedGovernorate!,
        widget.selectedCity!,
      );
      if (districts.isNotEmpty) {
        districtList = [...districts, 'الاخري'];
      } else {
        districtList = ['الاخري'];
      }
    } else {
      districtList = ['الاخري'];
    }
  }

  void _initializeSelectedDistrict() {
    if (widget.controller.text.isNotEmpty) {
      if (districtList.contains(widget.controller.text)) {
        selectedDistrict = widget.controller.text;
        isOtherSelected = widget.controller.text == 'الاخري';
      } else if (widget.controller.text != '') {
        // Custom value - set to "Other"
        selectedDistrict = 'الاخري';
        isOtherSelected = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isOtherSelected && selectedDistrict == 'الاخري') {
      // Show text field when "Other" is selected
      return TextFormField(
        controller: widget.controller,
        validator: widget.isRequired
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الحي مطلوب';
                }
                return null;
              }
            : widget.validator,
        decoration: InputDecoration(
          labelText: 'الحي ${widget.isRequired ? '*' : ''}',
          hintText: 'اكتب اسم الحي',
          prefixIcon: Icon(
            Icons.location_on_outlined,
            color: widget.primaryColor,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.arrow_drop_down, color: widget.primaryColor),
            onPressed: () {
              setState(() {
                isOtherSelected = false;
                selectedDistrict = null;
                widget.controller.clear();
              });
            },
            tooltip: 'العودة للقائمة',
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),
          labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: widget.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
        ),
      );
    }

    // Show dropdown
    return DropdownButtonFormField<String>(
      initialValue: selectedDistrict,
      decoration: InputDecoration(
        labelText: 'الحي ${widget.isRequired ? '*' : ''}',
        prefixIcon: Icon(
          Icons.location_on_outlined,
          color: widget.primaryColor,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: widget.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: widget.isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'الحي مطلوب';
              }
              return null;
            }
          : widget.validator,
      items: districtList.map((String district) {
        return DropdownMenuItem<String>(
          value: district,
          child: Text(district, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: districtList.isEmpty
          ? null
          : (String? newValue) {
              setState(() {
                selectedDistrict = newValue;
                if (newValue == 'الاخري') {
                  isOtherSelected = true;
                  widget.controller.clear();
                } else {
                  isOtherSelected = false;
                  widget.controller.text = newValue ?? '';
                }
              });
            },
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down, color: widget.primaryColor),
    );
  }
}

// Keep the old text field widgets for backward compatibility
/// Reusable City Text Field Widget (Legacy - for backward compatibility)
class CityTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Color primaryColor;
  final bool isRequired;

  const CityTextField({
    super.key,
    required this.controller,
    this.validator,
    this.primaryColor = const Color(0xFF13A9F6),
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'المدينة مطلوبة';
              }
              return null;
            }
          : validator,
      decoration: InputDecoration(
        labelText: 'المدينة ${isRequired ? '*' : ''}',
        prefixIcon: Icon(Icons.location_city, color: primaryColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}

/// Reusable District Text Field Widget (Legacy - for backward compatibility)
class DistrictTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Color primaryColor;
  final bool isRequired;

  const DistrictTextField({
    super.key,
    required this.controller,
    this.validator,
    this.primaryColor = const Color(0xFF13A9F6),
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: isRequired
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'الحي مطلوب';
              }
              return null;
            }
          : validator,
      decoration: InputDecoration(
        labelText: 'الحي ${isRequired ? '*' : ''}',
        prefixIcon: Icon(Icons.location_on_outlined, color: primaryColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        labelStyle: const TextStyle(fontSize: 14, color: Colors.black87),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
