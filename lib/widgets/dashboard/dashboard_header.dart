import 'package:flutter/material.dart';

const primary = Color(0xFF13A9F6);

class DashboardHeader extends StatelessWidget {
  final bool hasInternet;

  const DashboardHeader({super.key, required this.hasInternet});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primary.withOpacity(0.15),
          ),
          child: const Icon(Icons.home_outlined, color: primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'أهلاً بك!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                hasInternet
                    ? 'اكتشف مقدمي الخدمات المتاحين'
                    : 'عرض البيانات المخزنة',
                style: TextStyle(
                  fontSize: 12,
                  color: hasInternet ? Colors.grey[600] : Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
