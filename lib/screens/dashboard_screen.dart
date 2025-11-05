import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String search = '';
  int tabIndex = 0;
  final List<String> tabs = ['الكل', 'العمال', 'المهندسين', 'الشركات', 'المتاجر'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF6FAFF),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'ابحث عن عامل، مهندس، شركة...'
                          , filled: true, fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                      onChanged: (v) => setState(() { search = v; }),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_alt, color: Color(0xFF13A9F6)),
                    onPressed: () { Navigator.pushNamed(context, '/filters'); },
                  )
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tabs.length,
                  itemBuilder: (ctx, i) => GestureDetector(
                    onTap: () => setState(() => tabIndex = i),
                    child: Container(
                      margin: EdgeInsets.only(left: 12),
                      padding: EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        color: tabIndex == i ? Color(0xFF13A9F6) : Color(0xFFE8F0F8),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        tabs[i],
                        style: TextStyle(
                          color: tabIndex == i ? Colors.white : Colors.black54,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Text("مقدمو الخدمة", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5, // عدل لاحقا حسب البيانات القادمة من backend
                  itemBuilder: (ctx, i) => Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        backgroundImage: null, // ضع صورة حقيقية عند الربط مع backend
                        child: Icon(Icons.person, size: 28, color: Color(0xFF13A9F6)),
                      ),
                      SizedBox(height: 7),
                      Text("اسم", style: TextStyle(fontSize: 13)),
                      Text("نوع", style: TextStyle(fontSize: 11, color: Colors.black45))
                    ],
                  ),
                  separatorBuilder: (_, __) => SizedBox(width: 18),
                ),
              ),
              const SizedBox(height: 24),
              Text("المميزون", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/profile_company'),
                      child: _featuredCard("شركة مميزة", Icons.domain),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/profile_worker'),
                      child: _featuredCard("عامل مميز", Icons.engineering),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18)
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF13A9F6)),
                child: const Text('الدفع'),
                onPressed: () {
                  Navigator.pushNamed(context, '/payment');
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(foregroundColor: Color(0xFF13A9F6)),
                child: const Text('خدمة العملاء'),
                onPressed: () {
                  Navigator.pushNamed(context, '/payment'); // أو استدعِ دالة الواتساب مباشرة لو أردتها هكذا
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _featuredCard(String title, IconData icon) {
  return Expanded(
    child: Container(
      height: 78,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(1,2),
        )],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Color(0xFF13A9F6)),
            SizedBox(height: 6),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold ,fontSize: 13)),
            Text("شركة", style: TextStyle(fontSize: 11, color: Colors.black38)),
          ],
        ),
      ),
    ),
  );
}
