import 'package:flutter/material.dart';

class SelectAccountTypeScreen extends StatelessWidget {
  const SelectAccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Color(0xFFF7FAFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Header with icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [primary, primary.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [BoxShadow(color: primary.withOpacity(0.2), blurRadius: 12, offset: Offset(0, 6))],
                ),
                child: const Icon(Icons.person_add, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  const Text(
                    'اختر نوع الحساب',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'حدد النوع الذي ينطبق على نشاطك',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Account type tiles
            _AccountTypeTile(
              icon: Icons.build,
              label: 'عامل',
              description: 'تقديم خدمات فردية.',
              onPressed: () {
                Navigator.pushNamed(context, '/register_worker');
              },
            ),
            const SizedBox(height: 12),
            _AccountTypeTile(
              icon: Icons.engineering,
              label: 'مقاول أو مهندس',
              description: 'تقديم خدمات فنية متخصصة.',
              onPressed: () {
                Navigator.pushNamed(context, '/register_engineer');
              },
            ),
            const SizedBox(height: 12),
            _AccountTypeTile(
              icon: Icons.store_mall_directory,
              label: 'شركة أو متجر تجارى',
              description: 'عرض نشاطك أو خدماتك.',
              onPressed: () {
                Navigator.pushNamed(context, '/register_company');
              },
            ),
            const SizedBox(height: 32),
            // Login Link
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('لديك حساب بالفعل؟ ', style: TextStyle(fontSize: 14, color: Colors.black87)),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text(
                      'سجّل دخول',
                      style: TextStyle(
                        color: Color(0xFF13A9F6),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AccountTypeTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final String description;
  final VoidCallback onPressed;

  const _AccountTypeTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.onPressed,
  });

  @override
  State<_AccountTypeTile> createState() => _AccountTypeTileState();
}

class _AccountTypeTileState extends State<_AccountTypeTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF13A9F6);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Card(
        elevation: _isHovered ? 8 : 2,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: widget.onPressed,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withOpacity(0.1),
                  ),
                  child: Icon(widget.icon, size: 28, color: primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: primary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
