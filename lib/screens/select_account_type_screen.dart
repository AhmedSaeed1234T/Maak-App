import 'package:flutter/material.dart';

class SelectAccountTypeScreen extends StatelessWidget {
  const SelectAccountTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Color(0xFFF7FAFF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'اختر نوع الحساب',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: ListView(
                children: [
                  _AccountTypeTile(
                    icon: Icons.build,
                    label: 'عامل',
                    description: 'تقديم خدمات فردية.',
                    onPressed: () {
                      Navigator.pushNamed(context, '/register_worker');
                    },
                  ),
                  _AccountTypeTile(
                    icon: Icons.engineering,
                    label: 'مقاول أو مهندس',
                    description: 'تقديم خدمات فنية متخصصة.',
                    onPressed: () {
                      Navigator.pushNamed(context, '/register_engineer');
                    },
                  ),
                  _AccountTypeTile(
                    icon: Icons.store_mall_directory,
                    label: 'شركة أو متجر تجارى',
                    description: 'عرض نشاطك أو خدماتك.',
                    onPressed: () {
                      Navigator.pushNamed(context, '/register_company');
                    },
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('لديك حساب بالفعل؟ '),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text(
                    'سجّل دخول',
                    style: TextStyle(
                      color: Color(0xFF13A9F6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTypeTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Color(0xFF13A9F6)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.black38,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
