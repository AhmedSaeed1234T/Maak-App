import 'package:flutter/material.dart';

/// List of Egyptian governorates in Arabic
const List<String> egyptianGovernorates = [
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

/// Reusable Governorate Dropdown Field Widget
class GovernorateDropdownField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Color primaryColor;
  final bool isRequired;

  const GovernorateDropdownField({
    Key? key,
    required this.controller,
    this.validator,
    this.primaryColor = const Color(0xFF13A9F6),
    this.isRequired = true,
  }) : super(key: key);

  @override
  State<GovernorateDropdownField> createState() =>
      _GovernorateDropdownFieldState();
}

class _GovernorateDropdownFieldState extends State<GovernorateDropdownField> {
  String? selectedGovernorate;
  bool isOtherSelected = false;

  @override
  void initState() {
    super.initState();
    // Initialize from controller if it has a value
    if (widget.controller.text.isNotEmpty) {
      if (egyptianGovernorates.contains(widget.controller.text)) {
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
      value: selectedGovernorate,
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
      items: egyptianGovernorates.map((String governorate) {
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
      },
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down, color: widget.primaryColor),
    );
  }
}

/// Reusable City Text Field Widget
class CityTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Color primaryColor;
  final bool isRequired;

  const CityTextField({
    Key? key,
    required this.controller,
    this.validator,
    this.primaryColor = const Color(0xFF13A9F6),
    this.isRequired = true,
  }) : super(key: key);

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

/// Reusable District Text Field Widget
class DistrictTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Color primaryColor;
  final bool isRequired;

  const DistrictTextField({
    Key? key,
    required this.controller,
    this.validator,
    this.primaryColor = const Color(0xFF13A9F6),
    this.isRequired = false,
  }) : super(key: key);

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
