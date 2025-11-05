import 'package:flutter/material.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // أمثلة يجب استبدالها بالبيانات القادمة من backend لاحقاً
    final results = [
      {'name': 'جابر', 'profession': 'كهربائي', 'location': 'القاهرة', 'price': '50ج/ساعة', 'type': 'worker'},
      {'name': 'سامي', 'profession': 'سباك', 'location': 'القاهرة', 'price': '45ج/ساعة', 'type': 'worker'},
      {'name': 'شركة بناء', 'profession': 'شركة', 'location': 'القاهرة', 'price': 'تبدأ من 500ج', 'type': 'company'},
      {'name': 'أحمد علي', 'profession': 'مهندس مدني', 'location': 'الإسكندرية', 'price': '150ج/ساعة', 'type': 'engineer'},
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('نتائج البحث', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Color(0xFFF7FAFF),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${results.length} نتيجة وُجدت',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: results.length,
              itemBuilder: (ctx, i) {
                final r = results[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 13),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Color(0xFFE8F0F8), child: Icon(Icons.person, color: Color(0xFF13A9F6))),
                    title: Text(r['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${r['profession']}\n${r['location']}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(r['price']!, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        SizedBox(height: 7),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF13A9F6), minimumSize: Size(53, 30)),
                          onPressed: () {
                            // انتقال لصفحة details حسب النوع
                            switch (r['type']) {
                              case 'worker':
                                Navigator.pushNamed(context, '/profile_worker');
                                break;
                              case 'engineer':
                                Navigator.pushNamed(context, '/profile_engineer');
                                break;
                              case 'company':
                                Navigator.pushNamed(context, '/profile_company');
                                break;
                            }
                          },
                          child: const Text('عرض'),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // ترقيم الصفحات (Pagination)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: Icon(Icons.arrow_back_ios_new), onPressed: () {}),
                for (var i=1; i<=3; i++) ...[
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 3),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: i==1? Color(0xFF13A9F6): Colors.white,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text('$i', style: TextStyle(color: i==1? Colors.white : Colors.black)),
                  )
                ],
                IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: () {}),
              ],
            ),
          )
        ],
      ),
    );
  }
}
